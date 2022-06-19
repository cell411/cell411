//
//  C411RecentChatCell.h
//  cell411
//
//  Created by Milan Agarwal on 09/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C411ChatRoom;

@interface C411RecentChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVuChatEntity;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertType;
@property (weak, nonatomic) IBOutlet UILabel *lblEntityName;
@property (weak, nonatomic) IBOutlet UILabel *lblLastMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblLastMsgTimestamp;
@property (weak, nonatomic) IBOutlet UIView *vuUnreadMsgCountBase;
@property (weak, nonatomic) IBOutlet UILabel *lblUnreadMsgCount;


-(void)updateDetailsUsingChatRoom:(C411ChatRoom *)chatRoom;

@end
