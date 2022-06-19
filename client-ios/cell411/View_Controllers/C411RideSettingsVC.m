//
//  C411RideSettingsVC.m
//  cell411
//
//  Created by Milan Agarwal on 25/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideSettingsVC.h"
#import "C411StaticHelper.h"
#import "Constants.h"
//#import "ServerUtility.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "MAAlertPresenter.h"
#import "C411PhoneVerificationVC.h"
#import "UIImage+ResizeAdditions.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411AddPhoneVC.h"
#import "C411ColorHelper.h"
#define TXT_TAG_ALERT_CHG_CURRENCY     301

@interface C411RideSettingsVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnEditAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCity;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblContactNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPhoneVerified;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoneNotVerifiedIndicator;
@property (weak, nonatomic) IBOutlet UIView *vuRedBlink;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCar;
@property (weak, nonatomic) IBOutlet UIButton *btnEditCarImage;
@property (weak, nonatomic) IBOutlet UILabel *lblConfigureCost;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupCost;
@property (weak, nonatomic) IBOutlet UITextField *txtPickupCost;
@property (weak, nonatomic) IBOutlet UIView *vuPickupCostSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblCostPerMin;
@property (weak, nonatomic) IBOutlet UITextField *txtCostPerMin;
@property (weak, nonatomic) IBOutlet UIView *vuCostPerMinSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblCostPerMileOrKm;
@property (weak, nonatomic) IBOutlet UITextField *txtCostPerMile;
@property (weak, nonatomic) IBOutlet UIView *vuCostPerMileSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentModeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentModeSubtitle;
@property (weak, nonatomic) IBOutlet UIView *vuCashContainer;
@property (weak, nonatomic) IBOutlet UIView *vuCashImgContainer;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnCash;

@property (weak, nonatomic) IBOutlet UIView *vuSilverContainer;
@property (weak, nonatomic) IBOutlet UIView *vuSilverImgContainer;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnSilver;

@property (weak, nonatomic) IBOutlet UIView *vuCryptoContainer;
@property (weak, nonatomic) IBOutlet UIView *vuCryptoImgContainer;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnCrypto;

@property (weak, nonatomic) IBOutlet UIView *vuBarteringContainer;
@property (weak, nonatomic) IBOutlet UIView *vuBarteringImgContainer;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnBartering;

@property (weak, nonatomic) IBOutlet UIView *vuCreditCardContainer;
@property (weak, nonatomic) IBOutlet UIView *vuCreditCardImgContainer;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnCreditCard;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;
@property (strong, nonatomic) IBOutlet UIToolbar *tlbrHideKeyboard;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeCurrency;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupCostCurrency;
@property (weak, nonatomic) IBOutlet UILabel *lblCostPerMinCurrency;
@property (weak, nonatomic) IBOutlet UILabel *lblCostPerMileCurrency;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhone;


- (IBAction)btnEditAvatarTapped:(UIButton *)sender;
- (IBAction)btnPhoneNotVerifiedIndicatorTapped:(UIButton *)sender;
- (IBAction)btnEditCarImageTapped:(UIButton *)sender;
- (IBAction)tglBtnCashTapped:(UIButton *)sender;
- (IBAction)tglBtnSilverTapped:(UIButton *)sender;
- (IBAction)tglBtnCryptoTapped:(UIButton *)sender;
- (IBAction)tglBtnBarteringTapped:(UIButton *)sender;
- (IBAction)tglBtnCreditCardTapped:(UIButton *)sender;
- (IBAction)btnUpdateTapped:(UIButton *)sender;
- (IBAction)barBtnDoneTapped:(UIBarButtonItem *)sender;
- (IBAction)btnChangeCurrencyTapped:(UIButton *)sender;
- (IBAction)btnAddPhoneTapped:(UIButton *)sender;

@property (nonatomic, strong) NSString *strImageType;
///reference to the Change action method will be stored in this to use it to enable it later when there is some text inputted by user in Change Currency popup
@property (nonatomic, weak) UIAlertAction *changeAction;

@end

@implementation C411RideSettingsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]postNotificationName:kDidOpenedRideSettingsVCNotification object:nil];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
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
#pragma mark - Overridden Methods
//****************************************************
-(void)mag_viewDidBack {
    [super mag_viewDidBack];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDidClosedRideSettingsVCNotification object:nil];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)registerForNotifications
{
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
    self.title = NSLocalizedString(@"Ride Settings", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    ///Make rounded views
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    [C411StaticHelper makeCircularView:self.btnEditAvatar];
    [C411StaticHelper makeCircularView:self.btnPhoneNotVerifiedIndicator];
    [C411StaticHelper makeCircularView:self.vuRedBlink];
    [C411StaticHelper makeCircularView:self.vuCashImgContainer];
    [C411StaticHelper makeCircularView:self.vuSilverImgContainer];
    [C411StaticHelper makeCircularView:self.vuCryptoImgContainer];
    [C411StaticHelper makeCircularView:self.vuBarteringImgContainer];
    [C411StaticHelper makeCircularView:self.vuCreditCardImgContainer];
    
    ///set corner radius
    self.btnEditCarImage.layer.cornerRadius = 3.0;
    self.btnEditCarImage.layer.masksToBounds = YES;
    self.vuCashContainer.layer.cornerRadius = 3.0;
    self.vuCashContainer.layer.masksToBounds = YES;
    self.vuSilverContainer.layer.cornerRadius = 3.0;
    self.vuSilverContainer.layer.masksToBounds = YES;
    self.vuCryptoContainer.layer.cornerRadius = 3.0;
    self.vuCryptoContainer.layer.masksToBounds = YES;
    self.vuBarteringContainer.layer.cornerRadius = 3.0;
    self.vuBarteringContainer.layer.masksToBounds = YES;
    self.vuCreditCardContainer.layer.cornerRadius = 3.0;
    self.vuCreditCardContainer.layer.masksToBounds = YES;
    self.btnUpdate.layer.cornerRadius = 3.0;
    self.btnUpdate.layer.masksToBounds = YES;
    self.btnChangeCurrency.layer.cornerRadius = 3.0;
    self.btnChangeCurrency.layer.masksToBounds = YES;
    self.btnAddPhone.layer.cornerRadius = 3.0;
    self.btnAddPhone.layer.masksToBounds = YES;

    
    ///Set toolbar as input accessory view
    self.txtPickupCost.inputAccessoryView = self.tlbrHideKeyboard;
    self.txtCostPerMin.inputAccessoryView = self.tlbrHideKeyboard;
    self.txtCostPerMile.inputAccessoryView = self.tlbrHideKeyboard;
    
    [self applyColors];
}

-(void)applyColors {
    UIColor *backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.view.backgroundColor = backgroundColor;
    
    ///set theme colors
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnEditAvatar.backgroundColor = themeColor;
    self.btnUpdate.backgroundColor = themeColor;
    self.btnChangeCurrency.backgroundColor = themeColor;
    self.btnAddPhone.backgroundColor = themeColor;
    
    ///Set text color on theme BG
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnAddPhone setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    self.btnAddPhone.tintColor = primaryBGTextColor;
    self.btnEditAvatar.tintColor = primaryBGTextColor;
    [self.btnUpdate setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnChangeCurrency setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    ///Set hint icon color
    UIColor *hintIconColor = [C411ColorHelper sharedInstance].hintIconColor;
    self.imgVuCity.tintColor = hintIconColor;
    self.imgVuPhone.tintColor = hintIconColor;
    
    ///Set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblFullName.textColor = primaryTextColor;
    self.lblConfigureCost.textColor = primaryTextColor;
    self.lblPickupCost.textColor = primaryTextColor;
    self.lblCostPerMin.textColor = primaryTextColor;
    self.lblCostPerMileOrKm.textColor = primaryTextColor;
    self.lblPaymentModeTitle.textColor = primaryTextColor;
    self.lblPickupCostCurrency.textColor = primaryTextColor;
    self.lblCostPerMinCurrency.textColor = primaryTextColor;
    self.lblCostPerMileCurrency.textColor = primaryTextColor;
    self.txtPickupCost.textColor = primaryTextColor;
    self.txtCostPerMin.textColor = primaryTextColor;
    self.txtCostPerMile.textColor = primaryTextColor;
    
    ///Set disabled color for placeholder text
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtPickupCost];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtCostPerMin];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtCostPerMile];

    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuPickupCostSeparator.backgroundColor = separatorColor;
    self.vuCostPerMinSeparator.backgroundColor = separatorColor;
    self.vuCostPerMileSeparator.backgroundColor = separatorColor;

    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblCity.textColor = secondaryTextColor;
    self.lblContactNumber.textColor = secondaryTextColor;
    self.lblEmail.textColor = secondaryTextColor;
    self.lblPaymentModeSubtitle.textColor = secondaryTextColor;

    ///Set light theme color to phone not verified
    self.btnPhoneNotVerifiedIndicator.backgroundColor = [C411ColorHelper sharedInstance].lightThemeColor;
    
    ///Set payment mode colors
    [self toggleCashButtonSelection:NO];
    self.vuCashImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CASH_COLOR];
    [self toggleSilverButtonSelection:NO];
    self.vuSilverImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_SILVER_COLOR];
    [self toggleCryptoButtonSelection:NO];
    self.vuCryptoImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CRYPTO_COLOR];
    [self toggleBarteringButtonSelection:NO];
    self.vuBarteringImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_BARTERING_COLOR];
    [self toggleCreditCardButtonSelection:NO];
    self.vuCreditCardImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CREDIT_CARD_COLOR];

    ///set toolbar color
    self.tlbrHideKeyboard.barTintColor = backgroundColor;
    self.tlbrHideKeyboard.tintColor = themeColor;
}


-(void)fillDetails
{
    ///hide phone verification indicatros initially
    self.imgVuPhoneVerified.hidden = YES;
    self.btnPhoneNotVerifiedIndicator.hidden = YES;
    self.vuRedBlink.hidden = YES;
    
    ///hide add phone button initially
    self.btnAddPhone.hidden = YES;

    ///get the user details first
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (object) {
            
            ///get user avatar
//            [C411StaticHelper getAvatarForUser:currentUser shouldFallbackToGravatar:YES ofSize:weakSelf.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//                
//                if (image) {
//                    
//                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//                       
//                        weakSelf.imgVuAvatar.image = image;
//                        
//                    }];
//                   
//                }
//
//                
//            }];
            [weakSelf.imgVuAvatar setAvatarForUser:currentUser shouldFallbackToGravatar:YES ofSize:weakSelf.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];

            
            NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
            
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
                
                BOOL isPhoneVerified = [currentUser[kUserPhoneVerifiedKey]boolValue];
                if (isPhoneVerified) {
                    
                    ///Show the verified icon
                    weakSelf.imgVuPhoneVerified.hidden = NO;
                }
                else{
                    
                    ///Show phone verification indicator
                    [weakSelf showPhoneVerificationIndicator];
                }
                
            }
            else{
                
                ///Contact number is not available
                weakSelf.lblContactNumber.text = NSLocalizedString(@"N/A", nil);
                
                ///Show Add button
                self.btnAddPhone.hidden = NO;
                
            }
            
            ///get user car image
//            [C411StaticHelper getCarImageForUser:currentUser withCompletion:^(BOOL success, UIImage *image) {
//                
//                if (image) {
//                    
//                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//                        
//                        weakSelf.imgVuCar.image = image;
//                        
//                    }];
//                }
//                
//                
//            }];
            [self.imgVuCar setCarImageForUser:currentUser withCompletion:NULL];


            ///get the driver profile if available
            [weakSelf getDriverProfileWithCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                ///Hide the progress hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                

                if (object) {
                    
                    PFObject *driverProfile = (PFObject *)object;
                    
                    ///Set currency
                    NSString *strCurrency = driverProfile[kDriverProfileCurrencyKey];
                    [weakSelf setCurrency:strCurrency];
                    
                    ///set the pickup cost
                    NSNumber *pickUpCost = driverProfile[kDriverProfilePickupCostKey];
                    if (pickUpCost) {
                        
                        weakSelf.txtPickupCost.text = [C411StaticHelper getDecimalStringFromNumber:pickUpCost uptoDecimalPlaces:2];
                    }
                    
                    ///set the per min cost
                    NSNumber *perMinCost = driverProfile[kDriverProfilePerMinuteCostKey];
                    if (perMinCost) {
                        
                        weakSelf.txtCostPerMin.text = [C411StaticHelper getDecimalStringFromNumber:perMinCost uptoDecimalPlaces:2];
                    }

                    ///set the per mile cost
                    NSNumber *perMileCost = driverProfile[kDriverProfilePerMileCostKey];
                    ///Set data according to the selected metric system
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    ///Get metric chosen by user
                    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
                    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
                        
                        ///Metric system chosen by user is in Kms so show cost per kms
                        weakSelf.lblCostPerMileOrKm.text = NSLocalizedString(@"COST/KM", nil);
                        if (perMileCost) {
                            ///per mile cost is available on Parse so show that in per KM
                            float perKmCost = [perMileCost floatValue]/MILES_TO_KM;
                            
                            weakSelf.txtCostPerMile.text = [C411StaticHelper getDecimalStringFromNumber:@(perKmCost) uptoDecimalPlaces:2];
                        }
                        else{
                            ///Per mile cost is not available on Parse, show default Per mile cost in Per km format
                            float perKmCost = DEFAULT_PER_MILE_COST/MILES_TO_KM;
                            
                            weakSelf.txtCostPerMile.text = [C411StaticHelper getDecimalStringFromNumber:@(perKmCost) uptoDecimalPlaces:2];
                        }
                        
                    }
                    else{
                        
                        ///Metric system chosen by user is in miles so show cost per mile
                        weakSelf.lblCostPerMileOrKm.text = NSLocalizedString(@"COST/MILE", nil);
                        if (perMileCost) {
                            ///per mile cost is available on Parse so show that
                            weakSelf.txtCostPerMile.text = [C411StaticHelper getDecimalStringFromNumber:perMileCost uptoDecimalPlaces:2];
                        }
                        else{
                            ///Per mile cost is not available on Parse, show default Per mile cost
                            weakSelf.txtCostPerMile.text = [C411StaticHelper getDecimalStringFromNumber:@(DEFAULT_PER_MILE_COST) uptoDecimalPlaces:2];
                        }
                        
                        
                    }

                    
                    
                    ///Set the payment modes
                    BOOL isCashAccepted = [driverProfile[kDriverProfileIsCashAcceptedKey]boolValue];
                    if (isCashAccepted) {
                        
                        [weakSelf toggleCashButtonSelection:YES];
                        
                    }
                    
                    BOOL isSilverAccepted = [driverProfile[kDriverProfileIsSilverAcceptedKey]boolValue];
                    if (isSilverAccepted) {
                        
                        [weakSelf toggleSilverButtonSelection:YES];
                        
                    }
                    
                    BOOL isCryptoAccepted = [driverProfile[kDriverProfileIsCryptoAcceptedKey]boolValue];
                    if (isCryptoAccepted) {
                        
                        [weakSelf toggleCryptoButtonSelection:YES];
                        
                    }
                    
                    BOOL isBarteringAccepted = [driverProfile[kDriverProfileIsBarteringAcceptedKey]boolValue];
                    if (isBarteringAccepted) {
                        
                        [weakSelf toggleBarteringButtonSelection:YES];
                        
                    }
                    
                    BOOL isCreditCardAccepted = [driverProfile[kDriverProfileIsCreditCardAcceptedKey]boolValue];
                    if (isCreditCardAccepted) {
                        
                        [weakSelf toggleCreditCardButtonSelection:YES];
                        
     
                    }
                    
                    
                }
                else if (error.code == kPFErrorObjectNotFound){
                    
                    ///Driver profile doesn't exist, set the default values
                    weakSelf.txtPickupCost.text = [C411StaticHelper getDecimalStringFromNumber:@(DEFAULT_PICKUP_COST) uptoDecimalPlaces:2];
                    weakSelf.txtCostPerMin.text = [C411StaticHelper getDecimalStringFromNumber:@(DEFAULT_PER_MIN_COST) uptoDecimalPlaces:2];
                    ///Set data according to the selected metric system
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    ///Get metric chosen by user
                    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
                    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
                        
                        ///Metric system chosen by user is in Kms so show cost per kms
                        weakSelf.lblCostPerMileOrKm.text = NSLocalizedString(@"COST/KM", nil);
                        ///Per mile cost is not available on Parse, show default Per mile cost in Per km format
                            float perKmCost = DEFAULT_PER_MILE_COST/MILES_TO_KM;
                            
                            weakSelf.txtCostPerMile.text = [C411StaticHelper getDecimalStringFromNumber:@(perKmCost) uptoDecimalPlaces:2];
                
                    }
                    else{
                        
                        ///Metric system chosen by user is in miles so show cost per mile
                        weakSelf.lblCostPerMileOrKm.text = NSLocalizedString(@"COST/MILE", nil);
                        ///Per mile cost is not available on Parse, show default Per mile cost
                            weakSelf.txtCostPerMile.text = [C411StaticHelper getDecimalStringFromNumber:@(DEFAULT_PER_MILE_COST) uptoDecimalPlaces:2];
                    
                        
                    }

                    ///set cash option to be selected by default
                    [weakSelf toggleCashButtonSelection:YES];
                    
                    
                }
                else{
                   
                    if (error) {
                            
                            // Show the errorString somewhere and let the user try again.
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                            
                        }
                        
                    
                }
                
            }];
            
        }
        else{
            
            if (error) {
                
                // Show the errorString somewhere and let the user try again.
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                
            }
            
            ///Hide the progress hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
        }
        
        
    }];
    
}

-(void)showPhoneVerificationIndicator
{
    ///cancel any previous animation
    [self.vuRedBlink.layer removeAllAnimations];
    
    ///Show the verify phone indicator
    self.btnPhoneNotVerifiedIndicator.hidden = NO;
    self.vuRedBlink.hidden = NO;
    [UIView animateKeyframesWithDuration:1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationCurveEaseInOut animations:^{
        self.vuRedBlink.alpha = 0;
    } completion:^(BOOL finished) {
    }];
    
}


-(void)setCurrency:(NSString *)strCurrency
{
    if (!strCurrency || strCurrency.length == 0) {
        
        strCurrency = DEFAULT_RIDE_CURRENCY;
    }
    
    ///SET CURRENCY
    self.lblPickupCostCurrency.text = strCurrency;
    self.lblCostPerMinCurrency.text = strCurrency;
    self.lblCostPerMileCurrency.text = strCurrency;
    
}

-(void)toggleCashButtonSelection:(BOOL)shouldSelect
{

    self.tglBtnCash.selected = shouldSelect;
    if (shouldSelect) {
        
        self.vuCashContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CASH_COLOR andAlpha:PAY_SELECTED_ALPHA];
    }
    else{
        
        self.vuCashContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CASH_COLOR andAlpha:PAY_DESELECTED_ALPHA];

    }
    
}

-(void)toggleSilverButtonSelection:(BOOL)shouldSelect
{
    
    self.tglBtnSilver.selected = shouldSelect;
    if (shouldSelect) {
        
        self.vuSilverContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_SILVER_COLOR andAlpha:PAY_SELECTED_ALPHA];
    }
    else{
        
        self.vuSilverContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_SILVER_COLOR andAlpha:PAY_DESELECTED_ALPHA];
        
    }
    
}

-(void)toggleCryptoButtonSelection:(BOOL)shouldSelect
{
    
    self.tglBtnCrypto.selected = shouldSelect;
    if (shouldSelect) {
        
        self.vuCryptoContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CRYPTO_COLOR andAlpha:PAY_SELECTED_ALPHA];
    }
    else{
        
        self.vuCryptoContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CRYPTO_COLOR andAlpha:PAY_DESELECTED_ALPHA];
        
    }
    
}

-(void)toggleBarteringButtonSelection:(BOOL)shouldSelect
{
    
    self.tglBtnBartering.selected = shouldSelect;
    if (shouldSelect) {
        
        self.vuBarteringContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_BARTERING_COLOR andAlpha:PAY_SELECTED_ALPHA];
    }
    else{
        
        self.vuBarteringContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_BARTERING_COLOR andAlpha:PAY_DESELECTED_ALPHA];
        
    }
    
}

-(void)toggleCreditCardButtonSelection:(BOOL)shouldSelect
{
    self.tglBtnCreditCard.selected = shouldSelect;
    if (shouldSelect) {
        
        self.vuCreditCardContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CREDIT_CARD_COLOR andAlpha:PAY_SELECTED_ALPHA];
    }
    else{
        
        self.vuCreditCardContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CREDIT_CARD_COLOR andAlpha:PAY_DESELECTED_ALPHA];
        
    }
    
}

-(BOOL)canDeselectPaymentMode
{
    BOOL canDeselect = NO;
    if (self.tglBtnCash.isSelected) {
        canDeselect = YES;
    }
    else if (self.tglBtnSilver.isSelected) {
        canDeselect = YES;
    }
    else if (self.tglBtnCrypto.isSelected) {
        canDeselect = YES;
    }
    else if (self.tglBtnBartering.isSelected) {
        canDeselect = YES;
    }
    else if (self.tglBtnCreditCard.isSelected) {
        canDeselect = YES;
    }
    
    if (canDeselect == NO) {
        
        ///show a message
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Atleast one payment form has to be selected", nil) onViewController:self];
    }
    
    return canDeselect;
    
}

-(BOOL)canUpdateDriverProfile
{
    BOOL isValid = YES;
    NSString *strTrimmedPickupCost = [self.txtPickupCost.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedCostPerMin = [self.txtCostPerMin.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedCostPerMile = [self.txtCostPerMile.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (strTrimmedPickupCost.length == 0) {
        
        NSString *toastMsg = NSLocalizedString(@"Please enter pickup cost", nil);
        [AppDelegate showToastOnView:self.view withMessage:toastMsg];
        isValid = NO;

    }
    else if (strTrimmedCostPerMin.length == 0) {
        
        NSString *toastMsg = NSLocalizedString(@"Please enter cost/min", nil);
        [AppDelegate showToastOnView:self.view withMessage:toastMsg];
        isValid = NO;
        
    }
    else if (strTrimmedCostPerMile.length == 0) {
        
        NSString *toastMsg = NSLocalizedString(@"Please enter cost/mile", nil);
        [AppDelegate showToastOnView:self.view withMessage:toastMsg];
        isValid = NO;
        
    }
    
    return isValid;
}


-(void)getDriverProfileWithCompletion:(PFObjectResultBlock)completion
{
    ///get the driver profile if available
    PFUser *currentUser = [AppDelegate getLoggedInUser];

    PFQuery *getDriverProfileQuery = [PFQuery queryWithClassName:kDriverProfileClassNameKey];
    [getDriverProfileQuery whereKey:kDriverProfileUserKey equalTo:currentUser];
    [getDriverProfileQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (completion != NULL) {
            
            completion(object,error);
        }
        
    }];

}

-(void)saveDriverProfile:(PFObject *)driverProfile withCompletion:(PFBooleanResultBlock)completion
{
    if (!driverProfile) {
        ///Create a new object as driver profile is nil and doesn't exist on server
        driverProfile = [PFObject objectWithClassName:kDriverProfileClassNameKey];
        ///set user object first time
        driverProfile[kDriverProfileUserKey] = [AppDelegate getLoggedInUser];
    }
    
    ///Set cost values
    float pickupCost = [self.txtPickupCost.text floatValue];
    float perMinCost = [self.txtCostPerMin.text floatValue];
    float perMileOrKmCost = [self.txtCostPerMile.text floatValue];
    
    driverProfile[kDriverProfilePickupCostKey] = @(pickupCost);
    driverProfile[kDriverProfilePerMinuteCostKey] = @(perMinCost);
    
    ///Set data according to the selected metric system
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ///Get metric chosen by user
    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///Convert cost per km to cost per mile and then save it in parse
        float perMileCost = perMileOrKmCost * MILES_TO_KM;
        driverProfile[kDriverProfilePerMileCostKey] = @(perMileCost);

    }
    else{
        
        ///Cost is already in miles
        float perMileCost = perMileOrKmCost;
        driverProfile[kDriverProfilePerMileCostKey] = @(perMileCost);

    }

    ///set accepted payment modes
    driverProfile[kDriverProfileIsCashAcceptedKey] = @(self.tglBtnCash.isSelected);
    driverProfile[kDriverProfileIsSilverAcceptedKey] = @(self.tglBtnSilver.isSelected);
    driverProfile[kDriverProfileIsCryptoAcceptedKey] = @(self.tglBtnCrypto.isSelected);
    driverProfile[kDriverProfileIsBarteringAcceptedKey] = @(self.tglBtnBartering.isSelected);
    driverProfile[kDriverProfileIsCreditCardAcceptedKey] = @(self.tglBtnCreditCard.isSelected);
    ///save currency if it's not default
    NSString *strCurrency = self.lblPickupCostCurrency.text;
    if (![strCurrency isEqualToString:DEFAULT_RIDE_CURRENCY]) {
        
        driverProfile[kDriverProfileCurrencyKey] = strCurrency;
    }
    
    [driverProfile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (completion != NULL) {
            
            completion(succeeded,error);
        }
        
    }];
    
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
        if ([self.strImageType isEqualToString:IMAGE_TYPE_AVATAR]) {
            NSNumber *avatarImageNameNum = currentUser[kUserImageNameKey];
            if (avatarImageNameNum) {
            
                strImageName = [NSString stringWithFormat:@"%d",[avatarImageNameNum intValue] + 1];
            }
            else{
                
                strImageName = @"1";
            }
            
        }
        else if ([self.strImageType isEqualToString:IMAGE_TYPE_CAR]) {
            
            NSNumber *carImageNameNum = currentUser[kUserCarImageNameKey];
            if (carImageNameNum) {
                
                strImageName = [NSString stringWithFormat:@"%d",[carImageNameNum intValue] + 1];
            }
            else{
                
                strImageName = @"1";
            }
            

        }
        __weak typeof(self) weakSelf = self;
        [ServerUtility uploadImage:imageData withType:self.strImageType imageName:strImageName forUserWithId:currentUser.objectId withCompletion:^(NSError *error, id data) {
            
            if (!error) {
                
                if ([C411StaticHelper validateAndProcessBackendResponse:data]) {
                    
                    ///image uploaded successfully,increment the counter on parse and post notification for image updation
                    NSString *strNotificationName = nil;
                    if ([weakSelf.strImageType isEqualToString:IMAGE_TYPE_AVATAR]) {
                        
                        weakSelf.imgVuAvatar.image = selectedImage;
                        [currentUser incrementKey:kUserImageNameKey];
                        
                        strNotificationName = kMyProfileUpdatedNotification;
                    }
                    else if ([weakSelf.strImageType isEqualToString:IMAGE_TYPE_CAR]) {
                        
                        weakSelf.imgVuCar.image = selectedImage;
                        [currentUser incrementKey:kUserCarImageNameKey];
                    }
                    
                    ///update on Parse
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            
                            ///save it eventually
                            [currentUser saveEventually];
                        }
                        
                        ///hide the hud
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        
                        if (strNotificationName.length > 0) {
                            
                            ///Post notification
                            [[NSNotificationCenter defaultCenter]postNotificationName:strNotificationName object:nil];
                            
                        }
                        
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

- (IBAction)btnEditAvatarTapped:(UIButton *)sender {
    
    self.strImageType = IMAGE_TYPE_AVATAR;
    [self showImagePickerActionSheet];
}

- (IBAction)btnPhoneNotVerifiedIndicatorTapped:(UIButton *)sender {
    
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

    
}

- (IBAction)btnEditCarImageTapped:(UIButton *)sender {
    
    self.strImageType = IMAGE_TYPE_CAR;
    [self showImagePickerActionSheet];

}

- (IBAction)tglBtnCashTapped:(UIButton *)sender {
    
    BOOL shouldSelect = !sender.isSelected;
    if (shouldSelect) {
        
        [self toggleCashButtonSelection:shouldSelect];

    }
    else if ([self canDeselectPaymentMode]){
    
        [self toggleCashButtonSelection:shouldSelect];

    }
}

- (IBAction)tglBtnSilverTapped:(UIButton *)sender {
    BOOL shouldSelect = !sender.isSelected;
    if (shouldSelect) {
        
        [self toggleSilverButtonSelection:shouldSelect];
       
    }
    else if ([self canDeselectPaymentMode]){
        
        [self toggleSilverButtonSelection:shouldSelect];
        
    }

}

- (IBAction)tglBtnCryptoTapped:(UIButton *)sender {
    
    BOOL shouldSelect = !sender.isSelected;
    if (shouldSelect) {
       
        [self toggleCryptoButtonSelection:shouldSelect];

    }
    else if ([self canDeselectPaymentMode]){
        
        [self toggleCryptoButtonSelection:shouldSelect];

    }

}

- (IBAction)tglBtnBarteringTapped:(UIButton *)sender {
    
    BOOL shouldSelect = !sender.isSelected;
    if (shouldSelect) {
        
        [self toggleBarteringButtonSelection:shouldSelect];

    }
    else if ([self canDeselectPaymentMode]){
        
        [self toggleBarteringButtonSelection:shouldSelect];

    }

}

- (IBAction)tglBtnCreditCardTapped:(UIButton *)sender {
    
    BOOL shouldSelect = !sender.isSelected;

    if (shouldSelect) {
        
        ///show an informational message
        NSString *strLocalizedMsg = NSLocalizedString(@"To accept credit cards please use a squareup.com credit card reader, or a similar reader from another vendor", nil);
        [C411StaticHelper showAlertWithTitle:nil message:strLocalizedMsg onViewController:self];
        
        ///Select payment mode
        [self toggleCreditCardButtonSelection:shouldSelect];

    }
    else{
        
        if ([self canDeselectPaymentMode]) {
            
            [self toggleCreditCardButtonSelection:shouldSelect];

        }
        
    }
}

- (IBAction)btnUpdateTapped:(UIButton *)sender {
    
    if ([self canUpdateDriverProfile]) {
        
        ///get the driver profile first
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self) weakSelf = self;
        [self getDriverProfileWithCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            
            
            if (!error || error.code == kPFErrorObjectNotFound) {
                
                PFObject *driverProfile = (PFObject *)object;
                [weakSelf saveDriverProfile:driverProfile withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    ///Hide the progress hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    if (succeeded) {
                        
                        ///show toast for success
                        NSString *strToastMsg = NSLocalizedString(@"Updated Successfully", nil);
                        [AppDelegate showToastOnView:weakSelf.view withMessage:strToastMsg];
                    }
                    else{
                        
                        if (error) {
                            
                            // Show the errorString somewhere and let the user try again.
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                        }
                    }
                    
                }];
                
            }
            else {
                
                // Show the errorString somewhere and let the user try again.
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                
                ///Hide the progress hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

            }
            
        }];
    }
}

- (IBAction)barBtnDoneTapped:(UIBarButtonItem *)sender {
    
    [self.view endEditing:YES];
}

- (IBAction)btnChangeCurrencyTapped:(UIButton *)sender {
    
    ///Show Change Currency Popup
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Change Currency", nil)
                                          message:NSLocalizedString(@"Please enter your currency below",nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    ///Take user phone number and update it first
    __weak typeof(self) weakSelf = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.tag = TXT_TAG_ALERT_CHG_CURRENCY;
         textField.delegate = weakSelf;
         textField.text = weakSelf.lblPickupCostCurrency.text;
         
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///user canceled to change currency, do nothing
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];
    UIAlertAction *changeAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Change", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                       ///Get the currency and set it on label
                                       UITextField *txtCurrency = alertController.textFields.firstObject;
                                       NSString *strCurrency = txtCurrency.text;
                                       if (strCurrency.length > 0) {
                                           ///trim the white spaces
                                           strCurrency = [strCurrency stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                       }
                                       
                                       [weakSelf setCurrency:strCurrency];
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];
    
    ///disable change action and save it's reference in changeAction ivar to enable it later
    changeAction.enabled = NO;
    self.changeAction = changeAction;
    
    [alertController addAction:cancelAction];
    [alertController addAction:changeAction];
    //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

}

- (IBAction)btnAddPhoneTapped:(UIButton *)sender {
    
    C411AddPhoneVC *addPhoneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411AddPhoneVC"];
    __weak typeof(self) weakSelf = self;
#if PHONE_VERIFICATION_ENABLED
    addPhoneVC.verificationCompletionHandler = ^{
        ///Pop out all the VC on top of current VC i.e add phone vc and verification vc
        [weakSelf.navigationController popToViewController:weakSelf animated:YES];
    };

#endif


    [self.navigationController pushViewController:addPhoneVC animated:YES];
    
}

//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == TXT_TAG_ALERT_CHG_CURRENCY) {
        
        ///Change button can only be available if there is text
        NSString *strCurrency = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (strCurrency.length > 0) {
            
            self.changeAction.enabled = YES;
        }
        else{
            
            self.changeAction.enabled = NO;
            
        }
        
        
    }
    
    return YES;
    
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

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
        
        ///From cell 411 version > 7.4  a number can be added or updated after it is verified, so it can be marked as verified if phone verification is enabled
        [self.vuRedBlink.layer removeAllAnimations];
        self.btnPhoneNotVerifiedIndicator.hidden = YES;
        self.vuRedBlink.hidden = YES;
        self.imgVuPhoneVerified.hidden = NO;
        
    }
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
