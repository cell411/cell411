//
//  C411ResetPasswordVC.m
//  cell411
//
//  Created by Milan Agarwal on 18/02/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ResetPasswordVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411StaticHelper.h"
#import "Constants.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411ColorHelper.h"

@interface C411ResetPasswordVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuPasswordUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIView *vuConfirmPasswordUnderline;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vuBaseBLConstraints;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlVuBase;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UILabel *lblAppName;

- (IBAction)btnResetPasswordTapped:(UIButton *)sender;

///Property for scroll management
@property (nonatomic, assign)float kbHeight;
@property (nonatomic, assign) CGFloat scrlVuInitialBLConstarintValue;

@end

@implementation C411ResetPasswordVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setGradient];
    [self configureViews];
    ///set initial bottom constraint of scrollview
    self.scrlVuInitialBLConstarintValue = self.vuBaseBLConstraints.constant;
    [self registerForNotifications];
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
    ///Change Placeholder colors of textfields
    UIColor *placeholderColor = [C411ColorHelper sharedInstance].primaryBGPlaceholderTextColor;
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtPassword];
    
    [C411StaticHelper setPlaceholderColor:placeholderColor ofTextField:self.txtConfirmPassword];
    
    ///set corner radius of login button
    self.btnReset.layer.cornerRadius = 3.0;
    self.btnReset.layer.masksToBounds = YES;
    
    ///Set app Name
    self.lblAppName.text = LOCALIZED_APP_NAME;
    
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(BOOL)userCanResetPassword
{
    BOOL isValid = YES;
    ///Validate Password
    if ((!self.txtPassword.text) || (self.txtPassword.text.length == 0)) {
        
        NSString *localizedEmptyPwdMsg = NSLocalizedString(@"Please enter password", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyPwdMsg onViewController:self];
        
        isValid = NO;
    }
    else if ((!self.txtConfirmPassword.text) || (self.txtConfirmPassword.text.length == 0)) {
        
        NSString *localizedEmptyPwdMsg = NSLocalizedString(@"Please enter confirm password", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedEmptyPwdMsg onViewController:self];
        
        isValid = NO;
    }
    else if (![self.txtPassword.text isEqualToString:self.txtConfirmPassword.text]){
        
        NSString *localizedUnmatchedPwdMsg = NSLocalizedString(@"Confirm password didn't match.", nil);
        
        [C411StaticHelper showAlertWithTitle:nil message:localizedUnmatchedPwdMsg onViewController:self];
        
        isValid = NO;

    }
    
    return isValid;
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnResetPasswordTapped:(UIButton *)sender {
    
    if ([self userCanResetPassword]) {
        
        ///Make a call to reset user password
        
    }
}

//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtPassword) {
        
        [self.txtConfirmPassword becomeFirstResponder];
        return NO;
    }
    else{
        [textField resignFirstResponder];
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    float yOffset = textField.frame.origin.y - self.txtPassword.frame.origin.y;
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

@end
