var exec = require('cordova/exec');
var _ = require('cordova-plugin-signify.underscorejs');
var Q = require('cordova-plugin-signify.Q');

var Delegate = require('./Delegate');

/**
 * Creates an instance of the plugin.
 *
 * Important note: Creating multiple instances is expected to break the delegate
 * callback mechanism, as the native layer can only handle one  callback ID at a
 * time.
 *
 * @constructor {PositioningManager}
 */

function PositioningManager () {
    this.delegate = new Delegate();
    this._registerDelegateCallbackId();
}


PositioningManager.prototype.getDelegate = function() {
    return this.delegate;
};

PositioningManager.prototype.setDelegate = function(newDelegate) {

    if (!(newDelegate instanceof Delegate)) {
        console.error('newDelegate parameter has to be an instance of Delegate.');
        return;
    }

    this.delegate = newDelegate;

    return this.delegate;
};

/**
 * Calls the method 'registerDelegateCallbackId' in the native layer which
 * saves the callback ID for later use.
 *
 * The saved callback ID will be used when the native layer wants to notify
 * the DOM asynchronously about an BLE encounter event.
 *
 * The same callback will be used for success and fail handling since the
 * handling is the same.
 *
 * @returns {Q.Promise}
 */
PositioningManager.prototype._registerDelegateCallbackId = function () {

    var d = Q.defer();

    exec(_.bind(this._onDelegateCallback, this, d), _.bind(this._onDelegateCallback, this, d), "PositioningManager",
        "registerDelegateCallbackId", []);

    return d.promise;
};

/**
 * Handles asynchronous calls from the native layer. In this context async
 * means that message is not a response to a request of the DOM.
 *
 * @param {type} deferred {promise, resolve, reject} object.
 *
 * @param {type} pluginResult The PluginResult object constructed by the
 * native layer as the payload of the message it wishes to send to the DOM
 * asynchronously.
 *
 * @returns {undefined}
 */
PositioningManager.prototype._onDelegateCallback = function (deferred, pluginResult) {

    if (_.isString(pluginResult) && pluginResult !== 'OK') {
        pluginResult = JSON.parse(pluginResult);
    }

    if (pluginResult && _.isString(pluginResult['eventType'])) { // The native layer calling the DOM with a delegate event.
        this._mapDelegateCallback(pluginResult);
    } else if (Q.isPending(deferred.promise)) { // The callback ID registration finished, runs only once.
        deferred.resolve();
    } else { // The native layer calls back the delegate without specifying an event, coding error.
        console.error('Delegate registration promise is already been resolved, all subsequent callbacks should provide an "eventType" field.');
    }

};

/**
 * Routes async messages arriving from the native layer to the appropriate
 * delegate methods.
 *
 * @param {type} pluginResult The PluginResult object constructed by the
 * native layer as the payload of the message it wishes to send to the DOM
 *
 * @returns {undefined}
 */
PositioningManager.prototype._mapDelegateCallback = function (pluginResult) {

    var eventType = pluginResult['eventType']; // the Objective-C selector's name

    if (_.isFunction(this.delegate[eventType])) {
        this.delegate[eventType](pluginResult);
    } else {
        console.error('Delegate unable to handle eventType: ' + eventType);
    }
};

/**
 * Goes through the provided pre-processors *in order* adn applies them to
 * [pluginResult].
 * When the pre-processing is done, [resolve] is called with the pre-
 * processed results. The raw input is discarded.
 *
 * @param {Function} resolve A callback which will get called upon completion.
 *
 * @param {Array} pluginResult The PluginResult object constructed by the
 * native layer as the payload of the message it wishes to send to the DOM.
 * This function expects the [pluginResult] to be an array of elements.
 *
 * @param {Array} preProcessors An array of {Function}s which will be applied
 * to [pluginResult], in order.
 *
 * @returns {undefined}
 */
PositioningManager.prototype._preProcessorExecutor = function (resolve, pluginResult, preProcessors) {
    _.each(preProcessors, function (preProcessor) {
        pluginResult = preProcessor(pluginResult);
    });
    resolve(pluginResult);
};

/**
 * Wraps a Cordova exec call into a promise, allowing the client code to
 * operate with those promises instead of callbacks.
 *
 * @param {String} method The name of the method in the native layer to be
 * called by Cordova.
 *
 * @param {Array} commandArgs An array of arguments to be passed for the
 * native layer. Defaults to an empty array if omitted.
 *
 * @param {Array} preProcessors An array of callback functions all of which
 * takes an iterable (array) as it's parameter and applies a certain
 * operation to the elements of that iterable.
 *
 * @returns {Q.Promise}
 */
PositioningManager.prototype._promisedExec = function (method, commandArgs, preProcessors) {
    var self = this;
    commandArgs = _.isArray(commandArgs) ? commandArgs : [];
    preProcessors = _.isArray(preProcessors) ? preProcessors : [];
    preProcessors = _.filter(preProcessors, function(preProcessor) {
        return _.isFunction(preProcessor);
    });

    var d = Q.defer();


    var resolveWrap = function(pluginResult) {
        self._preProcessorExecutor(d.resolve, pluginResult, preProcessors);
    };

    exec(resolveWrap, d.reject, "PositioningManager", method, commandArgs);

    return d.promise;
};


PositioningManager.prototype.configure = function(license, testMode) {
    return this._promisedExec('configure', [license, testMode], []);
};

PositioningManager.prototype.start = function() {
    return this._promisedExec('start', [], []);
};

PositioningManager.prototype.stop = function() {
    return this._promisedExec('stop', [], []);
};


var positioningManager = new PositioningManager();
positioningManager.Delegate = Delegate;

module.exports = positioningManager;