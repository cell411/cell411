//
//  C411ChatEntitiesListVC.m
//  cell411
//
//  Created by Milan Agarwal on 05/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411ChatEntitiesListVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411OtherPublicCell.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "C411ChatVC.h"
#import "AppDelegate.h"
#import "C411ChatEntityAlertCell.h"
#import "C411ChatEntityMyPublicCell.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ColorHelper.h"


#define PAGE_LIMIT  10

#define TOTAL_SECTIONS  3
#define TABLE_SEC_INDEX_ALERTS          0
#define TABLE_SEC_INDEX_OWNED_CELLS     1
#define TABLE_SEC_INDEX_JOINED_CELLS    2

@interface C411ChatEntitiesListVC ()

@property (weak, nonatomic) IBOutlet UITableView *tblVuChatEntities;
@property (weak, nonatomic) IBOutlet UILabel *lblStickyNote;

@property (nonatomic, strong) NSMutableArray *arrChatEligibleAlerts;
@property (nonatomic, strong) NSMutableArray *arrOwnedPublicCells;
@property (nonatomic, strong) NSMutableArray *arrJoinedPublicCells;

@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, assign) BOOL canRefresh;

@end

@implementation C411ChatEntitiesListVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    ///set can refresh to Yes initially
    self.canRefresh = YES;
    
    ///Add pull to refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblVuChatEntities addSubview:refreshControl];
    [self registerForNotifications];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.canRefresh) {
        
        [self fetchChatEntities];
    }
    else{
        ///Update it to YES for next time refresh
        self.canRefresh = YES;
    }
    
    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;

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
#pragma mark - Property initializers
//****************************************************

-(NSMutableArray *)arrJoinedPublicCells
{
    if (!_arrJoinedPublicCells) {
        
        _arrJoinedPublicCells = [NSMutableArray array];
    }
    
    return _arrJoinedPublicCells;
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Select One", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.lblStickyNote.textColor = [C411ColorHelper sharedInstance].disabledTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)fetchChatEntities
{
    ///clear the old data
    self.noMoreData = NO;
    self.arrChatEligibleAlerts = nil;
    self.arrOwnedPublicCells = nil;
    self.arrJoinedPublicCells = nil;
    [self.tblVuChatEntities reloadData];
    self.lblStickyNote.hidden = YES;
    
    __weak typeof(self) weakself = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ///Fetch recent chat eligible alerts first
    [self fetchRecentChatEligibleAlertsWithCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error) {
            
            ///Filter out the deleted alerts
            NSMutableArray *arrAlerts = [NSMutableArray arrayWithArray:objects];
            weakself.arrChatEligibleAlerts = [C411StaticHelper alertsArrayByRemovingInvalidObjectsFromArray:arrAlerts isForwardedAlert:NO];
            
            ///Fetch owned public cell first
            [weakself fetchOwnedPublicCellWithCompletion:^(NSArray * objects, NSError * error){
                
                
                if (!error) {
                    
                    weakself.arrOwnedPublicCells = [NSMutableArray arrayWithArray:objects];
                    
                    ///Fetch joined Public Cell
                    [weakself fetchJoinedPublicCellWithCompletion:^(NSArray * objects, NSError * error){
                        
                        if (!error) {
                            
                            ///Joined cells fetched
                            [weakself.arrJoinedPublicCells addObjectsFromArray:objects];
                            
                            if (objects.count < PAGE_LIMIT) {
                                
                                weakself.noMoreData = YES;
                            }
                            else{
                                
                                weakself.noMoreData = NO;
                            }
                            
                            
                            ///show sticky note if no chat entities are available
                            if (weakself.arrChatEligibleAlerts.count == 0
                                && weakself.arrOwnedPublicCells.count == 0
                                && weakself.arrJoinedPublicCells.count == 0) {
                                
                                weakself.lblStickyNote.hidden = NO;
                                
                            }
                            
                        }
                        else {
                            
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
                            
                            
                            
                        }
                        
                        ///hide hud
                        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                        [weakself.tblVuChatEntities reloadData];
                        
                    }];
                    
                    
                }
                else {
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
                    
                    ///hide hud
                    [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                    
                }
                
                
                
                
            }];
            
        }
        else{
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
            
            ///hide hud
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            
            
        }

        
    }];
    
}


-(void)fetchRecentChatEligibleAlertsWithCompletion:(PFArrayResultBlock)completion
{
    ///make a query on cell411alert class to fetch the recent alerts on which user can chat
    NSDate *minDate = [[NSDate date]dateByAddingTimeInterval:(-1) * ALERT_CHAT_EXPIRATION_TIME];

    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *fetchRecentIssuedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchRecentIssuedAlertsQuery whereKey:kCell411AlertTargetMembersKey containsAllObjectsInArray:@[currentUser]];
    [fetchRecentIssuedAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];

    PFQuery *fetchNeedyPublicAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchNeedyPublicAlertsQuery whereKey:kCell411AlertCellMembersKey equalTo:currentUser];
    [fetchNeedyPublicAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];

    PFQuery *fetchSelfIssuedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchSelfIssuedAlertsQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
    [fetchSelfIssuedAlertsQuery whereKeyExists:kCell411AlertAlertTypeKey];
    [fetchSelfIssuedAlertsQuery whereKeyDoesNotExist:kCell411AlertToKey];
    [fetchSelfIssuedAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];

    //[fetchSelfVideoAlertsQuery whereKey:kCell411AlertAlertTypeKey equalTo:kAlertTypeVideo];
    
    PFQuery *fetchSelfForwardedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchSelfForwardedAlertsQuery whereKey:kCell411AlertForwardedByKey equalTo:currentUser];
    [fetchSelfForwardedAlertsQuery whereKeyExists:kCell411AlertAlertTypeKey];
    [fetchSelfForwardedAlertsQuery whereKeyDoesNotExist:kCell411AlertToKey];
    [fetchSelfForwardedAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];

    
    
    PFQuery *fetchNeedyForwardedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchNeedyForwardedAlertsQuery whereKey:kCell411AlertForwardedToMembersKey containsAllObjectsInArray:@[currentUser]];
    [fetchNeedyForwardedAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];

    PFQuery *fetchRecentAlertsQuery = [PFQuery orQueryWithSubqueries:@[fetchRecentIssuedAlertsQuery,fetchNeedyPublicAlertsQuery,fetchSelfIssuedAlertsQuery,fetchSelfForwardedAlertsQuery, fetchNeedyForwardedAlertsQuery]];
    
    [fetchRecentAlertsQuery includeKey:kCell411AlertIssuedByKey];
    [fetchRecentAlertsQuery includeKey:kCell411AlertForwardedByKey];
    [fetchRecentAlertsQuery orderByDescending:@"createdAt"];
    fetchRecentAlertsQuery.limit = 1000;
    
    [fetchRecentAlertsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
    }];

}

-(void)fetchOwnedPublicCellWithCompletion:(PFArrayResultBlock)completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getOwnedPublicCellsQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [getOwnedPublicCellsQuery whereKey:kPublicCellCreatedByKey equalTo:currentUser];
    [getOwnedPublicCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
    }];
    
}

-(void)fetchJoinedPublicCellWithCompletion:(PFArrayResultBlock)completion
{
    ///Make a new query
    PFQuery *fetchJoinedPublicCellsQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [fetchJoinedPublicCellsQuery whereKey:kPublicCellMembersKey equalTo:[AppDelegate getLoggedInUser]];
    [fetchJoinedPublicCellsQuery whereKey:kPublicCellCreatedByKey notEqualTo:[AppDelegate getLoggedInUser]];
    [fetchJoinedPublicCellsQuery includeKey:kPublicCellCreatedByKey];
    fetchJoinedPublicCellsQuery.skip = self.arrJoinedPublicCells.count;
    fetchJoinedPublicCellsQuery.limit = PAGE_LIMIT;
    [fetchJoinedPublicCellsQuery orderByDescending:kPublicCellTotalMembersKey];
    
    [fetchJoinedPublicCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        
        
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
    }];
    
}

-(void)fetchMoreJoinedPublicCells
{
    __weak typeof(self) weakself = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ///Fetch joined Public Cell
    [weakself fetchJoinedPublicCellWithCompletion:^(NSArray * objects, NSError * error){
        
        if (!error) {
            
            ///Joined cells fetched
            [weakself.arrJoinedPublicCells addObjectsFromArray:objects];
            
            if (objects.count < PAGE_LIMIT) {
                
                self.noMoreData = YES;
            }
            else{
                
                self.noMoreData = NO;
            }
            
            [weakself.tblVuChatEntities reloadData];
        }
        else {
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakself];
            
            
            
        }
        
        ///hide hud
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        
    }];
    
}


-(void)showChatVCForPublicCell:(PFObject *)publicCellObj
{
    C411ChatVC *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
    chatVC.entityType = ChatEntityTypePublicCell;
    chatVC.strEntityId = publicCellObj.objectId;
    chatVC.strEntityName = publicCellObj[kPublicCellNameKey];
    chatVC.entityCreatedAtInMillis = [publicCellObj.createdAt timeIntervalSince1970] * 1000;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:chatVC animated:YES];
    
}

-(void)applyColorOnHeaderview:(UIView *)headerView forSection:(NSInteger)section {
    headerView.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    UILabel *lblSectionName = (UILabel *)[headerView viewWithTag:101];
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    lblSectionName.textColor = primaryTextColor;
    
    UIView *vuSeparator = (UIView *)[headerView viewWithTag:102];
    vuSeparator.backgroundColor = [C411ColorHelper sharedInstance].separatorColor;
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

-(void)refresh:(UIRefreshControl *)refreshControl
{
    [self fetchChatEntities];
    [refreshControl endRefreshing];
    
}


//****************************************************
#pragma mark - UITableViewDatasource and delegate Methods
//****************************************************

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((velocity.y>0) && (!self.noMoreData)) {
        CGSize contentSize = scrollView.contentSize;
        CGSize scrollVSize  = scrollView.bounds.size;
        
        float downloadTriggerPointFromBottom = scrollVSize.height + 100;
        float downloadTriggerPoint              = contentSize.height - downloadTriggerPointFromBottom;
        
        if (targetContentOffset->y>=downloadTriggerPoint) {
            [self fetchMoreJoinedPublicCells];
            
        }
        
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TOTAL_SECTIONS;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_ALERTS) {
        
        return self.arrChatEligibleAlerts.count;
    }
    else if (section == TABLE_SEC_INDEX_OWNED_CELLS) {
        
        return self.arrOwnedPublicCells.count;
    }
    else if (section == TABLE_SEC_INDEX_JOINED_CELLS){
        
        return self.arrJoinedPublicCells.count;
    }
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    NSInteger secIndex = indexPath.section;
    if (secIndex == TABLE_SEC_INDEX_ALERTS) {
        
        static NSString *cellId = @"C411ChatEntityAlertCell";
        C411ChatEntityAlertCell *alertCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (rowIndex < self.arrChatEligibleAlerts.count) {
            
            PFObject *cell411Alert = [self.arrChatEligibleAlerts objectAtIndex:rowIndex];
            NSString *strAlertType = cell411Alert[kCell411AlertAlertTypeKey];
            
            ///This is an alert other than Custom alert
            PFUser *alertIssuedBy = cell411Alert[kCell411AlertIssuedByKey];
            //        NSString *strGravatarEmail = [C411StaticHelper getEmailFromUser:alertIssuedBy];
            
            PFUser *alertForwardedBy = cell411Alert[kCell411AlertForwardedByKey];
            
            static UIImage *placeHolderImage = nil;
            if (!placeHolderImage) {
                
                placeHolderImage = [UIImage imageNamed:@"logo"];
            }
            ///set the default image first, then fetch the gravatar
            alertCell.imgVuAvatar.image = placeHolderImage;
            
            if (alertForwardedBy) {
                
                ///This is an alert forwarded by someone, show the gravatar of the forwardedBy person
                
                //strGravatarEmail = [C411StaticHelper getEmailFromUser:alertForwardedBy];
                [alertCell.imgVuAvatar setAvatarForUser:alertForwardedBy shouldFallbackToGravatar:YES ofSize:alertCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
                
            }
            else{
                
                ///This is an alert issued by a user, show the gravatar of the issuer
                [alertCell.imgVuAvatar setAvatarForUser:alertIssuedBy shouldFallbackToGravatar:YES ofSize:alertCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
                
                
            }
            ///set alert image
            alertCell.strAlertType = strAlertType;
            
            ///Make alert title
            [self tableView:tableView configureCell:alertCell atIndexPath:indexPath];
            
            
            }
            
        return alertCell;

    }
    else if (secIndex == TABLE_SEC_INDEX_OWNED_CELLS) {
        
        if (rowIndex < self.arrOwnedPublicCells.count) {
            
            ///Create and Return cell
            static NSString *publicCellId = @"C411ChatEntityMyPublicCell";
            C411ChatEntityMyPublicCell *myPublicCell = [tableView dequeueReusableCellWithIdentifier:publicCellId];
            
            ///Get Cell object
            PFObject *publicCellObject = [self.arrOwnedPublicCells objectAtIndex:rowIndex];
            
            ///Set Cell name
            myPublicCell.lblCellName.text = publicCellObject[kPublicCellNameKey];
            
            ///Set Cell Image
            
            ///Set verified Image
            /*OLD implementation of verification request handling
             BOOL isVerified = [publicCellObject[kPublicCellIsVerifiedKey]boolValue];
             */
            BOOL isVerified = [publicCellObject[kPublicCellVerificationStatusKey]integerValue] == CellVerificationStatusApproved;
            if (isVerified) {
                
                ///Set verified image
                static UIImage *imgVerified = nil;
                if (!imgVerified) {
                    imgVerified = [UIImage imageNamed:@"ic_verified"];
                }
                
                myPublicCell.imgVuVerified.image = imgVerified;
                myPublicCell.imgVuVerified.layer.borderWidth = 2.0;
                
            }
            else{
                
                ///Remove verified image
                myPublicCell.imgVuVerified.image = nil;
                myPublicCell.imgVuVerified.layer.borderWidth = 0;
                
                
            }
            
            return myPublicCell;
            
        }
        
    }
    else if (secIndex == TABLE_SEC_INDEX_JOINED_CELLS){
        
        ///Create and Return cell
        static NSString *publicCellId = @"C411ChatEntityMyPublicCell";
        C411ChatEntityMyPublicCell *otherPublicCell = [tableView dequeueReusableCellWithIdentifier:publicCellId];
        
        if (rowIndex < self.arrJoinedPublicCells.count) {
            
            
            ///Get Cell object
            PFObject *publicCellObject = [self.arrJoinedPublicCells objectAtIndex:rowIndex];
            
            ///Set Cell name
            otherPublicCell.lblCellName.text = publicCellObject[kPublicCellNameKey];
            
            ///Set cell Image
            
            ///Set verified Image
/*OLD implementation of verification request handling
             BOOL isVerified = [publicCellObject[kPublicCellIsVerifiedKey]boolValue];
*/
            BOOL isVerified = [publicCellObject[kPublicCellVerificationStatusKey]integerValue] == CellVerificationStatusApproved;
            if (isVerified) {
                
                ///Set verified image
                static UIImage *imgVerified = nil;
                if (!imgVerified) {
                    imgVerified = [UIImage imageNamed:@"ic_verified"];
                }
                
                otherPublicCell.imgVuVerified.image = imgVerified;
                otherPublicCell.imgVuVerified.layer.borderWidth = 2.0;
                
                
            }
            else{
                
                ///Remove verified image
                otherPublicCell.imgVuVerified.image = nil;
                otherPublicCell.imgVuVerified.layer.borderWidth = 0;
            }
            
            
            return otherPublicCell;
            
        }
        
    }
    
    
    return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger secIndex = indexPath.section;
    if (secIndex == TABLE_SEC_INDEX_ALERTS) {
        
        return 68.0f;//

    }
    else{
        
        return 62.0f;//

    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    NSInteger secIndex = indexPath.section;
    if (secIndex == TABLE_SEC_INDEX_ALERTS) {
    
        if (rowIndex < self.arrChatEligibleAlerts.count) {
            
            PFObject *selectedCell411Alert = [self.arrChatEligibleAlerts objectAtIndex:rowIndex];
           
            C411ChatVC *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
            chatVC.entityType = ChatEntityTypeAlert;
            chatVC.strEntityId = selectedCell411Alert.objectId;
            chatVC.strEntityName = selectedCell411Alert[kCell411AlertAlertTypeKey];
            chatVC.entityCreatedAtInMillis = [selectedCell411Alert.createdAt timeIntervalSince1970] * 1000;
            UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
            [rootNavC pushViewController:chatVC animated:YES];
            
            ///set can refresh to no, so that it will not refresh the screen if user is coming back
            self.canRefresh = NO;


        }
    }
    else if (secIndex == TABLE_SEC_INDEX_OWNED_CELLS) {
        
        if (rowIndex < self.arrOwnedPublicCells.count){
            
            ///Get the PublicCell object and pass it to the Members screen
            PFObject *myPublicCellObj = [self.arrOwnedPublicCells objectAtIndex:rowIndex];
            
            [self showChatVCForPublicCell:myPublicCellObj];
            
            ///set can refresh to no, so that it will not refresh the screen if user is coming back
            self.canRefresh = NO;
            
            
        }
        
    }
    else if (secIndex == TABLE_SEC_INDEX_JOINED_CELLS){
        
        if (rowIndex <= self.arrJoinedPublicCells.count){
            
            ///Get the PublicCell object and pass it to the Members screen
            PFObject *joinedPublicCellObj = [self.arrJoinedPublicCells objectAtIndex:rowIndex];
            
            [self showChatVCForPublicCell:joinedPublicCellObj];

            ///set can refresh to no, so that it will not refresh the screen if user is coming back
            self.canRefresh = NO;
            
        }
        
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"SectionHeader" owner:self options:nil] lastObject];
    UILabel *lblSectionName = (UILabel *)[headerView viewWithTag:101];
    if (section == TABLE_SEC_INDEX_ALERTS && self.arrChatEligibleAlerts.count > 0) {
        ///Alerts section
        lblSectionName.text = NSLocalizedString(@"ALERTS", nil);
    }
    else if (section == TABLE_SEC_INDEX_OWNED_CELLS && self.arrOwnedPublicCells.count > 0) {
        ///Owned cells section
        lblSectionName.text = NSLocalizedString(@"OWNED CELLS", nil);
    }
    else if (section == TABLE_SEC_INDEX_JOINED_CELLS && self.arrJoinedPublicCells.count > 0){
        ///joined cells sections
        lblSectionName.text = NSLocalizedString(@"JOINED CELLS", nil);
    }
    else{
        return nil;
    }
    ///Apply colors
    [self applyColorOnHeaderview:headerView forSection:section];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_ALERTS && self.arrChatEligibleAlerts.count > 0) {
        ///Alerts section
        return 32.0f;
        
    }
    else if (section == TABLE_SEC_INDEX_OWNED_CELLS && self.arrOwnedPublicCells.count > 0) {
        ///Owned cells section
        return 32.0f;
        
    }
    else if (section == TABLE_SEC_INDEX_JOINED_CELLS && self.arrJoinedPublicCells.count > 0){
        
        ///joined cells sections
        return 32.0f;
    }
    else{
        
        return CGFLOAT_MIN;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == TABLE_SEC_INDEX_JOINED_CELLS  && self.arrJoinedPublicCells.count > 0){
        return 32.0f;
    }
    return CGFLOAT_MIN;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == TABLE_SEC_INDEX_JOINED_CELLS && self.arrJoinedPublicCells.count > 0){
        
        return self.noMoreData ? NSLocalizedString(@"No more Cells to load", nil) : nil;
        
    }
    
    return nil;
}

//****************************************************
#pragma mark - tableView:cellForRowAtIndexPath Helper Methods
//****************************************************

-(void)tableView:(UITableView *)tableView configureCell:(C411ChatEntityAlertCell *)alertCell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < self.arrChatEligibleAlerts.count) {
        
        PFObject *cell411Alert = [self.arrChatEligibleAlerts objectAtIndex:rowIndex];
        NSString *strAlertType = cell411Alert[kCell411AlertAlertTypeKey];
        ///This is an alert other than Custom alert and neither a friend/cell request
        PFUser *alertIssuedBy = cell411Alert[kCell411AlertIssuedByKey];
        
        NSDate *alertIssuedDate = cell411Alert.createdAt;
        alertCell.lblAlertTimestamp.text = [C411StaticHelper getFormattedTimeFromDate:alertIssuedDate withFormat:TimeStampFormatDateAndTime];
        
        ///Create the alert title
        NSString *strIssuerName = cell411Alert[kCell411AlertIssuerFirstNameKey];
        if ([alertIssuedBy.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
            
            ///1.Update issuer name
            strIssuerName = NSLocalizedString(@"I", nil);
            
        }
        
        
        NSMutableAttributedString *attribStrAlertTitle = nil;
        if (strAlertType.length > 0) {
            /*
             NSString *strAlertName = NSLocalizedString(strAlertType, nil);
             if ([strAlertType.lowercaseString isEqualToString:kAlertTypeCopBlocking.lowercaseString]) {
             
             ///Rename Cop Blocking to Police Interaction in UI only
             strAlertName = NSLocalizedString(@"Police Interaction", nil);
             }
             */
            NSString *strAlertName = [C411StaticHelper getLocalizedAlertTypeStringFromString:strAlertType];
            float fontSize = alertCell.lblAlertTitle.font.pointSize;
            NSDictionary *dictMainAttr = @{NSFontAttributeName:[UIFont systemFontOfSize: fontSize],
                                           NSForegroundColorAttributeName:[C411ColorHelper sharedInstance].primaryTextColor};
            NSDictionary *dictSubAttr = @{NSFontAttributeName:[UIFont boldSystemFontOfSize: fontSize]};
            NSRange issuerNameRange = NSMakeRange(0, strIssuerName.length);
            NSRange alertTypeRange = NSMakeRange(issuerNameRange.length + 10, strAlertName.length);
#if APP_CELL411
            attribStrAlertTitle = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 411 alert",nil),strIssuerName,strAlertName] attributes:dictMainAttr];
#elif APP_RO112
            attribStrAlertTitle = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 112 alert",nil),strIssuerName,strAlertName] attributes:dictMainAttr];
            
#else
            attribStrAlertTitle = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ alert",nil),strIssuerName,strAlertName] attributes:dictMainAttr];
            
            
#endif
            
            [attribStrAlertTitle setAttributes:dictSubAttr range:issuerNameRange];
            [attribStrAlertTitle setAttributes:dictSubAttr range:alertTypeRange];
            
            
            PFUser *alertForwardedBy = cell411Alert[kCell411AlertForwardedByKey];
            NSString *strCellName = cell411Alert[kCell411AlertCellNameKey];
            if (alertForwardedBy) {
                
                ///This is an Needy alert forwarded by someone.
                ///append the forwarder Name
                NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:alertForwardedBy[kUserFirstnameKey] andLastName:alertForwardedBy[kUserLastnameKey]];
                NSAttributedString *attribStrForwardedBy = [[NSAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@", forwarded by %@",nil),strFullName]];
                [attribStrAlertTitle appendAttributedString:attribStrForwardedBy];
                
            }
            else if (strCellName.length > 0)
            {
                ///This is a public alert, append cell name
                NSAttributedString *attribStrCellName = [[NSAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@" on %@",nil),strCellName]];
                [attribStrAlertTitle appendAttributedString:attribStrCellName];
            }
            
            
            
        }
        
        
        alertCell.lblAlertTitle.attributedText = attribStrAlertTitle;
        
        
        
    }
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    for (NSInteger index = 0; index < [self numberOfSectionsInTableView:self.tblVuChatEntities]; index++) {
        UIView *sectionHeaderView = [self.tblVuChatEntities headerViewForSection:index];
        [self applyColorOnHeaderview:sectionHeaderView forSection:index];
    }
}

@end
