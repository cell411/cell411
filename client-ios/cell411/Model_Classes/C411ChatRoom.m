//
//  C411ChatRoom.m
//  cell411
//
//  Created by Milan Agarwal on 07/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ChatRoom.h"
#import "Constants.h"
#import "C411ChatHelper.h"

@implementation C411ChatRoom

//****************************************************
#pragma mark - NSCoder implementation
//****************************************************


NSString *const kCoderKey_strEntityId = @"strEntityId";
NSString *const kCoderKey_strEntityName = @"strEntityName";
NSString *const kCoderKey_entityType = @"entityType";
NSString *const kCoderKey_unreadMsgCount = @"unreadMsgCount";
NSString *const kCoderKey_entityCreatedAtInMillis = @"entityCreatedAtInMillis";
NSString *const kCoderKey_isRemoved = @"isRemoved";
NSString *const kCoderKey_strLastMsg = @"strLastMsg";
NSString *const kCoderKey_lastMsgTimestamp = @"lastMsgTimestamp";
NSString *const kCoderKey_strLastMsgSenderId = @"strLastMsgSenderId";
NSString *const kCoderKey_strLastMsgSenderFirstName = @"strLastMsgSenderFirstName";
NSString *const kCoderKey_strLastMsgSenderLastName = @"strLastMsgSenderLastName";
NSString *const kCoderKey_lastMsgType = @"lastMsgType";
NSString *const kCoderKey_isLastMsgIncoming = @"isLastMsgIncoming";



- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.strEntityId forKey:kCoderKey_strEntityId];
    [encoder encodeObject:self.strEntityName forKey:kCoderKey_strEntityName];

    [encoder encodeObject:@(self.entityType) forKey:kCoderKey_entityType];
    [encoder encodeObject:@(self.unreadMsgCount) forKey:kCoderKey_unreadMsgCount];
    [encoder encodeObject:@(self.entityCreatedAtInMillis) forKey:kCoderKey_entityCreatedAtInMillis];
    
    [encoder encodeObject:@(self.isRemoved) forKey:kCoderKey_isRemoved];

    [encoder encodeObject:self.strLastMsg forKey:kCoderKey_strLastMsg];
    [encoder encodeObject:self.lastMsgTimestamp forKey:kCoderKey_lastMsgTimestamp];
    [encoder encodeObject:self.strLastMsgSenderId forKey:kCoderKey_strLastMsgSenderId];
    [encoder encodeObject:self.strLastMsgSenderFirstName forKey:kCoderKey_strLastMsgSenderFirstName];
    [encoder encodeObject:self.strLastMsgSenderLastName forKey:kCoderKey_strLastMsgSenderLastName];
    [encoder encodeObject:@(self.lastMsgType) forKey:kCoderKey_lastMsgType];
    [encoder encodeObject:@(self.isLastMsgIncoming) forKey:kCoderKey_isLastMsgIncoming];

}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.strEntityId = [aDecoder decodeObjectForKey:kCoderKey_strEntityId];
    self.strEntityName = [aDecoder decodeObjectForKey:kCoderKey_strEntityName];
    self.entityType = [[aDecoder decodeObjectForKey:kCoderKey_entityType]integerValue];
    self.unreadMsgCount = [[aDecoder decodeObjectForKey:kCoderKey_unreadMsgCount]integerValue];
    self.entityCreatedAtInMillis = [[aDecoder decodeObjectForKey:kCoderKey_entityCreatedAtInMillis]doubleValue];
    self.isRemoved = [[aDecoder decodeObjectForKey:kCoderKey_isRemoved]boolValue];

    self.strLastMsg = [aDecoder decodeObjectForKey:kCoderKey_strLastMsg];
    self.lastMsgTimestamp = [aDecoder decodeObjectForKey:kCoderKey_lastMsgTimestamp];
    self.strLastMsgSenderId = [aDecoder decodeObjectForKey:kCoderKey_strLastMsgSenderId];
    self.strLastMsgSenderFirstName = [aDecoder decodeObjectForKey:kCoderKey_strLastMsgSenderFirstName];
    self.strLastMsgSenderLastName = [aDecoder decodeObjectForKey:kCoderKey_strLastMsgSenderLastName];
    self.lastMsgType = [[aDecoder decodeObjectForKey:kCoderKey_lastMsgType]integerValue];
    self.isLastMsgIncoming = [[aDecoder decodeObjectForKey:kCoderKey_isLastMsgIncoming]boolValue];

    return self;
}


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

-(instancetype)initWithDictionary:(NSDictionary *)dictRoomInfo isMsgIncoming:(BOOL)isMsgIncoming
{
    if (self = [super init]) {
        
        ///Initialize the properties using dictionary keys
        self.strEntityId = dictRoomInfo[kPayloadChatEntityObjectIdKey];
        self.strEntityName = dictRoomInfo[kPayloadChatEntityNameKey];
        self.entityType = [C411ChatHelper getChatEntityTypeFromString:dictRoomInfo[kPayloadChatEntityTypeKey]];
        self.entityCreatedAtInMillis = [dictRoomInfo[kPayloadChatEntityCreatedAtKey]doubleValue];
        self.strLastMsg = dictRoomInfo[kPayloadChatMsgKey];
        NSTimeInterval lastMsgTimeInterval = [dictRoomInfo[kPayloadChatTimeKey]doubleValue] / 1000;
        self.lastMsgTimestamp = [NSDate dateWithTimeIntervalSince1970:lastMsgTimeInterval];
        self.strLastMsgSenderId = dictRoomInfo[kPayloadChatSenderIdKey];
        self.strLastMsgSenderFirstName = dictRoomInfo[kPayloadChatSenderFirstNameKey];
        self.strLastMsgSenderLastName = dictRoomInfo[kPayloadChatSenderLastNameKey];
        self.lastMsgType = [C411ChatHelper getChatMsgTypeFromString:dictRoomInfo[kPayloadChatMsgTypeKey]];
        self.isLastMsgIncoming = isMsgIncoming;
        
    }
    
    return self;
}

-(void)updateWithMessage:(NSDictionary *)dictMessage isMsgIncoming:(BOOL)isMsgIncoming

{
    self.strLastMsg = dictMessage[kPayloadChatMsgKey];
    NSTimeInterval lastMsgTimeInterval = [dictMessage[kPayloadChatTimeKey]doubleValue] / 1000;
    self.lastMsgTimestamp = [NSDate dateWithTimeIntervalSince1970:lastMsgTimeInterval];
    self.strLastMsgSenderId = dictMessage[kPayloadChatSenderIdKey];
    self.strLastMsgSenderFirstName = dictMessage[kPayloadChatSenderFirstNameKey];
    self.strLastMsgSenderLastName = dictMessage[kPayloadChatSenderLastNameKey];
    self.lastMsgType = [C411ChatHelper getChatMsgTypeFromString:dictMessage[kPayloadChatMsgTypeKey]];
    self.isLastMsgIncoming = isMsgIncoming;
    NSNumber *numEntityCreatedAt = dictMessage[kPayloadChatEntityCreatedAtKey];
    if (numEntityCreatedAt) {
        self.entityCreatedAtInMillis = [numEntityCreatedAt doubleValue];
    }
    
    
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

//-(NSData *)archive
//{
//    return [NSKeyedArchiver archivedDataWithRootObject:self];
//}
//
//+(instancetype)unarchiveWithData:(NSData *)data
//{
//    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
//}


@end
