//
//  C411SettingsVC.m
//  cell411
//
//  Created by Milan Agarwal on 27/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411SettingsVC.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "UIButton+FAB.h"
#import "C411SpammedUsersListVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "C411PublishToUserWallPopup.h"
#import "MAAlertPresenter.h"
#import "C411LocationManager.h"
#import "C411ColorHelper.h"
#import "C411AppDefaults.h"
#import "DateHelper.h"
#if IS_PANIC_BUTTON_ENABLED
#import "C411PanicAlertAdvancedSettingsVC.h"
#endif

#if VIDEO_STREAMING_ENABLED
#import "C411VideoSettingsVC.h"
#endif

#if FB_ENABLED
#import "PFFacebookUtils.h"
#endif

#if RIDE_HAILING_ENABLED
#import "C411RideSettingsVC.h"
#endif

#if IS_CONTACTS_SYNCING_ENABLED
#import "C411UploadContactsVC.h"
#endif


@import AVFoundation;

@interface C411SettingsVC ()

@property (weak, nonatomic) IBOutlet UIView *vuPanicButtonSettingsContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblPanicButtonSettingsTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPanicButtonSettingsSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *btnAdvancedPanicSettings;

@property (weak, nonatomic) IBOutlet UIView *vuNewPublicCellAlertContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblNewPublicCellAlertTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblNewPublicCellAlertDescription;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnNewPublicCellAlert;///tglBtn means toggle button

@property (weak, nonatomic) IBOutlet UIView *vuPatrolOptionContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblPatrolModeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPatrolModeRadiusTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPatrolModeDescription;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnPatrolMode;
@property (weak, nonatomic) IBOutlet UIView *vuPatrolRadiusSeparator;
@property (weak, nonatomic) IBOutlet UIView *vuCurrentPatrolRadiusContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblPatrolRadiusRange;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentPatrolRadius;
@property (weak, nonatomic) IBOutlet UISlider *sliderPatrolModeRadius;
@property (weak, nonatomic) IBOutlet UIView *vuMetricSelectionContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblMetricSelectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMetricSelectionDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgcMetricSystem;

@property (weak, nonatomic) IBOutlet UIView *vuConnectToFacebookContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblConnectToFacebookTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblConnectToFacebookSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *btnConnectToFacebook;
@property (weak, nonatomic) IBOutlet UIView *vuPublishOnFBContainer;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnPublishOnFB;
@property (weak, nonatomic) IBOutlet UILabel *lblPublishToFBWallTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPublishToFBWallSubtitle;
//@property (weak, nonatomic) IBOutlet UIView *vuStreamVideoToFBPageContainer;
//@property (weak, nonatomic) IBOutlet UIButton *tglBtnStreamVideoToFBPage;

@property (weak, nonatomic) IBOutlet UIView *vuDispatchModeContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblDispatchModeTitile;
@property (weak, nonatomic) IBOutlet UILabel *lblDispatchModeSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnDispatchMode;

@property (weak, nonatomic) IBOutlet UIView *vuDeleteVideoOptionContainer;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnDeleteVideoOption;
@property (weak, nonatomic) IBOutlet UILabel *lblDeleteVideoOptionTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDeleteVideoOptionSubtitle;

@property (weak, nonatomic) IBOutlet UIView *vuGPSAccurateTrackingContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblGPSAccurateTrackingTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblGPSAccurateTrackingSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnGPSAccurateTracking;

@property (weak, nonatomic) IBOutlet UIView *vuLocationUpdatesContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblLocationUpdatesTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblLocationUpdatesSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnLocationUpdates;
@property (weak, nonatomic) IBOutlet UIButton *btnBlockedUsersAndSpammers;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnectFromFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnVideoSettings;
@property (weak, nonatomic) IBOutlet UIView *vuRideRequestsOptionContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblRideRequestTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRideRequestSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnRideRequests;
@property (weak, nonatomic) IBOutlet UIButton *btnRideSettings;
@property (weak, nonatomic) IBOutlet UIView *vuUploadContactsOptionContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadContactsTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblUploadContactsSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnUploadContacts;

@property (weak, nonatomic) IBOutlet UIView *vuDarkModeOptionContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblDarkModeTitile;
@property (weak, nonatomic) IBOutlet UILabel *lblDarkModeSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnDarkMode;
@property (weak, nonatomic) IBOutlet UIButton *btnDownloadMyData;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteMyAccount;

///constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsConnectToFBTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsConnectToFBTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsConnectToFBSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsConnectToFBBtnTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsConnectToFBBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsConnectToFBBtnBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDisconnectFromFBBtnHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPublishToFBWallContainerTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPublishToFBWallTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPublishToFBWallSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPublishToFBWallSubtitleBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPublishToFBWallTglBtnWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVideoSettingsBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVideoSettingsBtnBS;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDeleteVideoOptionContainerTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDeleteVideoOptionTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDeleteVideoOptionSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDeleteVideoOptionSubtitleBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDeleteVideoOptionTglBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPatrolModeOptionContainerTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPatrolModeTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPatrolModeSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPatrolModeSeparatorTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPatrolModeSeparatorHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPatrolModeRadiusTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCurrentPatrolRadiusBaseVuTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCurrentPatrolRadiusBaseVuBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCurrentPatrolRadiusLblBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCurrentPatrolRadiusLblTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPatrolModeTglBtnWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDispatchModeOptionContainerTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDispatchModeTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDispatchModeSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDispatchModeSubtitleBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDispatchModeTglBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRideRequestsOptionContainerTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRideRequestsTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRideRequestsSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRideRequestTglBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRideSettingsButtonTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRideSettingsButtonBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRideSettingsButtonHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPanicButtonOptionContainerTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPanicButtonOptionTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPanicButtonOptionSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPanicButtonOptionAdvancePanicSettingBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPanicButtonOptionAdvancePanicSettingBtnTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPanicButtonOptionAdvancePanicSettingBtnBS;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsUploadContactsOptionContainerTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsUploadContactsTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsUploadContactsSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsUploadContactsSubtitleBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsUploadContactsTglBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDarkModeOptionContainerTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDarkModeTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDarkModeSubtitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDarkModeSubtitleBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDarkModeTglBtnWidth;


- (IBAction)btnNewPublicCellAlertToggled:(UIButton *)sender;
- (IBAction)sliderPatrolModeRadiusValueChanged:(UISlider *)sender;
- (IBAction)btnPatrolModeToggled:(UIButton *)sender;
- (IBAction)btnPublishOnFBToggled:(UIButton *)sender;
//- (IBAction)btnStreamVideoToFBPageToggled:(UIButton *)sender;
- (IBAction)btnDispatchModeToggled:(UIButton *)sender;
- (IBAction)btnDeleteVideoToggled:(UIButton *)sender;
- (IBAction)btnGPSAccurateTrackingToggled:(UIButton *)sender;
- (IBAction)btnLocationUpdatesToggled:(UIButton *)sender;

- (IBAction)btnBlockedUsersAndSpammersTapped:(UIButton *)sender;
- (IBAction)sgcMetricSystemValueChanged:(UISegmentedControl *)sender;
- (IBAction)btnConnectToFacebookTapped:(UIButton *)sender;
- (IBAction)btnDisconnectFromFacebookTapped:(UIButton *)sender;
- (IBAction)btnVideoSettingsTapped:(UIButton *)sender;
- (IBAction)btnAdvancedPanicSettingsTapped:(UIButton *)sender;
- (IBAction)btnRideRequestsToggled:(UIButton *)sender;
- (IBAction)btnRideSettingsTapped:(UIButton *)sender;
- (IBAction)btnUploadContactsToggled:(UIButton *)sender;
- (IBAction)btnDarkModeToggled:(UIButton *)sender;
- (IBAction)btnDownloadMyDataTapped:(UIButton *)sender;
- (IBAction)btnDeleteMyAccountTapped:(UIButton *)sender;

@property (nonatomic, strong) NSString *strConnectToFacebookTitle;
@property (nonatomic, strong) NSString *strConnectToFacebookSubtitle;
@property (nonatomic, strong) NSArray *arrConnectToFBOptionsInitialConstraints;
@property (nonatomic, assign) float disconnectFromFBBtnInitialHeightConstraintVal;
#if PATROL_FEATURE_ENABLED
@property (nonatomic, assign, getter=shouldEnablePatrolModeOnLocationAllowed) BOOL enablePatrolModeOnLocationAllowed;
#endif
@property (nonatomic, assign, getter=shouldEnableNewPublicCellAlertOnLocationAllowed) BOOL enableNewPublicCellAlertOnLocationAllowed;
#if RIDE_HAILING_ENABLED
@property (nonatomic, assign, getter=shouldEnableRideRequestsOnLocationAllowed) BOOL enableRideRequestsOnLocationAllowed;
#endif
@property (nonatomic, assign, getter=shouldEnableLocationUpdatesOnLocationAllowed) BOOL enableLocationUpdatesOnLocationAllowed;
@property (nonatomic, strong) UIImpactFeedbackGenerator *feedbackGenerator;
@end

@implementation C411SettingsVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self initializeSettings];
    [self registerForNotifications];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;
    
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

-(void)configureViews
{
    ///set title
    self.title = NSLocalizedString(@"Settings", nil);
    if (@available(iOS 11, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        ///Above line is commented to disable large title temporarily to fix an issue(Navigation bar background color gets cleared for large titles) until we switch to Xcode 11 having base SDK as iOS 13 for compilation that provides the new UINavigationBarAppearance Class using which we can set same appearance for all scrollEdgeAppearance, standardAppearance and compactAppearance to resolve the issue as provided here: https://stackoverflow.com/a/56696967/3412051
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }

    ///set corner radius to each container views
    self.vuDarkModeOptionContainer.layer.cornerRadius = 4.0;
    self.vuDarkModeOptionContainer.layer.masksToBounds = YES;
    
    self.vuPanicButtonSettingsContainer.layer.cornerRadius = 4.0;
    self.vuPanicButtonSettingsContainer.layer.masksToBounds = YES;
    
    self.vuNewPublicCellAlertContainer.layer.cornerRadius = 4.0;
    self.vuNewPublicCellAlertContainer.layer.masksToBounds = YES;
    
    self.vuPatrolOptionContainer.layer.cornerRadius = 4.0;
    self.vuPatrolOptionContainer.layer.masksToBounds = YES;
    
    self.vuMetricSelectionContainer.layer.cornerRadius = 4.0;
    self.vuMetricSelectionContainer.layer.masksToBounds = YES;

    self.vuConnectToFacebookContainer.layer.cornerRadius = 4.0;
    self.vuConnectToFacebookContainer.layer.masksToBounds = YES;

    self.vuPublishOnFBContainer.layer.cornerRadius = 4.0;
    self.vuPublishOnFBContainer.layer.masksToBounds = YES;
    
    self.vuDispatchModeContainer.layer.cornerRadius = 4.0;
    self.vuDispatchModeContainer.layer.masksToBounds = YES;


    self.vuDeleteVideoOptionContainer.layer.cornerRadius = 4.0;
    self.vuDeleteVideoOptionContainer.layer.masksToBounds = YES;

    self.vuGPSAccurateTrackingContainer.layer.cornerRadius = 4.0;
    self.vuGPSAccurateTrackingContainer.layer.masksToBounds = YES;

    self.vuLocationUpdatesContainer.layer.cornerRadius = 4.0;
    self.vuLocationUpdatesContainer.layer.masksToBounds = YES;

    ///set current patrol radius value container corner radius
    self.vuCurrentPatrolRadiusContainer.layer.cornerRadius = self.vuCurrentPatrolRadiusContainer.bounds.size.height / 2;
    self.vuCurrentPatrolRadiusContainer.layer.masksToBounds = YES;
    
    self.vuRideRequestsOptionContainer.layer.cornerRadius = 4.0;
    self.vuRideRequestsOptionContainer.layer.masksToBounds = YES;

    self.vuUploadContactsOptionContainer.layer.cornerRadius = 4.0;
    self.vuUploadContactsOptionContainer.layer.masksToBounds = YES;
    
    ///Make toggle buttons as FAB buttons
    [self.tglBtnDarkMode makeFloatingActionButton];
    [self.tglBtnNewPublicCellAlert makeFloatingActionButton];
    [self.tglBtnPatrolMode makeFloatingActionButton];
    [self.tglBtnPublishOnFB makeFloatingActionButton];
    [self.tglBtnDispatchMode makeFloatingActionButton];
    [self.tglBtnDeleteVideoOption makeFloatingActionButton];
    [self.tglBtnGPSAccurateTracking makeFloatingActionButton];
    [self.tglBtnLocationUpdates makeFloatingActionButton];
    [self.tglBtnRideRequests makeFloatingActionButton];
    [self.tglBtnUploadContacts makeFloatingActionButton];
    
    ///Configure blocked users and spammers button
    self.btnBlockedUsersAndSpammers.layer.cornerRadius = 4.0f;
    self.btnBlockedUsersAndSpammers.layer.masksToBounds = YES;
    
    ///configure connect to facebook button
    self.btnConnectToFacebook.layer.cornerRadius = 4.0f;
    self.btnConnectToFacebook.layer.masksToBounds = YES;

    ///configure disconnect from facebook button
    self.btnDisconnectFromFacebook.layer.cornerRadius = 4.0f;
    self.btnDisconnectFromFacebook.layer.masksToBounds = YES;

    ///configure video settings button
    self.btnVideoSettings.layer.cornerRadius = 4.0f;
    self.btnVideoSettings.layer.masksToBounds = YES;

    ///configure advanced panic settings button
    self.btnAdvancedPanicSettings.layer.cornerRadius = 4.0f;
    self.btnAdvancedPanicSettings.layer.masksToBounds = YES;

    ///configure Ride Settings button
    self.btnRideSettings.layer.cornerRadius = 4.0f;
    self.btnRideSettings.layer.masksToBounds = YES;

    ///Configure Download all my data button
    self.btnDownloadMyData.layer.cornerRadius = 4.0f;
    self.btnDownloadMyData.layer.masksToBounds = YES;
    
    ///configure delete my account button
    self.btnDeleteMyAccount.layer.cornerRadius = 4.0f;
    self.btnDeleteMyAccount.layer.masksToBounds = YES;

    ///Set New public cell alert description with dynamic app name
    self.lblNewPublicCellAlertDescription.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Turning this feature on will allow you to receive %@ alert whenever a new Public Cell is created nearby you. This feature requires Location Updates to be turned on.",nil),LOCALIZED_APP_NAME];
   
    ///Set Patrol mode description with dynamic app name
    self.lblPatrolModeDescription.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Turning this feature on will allow you to receive %@ alerts when someone in the patrol radius needs help.This feature requires Location Updates to be turned on.",nil),LOCALIZED_APP_NAME];

    ///Set Metric Selection description with dynamic app name
    self.lblMetricSelectionDescription.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Please select if you would like %@ to use kilometers or miles as the standard distance unit.",nil),LOCALIZED_APP_NAME];

    ///Set panic button settings title with dynamic app name
#if APP_IER
    self.lblPanicButtonSettingsTitle.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ PANIC BUTTON SETTINGS",nil),LOCALIZED_APP_NAME];
#else
    self.lblPanicButtonSettingsTitle.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ PANIC BUTTON SETTINGS",nil),LOCALIZED_APP_NAME.uppercaseString];

#endif
    
#if IS_PANIC_BUTTON_ENABLED
    
    ///Set panic button settings subtitle for only advanced panic alert setting
    self.lblPanicButtonSettingsSubtitle.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Tap Advanced Panic Settings to configure the time, recipients and additional text to be sent while issuing Panic alert.",nil)];
#else
    
    self.lblPanicButtonSettingsSubtitle.text = nil;
    
    
#endif
    
    ///Set Upload contacts subtitle with dynamic app name
    self.lblUploadContactsSubtitle.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Turning this feature ON will enable %@ to continuously upload your phone contacts in order to inform you when they join %@ so that you can friend with them if you want.",nil),LOCALIZED_APP_NAME, LOCALIZED_APP_NAME];
    
    ///Apply Colors
    [self applyColors];

    ///Prepare Selection Feedback Generator
    self.feedbackGenerator = [[UIImpactFeedbackGenerator alloc]init];
    [self.feedbackGenerator prepare];
}

-(void)applyColors {
    ///Set Background Color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set background color on option containers
    UIColor *containerBGColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuDarkModeOptionContainer.backgroundColor = containerBGColor;
    self.vuPanicButtonSettingsContainer.backgroundColor = containerBGColor;
    self.vuRideRequestsOptionContainer.backgroundColor = containerBGColor;
    self.vuNewPublicCellAlertContainer.backgroundColor = containerBGColor;
    self.vuPatrolOptionContainer.backgroundColor = containerBGColor;
    self.vuMetricSelectionContainer.backgroundColor = containerBGColor;
    self.vuConnectToFacebookContainer.backgroundColor = containerBGColor;
    self.vuDispatchModeContainer.backgroundColor = containerBGColor;
    self.vuDeleteVideoOptionContainer.backgroundColor = containerBGColor;
    self.vuUploadContactsOptionContainer.backgroundColor = containerBGColor;
    self.vuGPSAccurateTrackingContainer.backgroundColor = containerBGColor;
    self.vuLocationUpdatesContainer.backgroundColor = containerBGColor;
    
    ///Set separator color
    self.vuPatrolRadiusSeparator.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;
    
    ///Set container title colors
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblDarkModeTitile.textColor = primaryTextColor;
    self.lblPanicButtonSettingsTitle.textColor = primaryTextColor;
    self.lblRideRequestTitle.textColor = primaryTextColor;
    self.lblNewPublicCellAlertTitle.textColor = primaryTextColor;
    self.lblPatrolModeTitle.textColor = primaryTextColor;
    self.lblPatrolModeRadiusTitle.textColor = primaryTextColor;
    self.lblMetricSelectionTitle.textColor = primaryTextColor;
    self.lblConnectToFacebookTitle.textColor = primaryTextColor;
    self.lblDispatchModeTitile.textColor = primaryTextColor;
    self.lblDeleteVideoOptionTitle.textColor = primaryTextColor;
    self.lblUploadContactsTitle.textColor = primaryTextColor;
    self.lblGPSAccurateTrackingTitle.textColor = primaryTextColor;
    self.lblLocationUpdatesTitle.textColor = primaryTextColor;
    
    ///Set container subtitle colors
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblDarkModeSubtitle.textColor = secondaryTextColor;
    self.lblPanicButtonSettingsSubtitle.textColor = secondaryTextColor;
    self.lblRideRequestSubtitle.textColor = secondaryTextColor;
    self.lblNewPublicCellAlertDescription.textColor = secondaryTextColor;
    self.lblPatrolModeDescription.textColor = secondaryTextColor;
    self.lblPatrolRadiusRange.textColor = secondaryTextColor;
    self.lblMetricSelectionDescription.textColor = secondaryTextColor;
    self.lblConnectToFacebookSubtitle.textColor = secondaryTextColor;
    self.lblDispatchModeSubtitle.textColor = secondaryTextColor;
    self.lblDeleteVideoOptionSubtitle.textColor = secondaryTextColor;
    self.lblUploadContactsSubtitle.textColor = secondaryTextColor;
    self.lblGPSAccurateTrackingSubtitle.textColor = secondaryTextColor;
    self.lblLocationUpdatesSubtitle.textColor = secondaryTextColor;

    ///Set Action Buttons background color
    UIColor *primaryColor = [C411ColorHelper sharedInstance].primaryColor;
    self.btnVideoSettings.backgroundColor = primaryColor;
    self.btnAdvancedPanicSettings.backgroundColor = primaryColor;
    self.btnRideSettings.backgroundColor = primaryColor;
    self.btnConnectToFacebook.backgroundColor = primaryColor;
    self.btnBlockedUsersAndSpammers.backgroundColor = primaryColor;
    self.btnDisconnectFromFacebook.backgroundColor = [UIColor redColor];
    if ([[C411AppDefaults sharedAppDefaults]canDownloadMyData]) {
        self.btnDownloadMyData.backgroundColor = primaryColor;
    }
    else {
        self.btnDownloadMyData.backgroundColor = [UIColor grayColor];
    }
    self.btnDeleteMyAccount.backgroundColor = [UIColor redColor];
    
    ///Set title color on action buttons
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.btnVideoSettings.titleLabel.textColor = primaryBGTextColor;
    self.btnAdvancedPanicSettings.titleLabel.textColor = primaryBGTextColor;
    self.btnRideSettings.titleLabel.textColor = primaryBGTextColor;
    self.btnConnectToFacebook.titleLabel.textColor = primaryBGTextColor;
    self.btnBlockedUsersAndSpammers.titleLabel.textColor = primaryBGTextColor;
    self.btnDownloadMyData.titleLabel.textColor = primaryBGTextColor;
    self.btnDeleteMyAccount.titleLabel.textColor = primaryBGTextColor;
    
    ///Set tint color on segment control
    self.sgcMetricSystem.tintColor = primaryColor;
    ///Set title color on segment control
    [[UISegmentedControl appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName: primaryBGTextColor} forState:UIControlStateSelected];
    
    ///set secondary colors on slider
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    self.sliderPatrolModeRadius.minimumTrackTintColor = secondaryColor;
    self.sliderPatrolModeRadius.maximumTrackTintColor = secondaryColor;
    self.sliderPatrolModeRadius.thumbTintColor = secondaryColor;

    ///Set shadow color on fab buttons
    UIColor *fabShadowColor = [C411ColorHelper sharedInstance].fabShadowColor;
    self.tglBtnDarkMode.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnRideRequests.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnNewPublicCellAlert.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnPatrolMode.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnDispatchMode.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnDeleteVideoOption.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnUploadContacts.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnGPSAccurateTracking.layer.shadowColor = fabShadowColor.CGColor;
    self.tglBtnLocationUpdates.layer.shadowColor = fabShadowColor.CGColor;
    self.navigationController.navigationBar.barStyle = [C411ColorHelper sharedInstance].barStyle;
    
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

-(void)initializeSettings
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self initializeLocationDependentSettings];
    
    ///Hide publish to fb option
    [self hidePublishToFacebookWallOption];
    
    ///Hide connect to fb option
    [self hideConnectToFacebookOption];


#if FB_ENABLED
    ///show or hide connect to Facebook option
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if ([PFFacebookUtils isLinkedWithUser:currentUser]) {

         ///check whether user has initially signed up using facebook or using default signup option
        if ([C411StaticHelper getSignUpTypeOfUser:currentUser] == SignUpTypeFacebook) {

            ///user has initially signed up using facebook as in this case the username will not be human readable and we'll never change username in this case, hide the disconnect button.NOTE:if user is signed Up using facebook then username is automatically created by Parse and we are assuming that it will not contain '@' symbol

            [self hideDisconnectFromFacebookButton];


        }
        else{

            ///let the disconnect button be visible by default, do nothing

        }


    }
    else{

        ///user is not linked with facebook(i.e neither signed up with FB nor linked the existing account with FB), let the connect to facebook option be available by default, and hide the disconnect button

        [self hideDisconnectFromFacebookButton];

    }



//    ///Set publish on FB option
//    [self toggleButton:self.tglBtnPublishOnFB toSelected:[defaults boolForKey:kPublishOnFB]];

#else
    ///Hide disconnect from fb button
    [self hideDisconnectFromFacebookButton];

#endif

#if DISPATCH_FEATURE_ENABLED
    ///Set Dispatch Mode setting
    [self toggleButton:self.tglBtnDispatchMode toSelected:[defaults boolForKey:kDispatchMode]];
#else
    ///Hide dispatch mode option
    [self hideDispatchModeOption];
    
#endif

#if VIDEO_STREAMING_ENABLED
    ///Set fake Delete Video setting
    [self toggleButton:self.tglBtnDeleteVideoOption toSelected:[defaults boolForKey:kFakeDelete]];
#else
    ///Hide the Fake Delete Option
    [self hideFakeDeleteOption];
    
    ///Hide Video Settings Button
    [self hideVideoSettingsButton];
    
#endif

    ///Set location accuracy switch
    [self toggleButton:self.tglBtnGPSAccurateTracking toSelected:[defaults boolForKey:kLocationAccuracyOn]];
    
    
#if (!IS_PANIC_BUTTON_ENABLED)
    
    ///Hide panic button option
    [self hidePanicButtonOption];
        
#endif
    
#if IS_CONTACTS_SYNCING_ENABLED
    ///Set upload contacts switch
    BOOL isUploadContactsEnabled = [[AppDelegate getLoggedInUser][kUserSyncContactsKey] boolValue];
    [self toggleButton:self.tglBtnUploadContacts toSelected:isUploadContactsEnabled];
    
#else
    
    ///Hide upload contacts option
    [self hideUploadContactsOption];
    
#endif

#if IS_DARK_MODE_ENABLED
    ///Set Dark Mode setting
    [self toggleButton:self.tglBtnDarkMode toSelected:[defaults boolForKey:kDarkMode]];
#else
    ///Hide dark mode option
    [self hideDarkModeOption];
    
#endif
    
}

-(void)initializeLocationDependentSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    ///Set new public cell alert switch
    BOOL shouldNotifyOnNewPublicCellCreation = [[AppDelegate getLoggedInUser][kUserNewPublicCellAlertKey] boolValue];
    [self toggleButton:self.tglBtnNewPublicCellAlert toSelected:shouldNotifyOnNewPublicCellCreation];
    
    ///Get metric chosen by user
    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
    
#if PATROL_FEATURE_ENABLED
    ///Set patrol mode switch
    BOOL isPatrolModeOn = [[AppDelegate getLoggedInUser][kUserPatrolModeKey] boolValue];
    [self toggleButton:self.tglBtnPatrolMode toSelected:isPatrolModeOn];
    
    
    ///Set patrol mode radius
    float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];///will be in miles as it will always be saved in miles in user defaults
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///set values in kms
        ///convert patrol mode radius to km
        patrolModeRadius = patrolModeRadius * MILES_TO_KM;
        NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
        
        self.lblCurrentPatrolRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:2],strMetric];
        self.sliderPatrolModeRadius.minimumValue = PATROL_MODE_MIN_RADIUS * MILES_TO_KM;
        self.sliderPatrolModeRadius.maximumValue = PATROL_MODE_MAX_RADIUS * MILES_TO_KM;
        self.sliderPatrolModeRadius.value = patrolModeRadius;
        
        ///set km as selected metric system
        self.sgcMetricSystem.selectedSegmentIndex = 1;
        
        self.lblPatrolRadiusRange.text = NSLocalizedString(@"(1-80 kms)", nil);
        
    }
    else{
        
        ///Set values in miles
        NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
        self.lblCurrentPatrolRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:2],strMetric];
        self.sliderPatrolModeRadius.minimumValue = PATROL_MODE_MIN_RADIUS;
        self.sliderPatrolModeRadius.maximumValue = PATROL_MODE_MAX_RADIUS;
        self.sliderPatrolModeRadius.value = patrolModeRadius;
        
        ///set miles as selected metric system
        self.sgcMetricSystem.selectedSegmentIndex = 0;
        
        self.lblPatrolRadiusRange.text = NSLocalizedString(@"(1-50 miles)", nil);
        
    }
    
#else
    
    ///Hide the patrol Mode Option
    [self hidePatrolModeOption];
    
    ///set selected metric
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///set km as selected metric system
        self.sgcMetricSystem.selectedSegmentIndex = 1;
    }
    else{
        
        ///set miles as selected metric system
        self.sgcMetricSystem.selectedSegmentIndex = 0;
    }
    
    
#endif
    
    ///Set location update switch
    [self toggleButton:self.tglBtnLocationUpdates toSelected:[defaults boolForKey:kLocationUpdateOn]];
    
    
#if RIDE_HAILING_ENABLED
    ///Set ride requests switch
    BOOL isRideRequestEnabled = [[AppDelegate getLoggedInUser][kUserRideRequestAlertKey] boolValue];
    [self toggleButton:self.tglBtnRideRequests toSelected:isRideRequestEnabled];
    
#else
    
    ///Hide ride request option
    [self hideRideRequestOption];
    
#endif


}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(contactSyncingEnabled:) name:kContactSyncingEnabledNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationBasedFeaturesTemporarilyDisabled:) name:kLocationBasedFeaturesTemporarilyDisabledNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationBasedFeaturesReenabled:) name:kLocationBasedFeaturesReenabledNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)registerForForegroundNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)toggleLocationUpdateWithValue:(BOOL)isEnabled
{
    //[[NSNotificationCenter defaultCenter]postNotificationName:kLocationUpdateValueChangedNotification object:@(isEnabled)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isEnabled forKey:kLocationUpdateOn];
    [defaults synchronize];
    
    if(isEnabled){
        [[C411LocationManager sharedInstance]startUpdatingLocations];
    }
    else{
        [[C411LocationManager sharedInstance]stopUpdatingLocation];
    }
    
}

-(void)updatePatrolModeWithValue:(BOOL)isPatrolModeOn andCompletion:(void(^)(BOOL succeeded, NSError *error))completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSNumber *patrolModeValue = isPatrolModeOn ?PATROL_MODE_VALUE_ON : PATROL_MODE_VALUE_OFF;
    
    currentUser[kUserPatrolModeKey] = patrolModeValue;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (completion) {
            
            completion(succeeded,error);
        }
        
    }];
    
}

-(void)updateNewPublicCellAlertWithValue:(BOOL)isNewPublicCellAlertOn andCompletion:(void(^)(BOOL succeeded, NSError *error))completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSNumber *newPublicCellAlertValue = isNewPublicCellAlertOn ?NEW_PUBLIC_CELL_ALERT_VALUE_ON : NEW_PUBLIC_CELL_ALERT_VALUE_OFF;
    
    currentUser[kUserNewPublicCellAlertKey] = newPublicCellAlertValue;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (completion) {
            
            completion(succeeded,error);
        }
        
    }];
    
}

//-(void)updatePatrolModeWithValue:(BOOL)isPatrolModeOn newPublicCellAlertWithValue:(BOOL)isNewPublicCellAlertOn andCompletion:(void(^)(BOOL succeeded, NSError *error))completion
//{
//    PFUser *currentUser = [AppDelegate getLoggedInUser];
//    NSNumber *patrolModeValue = isPatrolModeOn ?PATROL_MODE_VALUE_ON : PATROL_MODE_VALUE_OFF;
//
//    currentUser[kUserPatrolModeKey] = patrolModeValue;
//
//    NSNumber *newPublicCellAlertValue = isNewPublicCellAlertOn ?NEW_PUBLIC_CELL_ALERT_VALUE_ON : NEW_PUBLIC_CELL_ALERT_VALUE_OFF;
//
//    currentUser[kUserNewPublicCellAlertKey] = newPublicCellAlertValue;
//
//    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
//
//        if (completion) {
//
//            completion(succeeded,error);
//        }
//
//    }];
//
//}


- (void)checkDeviceAuthorizationStatusForCamera
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            
        }
        else
        {
            //Not granted access to mediaType
            __weak typeof(self) weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{

                [C411StaticHelper showAlertWithTitle:LOCALIZED_APP_NAME message:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ doesn't have permission to use Camera, please change privacy settings",nil), LOCALIZED_APP_NAME] onViewController:weakSelf];
                
            });
        }
    }];
}

-(void)hideConnectToFacebookOption
{
    ///save the text for later
    self.strConnectToFacebookTitle = self.lblConnectToFacebookTitle.text;
    self.strConnectToFacebookSubtitle = self.lblConnectToFacebookSubtitle.text;
    ///save contraints initial value and use it later in that order
    self.arrConnectToFBOptionsInitialConstraints = @[@(self.cnsConnectToFBTS.constant),
                                                     @(self.cnsConnectToFBTitleTS.constant),
                                                     @(self.cnsConnectToFBSubtitleTS.constant),
                                                     @(self.cnsConnectToFBBtnTS.constant),
                                                     @(self.cnsConnectToFBBtnHeight.constant),
                                                     @(self.cnsConnectToFBBtnBS.constant)
                                                     
                                                     ];
    
    ///hide the option
    self.lblConnectToFacebookTitle.text = nil;
    self.lblConnectToFacebookSubtitle.text = nil;
    self.cnsConnectToFBTS.constant = 0;
    self.cnsConnectToFBTitleTS.constant = 0;
    self.cnsConnectToFBSubtitleTS.constant = 0;
    self.cnsConnectToFBBtnTS.constant = 0;
    self.cnsConnectToFBBtnHeight.constant = 0;
    self.cnsConnectToFBBtnBS.constant = 0;

}

-(void)showConnectToFacebookOption
{
    
    ///set text
    self.lblConnectToFacebookTitle.text = self.strConnectToFacebookTitle;
    self.lblConnectToFacebookSubtitle.text = self.strConnectToFacebookSubtitle;
    
    ///update constraints in the same order it's added to array
    self.cnsConnectToFBTS.constant = [[self.arrConnectToFBOptionsInitialConstraints objectAtIndex:0]floatValue];
    self.cnsConnectToFBTitleTS.constant = [[self.arrConnectToFBOptionsInitialConstraints objectAtIndex:1]floatValue];
    self.cnsConnectToFBSubtitleTS.constant = [[self.arrConnectToFBOptionsInitialConstraints objectAtIndex:2]floatValue];
    self.cnsConnectToFBBtnTS.constant = [[self.arrConnectToFBOptionsInitialConstraints objectAtIndex:3]floatValue];
    self.cnsConnectToFBBtnHeight.constant = [[self.arrConnectToFBOptionsInitialConstraints objectAtIndex:4]floatValue];
    self.cnsConnectToFBBtnBS.constant = [[self.arrConnectToFBOptionsInitialConstraints objectAtIndex:5]floatValue];

    
    
}

-(void)hideDisconnectFromFacebookButton
{
    ///save the initial height for later use
    self.disconnectFromFBBtnInitialHeightConstraintVal = self.cnsDisconnectFromFBBtnHeight.constant;
    
    ///hide the disconnect button by setting it's height contraint to 0
    self.cnsDisconnectFromFBBtnHeight.constant = 0;
    
}

-(void)showDisconnectFromFacebookButton
{
    ///set the initial contraint for height again
    self.cnsDisconnectFromFBBtnHeight.constant = self.disconnectFromFBBtnInitialHeightConstraintVal;
    
}

-(void)hidePublishToFacebookWallOption
{
    self.lblPublishToFBWallTitle.text = nil;
    self.lblPublishToFBWallSubtitle.text = nil;
    self.cnsPublishToFBWallContainerTS.constant = 0;
    self.cnsPublishToFBWallTitleTS.constant = 0;
    self.cnsPublishToFBWallSubtitleTS.constant = 0;
    self.cnsPublishToFBWallSubtitleBS.constant = 0;
    self.cnsPublishToFBWallTglBtnWidth.constant = 0;

}

-(void)hideVideoSettingsButton
{
    self.lblDeleteVideoOptionTitle.text = nil;
    self.lblDeleteVideoOptionSubtitle.text = nil;
    self.cnsDeleteVideoOptionContainerTS.constant = 0;
    self.cnsDeleteVideoOptionTitleTS.constant = 0;
    self.cnsDeleteVideoOptionSubtitleTS.constant = 0;
    self.cnsDeleteVideoOptionSubtitleBS.constant = 0;
    self.cnsDeleteVideoOptionTglBtnWidth.constant = 0;

}

-(void)hideFakeDeleteOption
{
    self.cnsVideoSettingsBtnHeight.constant = 0;
    self.cnsVideoSettingsBtnBS.constant = 0;
    self.btnVideoSettings.hidden = YES;
}

-(void)hidePatrolModeOption
{
    self.lblPatrolModeTitle.text = nil;
    self.lblPatrolModeDescription.text = nil;
    self.lblPatrolModeRadiusTitle.text = nil;
    self.lblPatrolRadiusRange.text = nil;
    self.lblCurrentPatrolRadius.text = nil;
    
    self.cnsPatrolModeOptionContainerTS.constant = 0;
    self.cnsPatrolModeTitleTS.constant = 0;
    self.cnsPatrolModeSubtitleTS.constant = 0;
    self.cnsPatrolModeSeparatorTS.constant = 0;
    self.cnsPatrolModeSeparatorHeight.constant = 0;
    self.cnsPatrolModeRadiusTitleTS.constant = 0;
    self.cnsCurrentPatrolRadiusBaseVuTS.constant = 0;
    self.cnsCurrentPatrolRadiusLblTS.constant = 0;
    self.cnsCurrentPatrolRadiusLblBS.constant = 0;
    self.cnsCurrentPatrolRadiusBaseVuBS.constant = 0;
    self.cnsPatrolModeTglBtnWidth.constant = 0;
    
}

-(void)hideDispatchModeOption
{
    self.lblDispatchModeTitile.text = nil;
    self.lblDispatchModeSubtitle.text = nil;
    
    self.cnsDispatchModeOptionContainerTS.constant = 0;
    self.cnsDispatchModeTitleTS.constant = 0;
    self.cnsDispatchModeSubtitleTS.constant = 0;
    self.cnsDispatchModeSubtitleBS.constant = 0;
    self.cnsDispatchModeTglBtnWidth.constant = 0;
    
}

-(void)hideRideRequestOption
{
    self.lblRideRequestTitle.text = nil;
    self.lblRideRequestSubtitle.text = nil;
    
    self.cnsRideRequestsOptionContainerTS.constant = 0;
    self.cnsRideRequestsTitleTS.constant = 0;
    self.cnsRideRequestsSubtitleTS.constant = 0;
    self.cnsRideRequestTglBtnWidth.constant = 0;
    self.cnsRideSettingsButtonTS.constant = 0;
    self.cnsRideSettingsButtonHeight.constant = 0;
    self.cnsRideSettingsButtonBS.constant = 0;
}

-(void)hidePanicButtonOption
{
    self.lblPanicButtonSettingsTitle.text = nil;
    self.lblPanicButtonSettingsSubtitle.text = nil;
    
    self.cnsPanicButtonOptionContainerTS.constant = 0;
    self.cnsPanicButtonOptionTitleTS.constant = 0;
    self.cnsPanicButtonOptionSubtitleTS.constant = 0;
    self.cnsPanicButtonOptionAdvancePanicSettingBtnHeight.constant = 0;
    self.cnsPanicButtonOptionAdvancePanicSettingBtnTS.constant = 0;
    self.cnsPanicButtonOptionAdvancePanicSettingBtnBS.constant = 0;

}

-(void)hideUploadContactsOption
{
    self.lblUploadContactsTitle.text = nil;
    self.lblUploadContactsSubtitle.text = nil;
    
    self.cnsUploadContactsOptionContainerTS.constant = 0;
    self.cnsUploadContactsTitleTS.constant = 0;
    self.cnsUploadContactsSubtitleTS.constant = 0;
    self.cnsUploadContactsSubtitleBS.constant = 0;
    self.cnsUploadContactsTglBtnWidth.constant = 0;
    
}

-(void)hideDarkModeOption
{
    self.lblDarkModeTitile.text = nil;
    self.lblDarkModeSubtitle.text = nil;
    
    self.cnsDarkModeOptionContainerTS.constant = 0;
    self.cnsDarkModeTitleTS.constant = 0;
    self.cnsDarkModeSubtitleTS.constant = 0;
    self.cnsDarkModeSubtitleBS.constant = 0;
    self.cnsDarkModeTglBtnWidth.constant = 0;
    
}

//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnNewPublicCellAlertToggled:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    BOOL isNewPublicCellAlertOn = (self.shouldEnableNewPublicCellAlertOnLocationAllowed) ? YES : (!sender.isSelected);
    if(!self.shouldEnableNewPublicCellAlertOnLocationAllowed){
        [self toggleButton:sender toSelected:isNewPublicCellAlertOn];
        ///Disable New Public Cell Alert switch
        sender.enabled = NO;
        sender.alpha = 0.6;
    }
    
    if (isNewPublicCellAlertOn) {
        
        ///Check if location access is allowed or not
        if(![[C411LocationManager sharedInstance]isLocationAccessAllowed]){
            ///Location access is not allowed, show enable location popup and return
            NSString *strMsgPrefix = [NSString localizedStringWithFormat: NSLocalizedString(@"Turning on New Public Cell Alerts requires %@ to access your location.", nil), LOCALIZED_APP_NAME];
            [[C411LocationManager sharedInstance]showEnableLocationPopupWithCustomMessagePrefix:strMsgPrefix cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                ///User cancelled to enable location
                ///reenable switches and deselect it back
                sender.enabled = YES;
                sender.alpha = 1.0;
                [weakSelf toggleButton:sender toSelected:NO];
                
            } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                ///User initiated to Enable location access, set the flag to enable this feature when location is enabled
                weakSelf.enableNewPublicCellAlertOnLocationAllowed = YES;
                [weakSelf registerForForegroundNotification];
            }];
            
            return;
        }
        ///Disable location update switch as well, as it needs to be set on as well if New Public Cell Alert is enabled successfully
        self.tglBtnLocationUpdates.enabled = NO;
        self.tglBtnLocationUpdates.alpha = 0.6;
        
    }
    
    [self updateNewPublicCellAlertWithValue:isNewPublicCellAlertOn andCompletion:^(BOOL succeeded, NSError *error) {
        
        ///reenable switches
        sender.enabled = YES;
        sender.alpha = 1.0;
        if (isNewPublicCellAlertOn) {
            ///Enable location update switch as well
            weakSelf.tglBtnLocationUpdates.enabled = YES;
            weakSelf.tglBtnLocationUpdates.alpha = 1.0;
        }
        
        if (succeeded) {
            
            
            ///New Public Cell Alert value updated successfully on parse
            ///notify the observers
//            [[NSNotificationCenter defaultCenter]postNotificationName:kNewPublicCellCreationAlertValueChangedNotification object:@(isNewPublicCellAlertOn)];
            
            if (isNewPublicCellAlertOn) {
                
                ///User has enabled New Public Cell Alert, so enable location update switch as well if it is off
                if (!weakSelf.tglBtnLocationUpdates.isSelected) {
                    
                    [weakSelf toggleButton:weakSelf.tglBtnLocationUpdates toSelected:YES];
                    [weakSelf toggleLocationUpdateWithValue:YES];
                    
                    
                }
                
                ///Show toast for enabled
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"New Public Cell Alert Enabled", nil)];
            }
            else{
                
                ///User has turned off the New Public Cell Alert, so it will cause no effect on location update value, so we do nothing over here
                
                ///Show toast for disabled
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"New Public Cell Alert Disabled", nil)];

            }
            
        }
        else{
            
            ///some error occured updating New Public Cell Alert value on parse, toggle switch back to original position
            [weakSelf toggleButton:sender toSelected:!isNewPublicCellAlertOn];
            
        }
        
    }];
    
}

- (IBAction)sliderPatrolModeRadiusValueChanged:(UISlider *)sender {
    
#if PATROL_FEATURE_ENABLED
    float patrolModeRadius = (int)sender.value;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ///Get metric chosen by user
    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
    
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///set values in kms
        ///Patrol mode radius we get is in km
        NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
        self.lblCurrentPatrolRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:2],strMetric];
        
        ///Convert to miles to be saved in user defaults
        patrolModeRadius = patrolModeRadius / MILES_TO_KM;
        
    }
    else{
        
        ///Set values in miles
        ///Patrol mode radius we get is in miles
        NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
        self.lblCurrentPatrolRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:2],strMetric];
    }
    
    ///update in defaults and save patrol mode in miles only for both case(miles or kms)
    [defaults setObject:@(patrolModeRadius) forKey:kPatrolModeRadius];
    [defaults synchronize];
    

#endif
    

}

- (IBAction)btnPatrolModeToggled:(UIButton *)sender {

#if PATROL_FEATURE_ENABLED
    __weak typeof(self) weakSelf = self;
    BOOL isPatrolModeOn = (self.shouldEnablePatrolModeOnLocationAllowed) ? YES : (!sender.isSelected);
    if(!self.shouldEnablePatrolModeOnLocationAllowed){
        [self toggleButton:sender toSelected:isPatrolModeOn];
        
        ///Disable patrol mode switch
        sender.enabled = NO;
        sender.alpha = 0.6;
    }
    
    if (isPatrolModeOn) {
        
        ///Check if location access is allowed or not
        if(![[C411LocationManager sharedInstance]isLocationAccessAllowed]){
            ///Location access is not allowed, show enable location popup and return
            NSString *strMsgPrefix = [NSString localizedStringWithFormat: NSLocalizedString(@"Turning on Patrol Mode requires %@ to access your location.", nil), LOCALIZED_APP_NAME];
            [[C411LocationManager sharedInstance]showEnableLocationPopupWithCustomMessagePrefix:strMsgPrefix cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                ///User cancelled to enable location
                ///reenable switches and deselect it back
                sender.enabled = YES;
                sender.alpha = 1.0;
                [weakSelf toggleButton:sender toSelected:NO];
                
            } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                ///User initiated to Enable location access, set the flag to enable this feature when location is enabled
                weakSelf.enablePatrolModeOnLocationAllowed = YES;
                [weakSelf registerForForegroundNotification];
            }];
            
            return;
        }
        
        ///Disable location update switch as well, as it needs to be set on as well if patrol mode is enabled successfully
        self.tglBtnLocationUpdates.enabled = NO;
        self.tglBtnLocationUpdates.alpha = 0.6;
        
    }
    
    
    [self updatePatrolModeWithValue:isPatrolModeOn andCompletion:^(BOOL succeeded, NSError *error) {
        
        ///reenable switches
        sender.enabled = YES;
        sender.alpha = 1.0;
        if (isPatrolModeOn) {
            ///Enable location update switch as well
            weakSelf.tglBtnLocationUpdates.enabled = YES;
            weakSelf.tglBtnLocationUpdates.alpha = 1.0;
        }
        
        if (succeeded) {
            
            
            ///Patrol mode value updated successfully on parse
            
            ///notify the observers
//            [[NSNotificationCenter defaultCenter]postNotificationName:kPatrolModeValueChangedNotification object:@(isPatrolModeOn)];
            
            if (isPatrolModeOn) {
                
                ///User has enabled patrol mode, so enable location update switch as well if it is off
                if (!weakSelf.tglBtnLocationUpdates.isSelected) {
                    
                    [weakSelf toggleButton:weakSelf.tglBtnLocationUpdates toSelected:YES];
                    [weakSelf toggleLocationUpdateWithValue:YES];
                    
                    
                }
                
                ///Show toast for enabled
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Patrol Mode Enabled", nil)];

            }
            else{
                
                ///User has turned off the patrol mode, so it will cause no effect on location update value, so we do nothing over here
                
                ///Show toast for disabled
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Patrol Mode Disabled", nil)];

            }
            
        }
        else{
            
            ///some error occured updating patrol mode value on parse, toggle switch back to original position
            [weakSelf toggleButton:sender toSelected:!isPatrolModeOn];
            
        }
        
    }];
#endif
    
}

- (IBAction)btnPublishOnFBToggled:(UIButton *)sender {

}


- (IBAction)btnDispatchModeToggled:(UIButton *)sender {

#if DISPATCH_FEATURE_ENABLED
    BOOL isOn = !sender.isSelected;
    [self toggleButton:sender toSelected:isOn];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:kDispatchMode];
    [defaults synchronize];
    if (isOn) {
        
        ///Show toast for enabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Dispatch Mode Enabled", nil)];
        
    }
    else{
        ///Show toast for disabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Dispatch Mode Disabled", nil)];

    }
#endif

}

- (IBAction)btnDeleteVideoToggled:(UIButton *)sender {
#if VIDEO_STREAMING_ENABLED
    BOOL isOn = !sender.isSelected;
    [self toggleButton:sender toSelected:isOn];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:kFakeDelete];
    [defaults synchronize];
    
    if (isOn) {
        
        ///Show informative alert
        UIAlertController *fakeDeleteInfoAlert = [UIAlertController alertControllerWithTitle:nil message:[NSString localizedStringWithFormat:NSLocalizedString(@"When this feature is enabled, a picture will be taken of anyone attempting to delete a %@ video alert using your phone's front camera. The video will not be deleted and will appear again when the app is relaunched",nil), LOCALIZED_APP_NAME] preferredStyle:UIAlertControllerStyleAlert];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            ///Ask permission to access the camera
            ///1.Check for authorization and show proper alert for first time
            [weakSelf checkDeviceAuthorizationStatusForCamera];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
            
        }];
        
        [fakeDeleteInfoAlert addAction:okAction];
        //[self presentViewController:fakeDeleteInfoAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:fakeDeleteInfoAlert];
        
        ///Show toast for enabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Delete Video Option Enabled", nil)];

    }
    else{
        
        ///Show toast for disabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Delete Video Option Disabled", nil)];

    }
 
#endif
}

- (IBAction)btnGPSAccurateTrackingToggled:(UIButton *)sender {
    
    BOOL isOn = !sender.isSelected;
    [self toggleButton:sender toSelected:isOn];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:kLocationAccuracyValueChangedNotification object:@(isOn)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:kLocationAccuracyOn];
    [defaults synchronize];

    if (isOn) {
        
        ///Show toast for enabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"GPS Accurate Tracking Enabled", nil)];
        
    }
    else{
        ///Show toast for disabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"GPS Accurate Tracking Disabled", nil)];
        
    }

}

- (IBAction)btnBlockedUsersAndSpammersTapped:(UIButton *)sender {
    
    C411SpammedUsersListVC *spammedUsersListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411SpammedUsersListVC"];
    [self.navigationController pushViewController:spammedUsersListVC animated:YES];
}

- (IBAction)sgcMetricSystemValueChanged:(UISegmentedControl *)sender {
    
    NSString *strSelectedMetric = nil;
    if (sender.selectedSegmentIndex == 0) {
        ///Miles is selected
        strSelectedMetric = kMetricSystemMiles;
    }
    else{
        
        ///Kilometers is selected
        strSelectedMetric = kMetricSystemKms;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ///Get the old metric chosen by user
    NSString *strOldMetricSystem = [defaults objectForKey:kMetricSystem];
    if (![strOldMetricSystem isEqualToString:strSelectedMetric]) {
        
#if PATROL_FEATURE_ENABLED
        float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
        
        ///Metric changed
        if ([strSelectedMetric isEqualToString:kMetricSystemKms]) {
            ///Metric changed to Kms
            patrolModeRadius = patrolModeRadius * MILES_TO_KM;
            NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
            self.lblCurrentPatrolRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:2],strMetric];
            
            self.sliderPatrolModeRadius.maximumValue = PATROL_MODE_MAX_RADIUS * MILES_TO_KM;
            
            self.lblPatrolRadiusRange.text = NSLocalizedString(@"(1-80 kms)", nil);
            [defaults setObject:kMetricSystemKms forKey:kMetricSystem];
            [defaults synchronize];
        }
        else{
            
            ///Metric changed to Miles
            NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
            self.lblCurrentPatrolRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:2],strMetric];
            self.sliderPatrolModeRadius.maximumValue = PATROL_MODE_MAX_RADIUS;
            self.lblPatrolRadiusRange.text = NSLocalizedString(@"(1-50 miles)", nil);
            [defaults setObject:kMetricSystemMiles forKey:kMetricSystem];
            [defaults synchronize];
            
        }
        
        self.sliderPatrolModeRadius.value = patrolModeRadius;
#else
        ///Metric changed
        if ([strSelectedMetric isEqualToString:kMetricSystemKms]) {
            [defaults setObject:kMetricSystemKms forKey:kMetricSystem];
            [defaults synchronize];
        }
        else{
            
            ///Metric changed to Miles
            [defaults setObject:kMetricSystemMiles forKey:kMetricSystem];
            [defaults synchronize];
            
        }

        
#endif
    }
    
}

- (IBAction)btnConnectToFacebookTapped:(UIButton *)sender {

}


- (IBAction)btnDisconnectFromFacebookTapped:(UIButton *)sender {

#if FB_ENABLED

    ///1. Show confirmation alert
// //    NSString *strMessage = NSLocalizedString(@"Are you sure you want to disconnect your account from Facebook? App will no longer be able to publish alerts or stream live video to your Facebook wall.", nil);
    NSString *strMessage = NSLocalizedString(@"Are you sure you want to disconnect your account from Facebook?", nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

        ///Do anything required on No action

        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];

    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        ///2. on Yes, Unlink the current user from facebook
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        __weak typeof(self) weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [PFFacebookUtils unlinkUserInBackground:currentUser block:^(BOOL succeeded, NSError * _Nullable error) {

            ///3. if success,clear access token, turn off Publish to Facebook option as well and hide the disconnect button and show the connect to facebook option again

            ///hide progress hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

            if (!error) {

                if (succeeded) {

                    ///3.1 clear access token
                    [FBSDKAccessToken setCurrentAccessToken:nil];

//                    ///3.2 turn off Publish to Facebook option
//                    [weakSelf togglePublishToFacebookWallOption:NO];
//
////                    ///3.2 turn off Stream Video to Facebook option
////                    [weakSelf toggleStreamVideoOnFacebookOption:NO];

                    ///3.4 hide the disconnect button
                    [weakSelf hideDisconnectFromFacebookButton];

                }
                else{
                    ///show toast
                    [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Some error occurred, try again later.", nil)];

                }

            }
            else{

                ///show error
                [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];

            }



        }];

        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];

    [alertController addAction:noAction];
    [alertController addAction:yesAction];
    //[self presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

#endif

}

- (IBAction)btnVideoSettingsTapped:(UIButton *)sender {

#if VIDEO_STREAMING_ENABLED
    C411VideoSettingsVC *videoSettingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411VideoSettingsVC"];
    [self.navigationController pushViewController:videoSettingsVC animated:YES];
   
#endif
    
}

- (IBAction)btnAdvancedPanicSettingsTapped:(UIButton *)sender {
    
#if IS_PANIC_BUTTON_ENABLED
    C411PanicAlertAdvancedSettingsVC *panicAlertAdvancedSettingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PanicAlertAdvancedSettingsVC"];
    [self.navigationController pushViewController:panicAlertAdvancedSettingsVC animated:YES];
#endif
  
}
                                       
- (IBAction)btnRideRequestsToggled:(UIButton *)sender {
    
#if RIDE_HAILING_ENABLED
    __weak typeof(self) weakSelf = self;
    BOOL isRideRequestsAlertOn = (self.shouldEnableRideRequestsOnLocationAllowed) ? YES : (!sender.isSelected);
    if(!self.shouldEnableRideRequestsOnLocationAllowed){
        [self toggleButton:sender toSelected:isRideRequestsAlertOn];
        ///Disable Rede Requests switch
        sender.enabled = NO;
        sender.alpha = 0.6;
    }
    
    if (isRideRequestsAlertOn) {
        
        ///Check if location access is allowed or not
        if(![[C411LocationManager sharedInstance]isLocationAccessAllowed]){
            ///Location access is not allowed, show enable location popup and return
            NSString *strMsgPrefix = [NSString localizedStringWithFormat: NSLocalizedString(@"Turning on Ride Requests requires %@ to access your location.", nil), LOCALIZED_APP_NAME];
            [[C411LocationManager sharedInstance]showEnableLocationPopupWithCustomMessagePrefix:strMsgPrefix cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                ///User cancelled to enable location
                ///reenable switches and deselect it back
                sender.enabled = YES;
                sender.alpha = 1.0;
                [weakSelf toggleButton:sender toSelected:NO];
                
            } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                ///User initiated to Enable location access, set the flag to enable this feature when location is enabled
                weakSelf.enableRideRequestsOnLocationAllowed = YES;
                [weakSelf registerForForegroundNotification];
            }];
            
            return;
        }
        
        ///Disable location update switch as well, as it needs to be set on as well if ride requests is enabled successfully
        self.tglBtnLocationUpdates.enabled = NO;
        self.tglBtnLocationUpdates.alpha = 0.6;
        
    }
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSNumber *rideRequestsAlertValue = [NSNumber numberWithBool:isRideRequestsAlertOn];
    
    currentUser[kUserRideRequestAlertKey] = rideRequestsAlertValue;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        ///reenable switches
        sender.enabled = YES;
        sender.alpha = 1.0;
        if (isRideRequestsAlertOn) {
            ///Enable location update switch as well
            weakSelf.tglBtnLocationUpdates.enabled = YES;
            weakSelf.tglBtnLocationUpdates.alpha = 1.0;
        }
        if (!succeeded) {
            
            ///some error occured updating Ride Request Alert value on parse, toggle switch back to original position
            [weakSelf toggleButton:sender toSelected:!isRideRequestsAlertOn];
        }
        else{
            
            if (isRideRequestsAlertOn) {
                ///User has enabled Ride Requests, so enable location update switch as well if it is off
                if (!weakSelf.tglBtnLocationUpdates.isSelected) {
                    
                    [weakSelf toggleButton:weakSelf.tglBtnLocationUpdates toSelected:YES];
                    [weakSelf toggleLocationUpdateWithValue:YES];
                }
                ///Show toast for enabled
                [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Ride Requests Enabled", nil)];

            }
            else{
                
                ///Show toast for disabled
                [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Ride Requests Disabled", nil)];

            }
        }
        
    }];

    
#endif
    
}

- (IBAction)btnRideSettingsTapped:(UIButton *)sender {
#if RIDE_HAILING_ENABLED
    
    C411RideSettingsVC *rideSettingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RideSettingsVC"];
    [self.navigationController pushViewController:rideSettingsVC animated:YES];

#endif

}

- (IBAction)btnUploadContactsToggled:(UIButton *)sender {
    
#if IS_CONTACTS_SYNCING_ENABLED
    
    BOOL isContactSyncingOn = !sender.isSelected;
    
    if(isContactSyncingOn){
        
        ///Push the upload contacts VC
        C411UploadContactsVC *uploadContactsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411UploadContactsVC"];
        uploadContactsVC.parentVC = self;
        [self.navigationController pushViewController:uploadContactsVC animated:YES];
    }
    else{
        
        ///Toggle it to off
        [self toggleButton:sender toSelected:isContactSyncingOn];
        
        ///Show the confirmation alert to user
        NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Previously uploaded contacts will be deleted and you will no longer get notification when someone joins %@.",nil),LOCALIZED_APP_NAME];
        UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            ///User taps cancel, so do not turn off contact syncing, set the switch value back to on again
            [self toggleButton:sender toSelected:YES];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *disableAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Disable", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            ///Disable Upload contacts switch
            sender.enabled = NO;
            sender.alpha = 0.6;
            __weak typeof(self) weakSelf = self;
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            NSNumber *syncContactValue = @0;
            
            currentUser[kUserSyncContactsKey] = syncContactValue;
            
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                
                ///reenable switches
                sender.enabled = YES;
                sender.alpha = 1.0;
                
                if (!succeeded) {
                    
                    ///some error occured updating SyncContact value on parse, toggle switch back to original position
                    [weakSelf toggleButton:sender toSelected:YES];
                }
                else{
                    
                    
                    ///Show toast for disabled
                    [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Upload Contacts Disabled", nil)];
                    
                    ///Delete contacts as well and show the toast of it
                    [C411StaticHelper deleteContactsWithCompletion:^(id  _Nullable object, NSError * _Nullable error) {
                        
                        if (!error) {
                            
                            [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Contacts deleted successfully", nil)];
                        }
                        else{
                            
                            NSLog(@"Some error occurred deleting contacts:%@",error.localizedDescription);
                            
                        }
                        
                    }];
                    
                    
                }
            
             
             }];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        
        [confirmAlert addAction:cancelAction];
        [confirmAlert addAction:disableAction];
        //[self presentViewController:confirmAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmAlert];
        
        
    }
    
#endif

}

- (IBAction)btnDarkModeToggled:(UIButton *)sender {
#if IS_DARK_MODE_ENABLED
    BOOL isOn = !sender.isSelected;
    [self toggleButton:sender toSelected:isOn];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:kDarkMode];
    [defaults synchronize];
    if (isOn) {
        
        ///Show toast for enabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Dark Mode Enabled", nil)];
        
    }
    else{
        ///Show toast for disabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Dark Mode Disabled", nil)];
        
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:kDarkModeValueChangedNotification object:nil];
    
    // Trigger selection feedback.
    [self.feedbackGenerator impactOccurred];
    
    // Keep the generator in a prepared state.
    //[self.feedbackGenerator prepare];
#endif
}

- (IBAction)btnLocationUpdatesToggled:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    BOOL isOn = (self.shouldEnableLocationUpdatesOnLocationAllowed) ? YES : (!sender.isSelected);
    if(!self.shouldEnableLocationUpdatesOnLocationAllowed){
        [self toggleButton:sender toSelected:isOn];
    }
    
    if (isOn) {
        ///Check if location access is allowed or not
        if(![[C411LocationManager sharedInstance]isLocationAccessAllowed]){
            ///Location access is not allowed, show enable location popup and return
            NSString *strMsgPrefix = [NSString localizedStringWithFormat: NSLocalizedString(@"Turning on Location Updates requires %@ to access your location.", nil), LOCALIZED_APP_NAME];
            [[C411LocationManager sharedInstance]showEnableLocationPopupWithCustomMessagePrefix:strMsgPrefix cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                ///User cancelled to enable location
                ///deselect it back
                [weakSelf toggleButton:sender toSelected:NO];
                
            } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
                ///User initiated to Enable location access, set the flag to enable this feature when location is enabled
                weakSelf.enableLocationUpdatesOnLocationAllowed = YES;
                [weakSelf registerForForegroundNotification];
            }];
            
            return;
        }
        
        ///User is trying to turn on the location update,then let him do
        [self toggleLocationUpdateWithValue:YES];
        
        ///Show toast for enabled
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Location Updates Enabled", nil)];
        
    }
    else{
        
        ///User is trying to turn off the location update
        NSString *strMessage = nil;
#if (PATROL_FEATURE_ENABLED && RIDE_HAILING_ENABLED)
        if (self.tglBtnPatrolMode.isSelected
            && self.tglBtnNewPublicCellAlert.isSelected
            && self.tglBtnRideRequests.isSelected) {
            
            ///If patrol mode is on, new public cell alert is on and ride requests is also on then show the alert that Turning location updates off will also disable Patrol Mode, New Public Cell Alert and Ride Requests. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Patrol Mode, New Public Cell Alert and Ride Requests. Do you still want to turn it off?", nil);
            
            
        }
        else if (self.tglBtnPatrolMode.isSelected && self.tglBtnNewPublicCellAlert.isSelected) {
            
            ///If patrol mode is on and new public cell alert is also on then show the alert that Turning location updates off will also disable Patrol Mode and New Public Cell Alert. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Patrol Mode and New Public Cell Alert. Do you still want to turn it off?", nil);
        }
        else if (self.tglBtnPatrolMode.isSelected && self.tglBtnRideRequests.isSelected) {
            
            ///If patrol mode is on and ride requests is also on then show the alert that Turning location updates off will also disable Patrol Mode and Ride Requests. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Patrol Mode and Ride Requests. Do you still want to turn it off?", nil);
        }
        else if (self.tglBtnRideRequests.isSelected && self.tglBtnNewPublicCellAlert.isSelected) {
            ///If ride requests is on and new public cell alert is also on then show the alert that Turning location updates off will also disable Ride Requests and New Public Cell Alert. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Ride Requests and New Public Cell Alert. Do you still want to turn it off?", nil);
        }
        else if (self.tglBtnPatrolMode.isSelected) {
            
            ///If patrol mode is on then show the alert that Turning location updates off will also disable Patrol Mode. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Patrol Mode. Do you still want to turn it off?", nil);
         }
        else if (self.tglBtnNewPublicCellAlert.isSelected) {
            ///If New Public Cell Alert is on then show the alert that Turning location updates off will also disable New Public Cell Alert. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable New Public Cell Alert. Do you still want to turn it off?", nil);
            
        }
        else if (self.tglBtnRideRequests.isSelected) {
            ///If ride requests is on then show the alert that Turning location updates off will also disable Ride Requests. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Ride Requests. Do you still want to turn it off?", nil);
        }
#elif PATROL_FEATURE_ENABLED
        if (self.tglBtnPatrolMode.isSelected && self.tglBtnNewPublicCellAlert.isSelected) {
            
            ///If patrol mode is on and new public cell alert is also on then show the alert that Turning location updates off will also disable Patrol Mode and New Public Cell Alert. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Patrol Mode and New Public Cell Alert. Do you still want to turn it off?", nil);
            
            
        }
        else if (self.tglBtnPatrolMode.isSelected) {
            
            ///If patrol mode is on then show the alert that Turning location updates off will also disable Patrol Mode. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Patrol Mode. Do you still want to turn it off?", nil);
            
        }
        else if (self.tglBtnNewPublicCellAlert.isSelected) {
            ///If New Public Cell Alert is on then show the alert that Turning location updates off will also disable New Public Cell Alert. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable New Public Cell Alert. Do you still want to turn it off?", nil);
            
        }
#elif RIDE_HAILING_ENABLED
        if (self.tglBtnRideRequests.isSelected && self.tglBtnNewPublicCellAlert.isSelected) {
            ///If ride requests is on and new public cell alert is also on then show the alert that Turning location updates off will also disable Ride Requests and New Public Cell Alert. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Ride Requests and New Public Cell Alert. Do you still want to turn it off?", nil);
        }
        else if (self.tglBtnRideRequests.isSelected) {
            ///If ride requests is on then show the alert that Turning location updates off will also disable Ride Requests. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable Ride Requests. Do you still want to turn it off?", nil);
        }
        else if (self.tglBtnNewPublicCellAlert.isSelected) {
            ///If New Public Cell Alert is on then show the alert that Turning location updates off will also disable New Public Cell Alert. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable New Public Cell Alert. Do you still want to turn it off?", nil);
            
        }
#else
        if (self.tglBtnNewPublicCellAlert.isSelected) {
            ///If New Public Cell Alert is on then show the alert that Turning location updates off will also disable New Public Cell Alert. Do you still want to turn it off?
            strMessage = NSLocalizedString(@"Turning location updates off will also disable New Public Cell Alert. Do you still want to turn it off?", nil);
            
        }
#endif
        
        else{
            
            ///If patrol mode is off, then let the user turn off the location update
            [self toggleLocationUpdateWithValue:NO];
            
            ///Show toast for disabled
            [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Location Updates Disabled", nil)];
            
        }
        
        if (strMessage.length > 0) {
            
            ///show alert
            UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                ///User taps cancel, so do not turn off location update, set the switch value back to on again
                [self toggleButton:self.tglBtnLocationUpdates toSelected:YES];
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];
                
            }];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                ///user tapped ok, that means user want to turn off location update as well as patrol mode, New Public Cell Alert and ride requests.
                ///1. disable patrol mode, New Public Cell Alert and Ride Requests
                self.tglBtnLocationUpdates.enabled  = NO;
                self.tglBtnLocationUpdates.alpha = 0.6;
                self.tglBtnPatrolMode.enabled = NO;
                self.tglBtnPatrolMode.alpha = 0.6;
                self.tglBtnNewPublicCellAlert.enabled = NO;
                self.tglBtnNewPublicCellAlert.alpha = 0.6;
                self.tglBtnRideRequests.enabled = NO;
                self.tglBtnRideRequests.alpha = 0.6;
                PFBooleanResultBlock completion = ^(BOOL succeeded, NSError *error) {
                    ///reenable switches
                    weakSelf.tglBtnLocationUpdates.enabled  = YES;
                    weakSelf.tglBtnLocationUpdates.alpha = 1.0;
                    weakSelf.tglBtnPatrolMode.enabled = YES;
                    weakSelf.tglBtnPatrolMode.alpha = 1.0;
                    weakSelf.tglBtnNewPublicCellAlert.enabled = YES;
                    weakSelf.tglBtnNewPublicCellAlert.alpha = 1.0;
                    weakSelf.tglBtnRideRequests.enabled = YES;
                    weakSelf.tglBtnRideRequests.alpha = 1.0;
                    
                    if (succeeded) {
                        
                        ///Patrol mode, new public cell alert and ride requests disabled successfully on parse
                        
                        ///2. set new public cell alert switch to off
                        [weakSelf toggleButton:weakSelf.tglBtnNewPublicCellAlert toSelected:NO];
                        
#if PATROL_FEATURE_ENABLED
                        ///2. set patrol mode switch to off
                        [weakSelf toggleButton:weakSelf.tglBtnPatrolMode toSelected:NO];
                        
                        ///3. notify the observers
//                        [[NSNotificationCenter defaultCenter]postNotificationName:kPatrolModeValueChangedNotification object:@(NO)];
                        
#endif
#if RIDE_HAILING_ENABLED
                        ///3. set ride requests switch to off
                        [weakSelf toggleButton:weakSelf.tglBtnRideRequests toSelected:NO];
                        
#endif

//                        [[NSNotificationCenter defaultCenter]postNotificationName:kNewPublicCellCreationAlertValueChangedNotification object:@(NO)];
                        
                        ///4. set loaction update value to off on defaults and notify the observers
                        [weakSelf toggleLocationUpdateWithValue:NO];
                        
                        ///Show toast for disabled
                        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Location Updates Disabled", nil)];
                        
                    }
                    else{
                        
                        ///Some error occured disabling patrol mode on parse, so reenable the location update switch
                        [weakSelf toggleButton:weakSelf.tglBtnLocationUpdates toSelected:YES];
                        
                        
                    }
                    
                    
                };
                
                PFUser *currentUser = [AppDelegate getLoggedInUser];
#if PATROL_FEATURE_ENABLED
                currentUser[kUserPatrolModeKey] = PATROL_MODE_VALUE_OFF;
#endif
#if RIDE_HAILING_ENABLED
                ///3. set ride requests switch to off
                currentUser[kUserRideRequestAlertKey] = [NSNumber numberWithBool:NO];
#endif
                currentUser[kUserNewPublicCellAlertKey] = NEW_PUBLIC_CELL_ALERT_VALUE_OFF;
                
                [currentUser saveInBackgroundWithBlock:completion];
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];
                
            }];
            
            [confirmAlert addAction:cancelAction];
            [confirmAlert addAction:okAction];
            //[self presentViewController:confirmAlert animated:YES completion:NULL];
            ///Enqueue the alert controller object in the presenter queue to be displayed one by one
            [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmAlert];
            
            
        }
        
    }
    
}

- (IBAction)btnDownloadMyDataTapped:(UIButton *)sender {
    
    ///Validate from server
    self.btnDownloadMyData.backgroundColor = [UIColor grayColor];
    NSDate *pastAllowedDate = [NSDate dateWithTimeIntervalSinceNow: (-1) * DOWNLOAD_DATA_TIME_LIMIT];
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getAppUserLogQuery = [PFQuery queryWithClassName:kAppUserLogClassNameKey];
    [getAppUserLogQuery whereKey:kAppUserLogUserKey equalTo:currentUser];
    [getAppUserLogQuery whereKey:kAppUserLogActionKey equalTo:@(kAppUserLogActionDownloaded)];
    [getAppUserLogQuery whereKey:@"createdAt" greaterThanOrEqualTo:pastAllowedDate];
    [getAppUserLogQuery orderByDescending:@"createdAt"];
    __weak typeof(self) weakSelf = self;
    ///Show progress HUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [getAppUserLogQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            ///Hide the progress HUD
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            ///User has already requested the download in the past and sufficient time has not been passed since then
            NSDate *lastDownloadDate = object.createdAt;
            NSInteger difference = [DateHelper daysBetweenDate:lastDownloadDate andDate:[NSDate date]];
            NSInteger downloadDataLimitInDays = DOWNLOAD_DATA_TIME_LIMIT / (24 * 60 * 60);
            NSString *strMsg = [NSString stringWithFormat:NSLocalizedString(@"You can only download data after %d days", nil), downloadDataLimitInDays - difference];
            [C411StaticHelper showAlertWithTitle:nil message:strMsg onViewController:weakSelf];
            sender.backgroundColor = [UIColor grayColor];
        }
        else if (error.code == kPFErrorObjectNotFound) {
            [sender setTitle:NSLocalizedString(@"Archiving your data...", nil) forState:UIControlStateNormal];
            [C411StaticHelper downloadMyDataWithCompletion:^(id  _Nullable object, NSError * _Nullable error) {
                ///Hide progress hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                ///Set button text back to download all my data
                [sender setTitle:NSLocalizedString(@"Download all my data", nil) forState:UIControlStateNormal];
                
                if (error) {
                    ///Show error
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                    ///3. Set button color back to primary color
                    sender.backgroundColor = [C411ColorHelper sharedInstance].primaryColor;
                    return;
                }
                ///Show success alert
                NSString *strSuccessMsg = NSLocalizedString(@"A link to your data archive will be soon sent to your e-mail address.\n(Please also look in your SPAM folder)", nil);
                [C411StaticHelper showAlertWithTitle:nil message:strSuccessMsg onViewController:weakSelf];
                ///Record data download time
                [[C411AppDefaults sharedAppDefaults]recordMyDataDownloadTime];
            }];
        }
        else {
            ///Some error occured show the error
            ///1. Hide progress hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            ///2. Show error
            [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
            ///3. Set button color back to primary color
            sender.backgroundColor = [C411ColorHelper sharedInstance].primaryColor;
        }
    }];
}

- (IBAction)btnDeleteMyAccountTapped:(UIButton *)sender {
    ///show confirmation alert
    NSString *strMessage = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete your %@ account? This action is irreversible.", nil),LOCALIZED_APP_NAME];
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///User taps no, so do nothing
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ///User agrees to delete his/her account, process with deleting the account
        ///Show progress HUD
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        ///Call cloud function to delete account
        [C411StaticHelper deleteMyAccountWithCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            ///Hide the progress hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (!error) {
                ///Account is deleted successfully
                [[AppDelegate sharedInstance]userDidLogout];
                
                ///Show toast
                [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Account Deleted", nil)];
                return;
            }
            
            ///Show error
            [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
        }];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [confirmAlert addAction:noAction];
    [confirmAlert addAction:yesAction];
    //[self presentViewController:confirmAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmAlert];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)userDidLinkedToFacebook:(NSNotification *)notif
{

}

-(void)contactSyncingEnabled:(NSNotification *)notif{

#if IS_CONTACTS_SYNCING_ENABLED
    
    [self toggleButton:self.tglBtnUploadContacts toSelected:YES];

#endif
    
}

-(void)locationBasedFeaturesTemporarilyDisabled:(NSNotification *)notif{
                                               
    [self initializeLocationDependentSettings];
                                               
}
  
-(void)locationBasedFeaturesReenabled:(NSNotification *)notif{
                                               
    [self initializeLocationDependentSettings];
                                               
}

-(void)cell411AppWillEnterForeground:(NSNotification *)notif
{
    ///Remove the foreground notification observer
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    if([[C411LocationManager sharedInstance] isLocationAccessAllowed]){
        ///Location access is allowed now
        if (self.shouldEnableNewPublicCellAlertOnLocationAllowed){
            ///Check if this service is temporarily disabled
            if([C411LocationManager isLocationDependentServiceTemporarilyDisabled:kTempDisabledServiceNewPublicCellAlert]){
                ///It will be automatically get enabled on notification just reenable switches
                self.tglBtnNewPublicCellAlert.enabled = YES;
                self.tglBtnNewPublicCellAlert.alpha = 1.0;
            }
            else{
                [self btnNewPublicCellAlertToggled:self.tglBtnNewPublicCellAlert];
            }
            ///Reset the ivar, should be done in last
            self.enableNewPublicCellAlertOnLocationAllowed = NO;
        }
#if PATROL_FEATURE_ENABLED
        else if(self.shouldEnablePatrolModeOnLocationAllowed){
            ///Check if this service is temporarily disabled
            if([C411LocationManager isLocationDependentServiceTemporarilyDisabled:kTempDisabledServicePatrolMode]){
                ///It will be automatically get enabled on notification just reenable switches
                self.tglBtnPatrolMode.enabled = YES;
                self.tglBtnPatrolMode.alpha = 1.0;
            }
            else{
                [self btnPatrolModeToggled:self.tglBtnPatrolMode];
            }
            ///Reset the ivar, should be done in last
            self.enablePatrolModeOnLocationAllowed = NO;
        }
#endif
#if RIDE_HAILING_ENABLED
        else if (self.shouldEnableRideRequestsOnLocationAllowed){
            ///Check if this service is temporarily disabled
            if([C411LocationManager isLocationDependentServiceTemporarilyDisabled:kTempDisabledServiceRideRequests]){
                ///It will be automatically get enabled on notification just reenable switches
                self.tglBtnRideRequests.enabled = YES;
                self.tglBtnRideRequests.alpha = 1.0;
            }
            else{
                [self btnRideRequestsToggled:self.tglBtnRideRequests];
            }
            ///Reset the ivar, should be done in last
            self.enableRideRequestsOnLocationAllowed = NO;
        }
#endif
        else if (self.shouldEnableLocationUpdatesOnLocationAllowed){
            ///Check if this service is temporarily disabled
            if([C411LocationManager isLocationDependentServiceTemporarilyDisabled:kTempDisabledServiceRideRequests]){
                ///It will be automatically get enabled on notification don't do anything else
            }
            else{
                [self btnLocationUpdatesToggled:self.tglBtnLocationUpdates];
            }
            ///Reset the ivar, should be done in last
            self.enableLocationUpdatesOnLocationAllowed = NO;
        }
    }
    else{
        ///Location access is still not allowed
        if (self.shouldEnableNewPublicCellAlertOnLocationAllowed){
            ///reenable switches and deselect it back
            self.tglBtnNewPublicCellAlert.enabled = YES;
            self.tglBtnNewPublicCellAlert.alpha = 1.0;
            [self toggleButton:self.tglBtnNewPublicCellAlert toSelected:NO];
            
            ///Reset the ivar, should be done in last
            self.enableNewPublicCellAlertOnLocationAllowed = NO;
            
            ///Show toast
            [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Cannot enable New Public Cell Alerts without location access.", nil)];
        }
#if PATROL_FEATURE_ENABLED
        else if(self.shouldEnablePatrolModeOnLocationAllowed){
            
            ///reenable switches and deselect it back
            self.tglBtnPatrolMode.enabled = YES;
            self.tglBtnPatrolMode.alpha = 1.0;
            [self toggleButton:self.tglBtnPatrolMode toSelected:NO];
            
            ///Reset the ivar, should be done in last
            self.enablePatrolModeOnLocationAllowed = NO;
            
            ///Show toast
            [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Cannot enable Patrol Mode without location access.", nil)];
        }
#endif
#if RIDE_HAILING_ENABLED
        else if (self.shouldEnableRideRequestsOnLocationAllowed){
            ///reenable switches and deselect it back
            self.tglBtnRideRequests.enabled = YES;
            self.tglBtnRideRequests.alpha = 1.0;
            [self toggleButton:self.tglBtnRideRequests toSelected:NO];
            
            ///Reset the ivar, should be done in last
            self.enableRideRequestsOnLocationAllowed = NO;
            
            ///Show toast
            [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Cannot enable Ride Requests without location access.", nil)];
        }
#endif
        else if (self.shouldEnableLocationUpdatesOnLocationAllowed){
            ///deselect it back
            [self toggleButton:self.tglBtnLocationUpdates toSelected:NO];
            
            ///Reset the ivar, should be done in last
            self.enableLocationUpdatesOnLocationAllowed = NO;
            
            ///Show toast
            [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Cannot enable Location Updates without location access.", nil)];

        }
    }
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}
@end
