//
//  C411OtherPublicCell.h
//  cell411
//
//  Created by Milan Agarwal on 27/01/16.
//  Copyright (c) 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C411OtherPublicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVuCell;
@property (weak, nonatomic) IBOutlet UILabel *lblCellName;
@property (weak, nonatomic) IBOutlet UIButton *btnJoinStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuVerified;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;

@property (nonatomic, strong) NSString *strStatus;

@end
