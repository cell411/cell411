//
//  C411RequestVerificationVC.m
//  cell411
//
//  Created by Milan Agarwal on 09/02/16.
//  Copyright (c) 2016 Milan Agarwal. All rights reserved.
//

#import "C411RequestVerificationVC.h"
#import "C411StaticHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Constants.h"
#import "ConfigConstants.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

@interface C411RequestVerificationVC ()
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnRequestVerification;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblInfoWithAppName;
- (IBAction)btnRequestVerificationTapped:(UIButton *)sender;
- (IBAction)btnDoneTapped:(UIButton *)sender;

@end

@implementation C411RequestVerificationVC


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

-(void)setupViews
{
    
    CellVerificationStatus verificationStatus = [self.myPublicCellObj[kPublicCellVerificationStatusKey]integerValue];
    NSString *greyColor = @"888888";
    NSString *greenColor = @"008000";
    ///Disable verification request object initially
    self.btnRequestVerification.enabled = NO;
    ///Set theme colors on request verification button as default
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnRequestVerification.backgroundColor = themeColor;
    
    switch (verificationStatus) {
        case CellVerificationStatusRejected:
            [self.btnRequestVerification setTitle:NSLocalizedString(@"Not Verified", nil) forState:UIControlStateNormal];
            self.btnRequestVerification.backgroundColor = [UIColor redColor];
            break;
            
        case CellVerificationStatusPending:
            [self.btnRequestVerification setTitle:NSLocalizedString(@"Verification Pending", nil) forState:UIControlStateNormal];
            self.btnRequestVerification.backgroundColor = [C411StaticHelper colorFromHexString:greyColor];
            break;
         
        case CellVerificationStatusUnsolicited:
            ///Verification request has not been sent till now, enable the button
            self.btnRequestVerification.enabled = YES;
            break;
            
        case CellVerificationStatusApproved:
            [self.btnRequestVerification setTitle:NSLocalizedString(@"Officially Verified", nil) forState:UIControlStateNormal];
            self.btnRequestVerification.backgroundColor = [C411StaticHelper colorFromHexString:greenColor];
            break;
            
        default:
            break;
    }
    
/*OLD implementation of verification request handling
    if (self.verificationReqObj) {
        
        ///Verification request has already been sent
        self.btnRequestVerification.enabled = NO;
        NSString *requestStatus = self.verificationReqObj[kVerificationRequestStatusKey];
        if ([requestStatus.lowercaseString isEqualToString:kRequestStatusApproved.lowercaseString]) {
            
            [self.btnRequestVerification setTitle:NSLocalizedString(@"Officially Verified", nil) forState:UIControlStateNormal];
            self.btnRequestVerification.backgroundColor = [UIColor greenColor];
            
        }
        else if ([requestStatus.lowercaseString isEqualToString:kRequestStatusRejected.lowercaseString]) {
            
            [self.btnRequestVerification setTitle:NSLocalizedString(@"Not Verified", nil) forState:UIControlStateNormal];
            self.btnRequestVerification.backgroundColor = [UIColor redColor];

        }
        else if ([requestStatus.lowercaseString isEqualToString:kRequestStatusPending.lowercaseString]) {
            NSString *greyColor = @"888888";
            [self.btnRequestVerification setTitle:NSLocalizedString(@"Verification Pending", nil) forState:UIControlStateNormal];
            self.btnRequestVerification.backgroundColor = [C411StaticHelper colorFromHexString:greyColor];

        }
    }
    else{
        
        ///Verification request has not been sent till now
        
    }
 */
    
}

-(void)configureViews
{
    self.title = NSLocalizedString(@"Request Verification", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    ///Set dynamic app name
    self.lblInfoWithAppName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Public Cells can be officially verified by %@ to confirm the identity of the owner and the legitimacy of the Cell. In order to be verified, please use a specific name for your Cell. For example, a Cell named \"New York City\" is misleading as it is not owned by the City of New York, however a Cell named \"New York City 55th St. Crime Watch\" is more specific and likely to be verified.",nil),LOCALIZED_APP_NAME];
    
    
    [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnDone.backgroundColor = themeColor;
    
    ///Set primary text color
    self.lblTitle.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    
    ///Set Secondary text color
    self.lblInfoWithAppName.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnRequestVerificationTapped:(UIButton *)sender {
    
    ///Call cloud function to send verification request
    __weak typeof(self) weakSelf = self;
   
    ///show hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
#if (!DEBUG && (APP_CELL411 || APP_IER))
   
    ///Maintaining backward compatibilty with old versions for Cell 411 and iER Prod
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kSendVerificationReqFuncParamCellIdKey] = self.myPublicCellObj.objectId;
    [C411StaticHelper sendVerificationRequestWithDetails:dictParams andCompletion:^(id  __nullable object, NSError * __nullable error) {
        
        ///Hide the hud
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        
        if (!error) {
            
            ///update the button appearance and title
            weakSelf.btnRequestVerification.enabled = NO;
            
            NSString *greyColor = @"888888";
            [weakSelf.btnRequestVerification setTitle:NSLocalizedString(@"Verification Pending", nil) forState:UIControlStateNormal];
            weakSelf.btnRequestVerification.backgroundColor = [C411StaticHelper colorFromHexString:greyColor];
            
            ///Set verificationStatus as Pending
            weakSelf.myPublicCellObj[kPublicCellVerificationStatusKey] = @(CellVerificationStatusPending);

            
        }
        else{
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
        }
        
        
    }];

#else

    
    self.myPublicCellObj[kPublicCellVerificationStatusKey] = @(CellVerificationStatusPending);
    [self.myPublicCellObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (error) {
            
            ///save it eventually if error occured
            [weakSelf.myPublicCellObj saveEventually];
            
        }
        
        ///update the button appearance and title
        weakSelf.btnRequestVerification.enabled = NO;
        
        NSString *greyColor = @"888888";
        [weakSelf.btnRequestVerification setTitle:NSLocalizedString(@"Verification Pending", nil) forState:UIControlStateNormal];
        weakSelf.btnRequestVerification.backgroundColor = [C411StaticHelper colorFromHexString:greyColor];
        
        ///Hide the hud
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        
        
    }];
    
#endif

/*OLD implementation of verification request handling
    ///Create a verification request object and save it on Parse
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
    NSString *strCellName = self.myPublicCellObj[kPublicCellNameKey];
    PFObject *verificationReqObj = [PFObject objectWithClassName:kVerificationRequestClassNameKey];
    verificationReqObj[kVerificationRequestRequestedByKey] = currentUser;
    verificationReqObj[kVerificationRequestNameKey] = strUserFullName;
    verificationReqObj[kVerificationRequestCellKey] = self.myPublicCellObj;
    
    verificationReqObj[kVerificationRequestCellNameKey] = strCellName;
    verificationReqObj[kVerificationRequestStatusKey] = kRequestStatusPending;
   
    ///Save it in background
    __weak typeof(self) weakSelf = self;
    
    ///show hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [verificationReqObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (succeeded) {
            
            ///Object saved successfully, call a cloud function to sendVerificationRequest
            NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
            NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
            strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictParams[kSendVerificationReqFuncParamEmailKey] = strEmail.lowercaseString;
            dictParams[kSendVerificationReqFuncParamNameKey] = strUserFullName;
            dictParams[kSendVerificationReqFuncParamCellNameKey] = strCellName;
            dictParams[kSendVerificationReqFuncParamRequestIdKey] = verificationReqObj.objectId;
            [C411StaticHelper sendVerificationRequestWithDetails:dictParams andCompletion:^(id  __nullable object, NSError * __nullable error) {
                ///Hide the hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                
                if (!error) {
                    
                    ///update the button appearance and title
                    weakSelf.btnRequestVerification.enabled = NO;
                    
                    NSString *greyColor = @"888888";
                    [weakSelf.btnRequestVerification setTitle:NSLocalizedString(@"Verification Pending", nil) forState:UIControlStateNormal];
                    weakSelf.btnRequestVerification.backgroundColor = [C411StaticHelper colorFromHexString:greyColor];
                    
                    
                }
                else{
                    ///Log the error and do not remove the activity indicator so that user do not send the request again
                     NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#Problem calling sendVerificationRequest Cloud Code%@",errorString);
                    
                }
            
                
            }];
            
            ///notify observer that verification request is sent
            [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellVerificationRequestSentNotification object:verificationReqObj];
            
        }
        else{
            
            if (error) {
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                }
            }
            
            ///remove hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }
        
        
    }];
*/
    
}

- (IBAction)btnDoneTapped:(UIButton *)sender {

    [self dismissViewControllerAnimated:YES completion:NULL];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
