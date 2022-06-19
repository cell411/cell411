//
//  C411SplitVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411SplitVC.h"
#import "C411LeftMenuVC.h"
#import "C411BaseVC.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "C411MyProfileVC.h"
#import "C411SettingsVC.h"
#import "C411KnowYourRightsVC.h"
#import "AppDelegate.h"
#import "C411BarcodeScannerVC.h"
#import "C411QRCodeGeneratorVC.h"
#import "C411AppDefaults.h"
#import "MAAlertPresenter.h"
#import "C411BroadcastMessageVC.h"
#import "C411NotificationVC.h"
#import "C411BrowserVC.h"
#import "C411ColorHelper.h"
#import "Constants.h"

#define CORNER_RADIUS   0
#define SLIDE_TIMING    .35
//#define PANEL_WIDTH     70
#define OVERLAY_MAX_ALPHA   .2

#define TAG_HIDE_LEFT_MENU  1001
#define TAG_SHOW_LEFT_MENU  1002

@interface C411SplitVC ()<UIGestureRecognizerDelegate,C411BaseVCDelegate,C411LeftMenuVCActionDelegate,C411BarcodeScannerVCDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuOverlay;
@property (nonatomic, strong) C411LeftMenuVC * leftMenuVC;
@property (nonatomic, strong) UITabBarController *tabBarController;


@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, assign) CGPoint preVelocity;
@property (nonatomic, assign) float menuVisibleWidth;

//@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
//@property (nonatomic, strong) UIButton *btnTapToHidePanel;

//this is used if one operation is perform then other not work
//@property (assign, nonatomic) BOOL transitionInProgress;


@end

@implementation C411SplitVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    [self registerForNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
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

-(UIStatusBarStyle)preferredStatusBarStyle {
    return [C411ColorHelper sharedInstance].statusBarStyle;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

- (void)setupView
{
    // setup Tabbar view
    if (!self.tabBarController) {
        self.tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"C411MainTabVC"];
        
#if !CHAT_ENABLED
        
        ///Remove the chat tab
        NSMutableArray *arrTabItems = [NSMutableArray arrayWithArray:[self.tabBarController viewControllers]];
        [arrTabItems removeLastObject];
        self.tabBarController.viewControllers = arrTabItems;
        
#endif
        
       for (UINavigationController *navController in [self.tabBarController viewControllers]) {
            ///Do other setups
            C411BaseVC *rootVC = (C411BaseVC *)[navController.viewControllers firstObject];
            rootVC.revealDelegate = self;
            rootVC.barBtnRevealSideMenu.tag = TAG_SHOW_LEFT_MENU;
            
        }
        
        UINavigationController *selectedNavController = (UINavigationController *)self.tabBarController.viewControllers.firstObject;
        C411BaseVC *selectedVC = (C411BaseVC *)[selectedNavController.viewControllers firstObject];
        
        //[selectedVC willMoveToParentViewController:self];
        [self addChildViewController:self.tabBarController];
        [self.view insertSubview:self.tabBarController.view belowSubview:self.vuOverlay];

        [selectedVC didMoveToParentViewController:self];
        
    }
    [self applyColors];
}

-(void)applyColors {
    
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    
    ///Set navigation bar appearance
    [[UINavigationBar appearance]setTitleTextAttributes:@{
                                                          NSForegroundColorAttributeName :primaryBGTextColor,
                                                          NSFontAttributeName : [UIFont boldSystemFontOfSize:21.0f]
                                                          }];
    if (@available(iOS 11, *)) {
        [[UINavigationBar appearance]setLargeTitleTextAttributes:@{NSForegroundColorAttributeName :primaryBGTextColor}];
    }

    UIColor *primaryColor = [C411ColorHelper sharedInstance].primaryColor;
    self.tabBarController.tabBar.barTintColor = primaryColor;
    self.navigationController.navigationBar.barTintColor = primaryColor;
    [UINavigationBar appearance].barStyle = [C411ColorHelper sharedInstance].barStyle;
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName :[C411ColorHelper sharedInstance].tabItemNormalColor,NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0]} forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName :[C411ColorHelper sharedInstance].tabItemSelectedColor,NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0]} forState:UIControlStateSelected];
    
    for (UINavigationController *navController in [self.tabBarController viewControllers]) {
        ///Set the bar tint color of each navigation bars
        navController.navigationBar.barTintColor = primaryColor;
    }
    
    ///Set keyboard appearance
    [UITextField appearance].keyboardAppearance = [C411ColorHelper sharedInstance].keyboardAppearance;
    //[UITextView appearance].keyboardAppearance = [C411ColorHelper sharedInstance].keyboardAppearance;
}

-(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}


- (UIView *)getLeftView
{
    // init view if it doesn't already exist
    if (self.leftMenuVC == nil)
    {
        // this is where you define the view for the left panel
        self.leftMenuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411LeftMenuVC"];
        self.leftMenuVC.leftMenuActionDelegate = self;
        
        //[self.leftMenuVC willMoveToParentViewController:self];
        [self addChildViewController:self.leftMenuVC];
        [self.view addSubview:self.leftMenuVC.view];
        
        [self.leftMenuVC didMoveToParentViewController:self];
        
        float menuWidth = self.view.frame.size.width;
        self.menuVisibleWidth = self.leftMenuVC.vuLeftMenuContainer.bounds.size.width;

        self.leftMenuVC.view.frame = CGRectMake(-menuWidth, 0, menuWidth, self.view.frame.size.height);
        [self setupGesturesOnLeftMenu];
    }
    
    self.showingLeftPanel = YES;
    
    // set up view shadows
    [self showLeftMenuViewWithShadow:YES withOffset:-2];
    
    UIView *view = self.leftMenuVC.view;
    return view;
}

- (void)setupGesturesOnLeftMenu
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movePanel:)];
    panRecognizer.delegate = self;
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.leftMenuVC.view addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideLeftMenuPanel:)];
    tapRecognizer.delegate = self;
    [self.leftMenuVC.view addGestureRecognizer:tapRecognizer];

}

- (void)showLeftMenuViewWithShadow:(BOOL)value withOffset:(double)offset
{
    
    if (value)
    {
        [self.leftMenuVC.view.layer setCornerRadius:CORNER_RADIUS];
        [self.leftMenuVC.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.leftMenuVC.view.layer setShadowOpacity:0.8];
        [self.leftMenuVC.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
    }
    else
    {
        [self.leftMenuVC.view.layer setCornerRadius:0.0f];
        [self.leftMenuVC.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

- (void)resetMainView
{
    // remove left view and reset variables, if needed
    if (self.leftMenuVC != nil)
    {
        
        [self.leftMenuVC.view removeFromSuperview];
        self.leftMenuVC = nil;
        
        UINavigationController *selectedNavController = (UINavigationController *)self.tabBarController.selectedViewController;
        C411BaseVC *selectedVC = (C411BaseVC *)[selectedNavController.viewControllers firstObject];
        
        selectedVC.barBtnRevealSideMenu.tag = TAG_SHOW_LEFT_MENU;
        // [self.tabBarController.view removeGestureRecognizer:_tapRecognizer];
        
        self.showingLeftPanel = NO;
        
    }
    
    // remove view shadows
    //    [self showCenterViewWithShadow:NO withOffset:0];
    
    ///Send Snapshot ImageView to back
    //[self.view sendSubviewToBack:self.imgViewSnapshot];
    
}

//****************************************************
#pragma mark - Tap Gesture Method
//****************************************************


-(void)hideLeftMenuPanel:(id)sender
{
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    if (_showingLeftPanel) {
        
        [self movePanelToOriginalPosition];
        
    }
}

//****************************************************
#pragma mark - Pan Gesture Method
//****************************************************


-(void)movePanel:(id)sender
{
    
    //[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        
    }
    else if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        float minFlickVelocity = 500.0f;
        if(abs(velocity.x) > minFlickVelocity){
            if(velocity.x > 0) {
                // NSLog(@"gesture went right");
                [self movePanelToRight];
                
            } else {
                // NSLog(@"gesture went left");
                [self movePanelToOriginalPosition];
                
            }
        }
        else{
            if (!_showPanel) {
                [self movePanelToOriginalPosition];
            } else {
                if (_showingLeftPanel) {
                    [self movePanelToRight];
                }
            }
            
        }
    }
    else if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
            CGPoint touchLocation = [(UIPanGestureRecognizer *)sender locationInView:self.view];
            if(touchLocation.x > self.menuVisibleWidth){
                [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
                return;
            }
        }
        
        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
        
        _showPanel = abs([sender view].frame.origin.x + self.menuVisibleWidth) > self.view.frame.size.width/2;
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        CGRect panelFrame = [sender view].frame;
        float translatedX = panelFrame.origin.x + translatedPoint.x;
        panelFrame.origin.x = translatedX < 0 ? translatedX : 0;
        [sender view].frame = panelFrame;
        ///Update background colour
        float visiblePercent = (self.menuVisibleWidth - abs(panelFrame.origin.x))/self.menuVisibleWidth;
        self.vuOverlay.alpha = OVERLAY_MAX_ALPHA * visiblePercent;
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
    }
    
}

//****************************************************
#pragma mark - UIGestureRecognizerDelegate Methods
//****************************************************
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]])
    {
        return (touch.view == self.leftMenuVC.view) ;
    }
    return YES;
}

//****************************************************
#pragma mark - C411BaseVCDelegate Methods
//****************************************************


- (void)movePanelToRight // to show left panel
{
    
    UIView *childView = [self getLeftView];
    //  [self.view sendSubviewToBack:childView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{

                         childView.frame = CGRectMake(0, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
                         weakSelf.vuOverlay.hidden = NO;
                         weakSelf.vuOverlay.alpha = OVERLAY_MAX_ALPHA;

                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             UINavigationController *selectedNavController = (UINavigationController *)weakSelf.tabBarController.selectedViewController;
                             C411BaseVC *selectedVC = (C411BaseVC *)[selectedNavController.viewControllers firstObject];
                             
                             selectedVC.barBtnRevealSideMenu.tag = TAG_HIDE_LEFT_MENU;
                             
                             ///setup tap gesture on tab bar
                             //[self setupGesturesOnMainView];
                         }
                     }];
    
}

- (void)movePanelToOriginalPosition
{
    float menuWidth = self.leftMenuVC.view.frame.size.width;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         weakSelf.leftMenuVC.view.frame = CGRectMake(-menuWidth, 0,menuWidth, weakSelf.view.frame.size.height);
                         weakSelf.vuOverlay.hidden = YES;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             [weakSelf resetMainView];
                         }
                     }];
}



//****************************************************
#pragma mark - C411LeftMenuVCActionDelegate Methods
//****************************************************

-(void)userDidPerformAction:(LeftMenuAction)leftMenuAction
{
    
    switch (leftMenuAction) {
        case LeftMenuActionMyProfileTapped:
            ///Show my profile screen
            [self showMyProfile];
            break;

        case LeftMenuActionGenerateQRCodeTapped:
            ///Show generate QR Code screen
            [self showGenerateQRCodeScreen];
            break;

        case LeftMenuActionScanQRCodeTapped:
            ///Show scan QR Code screen
            [self showScanQRCodeScreen];
            break;
        
        case LeftMenuActionSettingsTapped:
            ///Show Settings screen
            [self showSettings];
            break;
        case LeftMenuActionNotificationsTapped:
            ///Show Settings screen
            [self showNotifications];
            break;

        case LeftMenuActionKnowYourRightsTapped:
            ///Show Know Your Rights screen
            [self showKnowYourRights];
            break;
        
        case LeftMenuActionShareThisAppTapped:
            ///Show Share This App screen
            [self showShareThisAppPopup];
            break;
        
        case LeftMenuActionRateThisAppTapped:
            ///Show Rate This App screen
            [self showRateApp];
            break;
        
        case LeftMenuActionFAQTapped:
            ///Show FAQ screen
            [self showFAQ];
            break;
        
        case LeftMenuActionChangePasswordTapped:
            ///Show Change Password screen
            break;
        case LeftMenuActionBroadcastMessageTapped:
            ///Show Broadcast Message screen
            [self showBroadcastMessageUI];
            break;
            
        case LeftMenuActionAboutTapped:
            ///Show About us screen
            [self showAboutUsScreen];
            break;

        case LeftMenuActionLogoutTapped:
            ///Perform Logout
            [self showLogoutPopup];
            break;
            
        default:
            break;
    }
    
}


//****************************************************
#pragma mark - C411LeftMenuVCActionDelegate Helper Methods
//****************************************************

-(void)showMyProfile
{
    C411MyProfileVC *myProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411MyProfileVC"];
    [self.navigationController pushViewController:myProfileVC animated:YES];
    
}

-(void)showScanQRCodeScreen
{
    C411BarcodeScannerVC *barcodeScannerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411BarcodeScannerVC"];
    barcodeScannerVC.delegate = self;
    [self.navigationController pushViewController:barcodeScannerVC animated:YES];
}

-(void)showGenerateQRCodeScreen
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
    strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (strEmail.length > 0) {
        ///show QR Code generator screen
        C411QRCodeGeneratorVC *QRCodeGeneratorVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411QRCodeGeneratorVC"];
        [self.navigationController pushViewController:QRCodeGeneratorVC animated:YES];

    }
    else{
        
        ///Show update email popup
        __weak typeof(self) weakSelf = self;
        
        [[C411AppDefaults sharedAppDefaults]showUpdateEmailPopupForUser:currentUser fromViewController:self withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            ///Perform operation only if succeeded, error display is already handled
            if (succeeded) {
                
                ///show QR Code generator screen
                C411QRCodeGeneratorVC *QRCodeGeneratorVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"C411QRCodeGeneratorVC"];
                [weakSelf.navigationController pushViewController:QRCodeGeneratorVC animated:YES];

            }
            
        }];
        
    }

}

-(void)showSettings
{
    C411SettingsVC *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411SettingsVC"];
    [self.navigationController pushViewController:settingsVC animated:YES];
    
}

-(void)showNotifications
{
    C411NotificationVC *notificationsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411NotificationVC"];
    [self.navigationController pushViewController:notificationsVC animated:YES];
    
}


-(void)showKnowYourRights
{
    C411KnowYourRightsVC *knowYourRightsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411KnowYourRightsVC"];
    [self.navigationController pushViewController:knowYourRightsVC animated:YES];
    
}

-(void)showShareThisAppPopup
{
    NSString *strShareText = @"";
    
#if APP_IER
    strShareText =[NSString localizedStringWithFormat:NSLocalizedString(@"Hi, I am using %@ to issue alerts while emergencies. It's free. Why don't you check it out on your phone.\nhttp://www.ier.co.za/index.html", nil),LOCALIZED_APP_NAME];
#elif APP_RO112
    strShareText =[NSString localizedStringWithFormat:NSLocalizedString(@"Hi, I am using %@ to issue alerts while emergencies. It's free. Why don't you check it out on your phone.\n%@", nil),LOCALIZED_APP_NAME,DOWNLOAD_APP_URL];
#else
    strShareText =[NSString localizedStringWithFormat:NSLocalizedString(@"Hi, I am using %@ to issue alerts while emergencies. It's free. Why don't you check it out on your phone.\nhttp://getcell411.com", nil),LOCALIZED_APP_NAME];
#endif
    NSArray * arrActivityItems = @[strShareText];
    
    UIActivityViewController *shareActivityVC = [[UIActivityViewController alloc]initWithActivityItems:arrActivityItems applicationActivities:nil];
    shareActivityVC.excludedActivityTypes = @[UIActivityTypeAirDrop];
    //    [shareActivityVC setValue:self.story.strTitle forKey:@"subject"];
    [self presentViewController:shareActivityVC animated:YES completion:NULL];

}

-(void)showFAQ
{

    NSURL *FAQUrl = [NSURL URLWithString:FAQ_AND_TUTORIAL_URL];
    
    if (FAQUrl && [[UIApplication sharedApplication]canOpenURL:FAQUrl]) {
        
        [[UIApplication sharedApplication]openURL:FAQUrl];
        
    }

}

-(void)showRateApp
{
    if (RATE_APP_URL.length > 0) {
        NSURL *rateAppUrl = [NSURL URLWithString:RATE_APP_URL];
        [[UIApplication sharedApplication]openURL:rateAppUrl];
        
    }

}

-(void)showLogoutPopup
{
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Are you sure, you want to logout? You will no longer be able to receive and send emergency alerts!", nil) preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///User taps cancel, do nothing
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///perform logout operation
        [[AppDelegate sharedInstance]userDidLogout];

        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

        
    }];
    
    [confirmAlert addAction:cancelAction];
    [confirmAlert addAction:logoutAction];
    
    //[self presentViewController:confirmAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmAlert];

}


-(void)showBroadcastMessageUI
{

    C411BroadcastMessageVC *broadcastMessageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411BroadcastMessageVC"];
    [self.navigationController pushViewController:broadcastMessageVC animated:YES];

}

-(void)showAboutUsScreen
{
    C411BrowserVC *browserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411BrowserVC"];
    browserVC.url = [C411ColorHelper sharedInstance].aboutURL;
    browserVC.strTitle = NSLocalizedString(@"About", nil);
    [self.navigationController pushViewController:browserVC animated:YES];
}

//****************************************************
#pragma mark - C411BarcodeScannerVCDelegate Methods
//****************************************************

-(void)scanner:(C411BarcodeScannerVC *)scanner didScanBarcodesWithResult:(NSArray *)arrBarcodes
{
    scanner.delegate = nil;

    ///remove the scanner
    [self.navigationController popViewControllerAnimated:YES];

    if (arrBarcodes && arrBarcodes.count > 0) {
        
        [[C411AppDefaults sharedAppDefaults] addFriendWithEmailId:[arrBarcodes lastObject]];
        
    }
}

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
