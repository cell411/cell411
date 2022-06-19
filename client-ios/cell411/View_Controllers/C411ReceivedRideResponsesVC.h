//
//  C411ReceivedRideResponsesVC.h
//  cell411
//
//  Created by Milan Agarwal on 03/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Constants.h"
#import "MAGBackActionCallbackVC.h"

@interface C411ReceivedRideResponsesVC : MAGBackActionCallbackVC

@property (nonatomic, strong) PFObject *rideRequest;
@property (nonatomic, copy) backActionHandler backActionHandler;

@end
