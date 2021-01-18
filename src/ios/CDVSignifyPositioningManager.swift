import IndoorPositioning;

import os.log;

class ErrorEvent {

    let errorMessage:String;
    let timestamp:Date;

    init(error: NSError) {

        let indoorPositioningError = IPIndoorPositioningError(rawValue: Int32(error.code))

        switch indoorPositioningError {
            case .cannotSetPropertyWhileRunning:
                self.errorMessage = "Cannot set property while running"
            case .alreadyRunning:
                self.errorMessage = "Already running"
            case .alreadyStopped:
                self.errorMessage = "Already stopped"
            case .deviceNotSupported:
                self.errorMessage = "Device not supported"
            case .cameraAccessNotGranted:
                self.errorMessage = "Camera access not granted"
            case .locationNotGranted:
                self.errorMessage = "Location access not granted"
            case .locationTimeOut:
                self.errorMessage = "Location timeout"
            case .connectionFailed:
                self.errorMessage = "Connection failed"
            case .configurationFailed:
                self.errorMessage = "Configuration failed"
            case .bluetoothPoweredOff:
                self.errorMessage = "Bluetooth not turned on"
            case .cameraNotSupported:
                self.errorMessage = "Camera not supported"
            default:
                self.errorMessage = "Unknown error"
        }
        
        self.timestamp = Date();
    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "errorMessage" : errorMessage,
            "timestamp" : timestamp
        ]
    }

}

struct LocationEvent: Codable {

    let latitude:double;
    let longitude:double;
    let horizontalAccuracy:double;
    let altitude:double;
    let verticalAccuracy:double;
    let floor:String:
    let accuracyLevel:Int32;
    let expectedAccuracyLevel:String;

    init (location: [AnyHashable : Any]) {
        
        let location = location.mapValues { $0 as? NSNumber }.compactMapValues { $0 };

        latitude = location[kIPLocationLatitude]?.doubleValue ?? 0;
        longitude = location[kIPLocationLongitude]?.doubleValue ?? 0;
        horizontalAccuracy = location[kIPLocationHorizontalAccuracy]?.doubleValue ?? 0;
        altitude = location[kIPLocationAltitude]?.doubleValue ?? 0;
        verticalAccuracy = location[kIPLocationVerticalAccuracy]?.doubleValue ?? 0;
        floor = location[kIPLocationFloorLevel]?.stringValue ?? "Unknown";
        accuracyLevel = location[kIPLocationExpectedAccuracyLevel]?.int32Value ?? 1;
        
        let indicator = IPIndoorPositioningExpectedAccuracyIndicator(rawValue: accuracyLevel);

        switch indicator {
            case .unknown:
                expectedAccuracyLevel = "Unknown"
            case .low:
                expectedAccuracyLevel = "Low"
            case .medium:
                expectedAccuracyLevel = "Medium"
            case .high:
                expectedAccuracyLevel = "High"
            default:
                expectedAccuracyLevel = "Unknown"
        }

    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "latitude" : latitude,
            "longitude" : longitude,
            "horizontalAccuracy": horizontalAccuracy,
            "altitude": altitude,
            "altitudeAccuracy": altitudeAccuracy,
            "floor": floor,
            "accuracyLevel": accuracyLevel,
            "expectedAccuracyLevel": expectedAccuracyLevel
        ]
    }
}

struct HeadingEvent: Codable {

    let headingDegrees:double;
    let headingAccuracy:double;
    let headingArbitraryNorthDegrees:double;
   
    init (heading: [AnyHashable : Any]) {
        
        let heading = heading.mapValues { $0 as? NSNumber }.compactMapValues { $0 };

        headingDegrees = heading[kIPHeadingDegrees]?.doubleValue ?? 0;
        headingAccuracy = heading[kIPHeadingAccuracy]?.doubleValue ?? 0;
        headingArbitraryNorthDegrees = heading[kIPHeadingArbitraryNorthDegrees]?.doubleValue ?? 0;

    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "headingDegrees" : headingDegrees,
            "headingAccuracy" : headingAccuracy,
            "headingArbitraryNorthDegrees": headingArbitraryNorthDegrees
        ]
    }
}

struct ErrorCallbackEvent : Codable {
    
    let eventType: String
    let event: ErrorEvent

    var dictionaryRepresentation: [String: Any] {
        return [
            "eventType" : eventType,
            "event" : event
        ]
    }
}

struct LocationCallbackEvent : Codable {

    let eventType: String
    let event: LocationEvent

    var dictionaryRepresentation: [String: Any] {
        return [
            "eventType" : eventType,
            "event" : event
        ]
    }
}

struct HeadingCallbackEvent : Codable {

    let eventType: String;
    let event: HeadingEvent;

    var dictionaryRepresentation: [String: Any] {
        return [
            "eventType" : eventType,
            "event" : event
        ]
    }
}

class SignifyEventNotifier {

    var command: CDVInvokedUrlCommand? = nil;
    var commandDelegate :CDVCommandDelegate? = nil;

    init(command: CDVInvokedUrlCommand, commandDelegate: CDVCommandDelegate) {
        self.command = command;
        self.commandDelegate = commandDelegate;
    }

    func didReceiveError(event: ErrorEvent) {

        let callbackEvent = ErrorCallbackEvent(eventType: "didReceiveLog", event: event);

        do {

            let jsonData = try JSONEncoder().encode(callbackEvent);
            let jsonString = String(data: jsonData, encoding: .utf8)!

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: jsonString);

            pluginResult?.keepCallback = true

            self.commandDelegate!.send(pluginResult, callbackId: self.command?.callbackId);

        } catch {
            os_log("%@", error.localizedDescription );
        }

    }

    func didReceiveLocation(event: LocationEvent) {

        let callbackEvent = LocationCallbackEvent(eventType: "didReceiveLocation", event: event);

        do {

            let jsonData = try JSONEncoder().encode(callbackEvent);
            let jsonString = String(data: jsonData, encoding: .utf8)!

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: jsonString);

            pluginResult?.keepCallback = true

            self.commandDelegate!.send(pluginResult, callbackId: self.command?.callbackId);

        } catch {
            os_log("%@", error.localizedDescription );
        }

    }

    func didReceiveHeading(event: HeadingEvent) {

        let callbackEvent = HeadingCallbackEvent(eventType: "didReceiveHeading", event: event);

        do {

            let jsonData = try JSONEncoder().encode(callbackEvent);
            let jsonString = String(data: jsonData, encoding: .utf8)!

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: jsonString);

            pluginResult?.keepCallback = true

            self.commandDelegate!.send(pluginResult, callbackId: self.command?.callbackId);

        } catch {
            os_log("%@", error.localizedDescription );
        }

    }

}

@objc(CDVSignifyPositioningManager) class CDVSignifyPositioningManager : CDVPlugin, IPIndoorPositioningDelegate {

    private let indoorPositioning = IPIndoorPositioning.sharedInstance();

    var signifyEventNotifier: SignifyEventNotifier? = nil;
   
    override func pluginInitialize() {
    }

    @objc(configure:) func configure(command : CDVInvokedUrlCommand) {

        do {

            let license: String = (command.arguments[0] as? String)!;
            let testMode: Bool = (command.arguments[1] as? Bool ?? false);

            self.indoorPositioning.delegate = self
            self.indoorPositioning.headingOrientation = .portrait
            self.indoorPositioning.configuration = license
            self.indoorPositioning.mode = testMode ? .simulation : .default

            self.indoorPositioning.start();

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK);
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);

        } catch {

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR);
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);

        }

    }

    @objc(start:) func start(command : CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            self.indoorPositioning.start();
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK);
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
        }
    }

     @objc(stop:) func stop(command : CDVInvokedUrlCommand) {
         DispatchQueue.main.async {

             guard indoorPositioning.running else { 
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK);
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
              }
             
             self.indoorPositioning.stop();
             let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK);
             self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
         }
     }

    @objc(registerDelegateCallbackId:) func registerDelegateCallbackId(command : CDVInvokedUrlCommand){
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK);
        pluginResult?.keepCallback = true
        createNotifierCallbacks(command: command);
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }

    func createNotifierCallbacks(command : CDVInvokedUrlCommand) {
        self.signifyEventNotifier = SignifyEventNotifier(command: command, commandDelegate: self.commandDelegate);
    }

    func indoorPositioning(_ indoorPositioning: IPIndoorPositioning, didUpdateHeading heading: [AnyHashable : Any]) {
        self.signifyEventNotifier?.didReceiveHeading(event: HeadingEvent(heading: heading));
    }
    
    func indoorPositioning(_ indoorPositioning: IPIndoorPositioning, didUpdateLocation location: [AnyHashable : Any]) {
        self.signifyEventNotifier?.didReceiveLocation(event: LocationEvent(location: location));
    }
    
    func indoorPositioning(_ indoorPositioning: IPIndoorPositioning, didFailWithError error: Error) {
        let error = error as NSError;
        guard error.domain == IPIndoorPositioningErrorDomain else { return };
        self.signifyEventNotifier?.didReceiveError(event: ErrorEvent(error: error));  
    }

}