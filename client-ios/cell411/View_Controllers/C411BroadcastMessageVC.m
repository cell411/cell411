//
//  C411BroadcastMessageVC.m
//  cell411
//
//  Created by Milan Agarwal on 28/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411BroadcastMessageVC.h"
#import "C411StaticHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"

@interface C411BroadcastMessageVC ()

@property (weak, nonatomic) IBOutlet UITextView *txtVuMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnBroadcast;
@property (strong, nonatomic) IBOutlet UIToolbar *tlbrDone;
- (IBAction)btnBroadcastTapped:(UIButton *)sender;
- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender;
@end

@implementation C411BroadcastMessageVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    
    self.txtVuMessage.inputAccessoryView = self.tlbrDone;
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
#pragma mark - Private Methods
//****************************************************


-(void)configureViews
{
    self.title = NSLocalizedString(@"Broadcast Message", nil);
    if (@available(iOS 11, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        ///Above line is commented to disable large title temporarily to fix an issue(Navigation bar background color gets cleared for large titles) until we switch to Xcode 11 having base SDK as iOS 13 for compilation that provides the new UINavigationBarAppearance Class using which we can set same appearance for all scrollEdgeAppearance, standardAppearance and compactAppearance to resolve the issue as provided here: https://stackoverflow.com/a/56696967/3412051
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    ///set corner radius to each container views
    self.txtVuMessage.layer.cornerRadius = 4.0;
    self.txtVuMessage.layer.masksToBounds = YES;
    self.txtVuMessage.layer.borderWidth = 1.0f;
    
    ///Configure blocked users and spammers button
    self.btnBroadcast.layer.cornerRadius = 4.0f;
    self.btnBroadcast.layer.masksToBounds = YES;
    
    [self applyColors];
}

-(void)applyColors {
    UIColor *backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.view.backgroundColor = backgroundColor;
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnBroadcast.backgroundColor = themeColor;
    
    ///Set primaryBGText Color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnBroadcast setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    ///Set primary Text Color
    self.txtVuMessage.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    
    ///Set separator color
    self.txtVuMessage.layer.borderColor = [C411ColorHelper sharedInstance].separatorColor.CGColor;
    
    ///Set keyboard appearance
    self.txtVuMessage.keyboardAppearance = [C411ColorHelper sharedInstance].keyboardAppearance;
    
    self.tlbrDone.barTintColor = backgroundColor;
    self.tlbrDone.tintColor = themeColor;
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

- (IBAction)btnBroadcastTapped:(UIButton *)sender {
    
    if (self.txtVuMessage.text.length > 0) {
       
        NSString *strMessage = self.txtVuMessage.text;
        NSMutableDictionary *dictMessage = [NSMutableDictionary dictionary];
        dictMessage[kBroadcastMessageFuncParamMessageKey] = strMessage;
        __weak typeof(self) weakSelf = self;
        [self.txtVuMessage resignFirstResponder];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [C411StaticHelper broadcastMessage:dictMessage andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            if (!error) {
                
                weakSelf.txtVuMessage.text = nil;
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Messsage Broadcasted", nil)];
            }
            else{
                
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Error Occurred", nil)];
 
            }
            
        }];
       
        
        
    }
    else{
        
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Enter Message", nil)];

    }
    
}

- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender {
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)barBtnDoneTapped:(UIBarButtonItem *)sender {
    
    [self.txtVuMessage resignFirstResponder];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
