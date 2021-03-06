json.allowAttachment question.allow_attachment? unless question.hide_text?
json.autogradable question.auto_gradable?

json.solutions question.solutions.each do |solution|
  json.solutionType solution.solution_type
  json.solution format_inline_text(solution.solution)
  json.grade solution.grade
end if can_grade && question.auto_gradable?
