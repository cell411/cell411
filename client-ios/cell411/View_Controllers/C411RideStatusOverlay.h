//
//  C411RideStatusOverlay.h
//  cell411
//
//  Created by Milan Agarwal on 02/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C411AlertNotificationPayload.h"
@class PFObject;

typedef NS_ENUM(NSUInteger, RideOverlayType) {
    RideOverlayTypeNone = 0,
    RideOverlayTypePendingRideRequest,
    RideOverlayTypePendingPickup
};


@interface C411RideStatusOverlay : UIView

@property (nonatomic, assign) RideOverlayType overlayType;
@property (nonatomic, strong) PFObject *rideRequest;
@property (nonatomic, strong) PFObject *rideResponse;
@property (nonatomic, readonly) C411AlertNotificationPayload *alertNotificationPayload;

-(void)hideOverlay;


@end
