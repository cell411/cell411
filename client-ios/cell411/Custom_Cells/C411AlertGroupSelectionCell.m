//
//  C411AlertGroupSelectionCell.m
//  cell411
//
//  Created by Milan Agarwal on 22/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411AlertGroupSelectionCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411AlertGroupSelectionCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)awakeFromNib {
    
    [super awakeFromNib];

    // Initialization code
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
    self.lblAlertRecievingGroupName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.radioBtnCellSelectionIndicator.tintColor = [C411ColorHelper sharedInstance].secondaryColor;
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
