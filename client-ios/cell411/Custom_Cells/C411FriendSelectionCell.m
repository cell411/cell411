//
//  C411FriendSelectionCell.m
//  cell411
//
//  Created by Milan Agarwal on 03/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411FriendSelectionCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411FriendSelectionCell


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
    self.imgVuAvatar.layer.cornerRadius = self.imgVuAvatar.bounds.size.width / 2;
    self.imgVuAvatar.layer.masksToBounds = YES;
    
    ///Disable user interaction of checkbox so touch event could be
    ///passed to tableview:didSelectRowAtIndexpath
    self.btnCheckbox.userInteractionEnabled = NO;
    [self applyColors];
}

-(void)applyColors
{
    self.lblFriendName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.btnCheckbox.fillColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnCheckbox.borderColor = [C411ColorHelper sharedInstance].secondaryTextColor;
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
