
var exec = require('cordova/exec');

var PLUGIN_NAME = 'CordovaMobilePayAppSwitch';

var CordovaMobilePayAppSwitch = {
  startPayment: function(amount, orderId, callbackUrl, success, fail) {
    exec(success, fail, PLUGIN_NAME, 'startPayment', [amount, orderId, callbackUrl]);
  }
};

module.exports = CordovaMobilePayAppSwitch;
