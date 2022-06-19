//
//  C411FriendSelectionCell.h
//  cell411
//
//  Created by Milan Agarwal on 03/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"
#import "MAGCheckbox.h"

@interface C411FriendSelectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFriendName;

@property (weak, nonatomic) IBOutlet MAGCheckbox *btnCheckbox;

@end
