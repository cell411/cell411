//
//  C411ChatRoomSettings.h
//  cell411
//
//  Created by Milan Agarwal on 07/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "C411ChatRoom.h"

@interface C411ChatRoomSettings : NSObject<NSCoding>

///Entity here means room
@property (nonatomic, strong) NSString *strEntityId;
@property (nonatomic, strong) NSString *strEntityName;
@property (nonatomic, assign) ChatEntityType entityType;
@property (nonatomic, assign) BOOL isMute;
@property (nonatomic, assign) ChatMuteTimeType chatMuteTimeType;
@property (nonatomic, strong) NSDate *mutedUntil;
@property (nonatomic, strong) NSDate *mutedAt;
@property (nonatomic, assign) BOOL hideNotification;

-(instancetype)initWithDefaultSettingsForChatRoom:(C411ChatRoom *)chatRoom;
-(instancetype)initWithEntityId:(NSString *)strEntityId entityName:(NSString *)strEntityName andEntityType:(ChatEntityType)entityType;
@end
