//
//  C411AlertHelper.m
//  cell411
//
//  Created by Milan Agarwal on 27/02/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411AlertHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"

#if NOTIFICATION_ACK_ENABLED
#import "ServerUtility.h"
#endif

@implementation C411AlertHelper

//****************************************************
#pragma mark - Public Methods
//****************************************************

+(void)handleAlertNotificationRequest:(UNNotificationRequest *)request withBestAttemptContent:(UNMutableNotificationContent *)bestAttemptContent andContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler
{
  
#if NOTIFICATION_ACK_ENABLED
    
    NSDictionary *userInfo = bestAttemptContent.userInfo;
    
    ///Get the key and alertType value
    NSString *strAlertAckKey = userInfo[kPayloadAlertAckKey];
    NSString *strAlertType = userInfo[kPayloadAlertTypeKey];
    
    if((strAlertAckKey.length > 0)
       && ([strAlertType isEqualToString:kPayloadAlertTypeNeedy]
           || [strAlertType isEqualToString:kPayloadAlertTypePhoto]
           || [strAlertType isEqualToString:kPayloadAlertTypeNeedyForwarded]
           || [strAlertType isEqualToString:kPayloadAlertTypeNeedyCell]
           || [strAlertType isEqualToString:kPayloadAlertTypePhotoCell]))
    {
        [self sendAckForAlertNotificationWithKey:strAlertAckKey];
    }
#endif
    
    contentHandler(bestAttemptContent);
}

#if NOTIFICATION_ACK_ENABLED

+(void)saveLoggedInUserId:(NSString *)strUserId
{
    if(strUserId.length > 0){
    
        NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
        [defaults setObject:strUserId forKey:kLoggedInUserIdKey];
        [defaults synchronize];
        
    }
    
}

+(void)clearNotificationAckData
{
    [self removeLoggedInUserId];
}
#endif


//****************************************************
#pragma mark - Private Methods
//****************************************************

#if NOTIFICATION_ACK_ENABLED
+(void)sendAckForAlertNotificationWithKey:(NSString *)strAlertAckKey
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    
    NSString *strLoggedInUserId = [defaults objectForKey:kLoggedInUserIdKey];
    
    if(strLoggedInUserId.length > 0){
        
        NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
        
        dictParams[API_PARAM_KEY] = strAlertAckKey;
        dictParams[API_PARAM_USER_ID] = strLoggedInUserId;
        dictParams[API_PARAM_CLIENT_FIRM_ID] = CLIENT_FIRM_ID;
        dictParams[API_PARAM_IS_LIVE] = IS_APP_LIVE;
        
        [ServerUtility sendAckForAlertNotificationWithDetails:dictParams andCompletion:NULL];

    }
    
}

+(void)removeLoggedInUserId
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    [defaults removeObjectForKey:kLoggedInUserIdKey];
    [defaults synchronize];
    
}

#endif



@end
