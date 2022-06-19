//
//  C411MyPublicCell.m
//  cell411
//
//  Created by Milan Agarwal on 27/01/16.
//  Copyright (c) 2016 Milan Agarwal. All rights reserved.
//

#import "C411MyPublicCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411MyPublicCell

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
    [C411StaticHelper makeCircularView:self.imgVuCell];
    [C411StaticHelper makeCircularView:self.imgVuVerified];
    [C411StaticHelper makeCircularView:self.btnChat];
    
    [self applyColors];
}

-(void)applyColors
{
    ///set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblCellName.textColor = primaryTextColor;
    
#if CHAT_ENABLED
    ///set dark secondary color
    UIColor *darkSecondaryColor = [C411ColorHelper sharedInstance].darkSecondaryColor;
    self.btnChat.backgroundColor = darkSecondaryColor;
    self.btnChat.tintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
#endif

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
