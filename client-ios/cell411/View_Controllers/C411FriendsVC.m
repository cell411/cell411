//
//  C411FriendsVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411FriendsVC.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "Constants.h"
#import "MAAlertPresenter.h"
#import "C411BarcodeScannerVC.h"
#import "AppDelegate.h"
#import "C411AppDefaults.h"
#import "C411ImportContactsVC.h"
#import "C411ColorHelper.h"

#if IS_CONTACTS_SYNCING_ENABLED
#import "C411UploadContactsVC.h"
#endif

//#import <LGPlusButtonsView/LGPlusButtonsView.h>
//#import "UIButton+FABMenu.h"
#define TAG_TAB_TITLE 101

@interface C411FriendsVC ()<ViewPagerDataSource,ViewPagerDelegate,C411BarcodeScannerVCDelegate
>

//@property (nonatomic, strong) LGPlusButtonsView *plusButtonsViewMain;
- (IBAction)barBtnShowMoreOptionsTapped:(UIBarButtonItem *)sender;

@end

@implementation C411FriendsVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;
    self.delegate = self;
    //[self addFABMenuButton];
    [self configureViews];
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

/*
-(void)addFABMenuButton
{
    
    NSArray *arrButtonsDescription = @[@"",
                                       NSLocalizedString(@"Scan QR Code", nil),NSLocalizedString(@"Import Contacts", nil)];
    NSArray *arrButtonsImage = @[[NSNull new], [[UIImage imageNamed:@"nav_scan_qr"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal], [UIImage imageNamed:@"fab_add_friend"]];
    
    __weak typeof(self) weakSelf = self;
    self.plusButtonsViewMain = [UIButton plusButtonsViewWithNumberOfButtons:3 withButtonsTitle:@[@"+",@"",@""] buttonsDescription:arrButtonsDescription buttonsImage:arrButtonsImage actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index) {
        
        //NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
        
        
        if (index > 0){
            
            ///Close the menu if option other than + is tapped
            [weakSelf.plusButtonsViewMain hideButtonsAnimated:YES completionHandler:^{
                
                //NSLog(@"Hidden");
                
            }];
            
        }
        
        switch (index) {
                case 0:
                ///+ button tapped, do nothing
                break;
                
                case 1:
                ///Sacn QR code tapped
                break;
                
                case 2:
                ///Import Contacts tapped
                break;
                
            default:
                break;
        }
        
    }];
    [self.view addSubview:self.plusButtonsViewMain];

}
*/

-(void)configureViews
{
    self.title = NSLocalizedString(@"Friends", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors {
    ///Set colors of tab labels
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    for (UIView *tabView in self.tabs) {
        UILabel *lblTabTitle = [tabView viewWithTag:TAG_TAB_TITLE];
        if([lblTabTitle isKindOfClass:[UILabel class]]) {
            lblTabTitle.textColor = primaryTextColor;
        }
    }
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)showScanQRCodeScreen
{
    C411BarcodeScannerVC *barcodeScannerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411BarcodeScannerVC"];
    barcodeScannerVC.delegate = self;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;

    [rootNavC pushViewController:barcodeScannerVC animated:YES];
}

-(void)showImportContactsScreen
{
    C411ImportContactsVC *importContactsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ImportContactsVC"];
   UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    
    [rootNavC pushViewController:importContactsVC animated:YES];
}

#if IS_CONTACTS_SYNCING_ENABLED
-(void)showUploadContactsScreen
{
    ///Push the upload contacts VC
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    
    C411UploadContactsVC *uploadContactsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411UploadContactsVC"];
    uploadContactsVC.parentVC = [rootNavC.viewControllers lastObject];
    
    [rootNavC pushViewController:uploadContactsVC animated:YES];

}
#endif

//****************************************************
#pragma mark - ViewPagerDataSource Methods
//****************************************************

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 3;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    NSString *strTabTitle = nil;
    
    switch (index) {
        case 0:
            strTabTitle = NSLocalizedString(@"SEARCH", nil);
            break;
        case 1:
            strTabTitle = NSLocalizedString(@"REQUESTS", nil);
            break;
        case 2:
            strTabTitle = NSLocalizedString(@"FRIENDS", nil);
            break;
            
        default:
            break;
    }
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14.0];
    label.text = strTabTitle;
    label.textAlignment = NSTextAlignmentCenter;
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    label.textColor = primaryTextColor;
    label.tag = TAG_TAB_TITLE;
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    NSString *strStoryboardVCId = nil;
    
    switch (index) {
        case 0:
            strStoryboardVCId = @"C411SearchFriendsVC";
            break;
        case 1:
            strStoryboardVCId = @"C411FriendRequestsVC";
            break;
        case 2:
            strStoryboardVCId = @"C411FriendListVC";
            break;
            
        default:
            break;
    }
    
    UIViewController *contentVC = [self.storyboard instantiateViewControllerWithIdentifier:strStoryboardVCId];
    
    return contentVC;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 36.0;
        case ViewPagerOptionTabWidth:
            return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 168.0 : 136.0;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 1.0;
        default:
            return value;
    }
}

- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [C411ColorHelper sharedInstance].themeColor;
        case ViewPagerTabsView:
            return [C411ColorHelper sharedInstance].cardColor;
        case ViewPagerContent:
            return [C411ColorHelper sharedInstance].backgroundColor;
        default:
            return color;
    }
}

-(void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index fromIndex:(NSUInteger)previousIndex didSwipe:(BOOL)didSwipe
{

    if (previousIndex == 0){
        
        ///Post notification to remove search friends search bar if visible
        [[NSNotificationCenter defaultCenter]postNotificationName:kDidMovedAwayFromSearchFriendsNotification object:nil];

    }
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnShowMoreOptionsTapped:(UIBarButtonItem *)sender {
    
    UIAlertController *moreOptionPicker = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    ///2.Add scan QR code action
    UIAlertAction *scanQRCodeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Scan QR Code", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///Show Scan QR code screen
        [weakSelf showScanQRCodeScreen];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:scanQRCodeAction];
    
    ///3.Add import contacts action
    UIAlertAction *importContactsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Import Contacts", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
#if IS_CONTACTS_SYNCING_ENABLED
        BOOL isUploadContactsEnabled = [[AppDelegate getLoggedInUser][kUserSyncContactsKey] boolValue];
        if(isUploadContactsEnabled){
        
            ///Show Import Contacts screen
            [weakSelf showImportContactsScreen];
        }
        else{
            
            ///Show Upload Contacts screen
            [weakSelf showUploadContactsScreen];
        }
        
#else
        ///Show Import Contacts screen
        [weakSelf showImportContactsScreen];
#endif
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:importContactsAction];

    
    ///Add cancel button action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///Do anything to be done on cancel
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [moreOptionPicker addAction:cancelAction];
    
    ///Present action sheet
    //[self presentViewController:mapTypePicker animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:moreOptionPicker];

}

//****************************************************
#pragma mark - C411BarcodeScannerVCDelegate Methods
//****************************************************

-(void)scanner:(C411BarcodeScannerVC *)scanner didScanBarcodesWithResult:(NSArray *)arrBarcodes
{
    scanner.delegate = nil;
    
    ///remove the scanner
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;

    [rootNavC popViewControllerAnimated:YES];
    
    if (arrBarcodes && arrBarcodes.count > 0) {
        
        [[C411AppDefaults sharedAppDefaults] addFriendWithEmailId:[arrBarcodes lastObject]];
        
    }
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    [self setNeedsReloadColors];
}

@end
