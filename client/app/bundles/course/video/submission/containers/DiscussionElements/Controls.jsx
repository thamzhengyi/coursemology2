import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import IconButton from 'material-ui/IconButton';
import OnDemandVideo from 'material-ui/svg-icons/notification/ondemand-video';
import Refresh from 'material-ui/svg-icons/navigation/refresh';
import { cyan500 as activeColor, grey700 as inactiveColor } from 'material-ui/styles/colors';

import { changeAutoScroll, refreshDiscussion } from '../../actions/discussion';

const propTypes = {
  autoScroll: PropTypes.bool,
  onAutoScrollToggle: PropTypes.func,
  onRefresh: PropTypes.func,
};

const defaultProps = {
  autoScroll: false,
};

function Controls(props) {
  return (
    <div>
      <IconButton onClick={props.onRefresh}>
        <Refresh />
      </IconButton>
      <IconButton
        tooltip="Toggle Live Comments"
        onClick={() => props.onAutoScrollToggle(!props.autoScroll)}
      >
        <OnDemandVideo color={props.autoScroll ? activeColor : inactiveColor} />
      </IconButton>
    </div>
  );
}

Controls.propTypes = propTypes;
Controls.defaultProps = defaultProps;

function mapStateToProps(state) {
  return {
    autoScroll: state.discussion.autoScroll,
  };
}

function mapDispatchToProps(dispatch) {
  return {
    onAutoScrollToggle: newState => dispatch(changeAutoScroll(newState)),
    onRefresh: () => dispatch(refreshDiscussion()),
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(Controls);
