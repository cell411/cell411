//
//  C411WelcomeGalleryCell.m
//  cell411
//
//  Created by Milan Agarwal on 18/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411WelcomeGalleryCell.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@implementation C411WelcomeGalleryCell
//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
-(void)awakeFromNib {
    [super awakeFromNib];
    [self applyColors];
    [self registerForNotifications];
}

-(void)dealloc {
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)applyColors {
    
    ///Set text color on label
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblTitle.textColor = primaryBGTextColor;
    self.lblSubtitle.textColor = primaryBGTextColor;
}

-(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
