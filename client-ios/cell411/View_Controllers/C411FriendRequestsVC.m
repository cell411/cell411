//
//  C411FriendRequestsVC.m
//  cell411
//
//  Created by Milan Agarwal on 29/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411FriendRequestsVC.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
#import "C411FriendRequestCell.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "AppDelegate.h"
#import "C411AppDefaults.h"
#import "C411UserProfilePopup.h"
#import "C411ColorHelper.h"

#define PAGE_LIMIT  10

@interface C411FriendRequestsVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblVuFriendRequests;
@property (strong, nonatomic) IBOutlet UIView *vuStickyNote;
@property (strong, nonatomic) IBOutlet UILabel *lblStickyNoteText;
@property (nonatomic, strong) NSMutableArray *arrFriendRequests;
@property (nonatomic, weak) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, strong) NSMutableDictionary *dictPendingActions;

@end

@implementation C411FriendRequestsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    ///Add pull to refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblVuFriendRequests addSubview:refreshControl];
    
    ///save a weak reference in ivar
    self.refreshControl = refreshControl;
    
    ///Fetch the friend request
    [self fetchFriendRequestsAndInvites];
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

-(NSMutableArray *)arrFriendRequests
{
    if (!_arrFriendRequests) {
        
        _arrFriendRequests = [NSMutableArray array];
    }
    
    return _arrFriendRequests;
}

-(NSMutableDictionary *)dictPendingActions
{
    if (!_dictPendingActions) {
        
        _dictPendingActions = [NSMutableDictionary dictionary];
        
    }
    
    return _dictPendingActions;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************
-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set disabled text color
    self.lblStickyNoteText.textColor = [C411ColorHelper sharedInstance].disabledTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)fetchFriendRequestsAndInvites
{
    ///Create a query to fetch FRIEND_REQUEST/FRIEND_INVITE alerts
    ///for email users
    if (!self.refreshControl.isRefreshing) {
        
        ///Show the progress hud as the call is made either for pagination or loading data first time and not via pull to refresh control
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    }
    
    PFQuery *fetchFriendReqQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    
    if ([currentUser.username respondsToSelector:@selector(lowercaseString)]) {
        
        [fetchFriendReqQuery whereKey:kCell411AlertToKey equalTo:currentUser.username.lowercaseString];
        
    }
    else{
        
    #warning Milan->: Some how we are getting username as null which is crashing the app calling lowercaseString method on it
        // NSLog(@"%@",currentUser.username);
        ///fetch the current user
        [currentUser fetchIfNeeded];
        [fetchFriendReqQuery whereKey:kCell411AlertToKey equalTo:currentUser.username];
        
    }
    [fetchFriendReqQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite]];
    [fetchFriendReqQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
    
    NSMutableArray *arrSubQueries = [NSMutableArray array];
    
    if ([C411StaticHelper getSignUpTypeOfUser:currentUser] == SignUpTypeFacebook) {
        
        ///Create a query to fetch FRIEND_REQUEST/FRIEND_INVITE alerts for Facebook users
        
        ///1. update query to retrieve friend request, friend invite using username(without lowercase string)
        ///clear reference of first query
        fetchFriendReqQuery = nil;
        
        
        fetchFriendReqQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchFriendReqQuery whereKey:kCell411AlertToKey equalTo:currentUser.username];
        [fetchFriendReqQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite]];
        [fetchFriendReqQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
       
        ///make sub queries if facebook user has email to check for email also
        NSString *strCurrentUserEmail = [C411StaticHelper getEmailFromUser:currentUser];
        strCurrentUserEmail = [strCurrentUserEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (strCurrentUserEmail.length > 0) {
            
            ///1. get reference of first query
            PFQuery *fetchFriendReqWithUsernameSubQuery = fetchFriendReqQuery;
            ///clear fetchFriendReqQuery
            fetchFriendReqQuery = nil;
            
            ///2. Make another sub query to look for current user email as well, as user email is entered while sending friend request or friend invite from Invite Contacts screen.
            
            PFQuery *fetchFriendReqWithEmailSubQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertToKey equalTo:strCurrentUserEmail.lowercaseString];
            [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite]];
            [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
            
            ///or query with sub queries
            //fetchFriendReqQuery = [PFQuery orQueryWithSubqueries:@[fetchFriendReqWithUsernameSubQuery,fetchFriendReqWithEmailSubQuery]];
            
            ///Add queries to subqueries
            [arrSubQueries addObject:fetchFriendReqWithUsernameSubQuery];
            [arrSubQueries addObject:fetchFriendReqWithEmailSubQuery];
            
        }
        
    }

#if PHONE_VERIFICATION_ENABLED
    ///Check if mobile number of current user is available and is verified or not
    NSString *strContactNumber = currentUser[kUserMobileNumberKey];
    strContactNumber = [C411StaticHelper getNumericStringFromString:strContactNumber];
    BOOL isPhoneVerified = [currentUser[kUserPhoneVerifiedKey]boolValue];
    if ((strContactNumber.length > 0) && isPhoneVerified) {
        
        ///make a subquery to fetch FR/FI on this number
        PFQuery *fetchFriendReqWithPhoneNumberSubQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertToKey equalTo:strContactNumber];
        [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite]];
        [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
        
        if (arrSubQueries.count > 0) {
            
            ///Append this subquery only to array
            [arrSubQueries addObject:fetchFriendReqWithPhoneNumberSubQuery];
        }
        else{
            
            ///Append username query and phone query to array
            [arrSubQueries addObject:fetchFriendReqQuery];
            [arrSubQueries addObject:fetchFriendReqWithPhoneNumberSubQuery];

        }
        
    }
#endif
    
    if (arrSubQueries.count > 0) {
        
        ///Make a new fetchFriendReqQuery by using subqueries
        fetchFriendReqQuery = [PFQuery orQueryWithSubqueries:arrSubQueries];
    }
    
    
    ///2.Set max limit
    fetchFriendReqQuery.limit = PAGE_LIMIT;
    if (self.refreshControl.isRefreshing) {
        
        ///set the skip offset to 0 as we are refreshing the list
        fetchFriendReqQuery.skip = 0;
    }
    else{
        
        ///set the skip offset the array count
        fetchFriendReqQuery.skip = self.arrFriendRequests.count;
        
    }
    
    ///3.finally sort it with the most recent one first
    [fetchFriendReqQuery orderByDescending:@"createdAt"];
    
    ///Include the issuedBy person object as well
    [fetchFriendReqQuery includeKey:kCell411AlertIssuedByKey];
    
    
    __weak typeof(self) weakSelf = self;
    ///fetch the list of alerts from Cell411Alerts table
    [fetchFriendReqQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (!error) {
            
            ///Control pagination
            if (objects.count < PAGE_LIMIT) {
                
                weakSelf.noMoreData = YES;
            }
            else{
                
                weakSelf.noMoreData = NO;
            }

            ///filter the objects to remove invalid alerts
            NSArray *arrFilteredAlerts = [C411StaticHelper alertsArrayByRemovingInvalidObjectsFromArray:objects isForwardedAlert:NO];
            
            ///update the friend request array
            if (weakSelf.refreshControl.isRefreshing) {
            
                ///Clear the old data
                weakSelf.arrFriendRequests = nil;
            }
            
            ///Iterate the Filtered array and put the unique objects in the friend request array
            for (PFObject *friendRequest in arrFilteredAlerts) {
                
                PFUser *issuedBy = friendRequest[kCell411AlertIssuedByKey];
                if ([C411StaticHelper isUserDeleted:issuedBy]) {
                    ///Don't add requests from the deleted users
                    continue;
                }
                BOOL reqExist = NO;
                
                ///match the object id with the existing one and ignore it if it's already there
                for (PFObject *visibleFR in weakSelf.arrFriendRequests) {
                    
                    PFUser *visibleRequestIssuer = visibleFR[kCell411AlertIssuedByKey];
                    if ([issuedBy.objectId isEqualToString:visibleRequestIssuer.objectId]) {
                        
                        ///there is already a friend request by the same user shown
                        reqExist = YES;
                        
                        ///@TODO: We may handle deletion of duplicate friend request Here
                        
                        break;
                    }
                }
                
                if (!reqExist) {
                    
                    ///This friend request is not yet shown to user, so add it in the array
                    [weakSelf.arrFriendRequests addObject:friendRequest];
                }
                
            }
            

            ///Reload the tableview
            [weakSelf.tblVuFriendRequests reloadData];
           
            
        }
        else {
            
            if(![AppDelegate handleParseError:error]){
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#error: %@",errorString);
                
            }
            
        }
        
        ///Stop the progress indicator
        if (weakSelf.refreshControl.isRefreshing) {
            
            ///stop the refreshing control
            [weakSelf.refreshControl endRefreshing];
            
        }
        else{
            
            ///remove the progress hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
        }
        
        
    }];

}

-(void)refresh:(UIRefreshControl *)refreshControl
{
    [self fetchFriendRequestsAndInvites];
    
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
                [self fetchFriendRequestsAndInvites];
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
    NSInteger friendRequestsCount = self.arrFriendRequests.count;
    
    if (friendRequestsCount == 0) {
        
        self.vuStickyNote.hidden = NO;
    }
    else{
        
        self.vuStickyNote.hidden = YES;
    }
    
    return friendRequestsCount;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    ///Create a user Row
    static NSString *friendRequestCellId = @"C411FriendRequestCell";
    
    ///Get Tableview specific cell and user object
    C411FriendRequestCell *friendRequestCell = [self.tblVuFriendRequests dequeueReusableCellWithIdentifier:friendRequestCellId];
    if (rowIndex < self.arrFriendRequests.count) {
        
        PFObject *friendRequest = [self.arrFriendRequests objectAtIndex:rowIndex];
        friendRequestCell.friendRequest = friendRequest;
        friendRequestCell.dictPendingActions = self.dictPendingActions;
        friendRequestCell.btnAccept.tag = rowIndex;
        [friendRequestCell.btnAccept addTarget:self action:@selector(btnAcceptTapped:) forControlEvents:UIControlEventTouchUpInside];
        friendRequestCell.btnReject.tag = rowIndex;
        [friendRequestCell.btnReject addTarget:self action:@selector(btnRejectTapped:) forControlEvents:UIControlEventTouchUpInside];
        [friendRequestCell setupCell];
        
        
    }
    
    return friendRequestCell;
    
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84.0f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < self.arrFriendRequests.count) {
        
        ///Get friend object
        PFObject *friendRequest = [self.arrFriendRequests objectAtIndex:rowIndex];
        PFUser *friend = friendRequest[kCell411AlertIssuedByKey];

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
#pragma mark - Action Methods
//****************************************************


- (void)btnRejectTapped:(UIButton *)sender {
    
    ///Get the friend request object from tag
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.arrFriendRequests.count) {
        
        PFObject *friendRequest = [self.arrFriendRequests objectAtIndex:rowIndex];
        NSString *strFriendReqId = friendRequest.objectId;

        ///Add the pending reject action in dictionary for this request id
        [self.dictPendingActions setObject:@(FriendRequestActionPendingDenied) forKey:strFriendReqId];
        ///reload the cell
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        [self.tblVuFriendRequests reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        __weak typeof(self) weakSelf = self;
        [[C411AppDefaults sharedAppDefaults]rejectFriendRequest:friendRequest withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            ///remove the reject action for this request
            [weakSelf.dictPendingActions removeObjectForKey:strFriendReqId];
            
            ///reload the table
            [weakSelf.tblVuFriendRequests reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }];
    }
    

    
}


- (void)btnAcceptTapped:(UIButton *)sender {
    
    ///Get the friend request object from tag
    NSInteger rowIndex = sender.tag;
    if (rowIndex < self.arrFriendRequests.count) {
        
        PFObject *friendRequest = [self.arrFriendRequests objectAtIndex:rowIndex];
        NSString *strFriendReqId = friendRequest.objectId;
        PFUser *requestIssuer = friendRequest[kCell411AlertIssuedByKey];
        NSString *strRequestIssuerName = [C411StaticHelper getFullNameUsingFirstName:requestIssuer[kUserFirstnameKey] andLastName:requestIssuer[kUserLastnameKey]];
        ///Add the pending accept action in dictionary for this request id
        [self.dictPendingActions setObject:@(FriendRequestActionPendingApproved) forKey:strFriendReqId];
        
        ///reload the cell
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    
        [self.tblVuFriendRequests reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        __weak typeof(self) weakSelf = self;
        [[C411AppDefaults sharedAppDefaults]approveFriendRequestWithId:strFriendReqId fromUserWithId:requestIssuer.objectId fullName:strRequestIssuerName andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded) {
                
                ///Update status on FriendRequest object to make it reflect on cell
               friendRequest[kCell411AlertStatusKey] = kAlertStatusApproved;
                
            }
            
            ///remove the accept action for this request
            [weakSelf.dictPendingActions removeObjectForKey:strFriendReqId];
            
            ///reload the table
            [weakSelf.tblVuFriendRequests reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
        }];

    }
    
    
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
