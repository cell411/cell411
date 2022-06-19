//
//  C411SearchFriendsVC.m
//  cell411
//
//  Created by Milan Agarwal on 29/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411SearchFriendsVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
#import "C411FriendRequestCell.h"
#import "C411AddFriendCell.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "AppDelegate.h"
#import "C411AppDefaults.h"
#import "C411UserProfilePopup.h"
#import "C411ColorHelper.h"

#define PAGE_LIMIT  10

@interface C411SearchFriendsVC ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *tblVuSearchFriends;
@property (nonatomic, strong) PFQuery *searchUsersQuery;
@property (nonatomic, strong) NSMutableArray *arrSearchResults;
//@property (nonatomic, strong) NSMutableArray *arrJoinedOrPendingCells;
@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, strong) UISearchController *searchController;
///Will contain the state of the current friend request state
@property (nonatomic, strong) NSMutableDictionary *dictAddFriendRequestState;


@end

@implementation C411SearchFriendsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setupSearchController];
    [self applyColors];
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
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrSearchResults
{
    if (!_arrSearchResults) {
        
        _arrSearchResults = [NSMutableArray array];
    }
    
    return _arrSearchResults;
}

-(NSMutableDictionary *)dictAddFriendRequestState
{
    if (!_dictAddFriendRequestState) {
        
        _dictAddFriendRequestState = [NSMutableDictionary dictionary];
        
    }
    
    return _dictAddFriendRequestState;
}


//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didMovedAwayFromSearchFriends:) name:kDidMovedAwayFromSearchFriendsNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

-(void)setupSearchController
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.tblVuSearchFriends.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = NO;///setting it to YES will crash on switching to other tab while search bar is first responder
    self.searchController.searchBar.returnKeyType = UIReturnKeyDone;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search by name, phone or email", nil);
    [self.searchController.searchBar sizeToFit];
    
}

-(void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{

    ///Clear the data
    self.arrSearchResults = nil;
    self.noMoreData = NO;
    
    
    ///reload table
    [self.tblVuSearchFriends reloadData];
    
    ///Make new query to fetch results
    [self fetchUsersWithSearchText:searchText];
}

-(void)fetchUsersWithSearchText:(NSString *)strSearchText
{
    
    ///Cancel the previous request
    [self.searchUsersQuery cancel];
   
    ///Hide previous hud if visible
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    

    ///make an array of words by using search string
    NSString *strTrimmedSearchText = [strSearchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (strTrimmedSearchText.length > 0) {
        
        ///show progress hud
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        
        
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
        
        if (strRegex.length > 0) {
            
            ///Prefix carat^ for start with clause
            strRegex = [NSMutableString stringWithFormat:@"^(%@)",strRegex];
        }
        
        NSMutableArray *arrSubqueries = [NSMutableArray array];
        
        ///Make a subquery for search freind by first name
        PFQuery *searchFriendsByFirstnameQuery = [PFUser query];
        [searchFriendsByFirstnameQuery whereKey:kUserFirstnameKey matchesRegex:strRegex modifiers:@"i"];
        [arrSubqueries addObject:searchFriendsByFirstnameQuery];
        
        ///Make a subquery for search freind by Last name
        PFQuery *searchFriendsByLastnameQuery = [PFUser query];
        [searchFriendsByLastnameQuery whereKey:kUserLastnameKey matchesRegex:strRegex modifiers:@"i"];
        [arrSubqueries addObject:searchFriendsByLastnameQuery];
        
        if (arrWords.count == 1 && [C411StaticHelper isValidEmail:strTrimmedSearchText]) {
            ///Search text is a single word with a valid email
            ///Make a subquery for search freind by user name
            PFQuery *searchFriendsByUsernameQuery = [PFUser query];
            [searchFriendsByUsernameQuery whereKey:@"username" equalTo:strTrimmedSearchText.lowercaseString];
            [arrSubqueries addObject:searchFriendsByUsernameQuery];
            
            ///Make a subquery for search freind by email
            PFQuery *searchFriendsByEmailQuery = [PFUser query];
            [searchFriendsByEmailQuery whereKey:@"email" equalTo:strTrimmedSearchText.lowercaseString];
            [arrSubqueries addObject:searchFriendsByEmailQuery];
            
        }
        
        ///search for phone number too if there is a number in the text
        if([strTrimmedSearchText rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound){
            
            ///Check if user is searching for a phone number or not
            NSString *strSearchTextWithoutSpace = [strTrimmedSearchText stringByReplacingOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strTrimmedSearchText.length)];
            NSString *strNumericTextFromSearch = [C411StaticHelper getNumericStringFromString:strTrimmedSearchText];
            if (strSearchTextWithoutSpace.length == strNumericTextFromSearch.length) {
                
                ///Search text contains either digits only or digits with spaces, so search for phone number as well
                ///Make a subquery for search friend by phone number
                PFQuery *searchFriendsByPhoneQuery = [PFUser query];
                
                [searchFriendsByPhoneQuery whereKey:kUserMobileNumberKey equalTo:strNumericTextFromSearch];
                [arrSubqueries addObject:searchFriendsByPhoneQuery];

                
            }
            

        }
        
        self.searchUsersQuery = [PFQuery orQueryWithSubqueries:arrSubqueries];
        //[self.searchUsersQuery whereKey:kUserSpamUsersKey notEqualTo:currentUser];
        PFQuery *spammedByQuery = [[currentUser relationForKey:kUserSpammedByKey] query];
        PFQuery *friendsQuery = [[currentUser relationForKey:kUserFriendsKey] query];
        PFQuery *spammedByUsersAndFriendsQuery = [PFQuery orQueryWithSubqueries:@[spammedByQuery,friendsQuery]];
        [self.searchUsersQuery whereKey:kUserIsDeletedKey notEqualTo:@(1)];
        [self.searchUsersQuery whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:spammedByUsersAndFriendsQuery];
        [self.searchUsersQuery whereKey:@"objectId" notEqualTo:currentUser.objectId];
        //[self.searchUsersQuery whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:];
        PFGeoPoint *myLocation = currentUser[kUserLocationKey];
        [self.searchUsersQuery whereKey:kUserLocationKey  nearGeoPoint:myLocation];
        self.searchUsersQuery.skip = self.arrSearchResults.count;
        self.searchUsersQuery.limit = 10;
        
        __weak typeof(self) weakSelf = self;
        [self.searchUsersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (!error) {
                
                [weakSelf.arrSearchResults addObjectsFromArray:objects];
                
                if (objects.count < PAGE_LIMIT) {
                    
                    weakSelf.noMoreData = YES;
                }
                else{
                    
                    weakSelf.noMoreData = NO;
                }
                
                ///reload tableview
                [weakSelf.tblVuSearchFriends reloadData];
                
            }
            else{
                
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                }
                
            }
            
            ///Hide hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            ///reset ivar holding strong reference of query
            weakSelf.searchUsersQuery = nil;
            
        }];

    }
    

    
}

//****************************************************
#pragma mark - Table View Datasource and Delegate Methods
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
                [self fetchUsersWithSearchText:self.searchController.searchBar.text];
            }
            
        }
        
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
 
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.arrSearchResults.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;

    ///Create a user Row
    static NSString *addFriendCellId = @"C411AddFriendCell";
    
    ///Get Tableview specific cell and user object
    C411AddFriendCell *addFriendCell = [self.tblVuSearchFriends dequeueReusableCellWithIdentifier:addFriendCellId];
    if (rowIndex < self.arrSearchResults.count) {
        
        PFUser *user = [self.arrSearchResults objectAtIndex:rowIndex];;
        addFriendCell.user = user;
        addFriendCell.dictAddFriendRequestState = self.dictAddFriendRequestState;
        addFriendCell.btnAddFriend.tag = rowIndex;
        [addFriendCell.btnAddFriend addTarget:self action:@selector(btnAddFriendTapped:) forControlEvents:UIControlEventTouchUpInside];
        [addFriendCell setupCell];

        
    }
    
    
    return addFriendCell;
    
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 84.0f;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < self.arrSearchResults.count) {
        
        ///Get friend object
        PFUser *friend = [self.arrSearchResults objectAtIndex:rowIndex];
        ///Show user profile popup
        C411UserProfilePopup *vuUserProfilePopup = [[[NSBundle mainBundle] loadNibNamed:@"C411UserProfilePopup" owner:self options:nil] lastObject];
        vuUserProfilePopup.user = friend;
        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
        ///Set view frame
        vuUserProfilePopup.frame = rootVC.view.bounds;
        ///add view
        [rootVC.view addSubview:vuUserProfilePopup];
        [rootVC.view bringSubviewToFront:vuUserProfilePopup];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

//****************************************************
#pragma mark - UISearchResultsUpdating Methods
//****************************************************

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString scope:[[self.searchController.searchBar scopeButtonTitles]objectAtIndex:[self.searchController.searchBar selectedScopeButtonIndex]]];
    
    if(searchString.length == 0){
        
        [C411StaticHelper localizeCancelButtonForSearchBar:searchController.searchBar];

    }
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

-(void)btnAddFriendTapped:(UIButton *)sender
{
    
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.arrSearchResults.count) {
        
        ///Get friend object
        PFUser *friend = [self.arrSearchResults objectAtIndex:rowIndex];

        ///Add the friend request state as sending in dictionary for this user
        NSString *strFriendId = friend.objectId;
        NSNumber *addFRStateNum = self.dictAddFriendRequestState[strFriendId];
        if (!addFRStateNum) {
            ///Friend request is being sent first time so set it's state as sending
            [self.dictAddFriendRequestState setObject:@(AddFriendRequestStateSending) forKey:strFriendId];

        }
        else if([addFRStateNum integerValue] == AddFriendRequestStateSent){
            
            ///Request is already sent and sending it again so set it's state as Resending
            [self.dictAddFriendRequestState setObject:@(AddFriendRequestStateReSending) forKey:strFriendId];
  
            
        }
        
        ///reload the cell
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        [self.tblVuSearchFriends reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        
        ///Send friend request to this user
        __weak typeof(self) weakSelf = self;
        [[C411AppDefaults sharedAppDefaults] sendFriendRequestToUser:friend withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded) {
                
                ///Friend request is sent successfully
//                NSString *strMessage = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"A friend invite was send to", nil), weakSelf.lblFullName.text,NSLocalizedString(@"for approval", nil)];
//                [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
                
                ///Update the friend request state as sent in dictionary for this user
               [weakSelf.dictAddFriendRequestState setObject:@(AddFriendRequestStateSent) forKey:strFriendId];
                

                
                
            }
            else if (error){
                
                ///Some error occured sending friend request to this user
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                }
                
                NSNumber *addFRStateNum = weakSelf.dictAddFriendRequestState[strFriendId];
                if ([addFRStateNum integerValue] == AddFriendRequestStateSending) {

                    ///Remove the friend request state from dictionary to show Add Friend Option again in case of sending friend request for first time
                    [weakSelf.dictAddFriendRequestState removeObjectForKey:strFriendId];
                }
                
                
            }
            else{
                
                ///there is no error but operation doesn't get succeeded, could be the case that user to whom friend request is being sent has spammed current user
                
                NSNumber *addFRStateNum = weakSelf.dictAddFriendRequestState[strFriendId];
                if ([addFRStateNum integerValue] == AddFriendRequestStateSending) {
                    
                    ///Remove the friend request state from dictionary to show Add Friend Option again in case of sending friend request for first time
                    [weakSelf.dictAddFriendRequestState removeObjectForKey:strFriendId];
                }


                
            }
            
            ///reload the cell
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
            [weakSelf.tblVuSearchFriends reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

            
            
        }];

        
    }
    
    
    
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)didMovedAwayFromSearchFriends:(NSNotification *)notification
{
    ///hide the search bar
    self.searchController.active = NO;
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
