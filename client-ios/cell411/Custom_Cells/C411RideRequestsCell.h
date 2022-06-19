//
//  C411RideRequestsCell.h
//  cell411
//
//  Created by Milan Agarwal on 03/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"
#import <CoreLocation/CoreLocation.h>

@interface C411RideRequestsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuRequestIndicator;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuClock;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTimestamp;
@property (weak, nonatomic) IBOutlet UIButton *btnFlag;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDropAddress;

@property (nonatomic, assign) CLLocationCoordinate2D pickupLocation;
@property (nonatomic, assign) CLLocationCoordinate2D dropLocation;


@end
