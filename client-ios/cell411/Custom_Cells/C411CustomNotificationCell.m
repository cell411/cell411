//
//  C411CustomNotificationCell.m
//  cell411
//
//  Created by Milan Agarwal on 28/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411CustomNotificationCell.h"
#import "C411StaticHelper.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411CustomNotificationCell

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
#pragma mark - Public Methods
//****************************************************

-(void)setDataUsingObject:(PFObject *)customAlert
{
    ///set title
    self.lblNotificationTitle.text = customAlert[kCell411AlertAdditionalNoteKey];

    ///set timestamp
    NSDate *notifDate = customAlert.createdAt;
    self.lblTimestamp.text = [C411StaticHelper getFormattedTimeFromDate:notifDate withFormat:TimeStampFormatDateAndTime];
    
    
}

//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)applyColors
{
    self.lblNotificationTitle.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblTimestamp.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.imgVuClock.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
    //self.vuSeparator.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;
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
