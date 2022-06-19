//
//  C411RideDetailVC.h
//  cell411
//
//  Created by Milan Agarwal on 04/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C411AlertNotificationPayload.h"
#import "Constants.h"
#import "MAGBackActionCallbackVC.h"

@interface C411RideDetailVC : MAGBackActionCallbackVC

@property (nonatomic, strong) C411AlertNotificationPayload *alertPayload;
@property (nonatomic, weak) PFUser *rider;
@property (nonatomic, copy) backActionHandler backActionHandler;

@end
