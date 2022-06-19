//
//  C411AlertAudienceCell.m
//  cell411
//
//  Created by Milan Agarwal on 30/03/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411AlertAudienceCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@interface C411AlertAudienceCell ()

@property (nonatomic, assign) CGFloat counterInitialWidthConstraint;

@end

@implementation C411AlertAudienceCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.counterInitialWidthConstraint = self.cnsCounterWidth.constant;
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

-(void)setAudienceDisabled:(BOOL)audienceDisabled
{
    //self.vuDisabledOverlay.hidden = !audienceDisabled;
    if(audienceDisabled){
        ///Using alpha for button because with enabled property it's picking the image for default state
        self.tglBtnAudienceSelection.alpha = 0.6;
        self.lblAudienceType.enabled = NO;
    }
    else{
        self.tglBtnAudienceSelection.alpha = 1.0;
        self.lblAudienceType.enabled = YES;
    }
    self.userInteractionEnabled = !audienceDisabled;
    _audienceDisabled = audienceDisabled;
}

//****************************************************
#pragma mark - Public Methods
//****************************************************

-(void)hideCounter:(BOOL)hide
{
    if(hide){
    
        self.lblCounter.hidden = YES;
        self.cnsCounterWidth.constant = 0;
        self.cnsCounterTrailing.constant = 8;
        
    }
    else{
        
        self.cnsCounterTrailing.constant = 0;
        self.cnsCounterWidth.constant = self.counterInitialWidthConstraint;
        self.lblCounter.hidden = NO;
    }
}

//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)applyColors
{
    ///set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.tglBtnAudienceSelection.tintColor = primaryTextColor;
    self.lblAudienceType.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblCounter.textColor = secondaryTextColor;
    
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
