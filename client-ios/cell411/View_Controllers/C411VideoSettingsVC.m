//
//  C411VideoSettingsVC.m
//  cell411
//
//  Created by Milan Agarwal on 27/07/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411VideoSettingsVC.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "UIButton+FAB.h"
#import "C411AppDefaults.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "MAAlertPresenter.h"
#import "C411ColorHelper.h"

@interface C411VideoSettingsVC ()<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuFBLiveVideoOptionsContainer;
//@property (weak, nonatomic) IBOutlet UIButton *tglBtnStreamVideoToFBWall;
@property (weak, nonatomic) IBOutlet UILabel *lblStreamVideoToFBPageTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblStreamVideoToFBPageDescription;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnStreamVideoToFBPage;


@property (weak, nonatomic) IBOutlet UIView *vuYTLiveVideoOptionsContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblStreamVideoToYouTubeChannelTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblStreamVideoToUserYTChannelDescription;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnStreamVideoToUserLiveYTChannel;
@property (weak, nonatomic) IBOutlet UILabel *lblYTChannelServerURL;
@property (weak, nonatomic) IBOutlet UITextField *txtUserYTChannelServerUrl;
@property (weak, nonatomic) IBOutlet UILabel *lblYTChannelStreamName;
@property (weak, nonatomic) IBOutlet UITextField *txtUserYTChannelStreamName;
@property (weak, nonatomic) IBOutlet UIView *vuStreamVideoToCell411TVChannelSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblStreamVideoToCell411TVChannelDescription;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnStreamVideoToCell411YTChannel;
@property (weak, nonatomic) IBOutlet UIButton *btnReadMore;

@property (weak, nonatomic) IBOutlet UIView *vuGeneralVideoSettingsContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblGeneralVideoSettingsTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblVideoSize;
@property (weak, nonatomic) IBOutlet UITextField *txtVideoSize;
@property (weak, nonatomic) IBOutlet UIButton *btnVideoSize;
@property (weak, nonatomic) IBOutlet UIView *vuSaveVideoLocallySeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblSaveVideoLocallyTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSaveVideoLocallyDescription;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnSaveVideoLocally;
@property (strong, nonatomic) IBOutlet UIView *vuVideoSizePckrBase;
@property (weak, nonatomic) IBOutlet UIPickerView *pckrVideoSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsScrlVuBS;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;

- (IBAction)btnStreamVideoToFBPageToggled:(UIButton *)sender;
- (IBAction)btnStreamVideoToUserLiveYTChannelToggled:(UIButton *)sender;
- (IBAction)btnStreamVideoToCell411YTChannelToggled:(UIButton *)sender;
- (IBAction)btnSaveVideoLocallyToggled:(UIButton *)sender;
- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender;
- (IBAction)btnReadMoreTapped:(UIButton *)sender;
- (IBAction)barBtnSelectVideoSizeTapped:(UIBarButtonItem *)sender;
///Property for scroll management
@property (nonatomic, assign) float kbHeight;
@property (nonatomic, assign) CGFloat scrlVuInitialBLConstarintValue;

@end

@implementation C411VideoSettingsVC

#if VIDEO_STREAMING_ENABLED
///Include this class implementation in binary only if video streaming is enabled

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self setupViews];
    [self initializeSettings];
    [self registerForNotifications];
    
    ///set initial bottom constraint of scrollview
    self.scrlVuInitialBLConstarintValue = self.cnsScrlVuBS.constant;

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

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)configureViews
{
    self.title = NSLocalizedString(@"Video Settings", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    ///set corner radius to each container views
    self.vuFBLiveVideoOptionsContainer.layer.cornerRadius = 4.0;
    self.vuFBLiveVideoOptionsContainer.layer.masksToBounds = YES;
    
    self.vuYTLiveVideoOptionsContainer.layer.cornerRadius = 4.0;
    self.vuYTLiveVideoOptionsContainer.layer.masksToBounds = YES;
    
    
    self.vuGeneralVideoSettingsContainer.layer.cornerRadius = 4.0;
    self.vuGeneralVideoSettingsContainer.layer.masksToBounds = YES;
    
    ///Make toggle buttons as FAB buttons
    //[self.tglBtnStreamVideoToFBWall makeFloatingActionButton];
    [self.tglBtnStreamVideoToFBPage makeFloatingActionButton];
    [self.tglBtnStreamVideoToUserLiveYTChannel makeFloatingActionButton];
    [self.tglBtnStreamVideoToFBPage makeFloatingActionButton];
    [self.tglBtnStreamVideoToCell411YTChannel makeFloatingActionButton];
    [self.tglBtnSaveVideoLocally makeFloatingActionButton];
    
    ///Set dynamic app name
    self.lblStreamVideoToFBPageDescription.text = [NSString localizedStringWithFormat:NSLocalizedString(@"This will enable streaming live videos to %@ TV Facebook Page.",nil),LOCALIZED_APP_NAME];
    
    ///Set dynamic app name
    self.lblStreamVideoToCell411TVChannelDescription.text = [NSString localizedStringWithFormat:NSLocalizedString(@"This will enable streaming live videos to %@ TV Channel.",nil),LOCALIZED_APP_NAME];
    
    [self applyColors];
}

-(void)applyColors {
    ///Set Background Color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set background color on option containers
    UIColor *containerBGColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuFBLiveVideoOptionsContainer.backgroundColor = containerBGColor;
    self.vuYTLiveVideoOptionsContainer.backgroundColor = containerBGColor;
    self.vuGeneralVideoSettingsContainer.backgroundColor = containerBGColor;
    
    ///Set separator color
    self.vuStreamVideoToCell411TVChannelSeparator.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuSaveVideoLocallySeparator.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;

    ///Set container title colors
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblStreamVideoToFBPageTitle.textColor = primaryTextColor;
    self.lblStreamVideoToYouTubeChannelTitle.textColor = primaryTextColor;
    self.lblGeneralVideoSettingsTitle.textColor = primaryTextColor;
    self.lblYTChannelServerURL.textColor = primaryTextColor;
    self.lblYTChannelStreamName.textColor = primaryTextColor;
    self.lblVideoSize.textColor = primaryTextColor;
    self.lblSaveVideoLocallyTitle.textColor = primaryTextColor;
    self.txtUserYTChannelServerUrl.textColor = primaryTextColor;
    self.txtUserYTChannelStreamName.textColor = primaryTextColor;
    self.txtVideoSize.textColor = primaryTextColor;
    
    ///Set disabled text color for placeholer text
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtUserYTChannelServerUrl];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtUserYTChannelStreamName];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtVideoSize];
    
    ///Set container subtitle colors
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblStreamVideoToFBPageDescription.textColor = secondaryTextColor;
    self.lblStreamVideoToUserYTChannelDescription.textColor = secondaryTextColor;
    self.lblStreamVideoToCell411TVChannelDescription.textColor = secondaryTextColor;
    self.lblSaveVideoLocallyDescription.textColor = secondaryTextColor;
    
    ///Set hint icon color on dropdown
    self.btnVideoSize.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
    
    ///Set shadow color on fab buttons
    UIColor *fabShadowColor = [C411ColorHelper sharedInstance].fabShadowColor;
    self.tglBtnStreamVideoToFBPage.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnStreamVideoToCell411YTChannel.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnStreamVideoToUserLiveYTChannel.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnSaveVideoLocally.layer.shadowColor = fabShadowColor.CGColor;
    
    ///Set card color
    UIColor *cardColor = [C411ColorHelper sharedInstance].cardColor;
    self.txtUserYTChannelServerUrl.backgroundColor = cardColor;
    self.txtUserYTChannelStreamName.backgroundColor = cardColor;
    
}


-(void)setupViews
{
    ///Make picker view as input view for category selection
    self.txtVideoSize.inputView = self.vuVideoSizePckrBase;
    
    self.pckrVideoSize.dataSource = self;
    self.pckrVideoSize.delegate = self;
    
}


-(void)initializeSettings
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
//    ///Set stream video to FB Wall Option
//    [self toggleButton:self.tglBtnStreamVideoToFBWall toSelected:[defaults boolForKey:kStreamVideoOnFBWall]];

    ///Set stream video to FB Videos Page option
    [self toggleButton:self.tglBtnStreamVideoToFBPage toSelected:[defaults boolForKey:kStreamVideoOnFBPage]];
    
    ///Set stream video to User's Live YouTube Channel Option
    BOOL shouldStreamVideoToUserYTChannel = [defaults boolForKey:kStreamVideoOnUserYTChannel];
    [self toggleButton:self.tglBtnStreamVideoToUserLiveYTChannel toSelected:shouldStreamVideoToUserYTChannel];
    [self toggleEnablingUserLiveYTChannelInputFields:shouldStreamVideoToUserYTChannel];
    NSString *strStreamName = [defaults objectForKey:kUserLiveYTChannelStreamName];
    self.txtUserYTChannelStreamName.text = strStreamName;
    
    NSString *strServerUrl = [defaults objectForKey:kUserLiveYTChannelServerUrl];
    self.txtUserYTChannelServerUrl.text = strServerUrl;
    
    ///Set stream video to Cell 411 YouTube Channel option
    [self toggleButton:self.tglBtnStreamVideoToCell411YTChannel toSelected:[defaults boolForKey:kStreamVideoOnCell411YTChannel]];

    ///Set video resolution
    NSString *strVideoResolution = [defaults objectForKey:kVideoStreamingResolution];
    self.txtVideoSize.text = strVideoResolution;
    ///select it to the picker as well
    NSInteger selectedVideoResolutionIndex = [[C411AppDefaults getSupportedVideoResolutions]indexOfObject:strVideoResolution];
    if (selectedVideoResolutionIndex != NSNotFound) {
        
        [self.pckrVideoSize selectRow:selectedVideoResolutionIndex inComponent:0 animated:NO];

    }
    
    ///Set save video locally option
    [self toggleButton:self.tglBtnSaveVideoLocally toSelected:[defaults boolForKey:kRecordVideoLocally]];
    
    
}

/*
-(void)togglePublishVideoStreamToUserFBWallOption:(BOOL)shouldEnable
{
    [self toggleButton:self.tglBtnStreamVideoToFBWall toSelected:shouldEnable];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:shouldEnable forKey:kStreamVideoOnFBWall];
    [defaults synchronize];
    
}
*/

-(void)toggleStreamVideoToFacebookPageOptionWithValue:(BOOL)isEnabled
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isEnabled forKey:kStreamVideoOnFBPage];
    [defaults synchronize];
    
}

-(void)toggleButton:(UIButton *)button toSelected:(BOOL)shouldSelect
{
    button.selected = shouldSelect;
    if (shouldSelect) {
        button.backgroundColor = [C411ColorHelper sharedInstance].fabSelectedColor;
        button.tintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
    }
    else{
        ///make deselcted color
        button.backgroundColor = [C411ColorHelper sharedInstance].fabDeselectedColor;
        button.tintColor = [C411ColorHelper sharedInstance].fabDeselectedTintColor;
    }
    
}

-(void)toggleEnablingUserLiveYTChannelInputFields:(BOOL)shouldEnable
{
    ///Disable/enable textfields for server url and stream name
    self.txtUserYTChannelServerUrl.enabled = shouldEnable;
    self.txtUserYTChannelStreamName.enabled = shouldEnable;

}


//****************************************************
#pragma mark - UIPickerViewDataSource Methods
//****************************************************

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [C411AppDefaults getSupportedVideoResolutions].count;
}


//****************************************************
#pragma mark - UIPickerViewDelegate Methods
//****************************************************

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        
        return [C411AppDefaults getSupportedVideoResolutions][row];
        
    }
    
    return nil;
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender {
    ///Save stream name and server url for user's live Youtube Channel
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strStreamName = self.txtUserYTChannelStreamName.text;
    strStreamName = strStreamName ? strStreamName : @"";
    [defaults setObject:strStreamName forKey:kUserLiveYTChannelStreamName];

    NSString *strServerUrl = self.txtUserYTChannelServerUrl.text;
    strServerUrl = strServerUrl ? strServerUrl : @"";
    [defaults setObject:strServerUrl forKey:kUserLiveYTChannelServerUrl];
    
    if ([defaults boolForKey:kStreamVideoOnUserYTChannel]) {
        ///Show alert if Streaming to user's Live Youtube Channel is enabled and proper information is not provided
        ///extract rtmp:// if exist as a suffix
        NSString *strInvalidSuffix = @"rtmp://";
        if ([strServerUrl hasSuffix:strInvalidSuffix]) {
            strServerUrl = [strServerUrl substringFromIndex:strInvalidSuffix.length];
        }
        
        if ((strServerUrl.length == 0) || !([strServerUrl containsString:@"/"])) {
            ///Improper Server Url
            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Please provide a valid Server Url if you want to stream to your own live YouTube Channel. It should be like %@",nil),kUserLiveYTChannelDefaultServerUrl];
            [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:self];
        }
        else if (strStreamName.length == 0){
            ///Stream name is left blank
            NSString *strMessage = NSLocalizedString(@"Please provide a valid Stream name/key if you want to stream to your own live YouTube Channel.", nil);
            [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:self];
            
        }
        else{
            
            ///Everything is fine Go Back
            [self.navigationController popViewControllerAnimated:YES];

        }

    }
    else{
        ///Go Back
        [self.navigationController popViewControllerAnimated:YES];

    }

    
}

- (IBAction)btnReadMoreTapped:(UIButton *)sender {
    
    ///Show Read more popup tp describe how user can stream to his/her own YouTube Live Channel
    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"To stream to your own YouTube Live Channel via %@ you need to retrieve your YouTube stream key and URL from your YouTube Live settings and enter them below. For further help, please read the FAQ and follow the tutorial at %@",nil),LOCALIZED_APP_NAME, FAQ_AND_TUTORIAL_URL ];
    
    ///show alert
    UIAlertController *infoAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///User taps cancel, do nothing
       
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    UIAlertAction *openFaqAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"FAQ", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///user tapped on FAQ, take user to the FAQ section of website
        NSURL *FAQUrl = [NSURL URLWithString:FAQ_AND_TUTORIAL_URL];
        
        if (FAQUrl && [[UIApplication sharedApplication]canOpenURL:FAQUrl]) {
            
            [[UIApplication sharedApplication]openURL:FAQUrl];
            
        }

        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

        
    }];
    
    [infoAlert addAction:cancelAction];
    [infoAlert addAction:openFaqAction];
    //[self presentViewController:infoAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:infoAlert];

}

- (IBAction)barBtnSelectVideoSizeTapped:(UIBarButtonItem *)sender {
    
    NSInteger selectedRow = [self.pckrVideoSize selectedRowInComponent:0];
    NSString *strSelectedVideoResolution = [C411AppDefaults getSupportedVideoResolutions][selectedRow];
    self.txtVideoSize.text = strSelectedVideoResolution;
    
    [self.txtVideoSize resignFirstResponder];

    ///Save this resolution is user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strSelectedVideoResolution forKey:kVideoStreamingResolution];
    [defaults synchronize];
    
}

- (IBAction)btnStreamVideoToFBPageToggled:(UIButton *)sender {
    
    BOOL isOn = !sender.isSelected;
    [self toggleButton:sender toSelected:isOn];
    
    if (isOn) {
        
        ///User is trying to turn on the Stream Video to Facebook Page option, show the confirmation popup
        NSString *strMessage = NSLocalizedString(@"This will allow your live video streams to be shared to the general public on Facebook. Should you share obscene or sensitive footage, your account may be suspended or banned permanently. Do you want to continue?", nil);
        ///show alert
        UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            ///User taps cancel, so do not turn on Stream Video to Facebook Page option, set the switch value back to off again
            [self toggleButton:sender toSelected:NO];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            ///user tapped ok, that means user want to turn on Stream Video to Facebook Page option and he/she is giving their consent. Save it in defaults
            [self toggleStreamVideoToFacebookPageOptionWithValue:YES];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

            
        }];
        
        [confirmAlert addAction:cancelAction];
        [confirmAlert addAction:okAction];
        //[self presentViewController:confirmAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmAlert];

        
    }
    else{
        
        ///User is trying to turn off the Stream Video to Facebook Page option, turn it off
        [self toggleStreamVideoToFacebookPageOptionWithValue:NO];
        
        
        
    }
    
}

- (IBAction)btnStreamVideoToUserLiveYTChannelToggled:(UIButton *)sender {
    
    BOOL isOn = !sender.isSelected;
    [self toggleButton:sender toSelected:isOn];
    [self toggleEnablingUserLiveYTChannelInputFields:isOn];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:kStreamVideoOnUserYTChannel];
    [defaults synchronize];

}

- (IBAction)btnStreamVideoToCell411YTChannelToggled:(UIButton *)sender {

    BOOL isOn = !sender.isSelected;
    [self toggleButton:sender toSelected:isOn];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:kStreamVideoOnCell411YTChannel];
    [defaults synchronize];

}

- (IBAction)btnSaveVideoLocallyToggled:(UIButton *)sender {
    
    BOOL isOn = !sender.isSelected;
    [self toggleButton:sender toSelected:isOn];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:kRecordVideoLocally];
    [defaults synchronize];

}

//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtUserYTChannelServerUrl){
        
        [self.txtUserYTChannelStreamName becomeFirstResponder];
        return NO;
    }
    else{
        [textField resignFirstResponder];
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    float yOffset = self.vuYTLiveVideoOptionsContainer.frame.origin.y + 100;
    if (yOffset >= 0) {
        
        float underBarPadding = 0;
        [self.scrlVuBase setContentOffset:CGPointMake(self.scrlVuBase.contentOffset.x,yOffset - underBarPadding) animated:YES];
        
    }
    
    
}

//****************************************************
#pragma mark - Notifications
//****************************************************

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize _kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.kbHeight = _kbSize.width > _kbSize.height ? _kbSize.height : _kbSize.width;
    //      _scrlVu_Base.contentSize = CGSizeMake(_scrlVu_Base.bounds.size.width, _scrlVu_Base.bounds.size.height + kbHeight);
    self.cnsScrlVuBS.constant = self.kbHeight + self.scrlVuInitialBLConstarintValue;
    
}

-(void)keyboardWillHide:(NSNotification *)note
{
    self.cnsScrlVuBS.constant = self.scrlVuInitialBLConstarintValue;
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

#endif

@end
