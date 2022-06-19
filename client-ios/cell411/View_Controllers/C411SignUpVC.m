//
//  C411SignUpVC.m
//  cell411
//
//  Created by Milan Agarwal on 19/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411SignUpVC.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "AppDelegate.h"
#import "ConfigConstants.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411LoginVC.h"
#import "C411Enums.h"
#import "MAAlertPresenter.h"
#import "ServerUtility.h"
#import "MA_Country.h"
#import "C411CountrySelectionVC.h"
#import "C411ColorHelper.h"

@interface C411SignUpVC ()<UITextFieldDelegate, UITextViewDelegate,C411CountrySelectionVCDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmailIcon;
@property (weak, nonatomic) IBOutlet UIView *vuEmailUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPasswordIcon;
@property (weak, nonatomic) IBOutlet UIView *vuPasswordUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuFirstNameIcon;
@property (weak, nonatomic) IBOutlet UIView *vuFirstNameUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuLastNameIcon;
@property (weak, nonatomic) IBOutlet UIView *vuLastNameUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPhoneNumberIcon;
@property (weak, nonatomic) IBOutlet UIView *vuPhoneNumberUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuDropdown;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vuBaseBLConstraints;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UILabel *lblOr;
@property (weak, nonatomic) IBOutlet UIView *vuOr;
@property (weak, nonatomic) IBOutlet UIView *vuOrBase;
@property (weak, nonatomic) IBOutlet UIView *vuOrLeftSeparator;
@property (weak, nonatomic) IBOutlet UIView *vuOrRightSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUpWithFacebook;
@property (weak, nonatomic) IBOutlet UILabel *lblAppName;
@property (weak, nonatomic) IBOutlet UITextView *txtVuTermsAndConditionsDisclaimer;
@property (weak, nonatomic) IBOutlet UILabel *lblAlreadyHaveAccount;
@property (weak, nonatomic) IBOutlet UIButton *btnShowLoginScreen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVuOrBaseTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVuOrWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsLoginWithFBBtnTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsLoginWithFBBtnHeight;

- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnCreateAccountTapped:(UIButton *)sender;
- (IBAction)btnSignUpWithFacebookTapped:(UIButton *)sender;
- (IBAction)btnShowSignInScreenTapped:(UIButton *)sender;
- (IBAction)btnCountryCodeTapped:(UIButton *)sender;


///Property for scroll management
@property (nonatomic, assign)float kbHeight;
@property (nonatomic, assign) CGFloat scrlVuInitialBLConstarintValue;
@property (nonatomic, strong) MA_Country *selectedCountry;


@end

@implementation C411SignUpVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureViews];
    
    [self registerForNotifications];
    
    ///set initial bottom constraint of scrollview
    self.scrlVuInitialBLConstarintValue = self.vuBaseBLConstraints.constant;

    ///Set a default country code as per current locale
    self.selectedCountry = [MA_Country defaultCountry];
    [self updateCountryCode];
    
#if APP_RO112
    [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"This app is currently for testing purposes only, not yet intended for public use. Proceed only if you have early access credentials.",nil) onViewController:nil];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self unregisterNotifications];
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

-(void)setGradient
{
    UIColor *topColor = [C411ColorHelper sharedInstance].darkPrimaryColor;
    UIColor *bottomColor = [C411ColorHelper sharedInstance].loginGradientLightColor;
    
    NSArray *arrGradientColors = @[(id)topColor.CGColor,(id)bottomColor.CGColor];
    
    [C411StaticHelper setDiagonalGradientOnView:self.view withColors:arrGradientColors];
    
}

-(void)configureViews
{
    
    ///Hide Sign up with FB button if it's disabled
#if (!FB_ENABLED)
    
    self.cnsVuOrBaseTS.constant = 0;
    self.cnsVuOrWidth.constant = 0;
    self.cnsLoginWithFBBtnTS.constant = 0;
    self.cnsLoginWithFBBtnHeight.constant = 0;
    self.vuOrBase.hidden = YES;
    self.btnSignUpWithFacebook.hidden = YES;
    
#endif

    ///set corner radius of login button
    self.btnSignUp.layer.cornerRadius = 3.0;
    self.btnSignUp.layer.masksToBounds = YES;
    
    ///make or view rounder
    [C411StaticHelper makeCircularView:self.vuOr];
    
    ///Set app Name
    self.lblAppName.text = LOCALIZED_APP_NAME;
    
    ///set app name on terms and condition and make link
    //self.lblTermsAndConditionPrefixWithAppName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"By creating your %@ account you agree",nil),LOCALIZED_APP_NAME];
    NSDictionary *dictLinkTextAttr = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.txtVuTermsAndConditionsDisclaimer.linkTextAttributes = dictLinkTextAttr;

    NSString *strTermsAndConditions = NSLocalizedString(@"Terms & Conditions", nil);
    
    float fontSize = self.txtVuTermsAndConditionsDisclaimer.font.pointSize;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *dictMainAttr = @{NSFontAttributeName:[UIFont systemFontOfSize: fontSize],
                                   NSForegroundColorAttributeName:[UIColor whiteColor],
                                   NSParagraphStyleAttributeName:paragraphStyle};
    NSMutableAttributedString *attribStrTermsAndCondDisclaimer = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"By creating your %@ account you agree to our %@",nil),LOCALIZED_APP_NAME,strTermsAndConditions] attributes:dictMainAttr];
    
    
    NSDictionary *dictSubAttr = @{NSFontAttributeName:[UIFont boldSystemFontOfSize: fontSize]};
    
    ///set attributes on "Terms & Conditions" text
    ///1. make range
    NSRange termsAndConditionsRange = [attribStrTermsAndCondDisclaimer.string rangeOfString:strTermsAndConditions];
    if (termsAndConditionsRange.location != NSNotFound) {
    
        ///2. set bold attribute
        [attribStrTermsAndCondDisclaimer setAttributes:dictSubAttr range:termsAndConditionsRange];
        
        ///3. add link attribute for full name
        NSDictionary *dictParams = @{kInternalLinkParamType:kInternalLinkParamTypeShowTermsAndConditions};
        NSURL *url = [NSURL URLWithString:[ServerUtility stringByAppendingParams:dictParams toUrlString:kInternalLinkBaseURL]];
        [attribStrTermsAndCondDisclaimer addAttribute:NSLinkAttributeName value:url range:termsAndConditionsRange];
        
    }
    
    
    self.txtVuTermsAndConditionsDisclaimer.attributedText = attribStrTermsAndCondDisclaimer;
    self.txtVuTermsAndConditionsDisclaimer.delegate = self;
    
    [self applyColors];
}

-(void)applyColors {
    ///Set Gradient
    [self setGradient];
    
    ///Set theme colors on action button text
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    [self.btnSignUp setTitleColor:themeColor forState:UIControlStateNormal];
    
    ///Change Placeholder colors of textfields
    UIColor *placeholderColor = [C411ColorHelper sharedInstance].primaryBGPlaceholderTextColor;
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtEmail];
    
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtPassword];
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtFirstName];
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtLastName];
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtPhoneNumber];
    
    ///Set text color on labels, textfields, separators and other buttons
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.txtEmail.textColor = primaryBGTextColor;
    self.txtPassword.textColor = primaryBGTextColor;
    self.txtFirstName.textColor = primaryBGTextColor;
    self.txtLastName.textColor = primaryBGTextColor;
    self.txtPhoneNumber.textColor = primaryBGTextColor;
    
    self.lblAppName.textColor = primaryBGTextColor;
    self.lblOr.textColor = primaryBGTextColor;
    self.lblAlreadyHaveAccount.textColor = primaryBGTextColor;
    
    [self.btnCountryCode setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnSignUpWithFacebook setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnShowLoginScreen setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    self.vuEmailUnderline.backgroundColor = primaryBGTextColor;
    self.vuPasswordUnderline.backgroundColor = primaryBGTextColor;
    self.vuFirstNameUnderline.backgroundColor = primaryBGTextColor;
    self.vuLastNameUnderline.backgroundColor = primaryBGTextColor;
    self.vuPhoneNumberUnderline.backgroundColor = primaryBGTextColor;
    self.vuOrLeftSeparator.backgroundColor = primaryBGTextColor;
    self.vuOrRightSeparator.backgroundColor = primaryBGTextColor;
    
    ///set tint color to white
    self.imgVuDropdown.tintColor = [C411ColorHelper sharedInstance].primaryBGTextColor;

    ///Set tint color on text fields icons
    self.imgVuEmailIcon.tintColor = primaryBGTextColor;
    self.imgVuPasswordIcon.tintColor = primaryBGTextColor;
    self.imgVuFirstNameIcon.tintColor = primaryBGTextColor;
    self.imgVuLastNameIcon.tintColor = primaryBGTextColor;
    self.imgVuPhoneNumberIcon.tintColor = primaryBGTextColor;
    
    ///Set light theme color on OR view
    UIColor *lightThemeColor = [C411ColorHelper sharedInstance].lightThemeColor;
    self.vuOr.backgroundColor = lightThemeColor;

}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(BOOL)userCanSignUp
{
    BOOL isValid = YES;
    NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedFirstName = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedLastName = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedMobileNumber = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    ///Validate Email
    if ((!strTrimmedEmail) || (strTrimmedEmail.length == 0)) {
        NSString *localizedEmptyEmailMsg = NSLocalizedString(@"Please enter email", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyEmailMsg onViewController:self];
        
        isValid = NO;
    }
    ///Validate whether email is valid or not
    else if (![C411StaticHelper isValidEmail:strTrimmedEmail]){
        NSString *localizedInvalidEmailMsg = NSLocalizedString(@"Please enter valid email", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedInvalidEmailMsg onViewController:self];
        
        isValid = NO;
        
    }
    ///Validate Password
    else if ((!self.txtPassword.text) || (self.txtPassword.text.length == 0)) {
        
        NSString *localizedEmptyPwdMsg = NSLocalizedString(@"Please enter password", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyPwdMsg onViewController:self];
        
        isValid = NO;
    }
    ///Validate Firstname
    else if ((!strTrimmedFirstName) || (strTrimmedFirstName.length == 0)) {
        
        NSString *localizedEmptyFirstNameMsg = NSLocalizedString(@"Please enter firstname", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyFirstNameMsg onViewController:self];
        
        isValid = NO;
    }
    ///Validate Lastname
    else if ((!strTrimmedLastName) || (strTrimmedLastName.length == 0)) {
        
        NSString *localizedEmptyLastNameMsg = NSLocalizedString(@"Please enter lastname", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyLastNameMsg onViewController:self];
        
        isValid = NO;
    }
    ///Validate Mobile number
    else if ((!strTrimmedMobileNumber) || (strTrimmedMobileNumber.length == 0)) {
        
        NSString *localizedEmptyMobNumberMsg = NSLocalizedString(@"Please enter mobile number", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyMobNumberMsg onViewController:self];
        
        isValid = NO;
    }
#if (APP_IER || APP_RO112)
    
    else if (![C411StaticHelper isMobileNumberValid:strTrimmedMobileNumber forCountry:self.selectedCountry]) {
        
        NSString *localizedInvalidMobNumberMsg = NSLocalizedString(@"Please enter valid mobile number", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedInvalidMobNumberMsg onViewController:self];
        
        isValid = NO;
    }
    
#endif

    return isValid;
}



-(void)createUserAccount
{
    ///Create user object and initialize its fields
    PFUser *user = [PFUser user];
    NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedFirstName = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedLastName = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedMobileNumber = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#if (APP_IER || APP_RO112)
    strTrimmedMobileNumber = [C411StaticHelper removeCountryCodePrefixFromMobileNumber:strTrimmedMobileNumber forCountry:self.selectedCountry];
#endif
    
    NSString *strContactNumberWithCountryCode = [NSString stringWithFormat:@"%@%@",self.selectedCountry.dialingCode,strTrimmedMobileNumber];

    user.username = strTrimmedEmail.lowercaseString;
    user.password = self.txtPassword.text;
    
    // other fields can be set just like with PFObject
    user[kUserFirstnameKey] = strTrimmedFirstName;
    user[kUserLastnameKey] = strTrimmedLastName;
    user[kUserMobileNumberKey] = strContactNumberWithCountryCode;
    
    ///Set client firm id
    user[kUserClientFirmIdKey] = CLIENT_FIRM_ID;
    
    ///Enable New Public Cell alert notifications to on by default
    user[kUserNewPublicCellAlertKey] = NEW_PUBLIC_CELL_ALERT_VALUE_ON;
    
    ///Create weak refrence of self to be used in block
    __weak typeof (self) weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ///check if there is already a user with this email or not
    [C411StaticHelper getUserWithEmail:strTrimmedEmail.lowercaseString andCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (!error && object) {
            ///1.Enable interaction
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

            ///Found existing user object with this email, show the error message that user already exist with this email
            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"There is already an account under %@. Please tap on Forgot Password if you cannot remember your password.",nil),strTrimmedEmail];
            [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
            
        }
        else if (error.code == kPFErrorObjectNotFound){
            
            ///No user exist with this email, check if there is an existing user with this mobile number or not
            [C411StaticHelper getUserWithMobileNumber:strContactNumberWithCountryCode ignoreCurrentUser:NO andCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                if (!error && object) {
                    ///1.Enable interaction
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    ///Found existing user object with this email, show the error message that user already exist with this email
                    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"There is already an account registered with mobile number %@. Please use different mobile number.",nil),strContactNumberWithCountryCode];
                    [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                    
                }
                else if (error.code == kPFErrorObjectNotFound){

                    ///No user exist with this email or phone number, user can signup with this email and phone number safely
                    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        ///1.Enable interaction
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        
                        if (!error) {   // Hooray! Let them use the app now.
                            
#if APP_IER
                            
                            /*LMA_INTEGRATION
                             
                             ///Make an IER API call as well for registration
                             NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
                             ///Set first name
                             if (strTrimmedFirstName.length > 0) {
                             
                             [dictParams setObject:strTrimmedFirstName forKey:LMA_API_PARAM_FIRST_NAME];
                             }
                             ///set last name
                             if (strTrimmedLastName.length > 0) {
                             
                             [dictParams setObject:strTrimmedLastName forKey:LMA_API_PARAM_SURNAME];
                             }
                             
                             ///set user email
                             [dictParams setObject:strTrimmedEmail forKey:LMA_API_PARAM_CONTACT_EMAIL];
                             
                             ///Set user mobile
                             [dictParams setObject:strTrimmedMobileNumber forKey:LMA_API_PARAM_CONTACT_MOBILE];
                             [ServerUtility registerIERUserWithDetails:dictParams andCompletion:^(NSError *error, id data) {
                             
                             ///Show main interface
                             [[AppDelegate sharedInstance]userDidCreatedAccountWithSignUpType:SignUpTypeEmail];
                             
                             }];
                             */
                            
                            ///Make an IER API call as well for registration
                            NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
                            ///Set object id of the user
                            [dictParams setObject:user.objectId forKey:IER_API_PARAM_USER_ID];
                            
                            ///Set first name
                            if (strTrimmedFirstName.length > 0) {
                                
                                [dictParams setObject:strTrimmedFirstName forKey:IER_API_PARAM_FIRST_NAME];
                            }
                            ///set last name
                            if (strTrimmedLastName.length > 0) {
                                
                                [dictParams setObject:strTrimmedLastName forKey:IER_API_PARAM_SURNAME];
                            }
                            
                            ///set user email
                            [dictParams setObject:strTrimmedEmail forKey:IER_API_PARAM_CONTACT_EMAIL];
                            
                            ///Set user mobile
                            [dictParams setObject:strTrimmedMobileNumber forKey:IER_API_PARAM_CONTACT_MOBILE];
                            [ServerUtility registerIERUserWithDetails:dictParams andCompletion:^(NSError *error, id data) {
                                
                                ///Show main interface
                                [[AppDelegate sharedInstance]userDidCreatedAccountWithSignUpType:SignUpTypeEmail];
                                
                                //NSLog(@"IER--> %@",data);
                                
                                
                            }];
                            
                            
                            
#else
                            ///Show main interface, as this is other than IER app hence no API needs to be called
                            [[AppDelegate sharedInstance]userDidCreatedAccountWithSignUpType:SignUpTypeEmail];
                            
#endif
                            
                            
                            
                            
                        } else {
                            
                            // Show the errorString somewhere and let the user try again.
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                            
                        }
                    }];
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
        else{
            ///1.Enable interaction
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

            // Show the errorString somewhere and let the user try again.
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
        }

        
    }];
    
}

-(void)updateCountryCode
{
    ///set the country code text on button
    [self.btnCountryCode setTitle:[@"+" stringByAppendingString:self.selectedCountry.dialingCode] forState:UIControlStateNormal];
}

-(void)handleInternalUrl:(NSURL *)url
{
    
    ///Parse the url and get the type value to take corresponding action
    NSDictionary *dictParams = [ServerUtility getParamsFromUrl:url];
    
    if (dictParams) {
        
        ///get the type value
        NSString *strType = dictParams[kInternalLinkParamType];
        if ([strType isEqualToString:kInternalLinkParamTypeShowTermsAndConditions]) {
            
            [self showTermsAndConditions];
            
        }
    }
    
    
}

-(void)showTermsAndConditions
{
    NSURL *termsAndConditionsUrl = [NSURL URLWithString:TERMS_AND_CONDITIONS_URL];
    
    if (termsAndConditionsUrl && [[UIApplication sharedApplication]canOpenURL:termsAndConditionsUrl]) {
        
        [[UIApplication sharedApplication]openURL:termsAndConditionsUrl];
    }
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnBackTapped:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)btnCreateAccountTapped:(UIButton *)sender {
    
    if ([self userCanSignUp]) {
        
        ///show confirm email alert
        NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Is this correct email: \"%@\"?",nil),strTrimmedEmail];
        UIAlertController *confirmEmailAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            ///user said No and wants to change his email
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            ///user said yes, create his account
            [self createUserAccount];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [confirmEmailAlert addAction:noAction];
        [confirmEmailAlert addAction:yesAction];
        //[self presentViewController:confirmEmailAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmEmailAlert];

    }
    
}

- (IBAction)btnSignUpWithFacebookTapped:(UIButton *)sender {

#if FB_ENABLED
    
    [C411StaticHelper performLoginOrSignupWithFacebookFromViewController:self];

#endif

}


- (IBAction)btnShowSignInScreenTapped:(UIButton *)sender {
    
    ///Push Login VC only if SignUp VC is not pushed from Login VC, otherwise just pop out the Sign Up VC to display Login VC
    
    NSArray *arrVCStack = [self.navigationController viewControllers];
    
    UIViewController *prevVCInNavStack = [arrVCStack objectAtIndex:arrVCStack.count - 2];
    if ([prevVCInNavStack isKindOfClass:[C411LoginVC class]]) {
        
        ///Sign Up VC is Pushed from Login VC on Tap of "Sign Up" button in the bottom. So instead of Pushing new Login VC, just Pop Sign Up VC out
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        
        ///Sign Up VC is Pushed from some other screen, i.e Welcome Gallery Screen. Push Login VC
        C411LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411LoginVC"];
        [self.navigationController pushViewController:loginVC animated:YES];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtEmail) {
        
        [self.txtPassword becomeFirstResponder];
        return NO;
    }
    else if (textField == self.txtPassword){
        
        [self.txtFirstName becomeFirstResponder];
        return NO;
    }
    else if (textField == self.txtFirstName){
        
        [self.txtLastName becomeFirstResponder];
        return NO;
    }
    else if (textField == self.txtLastName){
        
        [self.txtPhoneNumber becomeFirstResponder];
        return NO;
    }
    else{
        [textField resignFirstResponder];
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    float yOffset = textField.frame.origin.y - self.txtEmail.frame.origin.y;
    if (yOffset >= 0) {
        
        float underBarPadding = 0;
        [self.scrlVuBase setContentOffset:CGPointMake(self.scrlVuBase.contentOffset.x,yOffset - underBarPadding) animated:YES];
        
    }
    
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == self.txtPhoneNumber && string.length > 0) {
        
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *characterSetFromString = [NSCharacterSet characterSetWithCharactersInString:string];
        
        BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromString];
        return stringIsValid;
        
        
    }
    
    return YES;
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


//****************************************************
#pragma mark - Notifications
//****************************************************

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize _kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.kbHeight = _kbSize.width > _kbSize.height ? _kbSize.height : _kbSize.width;
    //      _scrlVu_Base.contentSize = CGSizeMake(_scrlVu_Base.bounds.size.width, _scrlVu_Base.bounds.size.height + kbHeight);
    self.vuBaseBLConstraints.constant = self.kbHeight + self.scrlVuInitialBLConstarintValue;
    
}

-(void)keyboardWillHide:(NSNotification *)note
{
    self.vuBaseBLConstraints.constant = self.scrlVuInitialBLConstarintValue;
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
