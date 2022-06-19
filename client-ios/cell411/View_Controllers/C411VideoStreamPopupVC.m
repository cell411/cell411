//
//  C411VideoStreamPopupVC.m
//  cell411
//
//  Created by Milan Agarwal on 07/09/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411VideoStreamPopupVC.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411VideoStreamPopupVC ()
@property (weak, nonatomic) IBOutlet UIView *vuContentContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblPopupTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)btnStreamVideoTapped:(UIButton *)sender;
- (IBAction)btnPublishToFBTapped:(UIButton *)sender;
- (IBAction)btnCancelTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsStreamVideoBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsStreamVideoBtnTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPublishToFBTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPublishToFBBtnHeight;

@end

@implementation C411VideoStreamPopupVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self unregisterFromNotifications];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews {
    self.lblPopupTitle.text = self.strPopupTitle;
    if(!self.canShowVideoStreamOption){
        [self hideVideoStreamingOption];
    }
    
    [self hidePublishToFBOption];
    
    [C411StaticHelper makeCircularView:self.btnClose];
    
    self.btnClose.layer.borderWidth = 1.0;
    
    [self applyColors];
}

-(void)hideVideoStreamingOption {
    self.cnsStreamVideoBtnTS.constant = 0;
    self.cnsStreamVideoBtnHeight.constant = 0;
}

-(void)hidePublishToFBOption {
    self.cnsPublishToFBTS.constant = 0;
    self.cnsPublishToFBBtnHeight.constant = 0;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}


-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)applyColors {
    ///set background color
    self.vuContentContainer.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblPopupTitle.textColor = primaryTextColor;
    
    ///Set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnCancel setTitleColor:secondaryColor forState:UIControlStateNormal];
    
    UIColor *crossButtonColor = [C411ColorHelper sharedInstance].popupCrossButtonColor;
    self.btnClose.backgroundColor = crossButtonColor;

    UIColor *blackColor = [UIColor blackColor];
    self.btnClose.layer.borderColor = blackColor.CGColor;

    ///Set color on publish to FB button
    self.btnPublishToFB.backgroundColor = [C411ColorHelper sharedInstance].themeColor;
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnPublishToFB setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
}

//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnStreamVideoTapped:(UIButton *)sender {
    ///notify the delegate that Stream Video button is tapped
    [self.delegate videoStreamPopupVCDidTappedStreamVideo:self];
}

- (IBAction)btnPublishToFBTapped:(UIButton *)sender {
    ///notify the delegate that Stream Video button is tapped
}

- (IBAction)btnCancelTapped:(UIButton *)sender {
    ///notify the delegate the cancel button is tapped
    [self.delegate videoStreamPopupVCDidTappedCancel:self];
}

- (IBAction)btnCloseTapped:(UIButton *)sender {
    ///notify the delegate the close button is tapped
    [self.delegate videoStreamPopupVCDidTappedCancel:self];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
