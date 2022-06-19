//
//  C411ChatManager.m
//  cell411
//
//  Created by Milan Agarwal on 07/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ChatManager.h"
#import "C411ChatRoom.h"
#import "Constants.h"
#import "C411ChatRoomSettings.h"
#import "C411StaticHelper.h"
#import "DateHelper.h"

static C411ChatManager *sharedChatManager;

@interface C411ChatManager ()

///It will contain the list of ids for all the open chats
@property (nonatomic, strong) NSMutableArray *arrOpenChatEntityIds;

@end

@implementation C411ChatManager
//****************************************************
 #pragma mark - Public Interface
//****************************************************
 
 +(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!sharedChatManager) {
            
            sharedChatManager = [[C411ChatManager alloc]init];
            [sharedChatManager loadRecentChatData];
        }
    });
    
    return sharedChatManager;
    
}

-(void)handleSilentNotification:(NSDictionary *)userInfo withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    ///Get the chat room with given entity id
    NSString *strEntityId = userInfo[kPayloadChatEntityObjectIdKey];
    C411ChatRoom *chatRoom = [self getChatRoomWithId:strEntityId];
    [self updateChatRoom:chatRoom withMessageData:userInfo isIncoming:YES];
    
    ///trigger the local notifications using the chat room settings
    ///get the chat room settings for the given entity id
    C411ChatRoomSettings *chatRoomSettings = [self getChatRoomSettingsWithId:strEntityId];
    if (chatRoomSettings) {
        
        ///Check whether mute is enabled or not
        if ([self isChatRoomWithSettingsMuted:chatRoomSettings]) {
            
            ///Chat room is muted
            if (!chatRoomSettings.hideNotification) {
                ///Show notification without sound
                [self showLocalNotificationNowForChatRoom:chatRoom withSound:NO];
                
            }
            else{
                
                ///Notification is completely muted don't show it as well. Nothing to do here.
            }

        }
        else{
            
            ///Chat room is not mute, we can send the local notification with sound
            [self showLocalNotificationNowForChatRoom:chatRoom withSound:YES];
            

        }
        
    }
    
    ///Post Notification that a new chat message has arrived
    [[NSNotificationCenter defaultCenter]postNotificationName:kNewChatMessageArrivedNotification object:nil];
    
    
    if (completionHandler != NULL) {
        ///Call the completion handler
        completionHandler(UIBackgroundFetchResultNewData);

    }
}



-(void)updateChatRoomWithEntityObjectId:(NSString *)strEntityObjectId withMessageData:(NSDictionary *)dictMsgDetails isIncoming:(BOOL)isMsgIncoming
{
    C411ChatRoom *chatRoom = [self getChatRoomWithId:strEntityObjectId];
    [self updateChatRoom:chatRoom withMessageData:dictMsgDetails isIncoming:isMsgIncoming];
}

-(BOOL)isChatRoomWithEntityIdMuted:(NSString *)strEntityId
{
    
    ///get the chat room settings for the given entity id
    C411ChatRoomSettings *chatRoomSettings = [self getChatRoomSettingsWithId:strEntityId];
    
    return [self isChatRoomWithSettingsMuted:chatRoomSettings];
    
}

-(void)unmuteChatRoomWithEntityId:(NSString *)strEntityId
{
    
    ///get the chat room settings for the given entity id
    C411ChatRoomSettings *chatRoomSettings = [self getChatRoomSettingsWithId:strEntityId];
    
    [self unmuteChatRoomWithSettings:chatRoomSettings];
}


-(void)muteChatRoomWithEntityId:(NSString *)strEntityId forTime:(ChatMuteTimeType)chatMuteTimeType withNotificationEnabled:(BOOL)isNotificationEnabled
{
    
    ///get the chat room settings for the given entity id
    C411ChatRoomSettings *chatRoomSettings = [self getChatRoomSettingsWithId:strEntityId];
    
    [self muteChatRoomWithSettings:chatRoomSettings forTime:chatMuteTimeType withNotificationEnabled:isNotificationEnabled];
}

-(void)resetUnreadMsgCounterForChatRoomWithEntityId:(NSString *)strEntityId
{
    C411ChatRoom *chatRoom = [self getChatRoomWithId:strEntityId];
    [self resetUnreadMsgCounterForChatRoom:chatRoom];
}

-(void)chatRoomOpenedWithEntityId:(NSString *)strEntityId
{
    if (![self.arrOpenChatEntityIds containsObject:strEntityId]) {
        
        ///Insert it
        [self.arrOpenChatEntityIds addObject:strEntityId];
    }
}

-(void)chatRoomClosedWithEntityId:(NSString *)strEntityId
{
    [self.arrOpenChatEntityIds removeObject:strEntityId];
}

-(void)clearRecentChatsData
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    [defaults removeObjectForKey:kRecentChatKey];
    [defaults removeObjectForKey:kChatRoomsSettingsKey];
    [defaults synchronize];
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrRecentChats
{

    if (!_arrRecentChats) {
        ///try to get the data by loading it from defaults
        [self loadRecentChatData];
    }
    
    if (!_arrRecentChats) {
        ///if data is not available in defaults, make an empty array
        _arrRecentChats = [NSMutableArray array];
        
    }

    return _arrRecentChats;
}

-(NSMutableArray *)arrRecentChatRoomsSettings
{
    if (!_arrRecentChatRoomsSettings) {
        ///try to get the data by loading it from defaults
        [self loadRecentChatData];
    }
    
    if (!_arrRecentChatRoomsSettings) {
        
        ///if data is not available in defaults, make an empty array
        _arrRecentChatRoomsSettings = [NSMutableArray array];
    }
    
    return _arrRecentChatRoomsSettings;
}

-(NSMutableArray *)arrOpenChatEntityIds
{
    if (!_arrOpenChatEntityIds) {
        
        _arrOpenChatEntityIds = [NSMutableArray array];
    }
    
    return _arrOpenChatEntityIds;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)loadRecentChatData
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    NSData *rececntChatData = [defaults objectForKey:kRecentChatKey];
    if (rececntChatData) {
        
        self.arrRecentChats = [[NSKeyedUnarchiver unarchiveObjectWithData:rececntChatData]mutableCopy];
        
    }
    
    NSData *chatRoomSettingsData = [defaults objectForKey:kChatRoomsSettingsKey];
    if (chatRoomSettingsData) {
        
        self.arrRecentChatRoomsSettings = [[NSKeyedUnarchiver unarchiveObjectWithData:chatRoomSettingsData]mutableCopy];
        
    }

}

-(void)saveRecentChatsData
{
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:NOTIFICATION_SERVICE_SHARING_DEFAULTS];
    if (self.arrRecentChats) {
        NSData *recentChatData = [NSKeyedArchiver archivedDataWithRootObject:self.arrRecentChats];
        [defaults setObject:recentChatData forKey:kRecentChatKey];
        
    }
    
    if (self.arrRecentChatRoomsSettings) {
        NSData *chatRoomsSettingsData = [NSKeyedArchiver archivedDataWithRootObject:self.arrRecentChatRoomsSettings];
        [defaults setObject:chatRoomsSettingsData forKey:kChatRoomsSettingsKey];
        
    }
    
    [defaults synchronize];
}

-(C411ChatRoom *)getChatRoomWithId:(NSString *)strEntityId
{
    for (C411ChatRoom *chatRoom in self.arrRecentChats) {
        
        if ([strEntityId isEqualToString:chatRoom.strEntityId]) {
            return chatRoom;
        }
        
    }
    
    return nil;
}

-(C411ChatRoomSettings *)getChatRoomSettingsWithId:(NSString *)strEntityId
{
    for (C411ChatRoomSettings *chatRoomSettings in self.arrRecentChatRoomsSettings) {
        
        if ([strEntityId isEqualToString:chatRoomSettings.strEntityId]) {
            return chatRoomSettings;
        }
        
    }
    
    return nil;
}

-(void)updateChatRoom:(C411ChatRoom *)chatRoom withMessageData:(NSDictionary *)dictMsgDetails isIncoming:(BOOL)isMsgIncoming;

{
    if (chatRoom) {
        
        ///Update the chatroom details
        [chatRoom updateWithMessage:dictMsgDetails isMsgIncoming:isMsgIncoming];
    }
    else{
        
        ///Create a new chatroom
        chatRoom = [[C411ChatRoom alloc]initWithDictionary:dictMsgDetails isMsgIncoming:isMsgIncoming];
        
        ///Insert it in the array of chat rooms
        [self.arrRecentChats insertObject:chatRoom atIndex:0];
        
        ///Create a chat room settings for this chat room
        C411ChatRoomSettings *chatRoomSetting = [[C411ChatRoomSettings alloc]initWithDefaultSettingsForChatRoom:chatRoom];
        
        ///Insert it in the array of chat rooms settings
        [self.arrRecentChatRoomsSettings addObject:chatRoomSetting];
        
    }
    
    ///Update the unread message counter if it's an incoming message and it's window is not open
    if (isMsgIncoming
        && (![self.arrOpenChatEntityIds containsObject:chatRoom.strEntityId])) {
        
        chatRoom.unreadMsgCount++;
        
    }
    
    ///Save the chat data
    [self saveRecentChatsData];
    
}



-(void)showLocalNotificationNowForChatRoom:(C411ChatRoom *)chatRoom withSound:(BOOL)isSoundEnabled
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
    
        ///Present Notification
        [C411StaticHelper presentLocalNotificationNowWithSound:isSoundEnabled localizedMessage:NSLocalizedString(@"New Message", nil) userInfo:nil identifier:kChatMessageLocalNotifIdentifier];

    }
    else if(![self.arrOpenChatEntityIds containsObject:chatRoom.strEntityId]){
        
        ///show toast
        [AppDelegate showToastOnView:[AppDelegate sharedInstance].window.rootViewController.view withMessage:NSLocalizedString(@"New Message", nil)];
    }
}


-(BOOL)isChatRoomWithSettingsMuted:(C411ChatRoomSettings *)chatRoomSettings
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

-(void)unmuteChatRoomWithSettings:(C411ChatRoomSettings *)chatRoomSettings
{
    if (chatRoomSettings) {
        
        ///Unmute chat room and save it
        chatRoomSettings.isMute = NO;
        chatRoomSettings.mutedUntil = nil;
        chatRoomSettings.mutedAt = nil;
        chatRoomSettings.chatMuteTimeType = ChatMuteTimeTypeDefault;
        chatRoomSettings.hideNotification = NO;
        
        ///Save the chat data as settings is modified
        [self saveRecentChatsData];

        
    }
}

-(void)muteChatRoomWithSettings:(C411ChatRoomSettings *)chatRoomSettings forTime:(ChatMuteTimeType)chatMuteTimeType withNotificationEnabled:(BOOL)isNotificationEnabled
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
                chatRoomSettings.mutedUntil = [DateHelper getDateByAddingMonth:1 toDate:chatRoomSettings.mutedAt];
                break;

            default:
                break;
        }
        
        ///Save the chat data as settings is modified
        [self saveRecentChatsData];
        
        
    }
}

-(void)resetUnreadMsgCounterForChatRoom:(C411ChatRoom *)chatRoom
{
    chatRoom.unreadMsgCount = 0;
    [self saveRecentChatsData];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kUnreadMsgCountUpdatedNotification object:nil];
}

@end
