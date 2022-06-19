//
//  C411ChatRoom.h
//  cell411
//
//  Created by Milan Agarwal on 07/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "C411Enums.h"

@interface C411ChatRoom : NSObject<NSCoding>

///Entity here means room
@property (nonatomic, strong) NSString *strEntityId;
@property (nonatomic, strong) NSString *strEntityName;
@property (nonatomic, assign) ChatEntityType entityType;
@property (nonatomic, assign) NSInteger unreadMsgCount;
@property (nonatomic, assign) NSTimeInterval entityCreatedAtInMillis;
@property (nonatomic, assign) BOOL isRemoved;

///Last msg details
@property (nonatomic, strong) NSString *strLastMsg;
@property (nonatomic, strong) NSDate *lastMsgTimestamp;
@property (nonatomic, strong) NSString *strLastMsgSenderId;
@property (nonatomic, strong) NSString *strLastMsgSenderFirstName;
@property (nonatomic, strong) NSString *strLastMsgSenderLastName;
@property (nonatomic, assign) ChatMsgType lastMsgType;
@property (nonatomic, assign) BOOL isLastMsgIncoming;

-(instancetype)initWithDictionary:(NSDictionary *)dictRoomInfo isMsgIncoming:(BOOL)isMsgIncoming;
-(void)updateWithMessage:(NSDictionary *)dictMessage isMsgIncoming:(BOOL)isMsgIncoming;

@end
