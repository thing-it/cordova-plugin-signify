import IndoorPositioning;

import os.log;

class SignifyLogEvent: Codable {

    var message:String;
    var timestamp:Date;

    init(message:String) {
        self.message = "\(message)";
        self.timestamp = Date();
    }

    func getMessage() -> String {
        return self.message;
    }

    func getTimestamp() -> Date {
        return self.timestamp;
    }
}

struct ErrorEvent: Codable {

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
            "errorMessage" : self.errorMessage,
            "timestamp" : self.timestamp
        ]
    }

}

struct LocationEvent: Codable {

    let latitude:Double;
    let longitude:Double;
    let horizontalAccuracy:Double;
    let altitude:Double;
    let verticalAccuracy:Double;
    let floor:String;
    let accuracyLevel:Int32;
    let expectedAccuracyLevel:String;

    init (location: [AnyHashable : Any]) {
        
        let location = location.mapValues { $0 as? NSNumber }.compactMapValues { $0 };
        self.latitude = location[kIPLocationLatitude]?.doubleValue ?? 0;
        self.longitude = location[kIPLocationLongitude]?.doubleValue ?? 0;
        self.horizontalAccuracy = location[kIPLocationHorizontalAccuracy]?.doubleValue ?? 0;
        self.altitude = location[kIPLocationAltitude]?.doubleValue ?? 0;
        self.verticalAccuracy = location[kIPLocationVerticalAccuracy]?.doubleValue ?? 0;
        self.floor = location[kIPLocationFloorLevel]?.stringValue ?? "UNKNOWN";
        self.accuracyLevel = location[kIPLocationExpectedAccuracyLevel]?.int32Value ?? 1;
        
        let indicator = IPIndoorPositioningExpectedAccuracyIndicator(rawValue: accuracyLevel);

        switch indicator {
            case .unknown:
                self.expectedAccuracyLevel = "UNKNOWN"
            case .low:
                self.expectedAccuracyLevel = "LOW"
            case .medium:
                self.expectedAccuracyLevel = "MEDIUM"
            case .high:
                self.expectedAccuracyLevel = "HIGH"
            default:
                self.expectedAccuracyLevel = "UNKNOWN"
        }

    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "latitude" : self.latitude,
            "longitude" : self.longitude,
            "horizontalAccuracy": self.horizontalAccuracy,
            "altitude": self.altitude,
            "verticalAccuracy": self.verticalAccuracy,
            "floor": self.floor,
            "accuracyLevel": self.accuracyLevel,
            "expectedAccuracyLevel": self.expectedAccuracyLevel
        ]
    }
}

struct HeadingEvent: Codable {

    let headingDegrees:Double;
    let headingAccuracy:Double;
    let headingArbitraryNorthDegrees:Double;
   
    init (heading: [AnyHashable : Any]) {
        
        let heading = heading.mapValues { $0 as? NSNumber }.compactMapValues { $0 };

        self.headingDegrees = heading[kIPHeadingDegrees]?.doubleValue ?? 0;
        self.headingAccuracy = heading[kIPHeadingAccuracy]?.doubleValue ?? 0;
        self.headingArbitraryNorthDegrees = heading[kIPHeadingArbitraryNorthDegrees]?.doubleValue ?? 0;

    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "headingDegrees" : self.headingDegrees,
            "headingAccuracy" : self.headingAccuracy,
            "headingArbitraryNorthDegrees": self.headingArbitraryNorthDegrees
        ]
    }
}

struct ErrorCallbackEvent : Codable {
    
    var eventType: String;
    var event: ErrorEvent;
    
    init (errorEvent: ErrorEvent) {
        self.event = errorEvent;
        self.eventType = "didReceiveError";
    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "eventType" : self.eventType,
            "event" : self.event
        ]
    }
}

struct LocationCallbackEvent : Codable {

    var eventType: String;
    var event: LocationEvent;
    
    init (locationEvent: LocationEvent) {
        self.event = locationEvent;
        self.eventType = "didReceiveLocation";
    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "eventType" : self.eventType,
            "event" : self.event
        ]
    }
}

struct HeadingCallbackEvent : Codable {

    var eventType: String;
    var event: HeadingEvent;
    
    init (headingEvent: HeadingEvent) {
        self.event = headingEvent;
        self.eventType = "didReceiveHeading";
    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "eventType" : self.eventType,
            "event" : self.event
        ]
    }
}

struct SignifyLogCallbackEvent : Codable {
    
    var eventType: String
    var event: SignifyLogEvent
    
    init (logEvent: SignifyLogEvent) {
        self.event = logEvent;
        self.eventType = "didReceiveLog";
    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "eventType" : self.eventType,
            "event" : self.event
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
    
    func didReceiveLog(message: String) {

        let callbackEvent = SignifyLogCallbackEvent(logEvent: SignifyLogEvent(message: message));

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

    func didReceiveError(event: ErrorEvent) {

        let callbackEvent = ErrorCallbackEvent(errorEvent: event);

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

        let callbackEvent = LocationCallbackEvent(locationEvent: event);

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

        let callbackEvent = HeadingCallbackEvent(headingEvent: event);

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

    private var signifyEventNotifier: SignifyEventNotifier? = nil;
   
    override func pluginInitialize() {
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

    @objc(configure:) func configure(command : CDVInvokedUrlCommand) {
        
        let license : String = (command.arguments[0] as? String)!;
        let testMode: Bool = (command.arguments[1] as? Bool ?? false);

        IPIndoorPositioning.sharedInstance().delegate = self
        IPIndoorPositioning.sharedInstance().headingOrientation = .portrait
        IPIndoorPositioning.sharedInstance().configuration = license
        IPIndoorPositioning.sharedInstance().mode = testMode ? .simulation : .default

        IPIndoorPositioning.sharedInstance().start();

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK);
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);

    }

    @objc(start:) func start(command : CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            if (IPIndoorPositioning.sharedInstance().running == false) {
                self.signifyEventNotifier?.didReceiveLog(message: "Starting indoor positioning");
                let prefix: String = String(IPIndoorPositioning.sharedInstance().configuration?.prefix(25) ?? "");
                self.signifyEventNotifier?.didReceiveLog(message: String("Venue: \(prefix)"));
                IPIndoorPositioning.sharedInstance().start();
            }
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK);
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
        }
    }

     @objc(stop:) func stop(command : CDVInvokedUrlCommand) {
         DispatchQueue.main.async {
            if (IPIndoorPositioning.sharedInstance().running == true) {
                self.signifyEventNotifier?.didReceiveLog(message: "Stopping indoor positioning");
                IPIndoorPositioning.sharedInstance().stop();
            }
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

}
