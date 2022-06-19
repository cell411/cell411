//
//  C411AlertNotificationPayload.h
//  cell411
//
//  Created by Milan Agarwal on 24/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "C411Address.h"

@interface C411AlertNotificationPayload : NSObject

///This will contain either NEEDY or HELPER or FRIEND_REQUEST or FRIEND_APPROVED or VIDEO or others
@property (nonatomic, strong) NSString *strAlertType;
@property (nonatomic, strong) NSString *strAlert;
///Hold createdAt time in milliseconds
@property (nonatomic, assign) NSTimeInterval createdAtInMillis;
@property (nonatomic, strong) NSString *strUserId;
@property (nonatomic, strong) NSString *strUsername;
///Used for full name, in Alert,
@property (nonatomic, strong) NSString *strFullName;
///Holds the objectId of Cell411Alert table
@property (nonatomic, strong) NSString *strCell411AlertId;
///To be used for needy or helper
@property (nonatomic, strong) NSString *strAdditionalNote;


///Needy or VIDEO Properties
@property (nonatomic, strong) NSString *strAlertRegarding;
//@property (nonatomic, strong) NSString *strfirstname;
@property (nonatomic, strong) C411Address *alertAddress;
@property (nonatomic, assign) int isGlobalAlert;
@property (nonatomic, assign) int dispatchMode;

///Helper properties
@property (nonatomic, strong) NSString *strDuration;
@property (nonatomic, strong) NSString *strAdditionalNoteId;
///will hold FB if user responded to the alert opened through Facebook
@property (nonatomic, strong) NSString *strUserType;

///FRIEND_APPROVED properties
@property (nonatomic, strong) NSString *strTaskId;

///VIDEO Properties, hold LIVE or VOD
@property (nonatomic, strong) NSString *strStatus;

///PHOTO properties, hold photo file associated to photo alert fetched from parse
@property (nonatomic, strong) PFFileObject *photoFile;

///NEEDY_FORWARDED properties
@property (nonatomic, strong) NSString *strForwardedBy;
@property (nonatomic, strong) NSString *strForwardingAlertId;

///Public CELL_REQUEST properties
@property (nonatomic, strong) NSString *strCellRequestObjectId;

///NEEDY_CELL(properties for recieving alert sent to public cell) or CELL_REQUEST common properties
@property (nonatomic, strong) NSString *strCellId;
@property (nonatomic, strong) NSString *strCellName;

@property (nonatomic, assign,getter=isDeepLinked) BOOL deepLinked;

///Ride Properties
@property (nonatomic, assign) double pickUpLat;
@property (nonatomic, assign) double pickUpLon;
@property (nonatomic, assign) double dropLat;
@property (nonatomic, assign) double dropLon;
@property (nonatomic, strong) NSString *strRideRequestId;
@property (nonatomic, strong) NSString *strRideResponseId;
@property (nonatomic, strong) NSString *strCost;
@property (nonatomic, assign, getter=isRideCompleted) BOOL rideCompleted;
@property (nonatomic, assign, getter=isPickupReached) BOOL pickupReached;

@end
