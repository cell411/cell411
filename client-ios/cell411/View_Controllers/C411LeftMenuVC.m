//
//  C411LeftMenuVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411LeftMenuVC.h"
#import "C411StaticHelper.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "C411LeftMenuCell.h"
#import "UITableView+RemoveTopPadding.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "AppDelegate.h"
#import "C411AppDefaults.h"
#import "C411ColorHelper.h"

#define TOTAL_ROWS  10

#define TABLE_ROW_INDEX_MY_PROFILE          0
#define TABLE_ROW_INDEX_GEN_QR              1
#define TABLE_ROW_INDEX_SCAN_QR             2
#define TABLE_ROW_INDEX_SETTINGS            3
#define TABLE_ROW_INDEX_NOTIFICATIONS       4
#define TABLE_ROW_INDEX_KNOW_YOUR_RIGHTS    5
#define TABLE_ROW_INDEX_SHARE_THIS_APP      6
#define TABLE_ROW_INDEX_RATE_THIS_APP       7
#define TABLE_ROW_INDEX_FAQ                 8
//#define TABLE_ROW_INDEX_CHANGE_PWD          8
#define TABLE_ROW_INDEX_BROADCAST           9
#define TABLE_ROW_INDEX_ABOUT               10
#define TABLE_ROW_INDEX_LOGOUT              11

@interface C411LeftMenuVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgVuNavHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroup;
@property (weak, nonatomic) IBOutlet UIView *vuBloodGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblBloodGroupVal;
@property (weak, nonatomic) IBOutlet UITableView *tblVuMenuItems;
@property (nonatomic, strong) NSArray *arrRowIndexMapping;
@end

@implementation C411LeftMenuVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
    [self configureViews];
    [self fillDetails];
    
    ///Remove top padding of 15 pixel
    [self.tblVuMenuItems removeTopPadding];
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

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myProfileUpdated:) name:kMyProfileUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)configureViews
{
    ///Make rounded views
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    [C411StaticHelper makeCircularView:self.vuBloodGroup];
    [self applyColors];
}

-(void)applyColors {
    ///Set background color
    self.vuLeftMenuContainer.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set header image
    self.imgVuNavHeader.image = [C411ColorHelper sharedInstance].imgNavHeader;
    
    ///Set text color on primary BG
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblFullName.textColor = primaryBGTextColor;
    self.lblUsername.textColor = primaryBGTextColor;
    self.lblBloodGroup.textColor = primaryBGTextColor;
    self.lblBloodGroupVal.textColor = primaryBGTextColor;
}

-(void)fillDetails
{
 
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    
    __weak typeof(self) weakSelf = self;
    
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (object) {
            ///show user email
            NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
            weakSelf.lblUsername.text = strEmail;
            weakSelf.lblUsername.hidden = NO;
            
            ///show full name
            NSString *strFirstName = currentUser[kUserFirstnameKey];
            NSString *strLastName = currentUser[kUserLastnameKey];
            weakSelf.lblFullName.text = [C411StaticHelper getFullNameUsingFirstName:strFirstName andLastName:strLastName];
            weakSelf.lblFullName.hidden = NO;
            
            ///show blood group
            NSString *strBloodType = currentUser[kUserBloodTypeKey];
            if (strBloodType.length > 0) {
                
                weakSelf.lblBloodGroupVal.text = strBloodType;
                weakSelf.lblBloodGroup.hidden = NO;
                weakSelf.vuBloodGroup.hidden = NO;
            }
            else{
                weakSelf.lblBloodGroup.hidden = YES;
                weakSelf.vuBloodGroup.hidden = YES;
                
            }
            
//            if (strEmail.length > 0) {
//                
//                ///show user avatar or Gravatar if email is available
//                [C411StaticHelper getGravatarForEmail:strEmail ofSize:(weakSelf.imgVuAvatar.bounds.size.width * 3) roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//                    
//                    if (success && image) {
//                        
//                        weakSelf.imgVuAvatar.image = image;
//                        
//                    }
//                    
//                }];
//            }
            [weakSelf.imgVuAvatar setAvatarForUser:currentUser shouldFallbackToGravatar:YES ofSize:(weakSelf.imgVuAvatar.bounds.size.width * 3) roundedCorners:NO withCompletion:NULL];

            
            
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

/*
 *This will map the table rowindex with the Macros defined for TABLE_ROW_INDEX in order to handle feature enabling/disabling
 */
-(NSArray *)arrRowIndexMapping {
    if(!_arrRowIndexMapping) {
        
        NSMutableArray *arrRowIndexMapping = [NSMutableArray array];
        NSInteger rowIndex = 0;
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_MY_PROFILE);
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_GEN_QR);
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_SCAN_QR);
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_SETTINGS);
        if([C411AppDefaults isBroadcastEnabled]){
            arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_NOTIFICATIONS);
        }
#if KNOW_YOUR_RIGHTS_ENABLED
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_KNOW_YOUR_RIGHTS);
#endif
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_SHARE_THIS_APP);
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_RATE_THIS_APP);
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_FAQ);
        if ([C411AppDefaults isBroadcastEnabled]) {
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            NSInteger roleId = [currentUser[kUserRoleIdKey]integerValue];
            if (roleId == 1) {
                ///Show broadcast menu for admin
                arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_BROADCAST);
            }
        }
#if ABOUT_MENU_ENABLED
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_ABOUT);
#endif
        arrRowIndexMapping[rowIndex++] = @(TABLE_ROW_INDEX_LOGOUT);
        _arrRowIndexMapping = arrRowIndexMapping;
    }
    return _arrRowIndexMapping;
}

-(NSInteger )getMappedRowIndexFromVisibleRowIndex:(NSInteger)visibleRowIndex
{
    if(visibleRowIndex < self.arrRowIndexMapping.count){
        
        NSInteger mappedRowIndex = [self.arrRowIndexMapping[visibleRowIndex] integerValue];
        return mappedRowIndex;
    }
    return NSNotFound;
}

-(NSInteger )getVisibleRowIndexFromMappedRowIndex:(NSInteger)mappedRowIndex
{
    for (NSInteger visibleIndex = 0; visibleIndex < self.arrRowIndexMapping.count; visibleIndex++) {
        NSInteger mappedIndex = [self.arrRowIndexMapping[visibleIndex] integerValue];
        if(mappedIndex == mappedRowIndex){
            return visibleIndex;
        }
    }
    return NSNotFound;
}

//****************************************************
#pragma mark - UITableViewDelegate and Datasource Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrRowIndexMapping.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger visibleRowIndex = indexPath.row;
    NSInteger mappedRowIndex = [self getMappedRowIndexFromVisibleRowIndex:visibleRowIndex];
    static NSString *cellId = @"C411LeftMenuCell";
    C411LeftMenuCell *menuCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    BOOL willRedirectOutsideApp = NO;
    if (mappedRowIndex == TABLE_ROW_INDEX_MY_PROFILE) {
        
        static UIImage *profileIcon = nil;
        if (!profileIcon) {
            
            profileIcon = [UIImage imageNamed:@"nav_my_profile"];
        }
        menuCell.imgVuMenuIcon.image = profileIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"My Profile", nil);
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_GEN_QR) {
        
        static UIImage *genQRIcon = nil;
        if (!genQRIcon) {
            
            genQRIcon = [UIImage imageNamed:@"nav_generate_qr"];
        }
        menuCell.imgVuMenuIcon.image = genQRIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Generate Q.R. Code", nil);
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_SCAN_QR) {
        
        static UIImage *scanQRIcon = nil;
        if (!scanQRIcon) {
            
            scanQRIcon = [UIImage imageNamed:@"nav_scan_qr"];
        }
        menuCell.imgVuMenuIcon.image = scanQRIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Scan Q.R. Code", nil);
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_SETTINGS) {
        
        static UIImage *settingsIcon = nil;
        if (!settingsIcon) {
            
            settingsIcon = [UIImage imageNamed:@"nav_settings"];
        }
        menuCell.imgVuMenuIcon.image = settingsIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Settings", nil);
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_NOTIFICATIONS) {
        
        static UIImage *notificationsIcon = nil;
        if (!notificationsIcon) {
            
            notificationsIcon = [UIImage imageNamed:@"nav_notification"];
        }
        menuCell.imgVuMenuIcon.image = notificationsIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Notifications", nil);
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_KNOW_YOUR_RIGHTS) {
        
        static UIImage *rightsIcon = nil;
        if (!rightsIcon) {
            
            rightsIcon = [UIImage imageNamed:@"nav_know_your_rights"];
        }
        menuCell.imgVuMenuIcon.image = rightsIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Know your rights", nil);
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_SHARE_THIS_APP) {
        
        static UIImage *shareIcon = nil;
        if (!shareIcon) {
            
            shareIcon = [UIImage imageNamed:@"nav_share_this_app"];
        }
        menuCell.imgVuMenuIcon.image = shareIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Share this app", nil);
        willRedirectOutsideApp = YES;
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_RATE_THIS_APP) {
        
        static UIImage *rateIcon = nil;
        if (!rateIcon) {
            
            rateIcon = [UIImage imageNamed:@"nav_rate_this_app"];
        }
        menuCell.imgVuMenuIcon.image = rateIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Rate this app", nil);
        willRedirectOutsideApp = YES;
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_FAQ) {
        
        static UIImage *faqIcon = nil;
        if (!faqIcon) {
            
            faqIcon = [UIImage imageNamed:@"nav_faq"];
        }
        menuCell.imgVuMenuIcon.image = faqIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"FAQ & Tutorials", nil);
        willRedirectOutsideApp = YES;
    }
//    else if (rowIndex == TABLE_ROW_INDEX_CHANGE_PWD) {
//        
//        static UIImage *chgPwdIcon = nil;
//        if (!chgPwdIcon) {
//            
//            chgPwdIcon = [UIImage imageNamed:@"nav_change_password"];
//        }
//        menuCell.imgVuMenuIcon.image = chgPwdIcon;
//        menuCell.lblMenuTitle.text = NSLocalizedString(@"CHANGE PASSWORD", nil);
//        
//    }
    else if(mappedRowIndex == TABLE_ROW_INDEX_BROADCAST){
        
        static UIImage *settingsIcon = nil;
        if (!settingsIcon) {
            
            settingsIcon = [UIImage imageNamed:@"nav_settings"];
        }
        menuCell.imgVuMenuIcon.image = settingsIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Broadcast message", nil);

    }
    else if(mappedRowIndex == TABLE_ROW_INDEX_ABOUT){
        static UIImage *aboutIcon = nil;
        if (!aboutIcon) {
            
            aboutIcon = [UIImage imageNamed:@"nav_about"];
        }
        menuCell.imgVuMenuIcon.image = aboutIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"About", nil);
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_LOGOUT) {
        
        static UIImage *logoutIcon = nil;
        if (!logoutIcon) {
            
            logoutIcon = [UIImage imageNamed:@"nav_logout"];
        }
        menuCell.imgVuMenuIcon.image = logoutIcon;
        menuCell.lblMenuTitle.text = NSLocalizedString(@"Logout", nil);
        UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
        menuCell.imgVuMenuIcon.tintColor = themeColor;
        menuCell.lblMenuTitle.textColor = themeColor;
    }
    menuCell.willRedirectOutsideApp = willRedirectOutsideApp;
    return menuCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger visibleRowIndex = indexPath.row;
    NSInteger mappedRowIndex = [self getMappedRowIndexFromVisibleRowIndex:visibleRowIndex];
    if (mappedRowIndex == TABLE_ROW_INDEX_MY_PROFILE) {
        
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionMyProfileTapped];
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_GEN_QR)
    {
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionGenerateQRCodeTapped];
        
    }
    
    else if (mappedRowIndex == TABLE_ROW_INDEX_SCAN_QR)
    {
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionScanQRCodeTapped];
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_SETTINGS)
    {
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionSettingsTapped];
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_NOTIFICATIONS)
    {
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionNotificationsTapped];
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_KNOW_YOUR_RIGHTS)
    {
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionKnowYourRightsTapped];
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_SHARE_THIS_APP)
    {
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionShareThisAppTapped];
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_RATE_THIS_APP)
    {
        
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionRateThisAppTapped];
        
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_FAQ)
    {
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionFAQTapped];
        
    }
//    else if (rowIndex == TABLE_ROW_INDEX_CHANGE_PWD)
//    {
//        ///Notify the delegate for the action
//        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionChangePasswordTapped];
//        
//    }
    else if(mappedRowIndex == TABLE_ROW_INDEX_BROADCAST){
        
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionBroadcastMessageTapped];
        
    }
    else if(mappedRowIndex == TABLE_ROW_INDEX_ABOUT){
        
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionAboutTapped];
        
    }
    else if (mappedRowIndex == TABLE_ROW_INDEX_LOGOUT) {
        
        ///Notify the delegate for the action
        [self.leftMenuActionDelegate userDidPerformAction:LeftMenuActionLogoutTapped];
        
        
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 37.0f;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    NSString *strVersionString = [NSString stringWithFormat:@"v%@(%@)",appVersionString,appBuildString];
#if DEBUG
    
    strVersionString = [strVersionString stringByAppendingString:@" - dev"];
    
#endif
    return strVersionString;
 }

//****************************************************
#pragma mark - Notifications Methods
//****************************************************

-(void)myProfileUpdated:(NSNotification *)notif
{
    [self fillDetails];
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
