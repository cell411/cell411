//
//  C411LoginVC.m
//  cell411
//
//  Created by Milan Agarwal on 19/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411LoginVC.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411SignUpVC.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@interface C411LoginVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgVuEmailIcon;
@property (weak, nonatomic) IBOutlet UIView *vuEmailUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuPasswordIcon;
@property (weak, nonatomic) IBOutlet UIView *vuPasswordUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vuBaseBLConstraints;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UILabel *lblOr;
@property (weak, nonatomic) IBOutlet UIView *vuOr;
@property (weak, nonatomic) IBOutlet UIView *vuOrBase;
@property (weak, nonatomic) IBOutlet UIView *vuOrLeftSeparator;
@property (weak, nonatomic) IBOutlet UIView *vuOrRightSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginWithFacebook;
@property (weak, nonatomic) IBOutlet UILabel *lblAppName;
@property (weak, nonatomic) IBOutlet UILabel *lblDontHaveAccount;
@property (weak, nonatomic) IBOutlet UIButton *btnShowSignupScreen;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVuOrBaseTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsVuOrWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsLoginWithFBBtnTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsLoginWithFBBtnHeight;

- (IBAction)btnBackTapped:(UIBarButtonItem *)sender;
- (IBAction)btnLoginTapped:(UIButton *)sender;
- (IBAction)btnForgotPasswordTapped:(UIButton *)sender;
- (IBAction)btnShowSignUpScreenTapped:(UIButton *)sender;
- (IBAction)btnLoginWithFacebookTapped:(UIButton *)sender;

///Property for scroll management
@property (nonatomic, assign)float kbHeight;
@property (nonatomic, assign) CGFloat scrlVuInitialBLConstarintValue;

@end

@implementation C411LoginVC


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
    ///Hide Login with FB button if it's disabled
#if (!FB_ENABLED)
    
    self.cnsVuOrBaseTS.constant = 0;
    self.cnsVuOrWidth.constant = 0;
    self.cnsLoginWithFBBtnTS.constant = 0;
    self.cnsLoginWithFBBtnHeight.constant = 0;
    self.vuOrBase.hidden = YES;
    self.btnLoginWithFacebook.hidden = YES;
    
#endif
    
    ///set corner radius of login button
    self.btnLogin.layer.cornerRadius = 3.0;
    self.btnLogin.layer.masksToBounds = YES;
    
    ///make or view rounder
    [C411StaticHelper makeCircularView:self.vuOr];
    
    ///Set app Name
    self.lblAppName.text = LOCALIZED_APP_NAME;
    
    [self applyColors];
}

-(void)applyColors {
    ///Set Gradient
    [self setGradient];
    
    ///Set theme colors on action button text
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    [self.btnLogin setTitleColor:themeColor forState:UIControlStateNormal];
    
    ///Change Placeholder colors of textfields
    UIColor *placeholderColor = [C411ColorHelper sharedInstance].primaryBGPlaceholderTextColor;
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtEmail];
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtPassword];
    
    ///Set text color on labels, textfields, separators and other buttons
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.txtEmail.textColor = primaryBGTextColor;
    self.txtPassword.textColor = primaryBGTextColor;
    
    self.lblAppName.textColor = primaryBGTextColor;
    self.lblOr.textColor = primaryBGTextColor;
    self.lblDontHaveAccount.textColor = primaryBGTextColor;
    
    [self.btnForgotPassword setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnLoginWithFacebook setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnShowSignupScreen setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    self.vuEmailUnderline.backgroundColor = primaryBGTextColor;
    self.vuPasswordUnderline.backgroundColor = primaryBGTextColor;
    self.vuOrLeftSeparator.backgroundColor = primaryBGTextColor;
    self.vuOrRightSeparator.backgroundColor = primaryBGTextColor;
    
    ///Set tint color on text fields icons
    self.imgVuEmailIcon.tintColor = primaryBGTextColor;
    self.imgVuPasswordIcon.tintColor = themeColor;
    
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


-(BOOL)userCanLogin
{
    BOOL isValid = YES;
    ///Validate Email
    NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ((!strTrimmedEmail) || (strTrimmedEmail.length == 0)) {
        NSString *localizedEmptyEmailMsg = NSLocalizedString(@"Please enter email", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyEmailMsg onViewController:self];
        
        isValid = NO;
    }
    ///Validate Password
    else if ((!self.txtPassword.text) || (self.txtPassword.text.length == 0)) {
        
        NSString *localizedEmptyPwdMsg = NSLocalizedString(@"Please enter password", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyPwdMsg onViewController:self];
        
        isValid = NO;
    }
    
    return isValid;
}

-(void)performLogin
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self) weakSelf = self;
    NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [PFUser logInWithUsernameInBackground:strTrimmedEmail.lowercaseString password:self.txtPassword.text
                                    block:^(PFUser *user, NSError *error) {
                                    
                                        ///handle the login completion
                                        
                                        if (user) {
                                            
                                            [C411StaticHelper handleLoginCompletionWithUser:user fromViewController:weakSelf andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
                                                
                                                ///hide the hud
                                                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                                
                                            }];

                                        }else {
                                            ///Hide loading activity
                                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                            
                                            // The login failed. Check error to see why.
                                            if (error) {
                                                if(![AppDelegate handleParseError:error]){
                                                        NSString *errorString = [error userInfo][@"error"];
                                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                                }
                                            }
                                            
                                        }

                                        
                                    }];
                                   
    
}

/*
-(void)performLoginWithFacebook
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[FBSDKAccessToken setCurrentAccessToken:nil];
    //[[PFFacebookUtils facebookLoginManager]logOut];///logging out before logging in to handle different user login else it will give facebook login error "Domain=com.facebook.sdk.login Code=304 "(null)"
    __weak typeof(self) weakSelf = self;

    ///1. Login with facebook with read permission
        [PFFacebookUtils logInInBackgroundWithReadPermissions:@[kReadPermissionEmail,kReadPermissionPublicProfile] block:^(PFUser *user, NSError *error) {
            
            if (!user) {
                ///user cancelled login or error occured
                if (error) {
                    
                    ///show the error message
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                    
                }
                
                ///hide the hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
            }
            else if (user.isNew) {
                
                ///2.A new user is created using Facebook signup and logged in, get the basic info of the user and update it on parse
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"email,first_name,last_name"}]
                                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                        
                                          ///get the email
                                          NSString *strEmail = result[@"email"];
                                          NSString *strTrimmedEmail = [strEmail  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                          if (strTrimmedEmail.length > 0) {
                                              ///set the email if available
                                              user.email = strTrimmedEmail.lowercaseString;
                                          }
                                          
                                          ///get first and last name
                                          NSString *strFirstName = result[@"first_name"];
                                          if (strFirstName.length > 0) {
                                              
                                              user[kUserFirstnameKey] = strFirstName;
                                          }
                                          
                                          NSString *strLastName = result[@"last_name"];
                                          if (strLastName.length > 0) {
                                              
                                              user[kUserLastnameKey] = strLastName;
                                          }

                                          ///update user object
                                          [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                              
                                              if (!error) {
                                                  
                                                  ///User details updated
                                                  NSLog(@"user details updated");
                                                  
                                              } else {
                                                  
                                                  ///save it eventually
                                                  [user saveEventually];
                                                  
                                                  // Show the errorString somewhere and let the user try again.
                                                  NSString *errorString = [error userInfo][@"error"];
                                                  [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                                  
                                                  
                                              }
                                              
                                              ///hide the hud
                                              [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

                                              
                                              ///perform post signup steps even if error occured as it will be saved eventually
                                              ///Show main interface
                                              [[AppDelegate sharedInstance]userDidCreatedAccountWithSignUpType:SignUpTypeFacebook];
                                              
                                                                                        }];
                                          
                                      }
                                      else{
                                          
                                          ///Show the error
                                          [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                                          
                                          ///hide the hud
                                          [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

                                      }
                                  }];

                
            }
            else{
                
                ///Existing user logged in again through Facebook!
                [weakSelf handleLoginCompletionWithUser:user andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
                    
                    ///hide the progress hud
                   [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                }];

            }
        }];

}



-(void)handleLoginCompletionWithUser:(PFUser *)user andCompletion:(PFStringResultBlock)completion
{
    __weak typeof(self) weakSelf = self;
        ///Verify the user privileges and proceed with post login operations if applicable
        [C411StaticHelper getPrivilegeForUser:user shouldSetPrivilegeIfUndefined:YES andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
            if (completion!= NULL) {
                ///call compeltion to remove progress hud and other cleanup if required
                completion(string,error);
                
            }
            NSString *strPrivilege = string;
            if ((!strPrivilege)
                ||(strPrivilege.length == 0)) {
                
                ///some error occured fetching privilege
                NSLog(@"#error fetching privilege : %@",error.localizedDescription);
                
                [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, please try again.", nil) onViewController:weakSelf];
                
            }
            else if ([strPrivilege isEqualToString:kPrivilegeTypeBanned]){
                
                ///This user account is banned, log him out of the app
                [PFUser logOutInBackground];
                
                ///show message
                [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Your account has been blocked for violating the Cell 411 Terms of Service.", nil) onViewController:weakSelf];
                
            }
            else if ([strPrivilege hasPrefix:kPrivilegeTypeSuspended]){
                
                ///This user account is suspended, log him out of the app
                [PFUser logOutInBackground];
                
                ///show message
                [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Your account has been temporarily suspended for violating the Cell 411 Terms of Service.", nil) onViewController:weakSelf];
                
            }
            else{
                
                ///privilege is either FIRST, SECOND or SHADOW_BANNED. User with privilege FIRST or SHADOW_BANNED cannot send Global Alerts but can use the app
                
                // Do stuff after successful login.
                [[AppDelegate sharedInstance]userDidLogin];
                
                
            }
        }];
        
}
*/


//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnBackTapped:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)btnLoginTapped:(UIButton *)sender {
    
    if ([self userCanLogin]) {
        
        [self performLogin];
    }
}

- (IBAction)btnForgotPasswordTapped:(UIButton *)sender {
    
    NSString *strTrimmedEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (strTrimmedEmail.length > 0) {
        __weak typeof(self) weakSelf = self;

        [PFUser requestPasswordResetForEmailInBackground:strTrimmedEmail block:^(BOOL succeeded, NSError * error){
            if (succeeded) {
                
                NSString *msgString = NSLocalizedString(@"An email has been sent with reset password instructions, please check your email", nil);
                [C411StaticHelper showAlertWithTitle:nil message:msgString onViewController:weakSelf];
                
            }
            else if (error) {
                if(![AppDelegate handleParseError:error]){
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                }
            }
            
            
        }];
 /*
        
        ///Call a cloud function to forgotPassword
        NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
        dictParams[kForgotPasswordReqFuncParamEmailKey] = strTrimmedEmail;
        dictParams[kForgotPasswordReqFuncParamDeviceTypeKey] = kForgotPasswordReqFuncDeviceTypeValIOS;
        
        ///Show the hud
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [C411StaticHelper sendForgotPasswordRequestWithDetails:dictParams andCompletion:^(id  __nullable object, NSError * __nullable error) {
            
            if (!error) {
                
                [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Please check your email for password reset instructions.", nil) onViewController:weakSelf];
                
            }
            else{
                ///Log the error and do not remove the activity indicator so that user do not send the request again
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#Problem calling sendVerificationRequest Cloud Code%@",errorString);
                
            }
  
            ///Hide the hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

            
        }];
*/
        
    }
    else{
        
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Please enter your email", nil) onViewController:self];
        
    }
 
    
}

- (IBAction)btnShowSignUpScreenTapped:(UIButton *)sender {
    
    ///Push Sign Up VC only if Login VC is not pushed from Sign Up VC, otherwise just pop out the Login VC to display Sign Up VC
    
    NSArray *arrVCStack = [self.navigationController viewControllers];
    
    UIViewController *prevVCInNavStack = [arrVCStack objectAtIndex:arrVCStack.count - 2];
    if ([prevVCInNavStack isKindOfClass:[C411SignUpVC class]]) {
        
        ///Login VC is Pushed from Sign Up VC on Tap of "Sign In" button in the bottom. So instead of Pushing new Sign Up VC, just Pop Login VC out
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        
        ///Login VC is Pushed from some other screen, i.e Welcome Gallery Screen. Push Sign Up VC
        C411SignUpVC *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411SignUpVC"];
        [self.navigationController pushViewController:signUpVC animated:YES];
    }
    
}

- (IBAction)btnLoginWithFacebookTapped:(UIButton *)sender {
   
#if FB_ENABLED
    
    [C411StaticHelper performLoginOrSignupWithFacebookFromViewController:self];

#endif
    
/*
    FBSDKLoginManager *fbLogin = [[FBSDKLoginManager alloc] init];
    [fbLogin
     logInWithReadPermissions: @[@"public_profile",@"email",@"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in -> results = %@",result);
//             NSString *strToken = [FBSDKAccessToken currentAccessToken].tokenString;
//             NSString *strAppId = [FBSDKAccessToken currentAccessToken].appID;
//             NSString *strExpirationDate = [FBSDKAccessToken currentAccessToken].expirationDate.description;
//             NSMutableDictionary *dictFBSessionToken = [NSMutableDictionary dictionary];
//             [dictFBSessionToken setObject:strAppId forKey:@"id"];
//             [dictFBSessionToken setObject:strToken forKey:@"access_token"];
//             [dictFBSessionToken setObject:strExpirationDate forKey:@"expiration_date"];
//             NSMutableDictionary *dictSessionToken = [NSMutableDictionary dictionary];
//             [dictSessionToken setObject:dictFBSessionToken forKey:@"facebook"];
//             
//             NSMutableDictionary *dictOauth = [NSMutableDictionary dictionary];
//             [dictOauth setObject:dictSessionToken forKey:@"oauth"];
//             
//             
//             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictOauth options:NSJSONWritingPrettyPrinted error:nil];
//             NSString *sessionToken = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
             
             
             if ([FBSDKAccessToken currentAccessToken]) {
                 
                 [PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser *user, NSError *error) {
                     
                     
                     if (!user) {
                         NSLog(@"Uh oh. There was an error logging in.");
                     } else {
                         NSLog(@"User logged in through Facebook!");
                     }

                     
                 }];
//                 [PFUser becomeInBackground:sessionToken block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//                     
//                     if (!error) {
//                         
//                         ///Login Successful
//                         NSLog(@"User login successful id -> %@",user.objectId);
//                         
//                     }
//                     else{
//                         
//                         NSString *errorString = [error userInfo][@"error"];
//                         [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
//                     }
//                     
//                 }];
             
//                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"name,email"}]
//                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                      if (!error) {
//                          NSLog(@"fetched user:%@", result);
//                      }
//                  }];
             }
             
         }
     }];
*/
    
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
