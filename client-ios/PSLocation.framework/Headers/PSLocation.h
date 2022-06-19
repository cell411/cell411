//
//  PSLocation.h
//
//  Copyright (c) 2015-present PathSense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import <PSLocation/PSLocationManager.h>
#import <PSLocation/PSLocationManagerDelegate.h>

/*!
 The `PSLocation` class contains static functions that handle global configuration for the PSLocation framework.
 */
@interface PSLocation : NSObject

/*!
 @abstract Sets the applicationId and clientKey of your application.

 @param inApiKey The API key for your PSLocation application.
 @param inClientID The client ID for your PSLocation application.
 */
+ (void)setApiKey:(NSString *)inApiKey andClientID:(NSString *)inClientID;

/*!
 @abstract The current API key that was used to configure PSLocation framework.
 
 */
+ (const NSString *)getAPIKey;

/*!
 @abstract The current client ID that was used to configure PSLocation framework.
 
 */
+ (const NSString *)getClientID;


@end
