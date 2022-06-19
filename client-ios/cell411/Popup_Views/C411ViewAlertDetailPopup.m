//
//  C411ViewAlertDetailPopup.m
//  cell411
//
//  Created by Milan Agarwal on 13/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411ViewAlertDetailPopup.h"
#import "RFGravatarImageView.h"
#import "C411ViewPhotoVC.h"
#import "AppDelegate.h"
#import <OpenInGoogleMaps/OpenInGoogleMapsController.h>
#import "FileDownloader.h"
#import "C411StaticHelper.h"
#import "UIButton+FAB.h"
#import "ConfigConstants.h"
//#import "ServerUtility.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MAAlertPresenter.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ChatHelper.h"
#import "C411ChatVC.h"
#import "C411MyProfileVC.h"
#import "C411UserProfilePopup.h"
#import "C411ColorHelper.h"

#define DISABLED_COLOR @"A4A4A4"

@interface C411ViewAlertDetailPopup ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuGravatar;
@property (weak, nonatomic) IBOutlet UIView *vuConnector;
@property (weak, nonatomic) IBOutlet UITextView *txtVuAlertTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertType;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuClock;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTimestamp;
@property (weak, nonatomic) IBOutlet UIView *vuLocationContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertLocation;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnFlag;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNote;
@property (weak, nonatomic) IBOutlet UILabel *lblMedicalConditionHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroupHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblAllergiesHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblAllergies;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherMedicalConditionsHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherMedicalConditions;
@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *btnDownloadVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnWatchVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigateVideoAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnFakeDeleteVideoAlert;
@property (weak, nonatomic) IBOutlet UIView *vuBaseVideoAlertsFab;
@property (weak, nonatomic) IBOutlet UILabel *lblVideoDownloadProgress;
@property (weak, nonatomic) IBOutlet UIButton *btnSavePhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnViewPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigatePhotoAlert;
@property (weak, nonatomic) IBOutlet UIView *vuBasePhotoAlertFabs;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigateOtherAlert;
@property (weak, nonatomic) IBOutlet UIView *vuBaseOtherAlertFabs;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *medicalConditionsVuTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downloadProgressTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fakeDeleteBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fakeDeleteBtnLSConstraint;
@property (weak, nonatomic) IBOutlet UIView *vuLive;
@property (weak, nonatomic) IBOutlet UIView *vuLiveOuterCircle;
@property (weak, nonatomic) IBOutlet UIView *vuLiveInnerCircle;
@property (weak, nonatomic) IBOutlet UILabel *lblLive;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAlertBaseViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVideoAlertFabContainerBS;

- (IBAction)btnFlagTapped:(UIButton *)sender;
- (IBAction)btnSavePhotoTapped:(UIButton *)sender;
- (IBAction)btnViewPhotoTapped:(UIButton *)sender;
- (IBAction)btnWatchVideoTapped:(UIButton *)sender;
- (IBAction)btnDownloadVideoTapped:(UIButton *)sender;
-(IBAction)btnNavigateTapped:(UIButton *)sender;
- (IBAction)btnFakeDeleteVideoTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;
- (IBAction)btnChatTapped:(UIButton *)sender;

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, assign, getter=isFirstTime) BOOL firstTime;
@property (nonatomic, strong) NSURL *videoUrl;
//@property (nonatomic, strong) NSURLSessionDataTask *getLocationTask;


@end

@implementation C411ViewAlertDetailPopup


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
    self.firstTime = YES;
    [C411StaticHelper removeOnScreenKeyboard];

}

-(void)dealloc
{
    [self unregisterFromNotifications];
//    [self.getLocationTask cancel];
//    self.getLocationTask = nil;
    
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setSelectedCell411Alert:(PFObject *)selectedCell411Alert
{
    _selectedCell411Alert = selectedCell411Alert;
    if (self.isFirstTime) {
        self.firstTime = NO;
        [self setupAlertDetails];
    }
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    
    self.vuLive.layer.borderWidth = 2.0;
    self.vuLiveOuterCircle.layer.borderWidth = 2.0;
    self.btnClose.layer.borderWidth = 1.0;
    
    
   ///Set corner radius
    self.vuAlertBase.layer.cornerRadius = 5.0;
    self.vuAlertBase.layer.masksToBounds = YES;
    self.vuLive.layer.cornerRadius = 3.0;
    self.vuLive.layer.masksToBounds = YES;
    
    
    ///Make circular views
    [C411StaticHelper makeCircularView:self.imgVuGravatar];
    [C411StaticHelper makeCircularView:self.imgVuAlertType];
    [C411StaticHelper makeCircularView:self.vuLiveOuterCircle];
    [C411StaticHelper makeCircularView:self.vuLiveInnerCircle];
    [C411StaticHelper makeCircularView:self.btnChat];
    [C411StaticHelper makeCircularView:self.btnClose];

//    ///set border
//    self.imgVuAlertType.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.imgVuAlertType.layer.borderWidth = 2.0;
    
    ///make FABs
    //[self.btnClose makeFloatingActionButton];
    [self.btnFakeDeleteVideoAlert makeFloatingActionButton];
    [self.btnDownloadVideo makeFloatingActionButton];
    [self.btnWatchVideo makeFloatingActionButton];
    [self.btnNavigateVideoAlert makeFloatingActionButton];
    [self.btnSavePhoto makeFloatingActionButton];
    [self.btnViewPhoto makeFloatingActionButton];
    [self.btnNavigatePhotoAlert makeFloatingActionButton];
    [self.btnNavigateOtherAlert makeFloatingActionButton];
    
    ///Configure flag button
    self.btnFlag.layer.cornerRadius = 3.0;
    self.btnFlag.layer.masksToBounds = YES;
    
    ///set initial strings for localization
    self.lblAlertLocation.text = NSLocalizedString(@"Retreiving City...", nil);
    [self.btnFlag setTitle:NSLocalizedString(@"Spam", nil) forState:UIControlStateNormal];
    self.lblAdditionalNoteHeader.text = NSLocalizedString(@"ADDITIONAL NOTE", nil);
    self.lblMedicalConditionHeader.text = NSLocalizedString(@"MEDICAL CONDITIONS", nil);
    self.lblBloodGroupHeader.text = [NSString localizedStringWithFormat:@"%@:",NSLocalizedString(@"Blood Group", nil)];
    self.lblAllergiesHeader.text = [NSString localizedStringWithFormat:@"%@:",NSLocalizedString(@"Allergies", nil)];
    self.lblOtherMedicalConditionsHeader.text = [NSString localizedStringWithFormat:@"%@:",NSLocalizedString(@"Other Medical Conditions", nil)];
    self.lblLive.text = NSLocalizedString(@"LIVE", nil);

    ///Add tap gesture on avatar image view
    [self addTapGestureOnImageView:self.imgVuGravatar];
    
    ///set height of alert base to 0 initially and hide the cross button for animation to complete
    self.btnClose.hidden = YES;
    self.cnsAlertBaseViewHeight.constant = 0;
    [self applyColors];
}

-(void)updateMapStyle {
    self.mapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
}

-(void)applyColors {
    ///Set background color
    self.vuAlertBase.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    [self updateMapStyle];
    ///Set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.txtVuAlertTitle.textColor = primaryTextColor;
    self.lblAdditionalNoteHeader.textColor = primaryTextColor;
    self.lblAdditionalNote.textColor = primaryTextColor;
    self.lblMedicalConditionHeader.textColor = primaryTextColor;
    self.lblBloodGroupHeader.textColor = primaryTextColor;
    self.lblAllergiesHeader.textColor = primaryTextColor;
    self.lblOtherMedicalConditionsHeader.textColor = primaryTextColor;
    self.lblBloodGroup.textColor = primaryTextColor;
    self.lblAllergies.textColor = primaryTextColor;
    self.lblOtherMedicalConditions.textColor = primaryTextColor;
    self.lblVideoDownloadProgress.textColor = primaryTextColor;
    self.lblAlertLocation.textColor = primaryTextColor;
    
    ///set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblAlertTimestamp.textColor = secondaryTextColor;
    self.imgVuAlertLocation.tintColor = [C411ColorHelper sharedInstance].darkHintIconColor;
    self.imgVuClock.tintColor = [C411ColorHelper sharedInstance].hintIconColor;
    self.vuLocationContainer.backgroundColor = [C411ColorHelper sharedInstance].cardColor;
    
    ///set border color
    UIColor *redColor = [UIColor redColor];
    self.vuLive.layer.borderColor = redColor.CGColor;
    self.vuLiveOuterCircle.layer.borderColor = redColor.CGColor;
    UIColor *blackColor = [UIColor blackColor];
    self.btnClose.layer.borderColor = blackColor.CGColor;
    
    UIColor *fabSelectedColor = [C411ColorHelper sharedInstance].fabSelectedColor;;
    UIColor *fabShadowColor = [C411ColorHelper sharedInstance].fabShadowColor;
    UIColor *fabSelectedTintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;

    self.btnFakeDeleteVideoAlert.backgroundColor = fabSelectedColor;
    self.btnFakeDeleteVideoAlert.layer.shadowColor = fabShadowColor.CGColor;
    self.btnFakeDeleteVideoAlert.tintColor = fabSelectedTintColor;
    self.btnDownloadVideo.backgroundColor = fabSelectedColor;
    self.btnDownloadVideo.layer.shadowColor = fabShadowColor.CGColor;
    self.btnDownloadVideo.tintColor = fabSelectedTintColor;
    self.btnWatchVideo.backgroundColor = fabSelectedColor;
    self.btnWatchVideo.layer.shadowColor = fabShadowColor.CGColor;
    self.btnWatchVideo.tintColor = fabSelectedTintColor;
    self.btnNavigateVideoAlert.backgroundColor = fabSelectedColor;
    self.btnNavigateVideoAlert.layer.shadowColor = fabShadowColor.CGColor;
    self.btnNavigateVideoAlert.tintColor = fabSelectedTintColor;
    self.btnSavePhoto.backgroundColor = fabSelectedColor;
    self.btnSavePhoto.layer.shadowColor = fabShadowColor.CGColor;
    self.btnSavePhoto.tintColor = fabSelectedTintColor;
    self.btnViewPhoto.backgroundColor = fabSelectedColor;
    self.btnViewPhoto.layer.shadowColor = fabShadowColor.CGColor;
    self.btnViewPhoto.tintColor = fabSelectedTintColor;
    self.btnNavigatePhotoAlert.backgroundColor = fabSelectedColor;
    self.btnNavigatePhotoAlert.layer.shadowColor = fabShadowColor.CGColor;
    self.btnNavigatePhotoAlert.tintColor = fabSelectedTintColor;
    self.btnNavigateOtherAlert.backgroundColor = fabSelectedColor;
    self.btnNavigateOtherAlert.layer.shadowColor = fabShadowColor.CGColor;
    self.btnNavigateOtherAlert.tintColor = fabSelectedTintColor;

    ///set dark secondary color
    self.btnChat.backgroundColor = [C411ColorHelper sharedInstance].darkSecondaryColor;
    self.btnChat.tintColor = fabSelectedTintColor;

    UIColor *crossButtonColor = [C411ColorHelper sharedInstance].popupCrossButtonColor;
    self.btnClose.backgroundColor = crossButtonColor;

}

-(void)setupAlertDetails
{
    PFUser *alertIssuedBy = self.selectedCell411Alert[kCell411AlertIssuedByKey];
    ///Hide flag is already spammed
    [self hideFlagIfSpammed];
    
    ///hide/show chat icon
    [self handleChatIconVisibility];
    
    ///show Google Map
    CLLocationCoordinate2D alertCordinate = CLLocationCoordinate2DMake([self.selectedCell411Alert[kCell411AlertLocationKey]latitude], [self.selectedCell411Alert[kCell411AlertLocationKey]longitude]);
    NSString *strAlertIssuerName = [C411StaticHelper getFullNameUsingFirstName:alertIssuedBy[kUserFirstnameKey] andLastName:alertIssuedBy[kUserLastnameKey]];
    [self addGoogleMapWithAlertCoordinate:alertCordinate andMarkerTitle:strAlertIssuerName];
    
    ///Reverse GeoCode location
    NSString *strAlertCity = self.selectedCell411Alert[kCell411AlertCityKey];
    if(strAlertCity.length > 0){
        self.lblAlertLocation.text = strAlertCity;
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            ///update popup height in next runloop
            [weakSelf openPopup];
        }];
    }
    else{
        [self updateLocationUsingCoordinate:alertCordinate];
    }

    
    ///Show Gravatar image
    [self showAlertGravatar];
    
    ///get the alert type
    NSString *strAlertType = self.selectedCell411Alert[kCell411AlertAlertTypeKey];
    ///set border color on gravatar
    UIColor *alertColor = [C411StaticHelper getColorForAlert:strAlertType withColorType:ColorTypeLight];
    self.imgVuGravatar.layer.borderColor = alertColor.CGColor;
    self.imgVuGravatar.layer.borderWidth = 2.0;
    
    ///set background color of line view
    self.vuConnector.backgroundColor = alertColor;
    
    ///set alert image
    self.imgVuAlertType.image = self.imgAlertType;
    
    ///show alert title and timestamp
    self.txtVuAlertTitle.delegate = self;
    NSDictionary *dictLinkTextAttr = @{NSForegroundColorAttributeName:self.txtVuAlertTitle.textColor};
    self.txtVuAlertTitle.linkTextAttributes = dictLinkTextAttr;

    self.txtVuAlertTitle.attributedText = self.strAlertTitle;
    self.lblAlertTimestamp.text = self.strAlertTimestamp;
    
    ///show additional note if available
    NSString *strAdditionalNote = self.selectedCell411Alert[kCell411AlertAdditionalNoteKey];
    if (strAdditionalNote.length > 0) {
        ///Additional Note is available
        self.lblAdditionalNote.text = strAdditionalNote;
    }
    else{
        
        ///Additional note not available, hide it from screen along with heading and BS
        self.lblAdditionalNoteHeader.text = nil;
        self.lblAdditionalNote.text = nil;
        self.medicalConditionsVuTS.constant = 0;
        
    }
    
    ///show medical conditions if it's a medical alert
    if ([strAlertType isEqualToString:kAlertTypeMedical]) {
        
        ///this is a medical alert
        NSString *strBloodGroup = alertIssuedBy[kUserBloodTypeKey];
        if (strBloodGroup.length > 0) {
            
            self.lblBloodGroup.text = strBloodGroup;
        }
        else{
            
            self.lblBloodGroup.text = NSLocalizedString(@"N/A", nil);
        }
        
        NSString *strAllergies = alertIssuedBy[kUserAllergiesKey];
        if (strAllergies.length > 0) {
            
            self.lblAllergies.text = strAllergies;
        }
        else{
            
            self.lblAllergies.text = NSLocalizedString(@"N/A", nil);
        }
       
        NSString *strOMC = alertIssuedBy[kUserOtherMedicalCondtionsKey];
        if (strOMC.length > 0) {
            
            self.lblOtherMedicalConditions.text = strOMC;
        }
        else{
            
            self.lblOtherMedicalConditions.text = NSLocalizedString(@"N/A", nil);
        }
        
        
    }
    else{
        
        ///not a medical alert, hide the medical conditions section
        self.lblMedicalConditionHeader.text = nil;
        self.lblBloodGroupHeader.text = nil;
        self.lblBloodGroup.text = nil;
        self.lblAllergiesHeader.text = nil;
        self.lblAllergies.text = nil;
        self.lblOtherMedicalConditionsHeader.text = nil;
        self.lblOtherMedicalConditions.text = nil;
        self.downloadProgressTS.constant = 0;
        
    }
    
    
    ///Manage the visibility of bottom buttons on the basis of alert type
    ///clear video download progress text initially
    self.lblVideoDownloadProgress.text = nil;
    
    if ([strAlertType isEqualToString:kAlertTypeVideo]) {
        ///this is a video alert
        BOOL isLive = [self.selectedCell411Alert[kCell411AlertStatusKey] isEqualToString:kAlertStatusLive] ? YES : NO;
        if (isLive) {
            
            ///Disable download button and make it grey
            self.btnDownloadVideo.enabled = NO;
            self.btnDownloadVideo.backgroundColor = [C411StaticHelper colorFromHexString:DISABLED_COLOR];
            
            ///hide the delete button
            self.fakeDeleteBtnLSConstraint.constant = 0;
            self.fakeDeleteBtnWidthConstraint.constant = 0;
            
            ///show LIVE Status
            self.vuLive.hidden = NO;
            self.vuLiveOuterCircle.hidden = NO;
        }
        else{
            
            ///hide delete button if fakeDelete option is not enabled by user
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (![defaults boolForKey:kFakeDelete]) {
                
                ///hide the delete button
                self.fakeDeleteBtnLSConstraint.constant = 0;
                self.fakeDeleteBtnWidthConstraint.constant = 0;
                
            }
            
            ///get the download progress
            self.videoUrl = [self.alertDetailPopupDelegate alertDetailPopup:self didRequireVideoURLForAlert:self.selectedCell411Alert];
            
            if (self.videoUrl) {
                
                ///Check the download progess
                NSNumber *downloadProgress = [[FileDownloader sharedDownloader].progressBuffer objectForKey:[self.videoUrl absoluteString]];
                
                if (downloadProgress) {
                    
                    NSInteger downloadProgVal = [downloadProgress doubleValue] * 100;
                    if (downloadProgVal == 100) {
                        
                        ///Video is already downloaded
                        //[self.btnDownloadVideo setTitle:NSLocalizedString(@"Downloaded", nil) forState:UIControlStateNormal];
                        self.lblVideoDownloadProgress.text = NSLocalizedString(@"Downloaded", nil);
                    }
                    else{
                        
                        ///Video is being downloaded, set the download percentage
                        NSString *strDownloadPer = [NSString localizedStringWithFormat:@"%d%%",(int)downloadProgVal];
                        //[self.btnDownloadVideo setTitle:strDownloadPer forState:UIControlStateNormal];
                        self.lblVideoDownloadProgress.text = strDownloadPer;
                        
                    }
                    
                }
            }
            
            
        }
        
        ///Hide the photo and other alerts fab containers
        self.vuBasePhotoAlertFabs.hidden = YES;
        self.vuBaseOtherAlertFabs.hidden = YES;
    }
    else if ([strAlertType isEqualToString:kAlertTypePhoto]){
        ///this is a photo alert
        
        ///Hide the video and other alerts fab containers and delete video button
        self.vuBaseVideoAlertsFab.hidden = YES;
        self.vuBaseOtherAlertFabs.hidden = YES;
        
    }
    else{
        
        ///This is an alert other than video or photo
        
        ///hide video, photo alerts fab containers and delete button
        self.vuBaseVideoAlertsFab.hidden = YES;
        self.vuBasePhotoAlertFabs.hidden = YES;
        
        
    }
    
}

-(void)hideFlagIfSpammed
{
    
    ///Check if current user has already spammed this user or not
    PFUser *alertPerson = self.selectedCell411Alert[kCell411AlertIssuedByKey];
    PFUser *alertForwardedBy = self.selectedCell411Alert[kCell411AlertForwardedByKey];
    
    if (alertForwardedBy) {
        
        ///This is an Needy alert forwarded by someone. Update selected user so that it can be spammed
        alertPerson = alertForwardedBy;
        
    }
    
    if ([alertPerson.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]){
        
        ///this alert is issued by current user, so hide the flag as current user cannot spam himself and return
        self.btnFlag.hidden = YES;
        return;
        
    }
    
    if ([C411StaticHelper isUserDeleted:alertPerson]) {
        ///This alert is issued by deleted user, so hide the spam flag as there is no benifit of spamming deleted user
        self.btnFlag.hidden = YES;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:alertPerson.objectId andCompletion:^(SpamStatus status, NSError *error)
     {
         ///Check whether user is already spammed or not
         if (!error) {
             
             if (status == SpamStatusIsSpammed) {
                 
                 //                 ///This user is already spammed, make it as grey and disable it
                 //
                 //                 [self.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:DISABLED_COLOR]];
                 //                 self.btnFlag.enabled = NO;
                 ///This user is already spammed, hide it
                 weakSelf.btnFlag.hidden = YES;
                 
             }
         }
         else{
             
             ///Error occured while checking whether this user has been already spammed or not
             ///show error
             NSString *errorString = [error userInfo][@"error"];
             [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
         }
         
     }];
    
}

-(void)handleChatIconVisibility
{

#if CHAT_ENABLED

    ///show chat button if chat time is not expired
    NSTimeInterval alertCreatedAtInMillis = [self.selectedCell411Alert.createdAt timeIntervalSince1970] * 1000;
    
    BOOL isChatExpired = ![C411ChatHelper canChatOnAlertIssuedAt:alertCreatedAtInMillis];
    
    if (isChatExpired) {
        ///chat is expired, don't show chat bubble
        self.btnChat.hidden = YES;
        
    }
    else{
        ///chat is not expired, show chat bubble
        self.btnChat.hidden = NO;
    }
    
#else
    self.btnChat.hidden = YES;
#endif

}


-(void)showAlertGravatar
{
    ///Show Gravatar image
    PFUser *alertIssuedBy = self.selectedCell411Alert[kCell411AlertIssuedByKey];
    
//    NSString *strGravatarEmail = [C411StaticHelper getEmailFromUser:alertIssuedBy];
    
    PFUser *alertForwardedBy = self.selectedCell411Alert[kCell411AlertForwardedByKey];
    
    static UIImage *placeHolderImage = nil;
    if (!placeHolderImage) {
        
        placeHolderImage = [UIImage imageNamed:@"logo"];
    }
    ///set the default image first, then fetch the gravatar
    self.imgVuGravatar.image = placeHolderImage;
    
    if (alertForwardedBy) {
        ///This is an alert forwarded by someone, show the gravatar of the forwardedBy person
        
        //strGravatarEmail = [C411StaticHelper getEmailFromUser:alertForwardedBy];
        if (![C411StaticHelper isUserDeleted:alertForwardedBy]) {
            [self.imgVuGravatar setAvatarForUser:alertForwardedBy shouldFallbackToGravatar:YES ofSize:self.imgVuGravatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        }
    }
    else{
        ///This is an alert issued by a user, show the gravatar of the issuer
        if (![C411StaticHelper isUserDeleted:alertIssuedBy]) {
            [self.imgVuGravatar setAvatarForUser:alertIssuedBy shouldFallbackToGravatar:YES ofSize:self.imgVuGravatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        }
    }

//    if (strGravatarEmail.length > 0) {
//        ///Grab avatar image and place it here
//        static UIImage *placeHolderImage = nil;
//        if (!placeHolderImage) {
//            
//            placeHolderImage = [UIImage imageNamed:@"logo"];
//        }
//        self.imgVuGravatar.email = strGravatarEmail;
//        self.imgVuGravatar.placeholder = placeHolderImage;
//        self.imgVuGravatar.defaultGravatar = RFDefaultGravatarUrlSupplied;
//        NSURL *defaultGravatarUrl = [NSURL URLWithString:DEFAULT_GRAVATAR_URL];
//        self.imgVuGravatar.defaultGravatarUrl = defaultGravatarUrl;
//        
//        self.imgVuGravatar.size = self.imgVuGravatar.bounds.size.width * 3;
//        [self.imgVuGravatar load];
//
//    }
    
}

-(void)addGoogleMapWithAlertCoordinate:(CLLocationCoordinate2D)alertCoordinate andMarkerTitle:(NSString *)strMarkerTitle
{
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:alertCoordinate.latitude longitude:alertCoordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //self.mapView.mapType = kGMSTypeHybrid;
    
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
    self.mapView.selectedMarker = alertMarker;
    
    [self.mapView animateToLocation:alertCoordinate];
    [self updateMapStyle];
    
}

-(void)updateMapFrame
{
    float hPadding = 20;
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.bounds.size.width - 2 * hPadding;
    self.mapView.frame = mapFrame;
    self.vuAlertBase.layer.masksToBounds = YES;

}

-(void)spamUser:(PFUser *)user
{
    ///change color and disable spam button
    UIColor *currentColor = self.btnFlag.backgroundColor;
    [self.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:DISABLED_COLOR]];
    self.btnFlag.enabled = NO;
    __weak typeof(self) weakSelf = self;
    
    [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:user.objectId andCompletion:^(SpamStatus status, NSError *error)
     {
         ///Check whether user is already spammed or not
         if (!error) {
             
             if (status == SpamStatusIsSpammed) {
                 
                 ///show alert that this user is already spammed
                 NSString *issuerFullName = [C411StaticHelper getFullNameUsingFirstName:user[kUserFirstnameKey] andLastName:user[kUserLastnameKey]];
                 NSString *strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is already blocked.",nil),issuerFullName];
                 [C411StaticHelper showAlertWithTitle:nil message:strAlertMsg onViewController:[AppDelegate sharedInstance].window.rootViewController];
                 
                 //                 ///Change Color to disabled color and set alpha back to 1
                 //                 [weakSelf.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:DISABLED_COLOR]];
                 //                 weakSelf.btnFlag.alpha = 1.0;
                 ///hide the flag button
                 weakSelf.btnFlag.hidden = YES;
                 
                 ///post notification to observers
                 [[NSNotificationCenter defaultCenter]postNotificationName:kUserBlockedNotification object:user.objectId];
                 
             }
             else if (status == SpamStatusIsNotSpammed) {
                 ///user is not spammed yet, mark him/her as spam
                 PFUser *currentUser = [AppDelegate getLoggedInUser];
                 PFRelation *spamUsersRelation = [currentUser relationForKey:kUserSpamUsersKey];
                 [spamUsersRelation addObject:user];
                 
                 ///save current user object
                 [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                     
                     if (succeeded) {
                         ///user added to current user's spamUsers list
                         ///add a SPAM_ADD task, which has to be performed by user which is being spammed i.e the alert issuer
                         
                         ///1.make an entry in the Task table
                         PFObject *addSpamTask = [PFObject objectWithClassName:kTaskClassNameKey];
                         addSpamTask[kTaskAssigneeUserIdKey] = currentUser.objectId;
                         addSpamTask[kTaskUserIdKey] = user.objectId;
                         addSpamTask[kTaskTaskKey] = kTaskSpamAdd;
                         addSpamTask[kTaskStatusKey] = kTaskStatusPending;
                         [addSpamTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                             
                             if (succeeded) {
                                 
                                 ///SPAM_ADD task created successfully
                                 NSString *issuerFullName = [C411StaticHelper getFullNameUsingFirstName:user[kUserFirstnameKey] andLastName:user[kUserLastnameKey]];
                                 NSString *strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ blocked successfully.",nil),issuerFullName];
                                 [C411StaticHelper showAlertWithTitle:nil message:strAlertMsg onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                 
                                 //                                 ///Change Color to disabled color and set alpha back to 1
                                 //                                 [weakSelf.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:DISABLED_COLOR]];
                                 //                                 weakSelf.btnFlag.alpha = 1.0;
                                 ///hide the flag button
                                 weakSelf.btnFlag.hidden = YES;
                                 
                                 ///post notification to observers
                                 [[NSNotificationCenter defaultCenter]postNotificationName:kUserBlockedNotification object:user.objectId];

                             }
                             else{
                                 ///Unable to create SPAM_ADD task
                                 if (error) {
                                     ///show error
                                     NSString *errorString = [error userInfo][@"error"];
                                     [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                 }
                                 
                                 //                                 ///Reenable button and set alpha back to 1
                                 //                                 weakSelf.btnFlag.enabled = YES;
                                 //                                 weakSelf.btnFlag.alpha = 1.0;
                                 ///Reenable button and set it's color back to old one
                                 weakSelf.btnFlag.enabled = YES;
                                 weakSelf.btnFlag.backgroundColor = currentColor;
                                 
                             }
                             
                             
                         }];
                         
                     }
                     else{
                         ///some error occured marking user as spam
                         if (error) {
                             ///show error
                             NSString *errorString = [error userInfo][@"error"];
                             [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                         }
                         
                         //                         ///Reenable button and set alpha back to 1
                         //                         weakSelf.btnFlag.enabled = YES;
                         //                         weakSelf.btnFlag.alpha = 1.0;
                         
                         ///Reenable button and set it's color back to old one
                         weakSelf.btnFlag.enabled = YES;
                         weakSelf.btnFlag.backgroundColor = currentColor;
                         
                     }
                     
                 }];
                 
                 
             }
         }
         else{
             
             ///Error occured while checking whether this user has been already spammed or not
             ///show error
             NSString *errorString = [error userInfo][@"error"];
             [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
             
             //             ///Reenable button and set alpha back to 1
             //             weakSelf.btnFlag.enabled = YES;
             //             weakSelf.btnFlag.alpha = 1.0;
             ///Reenable button and set it's color back to old one
             weakSelf.btnFlag.enabled = YES;
             weakSelf.btnFlag.backgroundColor = currentColor;
             
         }
         
     }];
    
}


-(void)playVideoUsingAlert:(PFObject *)cell411Alert
{
    NSString *strVideoStreamUrl = nil;
    PFUser *alertIssuer = cell411Alert[kCell411AlertIssuedByKey];
    NSTimeInterval createdAtInMillis = [cell411Alert.createdAt timeIntervalSince1970] * 1000;
    
    NSString *strStreamName = [NSString stringWithFormat:@"%@_%.0lf",alertIssuer.objectId,createdAtInMillis];
//    if ([cell411Alert[kCell411AlertStatusKey] isEqualToString:kAlertStatusLive]) {
//        
//        strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/live/%@/playlist.m3u8",CNAME,strStreamName];
//    }
//    else if ([cell411Alert[kCell411AlertStatusKey] isEqualToString:kAlertStatusVOD]) {
//        
//        strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/vod/%@/playlist.m3u8",CNAME,strStreamName];
//    }
   
    ///using dvr now to fix url issue when switcing to live/vod. dvr option will work for both with same url
    strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/%@/%@/playlist.m3u8?DVR",CNAME,WZA_APP_NAME,strStreamName];

    ///2.Play video
    if (strVideoStreamUrl.length > 0) {
        
        NSURL *videoStreamUrl = [NSURL URLWithString:strVideoStreamUrl];
        if ([[UIApplication sharedApplication]canOpenURL:videoStreamUrl]) {
            
            [[UIApplication sharedApplication]openURL:videoStreamUrl];
            
        }
    }
    
}

-(void)showPhotoUsingAlert:(PFObject *)cell411Alert
{
    ///Show photo VC to view photo alert
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
    viewPhotoVC.photoFile = cell411Alert[kCell411AlertPhotoKey];
    viewPhotoVC.strAdditionalNote = cell411Alert[kCell411AlertAdditionalNoteKey];
    viewPhotoVC.strCell411AlertId = cell411Alert.objectId;
    [navRoot pushViewController:viewPhotoVC animated:YES];
}

-(void)registerForNotifications
{
    [super registerForNotifications];
    
    ///register for notification to listen for download progress and finish download
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didUpdateDownloadProgress:) name:kDidUpdateVideoDownloadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishDownloading:) name:kDidFinishDownloadingVideoNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterFromNotifications
{
    
    [super unregisterFromNotifications];

    if (self.videoUrl) {
        ///Remove observing from notification if Video Url is available as only then we would be observing the notifications
        [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidUpdateVideoDownloadProgressNotification object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidFinishDownloadingVideoNotification object:nil];

    }
}

-(void)updateLocationUsingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
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
        
        ///update popup height
        [weakSelf openPopup];

    }];
    
    /*
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
        
        ///update popup height
        [weakSelf openPopup];
        

        
    }];
     */
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    ///Hide the progress bar
    [MBProgressHUD hideHUDForView:self animated:YES];
    
    if (error) {
        
        [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:[AppDelegate sharedInstance].window.rootViewController];
        
    }
}

-(void)handleInternalUrl:(NSURL *)url
{
    
    ///Parse the url and get the type value to take corresponding action
    NSDictionary *dictParams = [ServerUtility getParamsFromUrl:url];
    
    if (dictParams) {
        
        ///get the type value
        NSString *strType = dictParams[kInternalLinkParamType];
        if ([strType isEqualToString:kInternalLinkParamTypeShowUserProfile]
            || [strType isEqualToString:kInternalLinkParamTypeShowAlertForwarderProfile]) {
            
            PFUser  *alertPerson = self.selectedCell411Alert[kCell411AlertIssuedByKey];
            
            if ([strType isEqualToString:kInternalLinkParamTypeShowAlertForwarderProfile]) {
                
                ///show user profile of alert forwarder
                alertPerson = self.selectedCell411Alert[kCell411AlertForwardedByKey];
                
                
            }
            
            if (alertPerson) {
                
                ///show user profile if alertPerson holds valid user object
                if ([alertPerson.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
                    
                    /* Open it to Show profile of current user
                    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;

                    C411MyProfileVC *myProfileVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411MyProfileVC"];
                    [navRoot pushViewController:myProfileVC animated:YES];
                     */
                    
                }
                else{
                    
                    ///show profile of other user
                    [self showUserProfile:alertPerson];
                }

            
            }
        }
    }
}


-(void)showUserProfile:(PFUser *)user
{
    
    ///Show user profile popup
    C411UserProfilePopup *vuUserProfilePopup = [[[NSBundle mainBundle] loadNibNamed:@"C411UserProfilePopup" owner:self options:nil] lastObject];
    
    vuUserProfilePopup.user = user;
    
    UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
    ///Set view frame
    vuUserProfilePopup.frame = rootVC.view.bounds;
    ///add view
    [rootVC.view addSubview:vuUserProfilePopup];
    [rootVC.view bringSubviewToFront:vuUserProfilePopup];
    
}

-(void)addTapGestureOnImageView:(UIView *)imgVu
{
    ///Enable user interaction to listen tap event
    imgVu.userInteractionEnabled = YES;
    
    ///remove old tap gestures first
    for (UIGestureRecognizer *gestureRecognizer in imgVu.gestureRecognizers) {
        
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            
            [imgVu removeGestureRecognizer:gestureRecognizer];
        }
        
    }
    
    ///Add tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgVuAvatarTapped:)];
    [imgVu addGestureRecognizer:tapRecognizer];
}


-(void)openPopup
{
    float popupHeight = self.vuBaseVideoAlertsFab.frame.origin.y + self.vuBaseVideoAlertsFab.bounds.size.height + self.cnsVideoAlertFabContainerBS.constant;
    self.cnsAlertBaseViewHeight.constant = popupHeight;
    self.btnClose.hidden = NO;
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:NULL];
}

-(void)closePopup{
    
    self.cnsAlertBaseViewHeight.constant = 0;
    [self setNeedsUpdateConstraints];
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        if (weakSelf.actionHandler != NULL) {
            ///call the Close action handler
            weakSelf.actionHandler(weakSelf.btnClose,0,nil);
            
        }
        
        [weakSelf removeFromSuperview];
        weakSelf.actionHandler = NULL;

    }];

}

//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnFlagTapped:(UIButton *)sender {
    
    ///User agreed to flag the selected user as spam
    PFUser *alertPerson = self.selectedCell411Alert[kCell411AlertIssuedByKey];
    PFUser *alertForwardedBy = self.selectedCell411Alert[kCell411AlertForwardedByKey];
    
    if (alertForwardedBy) {
        
        ///This is an Needy alert forwarded by someone. Update selected user so that it can be spammed
        alertPerson = alertForwardedBy;
        
    }
    
    ///show the confirmation dialog first
    NSString *strAlertPersonName = [C411StaticHelper getFullNameUsingFirstName:alertPerson[kUserFirstnameKey] andLastName:alertPerson[kUserLastnameKey]];
    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to flag %@ as a spammer?",nil),strAlertPersonName];
    UIAlertController *confirmSpamAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///user said No, do nothing
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///User opted to spam the user
        [self spamUser:alertPerson];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    [confirmSpamAlert addAction:noAction];
    [confirmSpamAlert addAction:yesAction];
    //[[AppDelegate sharedInstance].window.rootViewController presentViewController:confirmSpamAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmSpamAlert];

}

- (IBAction)btnSavePhotoTapped:(UIButton *)sender {
    
    ///download and save the photo in gallery
    PFFileObject *photoFile = self.selectedCell411Alert[kCell411AlertPhotoKey];
    if (photoFile) {
        __weak typeof(self) weakSelf = self;
        ///show loading screen
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        
        ///Get photo file
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError * error){
            
            if (!error) {
                
                ///make image from data
                if (data) {
                    
                    UIImage *image = [UIImage imageWithData:data];
                    
                    if (image) {
                        
                        ///Save image to photos album
                        UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                        
                    }
                    else{
                        
                        NSString *errorString = NSLocalizedString(@"Unable to load the photo", nil);
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        
                        ///Hide the progress bar
                        [MBProgressHUD hideHUDForView:weakSelf animated:YES];
                    }
                    
                    
                    
                }
                else{
                    
                    NSString *errorString = NSLocalizedString(@"Unable to load the photo", nil);
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                    ///Hide the progress bar
                    [MBProgressHUD hideHUDForView:weakSelf animated:YES];
                }
                
                
            }
            else {
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                
                ///Hide the progress bar
                [MBProgressHUD hideHUDForView:weakSelf animated:YES];
            }
            
        }];
        
    }
    
}

- (IBAction)btnViewPhotoTapped:(UIButton *)sender {
    
    [self showPhotoUsingAlert:self.selectedCell411Alert];
    
}

- (IBAction)btnWatchVideoTapped:(UIButton *)sender {
    
    [self playVideoUsingAlert:self.selectedCell411Alert];
    
}

- (IBAction)btnDownloadVideoTapped:(UIButton *)sender {
    
    [self.alertDetailPopupDelegate alertDetailPopup:self downloadVideoAtIndex:self.alertRowIndex];
    
}

- (IBAction)btnNavigateTapped:(UIButton *)sender {
    
    CLLocationCoordinate2D alertCordinate = CLLocationCoordinate2DMake([self.selectedCell411Alert[kCell411AlertLocationKey]latitude], [self.selectedCell411Alert[kCell411AlertLocationKey]longitude]);
    
    GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
    definition.destinationPoint = [GoogleDirectionsWaypoint
                                   waypointWithLocation:alertCordinate];
    definition.travelMode = kGoogleMapsTravelModeDriving;
    BOOL isOpened = [[OpenInGoogleMapsController sharedInstance] openDirections:definition];
    
    if(!isOpened){
        
        ///Get the cross-platform maps url to open
        NSString *strLatLong = [NSString stringWithFormat:@"%lf,%lf",alertCordinate.latitude,alertCordinate.longitude];
        NSDictionary *dictParams = @{kGoogleMapsDestinationKey : strLatLong,
                                     kGoogleMapsTravelModeKey : kGoogleMapsTravelModeValueDriving};
        NSURL *directionsUrl = [C411StaticHelper getGoogleMapsDirectionsUrlForAllPlatforms:dictParams];
        
        if([[UIApplication sharedApplication]canOpenURL:directionsUrl]){
        
            [[UIApplication sharedApplication]openURL:directionsUrl];
            
        }
        
    }
    
}

- (IBAction)btnFakeDeleteVideoTapped:(UIButton *)sender {
    
    [self.alertDetailPopupDelegate alertDetailPopup:self fakeDeleteVideoAtIndex:self.alertRowIndex];
    
    [self removeFromSuperview];
    self.actionHandler = NULL;
    
}

- (IBAction)btnCloseTapped:(UIBarButtonItem *)sender {
    
    [self closePopup];
    
}

- (IBAction)btnChatTapped:(UIButton *)sender {
    
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;

    C411ChatVC *chatVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
    chatVC.entityType = ChatEntityTypeAlert;
    chatVC.strEntityId = self.selectedCell411Alert.objectId;
    chatVC.strEntityName = self.selectedCell411Alert[kCell411AlertAlertTypeKey];
    chatVC.entityCreatedAtInMillis = [self.selectedCell411Alert.createdAt timeIntervalSince1970] * 1000;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:chatVC animated:YES];

}


- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    
    ///This is an alert other than Custom alert
    PFUser *alertIssuedBy = self.selectedCell411Alert[kCell411AlertIssuedByKey];
    PFUser *alertForwardedBy = self.selectedCell411Alert[kCell411AlertForwardedByKey];
    PFUser *alertPerson = nil;
    
    if (alertForwardedBy) {
        ///This is an alert forwarded by someone, show the gravatar of the forwardedBy person
        alertPerson = alertForwardedBy;
    }
    else{
        ///This is an alert issued by a user, show the gravatar of the issuer
        alertPerson = alertIssuedBy;
    }
    
    if (![C411StaticHelper isUserDeleted:alertPerson]) {
        ///Show photo VC to view photo alert
        UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
        C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
        viewPhotoVC.user = alertPerson;
        [navRoot pushViewController:viewPhotoVC animated:YES];
    }
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)didUpdateDownloadProgress:(NSNotification *)notif
{
    NSDictionary *dictDownloadProgress = notif.object;
    NSNumber *downloadProgress = [dictDownloadProgress objectForKey:self.videoUrl];
    if (downloadProgress) {
        
        NSInteger downloadProgVal = [downloadProgress doubleValue] * 100;
        
        NSString *strDownloadPer = [NSString localizedStringWithFormat:@"%d%%",(int)downloadProgVal];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.btnDownloadVideo setTitle:strDownloadPer forState:UIControlStateNormal];
            self.lblVideoDownloadProgress.text = strDownloadPer;
        });
        
    }
    
}

-(void)didFinishDownloading:(NSNotification *)notif
{
    NSURL *videoUrl = notif.object;
    if ([self.videoUrl isEqual:videoUrl]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[self.btnDownloadVideo setTitle:NSLocalizedString(@"Downloaded", nil) forState:UIControlStateNormal];
            self.lblVideoDownloadProgress.text = NSLocalizedString(@"Downloaded", nil);
            
            
        });
        
    }
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


//****************************************************
#pragma mark - UITextViewDelegate Methods
//****************************************************

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    // Call your method here.
    [self handleInternalUrl:URL];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    // Call your method here.
    [self handleInternalUrl:URL];
    return NO;
    
}


@end
