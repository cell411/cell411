//
//  C411ChatManager.h
//  cell411
//
//  Created by Milan Agarwal on 07/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface C411ChatManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrRecentChats;
@property (nonatomic, strong) NSMutableArray *arrRecentChatRoomsSettings;

+(instancetype)sharedInstance;

-(void)handleSilentNotification:(NSDictionary *)userInfo withFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

-(void)updateChatRoomWithEntityObjectId:(NSString *)strEntityObjectId withMessageData:(NSDictionary *)dictMsgDetails isIncoming:(BOOL)isMsgIncoming;

-(BOOL)isChatRoomWithEntityIdMuted:(NSString *)strEntityId;
-(void)unmuteChatRoomWithEntityId:(NSString *)strEntityId;
-(void)muteChatRoomWithEntityId:(NSString *)strEntityId forTime:(ChatMuteTimeType)chatMuteTimeType withNotificationEnabled:(BOOL)isNotificationEnabled;
-(void)resetUnreadMsgCounterForChatRoomWithEntityId:(NSString *)strEntityId;
-(void)chatRoomOpenedWithEntityId:(NSString *)strEntityId;
-(void)chatRoomClosedWithEntityId:(NSString *)strEntityId;
-(void)clearRecentChatsData;

@end
