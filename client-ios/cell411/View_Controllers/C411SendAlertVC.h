//
//  C411SendAlertVC.h
//  cell411
//
//  Created by Milan Agarwal on 30/03/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "C411Enums.h"

@protocol C411SendAlertVCDelegate <NSObject>

-(void)sendAlertWithParams:(NSDictionary *)dictAlertParams;

@end

@interface C411SendAlertVC : UIViewController

@property (nonatomic, assign) id<C411SendAlertVCDelegate> delegate;
@property (nonatomic, assign) AlertType alertType;
@property (nonatomic, assign) CLLocationCoordinate2D dispatchLocation;
@property (nonatomic, strong) NSString *strForwardedAlertId;

@end
