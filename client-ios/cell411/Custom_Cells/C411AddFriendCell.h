//
//  C411AddFriendCell.h
//  cell411
//
//  Created by Milan Agarwal on 03/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFUser;

@interface C411AddFriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFriend;

@property (nonatomic, weak) PFUser *user;
@property (nonatomic, weak) NSMutableDictionary *dictAddFriendRequestState;

-(void)setupCell;

@end
