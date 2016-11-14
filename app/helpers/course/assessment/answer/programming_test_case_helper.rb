module Course::Assessment::Answer::ProgrammingTestCaseHelper
  # Get a hint message. Use the one from test_result if available, else fallback to the one from
  # the test case.
  #
  # @param [Course::Assessment::Question::ProgrammingTestCase] The test case
  # @param [Course::Assessment::Answer::ProgrammingAutoGradingTestResult] The test result
  # @return [String] The hint, or an empty string if there isn't one
  def get_hint(test_case, test_case_result)
    hint = test_case_result.messages['hint'] if test_case_result
    hint ||= test_case.hint
    hint || ''
  end

  # Get the output message for the tutors to see when grading. Use the output meta attribute if
  # available, else fallback to the failure message, error message, and finally empty string.
  #
  # @param [Course::Assessment::Answer::ProgrammingAutoGradingTestResult] The test result
  # @return [String] The output, failure message, error message or empty string
  #   if the previous 3 don't exist.
  def get_output(test_case_result)
    if test_case_result
      output = test_case_result.messages['output']
      output = test_case_result.messages['failure'] if output.blank?
      output = test_case_result.messages['error'] if output.blank?
    end
    output || ''
  end

  # If the test case type has a failed test case, return the first one.
  #
  # @param [Hash] test_cases_by_type The test cases and their results keyed by type
  # @return [Hash] Failed test case and its result, if any
  def get_failed_test_cases_by_type(test_cases_and_results)
    {}.tap do |result|
      test_cases_and_results.each do |test_case_type, test_cases_and_results_of_type|
        result[test_case_type] = get_first_failed_test(test_cases_and_results_of_type)
      end
    end
  end

  # Organize the test cases and test results into a hash, keyed by test case type.
  #   If there is no test result, the test case key points to nil.
  #   nil is needed to make sure test cases are still displayed before they have a test result.
  #   Currently test_cases are ordered by sorting on the identifier of the ProgrammingTestCase.
  # e.g. { 'public_test': { test_case_1: result_1, test_case_2: result_2, test_case_3: nil },
  #        'private_test': { priv_case_1: priv_result_1 },
  #        'evaluation_test': { eval_case1: eval_result_1 } }
  #
  # @param [Hash] test_cases_by_type The test cases keyed by type
  # @param [Course::Assessment::Answer::ProgrammingAutoGrading] auto_grading Auto grading object
  # @return [Hash] The hash structure described above
  def get_test_cases_and_results(test_cases_by_type, auto_grading)
    answer_test_results_hash = map_answers_to_test_results(auto_grading)
    {}.tap do |result|
      test_cases_by_type.each do |test_case_type, test_cases|
        result[test_case_type] = test_cases.map do |test_case|
          [test_case, answer_test_results_hash[test_case]]
        end.sort_by { |test_case, _| test_case.identifier }.to_h
      end
    end
  end

  # Return the bootstrap class for highlighting the test case row.
  #
  # @param [Course::Assessment::Answer::ProgrammingAutoGradingTestResult] test_case_result The
  #   test case result.
  # @return [Array<String>] ['bg-success', 'text-success'], ['bg-danger', 'text-danger'] or an
  # empty array if there is no test_case_result.
  def test_result_class(test_case_result)
    return [] unless test_case_result
    test_case_result.passed? ? ['bg-success', 'text-success'] : ['bg-danger', 'text-danger']
  end

  private

  # Return a hash of the first failing test case and its test result
  #
  # @param [Hash] test_cases_and_results_of_type A hash of test cases and results keyed by type
  # @return [Hash] the failed test case and result, nil if all tests passed
  def get_first_failed_test(test_cases_and_results_of_type)
    test_cases_and_results_of_type.each do |test_case, test_result|
      return [[test_case, test_result]].to_h if test_result && !test_result.passed?
    end
    nil
  end

  # Convert an AutoGrading object to hash of test results, keyed by test case
  #
  # @param [Course::Assessment::Answer::ProgrammingAutoGrading] auto_grading Auto grading object
  # @return [Hash] Hash of test results, keyed by test case
  def map_answers_to_test_results(auto_grading)
    return {} unless auto_grading
    auto_grading.test_results.map { |result| [result.test_case, result] }.to_h
  end
end
