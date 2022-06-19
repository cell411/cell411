//
//  C411ChatHelper.h
//  cell411
//
//  Created by Milan Agarwal on 17/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "C411Enums.h"
@class C411ChatRoomSettings;
@interface C411ChatHelper : NSObject

NS_ASSUME_NONNULL_BEGIN
///To suppress warnings in legacy code, we are assuming all the parameters to be _Nonnull Type, but it may or may not be nil
+(void)handleChatNotificationRequest:(UNNotificationRequest *)request withBestAttemptContent:(UNMutableNotificationContent *)bestAttemptContent andContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler;


+(NSString *)getChatMessagePathForEntityType:(ChatEntityType)entityType andEntityId:(NSString *)strEntityId;
+(NSString *)getChatNotificationPathForEntityType:(ChatEntityType)entityType andEntityId:(NSString *)strEntityId;
+(ChatEntityType)getChatEntityTypeFromString:(NSString *)strChatEntityType;
+(NSString *)getChatEntityTypeStringFromType:(ChatEntityType)chatEntityType;
+(ChatMsgType)getChatMsgTypeFromString:(NSString *)strChatMsgype;
+(NSString *)getChatMsgTypeStringFromType:(ChatMsgType)chatMsgType;


+(void)updateChatRoomWithEntityObjectId:(NSString *)strEntityObjectId withMessageData:(NSDictionary *)dictMsgDetails isIncoming:(BOOL)isMsgIncoming;

+(BOOL)isChatRoomWithEntityIdMuted:(NSString *)strEntityId;
+(void)unmuteChatRoomWithEntityId:(NSString *)strEntityId;
+(void)muteChatRoomWithEntityId:(NSString *)strEntityId forTime:(ChatMuteTimeType)chatMuteTimeType withNotificationEnabled:(BOOL)isNotificationEnabled;
+(void)resetUnreadMsgCounterForChatRoomWithEntityId:(NSString *)strEntityId;
+(void)handleUserRemovedFromEntityWithId:(NSString *)strEntityId;
+(BOOL)isUserRemovedFromEntityWithId:(NSString *)strEntityId;
+(BOOL)canChatOnAlertIssuedAt:(NSTimeInterval)createdAtInMillis;

+(NSMutableArray *)getRecentChats;
+(void)clearRecentChatsData;
+(void)deleteChatRoomWithEntityObjectId:(NSString *)strEntityObjectId;
+(C411ChatRoomSettings *)getChatRoomSettingsWithId:(NSString *)strEntityId;
///Will save the chat room setting if it doesn't exist or replace the existing one with this setting.
+(void)insertChatRoomSetting:(C411ChatRoomSettings *)chatRoomSetting;
NS_ASSUME_NONNULL_END

@end
