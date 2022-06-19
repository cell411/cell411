//
//  C411ImportedContactCell.m
//  cell411
//
//  Created by Milan Agarwal on 08/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411ImportedContactCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411ImportedContactCell

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
    ///set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblContactName.textColor = primaryTextColor;
    
    ///set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblContactEmail.textColor = secondaryTextColor;
    
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
