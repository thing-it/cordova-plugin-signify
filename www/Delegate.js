/**
 *
 * @example
 *
 * var delegate = new cordova.plugins.signify.PositioningManager.Delegate();
 *
 * delegate.didReceiveError = function(event) {
 *      console.log('didReceiveError: ' + JSON.stringify(event));
 * };
 *
 *
 * @returns {Delegate} An instance of the type {@type Delegate}.
 */
function Delegate (){};

Delegate.didReceiveLog = function(pluginResult) {
    pluginResult.event = JSON.parse(pluginResult.event);
};

Delegate.didReceiveError = function(pluginResult) {
    pluginResult.event = JSON.parse(pluginResult.event);
};

Delegate.didReceiveLocation = function(pluginResult) {
    pluginResult.event = JSON.parse(pluginResult.event);
};

Delegate.didReceiveHeading = function(pluginResult) {
    pluginResult.event = JSON.parse(pluginResult.event);
};

module.exports = Delegate;
