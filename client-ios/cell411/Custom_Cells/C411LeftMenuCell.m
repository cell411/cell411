//
//  C411LeftMenuCell.m
//  cell411
//
//  Created by Milan Agarwal on 23/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411LeftMenuCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"
@interface C411LeftMenuCell()
@property (nonatomic, assign) CGFloat redirectIconInitialWidth;
@property (nonatomic, assign) CGFloat redirectIconInitialTS;

@end

@implementation C411LeftMenuCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.redirectIconInitialWidth = self.cnsRedirectIconWidth.constant;
    self.redirectIconInitialTS = self.cnsRedirectIconTS.constant;
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
#pragma mark - Property Initializers
//****************************************************
-(void)setWillRedirectOutsideApp:(BOOL)willRedirectOutsideApp {
    _willRedirectOutsideApp = willRedirectOutsideApp;
    if(willRedirectOutsideApp) {
        self.cnsRedirectIconWidth.constant = self.redirectIconInitialWidth;
        self.cnsRedirectIconTS.constant = self.redirectIconInitialTS;
        self.imgVuRedirectIcon.hidden = NO;
    }
    else{
        self.imgVuRedirectIcon.hidden = YES;
        self.cnsRedirectIconWidth.constant = 0;
        self.cnsRedirectIconTS.constant = 0;
    }
}

//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)applyColors
{
    if(![self.lblMenuTitle.text.lowercaseString isEqualToString:@"logout"]) {
        self.lblMenuTitle.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
        
        self.imgVuMenuIcon.tintColor = [C411ColorHelper sharedInstance].darkHintIconColor;
    }
    
    self.vuSeparator.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;
    self.imgVuRedirectIcon.tintColor = [C411ColorHelper sharedInstance].themeColor;
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
