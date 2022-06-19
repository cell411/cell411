//
//  C411GiveRideReviewCell.m
//  cell411
//
//  Created by Milan Agarwal on 04/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411GiveRideReviewCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411GiveRideReviewCell

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
    [self applyColors];
}

-(void)applyColors
{
    self.vuContainer.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.lblName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
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
