//
//  C411RideReviewsVC.h
//  cell411
//
//  Created by Milan Agarwal on 03/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAGBackActionCallbackVC.h"
@class PFUser;

@interface C411RideReviewsVC : MAGBackActionCallbackVC

@property (nonatomic, strong) PFUser *targetUser;
@property (nonatomic, strong) NSString *targetUserId;
@property (nonatomic, assign, getter=isRideConfirmed) BOOL rideConfirmed;

@end
