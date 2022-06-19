//
//  C411PhoneVerificationVC.m
//  cell411
//
//  Created by Milan Agarwal on 27/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PhoneVerificationVC.h"
#import "C411StaticHelper.h"
#import "C411PhoneVerificationVC.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "ServerUtility.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MAAlertPresenter.h"
#import "C411AddPhoneVC.h"
#import "C411ColorHelper.h"

#define TXT_TAG_ALERT_PHONE     301

typedef NS_ENUM(NSUInteger, PhoneVerificationJob) {
    PhoneVerificationJobPhoneVerified,
    PhoneVerificationJobPhoneAdded,
    PhoneVerificationJobPhoneUpdated
};

@interface C411PhoneVerificationVC ()<UITextFieldDelegate
#if PHONE_VERIFICATION_ENABLED
,C411AddPhoneVCDelegate
#endif
>
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet UITextField *txtPincode1;
@property (weak, nonatomic) IBOutlet UITextField *txtPincode2;
@property (weak, nonatomic) IBOutlet UITextField *txtPincode3;
@property (weak, nonatomic) IBOutlet UITextField *txtPincode4;
@property (weak, nonatomic) IBOutlet UILabel *lblCodeNotReceived;
@property (weak, nonatomic) IBOutlet UIButton *btnResendCode;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btnKeyboardNumbersCollection;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuEye;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuClear;
@property (weak, nonatomic) IBOutletCollection(UIView) NSArray *vuNumberPadSeparatorCollection;

- (IBAction)btnKeyboardNumberTapped:(UIButton *)sender;
- (IBAction)btnTogglePincodeVisibilityTapped:(UIButton *)sender;
- (IBAction)btnDeleteTapped:(UIButton *)sender;

- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnResendCodeTapped:(UIButton *)sender;

@property (nonatomic, assign)int verificationCode;
@property (nonatomic, strong) NSMutableString *strEnteredCode;
///reference to the UPDATE action method will be stored in this to use it to enable it later when there is some text inputted by user in update mobile number popup
@property (nonatomic, weak) UIAlertAction *updateAction;
@property (nonatomic, assign) PhoneVerificationJob verificationJob;
@property (nonatomic, assign, getter=shouldShowNavBar) BOOL showNavBar;
@end

@implementation C411PhoneVerificationVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    ///Send verification code
    [self sendVerificationCode];
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!(self.navigationController.navigationBarHidden)) {
        
        ///Navigation bar is initially visible so hide it and save it's state to show it again when going back
        self.showNavBar = YES;
        
        self.navigationController.navigationBarHidden = YES;
        
        
    }

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
    ///Configure Pincode
    _txtPincode1.layer.cornerRadius = 5.0;
    _txtPincode1.layer.masksToBounds = YES;
    
     _txtPincode2.layer.cornerRadius = 5.0;
    _txtPincode2.layer.masksToBounds = YES;
    
    _txtPincode3.layer.cornerRadius = 5.0;
    _txtPincode3.layer.masksToBounds = YES;
    
    _txtPincode4.layer.cornerRadius = 5.0;
    _txtPincode4.layer.masksToBounds = YES;
    
    ///Configure Numbers in Keyboard
//    for (UIButton *btnNumber in _btnKeyboardNumbersCollection) {
//        btnNumber.titleLabel.font = [UFTFontResource fontOpenSansRegularWithSize:24.0];
//        
//    }
     [self applyColors];
}

-(void)applyColors {
    ///Set Gradient
    [self setGradient];
    
    ///Set text color on labels, textfields, separators and other buttons
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblTitle.textColor = primaryBGTextColor;
    self.txtPincode1.backgroundColor = primaryBGTextColor;
    self.txtPincode2.backgroundColor = primaryBGTextColor;
    self.txtPincode3.backgroundColor = primaryBGTextColor;
    self.txtPincode4.backgroundColor = primaryBGTextColor;
    [self.btnResendCode setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    for (UIButton *btnKeyboardNumber in self.btnKeyboardNumbersCollection) {
        [btnKeyboardNumber setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    }
    self.imgVuEye.tintColor = primaryBGTextColor;
    self.imgVuClear.tintColor = primaryBGTextColor;
    for (UIView *vuNumberPadSeparator in self.vuNumberPadSeparatorCollection) {
        vuNumberPadSeparator.backgroundColor = primaryBGTextColor;
    }
    
    ///Set light theme color
    UIColor *lightThemeColor = [C411ColorHelper sharedInstance].lightThemeColor;
    self.lblSubtitle.textColor = lightThemeColor;
    self.lblCodeNotReceived.textColor = lightThemeColor;
    
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)sendVerificationCode
{
    NSString *strContactNumber = self.strContactNumber;

    if (![strContactNumber hasPrefix:@"+"]) {
     ///Add + if it's not there
        strContactNumber = [@"+" stringByAppendingString:strContactNumber];
    }
    
        if (self.verificationCode == 0) {
            
            ///Create a verification Code
            self.verificationCode = [C411StaticHelper getRandomVerificationCodeOfDigits:4];
            
        }
        
        NSString *strVerificationCodeMsg = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"Welcome to Cell 411. Your verification code is", nil),self.verificationCode];
        
        __weak typeof(self) weakSelf = self;
        [ServerUtility sendSms:strVerificationCodeMsg onNumber:strContactNumber withCompletion:^(NSError *error, id data) {
            
            if (!error) {
                
                ///show toast that verification code is sent
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Verification code sent", nil)];
            }
            else{
                
                ///show the error
                NSString *strMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"Unable to send verification code, is %@ your correct number?\nYour number should start with your country code followed by your contact number",nil),strContactNumber];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:strMsg preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *updateAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                    
                    ///User Tapped on Update action
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        ///Show alert to update number
                        [weakSelf showUpdateNumberPopup];
                        
                    });
                }];
                
                UIAlertAction *resendCodeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Resend Code", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                    
                    ///User Tapped on Resend code action
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf sendVerificationCode];
                    });
                    
                    
                    
                }];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    ///User Tapped on Cancel action
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                    
                }];
                
                [alertController addAction:updateAction];
                [alertController addAction:resendCodeAction];
                [alertController addAction:cancelAction];
                
                //[self presentViewController:alertController animated:YES completion:NULL];
                ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
                
            }
            
        }];

}

-(void)showUpdateNumberPopup
{
    
    C411AddPhoneVC *updatePhoneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411AddPhoneVC"];
    updatePhoneVC.strContactNumber = self.strContactNumber;
    updatePhoneVC.inEditMode = YES;
#if PHONE_VERIFICATION_ENABLED
    
    updatePhoneVC.comingFromPhoneVerificationVC = YES;
    updatePhoneVC.addOrUpdatePhoneDelegate = self;

#endif

    
    [self.navigationController pushViewController:updatePhoneVC animated:YES];
    
}



-(void)setPincodeWithString:(NSString *)strPincode
{
    ///Clear labels
    self.txtPincode1.text = @"";
    self.txtPincode2.text = @"";
    self.txtPincode3.text = @"";
    self.txtPincode4.text = @"";
    
    
    for (NSInteger index = 0; index < strPincode.length; index++) {
        NSRange charRange = NSMakeRange(index, 1);
        NSString *character = [strPincode substringWithRange:charRange];
        
        switch (index) {
            case 0:
                self.txtPincode1.text = character;
                break;
            case 1:
                self.txtPincode2.text = character;
                break;
            case 2:
                self.txtPincode3.text = character;
                break;
            case 3:
                self.txtPincode4.text = character;
                break;
                
            default:
                break;
        }
        
    }
}


//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnBackTapped:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.shouldShowNavBar) {
        
        ///Show the navigation bar again as it was initially visible
        self.navigationController.navigationBarHidden = NO;
        
    }

}


- (IBAction)btnKeyboardNumberTapped:(UIButton *)sender {
    
    ///Get the number tapped
    NSString *strNumberTapped = sender.titleLabel.text;
    
    ///Create string if nil
    if (!self.strEnteredCode) {
        self.strEnteredCode = [NSMutableString string];
    }
    
    ///Append Number if it can
    if (self.strEnteredCode.length < 4) {
        
        [self.strEnteredCode appendString:strNumberTapped];
        
        ///Reset the Pincode
        [self setPincodeWithString:self.strEnteredCode];
        
        if (self.strEnteredCode.length == 4) {
            
            ///Validate the code
            
            ///If verification code entered is correct, update on Parse
            int enteredCode = [self.strEnteredCode intValue];
            if (enteredCode == self.verificationCode) {
                
                ///Verification succeeded, update the current user
                PFUser *currentUser = [PFUser currentUser];///This should be fetched from parse only as it is created at the time of signup and before setting isLoggedIn flag
                currentUser[kUserPhoneVerifiedKey] = @(YES);
                currentUser[kUserMobileNumberKey] = self.strContactNumber;
                __weak typeof(self) weakSelf = self;
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if (error) {
                        
                        ///save it eventually if error occured
                        [currentUser saveEventually];
                        
                    }
                    
                    NSString *strMsg = nil;
                    switch (weakSelf.verificationJob) {
                        case PhoneVerificationJobPhoneVerified:
                            strMsg = NSLocalizedString(@"Phone verified successfully", nil);
                            ///Post the notification for contact updated
                            [[NSNotificationCenter defaultCenter]postNotificationName:kPhoneUpdatedNotification object:nil];
                            
                            break;
                        case PhoneVerificationJobPhoneAdded:
                            strMsg = NSLocalizedString(@"Phone added successfully", nil);
                            ///Post the notification for contact added
                            [[NSNotificationCenter defaultCenter]postNotificationName:kPhoneAddedNotification object:nil];
                            
                            break;
                        case PhoneVerificationJobPhoneUpdated:
                            strMsg = NSLocalizedString(@"Phone updated successfully", nil);
                            ///Post the notification for contact updated
                            [[NSNotificationCenter defaultCenter]postNotificationName:kPhoneUpdatedNotification object:nil];
                            break;
                            
                            
                        default:
                            break;
                    }
                    
                    if (strMsg.length > 0) {
                        
                        ///Show success toast on root view controller
                        [AppDelegate showToastOnView:nil withMessage:strMsg];
                    }
                    
                    ///remove hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    ///Call the success completion block
                    weakSelf.verificationCompletionHandler();
                    
                    
                }];
            }
            else{
                
                ///Show invalid code toast
                [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Invalid Code", nil)];
                
            }

            
            
        }
    }
    
    
}

- (IBAction)btnTogglePincodeVisibilityTapped:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        ///Make pincodes visible
        self.txtPincode1.secureTextEntry = NO;
        self.txtPincode2.secureTextEntry = NO;
        self.txtPincode3.secureTextEntry = NO;
        self.txtPincode4.secureTextEntry = NO;
        
        
    }
    else{
        
        ///Make pincodes Invisible
        self.txtPincode1.secureTextEntry = YES;
        self.txtPincode2.secureTextEntry = YES;
        self.txtPincode3.secureTextEntry = YES;
        self.txtPincode4.secureTextEntry = YES;
        
        
    }
    
}

- (IBAction)btnDeleteTapped:(UIButton *)sender {
    
    if (self.strEnteredCode.length > 0) {
        NSRange lastCharacterRange = NSMakeRange(self.strEnteredCode.length - 1, 1);
        [self.strEnteredCode deleteCharactersInRange:lastCharacterRange];
        
    }
    
    ///Reset the Pincode
    [self setPincodeWithString:self.strEnteredCode];
    
    
}


- (IBAction)btnResendCodeTapped:(UIButton *)sender {
    
    [self sendVerificationCode];

}


//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == TXT_TAG_ALERT_PHONE) {
        
        ///Submit button can only be available if there is number
        NSString *strPhoneNumber = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (strPhoneNumber.length > 0) {
            
            self.updateAction.enabled = YES;
        }
        else{
            
            self.updateAction.enabled = NO;
            
        }
        
        
    }
    
    return YES;
    
}

//****************************************************
#pragma mark - C411AddPhoneVCDelegate Methods
//****************************************************

-(void)addPhoneVC:(C411AddPhoneVC *)addPhoneVC didAddedOrUpdatedUniqueContactNumber:(NSString *)strContactNumber
{
    ///update the iVar with this new number
    self.strContactNumber = strContactNumber;
    
#if PHONE_VERIFICATION_ENABLED
    ///set the delegate to nil
    addPhoneVC.addOrUpdatePhoneDelegate = nil;
#endif

    
    ///Set the verification job type
    self.verificationJob = addPhoneVC.isInEditMode ? PhoneVerificationJobPhoneUpdated : PhoneVerificationJobPhoneAdded;
    
    ///Pop the add phone vc
    [self.navigationController popViewControllerAnimated:YES];
    
    ///send verification code again
    [self sendVerificationCode];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
