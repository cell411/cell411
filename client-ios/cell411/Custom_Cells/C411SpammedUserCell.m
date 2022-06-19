//
//  C411SpammedUserCell.m
//  cell411
//
//  Created by Milan Agarwal on 18/10/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411SpammedUserCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411SpammedUserCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
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
    self.imgVuAvatar.layer.cornerRadius = self.imgVuAvatar.bounds.size.width / 2;
    self.imgVuAvatar.layer.masksToBounds = YES;
    
    ///configure unblock button
    self.btnUnSpam.layer.cornerRadius = 4.0;
    self.btnUnSpam.layer.masksToBounds = YES;
    [self applyColors];
}

-(void)applyColors
{
    self.lblFriendName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.btnUnSpam.backgroundColor = [C411ColorHelper sharedInstance].themeColor;
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnUnSpam setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
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
