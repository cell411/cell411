//
//  PSLocationManagerDelegate.h
//
//  Copyright (c) 2015-present PathSense. All rights reserved.
//

@class PSLocationManager;

/*!
	@abstract Delegate for PSLocationManager.
 
 */
@protocol PSLocationManagerDelegate <CLLocationManagerDelegate>

@optional

/*!
	@abstract Invoked when a PSActivityType and/or a PSActivityConfidence level has changed. Return the CLLocationAccuracy
	desired for this activity and or confidence.
 
 	@param manager the PSLocationManager.
 	@param activityType the PSActivityType.
 	@param confidence the PSActivityConfidence.
 	@return the desired location accuarcy for the given activity (including kPSLocationAccuracyPathSenseNavigation).
 */
- (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager
    desiredAccuracyForActivity:(PSActivityType)activityType
    withConfidence:(PSActivityConfidence)confidence;

/*!
	@abstract Invoked when a PSActivityType and/or a PSActivityConfidence level has changed. Return the CLLocationDistance
	for this activity and or confidence.
 
 	@param manager the PSLocationManager.
 	@param activityType the PSActivityType.
 	@param confidence the PSActivityConfidence.
 
 	@return the desired location distance for the given activity.
 */
- (CLLocationDistance)psLocationManager:(PSLocationManager *)manager
    distanceFilterForActivity:(PSActivityType)activityType
	withConfidence:(PSActivityConfidence)confidence;

@end
