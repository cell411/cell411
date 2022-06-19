//
//  C411Alert.h
//  cell411
//
//  Created by Milan Agarwal on 21/02/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class PFUser;

@interface C411Alert : NSObject

@property (nonatomic, strong) NSString *strAlertId;
@property (nonatomic, assign) NSInteger alertType;
@property (nonatomic, strong) NSString *strAlertType;
@property (nonatomic, strong) NSString *strAdditionalNote;
@property (nonatomic, strong) NSMutableArray *arrAudiences;
@property (nonatomic, assign, getter=isDispatched) BOOL dispatched;
@property (nonatomic, assign) CLLocationCoordinate2D alertLocationCoordinate;
@property (nonatomic, strong) NSData *photoData;
@property (nonatomic, strong) NSString *strPhotoUrl;
@property (nonatomic, strong) PFUser *alertIssuer;
@property (nonatomic, assign) double alertGenerationTimeInMillis;
@property (nonatomic, assign) NSInteger targetMembersCount;
@property (nonatomic, assign) NSInteger targetNauMembersCount;


@end
