//
//  C411AddPhoneVC.m
//  cell411
//
//  Created by Milan Agarwal on 17/06/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411AddPhoneVC.h"
#import "C411StaticHelper.h"
#import "MA_Country.h"
#import "C411CountrySelectionVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

#if PHONE_VERIFICATION_ENABLED
#import "C411PhoneVerificationVC.h"
#endif


@interface C411AddPhoneVC ()<C411CountrySelectionVCDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgVuPhone;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuDropdown;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIView *vuPhoneNumberSeparator;
- (IBAction)barBtnSaveTapped:(UIBarButtonItem *)sender;
- (IBAction)btnCountryCodeTapped:(UIButton *)sender;

@property (nonatomic, strong) MA_Country *selectedCountry;
@property (nonatomic, assign, getter=shouldHideNavBar) BOOL hideNavBar;

@end

@implementation C411AddPhoneVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self configureViews];
    
    if (self.isInEditMode) {
        self.title = NSLocalizedString(@"Update Phone Number", nil);
        ///Get the country code and phone number
        NSDictionary *dictContactDetails = [C411StaticHelper splitPhoneNumberAndCountryCodeFromNumber:self.strContactNumber];

        self.selectedCountry = [dictContactDetails objectForKey:kPhoneCountryKey];
        self.txtPhoneNumber.text = [dictContactDetails objectForKey:kPhoneNumberKey];
        NSString *strPhoneNumber = [dictContactDetails objectForKey:kPhoneNumberKey];
        self.txtPhoneNumber.text = strPhoneNumber ? strPhoneNumber : @"";
        
    }
    else{
        self.title = NSLocalizedString(@"Add Phone Number", nil);

        ///Set a default country code as per current locale
        self.selectedCountry = [MA_Country defaultCountry];

    }
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }

    [self updateCountryCode];
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        
        ///Navigation bar is initially hidden so unhide it and save it's state to hide it again when going back
        self.hideNavBar = YES;
        
        self.navigationController.navigationBarHidden = NO;
        
        
    }

    ///show keyboard
    [self.txtPhoneNumber becomeFirstResponder];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (self.shouldHideNavBar) {
        
        ///Hide the navigation bar again as it was initially hidden
        self.navigationController.navigationBarHidden = YES;
        
    }
    
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
#if PHONE_VERIFICATION_ENABLED
    ///Explicitly nil the completion handler
    self.verificationCompletionHandler = nil;
    self.addOrUpdatePhoneDelegate = nil;
#endif
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
    ///Set phone number field delegate
    self.txtPhoneNumber.delegate = self;
    [self applyColors];
}

-(void)applyColors {
    ///Set BG color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set hint icon colors
    UIColor *hintIconColor = [C411ColorHelper sharedInstance].hintIconColor;
    self.imgVuPhone.tintColor = hintIconColor;
    self.imgVuDropdown.tintColor = hintIconColor;
    
    ///Set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    [self.btnCountryCode setTitleColor:primaryTextColor forState:UIControlStateNormal];
    self.txtPhoneNumber.textColor = primaryTextColor;
    
    ///Set disabled color for placeholder text
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtPhoneNumber];
    
    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuPhoneNumberSeparator.backgroundColor = separatorColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateCountryCode
{
    ///set the country code text on button
    NSString *strTitle = nil;
    if (self.selectedCountry) {
        ///Country code is available
        strTitle = [@"+" stringByAppendingString:self.selectedCountry.dialingCode];
    }
    else{
        ///Country code is not available
        strTitle = NSLocalizedString(@"Select", nil);
        
    }
    [self.btnCountryCode setTitle:strTitle forState:UIControlStateNormal];
}

-(void)addContactNumber:(NSString *)strContactNumber
{
    ///Update the current user contact number
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    currentUser[kUserMobileNumberKey] = strContactNumber;
    __weak typeof(self) weakSelf = self;
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if (!error) {
            
            ///Contact number added/updated successfully, show toast
            NSString *strMessage = self.isInEditMode ? NSLocalizedString(@"Phone number updated successfully", nil):NSLocalizedString(@"Phone number added successfully", nil);
            [AppDelegate showToastOnView:[AppDelegate sharedInstance].window.rootViewController.view withMessage:strMessage];
            
            
            ///Post the notification for contact added/updated
            if (self.isInEditMode) {
                
                [[NSNotificationCenter defaultCenter]postNotificationName:kPhoneUpdatedNotification object:nil];
                
            }
            else{
            
                [[NSNotificationCenter defaultCenter]postNotificationName:kPhoneAddedNotification object:nil];
                
            }
            
            ///Pop the view controller
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
        }
        
    }];
    
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnSaveTapped:(UIBarButtonItem *)sender {
    
    ///remove keyboard
    [self.view endEditing:YES];
    
    NSString *strContactNumber = self.txtPhoneNumber.text;
    if(!(self.selectedCountry)){
        
        ///Show toast to select country code
        [AppDelegate showToastOnView:[AppDelegate sharedInstance].window.rootViewController.view withMessage:NSLocalizedString(@"Please select your country", nil)];

        
    }
    else if((!strContactNumber) || (strContactNumber.length == 0)){
       
        ///Show toast to enter number
        [AppDelegate showToastOnView:[AppDelegate sharedInstance].window.rootViewController.view withMessage:NSLocalizedString(@"Please enter phone number", nil)];
    }
#if (APP_IER || APP_RO112)
    
    else if (![C411StaticHelper isMobileNumberValid:strContactNumber forCountry:self.selectedCountry]) {
        
        NSString *localizedInvalidMobNumberMsg = NSLocalizedString(@"Please enter valid mobile number", nil);
        
        [AppDelegate showToastOnView:[AppDelegate sharedInstance].window.rootViewController.view withMessage:NSLocalizedString(@"Please enter valid mobile number", nil)];
        
    }
    
#endif
    else{
        
        ///Check whether there is any user using this mobile number or not
#if (APP_IER || APP_RO112)
        strContactNumber = [C411StaticHelper removeCountryCodePrefixFromMobileNumber:strContactNumber forCountry:self.selectedCountry];
#endif
        NSString *strContactNumberWithCountryCode = [NSString stringWithFormat:@"%@%@",self.selectedCountry.dialingCode,strContactNumber];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self) weakSelf = self;
        ///check if there is already a user with this phone or not
        [C411StaticHelper getUserWithMobileNumber:strContactNumberWithCountryCode ignoreCurrentUser:YES andCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if (!error && object) {
                ///1.Enable interaction
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                ///Found existing user object with this email, show the error message that user already exist with this email
                NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"There is already an account registered with mobile number %@. Please use different mobile number.",nil),strContactNumberWithCountryCode];
                [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf.view.window.rootViewController];
                
                
            }
            else if (error.code == kPFErrorObjectNotFound){
                
#if PHONE_VERIFICATION_ENABLED
                ///No user exist with this phone number, user can update phone number safely after successful verification
                if (weakSelf.isComingFromPhoneVerificationVC && [weakSelf.addOrUpdatePhoneDelegate respondsToSelector:@selector(addPhoneVC:didAddedOrUpdatedUniqueContactNumber:)]) {
                    ///This screen came from phone verification screen to update the wrong contact number
                    ///Call the delegate and pass the new number and don't do push/pop. It is the delegate responsibility to push/pop the correct view controller
                    [weakSelf.addOrUpdatePhoneDelegate addPhoneVC:weakSelf didAddedOrUpdatedUniqueContactNumber:strContactNumberWithCountryCode];
                    
                }
                else{
                    
                    ///It's not coming from phone verification screen and hence delegate is not set as well. Push the phone verification screen to verify this contact number
                    ///1.Enable interaction
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

                    C411PhoneVerificationVC *phoneVerificationVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"C411PhoneVerificationVC"];
                    phoneVerificationVC.strContactNumber = strContactNumberWithCountryCode;
                    phoneVerificationVC.verificationCompletionHandler = weakSelf.verificationCompletionHandler;
                    [weakSelf.navigationController pushViewController:phoneVerificationVC animated:YES];

                }
              
#else
                ///No user exist with this phone number, user can update phone number safely
                ///Save the phone number for the user along with their country code
                [weakSelf addContactNumber:strContactNumberWithCountryCode];

#endif

                
            }
            else{
                ///1.Enable interaction
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                // Show the errorString somewhere and let the user try again.
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
            
        }];
        

        
        
    }
    
}

- (IBAction)btnCountryCodeTapped:(UIButton *)sender {
    
    ///Show the country selection VC
    C411CountrySelectionVC *countrySelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411CountrySelectionVC"];
    countrySelectionVC.delegate = self;
    countrySelectionVC.selectedCountryName = self.selectedCountry.name;
    [self.navigationController pushViewController:countrySelectionVC animated:YES];
    
}

//****************************************************
#pragma mark - C411CountrySelectionVCDelegate Methods
//****************************************************

-(void)countrySelectionVC:(C411CountrySelectionVC *)countrySelectionVC didSelectCountry:(MA_Country *)country
{
    self.selectedCountry = country;
    [self updateCountryCode];
}

//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (string.length > 0) {
        
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *characterSetFromString = [NSCharacterSet characterSetWithCharactersInString:string];
        
        BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromString];
        return stringIsValid;

        
    }
    
    return YES;
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
