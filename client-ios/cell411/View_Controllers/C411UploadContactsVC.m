//
//  C411UploadContactsVC.m
//  cell411
//
//  Created by Milan Agarwal on 05/01/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411UploadContactsVC.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "C411ImportContactsVC.h"
#import "C411ColorHelper.h"

@interface C411UploadContactsVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet UIView *vuSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblDisclaimer;
@property (weak, nonatomic) IBOutlet UIButton *btnGetStarted;
- (IBAction)btnGetStartedTapped:(UIButton *)sender;

@end

@implementation C411UploadContactsVC

#if IS_CONTACTS_SYNCING_ENABLED

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
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

-(void)configureViews{
    
    self.title = NSLocalizedString(@"Import Contacts", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
     ///Configure get started button
    self.btnGetStarted.layer.cornerRadius = 4.0f;
    self.btnGetStarted.layer.masksToBounds = YES;
    
    ///Set subtitle with dynamic app name
    self.lblSubtitle.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Check who's on %@ network by uploading your contacts and then you can choose with whom you want to connect",nil),LOCALIZED_APP_NAME];
    
    ///Set disclaimer with dynamic app name
    self.lblDisclaimer.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Info about contacts in your address book, including names, phone numbers and emails will be sent to %@ to help you and other find friends faster and to help us provide a better service. You can turn this off in Settings and manage or delete contact information you share with %@.",nil),LOCALIZED_APP_NAME, LOCALIZED_APP_NAME];
    
    [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///set secondary color on line separator
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    self.vuSeparator.backgroundColor = secondaryColor;
    
    ///Set themeColor
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnGetStarted.backgroundColor = themeColor;
    
    ///Set primary text color
    self.lblTitle.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    
    ///set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblSubtitle.textColor = secondaryTextColor;
    self.lblDisclaimer.textColor = secondaryTextColor;

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

- (IBAction)btnGetStartedTapped:(UIButton *)sender {
    
    ///Show the import contacts vc
    C411ImportContactsVC *importContactsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ImportContactsVC"];
    importContactsVC.syncContacts = YES;
    importContactsVC.parentVC = self.parentVC;
    [self.navigationController pushViewController:importContactsVC animated:YES];
    
}
//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

#endif

@end
