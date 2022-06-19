//
//  C411ContactSelectionCell.m
//  cell411
//
//  Created by Milan Agarwal on 31/08/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ContactSelectionCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411ContactSelectionCell

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
//    self.imgVuAvatar.layer.cornerRadius = self.imgVuAvatar.bounds.size.width / 2;
//    self.imgVuAvatar.layer.masksToBounds = YES;
    
    ///Disable user interaction of checkbox so touch event could be
    ///passed to tableview:didSelectRowAtIndexpath
    self.btnCheckbox.userInteractionEnabled = NO;
    [self applyColors];
}

-(void)applyColors
{
    self.lblContactName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblContactEmailOrPhone.textColor = secondaryTextColor;
    self.btnCheckbox.fillColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnCheckbox.borderColor = secondaryTextColor;
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
