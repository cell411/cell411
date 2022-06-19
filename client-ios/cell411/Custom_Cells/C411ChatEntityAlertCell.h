//
//  C411ChatEntityAlertCell.h
//  cell411
//
//  Created by Milan Agarwal on 07/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"

@interface C411ChatEntityAlertCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertType;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuClock;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTimestamp;

@property (nonatomic, strong) NSString *strAlertType;

@end
