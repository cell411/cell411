//
//  C411FriendCell.m
//  cell411
//
//  Created by Milan Agarwal on 16/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411FriendCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411FriendCell

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
    [self applyColors];
}

-(void)applyColors
 {
     ///set primary text color
     UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
     self.lblFriendName.textColor = primaryTextColor;
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
