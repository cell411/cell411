//
//  NotificationService.m
//  notificationserviceextension
//
//  Created by Milan Agarwal on 11/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "NotificationService.h"
#import "Constants.h"
#import "C411ChatHelper.h"
#import "C411AlertHelper.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    if ([self.bestAttemptContent.categoryIdentifier isEqualToString:kPayloadCategoryTypeMessage]) {
        
        ///This notification is related to Chat, so process it
        [C411ChatHelper handleChatNotificationRequest:request withBestAttemptContent:self.bestAttemptContent andContentHandler:contentHandler];
    }
    else if ([self.bestAttemptContent.categoryIdentifier isEqualToString:kPayloadCategoryTypeAlert]) {
        
        ///This notification is related to Chat, so process it
        [C411AlertHelper handleAlertNotificationRequest:request withBestAttemptContent:self.bestAttemptContent andContentHandler:contentHandler];
    }
    else{
        
        ///This notification is not yet handled for processing ,so display it as it is
        //self.bestAttemptContent.title = @"not found";

        self.contentHandler(self.bestAttemptContent);

    }
    // Modify the notification content here...
   // self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    //self.bestAttemptContent.body = [NSString stringWithFormat:@"%@",self.bestAttemptContent.userInfo];
    

    //self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
