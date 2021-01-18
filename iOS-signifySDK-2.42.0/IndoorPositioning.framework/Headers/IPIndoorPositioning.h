/*
 * © Philips Lighting, 2018.
 *   All rights reserved.
 */

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import <IndoorPositioning/IPDefines.h>

IP_EXPORT NSString * _Nonnull const IPIndoorPositioningErrorDomain;

/** The different indoorpositioning errors
 */
typedef NS_ENUM(int, IPIndoorPositioningError) {
    /** Cannot set property while started */
    IPIndoorPositioningErrorCannotSetPropertyWhileRunning  = 1,
    /** Library already in running mode */
    IPIndoorPositioningErrorAlreadyRunning                 = 2,
    /** Library already stopped mode */
    IPIndoorPositioningErrorAlreadyStopped                 = 3,
    /** The device is not supported */
    IPIndoorPositioningErrorDeviceNotSupported             = 4,
    /** No access to camera */
    IPIndoorPositioningErrorCameraAccessNotGranted         = 5,
    /** No access to location */
    IPIndoorPositioningErrorLocationNotGranted             = 6,
    /** No location fix within 5 seconds */
    IPIndoorPositioningErrorLocationTimeOut                = 7,
    /** Connection failed */
    IPIndoorPositioningErrorConnectionFailed               = 8,
    /** configuration failed */
    IPIndoorPositioningErrorConfigurationFailed            = 9,
    /** bluetooth is off */
    IPIndoorPositioningErrorBluetoothPoweredOff            = 10,
    /** camera not supported for vlc */
    IPIndoorPositioningErrorCameraNotSupported             = 11,
};

/** The different options in which the library fetches input data
 */
typedef NS_ENUM(int, IPIndoorPositioningMode) {
    /** Fetches live data */
    IPIndoorPositioningModeDefault          = 1,
    /** Simulation  */
    IPIndoorPositioningModeSimulation  		= 2,
    /** Static data for mobile setup */
    IPIndoorPositioningModeMobileSetup      = 3,
};

/** Different options to specify which heading orientation to use as the reference point for due north according to device orientation
 */
typedef NS_ENUM(int, IPIndoorPositioningHeadingOrientation) {
    /** Portrait mode, with the device held upright and the home button at the bottom */
    IPIndoorPositioningHeadingOrientationPortrait               = 1,
    /** Portrait mode but upside down, with the device held upright and the home button at the top */
    IPIndoorPositioningHeadingOrientationPortraitUpsideDown     = 2,
    /** Landscape mode, with the device held upright and the home button on the right side */
    IPIndoorPositioningHeadingOrientationLandscapeLeft          = 3,
    /** Landscape mode, with the device held upright and the home button on the left side */
    IPIndoorPositioningHeadingOrientationLandscapeRight         = 4,
};

/** Different indoor positioning expected accuracy indicators 
 */
typedef NS_ENUM(int, IPIndoorPositioningExpectedAccuracyIndicator) {
    /** Expected accuracy not yet known */
    IPIndoorPositioningExpectedAccuracyIndicatorUnknown     = 1,
    
    /** Expected accuracy low */
    IPIndoorPositioningExpectedAccuracyIndicatorLow         = 2,
    
    /** Expected accuracy medium */
    IPIndoorPositioningExpectedAccuracyIndicatorMedium      = 3,
    
    /** Expected accuracy high */
    IPIndoorPositioningExpectedAccuracyIndicatorHigh        = 4,
};


@protocol IPIndoorPositioningDelegate;

/*!
 *  The IPIndoorPositioning provides location and heading information of the device.
 *  In order to use the component, the minimal steps are:
 *
 *  - Implement a class that conforms to the IndoorPositioningDelegate protocol.
 *  - Obtain an IPIndoorPositioning instance using the sharedInstance class method.
 *  - Set the IPIndoorPositioningDelegate of the IPIndoorPositioning object using the
 *    delegate property.
 *  - Finally, start the indoor positioning.
 */
IP_EXPORT @interface IPIndoorPositioning : NSObject

/*!
 *  Obtain an instance of the IPIndoorPositioning. It is not allowed to instantiate
 *  this class yourself.
 */
+ (nonnull IPIndoorPositioning *)sharedInstance;

/*!
 *  Returns the current version.
 */
@property (readonly, nonatomic, nonnull) NSString *version;

/*!
 *  Option to set the way in which the library fetches input data. Three modes are available.
 *  Default mode fetches live data, simulation mode, and mobile setup use static data.
 */
@property (readwrite, nonatomic) IPIndoorPositioningMode mode;

/*!
 *  Options to specify which heading orientation to use as the reference point for due north.
 *  The default is portrait.
 */
@property (readwrite, nonatomic) IPIndoorPositioningHeadingOrientation headingOrientation;

/*!
 *  Mandatory option to set the configuration in which the library fetches the live database information.
 */
@property (strong, nonatomic, nullable) NSString *configuration;

/*!
 *  The delegate is used to communicate UserLocation and UserHeading to the application, and to
 *  instruct the application where needed.
 */
@property (weak, atomic, nullable) id<IPIndoorPositioningDelegate> delegate;

/*!
 *  Boolean that indicates whether the indoor positioning is currently running.
 */
@property (readonly, nonatomic) BOOL running;

/*!
 *  Starts indoor positioning. At this point, the delegate must be configured.
 *
 *  @see delegate
 */
- (void)start;

/*!
 *  Stops indoor positioning.
 */
- (void)stop;

@end

/*!
 *  This is the protocol used by IPIndoorPositioning to inform the application of
 *  location and heading.
 *
 *  All delegate methods are dispatched on the main dispatch queue.
 */
@protocol IPIndoorPositioningDelegate <NSObject>

@required

/*!
 *  This method is called when the heading is known in the IndoorPositioning object.
 *  @param indoorPositioning        The IndoorPositioning that is reporting the heading.
 *  @param heading                  An NSDictionary containing info about the heading.
 */
- (void)indoorPositioning:(nonnull IPIndoorPositioning *)indoorPositioning didUpdateHeading:(nonnull NSDictionary *)heading;

/*!
 *  Key in the dictionary of heading that gives the heading in degrees. The resulting value (double) represents
 *  the heading relative to the geographic North Pole. The value 0 means the device is pointed toward
 *  true north, 90 means it is pointed due east, 180 means it is pointed due south, and so on.
 */
IP_EXPORT NSString * _Nonnull const kIPHeadingDegrees;

/*!
 * Key in the dictionary of heading that gives the heading accuracy in degrees, value is a double.
 */
IP_EXPORT NSString * _Nonnull const kIPHeadingAccuracy;

/*!
 *  Key in the dictionary of heading that gives the heading in degrees. The resulting value (double) represents the heading relative to an arbitrary North, which is the direction of the device at the start of positioning. The value 0 means the device points in the same direction as at start, 90 means the device points in the direction 90 degrees clockwise from the start, 180 means the device points opposite of the start direction, and so on.
 */
IP_EXPORT NSString * _Nonnull const kIPHeadingArbitraryNorthDegrees;

/*!
 *  This method is called when the location is known in the IndoorPositioning object.
 *  The latitude and longitude associated with a location is specified using the WGS 84 reference frame.
 *  @param indoorPositioning        The IndoorPositioning that is reporting the location.
 *  @param location                 An NSDictionary containing info about the location.
 */
- (void)indoorPositioning:(nonnull IPIndoorPositioning *)indoorPositioning didUpdateLocation:(nonnull NSDictionary *)location;

/*!
 * Key in the dictionary of location that gives latitude of the location, value is a double.
 */
IP_EXPORT NSString * _Nonnull const kIPLocationLatitude;

/*!
 * Key in the dictionary of location that gives longitude of the location, value is a double.
 */
IP_EXPORT NSString * _Nonnull const kIPLocationLongitude;

/*!
 * Key in the dictionary of location that gives altitude of the location, value is a double.
 */
IP_EXPORT NSString * _Nonnull const kIPLocationAltitude;

/*!
 * Key in the dictionary of location that gives the accuracy (in meters) of the longitude/latitude, value
 * is a double.
 */
IP_EXPORT NSString * _Nonnull const kIPLocationHorizontalAccuracy;

/*!
 * Key in the dictionary of location that gives the vertical accuracy (in meters), value is a double.
 */
IP_EXPORT NSString * _Nonnull const kIPLocationVerticalAccuracy;

/*!
 * Key in the dictionary of location that gives the floor, value is integer. If unknown there will be no key.
 */
IP_EXPORT NSString * _Nonnull const kIPLocationFloorLevel;

/**
 * Key in the {@link #didUpdateLocation(Map)} callback map parameter
 * that gives the expected accuracy level.
 */
IP_EXPORT NSString * _Nonnull const kIPLocationExpectedAccuracyLevel;

/*!
 *  This method is called when an error occurred in the IndoorPositioning object.
 *  @param indoorPositioning        The IndoorPositioning that is reporting an error.
 *  @param error                    The details about the error that has occurred.
 */
- (void)indoorPositioning:(nonnull IPIndoorPositioning *)indoorPositioning didFailWithError:(nonnull NSError *)error;

@end
