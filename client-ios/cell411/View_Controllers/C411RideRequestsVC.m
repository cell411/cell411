//
//  C411RideRequestsVC.m
//  cell411
//
//  Created by Milan Agarwal on 30/09/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideRequestsVC.h"
#import "C411RideRequestsCell.h"
#import "UITableView+RemoveTopPadding.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Constants.h"
#import "ConfigConstants.h"
#import "C411AppDefaults.h"
#import "C411StaticHelper.h"
#import "AppDelegate.h"
#import "MAAlertPresenter.h"
#import "C411ReceivedRideResponsesVC.h"
#import "C411RideDetailVC.h"
#import "C411RideRequestPopup.h"
#import "C411AlertNotificationPayload.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ColorHelper.h"

#define FLAG_DISABLED_COLOR @"A4A4A4"
#define FLAG_ENABLED_COLOR  @"FF0000"

@interface C411RideRequestsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblVuRideRequests;

@property (nonatomic, strong) NSMutableArray *arrRequests;
@property (nonatomic, strong) NSMutableDictionary *dictSpammedUsers;
@property (nonatomic, strong) NSString *strSpammingUserObjectId;
@property (nonatomic, assign) BOOL canRefresh;
@end

@implementation C411RideRequestsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 15 pixel
    //[self.tblVuRideRequests removeTopPadding];
    
    [self registerForNotifications];
    ///set can refresh to Yes initially
    self.canRefresh = YES;
    
    ///Add pull to refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblVuRideRequests addSubview:refreshControl];
    [self applyColors];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.canRefresh) {
        
        [self refreshViews];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
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
-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
}

-(void)refreshViews
{
    ///empty tableview
    self.arrRequests = nil;
    [self.tblVuRideRequests reloadData];
    
    //show loading indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ///make a query on Ride Request class to fetch the ride requests
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *fetchReceivedRideRequestsQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [fetchReceivedRideRequestsQuery whereKey:kRideRequestTargetMembersKey containsAllObjectsInArray:@[currentUser]];
    
    PFQuery *fetchSelfIssuedRideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [fetchSelfIssuedRideRequestQuery whereKey:kRideRequestRequestedByKey equalTo:currentUser];
    
    PFQuery *fetchRecentRideRequestQuery = [PFQuery orQueryWithSubqueries:@[fetchReceivedRideRequestsQuery,fetchSelfIssuedRideRequestQuery]];
    
    [fetchRecentRideRequestQuery includeKey:kRideRequestRequestedByKey];
    [fetchRecentRideRequestQuery includeKey:kRideRequestSelectedUserKey];
    [fetchRecentRideRequestQuery orderByDescending:@"createdAt"];
    fetchRecentRideRequestQuery.limit = 50;
    __weak typeof(self) weakSelf = self;
 
    [fetchRecentRideRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        if (!error) {
            
            ///Filter out the deleted alerts
            NSMutableArray *arrRequests = [NSMutableArray arrayWithArray:objects];
            weakSelf.arrRequests = [C411StaticHelper rideRequestArrayByRemovingInvalidObjectsFromArray:arrRequests];
            
            ///get the spammed users list
            [[AppDelegate sharedInstance]getUsersSpammedByCurrentUserWithCompletion:^(id result, NSError *error) {
                
                if (!error) {
                    
                    ///Got members spammed by current user successfully
                    NSArray *arrSpammedUsers = [NSMutableArray arrayWithArray:(NSArray *)result];
                    
                    ///iterate the spammed users array and save it's object id in a dictionary to improve performance of the list
                    self.dictSpammedUsers = [NSMutableDictionary dictionary];
                    for (PFUser *spammedUser in arrSpammedUsers) {
                        
                        [self.dictSpammedUsers setObject:@(YES) forKey:spammedUser.objectId];
                        
                    }
                    
                    ///refresh the tableview
                    [weakSelf.tblVuRideRequests reloadData];
                    
                }
                else{
                    
                    ///Some error occured
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                    
                }
                
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
            }];
            
            
            
        }
        else{
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"#error fetching ride request :%@",errorString);
            ///hide loading screen
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
        }
        
        
    }];
    
 
    
    
}

-(void)spamUser:(PFUser *)user
{
    ///change color and disable spam button
    self.strSpammingUserObjectId = user.objectId;
    [self.tblVuRideRequests reloadData];
    
    __weak typeof(self) weakSelf = self;
    
    [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:user.objectId andCompletion:^(SpamStatus status, NSError *error)
     {
         ///Check whether user is already spammed or not
         if (!error) {
             
             if (status == SpamStatusIsSpammed) {
                 
                 ///show alert that this user is already spammed
                 NSString *issuerFullName = [C411StaticHelper getFullNameUsingFirstName:user[kUserFirstnameKey] andLastName:user[kUserLastnameKey]];
                 NSString *strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is already blocked.",nil),issuerFullName];
                 [C411StaticHelper showAlertWithTitle:nil message:strAlertMsg onViewController:weakSelf];
                 
                 ///save it in spammed users list
                 [weakSelf.dictSpammedUsers setObject:@(YES) forKey:weakSelf.strSpammingUserObjectId];
                 ///clear the iVar
                 weakSelf.strSpammingUserObjectId = nil;
                 
                 ///reload the table
                 [weakSelf.tblVuRideRequests reloadData];
                 
                 ///post notification to observers
                 [[NSNotificationCenter defaultCenter]postNotificationName:kUserBlockedNotification object:user.objectId];

                 
             }
             else if (status == SpamStatusIsNotSpammed) {
                 ///user is not spammed yet, mark him/her as spam
                 PFUser *currentUser = [AppDelegate getLoggedInUser];
                 PFRelation *spamUsersRelation = [currentUser relationForKey:kUserSpamUsersKey];
                 [spamUsersRelation addObject:user];
                 
                 ///save current user object
                 [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                     
                     if (succeeded) {
                         ///user added to current user's spamUsers list
                         ///add a SPAM_ADD task, which has to be performed by user which is being spammed i.e the alert issuer
                         
                         ///1.make an entry in the Task table
                         PFObject *addSpamTask = [PFObject objectWithClassName:kTaskClassNameKey];
                         addSpamTask[kTaskAssigneeUserIdKey] = currentUser.objectId;
                         addSpamTask[kTaskUserIdKey] = user.objectId;
                         addSpamTask[kTaskTaskKey] = kTaskSpamAdd;
                         addSpamTask[kTaskStatusKey] = kTaskStatusPending;
                         [addSpamTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                             
                             if (succeeded) {
                                 
                                 ///SPAM_ADD task created successfully
                                 NSString *issuerFullName = [C411StaticHelper getFullNameUsingFirstName:user[kUserFirstnameKey] andLastName:user[kUserLastnameKey]];
                                 NSString *strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ blocked successfully.",nil),issuerFullName];
                                 [C411StaticHelper showAlertWithTitle:nil message:strAlertMsg onViewController:weakSelf];
                                 
                                 ///save it in spammed users list
                                 [weakSelf.dictSpammedUsers setObject:@(YES) forKey:weakSelf.strSpammingUserObjectId];
                                 
                                 ///clear the iVar
                                 weakSelf.strSpammingUserObjectId = nil;
                                 
                                 ///reload the table
                                 [weakSelf.tblVuRideRequests reloadData];
                                 
                                 ///post notification to observers
                                 [[NSNotificationCenter defaultCenter]postNotificationName:kUserBlockedNotification object:user.objectId];

                                 
                             }
                             else{
                                 ///Unable to create SPAM_ADD task
                                 if (error) {
                                     ///show error
                                     NSString *errorString = [error userInfo][@"error"];
                                     [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                 }
                                 
                                 ///Clear the iVar
                                 weakSelf.strSpammingUserObjectId = nil;
                                 [weakSelf.tblVuRideRequests reloadData];
                                 
                             }
                             
                             
                         }];
                         
                     }
                     else{
                         ///some error occured marking user as spam
                         if (error) {
                             ///show error
                             NSString *errorString = [error userInfo][@"error"];
                             [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                         }
                         
                         ///Clear the iVar
                         weakSelf.strSpammingUserObjectId = nil;
                         [weakSelf.tblVuRideRequests reloadData];
                         
                     }
                     
                 }];
                 
                 
             }
         }
         else{
             
             ///Error occured while checking whether this user has been already spammed or not
             ///show error
             NSString *errorString = [error userInfo][@"error"];
             [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
             
             ///Clear the iVar
             weakSelf.strSpammingUserObjectId = nil;
             [weakSelf.tblVuRideRequests reloadData];
         }
         
     }];
    
}

-(void)registerForNotifications
{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didUnblockedUser:) name:kUserUnblockedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didBlockedUser:) name:kUserBlockedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}


//****************************************************
#pragma mark - UITableViewDataSource and UITableViewDelegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrRequests.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    
    static NSString *cellId = @"C411RideRequestsCell";
    C411RideRequestsCell *rideRequestCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (rowIndex < self.arrRequests.count) {
        
        PFObject *rideRequest = [self.arrRequests objectAtIndex:rowIndex];
        
        ///Get the ride requester
        PFUser *rider = rideRequest[kRideRequestRequestedByKey];
//        [C411StaticHelper getAvatarForUser:rider shouldFallbackToGravatar:YES ofSize:rideRequestCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//            
//            if (success && image) {
//                
//                ///Got the image, set it to the imageview
//                rideRequestCell.imgVuAvatar.image = image;
//            }
//
//        }];
        
        static UIImage *placeHolderImage = nil;
        if (!placeHolderImage) {
            
            placeHolderImage = [UIImage imageNamed:@"logo"];
        }
        ///set the default image first, then fetch the gravatar
        rideRequestCell.imgVuAvatar.image = placeHolderImage;
        BOOL isUserDeleted = [C411StaticHelper isUserDeleted:rider];
        if(!isUserDeleted){
          [rideRequestCell.imgVuAvatar setAvatarForUser:rider shouldFallbackToGravatar:YES ofSize:rideRequestCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        }
                
        ///Make alert title
        [self tableView:tableView configureCell:rideRequestCell atIndexPath:indexPath];
        
        NSString *strRiderId = rider.objectId;
        
        ///Show /hide spam flag and manage request indicator image
        if (strRiderId.length > 0) {
            
            ///Handle Spam Flag
            if ([self.strSpammingUserObjectId isEqualToString:strRiderId]) {
                
                [rideRequestCell.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:FLAG_DISABLED_COLOR]];
                rideRequestCell.btnFlag.enabled = NO;
                
            }
            else if ([[self.dictSpammedUsers objectForKey:strRiderId]boolValue]) {
                
                ///This person is already spammed, hide the spam flag
                rideRequestCell.btnFlag.hidden = YES;
                
            }
            else if ([strRiderId isEqualToString:[AppDelegate getLoggedInUser].objectId]){
                
                ///this alert is issued by current user, so hide the flag as current user cannot spam himself
                rideRequestCell.btnFlag.hidden = YES;
                
            }
            else if (isUserDeleted) {
                ///This user is deleted, so hide the spam flag as there is no benifit of spamming deleted user
                rideRequestCell.btnFlag.hidden = YES;
            }
            else{
                
                ///Show the spam flag
                rideRequestCell.btnFlag.hidden = NO;
                rideRequestCell.btnFlag.enabled = YES;
                [rideRequestCell.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:FLAG_ENABLED_COLOR]];
                
                ///set the selector to be performed
                rideRequestCell.btnFlag.tag = rowIndex;
                [rideRequestCell.btnFlag addTarget:self action:@selector(btnFlagTapped:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
            ///Handle Request indicator
            UIImage *imgRequestIndicator = nil;
            if ([strRiderId isEqualToString:[AppDelegate getLoggedInUser].objectId]){
                
                ///this request is issued by current user
                static UIImage *imgSelfRequestIndicator = nil;
                if (!imgSelfRequestIndicator) {
                    
                    imgSelfRequestIndicator = [UIImage imageNamed:@"ic_ride_request_sent"];
                }
                
                imgRequestIndicator = imgSelfRequestIndicator;
                
            }
            else{
                
                ///this request is issued by someone else
                static UIImage *imgElseRequestIndicator = nil;
                if (!imgElseRequestIndicator) {
                    
                    imgElseRequestIndicator = [UIImage imageNamed:@"ic_ride_request_received"];
                }
                
                imgRequestIndicator = imgElseRequestIndicator;
 
            }
            
            rideRequestCell.imgVuRequestIndicator.image = imgRequestIndicator;
            
            
        }
        
        ///Set the pickup location
        PFGeoPoint *pickUpGeoPoint = rideRequest[kRideRequestPickupLocationKey];
        CLLocationCoordinate2D pickUpCoordinate = CLLocationCoordinate2DMake(pickUpGeoPoint.latitude, pickUpGeoPoint.longitude);
        rideRequestCell.pickupLocation = pickUpCoordinate;
        
        
        ///Set the drop location
        NSString *strDropLocation = rideRequest[kRideRequestDropLocationKey];
        NSArray *arrDropLocation = [strDropLocation componentsSeparatedByString:@","];
        if (arrDropLocation.count == 2) {
            
            CLLocationCoordinate2D dropCoordinate = CLLocationCoordinate2DMake([[arrDropLocation firstObject]doubleValue], [[arrDropLocation lastObject]doubleValue]);
            rideRequestCell.dropLocation = dropCoordinate;

        }
                
    }
    
    return rideRequestCell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 152.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < self.arrRequests.count) {
        
        PFObject *selectedRideRequest = [self.arrRequests objectAtIndex:rowIndex];
        
        ///Get the ride requester
        PFUser *rider = selectedRideRequest[kRideRequestRequestedByKey];
        if ([rider.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]){
            
            ///this request is issued by current user, show received responses VC
            C411ReceivedRideResponsesVC *receivedRideResponsesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ReceivedRideResponsesVC"];
            receivedRideResponsesVC.rideRequest = selectedRideRequest;
            __weak typeof(self) weakSelf = self;
            receivedRideResponsesVC.backActionHandler = ^(id action, id customObject) {
                ///Set can refresh to Yes after a sec so that it will not refresh the view on back, but can refresh later on view will appear
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    weakSelf.canRefresh = YES;
                });
            };

            [self.navigationController pushViewController:receivedRideResponsesVC animated:YES];
            
            ///set can refresh to no, so that it will not refresh the screen if user is coming back
            self.canRefresh = NO;

        }
        else{
            
            ///this request is issued by someone else, check whether current user has already tapped interested for this ride or not. If Yes then show the Ride detail VC, else show the Ride request popup
            PFRelation *initiatedByRelation = [selectedRideRequest relationForKey:kRideRequestInitiatedByKey];
            __weak typeof(self) weakSelf = self;
            
            ///show the progress hud
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[initiatedByRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                
                ///hide the progress hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                if (!error) {
                    
                    ///Got initiatedBy members successfully
                    NSArray *arrInitiatedByMembers = (NSArray *)objects;
                    
                    ///Iterate the array and check whether current user has already initiated the offer or not
                    BOOL hasInitiated = NO;
                    NSString *strDriverId = [AppDelegate getLoggedInUser].objectId;
                    for (PFUser *user in arrInitiatedByMembers) {
                        
                        if ([user.objectId isEqualToString:strDriverId]) {
                            ///Yes the given user with strDriverId exist
                            hasInitiated = YES;
                            break;
                        }
                        
                    }
                    
                    ///make the alert notification payload using the ride request object
                    ///Notification is valid, create a notification payload
                    C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
                    ///set common properties
                    alertNotificationPayload.strAlertType = kPayloadAlertTypeRideRequest;
                    alertNotificationPayload.createdAtInMillis = [selectedRideRequest.createdAt timeIntervalSince1970]*1000;
                    PFUser *rider = selectedRideRequest[kRideRequestRequestedByKey];
                    alertNotificationPayload.strUserId = rider.objectId;
                    ///Ride request properties
                    alertNotificationPayload.strAdditionalNote = selectedRideRequest[kRideRequestAdditionalNoteKey];
                    alertNotificationPayload.strRideRequestId = selectedRideRequest.objectId;
                    alertNotificationPayload.strFullName = [C411StaticHelper getFullNameUsingFirstName:rider[kUserFirstnameKey] andLastName:rider[kUserLastnameKey]];
                    ///Set the pickup location
                    PFGeoPoint *pickUpGeoPoint = selectedRideRequest[kRideRequestPickupLocationKey];
                    alertNotificationPayload.pickUpLat = pickUpGeoPoint.latitude;
                    alertNotificationPayload.pickUpLon = pickUpGeoPoint.longitude;
                    
                    ///Set the drop location
                    NSString *strDropLocation = selectedRideRequest[kRideRequestDropLocationKey];
                    NSArray *arrDropLocation = [strDropLocation componentsSeparatedByString:@","];
                    if (arrDropLocation.count == 2) {
                        
                        alertNotificationPayload.dropLat = [[arrDropLocation firstObject]doubleValue];
                        alertNotificationPayload.dropLon = [[arrDropLocation lastObject]doubleValue];
                        
                    }

                    ///set pickup reached or not
                    alertNotificationPayload.pickupReached = [selectedRideRequest[kRideRequestPickupReachedKey]boolValue];
                    
                    ///set ride completed or not
                    alertNotificationPayload.rideCompleted = [selectedRideRequest[kRideRequestRideCompletedKey]boolValue];
                    

                    

                    if (hasInitiated) {
                        
                        ///show the Ride detail VC
                        C411RideDetailVC *rideDetailVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"C411RideDetailVC"];
                        rideDetailVC.rider = rider;
                        rideDetailVC.alertPayload = alertNotificationPayload;
                        rideDetailVC.backActionHandler = ^(id action, id customObject) {
                            
                            ///Set can refresh to Yes after a sec so that it will not refresh the view on back, but can refresh later on view will appear
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                
                                weakSelf.canRefresh = YES;

                            });
                        };
                        
                        [weakSelf.navigationController pushViewController:rideDetailVC animated:YES];
                        
                        
                    }
                    else{
                        
                        ///set can refresh to no, so that it will not refresh the screen if user is coming back
                        weakSelf.canRefresh = NO;
                        
                        ///Show Ride request popup
                        ///Get top vc reference
                        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
                        ///Load popup view from nib
                        C411RideRequestPopup *vuRideRequestPopup = [[[NSBundle mainBundle] loadNibNamed:@"C411RideRequestPopup" owner:weakSelf options:nil] lastObject];
                        vuRideRequestPopup.showNevermindAsClose = YES;
                        vuRideRequestPopup.alertPayload = alertNotificationPayload;///this must be the last property to be set
                        vuRideRequestPopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
                            
                            ///Do anything on close
                            ///Set can refresh to Yes so that it can again refresh the view later
                            
                            weakSelf.canRefresh = YES;
                            

                            
                        };
                        ///Set view frame
                        vuRideRequestPopup.frame = rootVC.view.bounds;
                        ///Add popup view in next run loop
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            
                            [rootVC.view addSubview:vuRideRequestPopup];
                            [rootVC.view bringSubviewToFront:vuRideRequestPopup];
                            
                        }];
                        
                    }
                    
                    
                }
                else{
                    
                    ///Show the error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                    
                }
                
                
                
                
                
            }];

            
            
            
        }

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

//****************************************************
#pragma mark - tableView:cellForRowAtIndexPath Helper Methods
//****************************************************

-(void)tableView:(UITableView *)tableView configureCell:(C411RideRequestsCell *)rideRequestCell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < self.arrRequests.count) {
        
        PFObject *rideRequest = [self.arrRequests objectAtIndex:rowIndex];
        PFUser *rider = rideRequest[kRideRequestRequestedByKey];
        
        NSDate *rideRequestDate = rideRequest.createdAt;
        rideRequestCell.lblAlertTimestamp.text = [C411StaticHelper getFormattedTimeFromDate:rideRequestDate withFormat:TimeStampFormatDateAndTime];
        
        ///Create the alert title
        NSString *strRiderName = @"";
        
        if ([rider.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
            strRiderName = NSLocalizedString(@"I", nil);
        }
        else{
            
            strRiderName = [C411StaticHelper getFullNameUsingFirstName:rider[kUserFirstnameKey] andLastName:rider[kUserLastnameKey]];

        }
        
        NSString *strTitleMidText = NSLocalizedString(@"requested a", nil);
        NSString *strTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ %@ Ride",nil),strRiderName,strTitleMidText];
        NSRange unboldTextRange = NSMakeRange(strRiderName.length + 1, strTitleMidText.length);
        CGFloat fontSize = rideRequestCell.lblAlertTitle.font.pointSize;
        NSMutableAttributedString *attrTitle = [C411StaticHelper getSemiboldAttributedStringWithString:strTitle ofSize:fontSize withUnboldTextInRange:unboldTextRange];
        if ([C411StaticHelper isUserDeleted:rider]) {
            NSDictionary *dictDeletedUserAttr = @{
                                                  NSFontAttributeName:[UIFont systemFontOfSize: fontSize],
                                                  NSForegroundColorAttributeName: [C411ColorHelper sharedInstance].deletedUserTextColor
                                                  };
            ///1. make name range
            NSRange riderNameRange = NSMakeRange(0, strRiderName.length);
            ///2. set deleted user attribute
            [attrTitle setAttributes:dictDeletedUserAttr range:riderNameRange];
        }
        
        rideRequestCell.lblAlertTitle.attributedText = attrTitle;
        
    }
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

-(void)btnFlagTapped:(UIButton *)sender {
    
    NSUInteger rowIndex = sender.tag;
    if (rowIndex >= self.arrRequests.count) {
        ///out of bounds
        return;
    }
    
    PFObject *selectedRideRequest = [self.arrRequests objectAtIndex:rowIndex];
    
    ///User agreed to flag the selected user as spam
    PFUser *rider = selectedRideRequest[kRideRequestRequestedByKey];
    
    ///show the confirmation dialog first
    NSString *strRiderName = [C411StaticHelper getFullNameUsingFirstName:rider[kUserFirstnameKey] andLastName:rider[kUserLastnameKey]];
    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to flag %@ as a spammer?",nil),strRiderName];
    UIAlertController *confirmSpamAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///user said No, do nothing
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///User opted to spam the user
        [self spamUser:rider];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [confirmSpamAlert addAction:noAction];
    [confirmSpamAlert addAction:yesAction];
    //[self presentViewController:confirmSpamAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmSpamAlert];
    
    
}

-(void)refresh:(UIRefreshControl *)refreshControl
{
    [self refreshViews];
    [refreshControl endRefreshing];
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)didUnblockedUser:(NSNotification *)notif
{
    NSString *strUnblockedUserId = notif.object;
    if (strUnblockedUserId.length > 0) {
        
        ///remove this object id from spammed users list
        [self.dictSpammedUsers removeObjectForKey:strUnblockedUserId];
        
        ///refresh the list
        [self.tblVuRideRequests reloadData];
        
    }
}

-(void)didBlockedUser:(NSNotification *)notif
{
    NSString *strBlockedUserId = notif.object;
    if (strBlockedUserId.length > 0) {
        
        ///add this object id to spammed users list
        [self.dictSpammedUsers setObject:@(YES) forKey:strBlockedUserId];
        
        ///refresh the list
        [self.tblVuRideRequests reloadData];
        
    }
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
