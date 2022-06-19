//
//  C411SendAlertPopupVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411SendAlertPopupVC.h"
#import "C411AlertGroupSelectionCell.h"
#import "C411AppDefaults.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "AppDelegate.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"

@interface C411SendAlertPopupVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *vuContentContainer;
@property (weak, nonatomic) IBOutlet UITableView *tblVuAlertGroups;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnIncludeSecurityGuards;
@property (weak, nonatomic) IBOutlet UILabel *lblIncludeSecurityGuards;
@property (weak, nonatomic) IBOutlet UIButton *btnIncludeSecurityGuards;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *        cnsIncludeSecurityGuardButtonHeight;
;
- (IBAction)btnOkTapped:(UIButton *)sender;
- (IBAction)btnCancelTapped:(UIButton *)sender;
- (IBAction)btnIncludeSecurityGuardToggled:(UIButton *)sender;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation C411SendAlertPopupVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 15 pixel
    self.tblVuAlertGroups.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);
    [self registerForNotifications];
    
    ///All Friends will be selected by default
    self.selectedIndex = 0;
    
#if NON_APP_USERS_ENABLED
    
    if ([self canShowNonAppUserCellsOption]) {

        self.selectedIndex++;
    }
    
#endif
    
    if ([self canShowPublicCellsOption]) {
        
        self.selectedIndex++;
        
    }
    
    if ([C411AppDefaults canShowSecurityGuardOption] && (!self.isForwardingAlert)) {
        
        self.selectedIndex++;
    }
    
    if ([self canShowGlobalAlertOption]) {
        
        self.selectedIndex++;
    }
    
    
    
/*
    if ([self canShowPublicCellsOption]) {
        
        if ([C411AppDefaults canShowSecurityGuardOption]) {
            
            self.selectedIndex = 3;
        }
        else{
            self.selectedIndex = 2;
        }
        
    }
    else if ([C411AppDefaults canShowSecurityGuardOption]) {
        
        self.selectedIndex = 2;
    }
    else{
        self.selectedIndex = 1;
        
    }
*/
    
    [self setupViews];
#if (!(APP_IER || APP_RO112))
    
    ///Update cell groups to have only cells with atleast one member
    self.arrCellGroups = [self getValidCellGroupsFromCellGroups:self.arrCellGroups];
#endif
    
    [self.tblVuAlertGroups reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.delegate = nil;
    self.arrCellGroups = nil;
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cellsListUpdated:) name:kCellsListUpdatedNotification object:nil];
    
    ///observe the open and close notification of non app users selection vc
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didOpenedNauSelectionVC:) name:kDidOpenedNonAppUsersSelectionVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClosedNauSelectionVC:) name:kDidClosedNonAppUsersSelectionVCNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}


-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setupViews
{
    NSString *strTitle = nil;
    
    if (self.isForwardingAlert) {
       
        ///User is forwarding someone's else alert.
        strTitle = NSLocalizedString(@"Forward Alert?", nil);
        
    }
    else{
        
        ///User is actually initiating the alert, use alertType to make the title
        switch (self.alertType) {
            case BTN_ALERT_TAG_PULLED_OVER:
                strTitle = NSLocalizedString(@"Send pulled over alert?", nil);
                break;
            case BTN_ALERT_TAG_ARRESTED:
                strTitle = NSLocalizedString(@"Send arrested alert?", nil);
                break;
            case BTN_ALERT_TAG_MEDICAL_ATTENTION:
                strTitle = NSLocalizedString(@"Send medical alert?", nil);
                break;
            case BTN_ALERT_TAG_CAR_BROKE:
                strTitle = NSLocalizedString(@"Send vehicle broken alert?", nil);
                break;
            case BTN_ALERT_TAG_CRIME:
                strTitle = NSLocalizedString(@"Send crime alert?", nil);
                break;
            case BTN_ALERT_TAG_FIRE:
                strTitle = NSLocalizedString(@"Send fire alert?", nil);
                break;
            case BTN_ALERT_TAG_DANGER:
                strTitle = NSLocalizedString(@"Send danger alert?", nil);
                break;
            case BTN_ALERT_TAG_COP_BLOCKING:
                strTitle = NSLocalizedString(@"Send police interaction alert?", nil);
                break;
            case BTN_ALERT_TAG_BULLIED:
#if APP_IER
                strTitle = NSLocalizedString(@"Send bullied alert?", nil);
#else
                strTitle = NSLocalizedString(@"Send harassed alert?", nil);
#endif
                break;
            case BTN_ALERT_TAG_GENERAL:
                strTitle = NSLocalizedString(@"Send general alert?", nil);
                break;
            case BTN_ALERT_TAG_VIDEO:
                strTitle = NSLocalizedString(@"Stream and share live video with?", nil);
                break;
            case BTN_ALERT_TAG_PHOTO:
                strTitle = NSLocalizedString(@"Send photo alert?", nil);
                break;
            case BTN_ALERT_TAG_HIJACK:
                strTitle = NSLocalizedString(@"Send hijack alert?", nil);
                break;
            case BTN_ALERT_TAG_PHYSICAL_ABUSE:
                strTitle = NSLocalizedString(@"Send physical abuse alert?", nil);
                break;
            case BTN_ALERT_TAG_TRAPPED:
                strTitle = NSLocalizedString(@"Send trapped/lost alert?", nil);
                break;
            case BTN_ALERT_TAG_CAR_ACCIDENT:
                strTitle = NSLocalizedString(@"Send car accident alert?", nil);
                break;
            case BTN_ALERT_TAG_NATURAL_DISASTER:
                strTitle = NSLocalizedString(@"Send natural disaster alert?", nil);
                break;
            case BTN_ALERT_TAG_PRE_AUTHORIZATION:
                strTitle = NSLocalizedString(@"Send pre-authorisation alert?", nil);
                break;
                

            default:
                break;
        }
    }

    
    self.lblAlertTitle.text = strTitle;
    
    ///Set dynamic name for call center
    self.lblIncludeSecurityGuards.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Include %@ Call Centre",nil),LOCALIZED_APP_NAME];
    
    if ((![C411AppDefaults canShowSecurityGuardOption]) || self.isForwardingAlert) {
        
        ///hide the include security guard option
        self.tglBtnIncludeSecurityGuards.hidden = YES;
        self.lblIncludeSecurityGuards.hidden = YES;
        self.btnIncludeSecurityGuards.hidden = YES;
        self.cnsIncludeSecurityGuardButtonHeight.constant = 0;

    }
    else{
        
        ///enable/disable include security guard option as per the settings
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.tglBtnIncludeSecurityGuards.selected = [[defaults objectForKey:kIncludeSecurityGuards]boolValue];
        
        ///this option will always be enabled and user is not allowed to edit it so disable it's interaction
        self.btnIncludeSecurityGuards.enabled = NO;
        self.tglBtnIncludeSecurityGuards.alpha = 0.6;
        self.lblIncludeSecurityGuards.alpha = 0.6;


    }
    [self applyColors];
}

-(void)applyColors {
    ///set background color
    self.vuContentContainer.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTitle.textColor = primaryTextColor;
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblIncludeSecurityGuards.textColor = secondaryTextColor;
    self.tglBtnIncludeSecurityGuards.tintColor = secondaryTextColor;
    
    ///Set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnOk setTitleColor:secondaryColor forState:UIControlStateNormal];
    [self.btnCancel setTitleColor:secondaryColor forState:UIControlStateNormal];
    
}

-(NSArray *)getValidCellGroupsFromCellGroups:(NSArray *)arrCellGroups
{
    NSMutableArray *arrValidCellGroups = [NSMutableArray array];
    for (PFObject *cell in arrCellGroups) {
        
        NSArray *arrCellMembers = cell[kCellMembersKey];
        if (arrCellMembers.count > 0) {
            
            [arrValidCellGroups addObject:cell];
            
        }
        
    }
    
    return arrValidCellGroups;
}

-(BOOL)canShowPublicCellsOption
{
    if (self.isForwardingAlert || self.alertType == BTN_ALERT_TAG_VIDEO) {
        
        return NO;
    }
    
    return YES;
    
}

-(BOOL)canShowGlobalAlertOption
{
#if PATROL_FEATURE_ENABLED
    return YES;
#else
    return NO;
#endif
}

-(BOOL)canShowNonAppUserCellsOption
{
    if (self.isForwardingAlert || self.alertType == BTN_ALERT_TAG_VIDEO) {
        
        return NO;
    }
    
    return YES;
    
}

-(void)goBack
{
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [navRoot.view sendSubviewToBack:self.view];
    
}

-(void)moveToFront
{
    ///bring current view to front
    [[AppDelegate sharedInstance].window.rootViewController.view bringSubviewToFront:self.view];
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnOkTapped:(UIButton *)sender {
    NSInteger selectedIndex = self.selectedIndex;
    
#if NON_APP_USERS_ENABLED
    
    if ([self canShowNonAppUserCellsOption]) {

        ///decrement the selected index by 1, so that below conditions could work as if there is no non app users cells option available in tableview
        selectedIndex--;
    }
    
#endif

    if ([self canShowPublicCellsOption]) {
        
        ///decrement the selected index by 1, so that below conditions could work as if there is no public cells option available in tableview
        selectedIndex--;
    }
    
    if ([C411AppDefaults canShowSecurityGuardOption] && (!self.isForwardingAlert)) {
        
        if (selectedIndex == 0) {
            
            ///Security guard option is selected
            [self.delegate sendAlertPopupDidSelectSecurityGuard:self];
            return;
            
        }
        else{
            
            ///decrement the selected index by 1, so that below conditions could work as if there is no Security guard option available in tableview
            selectedIndex--;
        }
    }
    
    if ([self canShowGlobalAlertOption]) {
        
        if (selectedIndex == 0) {
            
            ///User choses to send Gloabl Alert
            [self.delegate sendAlertPopupDidSelectGlobalAlert:self];
            return;
            
        }
        else{
            
            ///decrement the selected index by 1, so that below conditions could work as if there is no Global Alert option available in tableview
            selectedIndex--;
        }
    }

    
    if (selectedIndex == 0){
    
        ///User choses to send alert to all friends
        [self.delegate sendAlertPopupDidSelectAllFriends:self];
        
    }
    else{
        ///User choses to send alert to particular cell members
        
        PFObject *cell = [self.arrCellGroups objectAtIndex:selectedIndex - 1];
        [self.delegate sendAlertPopup:self didSelectCell:cell];
        
    }
    
}

- (IBAction)btnCancelTapped:(UIButton *)sender {
    
    [self.delegate sendAlertPopupDidCancel:self];
}

- (IBAction)btnIncludeSecurityGuardToggled:(UIButton *)sender
{
    self.tglBtnIncludeSecurityGuards.selected = !self.tglBtnIncludeSecurityGuards.isSelected;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(self.tglBtnIncludeSecurityGuards.isSelected) forKey:kIncludeSecurityGuards];
    [defaults synchronize];
    
}


//****************************************************
#pragma mark - UITableViewDataSource and delegate methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = self.arrCellGroups.count + 1; ///+1 for all friends option

#if NON_APP_USERS_ENABLED
    if ([self canShowNonAppUserCellsOption]) {

        //+1 for non app users cells option
        rowCount++;
    }
#endif
    

    if ([self canShowPublicCellsOption]) {
        //+1 for public cells option
        rowCount++;
    }
   
    if ([C411AppDefaults canShowSecurityGuardOption] && (!self.isForwardingAlert)) {
        //+1 for Security Guard option
        rowCount++;
    }

    if ([self canShowGlobalAlertOption]) {
        ///+1 for Global Alert option
        rowCount++;
        
    }
    return rowCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    NSInteger selectedIndex = self.selectedIndex;
    static NSString *strDisclosureCellId = @"C411DisclosureCell";

    
#if NON_APP_USERS_ENABLED

    if ([self canShowNonAppUserCellsOption]) {
        
        if (rowIndex == 0) {
            
            ///return the non app user cells cell
            UITableViewCell *nonAppUsersSelectionCell = [tableView dequeueReusableCellWithIdentifier:strDisclosureCellId];
            UILabel *lblCellTitle = [nonAppUsersSelectionCell viewWithTag:101];
            lblCellTitle.text = NSLocalizedString(@"SMS/Email", nil);
            lblCellTitle.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
            return nonAppUsersSelectionCell;
            
        }
        else{
            ///decrement the row index and selected index by 1, so that below conditions could work as if there is no non app user cells option available in tableview
            rowIndex--;
            selectedIndex--;
        }

    }
    
#endif
    
    if ([self canShowPublicCellsOption]) {
        
        if (rowIndex == 0) {
            
            ///return the public cells cell
            UITableViewCell *publicCellSelectionCell = [tableView dequeueReusableCellWithIdentifier:strDisclosureCellId];
            UILabel *lblCellTitle = [publicCellSelectionCell viewWithTag:101];
            lblCellTitle.text = NSLocalizedString(@"Public Cells", nil);
            lblCellTitle.textColor = [C411ColorHelper sharedInstance].primaryTextColor;

            return publicCellSelectionCell;
            
        }
        else{
            ///decrement the row index and selected index by 1, so that below conditions could work as if there is no public cells option available in tableview
            rowIndex--;
            selectedIndex--;
        }
        
    }
    static NSString * cellId = @"C411AlertGroupSelectionCell";
    C411AlertGroupSelectionCell *alertGroupCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if ([C411AppDefaults canShowSecurityGuardOption] && (!self.isForwardingAlert)) {
        
        if (rowIndex == 0) {
            
            ///set return the Security guard option cell
            alertGroupCell.lblAlertRecievingGroupName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ Call Centre",nil),LOCALIZED_APP_NAME];
            if (selectedIndex == rowIndex) {
                alertGroupCell.radioBtnCellSelectionIndicator.selected = YES;
            }
            else{
                
                alertGroupCell.radioBtnCellSelectionIndicator.selected = NO;
            }
            return alertGroupCell;
            
        }
        else{
            ///decrement the row index and selected index by 1, so that below conditions could work as if there is no security guard option available in tableview
            rowIndex--;
            selectedIndex--;
        }
        
    }

    if ([self canShowGlobalAlertOption]) {
        
        if (rowIndex == 0) {
            
            /// return the Global Alert option cell
            alertGroupCell.lblAlertRecievingGroupName.text = NSLocalizedString(@"GLOBAL ALERT", nil);
            if (selectedIndex == rowIndex) {
                alertGroupCell.radioBtnCellSelectionIndicator.selected = YES;
            }
            else{
                
                alertGroupCell.radioBtnCellSelectionIndicator.selected = NO;
            }
            return alertGroupCell;
            
        }
        else{
            ///decrement the row index and selected index by 1, so that below conditions could work as if there is no Global Alert option available in tableview
            rowIndex--;
            selectedIndex--;
        }
        
    }

    
    NSString *strCellName  = nil;
    if (rowIndex == 0) {
        ///All Friends
        strCellName = NSLocalizedString(@"All Friends", nil);
        
    }
    else{
        
        PFObject *cell = [self.arrCellGroups objectAtIndex:rowIndex - 1];
        
        strCellName = [C411StaticHelper getLocalizedNameForCell:cell];
    }
    
    alertGroupCell.lblAlertRecievingGroupName.text = strCellName;
    if (selectedIndex == rowIndex) {
        alertGroupCell.radioBtnCellSelectionIndicator.selected = YES;
    }
    else{
        
        alertGroupCell.radioBtnCellSelectionIndicator.selected = NO;
    }
    
    return alertGroupCell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    NSInteger publicCellRowIndex = 0;
#if NON_APP_USERS_ENABLED
   
    if ([self canShowNonAppUserCellsOption]) {
       
        if (rowIndex == 0) {
            
            ///if user tapped on non app user cells then show the non app user cells popup
            [self.delegate sendAlertPopupDidSelectNonAppUserCells:self];
            
            ///return from here and don't let below statement to be executed
            return;
        }
        else{
            ///increment the public cell row index by 1, to handle rowindex for  non app user cells option available in tableview
            publicCellRowIndex++;
        }
    
    }


#endif

    if ([self canShowPublicCellsOption] && rowIndex == publicCellRowIndex) {
        
        ///if user tapped on public cells then show the public cells popup
       
        [self.delegate sendAlertPopupDidSelectPublicCells:self];
    }
    else{
        
        self.selectedIndex = rowIndex;
        [self.tblVuAlertGroups reloadData];

    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)cellsListUpdated:(NSNotification *)notif
{
#if (APP_IER || APP_RO112)

    self.arrCellGroups = [C411AppDefaults sharedAppDefaults].arrCells;
    
#else
    
    self.arrCellGroups = [self getValidCellGroupsFromCellGroups:[C411AppDefaults sharedAppDefaults].arrCells];

#endif
    
    [self.tblVuAlertGroups reloadData];
}

-(void)didOpenedNauSelectionVC:(NSNotification *)notif
{
    [self goBack];
}

-(void)didClosedNauSelectionVC:(NSNotification *)notif
{
    [self moveToFront];
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    [self.tblVuAlertGroups reloadData];
}

@end
