//
//  C411AlertCell.m
//  cell411
//
//  Created by Milan Agarwal on 04/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411AlertCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411AlertCell


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
    ///make circular images
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    [C411StaticHelper makeCircularView:self.imgVuAlertType];
    [C411StaticHelper makeCircularView:self.btnChat];
    
    self.imgVuAlertType.layer.borderWidth = 2.0f;
    
    ///configure status button
    self.btnFlag.layer.cornerRadius = 3.0;

    self.vuAlertBase.layer.cornerRadius = 3.0;
    self.vuAlertBase.layer.shadowOffset = CGSizeMake(0, 1);
    self.vuAlertBase.layer.shadowOpacity = 0.8;
    self.vuAlertBase.layer.masksToBounds = NO;
    
    [self applyColors];
}

-(void)applyColors
{
    ///Set light card color
    self.vuAlertBase.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    
    ///Set Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.txtVuAlertTitle.textColor = primaryTextColor;
    
    self.lblAlertTimestamp.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.imgVuClock.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
#if CHAT_ENABLED
    ///set dark secondary color
    UIColor *darkSecondaryColor = [C411ColorHelper sharedInstance].darkSecondaryColor;
    self.btnChat.backgroundColor = darkSecondaryColor;
    self.btnChat.tintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
#endif
    self.imgVuAlertType.layer.borderColor = [UIColor whiteColor].CGColor;
    self.vuAlertBase.layer.shadowColor = [C411ColorHelper sharedInstance].fabShadowColor.CGColor;
    
    NSDictionary *dictLinkTextAttr = @{NSForegroundColorAttributeName:primaryTextColor};
    self.txtVuAlertTitle.linkTextAttributes = dictLinkTextAttr;

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
#pragma mark - Property Initializers
//****************************************************

-(void)setStrAlertType:(NSString *)strAlertType
{
    if (![_strAlertType isEqualToString:strAlertType]) {
        
        _strAlertType = strAlertType;
        self.imgVuAlertType.image = [C411StaticHelper getAlertTypeSmallImageForAlertType:strAlertType];
        
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
