//
//  C411NAUMemberCell.m
//  cell411
//
//  Created by Milan Agarwal on 12/09/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411NAUMemberCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411NAUMemberCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self applyColors];
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
-(void)applyColors
{
    ///set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblContactName.textColor = primaryTextColor;
    self.lblContactEmailOrPhone.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.btnRemove.tintColor = [C411ColorHelper sharedInstance].themeColor;
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
