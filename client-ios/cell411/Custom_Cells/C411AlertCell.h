//
//  C411AlertCell.h
//  cell411
//
//  Created by Milan Agarwal on 04/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"

@interface C411AlertCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertType;
@property (weak, nonatomic) IBOutlet UITextView *txtVuAlertTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuClock;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTimestamp;
@property (weak, nonatomic) IBOutlet UIButton *btnFlag;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;

@property (nonatomic, strong) NSString *strAlertType;

@end
