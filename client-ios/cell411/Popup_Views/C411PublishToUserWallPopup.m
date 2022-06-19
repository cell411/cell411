//
//  C411PublishToUserWallPopup.m
//  cell411
//
//  Created by Milan Agarwal on 03/08/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PublishToUserWallPopup.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"

@interface C411PublishToUserWallPopup ()

@property (weak, nonatomic) IBOutlet UIView *vuPublishToWallPopup;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPublishAlertToFBWall;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnPublishAlertToFBWall;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnStreamVideoToFBWall;
@property (weak, nonatomic) IBOutlet UIButton *btnLater;
@property (weak, nonatomic) IBOutlet UIButton *btnEnable;

-(IBAction)btnPublishAlertToFBWallToggled:(id)sender;
//-(IBAction)btnStreamVideoToFBWallToggled:(id)sender;
- (IBAction)btnEnableTapped:(UIButton *)sender;
- (IBAction)btnDoItLaterTapped:(UIButton *)sender;

@end
@implementation C411PublishToUserWallPopup

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
    [C411StaticHelper removeOnScreenKeyboard];
    [self registerForNotifications];
}

-(void)dealloc
{
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///Set corner radius
    self.vuPublishToWallPopup.layer.cornerRadius = 5.0;
    self.vuPublishToWallPopup.layer.masksToBounds = YES;
    [self applyColors];
}

-(void)applyColors {
    ///Set background color
    self.vuPublishToWallPopup.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.lblTitle.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    
    ///Set subtitle colors
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblPublishAlertToFBWall.textColor = secondaryTextColor;
    self.tglBtnPublishAlertToFBWall.tintColor = secondaryTextColor;

    ///Set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnLater setTitleColor:secondaryColor forState:UIControlStateNormal];
    [self.btnEnable setTitleColor:secondaryColor forState:UIControlStateNormal];
    
}

-(void)registerForNotifications {
    [super registerForNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

-(IBAction)btnPublishAlertToFBWallToggled:(id)sender
{
    self.tglBtnPublishAlertToFBWall.selected = !self.tglBtnPublishAlertToFBWall.isSelected;
    
    if (self.tglBtnPublishAlertToFBWall.isSelected) {
        
        ///Check box enabled for publishing alerts to FB Wall, enable the Enable button if it's not enabled
        if (!self.btnEnable.enabled) {
            self.btnEnable.enabled = YES;
        }
    }
    else if(!self.tglBtnStreamVideoToFBWall.isSelected){
        
        ///Disable the Enable button as both checkbox are deselected
        self.btnEnable.enabled = NO;
    
    }
    
}

/*
-(IBAction)btnStreamVideoToFBWallToggled:(id)sender
{
    self.tglBtnStreamVideoToFBWall.selected = !self.tglBtnStreamVideoToFBWall.isSelected;
    
    if (self.tglBtnStreamVideoToFBWall.isSelected) {
        
        ///Check box enabled for streaming video to FB Wall, enable the Enable button if it's not enabled
        if (!self.btnEnable.enabled) {
            self.btnEnable.enabled = YES;
        }
    }
    else if(!self.tglBtnPublishAlertToFBWall.isSelected){
        
        ///Disable the Enable button as both checkbox are deselected
        self.btnEnable.enabled = NO;
        
    }

}
*/

- (IBAction)btnEnableTapped:(UIButton *)sender {
    
    if (self.actionHandler != NULL) {
        ///call the Enable action handler and pass the userdefaults keys for the enabled options
        NSMutableArray *arrEnabledOptionsKeys = [NSMutableArray array];
        ///Add key for publish alert on FB wall if enabled
        if (self.tglBtnPublishAlertToFBWall.isSelected) {
            
            [arrEnabledOptionsKeys addObject:kPublishOnFB];
        }
        
        ///Add key for stream video on FB wall if enabled
        if (self.tglBtnStreamVideoToFBWall.isSelected) {
            
            [arrEnabledOptionsKeys addObject:kStreamVideoOnFBWall];
        }
        
        self.actionHandler(sender,1,arrEnabledOptionsKeys);
        
    }
    
    [self removeFromSuperview];
    self.actionHandler = NULL;

    
}

- (IBAction)btnDoItLaterTapped:(UIButton *)sender {
    
    if (self.actionHandler != NULL) {
        ///call the Close action handler
        self.actionHandler(sender,0,nil);
        
    }
    
    [self removeFromSuperview];
    self.actionHandler = NULL;

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
