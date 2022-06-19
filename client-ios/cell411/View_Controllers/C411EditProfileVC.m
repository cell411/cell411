//
//  C411EditProfileVC.m
//  cell411
//
//  Created by Milan Agarwal on 25/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411EditProfileVC.h"
#import "ConfigConstants.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ServerUtility.h"
#import "AppDelegate.h"
#import "MA_Country.h"
#import "C411CountrySelectionVC.h"
#import "C411ColorHelper.h"

#if PHONE_VERIFICATION_ENABLED
#import "MAAlertPresenter.h"
#import "C411PhoneVerificationVC.h"
#endif

@interface C411EditProfileVC ()<UITextFieldDelegate,UITextViewDelegate,C411CountrySelectionVCDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgVuUserFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UIView *vuUserFirstNameSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuUserLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UIView *vuUserLastNameSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIView *vuEmailSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuDropdown;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet UIView *vuPhoneNumberSeparator;

@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmergency;
@property (weak, nonatomic) IBOutlet UILabel *lblEmergencyHeading;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmergencyContactName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmergencyContactName;
@property (weak, nonatomic) IBOutlet UIView *vuEmergencyContactNameSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmergencyContactNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmergencyContactDropdown;
@property (weak, nonatomic) IBOutlet UITextField *txtEmergencyContactNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnEmergencyContactCountryCode;
@property (weak, nonatomic) IBOutlet UIView *vuEmergencyContactNumberSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuBloodGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroupHeading;
@property (weak, nonatomic) IBOutlet UIView *vuBloodGroupContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblAllergiesPlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAllergies;
@property (weak, nonatomic) IBOutlet UILabel *lblAllergiesHeading;
@property (weak, nonatomic) IBOutlet UITextView *txtVuAllergies;
@property (weak, nonatomic) IBOutlet UIView *vuAllergiesSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuOtherMedicalConditions;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherMedicalConditionsHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblOtherMedicalConditionsPlaceholder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vuBaseBLConstraints;
@property (weak, nonatomic) IBOutlet UITextView *txtVuOtherMedicalConditions;
@property (weak, nonatomic) IBOutlet UIView *vuOtherMedicalConditionsSeparator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;
- (IBAction)btnBloodGroupTapped:(UIButton *)sender;
- (IBAction)barBtnUpdateTapped:(UIBarButtonItem *)sender;
- (IBAction)btnCountryCodeTapped:(UIButton *)sender;
- (IBAction)btnEmergencyContactCountryCodeTapped:(UIButton *)sender;



@property (nonatomic, strong) NSString *strSelectedBloodType;
///Property for scroll management
@property (nonatomic, assign) float kbHeight;
@property (nonatomic, assign) CGFloat scrlVuInitialBLConstarintValue;

@property (nonatomic, assign, getter=isPhoneNumberChanged) BOOL phoneNumberChanged;

@property (weak, nonatomic)  UIButton *btnSelectedCountryCode;
@property (nonatomic, strong) MA_Country *selectedCountry;
@property (nonatomic, strong) MA_Country *selectedCountryForEmergencyContact;

@end

@implementation C411EditProfileVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViews];
    [self fillDetails];
    [self registerForNotifications];
    
    ///set initial bottom constraint of scrollview
    self.scrlVuInitialBLConstarintValue = self.vuBaseBLConstraints.constant;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self unregisterNotifications];
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(phoneUpdatedNotification:) name:kPhoneUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)configureViews
{
    self.title = NSLocalizedString(@"Edit Profile", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    ///set corner radius of blood group buttons container
    self.vuBloodGroupContainer.layer.cornerRadius = 3.0;
    self.vuBloodGroupContainer.layer.masksToBounds = YES;
 
    [self applyColors];
}

-(void)applyColors {
    ///Set BG color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set hint icon colors
    UIColor *hintIconColor = [C411ColorHelper sharedInstance].hintIconColor;
    self.imgVuUserFirstName.tintColor = hintIconColor;
    self.imgVuUserLastName.tintColor = hintIconColor;
    self.imgVuEmail.tintColor = hintIconColor;
    self.imgVuPhoneNumber.tintColor = hintIconColor;
    self.imgVuDropdown.tintColor = hintIconColor;
    self.imgVuEmergencyContactName.tintColor = hintIconColor;
    self.imgVuEmergencyContactNumber.tintColor = hintIconColor;
    self.imgVuEmergencyContactDropdown.tintColor = hintIconColor;
    
    ///Set dark hint color
    UIColor *darkHintIconColor = [C411ColorHelper sharedInstance].darkHintIconColor;
    self.imgVuBloodGroup.tintColor = darkHintIconColor;
    self.imgVuEmergency.tintColor = darkHintIconColor;
    self.imgVuAllergies.tintColor = darkHintIconColor;
    self.imgVuOtherMedicalConditions.tintColor = darkHintIconColor;
    
    
    ///Set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.txtFirstName.textColor = primaryTextColor;
    self.txtLastName.textColor = primaryTextColor;
    self.txtEmail.textColor = primaryTextColor;
    [self.btnCountryCode setTitleColor:primaryTextColor forState:UIControlStateNormal];
    self.txtPhoneNumber.textColor = primaryTextColor;
    self.txtEmergencyContactName.textColor = primaryTextColor;
    self.txtEmergencyContactNumber.textColor = primaryTextColor;
    [self.btnEmergencyContactCountryCode setTitleColor:primaryTextColor forState:UIControlStateNormal];
    self.txtVuAllergies.textColor = primaryTextColor;
    self.txtVuOtherMedicalConditions.textColor = primaryTextColor;
    self.lblBloodGroupHeading.textColor = primaryTextColor;
    self.lblEmergencyHeading.textColor = primaryTextColor;
    self.lblAllergiesHeading.textColor = primaryTextColor;
    self.lblOtherMedicalConditionsHeading.textColor = primaryTextColor;
    
    ///Set disabled color for placeholder text
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtFirstName];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtLastName];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtEmail];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtPhoneNumber];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtEmergencyContactName];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtEmergencyContactNumber];
    self.lblAllergiesPlaceholder.textColor = disabledTextColor;
    self.lblOtherMedicalConditionsPlaceholder.textColor = disabledTextColor;
    
    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuUserFirstNameSeparator.backgroundColor = separatorColor;
    self.vuUserLastNameSeparator.backgroundColor = separatorColor;
    self.vuEmailSeparator.backgroundColor = separatorColor;
    self.vuPhoneNumberSeparator.backgroundColor = separatorColor;
    self.vuEmergencyContactNameSeparator.backgroundColor = separatorColor;
    self.vuEmergencyContactNumberSeparator.backgroundColor = separatorColor;
    self.vuAllergiesSeparator.backgroundColor = separatorColor;
    self.vuOtherMedicalConditionsSeparator.backgroundColor = separatorColor;
    
    ///Set light card color
    self.vuBloodGroupContainer.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    
    ///set blood group buttons
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    for (UIView *subview in self.vuBloodGroupContainer.subviews) {
        
        if ([subview isKindOfClass:[UIButton class]]) {
            
            UIButton *btnBloodGroup = (UIButton *)subview;
            [btnBloodGroup setTitleColor:themeColor forState:UIControlStateNormal];
            [btnBloodGroup setTitleColor:primaryBGTextColor forState:UIControlStateSelected];
            btnBloodGroup.backgroundColor = primaryBGTextColor;
            btnBloodGroup.layer.borderColor = themeColor.CGColor;
            btnBloodGroup.layer.borderWidth = 2.0;
            [C411StaticHelper makeCircularView:btnBloodGroup];
        }
    }
    
    self.txtVuAllergies.keyboardAppearance = [C411ColorHelper sharedInstance].keyboardAppearance;
    self.txtVuOtherMedicalConditions.keyboardAppearance = [C411ColorHelper sharedInstance].keyboardAppearance;

}

-(void)fillDetails
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    __weak typeof(self) weakSelf = self;
    
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (object) {
            
            ///show name
            weakSelf.txtFirstName.text = currentUser[kUserFirstnameKey];
            weakSelf.txtLastName.text = currentUser[kUserLastnameKey];
            
            ///show user email
            NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
            weakSelf.txtEmail.text = strEmail;
            
            ///show phone number
            //weakSelf.txtPhoneNumber.text = currentUser[kUserMobileNumberKey];
            ///Get the country code and phone number
            NSString *strContactNumber = currentUser[kUserMobileNumberKey];
            NSDictionary *dictContactDetails = [C411StaticHelper splitPhoneNumberAndCountryCodeFromNumber:strContactNumber];
            
            weakSelf.selectedCountry = [dictContactDetails objectForKey:kPhoneCountryKey];
            NSString *strPhoneNumber = [dictContactDetails objectForKey:kPhoneNumberKey];
            weakSelf.txtPhoneNumber.text = strPhoneNumber ? strPhoneNumber : @"";

            [weakSelf updateCountryCode:weakSelf.selectedCountry forButton:weakSelf.btnCountryCode];
            
            ///show emergency contact name
            NSString *strEmergencyContactName = currentUser[kUserEmergencyContactNameKey];
            if (strEmergencyContactName.length > 0) {
                
                weakSelf.txtEmergencyContactName.text = strEmergencyContactName;
            }
            
            
            ///show emergency contact number
            NSString *strEmergencyContactNumber = currentUser[kUserEmergencyContactNumberKey];
/*
            if (strEmergencyContactNumber.length > 0) {
                
                weakSelf.txtEmergencyContactNumber.text = strEmergencyContactNumber;
            }
*/
            NSDictionary *dictEmergencyContactDetails = [C411StaticHelper splitPhoneNumberAndCountryCodeFromNumber:strEmergencyContactNumber];
            
            weakSelf.selectedCountryForEmergencyContact = [dictEmergencyContactDetails objectForKey:kPhoneCountryKey];
            NSString *strEmergencyPhoneNumber = [dictEmergencyContactDetails objectForKey:kPhoneNumberKey];
            weakSelf.txtEmergencyContactNumber.text = strEmergencyPhoneNumber ? strEmergencyPhoneNumber : @"";
            [weakSelf updateCountryCode:weakSelf.selectedCountryForEmergencyContact forButton:weakSelf.btnEmergencyContactCountryCode];
            

            
            ///select blood group
            NSString *strBloodType = currentUser[kUserBloodTypeKey];
            if (strBloodType.length > 0) {
                
                [weakSelf selectBloodGroup:strBloodType];
            }
            
            ///show allergies
            NSString *strAllergies = currentUser[kUserAllergiesKey];
            if (strAllergies.length > 0) {
                
                weakSelf.txtVuAllergies.text = strAllergies;
                weakSelf.lblAllergiesPlaceholder.hidden = YES;
            }
            
            
            ///show Other Medical Conditions
            NSString *strOMC = currentUser[kUserOtherMedicalCondtionsKey];
            if (strOMC.length > 0) {
                
                weakSelf.txtVuOtherMedicalConditions.text = strOMC;
                weakSelf.lblOtherMedicalConditionsPlaceholder.hidden = YES;
                
            }
            
            
            
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

-(void)selectBloodGroup:(NSString *)strBloodGroup
{
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    
    for (UIView *subview in self.vuBloodGroupContainer.subviews) {
        
        if ([subview isKindOfClass:[UIButton class]]) {
            
            UIButton *btnBloodGroup = (UIButton *)subview;
            NSString *strTitle = [btnBloodGroup titleForState:UIControlStateNormal];
            if ([strBloodGroup isEqualToString:strTitle]) {
                
                if (btnBloodGroup.isSelected) {
                    ///deselect the blood group
                    btnBloodGroup.selected = NO;
                    btnBloodGroup.backgroundColor = primaryBGTextColor;
                    self.strSelectedBloodType = nil;
                }
                else{
                    
                    ///select the blood group
                    btnBloodGroup.selected = YES;
                    btnBloodGroup.backgroundColor = themeColor;
                    self.strSelectedBloodType = strBloodGroup;
                }
            }
            else{
                
                btnBloodGroup.selected = NO;
                btnBloodGroup.backgroundColor = primaryBGTextColor;
                
            }
            
        }
    }


}

-(BOOL)canUpdateAccount
{
    NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedFirstName = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedLastName = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedMobileNumber = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedEmergencyNumber = [self.txtEmergencyContactNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    ///Validate Email is provided or not
    if ((!strTrimmedEmail) || (strTrimmedEmail.length == 0)) {
        NSString *localizedEmptyEmailMsg = NSLocalizedString(@"Please enter email", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyEmailMsg onViewController:self];
        
        return NO;
    }
    ///Validate whether email is valid or not
    else if (![C411StaticHelper isValidEmail:strTrimmedEmail]){
        NSString *localizedInvalidEmailMsg = NSLocalizedString(@"Please enter valid email", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedInvalidEmailMsg onViewController:self];
        
        return NO;

    }
    ///Validate Firstname
    else if ((!strTrimmedFirstName) || (strTrimmedFirstName.length == 0)) {
        
        NSString *localizedEmptyFirstNameMsg = NSLocalizedString(@"Please enter firstname", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyFirstNameMsg onViewController:self];
        
        return NO;
    }
    ///Validate Lastname
    else if ((!strTrimmedLastName) || (strTrimmedLastName.length == 0)) {
        
        NSString *localizedEmptyLastNameMsg = NSLocalizedString(@"Please enter lastname", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyLastNameMsg onViewController:self];
        
        return NO;
    }
    ///Validate Country code
    if(!(self.selectedCountry)){
        
        NSString *localizedEmptyCountryCodeMsg = NSLocalizedString(@"Please select your country", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyCountryCodeMsg onViewController:self];
        
        return NO;
        
    }
    ///Validate Mobile number
    else if ((!strTrimmedMobileNumber) || (strTrimmedMobileNumber.length == 0)) {
        
        NSString *localizedEmptyMobNumberMsg = NSLocalizedString(@"Please enter mobile number", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyMobNumberMsg onViewController:self];
        
        return NO;
    }
#if (APP_IER || APP_RO112)
    
    else if (![C411StaticHelper isMobileNumberValid:strTrimmedMobileNumber forCountry:self.selectedCountry]) {
        
        NSString *localizedInvalidMobNumberMsg = NSLocalizedString(@"Please enter valid mobile number", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedInvalidMobNumberMsg onViewController:self];
        
        return NO;

    }
    
#endif

    ///Validate if emergency contact number is given but country code is selected for it or not
    else if((strTrimmedEmergencyNumber.length > 0) && (self.selectedCountryForEmergencyContact == nil)){
        
        NSString *localizedEmptyCountryCodeMsg = NSLocalizedString(@"Please select country for your emergency contact", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyCountryCodeMsg onViewController:self];
        
        return NO;

    }
#if (APP_IER || APP_RO112)
    
    else if ((strTrimmedEmergencyNumber.length > 0) && (![C411StaticHelper isMobileNumberValid:strTrimmedEmergencyNumber forCountry:self.selectedCountryForEmergencyContact])) {
        
        NSString *localizedInvalidMobNumberMsg = NSLocalizedString(@"Please enter valid emergency mobile number", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedInvalidMobNumberMsg onViewController:self];
        
        return NO;
        
    }
    
#endif

    ///Check if any info has been changed or not
    BOOL isUpdated = [self areUserDetailsUpdated];
    
    return isUpdated;
}

-(BOOL)areUserDetailsUpdated
{
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedFirstName = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedLastName = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedMobileNumber = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#if (APP_IER || APP_RO112)
    strTrimmedMobileNumber = [C411StaticHelper removeCountryCodePrefixFromMobileNumber:strTrimmedMobileNumber forCountry:self.selectedCountry];
#endif

    NSString *strTrimmedEmergencyName = [self.txtEmergencyContactName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedEmergencyNumber = [self.txtEmergencyContactNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#if (APP_IER || APP_RO112)
    strTrimmedEmergencyNumber = [C411StaticHelper removeCountryCodePrefixFromMobileNumber:strTrimmedEmergencyNumber forCountry:self.selectedCountryForEmergencyContact];
#endif

    NSString *strTrimmedAllergies = [self.txtVuAllergies.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedOMC = [self.txtVuOtherMedicalConditions.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    ///Append country code selected to given phone number
    strTrimmedMobileNumber = [self.selectedCountry.dialingCode stringByAppendingString:strTrimmedMobileNumber];
    
    ///Get the current contact details for the current user
    NSString *strContactNumber = currentUser[kUserMobileNumberKey];
    if (strContactNumber.length > 0) {
        ///Extract the numeric string only
        strContactNumber = [C411StaticHelper getNumericStringFromString:strContactNumber];
        
    }
    
    if(strTrimmedEmergencyNumber.length > 0){
        
        ///Append country code selected to given phone number
        strTrimmedEmergencyNumber = [self.selectedCountryForEmergencyContact.dialingCode stringByAppendingString:strTrimmedEmergencyNumber];

    }
    
    ///assign empty string if it's nil
    strTrimmedEmergencyNumber = strTrimmedEmergencyNumber ? strTrimmedEmergencyNumber : @"";
    
    
    ///Get the current contact details for the emergency contact
    NSString *strEmergencyContactNumber = currentUser[kUserEmergencyContactNumberKey];
    if (strEmergencyContactNumber.length > 0) {
        ///Extract the numeric string only
        strEmergencyContactNumber = [C411StaticHelper getNumericStringFromString:strEmergencyContactNumber];

    }

    ///assign empty string if it's nil
    strEmergencyContactNumber = strEmergencyContactNumber ? strEmergencyContactNumber : @"";

    ///Check for phone number first
    if ((strContactNumber == nil)
        ||(strContactNumber.length == 0)
        ||(![strTrimmedMobileNumber isEqualToString:strContactNumber])){
        
//#if PHONE_VERIFICATION_ENABLED
        self.phoneNumberChanged = YES;
//#endif
        return YES;
    }
    else{
        
//#if PHONE_VERIFICATION_ENABLED
        self.phoneNumberChanged = NO;
//#endif

    }
    
    ///Check for email
    SignUpType signUpType = [C411StaticHelper getSignUpTypeOfUser:currentUser];
    if (signUpType == SignUpTypeEmail) {
        ///user signed up using email, compare email with username field
        if (![strTrimmedEmail.lowercaseString isEqualToString:currentUser.username]) {
            
            return YES;

        }
    }
    else{
        
        ///user signed up using social media, compare email with email field
        if (![strTrimmedEmail.lowercaseString isEqualToString:currentUser.email]) {
            
            return YES;
            
        }

    }
    
    ///check other fields
    if (![strTrimmedFirstName isEqualToString:currentUser[kUserFirstnameKey]]){
        
        return YES;
    }
    else if (![strTrimmedLastName isEqualToString:currentUser[kUserLastnameKey]]){
        
        return YES;
    }
    else if (![strTrimmedEmergencyName isEqualToString:currentUser[kUserEmergencyContactNameKey]]){
        
        return YES;
    }
    /*
    else if (![strTrimmedEmergencyNumber isEqualToString:currentUser[kUserEmergencyContactNumberKey]]){
        
        return YES;
    }
     */
    else if (![strTrimmedEmergencyNumber isEqualToString:strEmergencyContactNumber]){
        
        return YES;
    }
    else if ([self isBloodTypeChanged]){
        
        return YES;
    }
    else if (![strTrimmedAllergies isEqualToString:currentUser[kUserAllergiesKey]]){
        
        return YES;
    }
    else if (![strTrimmedOMC isEqualToString:currentUser[kUserOtherMedicalCondtionsKey]]){
        
        return YES;
    }
    
    return NO;
    
    
}

-(BOOL)isBloodTypeChanged
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *oldBloodType = currentUser[kUserBloodTypeKey];
    if (oldBloodType.length == self.strSelectedBloodType.length) {
        
        ///both could be nil or could have characters count
        if (oldBloodType.length > 0) {
            
            ///have same character count, check for string equality
            if ([oldBloodType isEqualToString:self.strSelectedBloodType]) {
                return NO;
            }
            
        }
        else{
            ///both are empty
            return NO;
            
        }
        
        
    }
    
    return YES;
}

-(void)updateUserDetails
{
    ///Create user object and initialize its fields
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strOldEmail = currentUser.username;
    
    NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedFirstName = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedLastName = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *strTrimmedEmergencyName = [self.txtEmergencyContactName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedEmergencyNumber = [self.txtEmergencyContactNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#if (APP_IER || APP_RO112)
    strTrimmedEmergencyNumber = [C411StaticHelper removeCountryCodePrefixFromMobileNumber:strTrimmedEmergencyNumber forCountry:self.selectedCountryForEmergencyContact];
#endif

    NSString *strEmergContactNumWithCountryCode = strTrimmedEmergencyNumber;
    if (strTrimmedEmergencyNumber.length > 0) {
        
        ///Merge the country code if emergency number is provided
        strEmergContactNumWithCountryCode = [NSString stringWithFormat:@"%@%@",self.selectedCountryForEmergencyContact.dialingCode,strTrimmedEmergencyNumber];
        
    }
    
    NSString *strTrimmedAllergies = [self.txtVuAllergies.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *strTrimmedOMC = [self.txtVuOtherMedicalConditions.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    SignUpType signUpType = [C411StaticHelper getSignUpTypeOfUser:currentUser];
    if (signUpType == SignUpTypeEmail) {
        currentUser.username = strTrimmedEmail.lowercaseString;
    }
    else{
        /// save old email
        strOldEmail = currentUser.email;
        ///update email
        currentUser.email = strTrimmedEmail.lowercaseString;
        
    }
    
    // other fields can be set just like with PFObject
    currentUser[kUserFirstnameKey] = strTrimmedFirstName;
    currentUser[kUserLastnameKey] = strTrimmedLastName;
    
    NSString *strContactNumberWithCountryCode = @"";
    
#if (!PHONE_VERIFICATION_ENABLED)
    
    ///Update phone number instantly if phone verification feature is not enabled, otherwise it has to be updated on phone verification screen
    NSString *strTrimmedMobileNumber = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#if (APP_IER || APP_RO112)
    strTrimmedMobileNumber = [C411StaticHelper removeCountryCodePrefixFromMobileNumber:strTrimmedMobileNumber forCountry:self.selectedCountry];
#endif

    strContactNumberWithCountryCode = [NSString stringWithFormat:@"%@%@",self.selectedCountry.dialingCode,strTrimmedMobileNumber];

    currentUser[kUserMobileNumberKey] = strContactNumberWithCountryCode;
    
#endif
    
    currentUser[kUserEmergencyContactNameKey] = strTrimmedEmergencyName;
    currentUser[kUserEmergencyContactNumberKey] = strEmergContactNumWithCountryCode;
    currentUser[kUserBloodTypeKey] = self.strSelectedBloodType ? self.strSelectedBloodType : @"";
    currentUser[kUserAllergiesKey] = strTrimmedAllergies;
    currentUser[kUserOtherMedicalCondtionsKey] = strTrimmedOMC;
    
    ///Create weak refrence of self to be used in block
    __weak typeof (self) weakSelf = self;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        ///1.Enable interaction
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        if (!error) {
            
            ///User details updated, notify observers for the update
            [[NSNotificationCenter defaultCenter]postNotificationName:kMyProfileUpdatedNotification object:nil];
            BOOL isVerifyingPhone = NO;
//#if PHONE_VERIFICATION_ENABLED
            ///Show verify phone popup as the phone can only be changed after user verify it
            if (weakSelf.isPhoneNumberChanged) {
                
                weakSelf.phoneNumberChanged = NO;
#if PHONE_VERIFICATION_ENABLED
                
                ///show the popup asking to verify phone
                [weakSelf showVerifyPhonePopup];
                isVerifyingPhone = YES;
#endif
            }
//#endif
            
            

#if APP_IER
             
             ///Make an IER API call as well to update user profile
             NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
            
            ///Set user id
            [dictParams setObject:currentUser.objectId forKey:IER_API_PARAM_UNIQUE_ID];

            ///Set first name
            [dictParams setObject:strTrimmedFirstName forKey:IER_API_PARAM_FIRST_NAME];

            ///set last name
            [dictParams setObject:strTrimmedLastName forKey:IER_API_PARAM_SURNAME];
            
             ///set user email
             [dictParams setObject:strTrimmedEmail forKey:IER_API_PARAM_CONTACT_EMAIL];
             
             ///Set user mobile
             [dictParams setObject:strContactNumberWithCountryCode forKey:IER_API_PARAM_CONTACT_MOBILE];
             
            
            ///set Emergency contact name
            [dictParams setObject:(strTrimmedEmergencyName ? strTrimmedEmergencyName : @"") forKey:IER_API_PARAM_EMER_CONTACT];
            
            ///set Emergency contact mobile
             [dictParams setObject:(strEmergContactNumWithCountryCode ? strEmergContactNumWithCountryCode : @"") forKey:IER_API_PARAM_EMER_CONTACT_NUM];
           
            ///set Blood Type
             [dictParams setObject:(weakSelf.strSelectedBloodType ? weakSelf.strSelectedBloodType : @"") forKey:IER_API_PARAM_BLOOD_GROUP];
            
            ///set Allergies
             [dictParams setObject:(strTrimmedAllergies ? strTrimmedAllergies : @"") forKey:IER_API_PARAM_ALLERGIES];
            
            ///set Other medical conditions
            [dictParams setObject:(strTrimmedOMC ? strTrimmedOMC : @"") forKey:IER_API_PARAM_CONDITIONS];
            
             [ServerUtility updateIERUserWithDetails:dictParams andCompletion:NULL];
            
#endif

            if(!isVerifyingPhone){
                ///Go back to previous screen on success
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            
            
        } else {
            
            if(![AppDelegate handleParseError:error]){
                // Show the errorString somewhere and let the user try again.
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                
                if (error.code == kPFErrorUsernameTaken) {
                    ///This error will occur for email user, revert the username back to older email
                    currentUser.username = strOldEmail;
                    
                    ///update the username textfield as well
                    weakSelf.txtEmail.text = strOldEmail;
                }
                else if (error.code == kPFErrorUserEmailTaken){
                    ///This error will occur for facebook user,revert the email back to older email
                    currentUser.email = strOldEmail;
                    
                    ///update the username textfield as well
                    weakSelf.txtEmail.text = strOldEmail;
                    
                    
                }
            }
        }
    }];
}

-(void)updateUserAccount
{
    NSString *strTrimmedMobileNumber = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#if (APP_IER || APP_RO112)
    strTrimmedMobileNumber = [C411StaticHelper removeCountryCodePrefixFromMobileNumber:strTrimmedMobileNumber forCountry:self.selectedCountry];
#endif
    NSString *strContactNumberWithCountryCode = [NSString stringWithFormat:@"%@%@",self.selectedCountry.dialingCode,strTrimmedMobileNumber];

    ///Create weak refrence of self to be used in block
    __weak typeof (self) weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.isPhoneNumberChanged) {
        
        ///check if there is already a user with this phone or not
        [C411StaticHelper getUserWithMobileNumber:strContactNumberWithCountryCode ignoreCurrentUser:YES andCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if (!error && object) {
                ///1.Enable interaction
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                ///Found existing user object with this phone, show the error message that user already exist with this phone
                NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"There is already an account registered with mobile number %@. Please use different mobile number.",nil),strContactNumberWithCountryCode];
                [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf.view.window.rootViewController];
                
                
            }
            else if (error.code == kPFErrorObjectNotFound){
                
                ///The mobile number given by user is unique
                [self updateUserDetails];
                
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
      
        [self updateUserDetails];

    }

}

#if PHONE_VERIFICATION_ENABLED
-(void)showVerifyPhonePopup
{
    
    ///Show the alert and on yes go to the phobe verification screen
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Verification Required", nil) message:NSLocalizedString(@"Please verify your phone", nil) preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;

    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///User tapped cancel, so revert the number back to old one
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        NSString *strContactNumber = currentUser[kUserMobileNumberKey];
        NSDictionary *dictContactDetails = [C411StaticHelper splitPhoneNumberAndCountryCodeFromNumber:strContactNumber];
        
        weakSelf.selectedCountry = [dictContactDetails objectForKey:kPhoneCountryKey];
        NSString *strPhoneNumber = [dictContactDetails objectForKey:kPhoneNumberKey];
        weakSelf.txtPhoneNumber.text = strPhoneNumber ? strPhoneNumber : @"";
        
        [weakSelf updateCountryCode:weakSelf.selectedCountry forButton:weakSelf.btnCountryCode];
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    UIAlertAction *verifyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Verify", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///User is ready to verify, show the phone verification screen
        C411PhoneVerificationVC *phoneVerificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PhoneVerificationVC"];
        NSString *strTrimmedMobileNumber = [self.txtPhoneNumber.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#if (APP_IER || APP_RO112)
        strTrimmedMobileNumber = [C411StaticHelper removeCountryCodePrefixFromMobileNumber:strTrimmedMobileNumber forCountry:self.selectedCountry];
#endif

        NSString *strContactNumberWithCountryCode = [NSString stringWithFormat:@"%@%@",self.selectedCountry.dialingCode,strTrimmedMobileNumber];
        phoneVerificationVC.strContactNumber = strContactNumberWithCountryCode;
        phoneVerificationVC.verificationCompletionHandler = ^{
            ///Pop out all the VC on top of current VC i.e phone verification vc
            [weakSelf.navigationController popToViewController:weakSelf.previousVC animated:YES];
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
#endif


-(void)updateCountryCode:(MA_Country *)country forButton:(UIButton *)btnCountryCode
{
    NSString *strTitle = nil;
    if (country) {
        ///Country code is available
        strTitle = [@"+" stringByAppendingString:country.dialingCode];
    }
    else{
        ///Country code is not available
        strTitle = NSLocalizedString(@"Select", nil);
        
    }

    ///set the country code text on button
    [btnCountryCode setTitle:strTitle forState:UIControlStateNormal];
}



//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnBloodGroupTapped:(UIButton *)sender {
    NSString *strBloodGroup = [sender titleForState:UIControlStateNormal];
    
    [self selectBloodGroup:strBloodGroup];
    
}

- (IBAction)barBtnUpdateTapped:(UIBarButtonItem *)sender {
    
    if ([self canUpdateAccount]) {
        NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        PFUser *currentUser = [AppDelegate getLoggedInUser];
        SignUpType signUpType = [C411StaticHelper getSignUpTypeOfUser:currentUser];
        __weak typeof(self) weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        if (signUpType == SignUpTypeEmail) {
           
            ///As we will update the username field which will be automatically validated by Parse for uniqueness, we need to check whether there is already a user with this email
            PFQuery *getExistingUserWithSameEmailQuery = [PFUser query];
            [getExistingUserWithSameEmailQuery whereKey:@"email" equalTo:strTrimmedEmail.lowercaseString];
            [getExistingUserWithSameEmailQuery whereKey:@"objectId" notEqualTo:currentUser.objectId];
            [getExistingUserWithSameEmailQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                
                ///1.Enable interaction
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

                if (!error && object) {
                    
                    ///Found user object with this email, show the error message that user already exist with this email
                    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is already registered, please use different email",nil),strTrimmedEmail];
                    [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf];
                    
                    
                }
                else if (error.code == kPFErrorObjectNotFound){
                    
                    ///No user exist with this email, you can update the user email safely
                    [weakSelf updateUserAccount];
                    
                }
                else{
                    
                    if(![AppDelegate handleParseError:error]){
                        // Show the errorString somewhere and let the user try again.
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                    }
                }


                
            }];

            
        }
        else{
            ///As we will update the email field which will be automatically validated by Parse for uniqueness, we need to check whether there is already a user with this username
            PFQuery *getExistingUserWithSameEmailQuery = [PFUser query];
            [getExistingUserWithSameEmailQuery whereKey:@"username" equalTo:strTrimmedEmail.lowercaseString];
            [getExistingUserWithSameEmailQuery whereKey:@"objectId" notEqualTo:currentUser.objectId];
            [getExistingUserWithSameEmailQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                
                ///1.Enable interaction
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                if (!error && object) {
                    
                    ///Found user object with this email, show the error message that user already exist with this email
                    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is already registered, please use different email",nil),strTrimmedEmail];
                    [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf];
                    
                    
                }
                else if (error.code == kPFErrorObjectNotFound){
                    
                    ///No user exist with this email, you can update the user email safely
                    [weakSelf updateUserAccount];
                    
                }
                else{
                    
                    if(![AppDelegate handleParseError:error]){
                        // Show the errorString somewhere and let the user try again.
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                    }
                }
                
                
                
            }];

            
        }
        
        ///remove keyboard
        [self.view endEditing:YES];
    }

}

- (IBAction)btnCountryCodeTapped:(UIButton *)sender {
    
    ///Show the country selection VC
    C411CountrySelectionVC *countrySelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411CountrySelectionVC"];
    countrySelectionVC.delegate = self;
    countrySelectionVC.selectedCountryName = self.selectedCountry.name;
    [self.navigationController pushViewController:countrySelectionVC animated:YES];
    
    ///set selected button for country code as current button
    self.btnSelectedCountryCode = sender;

}

- (IBAction)btnEmergencyContactCountryCodeTapped:(UIButton *)sender {
    
    ///Show the country selection VC
    C411CountrySelectionVC *countrySelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411CountrySelectionVC"];
    countrySelectionVC.delegate = self;
    countrySelectionVC.selectedCountryName = self.selectedCountryForEmergencyContact.name;
    [self.navigationController pushViewController:countrySelectionVC animated:YES];
    
    ///set selected button for country code as current button
    self.btnSelectedCountryCode = sender;
    
}

//****************************************************
#pragma mark - C411CountrySelectionVCDelegate Methods
//****************************************************

-(void)countrySelectionVC:(C411CountrySelectionVC *)countrySelectionVC didSelectCountry:(MA_Country *)country
{
    if(self.btnSelectedCountryCode == self.btnCountryCode){
       
        ///Country code button tapped for current user contact number
        self.selectedCountry = country;

    }
    else{
        ///Country code button tapped for emergency contact number

        self.selectedCountryForEmergencyContact = country;
    }
    
    [self updateCountryCode:country forButton:self.btnSelectedCountryCode];
}


//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtFirstName){
        
        [self.txtLastName becomeFirstResponder];
        return NO;
    }
    else if (textField == self.txtLastName){
        
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    else if (textField == self.txtEmail) {
        
        [self.txtPhoneNumber becomeFirstResponder];
        return NO;
    }
  
    else if (textField == self.txtPhoneNumber){
        
        [self.txtEmergencyContactName becomeFirstResponder];
        return NO;
    }
    else if (textField == self.txtEmergencyContactName){
        
        [self.txtEmergencyContactNumber becomeFirstResponder];
        return NO;
    }
    else{
        [textField resignFirstResponder];
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    float yOffset = textField.frame.origin.y - self.txtFirstName.frame.origin.y;
    if (yOffset >= 0) {
        
        float underBarPadding = 0;
        [self.scrlVuBase setContentOffset:CGPointMake(self.scrlVuBase.contentOffset.x,yOffset - underBarPadding) animated:YES];
        
    }
    
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ((textField == self.txtPhoneNumber || textField == self.txtEmergencyContactNumber) && string.length > 0) {
        
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

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    float yOffset = textView.frame.origin.y - self.txtFirstName.frame.origin.y;
    if (yOffset >= 0) {
        
        float underBarPadding = 0;
        [self.scrlVuBase setContentOffset:CGPointMake(self.scrlVuBase.contentOffset.x,yOffset - underBarPadding) animated:YES];
        
    }
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    ///Toggle Place holder visibility
    if (finalString && finalString.length > 0) {
        ///Hide Placeholder string
        if (textView == self.txtVuAllergies) {
            
            self.lblAllergiesPlaceholder.hidden = YES;
            
        }
        else if (textView == self.txtVuOtherMedicalConditions){
            
            self.lblOtherMedicalConditionsPlaceholder.hidden = YES;
            
        }
        
    }
    else{
        ///Show Placeholder string
        if (textView == self.txtVuAllergies) {
            
            self.lblAllergiesPlaceholder.hidden = NO;
            
        }
        else if (textView == self.txtVuOtherMedicalConditions){
            
            self.lblOtherMedicalConditionsPlaceholder.hidden = NO;
            
        }
    }
    
    return YES;
    
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

-(void)phoneUpdatedNotification:(NSNotification *)notif
{
    ///set the phone number
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strContactNumber = currentUser[kUserMobileNumberKey];
    if (strContactNumber.length > 0) {
        
        ///Contact number is available, set it on textfield
        NSDictionary *dictContactDetails = [C411StaticHelper splitPhoneNumberAndCountryCodeFromNumber:strContactNumber];
        
        self.selectedCountry = [dictContactDetails objectForKey:kPhoneCountryKey];
        [self updateCountryCode:self.selectedCountry forButton:self.btnCountryCode];
        
        NSString *strPhoneNumber = [dictContactDetails objectForKey:kPhoneNumberKey];
        self.txtPhoneNumber.text = strPhoneNumber ? strPhoneNumber : @"";
        
    }
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
