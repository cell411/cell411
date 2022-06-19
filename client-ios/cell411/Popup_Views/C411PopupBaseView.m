//
//  C411PopupBaseView.m
//  cell411
//
//  Created by Milan Agarwal on 16/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PopupBaseView.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation C411PopupBaseView

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)registerForNotifications
{
    ///observe the open and close notification of photo
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didOpenedViewPhotoVC:) name:kDidOpenedPhotoVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClosedViewPhotoVC:) name:kDidClosedPhotoVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didOpenedRideSettingsVC:) name:kDidOpenedRideSettingsVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClosedRideSettingsVC:) name:kDidClosedRideSettingsVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didOpenedRideReviewsVC:) name:kDidOpenedRideReviewsVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClosedRideReviewsVC:) name:kDidClosedRideReviewsVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didOpenedChatVC:) name:kDidOpenedChatVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClosedChatVC:) name:kDidClosedChatVCNotification object:nil];

}

-(void)unregisterFromNotifications
{
    ///remove the observer for photo notification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidOpenedPhotoVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidClosedPhotoVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidOpenedRideSettingsVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidClosedRideSettingsVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidOpenedChatVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidClosedChatVCNotification object:nil];

}

-(void)goBack
{
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [navRoot.view sendSubviewToBack:self];

}

-(void)moveToFront
{
    ///bring current view to front
    [[AppDelegate sharedInstance].window.rootViewController.view bringSubviewToFront:self];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)didOpenedViewPhotoVC:(NSNotification *)notif
{
    [self goBack];
}

-(void)didClosedViewPhotoVC:(NSNotification *)notif
{
    
    [self moveToFront];
}

-(void)didOpenedRideSettingsVC:(NSNotification *)notif
{
    [self goBack];
}

-(void)didClosedRideSettingsVC:(NSNotification *)notif
{
    
    [self moveToFront];
}

-(void)didOpenedRideReviewsVC:(NSNotification *)notif
{
    [self goBack];
}

-(void)didClosedRideReviewsVC:(NSNotification *)notif
{
    
    [self moveToFront];
}

-(void)didOpenedChatVC:(NSNotification *)notif
{
    [self goBack];
}

-(void)didClosedChatVC:(NSNotification *)notif
{
    
    [self moveToFront];
}

@end
