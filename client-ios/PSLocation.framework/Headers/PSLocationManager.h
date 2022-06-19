//
//  PSLocationManager.h
//
//  Copyright (c) 2015-present PathSense. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/Coremotion.h>

typedef NS_ENUM(NSInteger, PSActivityType) {
    PSActivityTypeUnknown = 0,
    PSActivityTypeStationary,
    PSActivityTypeInVehicle,
    PSActivityTypeInVehicleStationary,
    PSActivityTypeOnBicycle,
    PSActivityTypeWalking,
    PSActivityTypeRunning
};

typedef NS_ENUM(NSInteger, PSActivityConfidence) {
    PSActivityConfidenceLow = 0,
    PSActivityConfidenceMedium,
    PSActivityConfidenceHigh
};

#import "PSLocationManagerDelegate.h"

/*!
	@abstract PSLocationLatency is the type used to represent a PathSense location latency level in seconds. The higher the value is in seconds, the
	more time will be allowd to validate the location accuracy. A negative latency value indicates an infinite latency.
*/
typedef NSTimeInterval PSLocationLatency;

/*!
	@abstract Used to specify infinite latency
 */
extern const PSLocationLatency kPSLocationLatencyInfinite;

/*!
	@abstract Used to specify an additional accuracy level which can be assing to the desiredAccuracy property of the Location Manager.
    This accuracy performs additional filtering and sensor fusion on top of kCLLocationAccuracyBestForNavigation. This accuracy is power intensive.
 
 */
extern const CLLocationAccuracy kPSLocationAccuracyPathSenseNavigation;

/*!
	@abstract The PSLocationManager class is your entry point to the PathSense location service. PSLocationManager is inherited from CLLocationManager.
 
 */
@interface PSLocationManager : CLLocationManager

/*!
	@abstract Specifies the maximum latency allowed to PathSense to improve the accuracy of location data.
	By default, kPSLocationLatencyInfinite is used. This is only used in conjuction with kPSLocationAccuracyPathSenseNavigation.
 
 */
@property(assign, nonatomic) PSLocationLatency maximumLatency;

/*!
	@abstract Specifies that location updates will be paused when the device is in a completely still state.
	By default, this is NO.
 
 */
@property(assign, nonatomic) BOOL pausesLocationUpdatesWhenDeviceIsStationary;

/*!
	@abstract The current motion activity of the device.
 
*/
@property(readonly, nonatomic) CMMotionActivity * currentActivity;

/*!
	@abstract Sets the delegate for PSLocationManager.
 
*/
- (void) setDelegate:(id<PSLocationManagerDelegate>)delegate;

/*!
	@abstract The delegate object for PSLocationManager to receive update events.
 
 */
- (id<PSLocationManagerDelegate>) delegate;

/*!
	@abstract Start monitoring ambient location changes. The behavior of this service is not affected by the desiredAccuracy
	or distanceFilter properties. Locations will be delivered through the same delegate callback as the standard
	location service. You can expect to recieve sparce location data intermitenly. 
*/
- (void) startMonitoringAmbientLocationChanges;

/*!
	@abstract Stop monitoring ambient location changes

*/
- (void) stopMonitoringAmbientLocationChanges;

/*!
	@abstract Determines whether ambient location changes are being monitored.

*/
- (BOOL) isMonitoringAmbientLocationChanges;

/*!
	@abstract Use this method to feed in locations which in return will act as if they came through the system. Primary use is for testing.
 
 */
- (void) simulateLocation:(CLLocation *)location;

@end
