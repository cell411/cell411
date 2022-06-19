//
//  C411ExploreCellsVC.m
//  cell411
//
//  Created by Milan Agarwal on 29/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411ExploreCellsVC.h"
#import "ToggleImageView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411OtherPublicCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "C411LocationManager.h"
#import <Parse/Parse.h>
#import "C411PublicCellDetailVC.h"
#import "AppDelegate.h"
#import "C411ChatVC.h"
#import "C411ColorHelper.h"


#define PAGE_LIMIT  10

@interface C411ExploreCellsVC ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *vuHeader;
@property (weak, nonatomic) IBOutlet UITableView *tblVuExploreCells;
@property (strong, nonatomic) IBOutlet UILabel *lblNearby;
@property (weak, nonatomic) IBOutlet ToggleImageView *imgVuRadioNearby;
@property (strong, nonatomic) IBOutlet UILabel *lblExactMatch;
@property (weak, nonatomic) IBOutlet ToggleImageView *imgVuRadioExactMatch;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentRadius;
@property (weak, nonatomic) IBOutlet UISlider *sldrCellVisibilityRadius;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cnsHeaderHeight;
- (IBAction)btnRadioNearbyToggled:(UIButton *)sender;
- (IBAction)btnRadioExactMatchToggled:(UIButton *)sender;
- (IBAction)sldrCellVisibilityRadiusValueChanged:(UISlider *)sender;

@property (nonatomic, strong) PFQuery *fetchPublicCellsQuery;
@property (nonatomic, strong) NSMutableArray *arrOtherPublicCells;
//@property (nonatomic, strong) NSMutableArray *arrJoinedOrPendingCells;
@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, assign,getter=isFetchingJoinedOrPendingCells) BOOL fetchingJoinedOrPendingCells;
@property (nonatomic, assign) BOOL canRefresh;
@property (nonatomic, assign) float headerVuInitialHeight;
@property (nonatomic, strong) UIImageView *navBarHairlineImageView;
@property (nonatomic, assign, getter=shouldFetchPublicCellsOnLocationUpdate) BOOL fetchPublicCellsOnLocationUpdate;
@property (nonatomic, weak) MBProgressHUD *locationRetrievalProgressHud;

@end

@implementation C411ExploreCellsVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarHairlineImageView = [C411StaticHelper findHairlineImageViewUnder:self.navigationController.navigationBar];

    [self configureViews];
    
    // Do any additional setup after loading the view.
    [self initializeData];
    
    [self registerForNotifications];
    
    
//    ///set can refresh to Yes initially
//    self.canRefresh = YES;
    
//    
//    ///Add pull to refresh control
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
//    [self.tblVuExploreCells addSubview:refreshControl];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self unregisterFromNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navBarHairlineImageView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    if (self.canRefresh) {
        
        [self refreshViews];
    }
    else{
        ///Update it to YES for next time refresh
        self.canRefresh = YES;
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    self.navBarHairlineImageView.hidden = NO;
    [super viewWillDisappear:animated];
    
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


-(NSMutableArray *)arrOtherPublicCells
{
    if (!_arrOtherPublicCells) {
        _arrOtherPublicCells = [NSMutableArray array];
    }
    
    return _arrOtherPublicCells;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///Set title
    //[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = NSLocalizedString(@"Explore Cells", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    
    self.searchBar.returnKeyType = UIReturnKeyDone;
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    [C411StaticHelper localizeCancelButtonForSearchBar:self.searchBar];
    
    //self.searchBar.barTintColor = [UIColor clearColor];
    
    for (UIView *subview in [[self.searchBar.subviews lastObject] subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
        
    }

     [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
   
    ///set secondary colors on slider
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    
    self.sldrCellVisibilityRadius.minimumTrackTintColor = secondaryColor;
    self.sldrCellVisibilityRadius.maximumTrackTintColor = secondaryColor;
    self.sldrCellVisibilityRadius.thumbTintColor = secondaryColor;
    
    ///Set primary color on header view
    self.vuHeader.backgroundColor = self.navigationController.navigationBar.barTintColor;

    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.tintColor = [UIColor whiteColor];
    
    ///Set primaryBGTextColor
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblNearby.textColor = primaryBGTextColor;
    self.lblExactMatch.textColor = primaryBGTextColor;
    self.lblCurrentRadius.textColor = primaryBGTextColor;
    
}

-(void)localizeSearchCancelButton
{
    self.searchBar.showsCancelButton = YES;
    UIButton *cancelButton;
    UIView *topView = self.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        //Set the new title of the cancel button
        NSString *localizedCancelText = NSLocalizedString(@"Cancel", nil);
        [cancelButton setTitle:localizedCancelText forState:UIControlStateNormal];
    }
}


-(void)initializeData
{
    
    self.imgVuRadioNearby.selected = YES;
    self.headerVuInitialHeight = self.cnsHeaderHeight.constant;
    
    ///Get the current public cell visibility radius, which will always be saved in miles
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float publicCellVisibilityRadius = [[defaults objectForKey:kPublicCellVisibilityRadius]floatValue];
    
    ///Get metric chosen by user
    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
    
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///set values in kms
        ///convert public cell visibility radius to km
        publicCellVisibilityRadius = publicCellVisibilityRadius * MILES_TO_KM;
        NSString *strMetric = (publicCellVisibilityRadius <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
        
        self.lblCurrentRadius.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Radius %@ %@", nil),[C411StaticHelper getDecimalStringFromNumber:@(publicCellVisibilityRadius) uptoDecimalPlaces:2],strMetric];
        
        self.sldrCellVisibilityRadius.minimumValue = PUBLIC_CELL_VISIBILITY_MIN_RADIUS * MILES_TO_KM;
        self.sldrCellVisibilityRadius.maximumValue = PUBLIC_CELL_VISIBILITY_MAX_RADIUS * MILES_TO_KM;
        self.sldrCellVisibilityRadius.value = publicCellVisibilityRadius;
    }
    else{
        
        ///Set values in miles
        NSString *strMetric = (publicCellVisibilityRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
        self.lblCurrentRadius.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Radius %@ %@", nil),[C411StaticHelper getDecimalStringFromNumber:@(publicCellVisibilityRadius) uptoDecimalPlaces:2],strMetric];
        self.sldrCellVisibilityRadius.minimumValue = PUBLIC_CELL_VISIBILITY_MIN_RADIUS;
        self.sldrCellVisibilityRadius.maximumValue = PUBLIC_CELL_VISIBILITY_MAX_RADIUS;
        self.sldrCellVisibilityRadius.value = publicCellVisibilityRadius;
        
    }

    if([[C411LocationManager sharedInstance]isLocationAccessAllowed]){
        ///Check if current location is updated or not, if not then wait for location update before showing
        if([[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:NO]){
            ///Current location is available, fetch public cells
            [self refreshViews];
        }
        else{
            ///Current location is not available, so wait for location update to fetch public cells
            [self fetchPublicCellsOnLocationUpdate];
        }
    }
    else{
        ///Location access is denied, show enable location popup
        __weak typeof(self) weakSelf = self;
        [[C411LocationManager sharedInstance]showEnableLocationPopupWithCustomMessagePrefix:nil cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
            ///Do nothing on cancel
            ///Show using old location toast
            [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Using last known location.", nil)];
            [weakSelf refreshViews];
            
        } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
            
            [weakSelf fetchPublicCellsOnLocationUpdate];
        }];
    }

}


-(void)refreshViews
{
    
    self.arrOtherPublicCells = nil;
    self.noMoreData = NO;
    [self.tblVuExploreCells reloadData];

    
//    if (self.publicCellsDelegate.arrJoinedOrPendingCells != nil)
//    {
//        ///joined or pending cells have been fetched, Get the user location
//        
//        [self fetchOtherPublicCells];
//        
//        
//    }
//    else{
    
        ///fetch the pending cells from server first
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self) weakSelf = self;
        
        
        [self.publicCellsDelegate getPendingOrJoinedPublicCellsWithCompletion:^(NSArray * __nullable objects, NSError * __nullable error) {
            
            if (!error) {
                
                ///joined or pending cells have been fetched,fetch other public cells
                [weakSelf fetchOtherPublicCells];
                
                
            }
            else{
                
                ///show error message
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                
            }
            ///hide Hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            
        }];
        
//    }


}


-(void)fetchOtherPublicCells
{
    ///Cancel previous query request
    [self.fetchPublicCellsQuery cancel];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    ///Make a new query
    self.fetchPublicCellsQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
    [self.fetchPublicCellsQuery whereKey:kPublicCellCreatedByKey notEqualTo:[AppDelegate getLoggedInUser]];
    ///Get a trimmed search text
    NSString *strTrimmedSearchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (self.imgVuRadioNearby.isSelected) {
        ///Nearby search
        ///Get the current public cell visibility radius, which will always be saved in miles
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        float publicCellVisibilityRadius = [[defaults objectForKey:kPublicCellVisibilityRadius]floatValue];
        
        PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES]];
        [self.fetchPublicCellsQuery whereKey:kPublicCellGeoTagKey nearGeoPoint:userGeoPoint withinMiles:publicCellVisibilityRadius];
        //NSString *strSearchText = self.searchBar.text;
        if (strTrimmedSearchText.length > 0) {
            
            ///make an array of words by using search string
            NSArray *arrWords = [strTrimmedSearchText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            ///merge the array into a regex string by joining components with |
            NSMutableString *strRegex = [NSMutableString stringWithString:@""];
            
            for (NSString *strWord in arrWords) {
                
                if (strWord.length > 0) {
                    
                    if (strRegex.length > 0) {
                        
                        ///append Pipe
                        [strRegex appendString:@"|"];
                    }
                    
                    ///append word
                    [strRegex appendString:strWord];
                    
                }
            }

           // [self.fetchPublicCellsQuery whereKey:kPublicCellNameKey containsString:strSearchText];
            [self.fetchPublicCellsQuery whereKey:kPublicCellNameKey matchesRegex:strRegex modifiers:@"i"];
        }
        
    }
    else{
        ///Exact match search
        strTrimmedSearchText = strTrimmedSearchText ? strTrimmedSearchText : @"";
        ///append ^ for starts with and $ for ends with for exact match of a string in case insensitive manner
        NSString *strRegex = [NSString stringWithFormat:@"^%@$",strTrimmedSearchText];
         [self.fetchPublicCellsQuery whereKey:kPublicCellNameKey matchesRegex:strRegex modifiers:@"i"];
        
        //[self.fetchPublicCellsQuery whereKey:kPublicCellNameKey equalTo:strTrimmedSearchText];
    }
    [self.fetchPublicCellsQuery includeKey:kPublicCellCreatedByKey];
    self.fetchPublicCellsQuery.skip = self.arrOtherPublicCells.count;
    self.fetchPublicCellsQuery.limit = 10;
    [self.fetchPublicCellsQuery orderByDescending:kPublicCellTotalMembersKey];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.fetchPublicCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        
        
        if (!error) {
            
            [weakSelf.arrOtherPublicCells addObjectsFromArray:objects];
            
            if (objects.count < PAGE_LIMIT) {
                
                self.noMoreData = YES;
            }
            else{
                
                self.noMoreData = NO;
            }
            
            if (weakSelf.publicCellsDelegate.arrJoinedOrPendingCells != nil) {
                
                ///reload tableview
                [weakSelf.tblVuExploreCells reloadData];
                
                ///Hide hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
            }
            else if (!weakSelf.isFetchingJoinedOrPendingCells){
                
                ///set the flag
                weakSelf.fetchingJoinedOrPendingCells = YES;
                
                ///fetch joined or pending cells first
                [weakSelf.publicCellsDelegate getPendingOrJoinedPublicCellsWithCompletion:^(NSArray * objects, NSError * error) {
                    
                    ///update the fetching flag
                    weakSelf.fetchingJoinedOrPendingCells = NO;
                    
                    if (!error) {
                        
                        ///reload tableview
                        [weakSelf.tblVuExploreCells reloadData];
                        
                        
                    }
                    else {
                        
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                        
                        
                    }
                    
                    ///Hide hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                }];
            }
            
        }
        else {
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
            ///Hide hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
        }
        
        ///reset ivar holding strong reference of query
        weakSelf.fetchPublicCellsQuery = nil;
        
        
    }];
    
}

-(NSString *)getJoinOrLeaveStatusTitleForPublicCell:(PFObject *)publicCellObject
{
    NSString *strStatus = NSLocalizedString(@"JOIN", nil);
    for (PFObject *cell411Alert in self.publicCellsDelegate.arrJoinedOrPendingCells) {
        
        NSString *cellObjectId = cell411Alert[kCell411AlertCellIdKey];
        if ([cellObjectId isEqualToString:publicCellObject.objectId]) {
            
            ///Found, either user is member of this cell or his request is pending
            NSString *strJoinStatus = cell411Alert[kCell411AlertStatusKey];
            if ([strJoinStatus isEqualToString:kAlertStatusApproved]) {
                
                ///User is already a member of this Cell, set text as LEAVE in status so that user can leave the cell
                strStatus = NSLocalizedString(@"LEAVE", nil);
                
            }
            else if ([strJoinStatus isEqualToString:kAlertStatusPending]) {
                
                ///User is already a member of this Cell, set text as LEAVE in status so that user can leave the cell
                strStatus = NSLocalizedString(@"PENDING", nil);
                
                
            }
            
            break;
        }
        
    }
    
    return strStatus;
}

-(CellMembershipStatus)getCellMembershipStatusForCell:(PFObject *)publicCellObject
{
    CellMembershipStatus membershipStatus = CellMembershipStatusNotAMember;
    for (PFObject *cell411Alert in self.publicCellsDelegate.arrJoinedOrPendingCells) {
        
        NSString *cellObjectId = cell411Alert[kCell411AlertCellIdKey];
        if ([cellObjectId isEqualToString:publicCellObject.objectId]) {
            
            ///Found, either user is member of this cell or his request is pending
            NSString *strJoinStatus = cell411Alert[kCell411AlertStatusKey];
            if ([strJoinStatus isEqualToString:kAlertStatusApproved]) {
                
                ///User is already a member of this Cell
                membershipStatus = CellMembershipStatusIsAMember;
            }
            else if ([strJoinStatus isEqualToString:kAlertStatusPending]) {
                
                ///User has sent a cell join request but it's still to be approved
                membershipStatus = CellMembershipStatusPendingApproval;
                
                
            }
            
            break;
        }
        
    }

    
    return membershipStatus;
}

-(void)registerForNotifications
{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellJoined:) name:kPublicCellJoinedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellLeaved:) name:kPublicCellLeavedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publicCellDoesNotExist:) name:kPublicCellDoesNotExistNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPublicCellsListing:) name:kRefreshPublicCellListingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)refreshPublicCellObject:(PFObject *)publicCellObject
{
    NSInteger publicCellObjectIndex = -1;
    for (NSInteger index = 0; index < self.arrOtherPublicCells.count; index++) {
        
        PFObject *publicCell = [self.arrOtherPublicCells objectAtIndex:index];
        
        if ([publicCell.objectId isEqualToString:publicCellObject.objectId]) {
            ///found the corresponding old public cell
            publicCellObjectIndex = index;
            break;
            
        }
        
    }
    
    if (publicCellObjectIndex != -1 && publicCellObjectIndex < self.arrOtherPublicCells.count) {
        
        ///refresh the object
        [self.arrOtherPublicCells replaceObjectAtIndex:publicCellObjectIndex withObject:publicCellObject];
        
    }
}

-(void)fetchPublicCellsOnLocationUpdate
{
    ///Show progress hud to let user wait until his/her location is retrieved
    self.locationRetrievalProgressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.locationRetrievalProgressHud.labelText = NSLocalizedString(@"Retrieving Location", nil);
    self.locationRetrievalProgressHud.removeFromSuperViewOnHide = YES;
    
    ///Set ivar to send alert on location update
    self.fetchPublicCellsOnLocationUpdate = YES;
    
    ///Add location updated observer to send out the alert
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationManagerDidUpdateLocation:) name:kLocationUpdatedNotification object:nil];
    
    ///Add observer for app coming to foreground
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnRadioNearbyToggled:(UIButton *)sender {
    
    if (!self.imgVuRadioNearby.isSelected) {
        
        ///Enable Nearby
        self.imgVuRadioNearby.selected = YES;
        
        
        ///Disable Exact Match
        self.imgVuRadioExactMatch.selected = NO;
        
        ///remove data
        self.arrOtherPublicCells = nil;
        self.noMoreData = NO;
        [self.tblVuExploreCells reloadData];
        
        ///Fetch the Public Cells again
        [self fetchOtherPublicCells];
        
    }
}

- (IBAction)btnRadioExactMatchToggled:(UIButton *)sender {
    
    if (!self.imgVuRadioExactMatch.isSelected) {
        
        ///Enable Exact Match
        self.imgVuRadioExactMatch.selected = YES;
        
        
        ///Disable Nearby
        self.imgVuRadioNearby.selected = NO;
        
        ///remove data
        self.arrOtherPublicCells = nil;
        self.noMoreData = NO;
        [self.tblVuExploreCells reloadData];
        
        ///Fetch the Public Cells again
        [self fetchOtherPublicCells];
    }
    
}

- (IBAction)sldrCellVisibilityRadiusValueChanged:(UISlider *)sender {
    
    float cellVisibilityRadius = (int)sender.value;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ///Get metric chosen by user
    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
    
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///set values in kms
        ///Public cell visibility radius we get is in km
        NSString *strMetric = (cellVisibilityRadius <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
        self.lblCurrentRadius.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Radius %@ %@", nil),[C411StaticHelper getDecimalStringFromNumber:@(cellVisibilityRadius) uptoDecimalPlaces:2],strMetric];
        
        
        ///Convert to miles to be saved in user defaults
        cellVisibilityRadius = cellVisibilityRadius / MILES_TO_KM;
        
    }
    else{
        
        ///Set values in miles
        ///Patrol mode radius we get is in miles
        NSString *strMetric = (cellVisibilityRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
        self.lblCurrentRadius.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Radius %@ %@", nil),[C411StaticHelper getDecimalStringFromNumber:@(cellVisibilityRadius) uptoDecimalPlaces:2],strMetric];
        
    }

    if (cellVisibilityRadius >= PUBLIC_CELL_VISIBILITY_MIN_RADIUS && cellVisibilityRadius <= PUBLIC_CELL_VISIBILITY_MAX_RADIUS) {
        
        ///Update miles in defaults
        [defaults setObject:@(cellVisibilityRadius) forKey:kPublicCellVisibilityRadius];
        [defaults synchronize];
        
    }
    

}

-(void)joinOrLeaveCellTapped:(UIButton *)sender
{
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.arrOtherPublicCells.count) {
        
        PFObject *publicCellObj = [self.arrOtherPublicCells objectAtIndex:rowIndex];
        NSString *strStatus = [sender titleForState:UIControlStateNormal];
        
        if ([strStatus isEqualToString:NSLocalizedString(@"JOIN", nil)]) {
            
            ///Post notification to join public cell
            [[NSNotificationCenter defaultCenter]postNotificationName:kJoinPublicCellNotification object:publicCellObj];
            
        }
        else if ([strStatus isEqualToString:NSLocalizedString(@"LEAVE", nil)]) {
            
            ///Post notification to leave public cell
            [[NSNotificationCenter defaultCenter]postNotificationName:kLeavePublicCellNotification object:publicCellObj];
        }
        
    }
}

-(void)btnChatTapped:(UIButton *)sender
{
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.arrOtherPublicCells.count) {
        
        PFObject *publicCellObj = [self.arrOtherPublicCells objectAtIndex:rowIndex];
        C411ChatVC *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
        chatVC.entityType = ChatEntityTypePublicCell;
        chatVC.strEntityId = publicCellObj.objectId;
        chatVC.strEntityName = publicCellObj[kPublicCellNameKey];
        chatVC.entityCreatedAtInMillis = [publicCellObj.createdAt timeIntervalSince1970] * 1000;
        UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
        [rootNavC pushViewController:chatVC animated:YES];

        
    }
}


-(void)refresh:(UIRefreshControl *)refreshControl
{
    [self refreshViews];
    [refreshControl endRefreshing];
    
}


//****************************************************
#pragma mark - UITableViewDataSource and Delegate Methods
//****************************************************

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ((velocity.y>0) && (!self.noMoreData)) {
        CGSize contentSize = scrollView.contentSize;
        CGSize scrollVSize  = scrollView.bounds.size;
        
        float downloadTriggerPointFromBottom = scrollVSize.height + 100;
        float downloadTriggerPoint              = contentSize.height - downloadTriggerPointFromBottom;
        
        if (targetContentOffset->y>=downloadTriggerPoint) {
            {
                [self fetchOtherPublicCells];
            }
            
        }
        
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrOtherPublicCells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < self.arrOtherPublicCells.count) {
        
        ///Create and Return cell
        static NSString *publicCellId = @"C411OtherPublicCell";
        C411OtherPublicCell *otherPublicCell = [tableView dequeueReusableCellWithIdentifier:publicCellId];
        
        ///Get Cell object
        PFObject *publicCellObject = [self.arrOtherPublicCells objectAtIndex:rowIndex];
        
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
        
        ///Set status
        NSString *strStatus = [self getJoinOrLeaveStatusTitleForPublicCell:publicCellObject];
        otherPublicCell.strStatus = strStatus;
        
        
        ///Set title on button
        [otherPublicCell.btnJoinStatus setTitle:strStatus forState:UIControlStateNormal];
        otherPublicCell.btnJoinStatus.tag = indexPath.row;
        [otherPublicCell.btnJoinStatus addTarget:self action:@selector(joinOrLeaveCellTapped:) forControlEvents:UIControlEventTouchUpInside];

#if CHAT_ENABLED
       
        ///set target on chat button
        otherPublicCell.btnChat.tag = rowIndex;
        [otherPublicCell.btnChat addTarget:self action:@selector(btnChatTapped:) forControlEvents:UIControlEventTouchUpInside];

#else
        otherPublicCell.btnChat.hidden = YES;
#endif

        
        
        return otherPublicCell;
        
    }
    
    return nil;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex <= self.arrOtherPublicCells.count){
        
        ///Get the PublicCell object and pass it to the Members screen
        PFObject *otherPublicCellObj = [self.arrOtherPublicCells objectAtIndex:rowIndex];
        C411PublicCellDetailVC *publicCellDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PublicCellDetailVC"];
        publicCellDetailVC.publicCellObj = otherPublicCellObj;
        publicCellDetailVC.owner = NO;

        /*
        NSString *strBarBtnRightTitle = nil;
        NSString *strStatus = [self getJoinOrLeaveStatusTitleForPublicCell:otherPublicCellObj];
        
        if ([strStatus isEqualToString:NSLocalizedString(@"JOIN", nil)]) {
            
            ///user is not the member of this Cell
            strBarBtnRightTitle = NSLocalizedString(@"Join this Cell", nil);
            
        }
        else if ([strStatus isEqualToString:NSLocalizedString(@"LEAVE", nil)]){
            
            ///user is not the member of this Cell
            strBarBtnRightTitle = NSLocalizedString(@"Leave this Cell", nil);
            
        }
        publicCellDetailVC.strBarBtnRightTitle = strBarBtnRightTitle;
*/
        
        ///Set membership status in next runloop
        __weak typeof(self) weakSelf = self;
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            publicCellDetailVC.cellMembershipStatus = [weakSelf getCellMembershipStatusForCell:otherPublicCellObj];
            
        }];
        
        
        
        [self.navigationController pushViewController:publicCellDetailVC animated:YES];
       
        ///set can refresh to no, so that it will not refresh the screen if user is coming back
        self.canRefresh = NO;

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(self.arrOtherPublicCells.count > 0){
        return 32.0f;
    }
    return CGFLOAT_MIN;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(self.arrOtherPublicCells.count > 0){
      
        return self.noMoreData ? NSLocalizedString(@"No more Cells to load", nil) : nil;

    }
    
    return nil;
}

//****************************************************
#pragma mark - UIScrollViewDelegate Methods
//****************************************************

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    static CGFloat previousOffset;
    CGFloat yOffset = scrollView.contentOffset.y;

    float headerHeight = self.cnsHeaderHeight.constant + (previousOffset - yOffset);
    previousOffset = scrollView.contentOffset.y;
    self.cnsHeaderHeight.constant = headerHeight;
    
    if (self.cnsHeaderHeight.constant > self.headerVuInitialHeight) {
        
        self.cnsHeaderHeight.constant = self.headerVuInitialHeight;
    }
    else if (self.cnsHeaderHeight.constant < 0) {
        
        self.cnsHeaderHeight.constant = 0;
    }

    return;
     */
    if(scrollView.contentSize.height > self.tblVuExploreCells.bounds.size.height){
        
        ///Expand/Collapse header only if there is a content beyond the screen
        float yOffset = scrollView.contentOffset.y;
        
        if (yOffset < 0  && self.cnsHeaderHeight.constant < self.headerVuInitialHeight) {
            
            self.cnsHeaderHeight.constant += fabsf(yOffset);
            
            if (self.cnsHeaderHeight.constant > self.headerVuInitialHeight) {
                
                self.cnsHeaderHeight.constant = self.headerVuInitialHeight;
            }
        }
        else if(yOffset > 0 && self.cnsHeaderHeight.constant > 0){
            
            self.cnsHeaderHeight.constant -= fabsf(yOffset/100);
            
            if (self.cnsHeaderHeight.constant < 0) {
                
                self.cnsHeaderHeight.constant = 0;
            }
            
            //NSLog(@"Offset(%@)",NSStringFromCGPoint(scrollView.contentOffset));
        }

    }
    
}


-(void)animateHeader
{
    self.cnsHeaderHeight.constant = self.headerVuInitialHeight;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.view layoutIfNeeded];
        
    } completion:NULL];
    
}

//****************************************************
#pragma mark - UISearchbarDelegate Methods
//****************************************************

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.arrOtherPublicCells = nil;
    [self.tblVuExploreCells reloadData];
    [self fetchOtherPublicCells];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar resignFirstResponder];
    
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)publicCellJoined:(NSNotification *)notif
{
    PFObject *pendingCell411Alert = notif.object;
    [self.publicCellsDelegate addObjectToPendingOrJoinedCellsArray:pendingCell411Alert];
    
    ///replace the public cell object with the new refreshed one
    PFObject *refreshedPublicCellObj = [notif.userInfo objectForKey:kRefreshedPublicCellKey];
    
    ///replace the public cell object from the array
    [self refreshPublicCellObject:refreshedPublicCellObj];
    
    [self.tblVuExploreCells reloadData];
}

-(void)publicCellLeaved:(NSNotification *)notif
{
    ///1.remove the Cell411Alert object from the arrJoinedOrPendingCells
    PFObject *publicCellObj = notif.object;
    
    ///replace the public cell object from the array
    [self refreshPublicCellObject:publicCellObj];
    
    ///Reload table
    [self.tblVuExploreCells reloadData];
}

-(void)publicCellDoesNotExist:(NSNotification *)notif
{
    ///remove the public cell object from the list
    NSString *strDeletedPublicCellObjId = notif.object;
    
    NSInteger publicCellObjectIndex = -1;
    for (NSInteger index = 0; index < self.arrOtherPublicCells.count; index++) {
        
        PFObject *publicCell = [self.arrOtherPublicCells objectAtIndex:index];
        
        if ([publicCell.objectId isEqualToString:strDeletedPublicCellObjId]) {
            ///found the corresponding deleted public cell
            publicCellObjectIndex = index;
            break;
            
        }
        
    }
    
    if (publicCellObjectIndex != -1 && publicCellObjectIndex < self.arrOtherPublicCells.count) {
        
        ///refresh the object
        [self.arrOtherPublicCells removeObjectAtIndex:publicCellObjectIndex];
        
    }
    
    ///refresh the table
    [self.tblVuExploreCells reloadData];
}


-(void)refreshPublicCellsListing:(NSNotification *)notif
{
    [self refreshViews];
}

-(void)locationManagerDidUpdateLocation:(NSNotification *)notif
{
    if(self.shouldFetchPublicCellsOnLocationUpdate){
        ///Set this flag to no to avoid sending multile alerts
        self.fetchPublicCellsOnLocationUpdate = NO;
        
        ///remove the notification observer
        [[NSNotificationCenter defaultCenter]removeObserver:self name:kLocationUpdatedNotification object:nil];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        
        ///Remove the progress hud
        [self.locationRetrievalProgressHud hide:YES];
        self.locationRetrievalProgressHud = nil;
        
        ///fetch the public cells now
        [self refreshViews];
    }
}

-(void)cell411AppWillEnterForeground:(NSNotification *)notif
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.shouldFetchPublicCellsOnLocationUpdate
            && (![[C411LocationManager sharedInstance] isLocationAccessAllowed])) {
            ///Reset the public cells fetching flag
            weakSelf.fetchPublicCellsOnLocationUpdate = NO;
            
            ///remove the notification observer
            [[NSNotificationCenter defaultCenter]removeObserver:weakSelf name:kLocationUpdatedNotification object:nil];
            [[NSNotificationCenter defaultCenter]removeObserver:weakSelf name:UIApplicationWillEnterForegroundNotification object:nil];
            
            ///Remove the progress hud
            [weakSelf.locationRetrievalProgressHud hide:YES];
            weakSelf.locationRetrievalProgressHud = nil;
            
            ///Show cannot send alert toast
            [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Using last known location.", nil)];
            
            ///fetch the public cells now with old location
            [weakSelf refreshViews];
        }
        
    });
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
