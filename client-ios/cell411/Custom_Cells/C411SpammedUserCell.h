//
//  C411SpammedUserCell.h
//  cell411
//
//  Created by Milan Agarwal on 18/10/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"

@interface C411SpammedUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFriendName;
@property (weak, nonatomic) IBOutlet UIButton * btnUnSpam;
@end
