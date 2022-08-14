//= require eac_rails_utils/url_helper

if (typeof TasksScheduler == "undefined") {
  TasksScheduler = function() {};
}

TasksScheduler.Alert = function() {};

_A = TasksScheduler.Alert;

_A.DEFAULT_REFRESH_INTERVAL = 5000;
_A.DEFAULT_ELEMENT_SELECTOR = '#tasks_scheduler_alert';
_A.CSS_CLASSES_PREFIX = 'alert_';
_A.url = EacRailsUtils.UrlHelper.path_for('/tasks_scheduler_daemon/status');

_A.init = function(options) {
  options = typeof options !== 'undefined' ? options : {};
  $(document).ready(function() {
    _A.options = options;
    if (!_A.options.refresh_interval) {
      _A.options.refresh_interval = _A.DEFAULT_REFRESH_INTERVAL;
    }
    if (!_A.options.element_selector) {
      _A.options.element_selector = _A.DEFAULT_ELEMENT_SELECTOR;
    }
    _A.refresh();
  });
};

_A.setNextRefresh = function() {
  setTimeout(_A.refresh, _A.options.refresh_interval);
};

_A.refresh = function() {
  $.ajax(_A.refreshAjaxData());
};

_A.refreshAjaxData = function() {
  return {
    url: _A.url,
    success: function(result) {
      var alert = $(_A.options.element_selector);
      var pattern = new RegExp('(^|\\s)' + _A.CSS_CLASSES_PREFIX + "\\S+", 'g');
      alert.removeClass(function(index, className) {
        return (className.match(pattern) || []).join(' ');
      });
      alert.addClass(_A.resultToCssClass(result));
    },
    complete: function(result) {
      _A.setNextRefresh();
    }
  };
};

_A.resultToCssClass = function(result) {
  var suffix = "ok"
  if (!result.daemon_running) {
    suffix = "daemon_stopped";
  } else if (!result.tasks_all_ok) {
    suffix = "task_failed";
  }
  return _A.CSS_CLASSES_PREFIX + suffix;
};
