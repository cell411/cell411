//
//  C411OtherPublicCell.m
//  cell411
//
//  Created by Milan Agarwal on 27/01/16.
//  Copyright (c) 2016 Milan Agarwal. All rights reserved.
//

#import "C411OtherPublicCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "C411ColorHelper.h"

@implementation C411OtherPublicCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
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
    ///make circular images
    [C411StaticHelper makeCircularView:self.imgVuCell];
    [C411StaticHelper makeCircularView:self.imgVuVerified];
    [C411StaticHelper makeCircularView:self.btnChat];
    ///configure status button
    self.btnJoinStatus.layer.cornerRadius = 3.0;
    [self applyColors];
}

-(void)applyColors
{
    ///set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblCellName.textColor = primaryTextColor;
#if CHAT_ENABLED
    ///set dark secondary color
    UIColor *darkSecondaryColor = [C411ColorHelper sharedInstance].darkSecondaryColor;
    self.btnChat.backgroundColor = darkSecondaryColor;
    self.btnChat.tintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
#endif
    self.imgVuVerified.layer.borderColor = [UIColor whiteColor].CGColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)setStrStatus:(NSString *)strStatus
{
    if (![_strStatus isEqualToString:strStatus]) {
       
        _strStatus = strStatus;
        if ([strStatus isEqualToString:NSLocalizedString(@"JOIN", nil)]){
            
            ///configure the button for Join state
            UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
            self.btnJoinStatus.backgroundColor = themeColor;
            UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
            [self.btnJoinStatus setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
            self.btnJoinStatus.layer.borderColor = [UIColor clearColor].CGColor;
            self.btnJoinStatus.layer.borderWidth = 0;
            
            self.btnJoinStatus.enabled = YES;
#if CHAT_ENABLED

            self.btnChat.hidden = YES;
#endif
            
        }
        else if ([strStatus isEqualToString:NSLocalizedString(@"LEAVE", nil)]) {
            
            ///configure the button for leave state
            self.btnJoinStatus.backgroundColor = [UIColor clearColor];
            UIColor *pinkColor = [C411StaticHelper colorFromHexString:@"FF5A6A"];
            [self.btnJoinStatus setTitleColor:pinkColor forState:UIControlStateNormal];
            self.btnJoinStatus.layer.borderColor = pinkColor.CGColor;
            self.btnJoinStatus.layer.borderWidth = 1.0;
            self.btnJoinStatus.enabled = YES;

#if CHAT_ENABLED

            self.btnChat.hidden = NO;
#endif

        }
        else if([strStatus isEqualToString:NSLocalizedString(@"PENDING", nil)]){
            
            ///configure the button for Join state
            UIColor *greyColor = [C411StaticHelper colorFromHexString:@"888888"];
            self.btnJoinStatus.backgroundColor = greyColor;
            [self.btnJoinStatus setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.btnJoinStatus.layer.borderColor = [UIColor clearColor].CGColor;
            self.btnJoinStatus.layer.borderWidth = 0;
            self.btnJoinStatus.enabled = NO;
#if CHAT_ENABLED

            self.btnChat.hidden = YES;
#endif
        }

        
    }
}

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
