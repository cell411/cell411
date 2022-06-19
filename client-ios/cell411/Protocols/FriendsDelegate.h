//
//  FriendsDelegate.h
//  cell411
//
//  Created by Milan Agarwal on 17/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

@protocol FriendsDelegate <NSObject>

@property(nonatomic, readonly) NSArray *arrFriends;

-(void)addFriend:(id)userFriend;
-(void)removeFriendAtIndex:(NSUInteger)index;
-(void)removeFriend:(id)userFriend;

@optional
-(void)updateFriends;

@end
