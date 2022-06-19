//
//  C411ChatEntityMyPublicCell.m
//  cell411
//
//  Created by Milan Agarwal on 07/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ChatEntityMyPublicCell.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@implementation C411ChatEntityMyPublicCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self configureViews];
    [self registerForNotifications];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc {
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    [C411StaticHelper makeCircularView:self.imgVuCell];
    [C411StaticHelper makeCircularView:self.imgVuVerified];
    [self applyColors];
}

-(void)applyColors
{
    self.lblCellName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.imgVuVerified.layer.borderColor = [UIColor whiteColor].CGColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}
@end
