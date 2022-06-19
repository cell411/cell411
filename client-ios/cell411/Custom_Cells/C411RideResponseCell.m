//
//  C411RideResponseCell.m
//  cell411
//
//  Created by Milan Agarwal on 03/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideResponseCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411RideResponseCell

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

-(void)dealloc
{
    [self unregisterFromNotifications];
}
//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///make circular images
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    
    ///configure status button
    self.btnFlag.layer.cornerRadius = 3.0;
    
    self.vuBase.layer.cornerRadius = 3.0;
    self.vuBase.layer.shadowOffset = CGSizeMake(0, 1);
    self.vuBase.layer.shadowOpacity = 0.8;
    self.vuBase.layer.masksToBounds = NO;
    
    [self applyColors];
}

-(void)applyColors
{
    ///Set light card color
    self.vuBase.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    
    ///Set Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblResponderName.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblTimestamp.textColor = secondaryTextColor;
    self.imgVuClock.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
    
    self.vuBase.layer.shadowColor = [C411ColorHelper sharedInstance].fabShadowColor.CGColor;
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
