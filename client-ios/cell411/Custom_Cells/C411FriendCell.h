//
//  C411FriendCell.h
//  cell411
//
//  Created by Milan Agarwal on 16/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"

@interface C411FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFriendName;

@end
