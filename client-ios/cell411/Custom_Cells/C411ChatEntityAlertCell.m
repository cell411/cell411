//
//  C411ChatEntityAlertCell.m
//  cell411
//
//  Created by Milan Agarwal on 07/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ChatEntityAlertCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411ChatEntityAlertCell

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
    ///make circular images
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    [C411StaticHelper makeCircularView:self.imgVuAlertType];
    self.imgVuAlertType.layer.borderWidth = 2.0f;
    [self applyColors];
}

-(void)applyColors
{
    self.lblAlertTitle.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTimestamp.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.imgVuClock.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
    self.imgVuAlertType.layer.borderColor = [UIColor whiteColor].CGColor;
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
#pragma mark - Property Initializers
//****************************************************

-(void)setStrAlertType:(NSString *)strAlertType
{
    if (![_strAlertType isEqualToString:strAlertType]) {
        
        _strAlertType = strAlertType;
        self.imgVuAlertType.image = [C411StaticHelper getAlertTypeSmallImageForAlertType:strAlertType];
        
    }
    
}

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
