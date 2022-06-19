//
//  C411EmergencyAlertPopup.m
//  cell411
//
//  Created by Milan Agarwal on 10/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411EmergencyAlertPopup.h"
#import <GoogleMaps/GoogleMaps.h>
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "UIButton+FAB.h"
#import "DateHelper.h"
//#import "ServerUtility.h"
#import "C411LocationManager.h"
#import <OpenInGoogleMaps/OpenInGoogleMapsController.h>
#import "AppDelegate.h"
#import "GoogleDirectionProvider.h"
#import "C411SendAlertPopupVC.h"
#import "C411AppDefaults.h"
#import "MAAlertPresenter.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ChatHelper.h"
#import "C411ChatVC.h"
#import "C411Enums.h"
#import "C411Alert.h"
#import "C411Audience.h"
#import "C411SendAlertVC.h"
#import "C411ColorHelper.h"
//#import <MBProgressHUD/MBProgressHUD.h>

#define ALERT_DATA_ADDITIONAL_NOTE_KEY     @"additionalNote"

@interface C411EmergencyAlertPopup ()<GoogleDirectionProviderDelegate,C411SendAlertPopupVCDelegate,C411SendAlertVCDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertHead;
@property (weak, nonatomic) IBOutlet UIView *vuAlertTag;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTag;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertIssuer;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblForwardedByHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertForwarderName;
@property (weak, nonatomic) IBOutlet UIView *vuCollapsedAlertDetails;
@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *vuBaseUserDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblUserDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblCollapsedVuHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblCollapsedVuHeaderData;
@property (weak, nonatomic) IBOutlet UIButton *btnExpand;
@property (weak, nonatomic) IBOutlet UIButton *btnForwardAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnCallEmergencyContact;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigate;
@property (weak, nonatomic) IBOutlet UIButton *btnCallAlertIssuer;
@property (weak, nonatomic) IBOutlet UIView *vuExpandedAlertDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblExpandedVuAdditionalNoteHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNote;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroupHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblAllergiesHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblAllergies;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherMedicalConditionsHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherMedicalConditions;
@property (weak, nonatomic) IBOutlet UIButton *btnCannotHelp;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnCollapse;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseAlert;
@property (weak, nonatomic) IBOutlet UIView *vuCollapseButtonTopSeparator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forwardAlertBtnHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callEmergencyContactBtnHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *vuAnonymousUserDetailsPopupBase;
@property (weak, nonatomic) IBOutlet UIView *vuAnonymousUserDetailsPopupContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblAnonymousUserDetailsPopupSubtitle;
@property (weak, nonatomic) IBOutlet UITextField *txtAnonymousUserName;
@property (weak, nonatomic) IBOutlet UIView *vuAnonymousUserNameSeparator;
@property (weak, nonatomic) IBOutlet UITextField *txtAnonymousUserAdditionalText;
@property (weak, nonatomic) IBOutlet UIView *vuAnonymousUserAdditionalTextSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btnSendAnonymousUserDetails;
@property (weak, nonatomic) IBOutlet UIView *vuExpandedMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *btnCollapseMap;
@property (weak, nonatomic) IBOutlet UIButton *btnExpandMap;
@property (weak, nonatomic) IBOutlet UILabel *lblAnonymousUserDetailsPopupTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAnonymousUserDetailsContainerViewVerticalCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsNavigateBtnLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsChatBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAlertBaseViewTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAlertBaseViewBS;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
- (IBAction)btnExpandTapped:(UIButton *)sender;
- (IBAction)btnCannotHelpTapped:(UIButton *)sender;
- (IBAction)btnAcceptTapped:(UIButton *)sender;
- (IBAction)btnForwardAlertTapped:(UIButton *)sender;
- (IBAction)btnCallEmergencyContactTapped:(UIButton *)sender;
- (IBAction)btnChatTapped:(UIButton *)sender;
- (IBAction)btnNavigateTapped:(UIButton *)sender;
- (IBAction)btnCallAlertIssuerTapped:(UIButton *)sender;
- (IBAction)btnCollapseTapped:(UIButton *)sender;
- (IBAction)btnCloseAlertTapped:(UIButton *)sender;
- (IBAction)btnSendAnonymousUserDetailsTapped:(UIButton *)sender;
- (IBAction)btnExpandMapTapped:(UIButton *)sender;
- (IBAction)btnCollapseMapTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;

@property (nonatomic, assign, getter=isInitialized) BOOL initialized;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSMapView *expandedMapView;
//@property (nonatomic, strong) NSURLSessionDataTask *getLocationTask;
@property (nonatomic, strong) GoogleDirectionProvider *directionSource;
@property (nonatomic, strong) C411SendAlertPopupVC *fwdAlertPopupVC;
//@property (nonatomic, assign, getter=isCrossTapped) BOOL crossTapped;
//@property (nonatomic, assign, getter=isResponedToAlert) BOOL respondedToAlert;

///anonymous user peoperties
@property (nonatomic, strong) NSString *strAnonymousUserName;
@property (nonatomic, assign, getter=shouldSetUserDistanceOnLocationUpdate) BOOL setUserDistanceOnLocationUpdate;

@end

@implementation C411EmergencyAlertPopup

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
    [self registerForNotifications];
    [C411StaticHelper removeOnScreenKeyboard];
}

-(void)dealloc
{
//    [self.getLocationTask cancel];
//    self.getLocationTask = nil;
    [self.directionSource reset];
    self.directionSource.directionDelegate = nil;
    self.directionSource = nil;
    [self unregisterFromNotifications];

}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    _alertPayload = alertPayload;
    
    if (!self.isInitialized) {
        
        [self initializeViewWithAlertPayload:alertPayload];
        self.initialized = YES;
        
    }
    
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)registerForNotifications
{
    [super registerForNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboarWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboarWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)configureViews
{
    ///Update constraints
    [self updateLayoutConstraints];
    
    ///Set corner radius
    self.vuAlertBase.layer.cornerRadius = 5.0;
    self.vuAlertTag.layer.cornerRadius = 2.0;
    self.vuBaseUserDistance.layer.cornerRadius = self.vuBaseUserDistance.bounds.size.height / 2;
    self.vuAnonymousUserDetailsPopupContainer.layer.cornerRadius = 5.0;
    self.btnExpand.layer.cornerRadius = 3.0;
    self.btnCallEmergencyContact.layer.cornerRadius = 3.0;
    self.btnForwardAlert.layer.cornerRadius = 3.0;
    self.btnCollapseMap.layer.cornerRadius = 3.0;
    self.btnCollapseMap.layer.masksToBounds = YES;
    self.btnExpandMap.layer.cornerRadius = 3.0;
    self.btnExpandMap.layer.masksToBounds = YES;

    self.btnExpand.layer.borderWidth = 1.0;
    self.btnCallEmergencyContact.layer.borderWidth = 1.0;
    self.btnForwardAlert.layer.borderWidth = 1.0;
    self.btnClose.layer.borderWidth = 1.0;
    
    ///make circular views
    [C411StaticHelper makeCircularView:self.imgVuAlertIssuer];
    [C411StaticHelper makeCircularView:self.btnClose];

    ///make fab buttons
    [self.btnNavigate makeFloatingActionButton];
    [self.btnCallAlertIssuer makeFloatingActionButton];
    [self.btnChat makeFloatingActionButton];
    
    ///Set initial strings for localization support
    self.lblForwardedByHeader.text = NSLocalizedString(@"FORWARDED BY", nil);
    self.lblAlertLocation.text = NSLocalizedString(@"Retreiving city...", nil);
    [self.btnExpand setTitle:NSLocalizedString(@"Expand", nil) forState:UIControlStateNormal];
    [self.btnForwardAlert setTitle:NSLocalizedString(@"Forward Alert", nil) forState:UIControlStateNormal];
    [self.btnCallEmergencyContact setTitle:NSLocalizedString(@"Call Emergency Contact", nil) forState:UIControlStateNormal];
    [self.btnCannotHelp setTitle:NSLocalizedString(@"Cannot Help", nil) forState:UIControlStateNormal];
    [self.btnAccept setTitle:NSLocalizedString(@"Accept", nil) forState:UIControlStateNormal];
    [self.btnCloseAlert setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    [self.btnCollapse setTitle:NSLocalizedString(@"Collapse", nil) forState:UIControlStateNormal];

    self.lblBloodGroupHeader.text = NSLocalizedString(@"BLOOD GROUP", nil);
    self.lblAllergiesHeader.text = NSLocalizedString(@"ALLERGIES", nil);
    self.lblOtherMedicalConditionsHeader.text = NSLocalizedString(@"OTHER MEDICAL CONDITIONS", nil);
    self.lblAnonymousUserDetailsPopupTitle.text = NSLocalizedString(@"Enter Your Name", nil);
    self.txtAnonymousUserName.placeholder = NSLocalizedString(@"Enter your name", nil);
    self.txtAnonymousUserAdditionalText.placeholder = NSLocalizedString(@"Additional text message if any", nil);
    
    [self.btnSendAnonymousUserDetails setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];

    [self applyColors];
}

-(void)updateMapStyle {
    self.mapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
    self.expandedMapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
}

-(void)applyColors {
    [self updateMapStyle];
    UIColor *fabSelectedColor = [C411ColorHelper sharedInstance].fabSelectedColor;;
    UIColor *fabShadowColor = [C411ColorHelper sharedInstance].fabShadowColor;
    UIColor *fabSelectedTintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
    self.btnChat.backgroundColor = fabSelectedColor;
    self.btnChat.layer.shadowColor = fabShadowColor.CGColor;
    self.btnChat.tintColor = fabSelectedTintColor;
    self.btnNavigate.backgroundColor = fabSelectedColor;
    self.btnNavigate.layer.shadowColor = fabShadowColor.CGColor;
    self.btnNavigate.tintColor = fabSelectedTintColor;
    self.btnCallAlertIssuer.backgroundColor = fabSelectedColor;
    self.btnCallAlertIssuer.layer.shadowColor = fabShadowColor.CGColor;
    self.btnCallAlertIssuer.tintColor = fabSelectedTintColor;

    ///set border color
    UIColor *whiteColor = [UIColor whiteColor];
    self.btnExpand.layer.borderColor = whiteColor.CGColor;
    self.btnCallEmergencyContact.layer.borderColor = [C411StaticHelper colorFromHexString:@"DB0002"].CGColor;
    self.btnForwardAlert.layer.borderColor = whiteColor.CGColor;
    UIColor *blackColor = [UIColor blackColor];
    self.btnClose.layer.borderColor = blackColor.CGColor;
    
    UIColor *crossButtonColor = [C411ColorHelper sharedInstance].popupCrossButtonColor;
    self.btnClose.backgroundColor = crossButtonColor;
    
    ///Set white BG color for emergency contact button
    self.btnCallEmergencyContact.backgroundColor = whiteColor;
    
    ///Set background color for anonymous popup
    self.vuAnonymousUserDetailsPopupContainer.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    ///Set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAnonymousUserDetailsPopupTitle.textColor = primaryTextColor;
    self.txtAnonymousUserName.textColor = primaryTextColor;
    self.txtAnonymousUserAdditionalText.textColor = primaryTextColor;
    
    ///set secondary text color
    self.lblAnonymousUserDetailsPopupTitle.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    
    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuAnonymousUserNameSeparator.backgroundColor = separatorColor;
    self.vuAnonymousUserAdditionalTextSeparator.backgroundColor = separatorColor;
    
    ///set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnSendAnonymousUserDetails setTitleColor:secondaryColor forState:UIControlStateNormal];
    
}

-(void)updateLayoutConstraints
{
    if (@available(iOS 11, *)) {
        ///Deactivate top and bottom constraint added via storyboard
        [NSLayoutConstraint deactivateConstraints:@[
                                                    self.cnsAlertBaseViewTS,
                                                    self.cnsAlertBaseViewBS
                                                    ]];

        ///Activate constraint using safeAreaLayoutGuide
        UILayoutGuide *guide = self.safeAreaLayoutGuide;
        NSLayoutConstraint *topConstraint = [self.vuAlertBase.topAnchor constraintEqualToAnchor:guide.topAnchor constant:42.0f];
        NSLayoutConstraint *bottomConstraint = [guide.bottomAnchor constraintEqualToAnchor:self.vuAlertBase.bottomAnchor constant:20.0f];
        
        [NSLayoutConstraint activateConstraints:@[
                                                  topConstraint,
                                                  bottomConstraint
                                                  ]];
    }
}

-(void)initializeViewWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    ///Handle alert seen
    [self handleAlertSeen];
    
    ///hide chat icon if it's expired
    [self handleChatIconVisibility];
    
    ///set the alert color
    UIColor *lightColor = [C411StaticHelper getColorForAlert:alertPayload.strAlertRegarding withColorType:ColorTypeLight];
    UIColor *darkColor = [C411StaticHelper getColorForAlert:alertPayload.strAlertRegarding withColorType:ColorTypeDark];
    
    self.vuAlertBase.backgroundColor = lightColor;
    self.vuCollapseButtonTopSeparator.backgroundColor = lightColor;
    self.vuCollapsedAlertDetails.backgroundColor = darkColor;
    self.vuExpandedAlertDetails.backgroundColor = darkColor;
    self.btnCannotHelp.backgroundColor = darkColor;
    self.btnAccept.backgroundColor = darkColor;
    self.btnCollapse.backgroundColor =  darkColor;
    self.btnCloseAlert.backgroundColor = darkColor;
    
    ///set the alert head image
    self.imgVuAlertHead.image = [self getAlertHeadImageForAlert:alertPayload.strAlertRegarding];
    
    ///create alert tag and handle it's visibility
    NSString *strTag = alertPayload.isGlobalAlert ? NSLocalizedString(@"GLOBAL ALERT", nil) : nil;
    if ([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyForwarded.lowercaseString] && alertPayload.strForwardedBy.length > 0) {
        
        if (!strTag) {
            strTag = NSLocalizedString(@"FORWARDED ALERT", nil);
        }
        else{
            
            ///append forwarded alert tag
            strTag = [strTag stringByAppendingFormat:@"\n%@",NSLocalizedString(@"FORWARDED ALERT", nil)];
        }

    }
    
    if (strTag.length > 0) {
        ///update the text on alert tag view
        self.lblAlertTag.text = strTag;
    }
    else{
    
        ///hide the alert tag view
        self.vuAlertTag.hidden = YES;
        
    }

    ///set alert time
    NSDate *alertIssuedDate = [NSDate dateWithTimeIntervalSince1970:(alertPayload.createdAtInMillis / 1000)];
    NSString *timeString = [[DateHelper sharedHelper]stringFromDate:alertIssuedDate withFormat:kDateFormatTimeInAMPM];
    self.lblAlertTime.text = timeString;
    
    ///set gravatar image
    [self setGravatarForUser:self.alertIssuer];
    
    ///set the alert title
    /*
    NSString *strAlertName = alertPayload.strAlertRegarding;
    if ([alertPayload.strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCopBlocking.lowercaseString]) {
        
        ///Rename Cop Blocking to Police Interaction in UI only
        strAlertName = NSLocalizedString(@"Police Interaction", nil);
    }
*/
    NSString *strAlertName = [C411StaticHelper getLocalizedAlertTypeStringFromString:alertPayload.strAlertRegarding];

    NSString *strAlertTitle = nil;
#if APP_CELL411
    strAlertTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 411 alert",nil),alertPayload.strFullName, strAlertName];
#elif APP_RO112
    strAlertTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 112 alert",nil),alertPayload.strFullName, strAlertName];
 
#else
    strAlertTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ alert",nil),alertPayload.strFullName, strAlertName];
 
#endif

    self.lblAlertTitle.text = strAlertTitle;
    
    ///set the forwarded by or cell name info if it's available
    if ([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyForwarded.lowercaseString] && alertPayload.strForwardedBy.length > 0) {
        
        ///set the forwarder person name
        self.lblAlertForwarderName.text = alertPayload.strForwardedBy;
        
        ///hide the forward alert button as a forwarded alert cannot be forwarded again
        self.forwardAlertBtnHeightConstraint.constant = 0;
        
        
    }
    else if (([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyCell.lowercaseString] || alertPayload.isDeepLinked) && alertPayload.strCellName.length > 0) {
        
        self.lblForwardedByHeader.text = NSLocalizedString(@"Cell Name", nil);
        self.lblAlertForwarderName.text = alertPayload.strCellName;
        
    }
    else{
        
        ///hide the details
        self.lblForwardedByHeader.text = nil;
        self.lblAlertForwarderName.text = nil;
        
    }
    
    if (self.alertPayload.isDeepLinked) {
        
        ///hide the forward alert button as an alert opened from facebook cannot be forwarded
        self.forwardAlertBtnHeightConstraint.constant = 0;

    }
    
    ///Hide emergency contact button if unavailable
    NSString *strEmergencyContactNumber = self.alertIssuer[kUserEmergencyContactNumberKey];
    if (!strEmergencyContactNumber || strEmergencyContactNumber.length == 0) {
        
        self.callEmergencyContactBtnHeightConstraint.constant = 0;
        
    }
    
    
    ///set the collapsed view header
    if (alertPayload.strAdditionalNote.length > 0) {
        
        ///set additional note as header
        self.lblCollapsedVuHeader.text = NSLocalizedString(@"ADDITIONAL NOTE", nil);
        
        ///set the additional Note
        self.lblCollapsedVuHeaderData.text = alertPayload.strAdditionalNote;
        
        ///show expand button
        self.btnExpand.hidden = NO;
        
    }
    else if ([alertPayload.strAlertRegarding.lowercaseString isEqualToString:kAlertTypeMedical.lowercaseString]) {
        
        ///Since additional note is not available and this is the medical alert so get the first available medical data and display it in place of additional note else clear additonal note header and data and hide the expand button
        NSString *strCollapsedVuHeader = nil;
        NSString *strCollapsedVuHeaderData = nil;
        
        ///Get the first available Medical Data
        NSString *strBloodType = self.alertIssuer[kUserBloodTypeKey];
        NSString *strAllergies = self.alertIssuer[kUserAllergiesKey];
        NSString *strOMC = self.alertIssuer[kUserOtherMedicalCondtionsKey];
        if (strBloodType.length > 0) {
            strCollapsedVuHeader = NSLocalizedString(@"BLOOD GROUP", nil);
            strCollapsedVuHeaderData = strBloodType;
        }
        else if (strAllergies.length > 0) {
            
            strCollapsedVuHeader = NSLocalizedString(@"ALLERGIES", nil);
            strCollapsedVuHeaderData = strAllergies;
        }
        else if (strOMC.length > 0) {
            
            strCollapsedVuHeader = NSLocalizedString(@"OTHER MEDICAL CONDITIONS", nil);
            strCollapsedVuHeaderData = strOMC;
        }
        
         ///set the values
        self.lblCollapsedVuHeader.text = strCollapsedVuHeader;
        self.lblCollapsedVuHeaderData.text = strCollapsedVuHeaderData;
        
        if (strCollapsedVuHeader.length > 0) {
            
            ///show expand button
            self.btnExpand.hidden = NO;
            
        }
        else{
            
            ///Hide expand button
            self.btnExpand.hidden = YES;
  
        }
        
    }
    else{
        
        ///clear additonal note header and data and hide the expand button
        self.lblCollapsedVuHeader.text = nil;
        self.lblCollapsedVuHeaderData.text = nil;
        self.btnExpand.hidden = YES;

    }
    
    ///retreive the location
    CLLocationCoordinate2D alertCoordinate = alertPayload.alertAddress.coordinate;
    if(alertPayload.alertAddress.strCity.length > 0){
        self.lblAlertLocation.text = alertPayload.alertAddress.strCity;
    }
    else{
        [self updateLocationUsingCoordinate:alertCoordinate];
    }
    
    ///set google map
    [self addGoogleMapWithAlertCoordinate:alertCoordinate andMarkerTitle:alertPayload.strFullName];

    ///set user distance
    ///1. set retrieving text initially
    self.lblUserDistance.text = NSLocalizedString(@"Retrieving...", nil);
    ///2. Retrieve distance based on user location
    if([[C411LocationManager sharedInstance]isLocationAccessAllowed]){
        ///Check if current location is updated or not, if not then wait for location update before setting the distance
        if([[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:NO]){
            ///Current location is available, set the user distance from the alert issuer
            [self setUserDistance];
        }
        else{
            ///Current location is not available, so wait for location update to set the user distance from the alert issuer
            [self setUserDistanceOnLocationUpdateAndObserveFG:YES];
        }
    }
    else if ([C411LocationManager sharedInstance].isShowingEnableLocationPopup){
        ///Enable location popup is already visible to user, observe cancel action of that popup to hide lblUserDistance in that case
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enableLocationPopupCancelTapped:) name:kEnableLocationPopupCancelTappedNotification object:nil];
        
        ///wait for location update to set the user distance from the alert issuer
        [self setUserDistanceOnLocationUpdateAndObserveFG:YES];

    }
    else{
        ///Location access is denied, show enable location popup
        __weak typeof(self) weakSelf = self;
        [[C411LocationManager sharedInstance]showEnableLocationPopupWithCustomMessagePrefix:nil cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
            ///Hide user distance view
            [weakSelf hideUserDistanceView];
            
            ///still wait for location update to set the user distance from the alert issuer without observing for coming to foreground as user distance view is already hidden
            [self setUserDistanceOnLocationUpdateAndObserveFG:NO];

        } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
            [self setUserDistanceOnLocationUpdateAndObserveFG:YES];
        }];
    }
    
    ///set the expanded view data if expand button is visible
    if (self.btnExpand.hidden == NO) {
        
        ///set additional note
        if (alertPayload.strAdditionalNote.length > 0) {
            
            ///set additional note as header
            self.lblExpandedVuAdditionalNoteHeader.text = NSLocalizedString(@"ADDITIONAL NOTE", nil);
            
            ///set the additional Note
            self.lblAdditionalNote.text = alertPayload.strAdditionalNote;
            
        }
        else{
            
            self.lblExpandedVuAdditionalNoteHeader.text = nil;
            self.lblAdditionalNote.text = nil;
            
        }
        
        ///set medical data if this is a medical alert
        if ([alertPayload.strAlertRegarding.lowercaseString isEqualToString:kAlertTypeMedical.lowercaseString]) {
        
            ///show blood group
            NSString *strBloodType = self.alertIssuer[kUserBloodTypeKey];
            if (strBloodType.length > 0) {
                
                self.lblBloodGroup.text = strBloodType;
            }
            else{
                
                self.lblBloodGroup.text = NSLocalizedString(@"N/A", nil);
            }
            
            ///show allergies
            NSString *strAllergies = self.alertIssuer[kUserAllergiesKey];
            if (strAllergies.length > 0) {
                
                self.lblAllergies.text = strAllergies;
            }
            else{
                
                self.lblAllergies.text = NSLocalizedString(@"N/A", nil);
            }
            
            ///show Other Medical Conditions
            NSString *strOMC = self.alertIssuer[kUserOtherMedicalCondtionsKey];
            if (strOMC.length > 0) {
                
                self.lblOtherMedicalConditions.text = strOMC;
            }
            else{
                
                self.lblOtherMedicalConditions.text = NSLocalizedString(@"N/A", nil);
            }

            
        }
        else{
            ///remove the medical details labels
            self.lblBloodGroupHeader.text = nil;
            self.lblBloodGroup.text = nil;
            self.lblAllergiesHeader.text = nil;
            self.lblAllergies.text = nil;
            self.lblOtherMedicalConditionsHeader.text = nil;
            self.lblOtherMedicalConditions.text = nil;
        }
    }
}

-(void)addGoogleMapWithAlertCoordinate:(CLLocationCoordinate2D)alertCoordinate andMarkerTitle:(NSString *)strMarkerTitle
{
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:alertCoordinate.latitude longitude:alertCoordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //self.mapView.mapType = kGMSTypeHybrid;
    [self.mapView animateToLocation:alertCoordinate];
    
    float hPadding = 20;
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.bounds.size.width - 2 * hPadding;
    self.mapView.frame = mapFrame;
    [self.vuMapPlaceholder addSubview:self.mapView];
    [self.vuMapPlaceholder sendSubviewToBack:self.mapView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ///update map frame to get the correct frame values
        [self updateMapFrame];
    });

    ///Add the marker to it and display title by default
    GMSMarker *alertMarker = [[GMSMarker alloc]init];
    alertMarker.position = alertCoordinate;
    alertMarker.title = strMarkerTitle;
    alertMarker.map = self.mapView;
    alertMarker.icon = [UIImage imageNamed:MAP_MARKER_ICON_NAME];

    [self updateMapStyle];

}

-(void)updateMapFrame
{
    float hPadding = 20;
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.bounds.size.width - 2 * hPadding;
    self.mapView.frame = mapFrame;
    
}

-(void)addExpandedGoogleMapWithAlertCoordinate:(CLLocationCoordinate2D)alertCoordinate andMarkerTitle:(NSString *)strMarkerTitle
{
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:alertCoordinate.latitude longitude:alertCoordinate.longitude zoom:15];
    self.expandedMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [self.expandedMapView animateToLocation:alertCoordinate];
    
    float hPadding = 20;
    CGRect mapFrame = self.vuExpandedMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.bounds.size.width - 2 * hPadding;
    self.expandedMapView.frame = mapFrame;
    [self.vuExpandedMapPlaceholder addSubview:self.expandedMapView];
    [self.vuExpandedMapPlaceholder sendSubviewToBack:self.expandedMapView];
    
    ///Add the marker to it and display title by default
    GMSMarker *alertMarker = [[GMSMarker alloc]init];
    alertMarker.position = alertCoordinate;
    alertMarker.title = strMarkerTitle;
    alertMarker.map = self.expandedMapView;
    alertMarker.icon = [UIImage imageNamed:MAP_MARKER_ICON_NAME];
    [self updateMapStyle];
}


-(UIImage *)getAlertHeadImageForAlert:(NSString *)strAlertRegarding
{
    NSString *strHeadImage = nil;
    
    if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeVehiclePulled.lowercaseString]) {
        
        strHeadImage = @"alert_head_pulled_over";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeArrested.lowercaseString]) {
        
        strHeadImage = @"alert_head_police_arrest";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeMedical.lowercaseString]) {
        
        strHeadImage = @"alert_head_medical";
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeVehicleBroken.lowercaseString]) {
        
        strHeadImage = @"alert_head_broken_car";
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCrime.lowercaseString]) {
        
        strHeadImage = @"alert_head_criminal";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeFire.lowercaseString]) {
        
        strHeadImage = @"alert_head_fire";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeDanger.lowercaseString]) {
        
        strHeadImage = @"alert_head_danger";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCopBlocking.lowercaseString]) {
        
        strHeadImage = @"alert_head_police_interaction";
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeBullied.lowercaseString]) {
        
        strHeadImage = @"alert_head_bullied";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeGeneral.lowercaseString]) {
        
        strHeadImage = @"alert_head_general";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeHijack.lowercaseString]) {
        
        strHeadImage = @"alert_head_hijack";

    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePanic.lowercaseString]) {
        
        strHeadImage = @"alert_head_panic";

    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeFallen.lowercaseString]) {
        
        strHeadImage = @"alert_head_fallen";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePhysicalAbuse.lowercaseString]) {
        
        strHeadImage = @"alert_head_physical_abuse";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeTrapped.lowercaseString]) {
        
        strHeadImage = @"alert_head_trapped";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeCarAccident.lowercaseString]) {
        
        strHeadImage = @"alert_head_broken_car";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypeNaturalDisaster.lowercaseString]) {
        
        strHeadImage = @"alert_head_natural_disaster";
        
    }
    else if ([strAlertRegarding.lowercaseString isEqualToString:kAlertTypePreAuthorisation.lowercaseString]) {
        
        strHeadImage = @"alert_head_pre_authorization";
        
    }
    else{
        
        strHeadImage = @"alert_head_un_recognized";
        
    }
    
    return [UIImage imageNamed:strHeadImage];
    
    
}

-(void)setGravatarForUser:(PFUser *)user
{

    ///get it's email and download the gravatar
    [self.imgVuAlertIssuer setAvatarForUser:user shouldFallbackToGravatar:YES ofSize:(self.imgVuAlertIssuer.bounds.size.width * 3) roundedCorners:NO withCompletion:NULL];
    
//    __weak typeof(self) weakSelf = self;
//    NSString *strEmail = [C411StaticHelper getEmailFromUser:user];
//    [C411StaticHelper getGravatarForEmail:strEmail ofSize:(self.imgVuAlertIssuer.bounds.size.width * 3) roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//                
//    
//        if (success && image) {
//                    
//        
//            weakSelf.imgVuAlertIssuer.image = image;
//                    
//            
//        }
//                
//        
//    }];

    
}


-(void)updateLocationUsingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    
    GMSGeocoder *geoCoder = [GMSGeocoder geocoder];
    __weak typeof(self) weakSelf = self;
    [geoCoder reverseGeocodeCoordinate:locCoordinate completionHandler:^(GMSReverseGeocodeResponse * _Nullable geoCodeResponse, NSError * _Nullable error) {
        
        if (!error && geoCodeResponse) {
            //NSLog(@"#Succeed: resp= %@\nerr=%@",geoCodeResponse,error);
            
            ///Get first available address
            GMSAddress *firstAddress = [geoCodeResponse firstResult];
            
            if (!firstAddress && ([geoCodeResponse results].count > 0)) {
                ///Additional handling to fallback to get address from array if in any case first result gives nil
                firstAddress = [[geoCodeResponse results]firstObject];
                
            }
            
            if(firstAddress){
                
                weakSelf.lblAlertLocation.text = firstAddress.locality;
            }
            else{
                
                weakSelf.lblAlertLocation.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        else{
            
            NSLog(@"#Failed: resp= %@\nerr=%@",geoCodeResponse,error);
        }
        
        
    }];
    
    
/*
    NSLog(@"%s",__PRETTY_FUNCTION__);
    ///cancel previous request
    [self.getLocationTask cancel];
    self.getLocationTask = nil;
    
    ///make a new request
    NSString *strLatLong = [NSString stringWithFormat:@"%f,%f",locCoordinate.latitude,locCoordinate.longitude];
    __weak typeof(self) weakSelf = self;
    
    self.getLocationTask = [ServerUtility getAddressForCoordinate:strLatLong andCompletion:^(NSError *error, id data) {
        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
        
        if (!error && data) {
            
            NSArray *results=[data objectForKey:kGeocodeResultsKey];
            
            if([results count]>0){
                
                NSDictionary *address=[results firstObject];
                NSArray *addcomponents=[address objectForKey:kGeocodeAddressComponentsKey];
                
                weakSelf.lblAlertLocation.text = [C411StaticHelper getAddressCompFromResult:addcomponents forType:kGeocodeTypeLocality useLongName:YES];
            }
            else{
                
                weakSelf.lblAlertLocation.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        
    }];
 */
    
}


-(void)showWorkingButton
{
    
    ///show close button with title as working... and disable interaction
    [self.btnCloseAlert setTitle:NSLocalizedString(@"Working...", nil) forState:UIControlStateNormal];
    self.userInteractionEnabled = NO;
    self.btnCloseAlert.hidden = NO;

}

-(void)hideWorkingButton
{
    self.userInteractionEnabled = YES;
    self.btnCloseAlert.hidden = YES;

}

-(void)showCloseButton
{
    ///update close title and enable interaction
    [self.btnCloseAlert setTitle:NSLocalizedString(@"CLOSE", nil) forState:UIControlStateNormal];
    self.userInteractionEnabled = YES;
    self.btnCloseAlert.hidden = NO;
    
//    ///Update the isRespondedToAlert flag to Yes
//    self.respondedToAlert = YES;
    
}

///This method will handle both cannot help and accept action.
///canHelp will hold YES if user tapped on ACCEPT button, and will hold NO if user tapped on CANNOT HELP button
-(void)handleUserResponseToAlertWithHelp:(BOOL)canHelp
{
    
    ///show working button
    [self showWorkingButton];

    __weak typeof(self) weakSelf = self;
    ///handle user actions
    C411AlertNotificationPayload *alertPayload = self.alertPayload;
    if (([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyForwarded.lowercaseString]
         ||([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyCell.lowercaseString])) && canHelp == NO) {
        
        ///1.Save current user in rejectedBy key on reject for forwarded alert or NEEDY_CELL alert(issued on public cell)
        PFObject *cell411Alert = self.cell411Alert;
        PFRelation *rejectedRelation = [cell411Alert relationForKey:kCell411AlertRejectedByKey];
        [rejectedRelation addObject:[AppDelegate getLoggedInUser]];
        
        ///Save it in background
        [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (error) {
                
                ///save it eventually if error occured
                [cell411Alert saveEventually];
                
            }
            
            ///hide working and show close button
            [weakSelf showCloseButton];
/*
            if (weakSelf.isCrossTapped) {
                
                ///Cross was tapped so close it without showing cross button
                [weakSelf btnCloseAlertTapped:weakSelf.btnCloseAlert];
                
            }
            else{
                
                
                ///hide working and show close button
                [weakSelf showCloseButton];
                
            }
 */
            
        }];
        
        /*
        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
        [getCell411AlertQuery selectKeys:@[kCell411AlertRejectedByKey]];
        [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error && objects.count > 0) {
                
                PFObject *cell411Alert = [objects firstObject];
                
                PFRelation *rejectedRelation = [cell411Alert relationForKey:kCell411AlertRejectedByKey];
                [rejectedRelation addObject:[AppDelegate getLoggedInUser]];
                
                ///Save it in background
                [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if (error) {
                    
                        ///save it eventually if error occured
                        [cell411Alert saveEventually];
                        
                    }
                    
                    if (self.isCrossTapped) {
                        
                        ///Cross was tapped so close it without showing cross button
                        [self btnCloseAlertTapped:self.btnCloseAlert];
                        
                    }
                    else{
                        
                        
                        ///hide working and show close button
                        [weakSelf showCloseButton];

                    }
                    
                }];
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error fetching cell411alert :%@",errorString);
                }
                
            }
            
            
            
        }];
         */
        
    }
    else{
        
        ///Show additional note by helper alert in case of NEEDY for both help or reject, or on Help in case of NEEDY_FORWARDED or NEEDY_CELL
        NSString *strAlertTitle = NSLocalizedString(@"Additional Note", nil);
        NSString *strMessage = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Do you want to send additional note to", nil),alertPayload.strFullName];
        NSString *strSend = NSLocalizedString(@"Send", nil);
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:strAlertTitle
                                              message:strMessage
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {

         }];
        
        UIAlertAction *sendAction = [UIAlertAction
                                       actionWithTitle:strSend
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           ///User tapped Send
                                           UITextField *txtAdditionalNote = alertController.textFields.firstObject;
                                           NSString *strAdditionalNote = txtAdditionalNote.text;
                                           if (strAdditionalNote.length > 0) {
                                               ///trim the white spaces
                                               strAdditionalNote = [strAdditionalNote stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                           }
                                           
                                           ///Check additional Note is provided or not
                                           if (strAdditionalNote.length > 0) {
                                               
                                              
                                               if (canHelp == NO) {
                                                   __weak typeof(self) weakSelf = self;
                                                   
                                                   ///User cannot help so save additional note on parse and send push notification
                                                   PFObject *responseAdditionalNote = [PFObject objectWithClassName:kAdditionalNoteClassNameKey];
                                                   responseAdditionalNote[kAdditionalNoteCell411AlertIdKey] = alertPayload.strCell411AlertId;
                                                   responseAdditionalNote[kAdditionalNoteNoteKey] = strAdditionalNote;
                                                   responseAdditionalNote[kAdditionalNoteSeenKey] = @(0); ///will be unseen initially
                                                   responseAdditionalNote[kAdditionalNoteAlertTypeKey] = kPayloadAlertTypeRejector;
                                                   
                                                   PFUser *currentUser = [AppDelegate getLoggedInUser];
                                                   responseAdditionalNote[kAdditionalNoteWriterIdKey] = currentUser.objectId;
                                                   NSString *strWriterName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                                                   responseAdditionalNote[kAdditionalNoteWriterNameKey] = strWriterName;
                                                   
                                                   [responseAdditionalNote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                                       
                                                       if (succeeded) {
                                                           
                                                           
                                                           ///additional note saved,
                                                                                                                 ///1. send can't help ack alert and push notification with additional note
                                                           [weakSelf sendRejectorAckAlertUsingAlertPayload:alertPayload additionalNoteId:responseAdditionalNote.objectId andAdditionalNote:strAdditionalNote];
                                                           
                                                           
                                                       }
                                                       else{
                                                           
                                                           if (error) {
                                                               if(![AppDelegate handleParseError:error]){
                                                                   ///show error
                                                                   NSString *errorString = [error userInfo][@"error"];
                                                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                                               }
                                                           }
                                                           
                                                       }
                                                       
                                                       
                                                   }];
                                                   
                                                   
                                               }
                                               else{
                                                   
                                                   ///User Initiated help to needy with additional note which is already added in dictionary above,show route using Google Directions API,make entry on additional note table, send helper ACK to needy and update cell411alert object by adding current user to initiatedAt
                                                   [self showRouteUsingAlertPayload:alertPayload andAdditionalNote:strAdditionalNote];
                                                   
                                               }
                                               
                                               
                                               
                                           }
                                           else{
                                               
                                               if (canHelp) {
                                                   
                                                   ///User Initiated help to needy but without additional note,show route using Google Directions API, send helper ACK to needy and update cell411alert object by adding current user to initiatedAt
                                                   [self showRouteUsingAlertPayload:alertPayload andAdditionalNote:nil];
                                                   
                                               }
                                               else{
                                                   
                                                   ///send can't help ack alert and push notification
                                                   [self sendRejectorAckAlertUsingAlertPayload:alertPayload additionalNoteId:nil andAdditionalNote:nil];
                                               }
                                               
                                           }

                                           ///Dequeue the current Alert Controller and allow other to be visible
                                           [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                           
                                           
                                       }];
        [alertController addAction:sendAction];
        //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

        
        
    }

    
}


-(void)sendHelperAckAlertUsingAlertPayload:(C411AlertNotificationPayload *)alertPayload additionalNote:(NSString *)strAdditionalNote andDuration:(NSString *)strDuration
{

    if (alertPayload) {
//        ///Make duration text
//        strDuration = strDuration.length > 0 ? strDuration : NSLocalizedString(@"few mins", nil);
        
        
        if (strAdditionalNote.length > 0) {
            ///If there is additional note then get it and its objectId
            
            __weak typeof(self) weakSelf = self;
            
            ///save additional note on parse
            PFObject *responseAdditionalNote = [PFObject objectWithClassName:kAdditionalNoteClassNameKey];
            responseAdditionalNote[kAdditionalNoteCell411AlertIdKey] = alertPayload.strCell411AlertId;
            responseAdditionalNote[kAdditionalNoteNoteKey] = strAdditionalNote;
            responseAdditionalNote[kAdditionalNoteSeenKey] = @(0); ///will be unseen initially
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            NSString *strWriterName = @"";
            if (currentUser) {
                ///alert opened by logged in user
                responseAdditionalNote[kAdditionalNoteWriterIdKey] = currentUser.objectId;
                strWriterName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                
            }
            else{
                ///alert opened by anonymous user, set user id as anonymous so that user can be shown that alert is responded by Facebook user
                responseAdditionalNote[kAdditionalNoteWriterIdKey] = kPayloadUserIdValueAnonymous;
                
                strWriterName = self.strAnonymousUserName;
                
            }
            
            if (alertPayload.isDeepLinked) {
                
                ///Set facebook as userType so that it can be shown at the other end
                responseAdditionalNote[kAdditionalNoteUserTypeKey] = kUserTypeFacebook;
                
            }

            responseAdditionalNote[kAdditionalNoteWriterNameKey] = strWriterName;
//            responseAdditionalNote[kAdditionalNoteWriterDurationKey] = strDuration;
            if(strDuration.length > 0){
                responseAdditionalNote[kAdditionalNoteWriterDurationKey] = strDuration;
            }
            responseAdditionalNote[kAdditionalNoteAlertTypeKey] = kPayloadAlertTypeHelper;
            if (alertPayload.strForwardedBy.length > 0) {
                ///Added forwardedBy person name if available, which will only be available in case of NEEDY_FORWARDED alert for now
                responseAdditionalNote[kAdditionalNoteForwardedByKey] = alertPayload.strForwardedBy;
            }
            if (([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyCell.lowercaseString]) || (alertPayload.isDeepLinked && alertPayload.strCellName.length > 0)) {
                
                ///This is a public alert or public alert opened through Facebook, add the cellId and cellName of public Cell
                if (alertPayload.strCellId.length > 0) {
                    responseAdditionalNote[kAdditionalNoteCellIdKey] = alertPayload.strCellId;
                    
                }
                
                responseAdditionalNote[kAdditionalNoteCellNameKey] = alertPayload.strCellName;
                
                
            }
            [responseAdditionalNote saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                
                if (succeeded) {
                    
                    ///additional note saved,
                    
                    ///1. Make entry of initiatedBy on Cell411Alert table and then send push with additional note
                    [weakSelf saveHelpInitiatedAndSendPushUsingAlertPayload:alertPayload additionalNoteId:responseAdditionalNote.objectId additionalNote:strAdditionalNote andDuration:strDuration];
                    
                    
                    
                }
                else{
                    
                    if (error) {
                        if(![AppDelegate handleParseError:error]){
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        }
                    }
                    
                    
                }
                
                
            }];
            
        }
        else{
            ///Make entry of initiatedBy on Cell411Alert table and then send push without additional note
            [self saveHelpInitiatedAndSendPushUsingAlertPayload:alertPayload additionalNoteId:nil additionalNote:strAdditionalNote andDuration:strDuration];
            
        }
        
        
        
    }
}

-(void)saveHelpInitiatedAndSendPushUsingAlertPayload:(C411AlertNotificationPayload *)alertPayload additionalNoteId:(NSString *)strAdditionalNoteId additionalNote:(NSString *)strAdditionalNote andDuration:(NSString *)strDuration
{
    ///get saved alert payload
    if (alertPayload) {
//        ///Make duration text
//        strDuration = strDuration.length > 0 ? strDuration : NSLocalizedString(@"few mins", nil);
        ///1.Send helper ack notification
        ///1.1Generate Ack Message
        NSString *strAckMessage = nil;
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *currentUserFullName = nil;
        if (currentUser) {
            
            ///Alert responded by logged in user
            NSString *currentUserFirstName = currentUser[kUserFirstnameKey];
            NSString *currentUserLastName = currentUser[kUserLastnameKey];
            //        NSString *strAckMessage = [NSString stringWithFormat:@"%@ %@ is %@ away and is on the way to help you out.",currentUserFirstName,currentUserLastName,strDuration];
            currentUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUserFirstName andLastName:currentUserLastName];
            if (alertPayload.isDeepLinked) {
                
                ///Append a facebook user to name as well if help is initiated by logged in user so that it can be shown at the other end
                strAckMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, a Facebook user is on the way to help you out!",nil),currentUserFullName];
                
            }
            else{
                
                strAckMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is on the way to help you out!",nil),currentUserFullName];

            }


        }
        else{
            
            ///Alert responded by non logged in(anonymous) user, create the ack message through ivars
            currentUserFullName = self.strAnonymousUserName;
            strAckMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, a Facebook user is on the way to help you out!",nil),currentUserFullName];

        }

        ///1.2 Create Payload data
        NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
        
        if ([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyCell.lowercaseString] || (alertPayload.isDeepLinked && alertPayload.strCellName.length > 0)) {
            
            ///This is a public alert or public alert opened through Facebook, add the cellId and cellName of public Cell to the payload
            if (alertPayload.strCellId.length > 0) {
                
                dictData[kPayloadCellIdKey] = alertPayload.strCellId;
                
            }
            dictData[kPayloadCellNameKey] = alertPayload.strCellName;
            
            if (!alertPayload.isDeepLinked) {
                ///update ackMessage to include cell info if it's not opened through Facebook
                strAckMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, a member of %@ is on the way to help you out!",nil),currentUserFullName,alertPayload.strCellName];

            }
        }
        
        if (alertPayload.strForwardedBy.length > 0) {
            ///Add forwardedBy person name if available, which will only be available in case of NEEDY_FORWARDED for now
            dictData[kPayloadForwardedByKey] = alertPayload.strForwardedBy;
            
            ///update ackMessage
            strAckMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, a friend of %@ is on the way to help you out!",nil),currentUserFullName,alertPayload.strForwardedBy];
            
        }
        
        dictData[kPayloadAlertKey] = strAckMessage;
        dictData[kPayloadUserIdKey] = currentUser ? currentUser.objectId : kPayloadUserIdValueAnonymous;///set anonymous as user id if current user is nil i.e alert is opened through Facebook and no user is currently logged in
        dictData[kPayloadCreatedAtKey] = @(alertPayload.createdAtInMillis);
        dictData[kPayloadNameKey] = currentUserFullName;
//        dictData[kPayloadDurationKey] = strDuration;
        if(strDuration.length > 0){
            dictData[kPayloadDurationKey] = strDuration;
        }
        dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeHelper;
        dictData[kPayloadSoundKey] = @"default";///To play default sound
        if (strAdditionalNote.length > 0) {
            ///add additional note if its there
            dictData[kPayloadAdditionalNoteKey] = strAdditionalNote;
        }
        
        if (strAdditionalNoteId.length > 0) {
            ///add additional note ID if its there
            dictData[kPayloadAdditionalNoteIdKey] = strAdditionalNoteId;
        }
        if (alertPayload.isDeepLinked) {
            
            ///Set facebook as userType so that it can be shown at the other end
            dictData[kPayloadUserTypeKey] = kUserTypeFacebook;
            
        }

        dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
        
        // Create our Installation query
        PFQuery *pushQuery = [PFInstallation query];
        PFQuery *innerQuery = [PFUser query];
        [innerQuery whereKey:@"objectId" equalTo:alertPayload.strUserId];
        [pushQuery whereKey:kInstallationUserKey matchesQuery:innerQuery];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setData:dictData];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            
            if (error) {
                
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error fetching cell411alert :%@",errorString);
                }
                
                
            }
            
        }];
        
        ///2.Save current user in initiatedBy key
        if (currentUser) {
            ///User is logged in, save current user in initiated by relation
            __weak typeof(self) weakSelf = self;
            PFObject *cell411Alert = self.cell411Alert;
            
            PFRelation *initiatedByRelation = [cell411Alert relationForKey:kCell411AlertInitiatedByKey];
            [initiatedByRelation addObject:[AppDelegate getLoggedInUser]];
            
            ///Save it in background
            [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    
                    ///save it eventually if error occured
                    [cell411Alert saveEventually];
                    
                }
                
                ///hide working and show close button
                [weakSelf showCloseButton];
                
            }];
            /*
            PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
            [getCell411AlertQuery selectKeys:@[kCell411AlertInitiatedByKey]];
            [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                
                if (!error && objects.count > 0) {
                    
                    PFObject *cell411Alert = [objects firstObject];
                    
                    PFRelation *initiatedByRelation = [cell411Alert relationForKey:kCell411AlertInitiatedByKey];
                    [initiatedByRelation addObject:[AppDelegate getLoggedInUser]];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                            
                        }
                        
                        ///hide working and show close button
                        [weakSelf showCloseButton];
                        
                    }];
                    
                    
                    
                    
                }
                else {
                    
                    if(![AppDelegate handleParseError:error]){
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"#error fetching cell411alert :%@",errorString);
                    }
                    
                }
                
                
                
            }];
             */

        }
        else{
            
            ///user is not logged in when this alert is opened, i.e the alert is opened through Facebook. Do not save anything on Parse for anonymous user. Do other tasks if it's required
            
            ///clear name saved in ivar
            self.strAnonymousUserName = nil;
            
            ///hide working and show close button
            [self showCloseButton];

        }
        
        
        
    }
}

-(void)sendRejectorAckAlertUsingAlertPayload:(C411AlertNotificationPayload *)alertPayload additionalNoteId:(NSString *)strAdditionalNoteId andAdditionalNote:(NSString *)strAdditionalNote
{
 
    if (alertPayload) {
        
        ///1.Send helper ack notification
        ///1.1Generate Ack Message
        
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *currentUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
        //        NSString *strAckMessage = [NSString stringWithFormat:@"%@ %@ is %@ away and is on the way to help you out.",currentUserFirstName,currentUserLastName,strDuration];
        NSString *strAckMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ can't help you this time.",nil),currentUserFullName];
        
        ///1.2 Create Payload data
        NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
        dictData[kPayloadAlertKey] = strAckMessage;
        dictData[kPayloadUserIdKey] = currentUser.objectId;
        dictData[kPayloadCreatedAtKey] = @(alertPayload.createdAtInMillis);
        dictData[kPayloadNameKey] = currentUserFullName;
        dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeRejector;
        dictData[kPayloadSoundKey] = @"default";///To play default sound
        if (strAdditionalNote.length > 0) {
            ///add additional note if its there
            dictData[kPayloadAdditionalNoteKey] = strAdditionalNote;
            dictData[kPayloadAdditionalNoteIdKey] = strAdditionalNoteId;
        }
        dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
        
        // Create our Installation query
        PFQuery *pushQuery = [PFInstallation query];
        PFQuery *innerQuery = [PFUser query];
        [innerQuery whereKey:@"objectId" equalTo:alertPayload.strUserId];
        [pushQuery whereKey:kInstallationUserKey matchesQuery:innerQuery];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setData:dictData];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            
            if (error) {
                
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error fetching cell411alert :%@",errorString);
                }
                
                
            }
            
        }];
        
        ///2.Save current user in rejectedBy key
        __weak typeof(self) weakSelf = self;
        PFObject *cell411Alert = self.cell411Alert;
        
        PFRelation *rejectedRelation = [cell411Alert relationForKey:kCell411AlertRejectedByKey];
        [rejectedRelation addObject:[AppDelegate getLoggedInUser]];
        
        ///Save it in background
        [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (error) {
                
                ///save it eventually if error occured
                [cell411Alert saveEventually];
                
            }
            
            ///hide working and show close button
            [weakSelf showCloseButton];

            /*
            if (self.isCrossTapped) {
                
                ///Cross was tapped so close it without showing cross button
                [self btnCloseAlertTapped:self.btnCloseAlert];
                
            }
            else{
                
                
                ///hide working and show close button
                [weakSelf showCloseButton];
                
            }
            */
            
        }];
        /*
        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
        [getCell411AlertQuery selectKeys:@[kCell411AlertRejectedByKey]];
        [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error && objects.count > 0) {
                
                PFObject *cell411Alert = [objects firstObject];
                
                PFRelation *rejectedRelation = [cell411Alert relationForKey:kCell411AlertRejectedByKey];
                [rejectedRelation addObject:[AppDelegate getLoggedInUser]];
                
                ///Save it in background
                [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if (error) {
                        
                        ///save it eventually if error occured
                        [cell411Alert saveEventually];
                        
                    }
                    
                    if (self.isCrossTapped) {
                        
                        ///Cross was tapped so close it without showing cross button
                        [self btnCloseAlertTapped:self.btnCloseAlert];
                        
                    }
                    else{
                        
                        
                        ///hide working and show close button
                        [weakSelf showCloseButton];
  
                    }
                    
                }];

                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error fetching cell411alert :%@",errorString);
                }
                
            }
            
            
            
        }];
         */
    }
}

-(void)showRouteUsingAlertPayload:(C411AlertNotificationPayload *)alertPayload andAdditionalNote:(NSString *)strAdditionalNote
{

    if (alertPayload) {
        
        if([[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:NO]){
            ///User location is available so get the ETA
            ///Get destination location
            CLLocation *destLocation = [[CLLocation alloc]initWithLatitude:alertPayload.alertAddress.coordinate.latitude longitude:alertPayload.alertAddress.coordinate.longitude];
            self.directionSource = [[GoogleDirectionProvider alloc] initWithDirectionsFromSourceLocation:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:NO].coordinate andDestinations:[@[destLocation]mutableCopy]];
            ///Add alert data object to be used when delegate callback is called
            NSMutableDictionary *dictAlertData = nil;
            if (strAdditionalNote.length > 0) {
                dictAlertData = [NSMutableDictionary dictionary];
                [dictAlertData setObject:strAdditionalNote forKey:ALERT_DATA_ADDITIONAL_NOTE_KEY];
            }
            self.directionSource.dictAlertData = dictAlertData;
            self.directionSource.directionDelegate = self;
            [self.directionSource startFetchingDirections];
        }
        else{
            ///User location is not available so send help acknowledgement without ETA
            [self sendHelperAckAlertUsingAlertPayload:alertPayload additionalNote:strAdditionalNote andDuration:nil];
        }
    }
    
}

-(void)showForwardAlertPopup
{
#if USE_OLD_AUDIENCE_SELECTION_POPUP
    self.fwdAlertPopupVC = [[AppDelegate sharedInstance].window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"C411SendAlertPopupVC"];
    self.fwdAlertPopupVC.delegate = self;
    self.fwdAlertPopupVC.forwardingAlert = YES;
    self.fwdAlertPopupVC.cell411AlertToFwd = self.cell411Alert;
    self.fwdAlertPopupVC.needyPerson = self.alertIssuer;
    self.fwdAlertPopupVC.arrCellGroups = [C411AppDefaults sharedAppDefaults].arrCells;
    UIView *vufwdAlertPopup = self.fwdAlertPopupVC.view;
    UIView *vuRootVC = [AppDelegate sharedInstance].window.rootViewController.view;
    vufwdAlertPopup.frame = vuRootVC.frame;
    [vuRootVC addSubview:vufwdAlertPopup];
    [vuRootVC bringSubviewToFront:vufwdAlertPopup];
#else
    UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
    UINavigationController *sendAlertNavC = [rootVC.storyboard instantiateViewControllerWithIdentifier:@"C411SendAlertNavC"];
    C411SendAlertVC *sendAlertVC = [sendAlertNavC.viewControllers firstObject];
    sendAlertVC.delegate = self;
    sendAlertVC.alertType = [C411StaticHelper getAlertTypeUsingAlertTypeString:self.alertPayload.strAlertRegarding];
    sendAlertVC.strForwardedAlertId = self.alertPayload.strCell411AlertId;
    [rootVC presentViewController:sendAlertNavC animated:YES completion:NULL];
#endif
}


-(void)forwardAlertWithAlertParams:(NSDictionary *)dictAlertParams andCompletion:(PFBooleanResultBlock)completion
{
    
    NSError *err = nil;
    NSData *alertJsonData = [NSJSONSerialization dataWithJSONObject:dictAlertParams options:NSJSONWritingPrettyPrinted error:&err];
    if (!err && alertJsonData) {
        
        NSString *strAlertJson = [[NSString alloc]initWithData:alertJsonData encoding:NSUTF8StringEncoding];
        if (strAlertJson.length > 0) {
            
            NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
            dictParams[kSendAlertV3FuncParamAlertKey] = strAlertJson;
            
//            AlertType alertType = (AlertType)[dictAlertParams[kSendAlertV3FuncParamAlertIdKey]integerValue];
//            if(alertType == AlertTypePhoto){
//                
//                dictParams[kSendAlertV3FuncParamImageBytesKey] = self.photoData;
//                
//                ///clear the ivar
//                self.photoData = nil;
//                
//            }
//            __weak typeof(self) weakSelf = self;
//            [MBProgressHUD showHUDAddedTo:self animated:YES];
            
            [C411StaticHelper sendAlertV3WithDetails:dictParams andCompletion:^(id object, NSError * error) {
                
                if(!error){
                    
                    ///Read the alert id from json string returned from cloud function as object and publish on facebook if allowed
                    NSDictionary *dictCloudResp = nil;
                    if (object && [object isKindOfClass:[NSString class]]) {
                        
                        NSData *jsonData = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *err = nil;
                        dictCloudResp = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                        if (err) {
                            
                            NSLog(@"Error retriving data from send alert cloud response, error -> %@",err.localizedDescription);
                        }
                    }
                    
                    if([dictCloudResp isKindOfClass:[NSDictionary class]]){
                        ///Show success message
                        NSInteger targetMembersCount = [dictCloudResp[kSendAlertV3FuncRespTargetMembersCountKey]integerValue];
                        NSInteger targetNauMembersCount = [dictCloudResp[kSendAlertV3FuncRespTargetNauMembersCountKey]integerValue];
                        
                        NSInteger alertReceiversCount = targetMembersCount + targetNauMembersCount;
                        NSString *strToastMsg = nil;
                        if(alertReceiversCount == 0){
                            
                            ///TODO: Prepare correct toast message for no members
                            strToastMsg = NSLocalizedString(@"No members in the selected Cell", nil);
                        }
                        else{
                            
                            NSString *strAlertAudienceSuffix = nil;
                            if(alertReceiversCount == 1){
                                
                                strAlertAudienceSuffix = NSLocalizedString(@"1 user", nil);
                            }
                            else{
                                
                                strAlertAudienceSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"%d users",nil),alertReceiversCount];
                                
                            }
                            
                            NSString *strMsgPrefix = NSLocalizedString(@"Alert", nil);
                            
                            strToastMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to %@",nil),strMsgPrefix,strAlertAudienceSuffix];
                        }
                        
                        [AppDelegate showToastOnView:nil withMessage:strToastMsg];
                    }
                    
                    ///Call the completion block
                    if(completion != NULL){
                        completion(YES, error);
                    }
                    
                }
                else{
                    
                    ///Hide the progress hud
//                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    ///show error
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                    if(completion != NULL){
                        completion(NO, nil);
                    }
                }
            }];
        }
        else{
            [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Some error occurred, please try again.", nil)];
            if(completion != NULL){
                
                completion(NO, nil);
            }
        }
    }
    else{
        [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Some error occurred, please try again.", nil)];
        if(completion != NULL){
            
            completion(NO, nil);
        }
    }
}

/*!
 * @description This method will initiate the forwarding of an alert to the members chosen by the user from the popup.If the arrAlertAudience is nil anyhow then it will try to fetch the members first.
 * @param audienceType Will describe about the type of target audience chosen by user.
 * @param arrAlertAudience will hold the objects of the members who will be going to recieve this forwarded alert. It could be nil for some cases, so if it is nil it should be fetched from Parse otherwise the error should be shown to user.
 * @param alertRecievingCell This will only contain valid object if audienceType is AudienceTypePrivateCellMembers
 * @param originalAlertIssuer Will hold the reference of PFUser object of the person who had actually issued this alert which is now being forwarded by current user
 * @param cell411AlertToFwd Will hold the reference of Cell411Alert object of the original alert which is being forwarded by current user
 */
-(void)initiateAlertForwardingWithAudienceType:(AudienceType)audienceType alertAudience:(NSArray *)arrAlertAudience onCell:(PFObject *)alertRecievingCell fromOriginalIssuer:(PFUser *)originalAlertIssuer andOriginalAlertToFwd:(PFObject *)cell411AlertToFwd{
    
    __weak typeof(self) weakSelf = self;
    ///get the privilege set for the user
    [C411StaticHelper getPrivilegeForUser:[AppDelegate getLoggedInUser] shouldSetPrivilegeIfUndefined:YES andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
        
        NSString *strPrivilege = string;
        if ((!strPrivilege)
            ||(strPrivilege.length == 0)) {
            
            ///some error occured fetching privilege
            NSLog(@"#error fetching privilege : %@",error.localizedDescription);
            
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, please try again.", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
        }
        else if ([strPrivilege isEqualToString:kPrivilegeTypeBanned]){
            
            ///This user account is banned, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else if ([strPrivilege hasPrefix:kPrivilegeTypeSuspended]){
            
            ///This user account is suspended, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else{
            
            ///privilege is either FIRST, SECOND or SHADOW_BANNED. User with privilege FIRST or SHADOW_BANNED cannot send Global Alerts
            if (audienceType == AudienceTypePatrolMembers){
                
                if ([strPrivilege isEqualToString:kPrivilegeTypeFirst]) {
                    
                    ///user has not such privilege to issue Global alert
                    [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You must have at least two friends and must have issued an alert to some Private Cell in order to issue alerts globally.", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                }
                else if ([strPrivilege isEqualToString:kPrivilegeTypeShadowBanned]){
                    
                    ///user is SHADOW_BANNED, he will not be informed that he cannot send Global Alert, so that he'll be in impression that he can send Global Alerts and this will avoid fake users to send spam alerts.DO NOTHING over here
                    
                    
                }
                else{
                    
                    ///Send global alert
                    [weakSelf forwardAlertWithId:cell411AlertToFwd.objectId issuedBy:originalAlertIssuer toAudienceType:audienceType onCell:alertRecievingCell withCompletion:NULL];
                    
                }
            }
            else{
                
                ///Alert sent to other audience
                [weakSelf forwardAlertWithId:cell411AlertToFwd.objectId issuedBy:originalAlertIssuer toAudienceType:audienceType onCell:alertRecievingCell withCompletion:NULL];
                
            }
            
            
        }
        
    }];
    
    
}


-(void)forwardAlertWithId:(NSString *)strForwardedAlertId issuedBy:(PFUser *)originalAlertIssuer toAudienceType:(AudienceType)audienceType onCell:(PFObject *)alertRecievingCell withCompletion:(PFBooleanResultBlock)completion{
    
    
    ///Create alert params to issue alert
    C411AlertNotificationPayload *alertPayload = self.alertPayload;
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    
    NSString *strAlertIssuerName = [C411StaticHelper getFullNameUsingFirstName:originalAlertIssuer[kUserFirstnameKey] andLastName:originalAlertIssuer[kUserLastnameKey]];
    
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *dictAlert = [NSMutableDictionary dictionary];
    
    CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;

    dictAlert[kSendAlertV2FuncParamLatKey] = @(currentLocationCoordinate.latitude);
    dictAlert[kSendAlertV2FuncParamLongKey] = @(currentLocationCoordinate.longitude);
    dictAlert[kSendAlertV2FuncParamTypeKey] = kPayloadAlertTypeNeedyForwarded;
    dictAlert[kSendAlertV2FuncParamFwdAlertIdKey] = strForwardedAlertId;
    
    NSMutableDictionary *dictAudience = [NSMutableDictionary dictionary];
    dictAlert[kSendAlertV2FuncParamAudienceKey] = dictAudience;
    
    ///Set the audience and other audience dependent data
    NSString *strAlertMsgPrefix = strAlertIssuerName;
    
    
        ///Set audience
        if(audienceType == AudienceTypePatrolMembers){
            
            ///Set radius
            dictAlert[kSendAlertV2FuncParamMetricKey] = kSendAlertV2FuncMetricValueMiles;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
            
            dictAlert[kSendAlertV2FuncParamRadiusKey] = @(patrolModeRadius);
            
            ///Update Alert msg prefix
            strAlertMsgPrefix = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, someone in your area", nil),strAlertIssuerName];
            
            ///Set audience type Global to YES
            dictAudience[kSendAlertV2FuncParamGlobalKey] = @(YES);
            
            
        }
        else if (audienceType == AudienceTypeAllFriends){
            
            ///Set audience type AllFriends
            dictAudience[kSendAlertV2FuncParamAllFriendsKey] = @(YES);
            
        }
        else if (audienceType == AudienceTypePrivateCellMembers){
            
            ///Set array of private Cell ids
            dictAudience[kSendAlertV2FuncParamPrivateCellsKey] = @[alertRecievingCell.objectId];
            
        }
    
    NSString *strAlertMsg = nil;
    NSString *strAlertName = [C411StaticHelper getLocalizedAlertTypeStringFromString:alertPayload.strAlertRegarding];
    
#if APP_CELL411
    strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 411 alert",nil),strAlertMsgPrefix,strAlertName];
    
#elif APP_RO112
    strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 112 alert",nil),strAlertMsgPrefix,strAlertName];
    
#else
    strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ alert",nil),strAlertMsgPrefix,strAlertName];
#endif
    
    ///Append public cell name
    NSString *strForwardedByName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
    strAlertMsg = [strAlertMsg stringByAppendingString:[NSString localizedStringWithFormat:NSLocalizedString(@", forwarded by %@",nil),strForwardedByName]];
    
    dictAlert[kSendAlertV2FuncParamMsgKey] = strAlertMsg;
    
    NSError *err = nil;
    NSData *alertJsonData = [NSJSONSerialization dataWithJSONObject:dictAlert options:NSJSONWritingPrettyPrinted error:&err];
    if (!err && alertJsonData) {
        
        NSString *strAlertJson = [[NSString alloc]initWithData:alertJsonData encoding:NSUTF8StringEncoding];
        if (strAlertJson.length > 0) {
            
            dictParams[kSendAlertV2FuncParamAlertKey] = strAlertJson;
            
            
            [C411StaticHelper sendAlertV2WithDetails:dictParams andCompletion:^(id object, NSError * error) {
                
                if(!error){
                    
                    ///Read the alert id from json string returned from cloud function as object and publish on facebook if allowed
                    NSDictionary *dictCloudResp = nil;
                    if (object && [object isKindOfClass:[NSString class]]) {
                        
                        NSData *jsonData = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *err = nil;
                        dictCloudResp = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                        if (err) {
                            
                            NSLog(@"Error retriving data from send alert cloud response, error -> %@",err.localizedDescription);
                        }
                    }
                    
                    if([dictCloudResp isKindOfClass:[NSDictionary class]]){
                        
                        
                        ///Show success message
                        NSInteger targetMembersCount = [dictCloudResp[kSendAlertV2FuncRespTargetMembersCountKey]integerValue];
                        NSInteger targetNauMembersCount = [dictCloudResp[kSendAlertV2FuncRespTargetNauMembersCountKey]integerValue];
                        
                        NSInteger alertReceiversCount = targetMembersCount + targetNauMembersCount;
                        NSString *strToastMsg = nil;
                        if(alertReceiversCount == 0){
                            
                            ///TODO: Prepare correct toast message for no members
                            strToastMsg = NSLocalizedString(@"No members in the selected Cell", nil);
                        }
                        else{
                            
                            NSString *strAlertAudienceSuffix = nil;
                            if(alertReceiversCount == 1){
                                
                                strAlertAudienceSuffix = NSLocalizedString(@"1 user", nil);
                            }
                            else{
                                
                                strAlertAudienceSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"%d users",nil),alertReceiversCount];
                                
                            }
                            
                            NSString *strMsgPrefix = NSLocalizedString(@"Alert", nil);
                            
                            strToastMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to %@",nil),strMsgPrefix,strAlertAudienceSuffix];
                        }
                        
                        [AppDelegate showToastOnView:nil withMessage:strToastMsg];
                        
                    }
                    
                    
                }
                else{
                    
                    ///show error
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                    
                    
                }
                
                ///Call the completion block
                if(completion != NULL){
                    
                    completion(NO, nil);
                }
                
            }];

            
        }
        else{
            
            ///Some error occured
            
            ///show error
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, try again later.", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
            if(completion != NULL){
                
                completion(NO, nil);
            }
            
        }
    }
    else{
        
        ///Some error occured
        ///show error
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, try again later.", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
        
        if(completion != NULL){
            
            completion(NO, nil);
        }
        
    }

    
    
    
    
    
}


/*!
 * @description This method will initiate the forwarding of an alert to the members chosen by the user from the popup.If the arrAlertAudience is nil anyhow then it will try to fetch the members first.
 * @param audienceType Will describe about the type of target audience chosen by user.
 * @param arrAlertAudience will hold the objects of the members who will be going to recieve this forwarded alert. It could be nil for some cases, so if it is nil it should be fetched from Parse otherwise the error should be shown to user.
 * @param alertRecievingCell This will only contain valid object if audienceType is AudienceTypePrivateCellMembers
 * @param originalAlertIssuer Will hold the reference of PFUser object of the person who had actually issued this alert which is now being forwarded by current user
 * @param cell411AlertToFwd Will hold the reference of Cell411Alert object of the original alert which is being forwarded by current user
 */
/*
-(void)initiateAlertForwardingWithAudienceType:(AudienceType)audienceType alertAudience:(NSArray *)arrAlertAudience onCell:(PFObject *)alertRecievingCell fromOriginalIssuer:(PFUser *)originalAlertIssuer andOriginalAlertToFwd:(PFObject *)cell411AlertToFwd
{
    
    __weak typeof(self) weakSelf = self;
    ///get the privilege set for the user
    [C411StaticHelper getPrivilegeForUser:[AppDelegate getLoggedInUser] shouldSetPrivilegeIfUndefined:YES andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
        
        NSString *strPrivilege = string;
        if ((!strPrivilege)
            ||(strPrivilege.length == 0)) {
            
            ///some error occured fetching privilege
            NSLog(@"#error fetching privilege : %@",error.localizedDescription);
            
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, please try again.", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
        }
        else if ([strPrivilege isEqualToString:kPrivilegeTypeBanned]){
            
            ///This user account is banned, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else if ([strPrivilege hasPrefix:kPrivilegeTypeSuspended]){
            
            ///This user account is suspended, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else{
            
            ///privilege is either FIRST, SECOND or SHADOW_BANNED. User with privilege FIRST or SHADOW_BANNED cannot send Global Alerts
            ///Validate if target audience is available
            if (arrAlertAudience.count == 0) {
                
                ///Audience is not available, show alert if its a cell member
                if (audienceType == AudienceTypePrivateCellMembers) {
                    
                    
                    ///Show no members alert
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                        ///Do anything required on OK action
                        
                        ///Dequeue the current Alert Controller and allow other to be visible
                        [[MAAlertPresenter sharedPresenter]dequeueAlert];

                    }];
                    
                    [alertController addAction:okAction];
                    //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                    
                }
                else if (audienceType == AudienceTypeAllFriends){
                    
                    ///1.Pick from defaults first if available
                    NSArray *arrFriends = [C411AppDefaults sharedAppDefaults].arrFriends;
                    
                    if (arrFriends.count > 0) {
                        
                        ///All friends are now available forward alert
                        [self forwardAlertToMembers:arrFriends audienceType:audienceType onCell:alertRecievingCell fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
                        
                        
                    }
                    else{
                        ///2.Try fetching all friends from parse if available
                        
                        PFUser *currentUser = [AppDelegate getLoggedInUser];
                        PFRelation *getFriendsRelation = [currentUser relationForKey:kUserFriendsKey];
                        [[getFriendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                            
                            if (!error) {
                                
                                if (objects.count > 0) {
                                    
                                    NSMutableArray *arrAllFriends = [NSMutableArray arrayWithArray:objects];
                                    ///All friends are now available forward alert
                                    [weakSelf forwardAlertToMembers:arrAllFriends audienceType:audienceType onCell:alertRecievingCell fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
                                    
                                    
                                }
                                else{
                                    
                                    ///Show no members alert
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                        
                                        ///Do anything required on OK action
                                        
                                        ///Dequeue the current Alert Controller and allow other to be visible
                                        [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                    }];
                                    
                                    [alertController addAction:okAction];
                                    //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
                                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                                    
                                }
                                
                            }
                            else {
                                
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                }
                                
                                
                            }
                            
                            
                            
                        }];
                        
                    }
                    
                }
                else if (audienceType == AudienceTypePatrolMembers){
                    
                    if ([strPrivilege isEqualToString:kPrivilegeTypeFirst]) {
                        
                        ///user has not such privilege to issue Global alert
                        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You must have at least two friends and must have issued an alert to some private Cell in order to issue alerts globally.", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        
                    }
                    else if ([strPrivilege isEqualToString:kPrivilegeTypeShadowBanned]){
                        
                        ///user is SHADOW_BANNED, he will not be informed that he cannot send Global Alert, so that he'll be in impression that he can send Global Alerts and this will avoid fake users to send spam alerts.DO NOTHING over here
                        
                        
                    }
                    else{
                        
                        ///Fetch the patrol members within the given radius
                        ///Get patrol radius
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
                        
                        ///Make a query to fetch users
                        PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:[LocationManager sharedInstance].currentLocation];
                        
                        PFQuery *fetchGloablUsersQuery = [PFUser query];
                        [fetchGloablUsersQuery whereKey:kUserPatrolModeKey equalTo:PATROL_MODE_VALUE_ON];
                        [fetchGloablUsersQuery whereKey:kUserLocationKey nearGeoPoint:userGeoPoint withinMiles:(double)patrolModeRadius];
                        [fetchGloablUsersQuery whereKey:@"objectId" notEqualTo:[AppDelegate getLoggedInUser].objectId];
                        [fetchGloablUsersQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                            
                            if (!error) {
                                
                                if (objects.count > 0) {
                                    
                                    NSMutableArray *arrPatrolMembers = [NSMutableArray arrayWithArray:objects];
                                    ///All Patrol members within specified miles are now available filter the members who have spammed current user and then forward alert
                                    [weakSelf forwardAlertToMembers:arrPatrolMembers audienceType:audienceType onCell:alertRecievingCell fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
                                    
                                    
                                }
                                else{
                                    
                                    ///Show no members alert, as no patrol member available
                                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                        
                                        ///Do anything required on OK action
                                        
                                        ///Dequeue the current Alert Controller and allow other to be visible
                                        [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                    }];
                                    
                                    [alertController addAction:okAction];
                                    //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
                                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                                }
                                
                            }
                            else {
                                
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                }
                                
                                
                            }
                            
                            
                            
                        }];
                        
                    }
                }
                
                
                
                
            }
            else{
                
                ///members are available forward the alert, this will not issue global alerts so there is no need to check for privilege here
                [self forwardAlertToMembers:arrAlertAudience audienceType:audienceType onCell:alertRecievingCell fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
                
            }
            
            
        }
        
    }];
    
    
}

-(void)forwardAlertToMembers:(NSArray *)arrAudience audienceType:(AudienceType)audienceType onCell:(PFObject *)alertRecievingCell fromOriginalIssuer:(PFUser *)originalAlertIssuer andOriginalAlertToFwd:(PFObject *)cell411AlertToFwd
{
    
    C411AlertNotificationPayload *alertPayload = self.alertPayload;
    if (alertPayload) {
        
        PFUser *alertForwarder = [AppDelegate getLoggedInUser];
        
        ///Make a new entry on Cell 411 alert table and send push if audience is greater than 0, copying almost all the data of the alertPayload leaving targetMembers, and add forwardedBy and forwardedToMembers info in it.
        if (arrAudience.count > 0) {
            
            ///Filter the audience by removing the members who have spammed current user
            [[AppDelegate sharedInstance]filteredArrayByRemovingMembersInSpammedByRelationFromArray:arrAudience withCompletion:^(id result, NSError *error) {
                NSArray *arrFilteredAudience = (NSArray *)result;
                
                if (arrFilteredAudience.count > 0) {
                    ///Forward alert to target audience
                    
                    ///1. Save it to Cell411Alert Table first
                    
                    ///Create object and initialize it
                    PFObject *cell411Alert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                    cell411Alert[kCell411AlertAdditionalNoteKey] = alertPayload.strAdditionalNote;
                    cell411Alert[kCell411AlertAlertTypeKey] = alertPayload.strAlertRegarding;
                    cell411Alert[kCell411AlertIssuedByKey] = originalAlertIssuer;
                    cell411Alert[kCell411AlertIssuerFirstNameKey] = alertPayload.strFullName;
                    cell411Alert[kCell411AlertIssuerIdKey] = alertPayload.strUserId;
                    cell411Alert[kCell411AlertLocationKey] = [PFGeoPoint geoPointWithLatitude:alertPayload.lat longitude:alertPayload.lon];
                    
                    ///Set dispatchMode key value.This is something should be picked from alertPayload like other values
                    cell411Alert[kCell411AlertDispatchModeKey] = @(alertPayload.dispatchMode);
                    
                    ///Set isGloabl to 1 if this being sent to patrol members else 0, isGlobal will only hold the value as per the forwardedBy person setting, i.e if alert forwarder is forwarding the alert Globally then it will be set to 1 else 0. It will not consider the value set in alertPayload for this
                    NSNumber *isGlobalAlert = (audienceType == AudienceTypePatrolMembers) ? @1 : @0;
                    cell411Alert[kCell411AlertIsGlobalKey] = isGlobalAlert;
                    
                    
                    cell411Alert[kCell411AlertForwardedByKey] = alertForwarder;
                    
                    cell411Alert[kCell411AlertForwardedToMembersKey] = arrFilteredAudience;
                    cell411Alert[kCell411AlertForwardedAlertKey] = cell411AlertToFwd;
                    //Save in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            
                            
                            ///2.An entry has been made successfully on Cell411Alert table regarding the alert being forwarded and now you can send the notification to the target members whom it has been forwarded to
                            
                            
                            ///Show notification delivered alert
                            NSString *strAlertAudienceSuffix = nil;
                            
                            if (audienceType == AudienceTypeAllFriends) {
                                
                                strAlertAudienceSuffix = NSLocalizedString(@"All Friends", nil);
                            }
                            else if (audienceType == AudienceTypePrivateCellMembers){
                                
                                strAlertAudienceSuffix = alertRecievingCell[kCellNameKey];
                            }
                            else if (audienceType == AudienceTypePatrolMembers){
                                
                                if (arrFilteredAudience.count == 1)
                                {
                                    strAlertAudienceSuffix = NSLocalizedString(@"1 user", nil);
                                    
                                }
                                else{
                                    
                                    strAlertAudienceSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"%d users",nil),(int)arrFilteredAudience.count];
                                }
                            }
                            
                            NSString *strMsgPrefix = NSLocalizedString(@"Alert", nil);
                            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to %@",nil),strMsgPrefix,strAlertAudienceSuffix];
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                
                                ///Do anything required on OK action
                                
                                ///Dequeue the current Alert Controller and allow other to be visible
                                [[MAAlertPresenter sharedPresenter]dequeueAlert];

                            }];
                            
                            [alertController addAction:okAction];
                            //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
                            ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                            [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                            ///Send push notification only if members are greater than 0
                            if (arrFilteredAudience.count > 0) {
                                
                                ///Create Payload data
                                NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                                
                                NSString *strCurrentUserFullName = [C411StaticHelper getFullNameUsingFirstName:alertForwarder[kUserFirstnameKey] andLastName:alertForwarder[kUserLastnameKey]];
                                
                                NSString *strAlertMsg = [NSString stringWithFormat:@"%@ %@",strCurrentUserFullName,NSLocalizedString(@"forwarded an emergency alert!", nil)];
                                
                                dictData[kPayloadAlertKey] = strAlertMsg;
                                dictData[kPayloadAlertRegardingKey] = alertPayload.strAlertRegarding;
                                dictData[kPayloadUserIdKey] = alertPayload.strUserId;
                                dictData[kPayloadCell411AlertIdKey] = alertPayload.strCell411AlertId;
                                dictData[kPayloadLatKey] = @(alertPayload.lat);
                                dictData[kPayloadLonKey] = @(alertPayload.lon);
                                dictData[kPayloadAdditionalNoteKey] = alertPayload.strAdditionalNote;
                                
                                dictData[kPayloadCreatedAtKey] = @(alertPayload.createdAtInMillis);
                                dictData[kPayloadFirstNameKey] = alertPayload.strFullName;
                                dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeNeedyForwarded;
                                dictData[kPayloadForwardedByKey] = strCurrentUserFullName;
                                
                                dictData[kPayloadSoundKey] = @"default";///To play default sound
                                dictData[kPayloadIsGlobalKey] = isGlobalAlert;///Set GloablAlert value, this will hold the value as per the setting of current user, this will be 1 if user has forwarded the alert to Global Cell(i.e patrol members).
                                dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                                
                                ///.Set dispatchMode key value from payload data,
                                dictData[kPayloadDispatchModeKey] = @(alertPayload.dispatchMode);
                                
                                
                                
                                // Create our Installation query
                                PFQuery *pushQuery = [PFInstallation query];
                                [pushQuery whereKey:kInstallationUserKey containedIn:arrFilteredAudience];
                                
                                // Send push notification to query
                                PFPush *push = [[PFPush alloc] init];
                                [push setQuery:pushQuery]; // Set our Installation query
                                [push setData:dictData];
                                
                                ///Send Push notification
                                [push sendPushInBackground];
                                
                                ///set Second privilege if applicable
                                NSString *strPrivilege = alertForwarder[kUserPrivilegeKey];
                                
                                if (([isGlobalAlert intValue] !=1)
                                    &&((!strPrivilege)
                                       || (strPrivilege.length == 0)
                                       ||([strPrivilege isEqualToString:kPrivilegeTypeFirst]))) {
                                        ///this is an alert other than Global alert and privilege is either FIRST or unset
                                        ///get the friends count for current user
                                        [C411StaticHelper getFriendCountForUser:alertForwarder withCompletion:^(int number, NSError * _Nullable error) {
                                            
                                            ///check the friend count
                                            if (!error) {
                                                
                                                if (number >= MIN_FRIENDS_FOR_SECOND_PRIVILEGE) {
                                                    
                                                    ///save the privilege as SECOND
                                                    [C411StaticHelper savePrivilege:kPrivilegeTypeSecond forUser:alertForwarder withOptionalCompletion:NULL];
                                                    
                                                }
                                                
                                                
                                            }
                                            else{
                                                ///show error
                                                NSString *errorString = [error userInfo][@"error"];
                                                NSLog(@"fwd alert check privilege -> error getting friend count %@",errorString);
                                                
                                            }
                                            
                                        }];
                                        
                                    }
                                
                                
                            }
                            
                            
                            
                        }
                        else{
                            
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:errorString preferredStyle:UIAlertControllerStyleAlert];
                                
                                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                    
                                        ///Do anything required on OK action
                                        ///Dequeue the current Alert Controller and allow other to be visible
                                        [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                    }];
                                
                                    [alertController addAction:okAction];
                                    //[[AppDelegate     sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
                                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
                                }

                            }
                            
                        }
                        
                        
                    }];
                    
                    
                }
                else{
                    
                    ///Show no members alert
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                        ///Do anything required on OK action
                        
                        ///Dequeue the current Alert Controller and allow other to be visible
                        [[MAAlertPresenter sharedPresenter]dequeueAlert];

                    }];
                    
                    [alertController addAction:okAction];
                    //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                    
                }
            }];
            
            
            
            
        }
        else{
            
            ///Show no members alert
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                ///Do anything required on OK action
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];

            }];
            
            [alertController addAction:okAction];
            //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
            ///Enqueue the alert controller object in the presenter queue to be displayed one by one
            [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

            
        }
        
        
    }
    
}
*/

-(void)handleAlertSeen
{
    if([self.alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyForwarded.lowercaseString]){
        
        ///This is a NEEDY_FORWARDED alert, so get the forwarding alert and set current user on seenBy
        if(self.alertPayload.strForwardingAlertId){
            PFQuery *getForwardingAlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [getForwardingAlertQuery whereKey:@"objectId" equalTo:self.alertPayload.strForwardingAlertId];
            [getForwardingAlertQuery selectKeys:@[kCell411AlertSeenByKey]];
            [getForwardingAlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                
                if (!error && object) {
                    ///Forwarding alert is fetched, set current user on seenBy relation
                    PFObject *forwardingAlert = object;
                    [[C411AppDefaults sharedAppDefaults] setCurrentUserHasSeenAlert:forwardingAlert];
                }
                else {
                    
                    if(![AppDelegate handleParseError:error]){
                        
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"#error: %@",errorString);
                    }
                    
                }
            }];
        }
        else{
            ///TODO: Handle backward compatibility by fetching the forwarding alert id and then setting current user on seenBy relation
        }
    }
    else{
        
        ///This is the actual alert so set current user on seenBy for current Cell411Alert object
        [[C411AppDefaults sharedAppDefaults] setCurrentUserHasSeenAlert:self.cell411Alert];
    
    }
}



-(void)handleChatIconVisibility
{
    
#if CHAT_ENABLED
    
    ///show chat button if chat time is not expired
    BOOL isChatExpired = ![C411ChatHelper canChatOnAlertIssuedAt:self.alertPayload.createdAtInMillis];
    
    if (isChatExpired) {
        ///chat is expired, don't show chat bubble
        [self hideChatIcon];
        
    }
#else
    
    [self hideChatIcon];
    
#endif
    
}

-(void)hideChatIcon
{
    self.cnsChatBtnWidth.constant = 0;
    self.cnsNavigateBtnLS.constant = 0;
}

-(void)setUserDistance
{
    ///1.Get distance in miles from current user to the needy
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES]];
    PFGeoPoint *needyGeoPoint = [PFGeoPoint geoPointWithLatitude:self.alertPayload.alertAddress.coordinate.latitude longitude:self.alertPayload.alertAddress.coordinate.longitude];
    double distanceInMiles = [userGeoPoint distanceInMilesTo:needyGeoPoint];
    
    ///get the current metric system chosen by user
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
    NSString *strDistanceWithSelectedMetric = nil;
    
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///current metric is in kms
        float distanceInKms = distanceInMiles * MILES_TO_KM;
        NSString *strMetric = (distanceInKms <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
        strDistanceWithSelectedMetric = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ %@ away",nil),[C411StaticHelper getDecimalStringFromNumber:@(distanceInKms) uptoDecimalPlaces:1],strMetric];
        
    }
    else{
        ///current metric is in miles
        NSString *strMetric = (distanceInMiles <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
        strDistanceWithSelectedMetric = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ %@ away",nil),[C411StaticHelper getDecimalStringFromNumber:@(distanceInMiles) uptoDecimalPlaces:1],strMetric];
    }
    self.lblUserDistance.text = strDistanceWithSelectedMetric;

}

-(void)setUserDistanceOnLocationUpdateAndObserveFG:(BOOL)shouldObserveForeground
{
    ///Set ivar to set user distance on location update
    self.setUserDistanceOnLocationUpdate = YES;
    
    ///Add location updated observer to send out the alert
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationManagerDidUpdateLocation:) name:kLocationUpdatedNotification object:nil];
    if(shouldObserveForeground){
        ///Add observer for app coming to foreground
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
}

-(void)hideUserDistanceView
{
    self.vuBaseUserDistance.hidden = YES;
}

-(void)showUserDistanceView
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.4 animations:^{
        weakSelf.vuBaseUserDistance.hidden = NO;
    }];
}

//****************************************************
#pragma mark - GoogleDirectionProviderDelegate Methods
//****************************************************

-(void)directionProviderBeginFetching:(GoogleDirectionProvider *)provider
{
    /*
     if (![_directionSource polyline]) {
     [self showLoadingActivity:YES];
     };
     if ([NAH_GoogleDirectionProvider listingAddedToDirections].count>1) {
     [_topBar addViewsOnRightSide:@[_closeButton,_sortButton]];
     [_sortButton setHidden:NO];
     }else
     {
     [_topBar addViewsOnRightSide:@[_closeButton]];
     [_sortButton setHidden:YES];
     
     }
     */
    
}

-(void)directionProviderEndFetching:(GoogleDirectionProvider *)provider
{
    //[self showLoadingActivity:NO];
    ///1.Send Helper ACK
    NSString *strAdditionalNote = [provider.dictAlertData objectForKey:ALERT_DATA_ADDITIONAL_NOTE_KEY];
    [self sendHelperAckAlertUsingAlertPayload:self.alertPayload additionalNote:strAdditionalNote andDuration:provider.strFormattedDurationText];
    /*
    //2.Adding Route overlay
    provider.overviewPolyline.strokeWidth = 10;
    provider.overviewPolyline.strokeColor = [UIColor colorWithRed:33.0/255 green:150.0/255 blue:243.0/255 alpha:1.0];
    provider.overviewPolyline.map = mapView_;
    
    ///3. Add destination Marker on map
    GMSMarker *destMarker = [[GMSMarker alloc]init];
    destMarker.position = [(CLLocation *)[provider.destinations lastObject]coordinate];
    destMarker.groundAnchor = CGPointMake(0.5, 0.5);
    if (!defaultPinImage) {
        defaultPinImage = [UIImage imageNamed:@"icon_default_pin"];
    }
    
    destMarker.icon = defaultPinImage;
    [self setGravatarOnMarker:destMarker usingAlertData:provider.dictAlertData];
    destMarker.map = mapView_;
    
    
    
    ///4. set bounds of Map
    [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:provider.boundRegion withPadding:30.0f]];
    */
    
    ///5. remove direction provider from ivar
    self.directionSource.directionDelegate = nil;
    self.directionSource = nil;
    
    
    
    /*
     // Setting bound
     MKCoordinateRegion region = provider.boundRegion;
     region = [_map regionThatFits:region];
     [_map setRegion:region animated:NO];
     if (self.shownDirectionListOnce) {
     if (_expensionState == DirectionListExpensionState_Hidden) {
     [self setDirectionStepViewForState:DirectionListExpensionState_Collapsed animate:YES];
     }else{
     [self setDirectionStepViewForState:_expensionState animate:YES];
     }
     
     }else{
     [self setDirectionStepViewForState:DirectionListExpensionState_Expanded animate:YES];
     self.shownDirectionListOnce = YES;
     }
     if (_directionSource.copywirte.length>0) {
     _copywriteLabel.text = _directionSource.copywirte;
     _copywriteLabel.hidden = NO;
     }
     */
    
}

-(void)directionProvider:(GoogleDirectionProvider *)provider receivedErrorFetching:(NSError *)error
{
    /*
     [self showLoadingActivity:NO];
     if (!_directionSource.polyline ) {
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to get directions. Check your connection", nil) message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Re-try", nil];
     alertView.tag = Alert_UnableToGetRoute;
     [alertView show];
     }
     */
    
    NSLog(@"#error fetching direction: %@",error.localizedDescription);
    
    ///1.Send Helper ACK
    NSString *strAdditionalNote = [provider.dictAlertData objectForKey:ALERT_DATA_ADDITIONAL_NOTE_KEY];
    [self sendHelperAckAlertUsingAlertPayload:self.alertPayload additionalNote:strAdditionalNote andDuration:nil];
    
    
    ///2. remove direction provider from ivar
    self.directionSource.directionDelegate = nil;
    self.directionSource = nil;
    
    
}

-(void)directionProviderWillResetDirectionData:(GoogleDirectionProvider *)provider
{
    if (provider.overviewPolyline) {
        provider.overviewPolyline.map = nil;
    }
    /*
     if (provider.annotations.count>0) {
     [_map removeAnnotations:provider.annotations];
     }
     
     if (_directionsListDelegate.selectedLeg.polylines.count>0) {
     [_map removeAnnotations:_directionsListDelegate.selectedLeg.polylines];
     }
     */
    provider.statusCode = 0;
    //[_routStepTable reloadData];
    //_copywriteLabel.hidden = YES;
}

-(void)directionProviderRouteNotPossible:(GoogleDirectionProvider *)provider
{
    /*
     [self showLoadingActivity:NO];
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Route not possible between your locations and waypoints" message:Nil delegate:Nil cancelButtonTitle:@"Ok." otherButtonTitles: nil];
     alert.tag = Alert_RouteNotPossible;
     [alert show];
     */
    NSLog(@"#Route not possible");
    
    ///1.Send Helper ACK
    NSString *strAdditionalNote = [provider.dictAlertData objectForKey:ALERT_DATA_ADDITIONAL_NOTE_KEY];
    [self sendHelperAckAlertUsingAlertPayload:self.alertPayload additionalNote:strAdditionalNote andDuration:nil];
    
    ///2. remove direction provider from ivar
    self.directionSource.directionDelegate = nil;
    self.directionSource = nil;
    
    
}

//****************************************************
#pragma mark - C411SendAlertVCDelegate Methods
//****************************************************

-(void)sendAlertWithParams:(NSDictionary *)dictAlertParams
{
    NSLog(@"%s-->\n%@",__PRETTY_FUNCTION__, dictAlertParams);
    [self forwardAlertWithAlertParams:dictAlertParams andCompletion:NULL];
    
}

//****************************************************
#pragma mark - C411SendAlertPopupVCDelegate Methods
//****************************************************

-(void)sendAlertPopupDidSelectGlobalAlert:(C411SendAlertPopupVC *)alertPopupVC
{
    
     if (alertPopupVC.isForwardingAlert) {
     
     ///User has selected to forward someone's alert globally to patrol members
     PFUser *originalAlertIssuer = alertPopupVC.needyPerson;///This is the actual person who issued the alert, which is being forwarded by current user
     PFObject *cell411AlertToFwd = alertPopupVC.cell411AlertToFwd; ///This is the actual Cell411Alert being forwarded by current user
     alertPopupVC.delegate = nil;
     
     ///Dismiss popup
     [alertPopupVC.view removeFromSuperview];
     ///Clear the alert data hold as a strong refernce and remove the popup from queue
    alertPopupVC.needyPerson = nil;
     alertPopupVC.cell411AlertToFwd = nil;
         self.fwdAlertPopupVC = nil;
     
     ///Initiate alert forwarding to Patrol members, alertAudience will be nil as it will be retrived in the method called below.
     [self initiateAlertForwardingWithAudienceType:AudienceTypePatrolMembers alertAudience:nil onCell:nil fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
     
     }
    
}


-(void)sendAlertPopupDidSelectAllFriends:(C411SendAlertPopupVC *)alertPopupVC
{
    
     if (alertPopupVC.isForwardingAlert) {
     
     ///User has selected to forward someone's alert to all friends
     PFUser *originalAlertIssuer = alertPopupVC.needyPerson;///This is the actual person who issued the alert, which is being forwarded by current user
     PFObject *cell411AlertToFwd = alertPopupVC.cell411AlertToFwd; ///This is the actual Cell411Alert being forwarded by current user
     
     alertPopupVC.delegate = nil;
     
     ///Dismiss popup
     [alertPopupVC.view removeFromSuperview];
     ///Clear the alert data hold as a strong refernce and remove the popup from queue
     alertPopupVC.needyPerson = nil;
     alertPopupVC.cell411AlertToFwd = nil;
     self.fwdAlertPopupVC = nil;
     
     ///Initiate alert forwarding to All friends.
     NSArray *arrAlertAudience = [C411AppDefaults sharedAppDefaults].arrFriends;
     
     [self initiateAlertForwardingWithAudienceType:AudienceTypeAllFriends alertAudience:arrAlertAudience onCell:nil fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
     
     }
    
}

-(void)sendAlertPopup:(C411SendAlertPopupVC *)alertPopupVC didSelectCell:(PFObject *)cell
{
    
     if (alertPopupVC.isForwardingAlert) {
     
     ///User has selected to forward someone's alert to members of a particular cell
     PFUser *originalAlertIssuer = alertPopupVC.needyPerson;///This is the actual person who issued the alert, which is being forwarded by current user
     PFObject *cell411AlertToFwd = alertPopupVC.cell411AlertToFwd; ///This is the actual Cell411Alert being forwarded by current user
     
     alertPopupVC.delegate = nil;
     
     ///Dismiss popup
     [alertPopupVC.view removeFromSuperview];
     ///Clear the alert data hold as a strong refernce and remove the popup from queue
     alertPopupVC.needyPerson = nil;
     alertPopupVC.cell411AlertToFwd = nil;
         self.fwdAlertPopupVC = nil;
         
     ///Initiate alert forwarding to All friends.
     NSArray *arrAlertAudience = cell[kCellMembersKey];
     
     [self initiateAlertForwardingWithAudienceType:AudienceTypePrivateCellMembers alertAudience:arrAlertAudience onCell:cell fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
     
     }
    
}

-(void)sendAlertPopupDidCancel:(C411SendAlertPopupVC *)alertPopupVC
{
    
     if (alertPopupVC.isForwardingAlert) {
     ///User cancelled to forward the alert
     alertPopupVC.delegate = nil;
     
     ///Dismiss popup
     [alertPopupVC.view removeFromSuperview];
     
     ///Clear the alert data hold as a strong refernce and remove the popup from queue
     alertPopupVC.needyPerson = nil;
     alertPopupVC.cell411AlertToFwd = nil;
         self.fwdAlertPopupVC = nil;
     }
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnExpandTapped:(UIButton *)sender {
    
    ///show the expanded view
    self.vuExpandedAlertDetails.hidden = NO;
    
}

- (IBAction)btnCannotHelpTapped:(UIButton *)sender {

    if (self.alertPayload.isDeepLinked) {
        ///close the popup as there is no need to send cancel response of facebook user to the alert issuer
        [self btnCloseAlertTapped:self.btnCloseAlert];
    }
    else if (self.canRespondToAlert) {
        ///user can respond to this alert
        ///perform cannot help task
        [self handleUserResponseToAlertWithHelp:NO];        
    }
    else{
        ///show close button to close the alert
        [self showCloseButton];
     }

    /*
    if (self.alertPayload.isDeepLinked) {
        ///close the popup as there is no need to send cancel response of facebook user to the alert issuer
        [self btnCloseAlertTapped:self.btnCloseAlert];
        
    }
    else if ((self.canRespondToAlert) && (!self.isResponedToAlert)) {
        
        ///user can respond to this alert
        ///perform cannot help task
        [self handleUserResponseToAlertWithHelp:NO];
        
        
    }
    else{
        
        if (self.isCrossTapped) {
            
            ///Cross was tapped so close it without showing cross button
            [self btnCloseAlertTapped:self.btnCloseAlert];

        }
        else{
          
            ///show close button to close the alert
            [self showCloseButton];

        }

    }
     */
}

- (IBAction)btnAcceptTapped:(UIButton *)sender {

    if (self.canRespondToAlert) {
        
        ///user can respond to this alert and current user is available
        if ([AppDelegate getLoggedInUser]) {
            
            ///perform accept task
            [self handleUserResponseToAlertWithHelp:YES];

        }
        else{
           
            ///alert opened when user is not logged in, i.e alert opened through facebook and user is logged out.
            ///1.Show Custom view to take user name and additional note
            NSString *strIssueFirstName = [[self.alertPayload.strFullName componentsSeparatedByString:@" "]firstObject];
            NSString *strAnonymousUserPopupSubtitle = [NSString localizedStringWithFormat:NSLocalizedString(@"Please enter your name so that %@ can recognize you.",nil),strIssueFirstName];
            self.lblAnonymousUserDetailsPopupSubtitle.text = strAnonymousUserPopupSubtitle;
            self.vuAnonymousUserDetailsPopupBase.hidden = NO;
            self.btnSendAnonymousUserDetails.enabled = NO;
            
            
        }
        
        
    }
    else{
        
        ///show close button to close the alert
        [self showCloseButton];
        
    }

    
}

- (IBAction)btnForwardAlertTapped:(UIButton *)sender {
    
    ///show forward alert popup
    [self showForwardAlertPopup];
    
    /*
#if USE_OLD_AUDIENCE_SELECTION_POPUP
    if (!self.cell411Alert) {
        
        ///show working button
        [self showWorkingButton];
       
        //Fetch the cell411Alert object associated to this alert
        __weak typeof(self) weakSelf = self;
        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [getCell411AlertQuery whereKey:@"objectId" equalTo:self.alertPayload.strCell411AlertId];
        [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
            
            if (!error && object) {
                ///Cell411Alert object for the recieved alert is fetched successfully, now pass this object on forward alert popup which can be used later to make an entry on Cell411Alert record associated to forwarded alert
                weakSelf.cell411Alert = (PFObject *)object;
                
                ///show the forward alert popup with valid cell411Alert object
                [weakSelf showForwardAlertPopup];
            }
            else{
                
                if(![AppDelegate handleParseError:error]){
                    ///show the error
                    NSString *errorString = [error userInfo][@"error"];
                
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
            }
            
            ///remove working button
            [weakSelf hideWorkingButton];
            
        }];
        
    }
    else{
        ///show forward alert popup
        [self showForwardAlertPopup];
        
    }
#else
    ///show forward alert popup
    [self showForwardAlertPopup];
#endif
*/
}

- (IBAction)btnCallEmergencyContactTapped:(UIButton *)sender {
    
    NSString *emergencyContactNumber = self.alertIssuer[kUserEmergencyContactNumberKey];
    if (emergencyContactNumber.length > 0) {
        [C411StaticHelper callOnNumber:emergencyContactNumber];
    }

}

- (IBAction)btnChatTapped:(UIButton *)sender {
    
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    
    C411ChatVC *chatVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
    chatVC.entityType = ChatEntityTypeAlert;
    chatVC.strEntityId = self.alertPayload.strCell411AlertId;
    chatVC.strEntityName = self.alertPayload.strAlertRegarding;

    chatVC.entityCreatedAtInMillis = self.alertPayload.createdAtInMillis;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:chatVC animated:YES];

}

- (IBAction)btnNavigateTapped:(UIButton *)sender {
    ///open google maps app, do not give starting point so that it will use user current location as starting point
    GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
    definition.destinationPoint = [GoogleDirectionsWaypoint
                                   waypointWithLocation:self.alertPayload.alertAddress.coordinate];
    definition.travelMode = kGoogleMapsTravelModeDriving;
    BOOL isOpened = [[OpenInGoogleMapsController sharedInstance] openDirections:definition];

    if(!isOpened){
        
        ///Get the cross-platform maps url to open
        NSString *strLatLong = [NSString stringWithFormat:@"%lf,%lf",self.alertPayload.alertAddress.coordinate.latitude,self.alertPayload.alertAddress.coordinate.longitude];
        NSDictionary *dictParams = @{kGoogleMapsDestinationKey : strLatLong,
                                     kGoogleMapsTravelModeKey : kGoogleMapsTravelModeValueDriving};
        NSURL *directionsUrl = [C411StaticHelper getGoogleMapsDirectionsUrlForAllPlatforms:dictParams];
        
        if([[UIApplication sharedApplication]canOpenURL:directionsUrl]){
            
            [[UIApplication sharedApplication]openURL:directionsUrl];
            
        }
        
    }

    
}

- (IBAction)btnCallAlertIssuerTapped:(UIButton *)sender {
    
    NSString *contactNumber = self.alertIssuer[kUserMobileNumberKey];
    [C411StaticHelper callOnNumber:contactNumber];
    
}

- (IBAction)btnCollapseTapped:(UIButton *)sender {
    
    ///hide the expanded view
    self.vuExpandedAlertDetails.hidden = YES;
    
}

- (IBAction)btnCloseAlertTapped:(UIButton *)sender {
    
    if (self.actionHandler != NULL) {
        ///call the Close action handler
        self.actionHandler(sender,0,nil);
    
    }
    
    [self removeFromSuperview];
    self.actionHandler = NULL;
    
    
}

- (IBAction)btnSendAnonymousUserDetailsTapped:(UIButton *)sender {
    
    ///send tapped
    if (self.txtAnonymousUserName.text > 0) {
        ///Anonymous User Initiated help to needy,get ETA using Google Directions API,make entry on additional note table, send helper ACK to needy
        ///1. get name and additional note
        self.strAnonymousUserName = self.txtAnonymousUserName.text;
        NSString *strAdditionalNote = self.txtAnonymousUserAdditionalText.text;
        
        ///2. remove keyboard if visible
        [self endEditing:YES];
        
        ///3. Hide the popup
        self.vuAnonymousUserDetailsPopupBase.hidden = YES;
        
        ///4. show working button
        [self showWorkingButton];
        
        ///5. get user duration and send response
        [self showRouteUsingAlertPayload:self.alertPayload andAdditionalNote:strAdditionalNote];

        
    }
}

- (IBAction)btnExpandMapTapped:(UIButton *)sender {
    
    if (!self.expandedMapView) {
        ///Create the expanded map if it's not yet created
        ///set google map
        [self addExpandedGoogleMapWithAlertCoordinate:self.alertPayload.alertAddress.coordinate andMarkerTitle:self.alertPayload.strFullName];
    }
    
    ///show the expanded map
    self.vuExpandedMapPlaceholder.hidden = NO;
    self.btnCollapseMap.hidden = NO;
}

- (IBAction)btnCollapseMapTapped:(UIButton *)sender {
    
    self.vuExpandedMapPlaceholder.hidden = YES;
    self.btnCollapseMap.hidden = YES;

}

- (IBAction)btnCloseTapped:(UIButton *)sender {

    ///Cross is tapped so close it without doing anything else
    [self btnCloseAlertTapped:self.btnCloseAlert];
    
    /*
    ///set cross tapped to Yes
    self.crossTapped = YES;
    
    ///Call the cannot help action
    [self btnCannotHelpTapped:self.btnCannotHelp];
     */
    
}

//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtAnonymousUserName) {
        
        [self.txtAnonymousUserAdditionalText becomeFirstResponder];
        return NO;
    }
    else{

        [textField resignFirstResponder];
        return YES;

    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtAnonymousUserName) {
        
        NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (finalString && finalString.length > 0) {
            ///Enable send button
            self.btnSendAnonymousUserDetails.enabled = YES;
        }
        else{
            ///Disable send button
            self.btnSendAnonymousUserDetails.enabled = NO;

        }

        
    }

    return YES;
    
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)keyboarWillShow:(NSNotification *)notif
{
    
    ///if custom additional note popup is visible, move it up by 100 pixel
    if (!self.vuAnonymousUserDetailsPopupBase.isHidden) {
        
        self.cnsAnonymousUserDetailsContainerViewVerticalCenter.constant = -100;
        
    }
    
}

-(void)keyboarWillHide:(NSNotification *)notif
{
    
    ///if custom additional note popup is visible, move it back to original position
    if (!self.vuAnonymousUserDetailsPopupBase.isHidden) {
        
        self.cnsAnonymousUserDetailsContainerViewVerticalCenter.constant = 0;
        
    }
    
}

-(void)enableLocationPopupCancelTapped:(NSNotification *)notif
{
    ///Hide the user distance view
    [self hideUserDistanceView];

    ///Remove cancel action notification observer
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kEnableLocationPopupCancelTappedNotification object:nil];
    
    ///remove the notification observer for foreground
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

}

-(void)locationManagerDidUpdateLocation:(NSNotification *)notif
{
    if(self.shouldSetUserDistanceOnLocationUpdate){
        ///Set this flag to no to avoid setting user distance multiple times
        self.setUserDistanceOnLocationUpdate = NO;
        
        ///remove the notification observer
        [[NSNotificationCenter defaultCenter]removeObserver:self name:kLocationUpdatedNotification object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        
        ///set the user distance now
        [self setUserDistance];
        
        ///unhide the user distance view if it's hidden
        if(self.vuBaseUserDistance.hidden){
            [self showUserDistanceView];
        }
    }
}

-(void)cell411AppWillEnterForeground:(NSNotification *)notif
{
    ///Remove cancel action notification observer
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kEnableLocationPopupCancelTappedNotification object:nil];

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.shouldSetUserDistanceOnLocationUpdate
            && (![[C411LocationManager sharedInstance] isLocationAccessAllowed])) {

            ///remove the notification observer for foreground
            [[NSNotificationCenter defaultCenter]removeObserver:weakSelf name:UIApplicationWillEnterForegroundNotification object:nil];
            
            ///Hide the user distance view
            [weakSelf hideUserDistanceView];
                        
        }
        
    });
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
