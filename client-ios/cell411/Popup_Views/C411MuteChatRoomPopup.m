//
//  C411MuteChatRoomPopup.m
//  cell411
//
//  Created by Milan Agarwal on 09/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411MuteChatRoomPopup.h"
#import "ToggleImageView.h"
#import "C411Enums.h"
#import "C411ChatManager.h"
#import "C411ChatHelper.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411MuteChatRoomPopup ()

@property (weak, nonatomic) IBOutlet UIView *vuMuteChatRoomPopup;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnShowNotifications;
@property (weak, nonatomic) IBOutlet ToggleImageView *imgVuRadio1Hour;
@property (weak, nonatomic) IBOutlet UILabel *lbl1Hour;
@property (weak, nonatomic) IBOutlet ToggleImageView *imgVuRadio6Hours;
@property (weak, nonatomic) IBOutlet UILabel *lbl6Hours;
@property (weak, nonatomic) IBOutlet ToggleImageView *imgVuRadio24Hours;
@property (weak, nonatomic) IBOutlet UILabel *lbl24Hours;
@property (weak, nonatomic) IBOutlet ToggleImageView *imgVuRadio1Month;
@property (weak, nonatomic) IBOutlet UILabel *lbl1Month;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

- (IBAction)btnShowNotificationsToggled:(id)sender;
- (IBAction)btnOkTapped:(UIButton *)sender;
- (IBAction)btnCancelTapped:(UIButton *)sender;
- (IBAction)btnRadio1HourToggled:(UIButton *)sender;
- (IBAction)btnRadio6HoursToggled:(UIButton *)sender;
- (IBAction)btnRadio24HoursToggled:(UIButton *)sender;
- (IBAction)btnRadio1MonthToggled:(UIButton *)sender;

@end

@implementation C411MuteChatRoomPopup

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

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureViews];
    [self initializeViews];
    [C411StaticHelper removeOnScreenKeyboard];
    [self registerForNotifications];
}

-(void)dealloc {
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///Set corner radius
    self.vuMuteChatRoomPopup.layer.cornerRadius = 5.0;
    self.vuMuteChatRoomPopup.layer.masksToBounds = YES;
    
    ///Set initial strings for localization support
    self.lblTitle.text = NSLocalizedString(@"Mute for...", nil);
    self.lbl1Hour.text = NSLocalizedString(@"1 Hour", nil);
    self.lbl6Hours.text = NSLocalizedString(@"6 Hours", nil);
    self.lbl24Hours.text = NSLocalizedString(@"24 Hours", nil);
    self.lbl1Month.text = NSLocalizedString(@"1 Month", nil);
    
    [self.btnCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.btnOk setTitle:NSLocalizedString(@"Ok", nil) forState:UIControlStateNormal];
   
    [self applyColors];
}

-(void)applyColors {
    ///set background color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuMuteChatRoomPopup.backgroundColor = lightCardColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblTitle.textColor = primaryTextColor;
    self.lbl1Hour.textColor = primaryTextColor;
    self.lbl6Hours.textColor = primaryTextColor;
    self.lbl24Hours.textColor = primaryTextColor;
    self.lbl1Month.textColor = primaryTextColor;
    
    ///Set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnOk setTitleColor:secondaryColor forState:UIControlStateNormal];
    [self.btnCancel setTitleColor:secondaryColor forState:UIControlStateNormal];
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)initializeViews
{
    self.tglBtnShowNotifications.selected = YES;
    
    ///Enable 1 hour option by default
    self.imgVuRadio1Hour.selected = YES;
    ///Disable other radio options
    self.imgVuRadio6Hours.selected = NO;
    self.imgVuRadio24Hours.selected = NO;
    self.imgVuRadio1Month.selected = NO;

}

//****************************************************
#pragma mark - Action Methods
//****************************************************

-(IBAction)btnShowNotificationsToggled:(id)sender
{
    self.tglBtnShowNotifications.selected = !self.tglBtnShowNotifications.isSelected;
        
}

- (IBAction)btnOkTapped:(UIButton *)sender
{
    
    ///Mute the chatroom with given settings
    ChatMuteTimeType chatMuteTimeType = ChatMuteTimeTypeDefault;
    
    if (self.imgVuRadio1Hour.isSelected) {
        
        chatMuteTimeType = ChatMuteTimeType1Hour;
    }
    else if (self.imgVuRadio6Hours.isSelected) {
        
        chatMuteTimeType = ChatMuteTimeType6Hours;
    }
    else if (self.imgVuRadio24Hours.isSelected) {
        
        chatMuteTimeType = ChatMuteTimeType24Hours;
    }
    else if (self.imgVuRadio1Month.isSelected) {
        
        chatMuteTimeType = ChatMuteTimeType1Month;
    }
    
    [C411ChatHelper muteChatRoomWithEntityId:self.strEntityId forTime:chatMuteTimeType withNotificationEnabled:self.tglBtnShowNotifications.isSelected];
    
    [self removeFromSuperview];

}

- (IBAction)btnCancelTapped:(UIButton *)sender
{
    [self removeFromSuperview];
}

- (IBAction)btnRadio1HourToggled:(UIButton *)sender
{
    if (!self.imgVuRadio1Hour.isSelected) {
        
        ///Enable 1 hour
        self.imgVuRadio1Hour.selected = YES;
        
        ///Disable other radio options
        self.imgVuRadio6Hours.selected = NO;
        self.imgVuRadio24Hours.selected = NO;
        self.imgVuRadio1Month.selected = NO;
        
    }
}

- (IBAction)btnRadio6HoursToggled:(UIButton *)sender
{
    if (!self.imgVuRadio6Hours.isSelected) {
        
        ///Enable 6 hour
        self.imgVuRadio6Hours.selected = YES;
        
        ///Disable other radio options
        self.imgVuRadio1Hour.selected = NO;
        self.imgVuRadio24Hours.selected = NO;
        self.imgVuRadio1Month.selected = NO;
        
    }
}

- (IBAction)btnRadio24HoursToggled:(UIButton *)sender
{
    if (!self.imgVuRadio24Hours.isSelected) {
        
        ///Enable 24 hour
        self.imgVuRadio24Hours.selected = YES;
        
        ///Disable other radio options
        self.imgVuRadio6Hours.selected = NO;
        self.imgVuRadio1Hour.selected = NO;
        self.imgVuRadio1Month.selected = NO;
        
    }
}

- (IBAction)btnRadio1MonthToggled:(UIButton *)sender
{
    if (!self.imgVuRadio1Month.isSelected) {
        
        ///Enable 1 month
        self.imgVuRadio1Month.selected = YES;
        
        ///Disable other radio options
        self.imgVuRadio6Hours.selected = NO;
        self.imgVuRadio24Hours.selected = NO;
        self.imgVuRadio1Hour.selected = NO;
        
    }
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}
@end
