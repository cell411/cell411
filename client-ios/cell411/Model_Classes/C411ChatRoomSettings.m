//
//  C411ChatRoomSettings.m
//  cell411
//
//  Created by Milan Agarwal on 07/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ChatRoomSettings.h"

@implementation C411ChatRoomSettings

//****************************************************
#pragma mark - NSCoder implementation
//****************************************************


NSString *const kCoderKey_strEntityId_settings = @"strEntityId_settings";
NSString *const kCoderKey_strEntityName_settings = @"strEntityName_settings";
NSString *const kCoderKey_entityType_settings = @"entityType_settings";
NSString *const kCoderKey_isMute_settings = @"isMute_settings";
NSString *const kCoderKey_chatMuteTimeType_settings = @"chatMuteTimeType_settings";
NSString *const kCoderKey_mutedUntil_settings = @"mutedUntil_settings";
NSString *const kCoderKey_mutedAt_settings = @"mutedAt_settings";
NSString *const kCoderKey_hideNotification_settings = @"hideNotification_settings";



- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.strEntityId forKey:kCoderKey_strEntityId_settings];
    [encoder encodeObject:self.strEntityName forKey:kCoderKey_strEntityName_settings];
    [encoder encodeObject:@(self.entityType) forKey:kCoderKey_entityType_settings];

    [encoder encodeObject:@(self.isMute) forKey:kCoderKey_isMute_settings];
    [encoder encodeObject:@(self.chatMuteTimeType) forKey:kCoderKey_chatMuteTimeType_settings];
    [encoder encodeObject:self.mutedUntil forKey:kCoderKey_mutedUntil_settings];
    [encoder encodeObject:self.mutedAt forKey:kCoderKey_mutedAt_settings];
    [encoder encodeObject:@(self.hideNotification) forKey:kCoderKey_hideNotification_settings];
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.strEntityId = [aDecoder decodeObjectForKey:kCoderKey_strEntityId_settings];
    self.strEntityName = [aDecoder decodeObjectForKey:kCoderKey_strEntityName_settings];
    self.entityType = [[aDecoder decodeObjectForKey:kCoderKey_entityType_settings]integerValue];

    self.isMute = [[aDecoder decodeObjectForKey:kCoderKey_isMute_settings]boolValue];
    self.chatMuteTimeType = [[aDecoder decodeObjectForKey:kCoderKey_chatMuteTimeType_settings]integerValue];
    
    self.mutedUntil = [aDecoder decodeObjectForKey:kCoderKey_mutedUntil_settings];
    self.mutedAt = [aDecoder decodeObjectForKey:kCoderKey_mutedAt_settings];
    self.hideNotification = [[aDecoder decodeObjectForKey:kCoderKey_hideNotification_settings]boolValue];
    
    return self;
}

-(instancetype)initWithDefaultSettingsForChatRoom:(C411ChatRoom *)chatRoom
{
    if (self = [super init]) {
        
        self.strEntityId = chatRoom.strEntityId;
        self.strEntityName = chatRoom.strEntityName;
        self.entityType = chatRoom.entityType;
    }
    
    return self;
    
}

-(instancetype)initWithEntityId:(NSString *)strEntityId entityName:(NSString *)strEntityName andEntityType:(ChatEntityType)entityType
{
    if (self = [super init]) {
        
        self.strEntityId = strEntityId;
        self.strEntityName = strEntityName;
        self.entityType = entityType;
    }
    
    return self;
}

@end
