//
//  C411ActivateAccountVC.m
//  cell411
//
//  Created by Milan Agarwal on 29/10/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411ActivateAccountVC.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411ActivateAccountVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblAppName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnTryNow;
//- (IBAction)btnTryNowTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;

@end

@implementation C411ActivateAccountVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self setupViews];
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
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

-(void)setGradient
{
    UIColor *topColor = [C411ColorHelper sharedInstance].darkPrimaryColor;
    UIColor *bottomColor = [C411ColorHelper sharedInstance].loginGradientLightColor;
    NSArray *arrGradientColors = @[(id)topColor.CGColor,(id)bottomColor.CGColor];
    
    [C411StaticHelper setDiagonalGradientOnView:self.view withColors:arrGradientColors];
}

-(void)configureViews
{
    ///set corner radius of Try now button
    self.btnTryNow.layer.cornerRadius = 3.0;
    self.btnTryNow.layer.masksToBounds = YES;
    
    ///Set app Name
    self.lblAppName.text = LOCALIZED_APP_NAME;
}

-(void)setupViews {
    self.lblTitle.text = NSLocalizedString(@"Activate account", nil);
    self.lblDescription.text = NSLocalizedString(@"Thank you for your interest, we will inform you via the e-mail you have provided as soon as this app becomes public.",nil);
    [self.btnTryNow setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
}

-(void)applyColors {
    ///Set Gradient
    [self setGradient];
    
    ///Set theme colors on action button text
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    [self.btnTryNow setTitleColor:themeColor forState:UIControlStateNormal];
    
    ///Set text color on label
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblAppName.textColor = primaryBGTextColor;
    self.lblTitle.textColor = primaryBGTextColor;
    self.lblDescription.textColor = primaryBGTextColor;
    
}
-(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

//- (IBAction)btnTryNowTapped:(UIButton *)sender {
//    ///Check if current user is now active or not
//    PFUser *currentUser = [PFUser currentUser];
//    if(currentUser){
//        __weak typeof(self) weakSelf = self;
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [currentUser fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//            if(!error){
//                ///Check whether account is activated or not
//                BOOL isActive = [currentUser[kUserIsActiveKey]boolValue];
//                if(isActive) {
//                    ///User is logged in and account is activated
//                    if(weakSelf.activationCompletionHandler != NULL) {
//                        ///Call the completion Block
//                        weakSelf.activationCompletionHandler();
//                    }
//                }
//                else {
//                    ///Show alert to activate account first
//                    [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Your account is not yet activated by administrator.", nil) onViewController:nil];
//                }
//            }
//            else{
//                    NSString *errorString = [error userInfo][@"error"];
//                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
//            }
//        }];
//    }
//}

- (IBAction)btnCloseTapped:(UIButton *)sender {
    exit(0); ///Terminate the app
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
