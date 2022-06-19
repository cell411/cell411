//
//  C411AlertHelper.h
//  cell411
//
//  Created by Milan Agarwal on 27/02/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface C411AlertHelper : NSObject

NS_ASSUME_NONNULL_BEGIN
///To suppress warnings in legacy code, we are assuming all the parameters to be _Nonnull Type, but it may or may not be nil
+(void)handleAlertNotificationRequest:(UNNotificationRequest *)request withBestAttemptContent:(UNMutableNotificationContent *)bestAttemptContent andContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler;

#if NOTIFICATION_ACK_ENABLED
+(void)clearNotificationAckData;
+(void)saveLoggedInUserId:(NSString *)strUserId;
#endif

NS_ASSUME_NONNULL_END
@end
