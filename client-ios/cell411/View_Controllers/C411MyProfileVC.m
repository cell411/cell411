//
//  C411MyProfileVC.m
//  cell411
//
//  Created by Milan Agarwal on 25/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411MyProfileVC.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ServerUtility.h"
#import "C411EditProfileVC.h"
#import "AppDelegate.h"
#import "MAGProgressView.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "MAAlertPresenter.h"
#import "UIImage+ResizeAdditions.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411AddPhoneVC.h"
#import "C411ColorHelper.h"
#if PHONE_VERIFICATION_ENABLED
#import "C411PhoneVerificationVC.h"
#endif


@interface C411MyProfileVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgVuHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCity;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuContactNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblContactNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuBloodGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroupHeading;
@property (weak, nonatomic) IBOutlet UIView *vuBloodGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroupVal;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmergencyContactName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmergencyConactNameHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblEmergencyConactName;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmergencyContactNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblEmergencyContactNumberHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblEmergencyContactNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAllergies;
@property (weak, nonatomic) IBOutlet UILabel *lblAllergiesHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblAllergies;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuOtherMedicalConditions;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherMedicalConditionsHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherMedicalConditions;
@property (weak, nonatomic) IBOutlet UIButton *btnEditAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPhoneVerified;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneNotVerifiedIndicator;
@property (weak, nonatomic) IBOutlet UIView *vuRedBlink;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblProfileStrengthHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblProfileStrengthValue;
@property (weak, nonatomic) IBOutlet UIView *vuProfileStrengthProgressContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsProfileStrengthHeadingTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVuProfileStrengthTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVuProfileStrengthHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVuProfileStrengthLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVuProfileStrengthTrailingSpace;

- (IBAction)barBtnEditProfileTapped:(UIBarButtonItem *)sender;
- (IBAction)btnEditAvatarTapped:(UIButton *)sender;
- (IBAction)btnPhoneNotVerifiedIndicatorTapped:(UIButton *)sender;
- (IBAction)btnAddPhoneTapped:(UIButton *)sender;

#if PATROL_FEATURE_ENABLED
@property (nonatomic, strong) MAGProgressView *vuProfileStrength;
#endif

@end
@implementation C411MyProfileVC



//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViews];
    [self fillDetails];
    [self registerForNotifications];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;
    
}

-(void)dealloc
{
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************
#if PATROL_FEATURE_ENABLED
-(MAGProgressView *)vuProfileStrength
{
    if(!_vuProfileStrength){
        CGRect progressViewFrame = CGRectZero;
        progressViewFrame.size.width = self.view.bounds.size.width - (self.cnsVuProfileStrengthLS.constant + self.cnsVuProfileStrengthTrailingSpace.constant);
        progressViewFrame.size.height = self.vuProfileStrengthProgressContainer.bounds.size.height;
        MAGProgressView *progressView = [[MAGProgressView alloc]initWithFrame:progressViewFrame withDivisions:4];

        progressView.progress = 0;
        progressView.curvaceousness = 0;
        progressView.progressTintColor = [C411ColorHelper sharedInstance].themeColor;
        progressView.progressTintGradientEndColor = [C411ColorHelper sharedInstance].secondaryColor;
        progressView.displayGradient = YES;
        _vuProfileStrength = progressView;
    }
    return _vuProfileStrength;
}
#endif

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myProfileUpdated:) name:kMyProfileUpdatedNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(phoneAddedOrUpdatedNotification:) name:kPhoneAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(phoneAddedOrUpdatedNotification:) name:kPhoneUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)configureViews
{
    self.title = NSLocalizedString(@"View Profile", nil);
    if (@available(iOS 11, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        ///Above line is commented to disable large title temporarily to fix an issue(Navigation bar background color gets cleared for large titles) until we switch to Xcode 11 having base SDK as iOS 13 for compilation that provides the new UINavigationBarAppearance Class using which we can set same appearance for all scrollEdgeAppearance, standardAppearance and compactAppearance to resolve the issue as provided here: https://stackoverflow.com/a/56696967/3412051
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    [C411StaticHelper makeCircularView:self.btnEditAvatar];
    [C411StaticHelper makeCircularView:self.btnPhoneNotVerifiedIndicator];
    [C411StaticHelper makeCircularView:self.vuRedBlink];

    ///Make rounded views
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    [C411StaticHelper makeCircularView:self.vuBloodGroup];
    
    ///set corner radius
    self.btnAddPhone.layer.cornerRadius = 3.0;
    self.btnAddPhone.layer.masksToBounds = YES;

#if PATROL_FEATURE_ENABLED
    ///Add Profile strength View
    [self.vuProfileStrengthProgressContainer addSubview:self.vuProfileStrength];
#else
    ///Hide the profile strength option
    self.lblProfileStrengthHeading.text = nil;
    self.lblProfileStrengthValue.text = nil;
    self.cnsProfileStrengthHeadingTS.constant = 0;
    self.cnsVuProfileStrengthTS.constant = 0;
    self.cnsVuProfileStrengthHeight.constant = 0;
#endif
    
    [self applyColors];
}

-(void)applyColors {
    ///Set BG color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set navigation header image
    self.imgVuHeader.image = [C411ColorHelper sharedInstance].imgNavHeader;
    
    ///Set text color on primary BG
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblFullName.textColor = primaryBGTextColor;
    self.lblEmail.textColor = primaryBGTextColor;
    self.lblBloodGroupVal.textColor = primaryBGTextColor;
    [self.btnAddPhone setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    self.btnAddPhone.tintColor = primaryBGTextColor;
    self.btnEditAvatar.tintColor = primaryBGTextColor;
    
    ///Set hint icon color
    UIColor *hintIconColor = [C411ColorHelper sharedInstance].hintIconColor;
    self.imgVuCity.tintColor = hintIconColor;
    self.imgVuContactNumber.tintColor = hintIconColor;
    
    ///Set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblProfileStrengthHeading.textColor = primaryTextColor;
    self.lblBloodGroupHeading.textColor = primaryTextColor;
    self.lblEmergencyConactNameHeading.textColor = primaryTextColor;
    self.lblEmergencyContactNumberHeading.textColor = primaryTextColor;
    self.lblAllergiesHeading.textColor = primaryTextColor;
    self.lblOtherMedicalConditionsHeading.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblCity.textColor = secondaryTextColor;
    self.lblContactNumber.textColor = secondaryTextColor;
    self.lblProfileStrengthValue.textColor = secondaryTextColor;
    self.lblEmergencyConactName.textColor = secondaryTextColor;
    self.lblEmergencyContactNumber.textColor = secondaryTextColor;
    self.lblAllergies.textColor = secondaryTextColor;
    self.lblOtherMedicalConditions.textColor = secondaryTextColor;

    ///Set dark hint color
    UIColor *darkHintIconColor = [C411ColorHelper sharedInstance].darkHintIconColor;
    self.imgVuBloodGroup.tintColor = darkHintIconColor;
    self.imgVuEmergencyContactName.tintColor = darkHintIconColor;
    self.imgVuEmergencyContactNumber.tintColor = darkHintIconColor;
    self.imgVuAllergies.tintColor = darkHintIconColor;
    self.imgVuOtherMedicalConditions.tintColor = darkHintIconColor;
    
    ///set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuBloodGroup.backgroundColor = themeColor;
    self.btnEditAvatar.backgroundColor = themeColor;
    self.btnAddPhone.backgroundColor = themeColor;
    
    ///Set light theme color to phone not verified
    self.btnPhoneNotVerifiedIndicator.backgroundColor = [C411ColorHelper sharedInstance].lightThemeColor;
}

-(void)fillDetails
{
    ///hide phone verification indicatros initially
    self.imgVuPhoneVerified.hidden = YES;
    self.btnPhoneNotVerifiedIndicator.hidden = YES;
    self.vuRedBlink.hidden = YES;
    
    ///hide add phone button initially
    self.btnAddPhone.hidden = YES;

#if (!CUSTOM_PIC_ENABLED)
    self.btnEditAvatar.hidden = YES;
#endif
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    __weak typeof(self) weakSelf = self;

    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (object) {
            ///get user email
            NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
//            if (strEmail.length > 0) {
//                ///show user avatar or Gravatar
//                [C411StaticHelper getGravatarForEmail:strEmail ofSize:(weakSelf.imgVuAvatar.bounds.size.width * 3) roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//                    
//                    if (success && image) {
//                        
//                        weakSelf.imgVuAvatar.image = image;
//                        
//                    }
//                    
//                }];
//
//            }
            [weakSelf.imgVuAvatar setAvatarForUser:currentUser shouldFallbackToGravatar:YES ofSize:(weakSelf.imgVuAvatar.bounds.size.width * 3) roundedCorners:NO withCompletion:NULL];

            ///show full name
            NSString *strFirstName = currentUser[kUserFirstnameKey];
            NSString *strLastName = currentUser[kUserLastnameKey];
            weakSelf.lblFullName.text = [C411StaticHelper getFullNameUsingFirstName:strFirstName andLastName:strLastName];
            
            ///show user email
            weakSelf.lblEmail.text = strEmail;
            
            ///show city, using reverse geocoding
            PFGeoPoint *userLocation = currentUser[kUserLocationKey];
            GMSGeocoder *geoCoder = [GMSGeocoder geocoder];
            [geoCoder reverseGeocodeCoordinate:CLLocationCoordinate2DMake(userLocation.latitude, userLocation.longitude) completionHandler:^(GMSReverseGeocodeResponse * _Nullable geoCodeResponse, NSError * _Nullable error) {
                
                if (!error && geoCodeResponse) {
                    //NSLog(@"#Succeed: resp= %@\nerr=%@",geoCodeResponse,error);
                    
                    ///Get first available address
                    GMSAddress *firstAddress = [geoCodeResponse firstResult];
                    
                    if (!firstAddress && ([geoCodeResponse results].count > 0)) {
                        ///Additional handling to fallback to get address from array if in any case first result gives nil
                        firstAddress = [[geoCodeResponse results]firstObject];
                        
                    }
                    
                    if(firstAddress){
                        
                        weakSelf.lblCity.text = firstAddress.locality;
                    }
                    else{
                        
                        weakSelf.lblCity.text = NSLocalizedString(@"N/A", nil);
                    }
                    
                }
                else{
                    
                    NSLog(@"#Failed: resp= %@\nerr=%@",geoCodeResponse,error);
                }
                
                
            }];
            
            /*
            NSString *strLatLong = [NSString stringWithFormat:@"%f,%f",userLocation.latitude,userLocation.longitude];
            [ServerUtility getAddressForCoordinate:strLatLong andCompletion:^(NSError *error, id data) {
                
                if (!error && data) {
                    
                    NSArray *results=[data objectForKey:kGeocodeResultsKey];
                    
                    if([results count]>0){
                        
                        NSDictionary *address=[results firstObject];
                        NSArray *addcomponents=[address objectForKey:kGeocodeAddressComponentsKey];
                        
                        weakSelf.lblCity.text = [C411StaticHelper getAddressCompFromResult:addcomponents forType:kGeocodeTypeLocality useLongName:YES];
                    }
                    else{
                        
                         weakSelf.lblCity.text = NSLocalizedString(@"N/A", nil);
                    }
                    
                }
                
            }];
             */
            
            ///show phone number
            NSString *strContactNumber = currentUser[kUserMobileNumberKey];
            if (strContactNumber.length > 0) {
                
                ///Contact number is available
                weakSelf.lblContactNumber.text = strContactNumber;
                
#if PHONE_VERIFICATION_ENABLED
                BOOL isPhoneVerified = [currentUser[kUserPhoneVerifiedKey]boolValue];
                if (isPhoneVerified) {
                    
                    ///Show the verified icon
                    weakSelf.imgVuPhoneVerified.hidden = NO;
                }
                else{
                    
                    ///Show phone verification indicator
                    [weakSelf showPhoneVerificationIndicator];
                }
#endif

            }
            else{
                
                ///Contact number is not available
                weakSelf.lblContactNumber.text = NSLocalizedString(@"N/A", nil);
                
                ///Show Add button
                self.btnAddPhone.hidden = NO;

            }
            
            ///show emergency contact name
            NSString *strEmergencyContactName = currentUser[kUserEmergencyContactNameKey];
            if (strEmergencyContactName.length > 0) {
                
                weakSelf.lblEmergencyConactName.text = strEmergencyContactName;
            }
            else{
                
                weakSelf.lblEmergencyConactName.text = NSLocalizedString(@"N/A", nil);
            }
            
            ///show emergency contact number
            NSString *strEmergencyContactNumber = currentUser[kUserEmergencyContactNumberKey];
            if (strEmergencyContactNumber.length > 0) {
                
                weakSelf.lblEmergencyContactNumber.text = strEmergencyContactNumber;
            }
            else{
                
                weakSelf.lblEmergencyContactNumber.text = NSLocalizedString(@"N/A", nil);
            }
           
            ///show blood group
            NSString *strBloodType = currentUser[kUserBloodTypeKey];
            if (strBloodType.length > 0) {
                
                weakSelf.lblBloodGroupVal.text = strBloodType;
            }
            else{
                
                weakSelf.lblBloodGroupVal.text = NSLocalizedString(@"N/A", nil);
            }
            
            ///show allergies
            NSString *strAllergies = currentUser[kUserAllergiesKey];
            if (strAllergies.length > 0) {
                
                weakSelf.lblAllergies.text = strAllergies;
            }
            else{
                
                weakSelf.lblAllergies.text = NSLocalizedString(@"N/A", nil);
            }

            ///show Other Medical Conditions
            NSString *strOMC = currentUser[kUserOtherMedicalCondtionsKey];
            if (strOMC.length > 0) {
                
                weakSelf.lblOtherMedicalConditions.text = strOMC;
            }
            else{
                
                weakSelf.lblOtherMedicalConditions.text = NSLocalizedString(@"N/A", nil);
            }
#if PATROL_FEATURE_ENABLED
            ///Update the profile strength
            [weakSelf updateProfileStrength];
#endif
        }
        else{
            
            if (error) {
                
                if(![AppDelegate handleParseError:error]){
                    // Show the errorString somewhere and let the user try again.
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                }
                
            }
            
        }
        
        
    }];

}

#if PATROL_FEATURE_ENABLED
-(void)updateProfileStrength
{
    NSUInteger profileStrengthPercent = 0;
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
    if(strEmail.length > 0){
        profileStrengthPercent+= 10;
    }

#if CUSTOM_PIC_ENABLED
    NSNumber *imageNameNum = currentUser[kUserImageNameKey];
    if (imageNameNum) {
        profileStrengthPercent+= 10;
    }
#endif
    
    NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
    if(strFullName.length > 0){
        profileStrengthPercent+= 10;
    }
    
    PFGeoPoint *userLocation = currentUser[kUserLocationKey];
    if(userLocation){
        profileStrengthPercent+= 10;
    }
    
    NSString *strContactNumber = currentUser[kUserMobileNumberKey];
    if (strContactNumber.length > 0) {
         ///Contact number is available
#if PHONE_VERIFICATION_ENABLED
        BOOL isPhoneVerified = [currentUser[kUserPhoneVerifiedKey]boolValue];
        if (isPhoneVerified) {
            ///Phone number is available and verified, increase the profile strength
            profileStrengthPercent+= 10;
        }
#endif
    }

    NSString *strEmergencyContactName = currentUser[kUserEmergencyContactNameKey];
    if (strEmergencyContactName.length > 0) {
        
        profileStrengthPercent+= 10;
    }
    
    NSString *strEmergencyContactNumber = currentUser[kUserEmergencyContactNumberKey];
    if (strEmergencyContactNumber.length > 0) {
        
        profileStrengthPercent+= 10;
    }
    
    NSString *strBloodType = currentUser[kUserBloodTypeKey];
    if (strBloodType.length > 0) {
        
        profileStrengthPercent+= 10;
    }
    
    NSString *strAllergies = currentUser[kUserAllergiesKey];
    if (strAllergies.length > 0) {
        
        profileStrengthPercent+= 10;
    }
    
    NSString *strOMC = currentUser[kUserOtherMedicalCondtionsKey];
    if (strOMC.length > 0) {
        
        profileStrengthPercent+= 10;
    }

    self.vuProfileStrength.progress = profileStrengthPercent / 100.0;
    self.lblProfileStrengthValue.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d%% completed", nil),(int)profileStrengthPercent];
}
#endif

-(void)showPhoneVerificationIndicator
{

#if PHONE_VERIFICATION_ENABLED
    
    ///cancel any previous animation
    [self.vuRedBlink.layer removeAllAnimations];
    
    ///Show the verify phone indicator
    self.btnPhoneNotVerifiedIndicator.hidden = NO;
    self.vuRedBlink.hidden = NO;
    [UIView animateKeyframesWithDuration:1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationCurveEaseInOut animations:^{
        self.vuRedBlink.alpha = 0;
    } completion:^(BOOL finished) {
    }];

#endif


}

-(void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType animated:(BOOL)animated
{
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
    
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    __weak typeof(self) weakSelf = self;
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        [weakSelf presentViewController:imagePickerController animated:animated completion:nil];
    }];
    
    
}


-(void)showImagePickerActionSheet
{
    ///Show photo picker selection action sheet
    UIAlertController *photoPickerType = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    ///Add Camera action
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakSelf showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera animated:YES];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [photoPickerType addAction:cameraAction];
    
    ///Add Gallery action
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Gallery", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [weakSelf showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary animated:YES];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [photoPickerType addAction:galleryAction];
    
    ///Add cancel button action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///Do anything to be done on cancel
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [photoPickerType addAction:cancelAction];
    
    ///Present action sheet
    //[self presentViewController:photoPickerType animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:photoPickerType];
    
    
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    // [self dismissViewControllerAnimated:YES completion:nil];
    
    float maxImageWidth = 1080;
    float maxImageHeight = 1920;
    
    if ((selectedImage.size.width > maxImageWidth)
        ||(selectedImage.size.height > maxImageHeight)) {
        
        ///Down Scale the image
        selectedImage = [selectedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(maxImageWidth, maxImageHeight) interpolationQuality:kCGInterpolationHigh];
    }
    
    
    ///Compress the image
    float compressionQuality = 0.5;
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, compressionQuality);
    selectedImage = [UIImage imageWithData:imageData];
    
    if (selectedImage) {
        
        ///upload this image
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *strImageName = @"";
        NSNumber *avatarImageNameNum = currentUser[kUserImageNameKey];
        if (avatarImageNameNum) {
                
            strImageName = [NSString stringWithFormat:@"%d",[avatarImageNameNum intValue] + 1];
        }
        else{
            
            strImageName = @"1";
        }
        __weak typeof(self) weakSelf = self;
        [ServerUtility uploadImage:imageData withType:IMAGE_TYPE_AVATAR imageName:strImageName forUserWithId:currentUser.objectId withCompletion:^(NSError *error, id data) {
            
            if (!error) {
                
                if ([C411StaticHelper validateAndProcessBackendResponse:data]) {
                    
                    ///image uploaded successfully,increment the counter on parse and post notification for image updation
                       weakSelf.imgVuAvatar.image = selectedImage;
                        [currentUser incrementKey:kUserImageNameKey];
                    
                    ///update on Parse
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            
                            ///save it eventually
                            [currentUser saveEventually];
                        }
                        
                        ///hide the hud
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        
                           ///Post notification
                            [[NSNotificationCenter defaultCenter]postNotificationName:kMyProfileUpdatedNotification object:nil];
                            
                       
                        
                    }];
                    
                    
                    
                    
                }
                else{
                    
                    ///hide the hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                }
            }
            else{
                
                ///Show the error
                [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                
                ///hide the hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
            }
            
        }];
        
        
    }
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}



//****************************************************
#pragma mark - Action Methods
//****************************************************
- (IBAction)barBtnEditProfileTapped:(UIBarButtonItem *)sender {

    C411EditProfileVC *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411EditProfileVC"];
    editProfileVC.previousVC = self;

    [self.navigationController pushViewController:editProfileVC animated:YES];
}

- (IBAction)btnEditAvatarTapped:(UIButton *)sender {
    
#if CUSTOM_PIC_ENABLED
 [self showImagePickerActionSheet];
#endif

}

- (IBAction)btnPhoneNotVerifiedIndicatorTapped:(UIButton *)sender {
    
#if PHONE_VERIFICATION_ENABLED
    ///Show the alert and on yes go to the phobe verification screen
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Verification Required", nil) message:NSLocalizedString(@"Please verify your phone", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Do it later", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///User tapped to do it later
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    UIAlertAction *verifyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Verify", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///User is ready to verify, show the phone verification screen
        C411PhoneVerificationVC *phoneVerificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PhoneVerificationVC"];
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *strContactNumber = currentUser[kUserMobileNumberKey];
        phoneVerificationVC.strContactNumber = strContactNumber;
        __weak typeof(self) weakSelf = self;
        phoneVerificationVC.verificationCompletionHandler = ^{
            ///Pop out all the VC on top of current VC i.e phone verification vc
            [weakSelf.navigationController popToViewController:weakSelf animated:YES];
        };

        [self.navigationController pushViewController:phoneVerificationVC animated:YES];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [alertController addAction:laterAction];
    [alertController addAction:verifyAction];
    
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
#endif
   
    
}

- (IBAction)btnAddPhoneTapped:(UIButton *)sender {
    
    C411AddPhoneVC *addPhoneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411AddPhoneVC"];
#if PHONE_VERIFICATION_ENABLED
    
    __weak typeof(self) weakSelf = self;
    addPhoneVC.verificationCompletionHandler = ^{
        ///Pop out all the VC on top of current VC i.e add phone vc and verification vc
        [weakSelf.navigationController popToViewController:weakSelf animated:YES];
    };

#endif

    [self.navigationController pushViewController:addPhoneVC animated:YES];
    
}


//****************************************************
#pragma mark - Notifications Methods
//****************************************************

-(void)myProfileUpdated:(NSNotification *)notif
{
    [self fillDetails];
}



-(void)phoneAddedOrUpdatedNotification:(NSNotification *)notif
{
    ///set the phone number
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strContactNumber = currentUser[kUserMobileNumberKey];
    if (strContactNumber.length > 0) {
        
        ///Contact number is available
        self.lblContactNumber.text = strContactNumber;
        
        ///hide the add phone button
        self.btnAddPhone.hidden = YES;
       
#if PHONE_VERIFICATION_ENABLED
        ///From cell 411 version > 7.4  a number can be added or updated after it is verified, so it can be marked as verified if phone verification is enabled
        [self.vuRedBlink.layer removeAllAnimations];
        self.btnPhoneNotVerifiedIndicator.hidden = YES;
        self.vuRedBlink.hidden = YES;
        self.imgVuPhoneVerified.hidden = NO;
    
#endif

        
    }
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
