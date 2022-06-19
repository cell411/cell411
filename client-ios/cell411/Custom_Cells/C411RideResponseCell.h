//
//  C411RideResponseCell.h
//  cell411
//
//  Created by Milan Agarwal on 03/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"

@interface C411RideResponseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vuBase;
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblResponderName;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuClock;
@property (weak, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (weak, nonatomic) IBOutlet UIButton *btnFlag;

@end
