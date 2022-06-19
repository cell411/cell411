//
//  C411ChatHelper.m
//  cell411
//
//  Created by Milan Agarwal on 17/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ChatHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "C411ChatRoom.h"
#import "C411ChatRoomSettings.h"

@implementation C411ChatHelper

//****************************************************
#pragma mark - Public Methods
//****************************************************

+(void)handleChatNotificationRequest:(UNNotificationRequest *)request withBestAttemptContent:(UNMutableNotificationContent *)bestAttemptContent andContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler
{
    //bestAttemptContent.title = @"found";
    
    NSDictionary *userInfo = bestAttemptContent.userInfo;
    
    ///Get the chat room with given entity id
    NSString *strEntityId = userInfo[kPayloadChatEntityObjectIdKey];
    C411ChatRoom *chatRoom = [self getChatRoomWithId:strEntityId];
    [self updateChatRoom:chatRoom withMessageData:userInfo isIncoming:YES];
    
    ///get the chat room settings for the given entity id
    C411ChatRoomSettings *chatRoomSettings = [self getChatRoomSettingsWithId:strEntityId];
    if (chatRoomSettings) {
        
        ///Check whether mute is enabled or not
        if ([self isChatRoomWithSettingsMuted:chatRoomSettings]) {
            
            ///Chat room is muted
            if (!chatRoomSettings.hideNotification) {
                ///Show notification without sound
                bestAttemptContent.sound = nil;
                
            }
            else{
                
                ///Notification is completely muted don't show it as well.
                bestAttemptContent.title = nil;
                bestAttemptContent.subtitle = nil;
                bestAttemptContent.body = nil;
                bestAttemptContent.sound = nil;

            }
            
        }
        else{
            
            ///Chat room is not mute we can show the notification with sound
            
        }
        
    }
    

    contentHandler(bestAttemptContent);
}

+(NSString *)getChatMessagePathForEntityType:(ChatEntityType)entityType andEntityId:(NSString *)strEntityId
{
    NSString *strPath = @"";
    switch (entityType) {
        case ChatEntityTypePublicCell:
            strPath = [NSString stringWithFormat:@"messages/publicCells/%@/chats",strEntityId];
            break;
        case ChatEntityTypePrivateCell:
            break;
        case ChatEntityTypeAlert:
            strPath = [NSString stringWithFormat:@"messages/alerts/%@/chats",strEntityId];

            break;
            
        default:
            break;
    }
    
    return strPath;
}

+(NSString *)getChatNotificationPathForEntityType:(ChatEntityType)entityType andEntityId:(NSString *)strEntityId
{
    NSString *strPath = @"";
    switch (entityType) {
        case ChatEntityTypePublicCell:
            strPath = [NSString stringWithFormat:@"notifications/publicCells/%@/chats",strEntityId];
            break;
        case ChatEntityTypePrivateCell:
            break;
        case ChatEntityTypeAlert:
            strPath = [NSString stringWithFormat:@"notifications/alerts/%@/chats",strEntityId];
            break;
            
        default:
            break;
    }
    
    return strPath;
}

+(ChatEntityType)getChatEntityTypeFromString:(NSString *)strChatEntityType
{
    if ([strChatEntityType isEqualToString:@"PUBLIC_CELL"]) {
        
        return ChatEntityTypePublicCell;
    }
    else if([strChatEntityType isEqualToString:@"PRIVATE_CELL"]){
        
        return ChatEntityTypePrivateCell;
    }
    else if([strChatEntityType isEqualToString:@"ALERT"]){
        
        return ChatEntityTypeAlert;
    }
    else{
        
        return  ChatEntityTypeInvalid;
    }
    
}

+(NSString *)getChatEntityTypeStringFromType:(ChatEntityType)chatEntityType
{
    switch (chatEntityType) {
        case ChatEntityTypePublicCell:
            return @"PUBLIC_CELL";
            break;
        case ChatEntityTypePrivateCell:
            return @"PRIVATE_CELL";
            break;
        case ChatEntityTypeAlert:
            return @"ALERT";
            break;
            
        default:
            return @"";
            break;
    }
}

+(ChatMsgType)getChatMsgTypeFromString:(NSString *)strChatMsgype
{
    if ([strChatMsgype isEqualToString:kChatMsgTypeText]) {
        
        return ChatMsgTypeText;
    }
    else if ([strChatMsgype isEqualToString:kChatMsgTypeLoc]) {
        
        return ChatMsgTypeLoc;
    }
    else if ([strChatMsgype isEqualToString:kChatMsgTypeImg]) {
        
        return ChatMsgTypeImg;
    }
    else{
        
        return  ChatMsgTypeInvalid;
    }
    
}

+(NSString *)getChatMsgTypeStringFromType:(ChatMsgType)chatMsgType
{
    switch (chatMsgType) {
        case ChatMsgTypeText:
            return kChatMsgTypeText;
            break;
        case ChatMsgTypeLoc:
            return kChatMsgTypeLoc;
            break;
        case ChatMsgTypeImg:
            return kChatMsgTypeImg;
            break;

        default:
            return @"";
            break;
    }
}


+(void)updateChatRoomWithEntityObjectId:(NSString *)strEntityObjectId withMessageData:(NSDictionary *)dictMsgDetails isIncoming:(BOOL)isMsgIncoming
{
    C411ChatRoom *chatRoom = [self getChatRoomWithId:strEntityObjectId];
    [self updateChatRoom:chatRoom withMessageData:dictMsgDetails isIncoming:isMsgIncoming];
}

+(BOOL)isChatRoomWithEntityIdMuted:(NSString *)strEntityId
{
    
    ///get the chat room settings for the given entity id
    C411ChatRoomSettings *chatRoomSettings = [self getChatRoomSettingsWithId:strEntityId];
    
    return [self isChatRoomWithSettingsMuted:chatRoomSettings];
    
}

+(void)unmuteChatRoomWithEntityId:(NSString *)strEntityId
{
    
    ///get the chat room settings for the given entity id
    C411ChatRoomSettings *chatRoomSettings = [self getChatRoomSettingsWithId:strEntityId];
    
    [self unmuteChatRoomWithSettings:chatRoomSettings];
}


+(void)muteChatRoomWithEntityId:(NSString *)strEntityId forTime:(ChatMuteTimeType)chatMuteTimeType withNotificationEnabled:(BOOL)isNotificationEnabled
{
    
    ///get the chat room settings for the given entity id
    C411ChatRoomSettings *chatRoomSettings = [self getChatRoomSettingsWithId:strEntityId];
    
    [self muteChatRoomWithSettings:chatRoomSettings forTime:chatMuteTimeType withNotificationEnabled:isNotificationEnabled];
}

+(void)resetUnreadMsgCounterForChatRoomWithEntityId:(NSString *)strEntityId
{
    C411ChatRoom *chatRoom = [self getChatRoomWithId:strEntityId];
    [self resetUnreadMsgCounterForChatRoom:chatRoom];
}

+(void)handleUserRemovedFromEntityWithId:(NSString *)strEntityId
{
    C411ChatRoom *chatRoom = [self getChatRoomWithId:strEntityId];
    chatRoom.isRemoved = YES;
    [self updateExistingChatRoomWithNewChatRoom:chatRoom];
}

+(BOOL)isUserRemovedFromEntityWithId:(NSString *)strEntityId
{
    C411ChatRoom *chatRoom = [self getChatRoomWithId:strEntityId];
    if (chatRoom && chatRoom.isRemoved) {
        
        return YES;
    }
    
    ///Will return NO is user is not removed or if there is no data available for this room, so it needs to validated from backened whether user exist on a particular cell or not in this case
    return NO;

}

+(BOOL)canChatOnAlertIssuedAt:(NSTimeInterval)createdAtInMillis
{

    double currentTimeInMillis = [[NSDate date]timeIntervalSince1970] * 1000;///Multiply by 1000 to convert it from second to millisecond
        
    double timeElaplsedInMillis = currentTimeInMillis - createdAtInMillis;
        
        if (timeElaplsedInMillis <= ((ALERT_CHAT_EXPIRATION_TIME)*1000.0)) {
            
            ///Not yet expired
            return YES;
            
        }
    
    return NO;
}


//+(void)chatRoomOpenedWithEntityId:(NSString *)strEntityId
//{
//    if (![self.arrOpenChatEntityIds containsObject:strEntityId]) {
//        
//        ///Insert it
//        [self.arrOpenChatEntityIds addObject:strEntityId];
//    }
//}
//
//+(void)chatRoomClosedWithEntityId:(NSString *)strEntityId
//{
//    [self.arrOpenChatEntityIds removeObject:strEntityId];
//}


+(NSMutableArray *)getRecentChats
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    NSData *rececntChatData = [defaults objectForKey:kRecentChatKey];
    if (rececntChatData) {
        
        NSMutableArray *arrRecentChats = [[NSKeyedUnarchiver unarchiveObjectWithData:rececntChatData]mutableCopy];
        return arrRecentChats;
    }
    
    ///return an empty array
    return [NSMutableArray array];
    
}



+(void)clearRecentChatsData
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    [defaults removeObjectForKey:kRecentChatKey];
    [defaults removeObjectForKey:kChatRoomsSettingsKey];
    [defaults synchronize];
}

+(void)deleteChatRoomWithEntityObjectId:(NSString *)strEntityObjectId
{
    NSMutableArray *arrRecentChats = [self getRecentChats];
    NSInteger roomIndex = -1;
    for (NSInteger index = 0; index < arrRecentChats.count; index++) {
        C411ChatRoom *chatRoom = [arrRecentChats objectAtIndex:index];
        if ([strEntityObjectId isEqualToString:chatRoom.strEntityId]) {
            roomIndex = index;
            break;
        }
        
    }
    
    ///remove object if index is non zero value
    if (roomIndex >= 0) {
        
        [arrRecentChats removeObjectAtIndex:roomIndex];
        [self saveRecentChats:arrRecentChats];
        
    }
    
}

+(C411ChatRoomSettings *)getChatRoomSettingsWithId:(NSString *)strEntityId
{
    NSArray *arrRecentChatRoomsSettings = [self getChatRoomSettings];
    for (C411ChatRoomSettings *chatRoomSettings in arrRecentChatRoomsSettings) {
        
        if ([strEntityId isEqualToString:chatRoomSettings.strEntityId]) {
            return chatRoomSettings;
        }
        
    }
    
    return nil;
}

+(void)insertChatRoomSetting:(C411ChatRoomSettings *)chatRoomSetting
{
    if([self getChatRoomSettingsWithId:chatRoomSetting.strEntityId]){
        ///Replace it with the existing one
        [self updateExistingChatRoomSettingWithNewSettings:chatRoomSetting];
    }
    else{
        ///Insert it in the array of chat rooms settings
        NSMutableArray *arrRecentChatRoomsSettings = [self getChatRoomSettings];
        [arrRecentChatRoomsSettings addObject:chatRoomSetting];
        [self saveChatRoomSettings:arrRecentChatRoomsSettings];
    }
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

+(NSMutableArray *)getChatRoomSettings
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    
    NSData *chatRoomSettingsData = [defaults objectForKey:kChatRoomsSettingsKey];
    if (chatRoomSettingsData) {
        
        NSMutableArray *arrRecentChatRoomsSettings = [[NSKeyedUnarchiver unarchiveObjectWithData:chatRoomSettingsData]mutableCopy];
        return arrRecentChatRoomsSettings;
    }
    
    ///return an empty array
    return [NSMutableArray array];
    
}


+(void)saveRecentChats:(NSArray *)arrRecentChats{
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    if (arrRecentChats) {
        NSData *recentChatData = [NSKeyedArchiver archivedDataWithRootObject:arrRecentChats];
        [defaults setObject:recentChatData forKey:kRecentChatKey];
        
    }
        
    [defaults synchronize];
}


+(void)saveChatRoomSettings:(NSArray *)arrRecentChatRoomsSettings{
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];

    if (arrRecentChatRoomsSettings) {
        NSData *chatRoomsSettingsData = [NSKeyedArchiver archivedDataWithRootObject:arrRecentChatRoomsSettings];
        [defaults setObject:chatRoomsSettingsData forKey:kChatRoomsSettingsKey];
        
    }
    
    [defaults synchronize];
}

+(C411ChatRoom *)getChatRoomWithId:(NSString *)strEntityId
{
    NSArray *arrRecentChats = [self getRecentChats];
    for (C411ChatRoom *chatRoom in arrRecentChats) {
        
        if ([strEntityId isEqualToString:chatRoom.strEntityId]) {
            return chatRoom;
        }
        
    }
    
    return nil;
}

+(void)updateChatRoom:(C411ChatRoom *)chatRoom withMessageData:(NSDictionary *)dictMsgDetails isIncoming:(BOOL)isMsgIncoming;

{
    if (chatRoom) {
        
        ///Update the chatroom details
        [chatRoom updateWithMessage:dictMsgDetails isMsgIncoming:isMsgIncoming];
        
        ///Update the unread message counter if it's an incoming message
        if (isMsgIncoming) {
            
            chatRoom.unreadMsgCount++;
            
        }
        
        ///replace the existing chatroom with this
        [self updateExistingChatRoomWithNewChatRoom:chatRoom];

    }
    else{
        
        ///Create a new chatroom
        chatRoom = [[C411ChatRoom alloc]initWithDictionary:dictMsgDetails isMsgIncoming:isMsgIncoming];
        
        ///Update the unread message counter if it's an incoming message
        if (isMsgIncoming) {
            
            chatRoom.unreadMsgCount++;
         }

        ///Insert it in the array of chat rooms and save it
        NSMutableArray *arrRecentChats = [self getRecentChats];
        [arrRecentChats insertObject:chatRoom atIndex:0];
        [self saveRecentChats:arrRecentChats];
        
        ///Create a chat room settings for this chat room if it doesn't exist
        C411ChatRoomSettings *chatRoomSetting = [self getChatRoomSettingsWithId:chatRoom.strEntityId];
        if(!chatRoomSetting){
            chatRoomSetting = [[C411ChatRoomSettings alloc]initWithDefaultSettingsForChatRoom:chatRoom];
            
            ///Insert it in the array of chat rooms settings
            NSMutableArray *arrRecentChatRoomsSettings = [self getChatRoomSettings];
            [arrRecentChatRoomsSettings addObject:chatRoomSetting];
            [self saveChatRoomSettings:arrRecentChatRoomsSettings];
        }
        
    }
    
    
}




+(BOOL)isChatRoomWithSettingsMuted:(C411ChatRoomSettings *)chatRoomSettings
{
    ///Check whether mute is enabled or not
    if (chatRoomSettings.isMute) {
        
        ///Chat room is muted
        ///Check if the mute time is over or not
        if ([chatRoomSettings.mutedUntil timeIntervalSince1970] > [[NSDate date]timeIntervalSince1970]) {
            
            ///Mute time is not yet over
            return YES;
            
        }
        else{
            ///Mute time is over but it's not updated on settings, so update it and return No as it's no longer muted
            [self unmuteChatRoomWithSettings:chatRoomSettings];
            
            return NO;
        }
    }
    else{
        
        ///Chat room is not mute
        
        return NO;
        
    }
    
}

+(void)unmuteChatRoomWithSettings:(C411ChatRoomSettings *)chatRoomSettings
{
    if (chatRoomSettings) {
        
        ///Unmute chat room and save it
        chatRoomSettings.isMute = NO;
        chatRoomSettings.mutedUntil = nil;
        chatRoomSettings.mutedAt = nil;
        chatRoomSettings.chatMuteTimeType = ChatMuteTimeTypeDefault;
        chatRoomSettings.hideNotification = NO;
        
        ///Save the chat data as settings is modified
        [self updateExistingChatRoomSettingWithNewSettings:chatRoomSettings];
        
        
    }
}

+(void)muteChatRoomWithSettings:(C411ChatRoomSettings *)chatRoomSettings forTime:(ChatMuteTimeType)chatMuteTimeType withNotificationEnabled:(BOOL)isNotificationEnabled
{
    if (chatRoomSettings) {
        
        ///Unmute chat room and save it
        chatRoomSettings.isMute = YES;
        chatRoomSettings.mutedAt = [NSDate date];
        chatRoomSettings.chatMuteTimeType = chatMuteTimeType;
        chatRoomSettings.hideNotification = !isNotificationEnabled;
        
        switch (chatMuteTimeType) {
            case ChatMuteTimeType1Hour:
                chatRoomSettings.mutedUntil = [chatRoomSettings.mutedAt dateByAddingTimeInterval:60*60];
                break;
            case ChatMuteTimeType6Hours:
                chatRoomSettings.mutedUntil = [chatRoomSettings.mutedAt dateByAddingTimeInterval:6*60*60];
                break;
            case ChatMuteTimeType24Hours:
                chatRoomSettings.mutedUntil = [chatRoomSettings.mutedAt dateByAddingTimeInterval:24*60*60];
                break;
            case ChatMuteTimeType1Month:
                chatRoomSettings.mutedUntil = [self getDateByAddingMonth:1 toDate:chatRoomSettings.mutedAt];
                break;
                
            default:
                break;
        }
        
        ///Save the chat data as settings is modified
        [self updateExistingChatRoomSettingWithNewSettings:chatRoomSettings];

        
        
    }
}

+(void)resetUnreadMsgCounterForChatRoom:(C411ChatRoom *)chatRoom
{
    chatRoom.unreadMsgCount = 0;
    [self updateExistingChatRoomWithNewChatRoom:chatRoom];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kUnreadMsgCountUpdatedNotification object:nil];
}


+(void)updateExistingChatRoomWithNewChatRoom:(C411ChatRoom *)newChatRoom
{
    NSMutableArray *arrRecentChats = [self getRecentChats];
    NSInteger roomIndex = -1;
    for (NSInteger index = 0; index < arrRecentChats.count; index++) {
        C411ChatRoom *chatRoom = [arrRecentChats objectAtIndex:index];
        if ([newChatRoom.strEntityId isEqualToString:chatRoom.strEntityId]) {
            roomIndex = index;
            break;
        }
        
    }
    
    ///replace object if index is non zero value
    if (roomIndex >= 0) {
        
        [arrRecentChats replaceObjectAtIndex:roomIndex withObject:newChatRoom];
        [self saveRecentChats:arrRecentChats];
        
    }

}

+(void)updateExistingChatRoomSettingWithNewSettings:(C411ChatRoomSettings *)newChatRoomSettings
{
    NSMutableArray *arrRecentChatRoomSettings = [self getChatRoomSettings];
    NSInteger settingIndex = -1;
    for (NSInteger index = 0; index < arrRecentChatRoomSettings.count; index++) {
        C411ChatRoomSettings *chatRoomSetting = [arrRecentChatRoomSettings objectAtIndex:index];
        if ([newChatRoomSettings.strEntityId isEqualToString:chatRoomSetting.strEntityId]) {
            settingIndex = index;
            break;
        }
        
    }
    
    ///replace object if index is non zero value
    if (settingIndex >= 0) {
        
        [arrRecentChatRoomSettings replaceObjectAtIndex:settingIndex withObject:newChatRoomSettings];
        [self saveChatRoomSettings:arrRecentChatRoomSettings];
        
    }
    
}



+(NSDate *)getDateByAddingMonth:(NSInteger)monthCount toDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:monthCount];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}


//+(NSString *)getUnreadMessagesStringForNotification
//{
//    
//    NSArray *arrRecentChats = [self getRecentChats];
//    for (C411ChatRoom *chatRoom in arrRecentChats) {
//        
//        if (chatRoom.unreadMsgCount > 0) {
//            
//            
//            
//        }
//        
//    }
//    
//}

@end
