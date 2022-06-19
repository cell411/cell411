//
//  C411RideStatusOverlay.m
//  cell411
//
//  Created by Milan Agarwal on 02/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideStatusOverlay.h"
#import "Constants.h"
#import "C411StaticHelper.h"

@interface C411RideStatusOverlay ()

@property (nonatomic, weak) IBOutlet UILabel *lblStatus;
-(IBAction)btnCloseOverlayTapped:(id)sender;

@property (nonatomic, readwrite) C411AlertNotificationPayload *alertNotificationPayload;

@end

@implementation C411RideStatusOverlay

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//****************************************************
#pragma mark - Public Interface
//****************************************************

-(void)hideOverlay
{
    ///Hide the overlay
    self.hidden = YES;
    ///clear the ivars
    self.overlayType = RideOverlayTypeNone;
    self.rideRequest = nil;
    self.rideResponse = nil;
    self.alertNotificationPayload = nil;
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setOverlayType:(RideOverlayType)overlayType
{
    _overlayType = overlayType;
    if (overlayType == RideOverlayTypePendingRideRequest) {
        
        self.lblStatus.text = NSLocalizedString(@"You have a pending ride request", nil);

    }
    else if (overlayType == RideOverlayTypePendingPickup) {
    
        self.lblStatus.text = NSLocalizedString(@"You have a pending pickup", nil);
    }
    else{
        
        self.lblStatus.text = nil;
    }

}

-(C411AlertNotificationPayload *)alertNotificationPayload
{
    
    if (self.rideRequest) {
        
        ///make the alert notification payload using the ride request object
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        ///set common properties
        alertNotificationPayload.strAlertType = kPayloadAlertTypeRideRequest;
        alertNotificationPayload.createdAtInMillis = [self.rideRequest.createdAt timeIntervalSince1970]*1000;
        PFUser *rider = self.rideRequest[kRideRequestRequestedByKey];
        alertNotificationPayload.strUserId = rider.objectId;
        ///Ride request properties
        alertNotificationPayload.strAdditionalNote = self.rideRequest[kRideRequestAdditionalNoteKey];
        alertNotificationPayload.strRideRequestId = self.rideRequest.objectId;
        alertNotificationPayload.strFullName = [C411StaticHelper getFullNameUsingFirstName:rider[kUserFirstnameKey] andLastName:rider[kUserLastnameKey]];
        ///Set the pickup location
        PFGeoPoint *pickUpGeoPoint = self.rideRequest[kRideRequestPickupLocationKey];
        alertNotificationPayload.pickUpLat = pickUpGeoPoint.latitude;
        alertNotificationPayload.pickUpLon = pickUpGeoPoint.longitude;
        
        ///Set the drop location
        NSString *strDropLocation = self.rideRequest[kRideRequestDropLocationKey];
        NSArray *arrDropLocation = [strDropLocation componentsSeparatedByString:@","];
        if (arrDropLocation.count == 2) {
            
            alertNotificationPayload.dropLat = [[arrDropLocation firstObject]doubleValue];
            alertNotificationPayload.dropLon = [[arrDropLocation lastObject]doubleValue];
            
        }

        _alertNotificationPayload = alertNotificationPayload;
        
    }
    
    return _alertNotificationPayload;
    

}

//****************************************************
#pragma mark - Action Methods
//****************************************************

-(IBAction)btnCloseOverlayTapped:(id)sender{
    
    
    ///Update on Parse
    if (self.overlayType == RideOverlayTypePendingRideRequest) {
        
        ///Get the latest ride request object and update the dismiss status
        NSString *strRideRequestId = self.rideRequest.objectId;
        PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
        [rideRequestQuery getObjectInBackgroundWithId:strRideRequestId block:^(PFObject *object,  NSError *error){
            
             if (!error && object) {
                 
                 ///set the overlayDismissed to Yes
                 PFObject *rideRequest = object;
                 rideRequest[kRideRequestOverlayDismissedKey] = @(YES);
                 [rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                     
                     if (succeeded) {
                         
                         NSLog(@"overlay dismiss status updated successfully");
                     }
                     else{
                         
                         if (error) {
                             
                             NSLog(@"Error updating overlay dismiss status for ride request:%@",error.localizedDescription);
                         }
                     }
                     
                 }];
            }
        }];
         

    }
    else if (self.overlayType == RideOverlayTypePendingPickup) {
        
        ///Get the latest ride response object and update the dismiss status
        NSString *strRideResponseId = self.rideResponse.objectId;
        PFQuery *rideResponseQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
        [rideResponseQuery getObjectInBackgroundWithId:strRideResponseId block:^(PFObject *object,  NSError *error){
            
            if (!error && object) {
                
                ///set the overlayDismissed to Yes
                PFObject *rideResponse = object;
                rideResponse[kRideResponseOverlayDismissedKey] = @(YES);
                [rideResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if (succeeded) {
                        
                        NSLog(@"overlay dismiss status updated successfully");
                    }
                    else{
                        
                        if (error) {
                            
                            NSLog(@"Error updating overlay dismiss status for pending pickup:%@",error.localizedDescription);
                        }
                    }
                    
                }];
            }
        }];
        
        

    }
    
    ///Hide the overlay
    [self hideOverlay];

}

@end
