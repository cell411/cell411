//
//  C411LocationPickerVC.h
//  cell411
//
//  Created by Milan Agarwal on 14/10/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"

@interface C411LocationPickerVC : UIViewController

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, copy) completionHandler completionHandler;

@end
