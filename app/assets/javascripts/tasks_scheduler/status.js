if (typeof TasksScheduler == "undefined") {
  TasksScheduler = function() {};
}

TasksScheduler.Status = function () {
};

// Shortcut
var _S = TasksScheduler.Status;

_S.initialized = false;

_S.init = function (url, interval_max) {
  if (!_S.initialized) {
    _S.initialized = true;
    _S.url = url;
    _S.interval_max = interval_max;
    _S.update();
  }
};

_S.content = function () {
  return $('#TaskScheduler_Status_Content');
};

_S.status = function () {
  return $('#TaskScheduler_Status_Status');
};

_S.update_status = function () {
  _S.status().html(
    "Updating in " + _S.interval + " seconds..."
  );
};

_S.check = function () {
  if (_S.interval <= 0) {
    _S.update();
  } else {
    _S.interval--;
    _S.update_status();
    setTimeout(_S.check, 1000);
  }
};

_S.update = function () {
  $.ajax(_S.updateAjaxData());
};

_S.updateAjaxData = function() {
  return {
    url: _S.url,
    success: function (result) {
      _S.content().html(result);
    },
    complete: function (result) {
      _S.interval = _S.interval_max + 1;
      _S.last_update = new Date();
      _S.check();
    }
  };
};
