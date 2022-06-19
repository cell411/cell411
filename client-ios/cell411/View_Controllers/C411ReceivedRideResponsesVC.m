//
//  C411ReceivedRideResponsesVC.m
//  cell411
//
//  Created by Milan Agarwal on 03/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411ReceivedRideResponsesVC.h"
#import "RFGravatarImageView.h"
#import "C411StaticHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "C411RideResponseCell.h"
#import "MAAlertPresenter.h"
#import "C411AlertNotificationPayload.h"
#import "C411RideResponsePopup.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ColorHelper.h"
#import "Constants.h"

#define FLAG_DISABLED_COLOR @"A4A4A4"
#define FLAG_ENABLED_COLOR  @"FF0000"

@interface C411ReceivedRideResponsesVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRideStatusHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblRideSelectionStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuClock;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeStamp;
@property (weak, nonatomic) IBOutlet UITableView *tblVuRideResponses;
@property (weak, nonatomic) IBOutlet UIView *vuSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btnCancelRequest;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCancelRequestHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCancelButtonTS;

@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNote;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteValue;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDropAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedDriverText;
@property (weak, nonatomic) IBOutlet UIView *vuResponseCountBase;
@property (weak, nonatomic) IBOutlet UIView *vuResponseCountInner;
@property (weak, nonatomic) IBOutlet UILabel *lblResponseCountHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblResponseCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSelectionStatusLblTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSelectionStatusLblBS;
- (IBAction)btnCancelRequestTapped:(UIButton *)sender;

@property (nonatomic, strong) NSURLSessionDataTask *pickUpLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *dropLocationTask;
@property (nonatomic, strong) NSMutableArray *arrResponses;
@property (nonatomic, strong) NSMutableDictionary *dictSpammedUsers;
@property (nonatomic, strong) NSString *strSpammingUserObjectId;
@property (nonatomic, assign) CLLocationCoordinate2D pickUpCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D dropCoordinate;


@end

@implementation C411ReceivedRideResponsesVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self initializeViews];
    [self registerForNotifications];
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
#pragma mark - Overridden Methods
//****************************************************
-(void)mag_viewDidBack {
    [super mag_viewDidBack];
    self.rideRequest = nil;
    
    if (self.backActionHandler != NULL) {
        ///call the Close action handler
        self.backActionHandler(nil, nil);
    }
    self.backActionHandler = NULL;
}

//****************************************************
#pragma mark - Private methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Ride Responses", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    ///make circular views
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    
    ///set corner radius
    self.vuResponseCountBase.layer.cornerRadius = 3.0;
    self.vuResponseCountBase.layer.masksToBounds = YES;
    self.vuResponseCountInner.layer.cornerRadius = 3.0;
    self.vuResponseCountInner.layer.masksToBounds = YES;
    self.btnCancelRequest.layer.cornerRadius = 3.0;
    self.btnCancelRequest.layer.masksToBounds = YES;
    
    [self applyColors];
}

-(void)applyColors
{
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblTitle.textColor = primaryTextColor;
    self.lblAdditionalNote.textColor = primaryTextColor;

    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblRideStatusHeading.textColor = secondaryTextColor;
    self.lblTimeStamp.textColor = secondaryTextColor;
    self.lblPickUpAddress.textColor = secondaryTextColor;
    self.lblDropAddress.textColor = secondaryTextColor;
    
    self.imgVuClock.tintColor = [C411ColorHelper sharedInstance].hintIconColor;

    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuSeparator.backgroundColor = themeColor;
    self.vuResponseCountBase.backgroundColor = themeColor;
    self.lblResponseCount.textColor = themeColor;

    ///Set primaryBGTextColor
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblResponseCountHeading.textColor = primaryBGTextColor;
    self.vuResponseCountInner.backgroundColor = primaryBGTextColor;
}

-(void)initializeViews
{
    ///Get the ride requester
    PFUser *rider = self.rideRequest[kRideRequestRequestedByKey];
//    __weak typeof(self) weakSelf = self;
//    [C411StaticHelper getAvatarForUser:rider shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//        
//        if (success && image) {
//            
//            ///Got the image, set it to the imageview
//            weakSelf.imgVuAvatar.image = image;
//        }
//        
//    }];
    
    [self.imgVuAvatar setAvatarForUser:rider shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
    
    NSDate *rideRequestDate = self.rideRequest.createdAt;
    self.lblTimeStamp.text = [C411StaticHelper getFormattedTimeFromDate:rideRequestDate withFormat:TimeStampFormatDateAndTime];

    ///Set the pickup location
    PFGeoPoint *pickUpGeoPoint = self.rideRequest[kRideRequestPickupLocationKey];
    self.pickUpCoordinate = CLLocationCoordinate2DMake(pickUpGeoPoint.latitude, pickUpGeoPoint.longitude);
    self.pickUpLocationTask = [C411StaticHelper updateLocationonLabel:self.lblPickUpAddress usingCoordinate:self.pickUpCoordinate];

    
    ///Set the drop location
    NSString *strDropLocation = self.rideRequest[kRideRequestDropLocationKey];
    NSArray *arrDropLocation = [strDropLocation componentsSeparatedByString:@","];
    if (arrDropLocation.count == 2) {
        
        self.dropCoordinate = CLLocationCoordinate2DMake([[arrDropLocation firstObject]doubleValue], [[arrDropLocation lastObject]doubleValue]);
        self.dropLocationTask = [C411StaticHelper updateLocationonLabel:self.lblDropAddress usingCoordinate:self.dropCoordinate];

        
    }
    
    NSString *strAdditionalNote = self.rideRequest[kRideRequestAdditionalNoteKey];
    if (strAdditionalNote.length > 0) {
        
        ///Show the additional Note
        self.lblAdditionalNoteValue.text = strAdditionalNote;
        
    }
    else{
        
        ///hide the additional note label as well
        self.lblAdditionalNote.text = nil;
        self.lblAdditionalNoteValue.text = nil;
        self.cnsCancelButtonTS.constant = 0;
        
    }
    
    ///Hide the status view initially
    self.lblSelectedDriverText.text = nil;
    self.cnsSelectionStatusLblTS.constant = 0;
    self.cnsSelectionStatusLblBS.constant = 0;
    
    ///Hide cancel button initially
    self.cnsCancelButtonTS.constant = 0;
    self.cnsCancelRequestHeight.constant = 0;

    ///Handle ride status
    [self handleRideStatusAndFetchOnPending:YES];
    
    ///Handle ride responses
    [self fetchAndHandleRideResponses];
    
    
}

-(void)handleRideStatusAndFetchOnPending:(BOOL)fetchOnPending
{
    NSString *strRideStatus = self.rideRequest[kRideRequestStatusKey];
    if ([strRideStatus isEqualToString:kRideRequestStatusSelected]) {
        
        ///Get the selected driver
        PFUser *selectedDriver = self.rideRequest[kRideRequestSelectedUserKey];
        NSString *strDriverFullname = [C411StaticHelper getFullNameUsingFirstName:selectedDriver[kUserFirstnameKey] andLastName:selectedDriver[kUserLastnameKey]];
        ///set the status
        self.lblRideSelectionStatus.text = NSLocalizedString(@"Selected", nil);
        
        ///show the selected driver text
        self.lblSelectedDriverText.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is selected for this ride",nil),strDriverFullname];
        self.cnsSelectionStatusLblTS.constant = 5;
        self.cnsSelectionStatusLblBS.constant = 5;
        
        ///Reset cancel constraint and hide it
        self.btnCancelRequest.hidden = YES;
        self.cnsCancelButtonTS.constant = 10;
        self.cnsCancelRequestHeight.constant = 28;
        
        
    }
    else if ([strRideStatus isEqualToString:kRideRequestStatusCancelled]){
        
        ///set status
        self.lblRideSelectionStatus.text = NSLocalizedString(@"Cancelled", nil);
        
        
    }
    else{
        
        ///ride status is pending
        if (fetchOnPending) {
            
            ///fetch the updated ride request object from Parse and then update the status
             __weak typeof(self) weakSelf = self;
            PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
            [rideRequestQuery includeKey:kRideRequestSelectedUserKey];
            [rideRequestQuery getObjectInBackgroundWithId:self.rideRequest.objectId block:^(PFObject *object,  NSError *error){
                
                if (!error && object) {
                    
                    ///ride request found
                    weakSelf.rideRequest = object;
                    [weakSelf handleRideStatusAndFetchOnPending:NO];
                    
                }
                else {
                    
                    ///show the error
                    if (error) {
                        
                        if(![AppDelegate handleParseError:error]){
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                        }
                    }
                    
                    
                    
                }
            }];
            

        }
        else{
            
            ///show status as pending without fetching from Parse
            ///set status
            self.lblRideSelectionStatus.text = NSLocalizedString(@"Pending", nil);
            
            ///Reset cancel constraint to make it visible
            self.cnsCancelButtonTS.constant = 10;
            self.cnsCancelRequestHeight.constant = 28;
            

        }
        
    }
}

-(void)fetchAndHandleRideResponses
{
    ///fetch the ride responses object from Parse for current request
    __weak typeof(self) weakSelf = self;
    PFQuery *rideResponsesQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
    [rideResponsesQuery includeKey:kRideResponseRespondedByKey];
    [rideResponsesQuery whereKey:kRideResponseRideRiquestIdKey equalTo:self.rideRequest.objectId];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [rideResponsesQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        
        
        if (!error) {
            
            weakSelf.lblResponseCount.text = [NSString stringWithFormat:@"%d",(int)objects.count];
            
            ///Filter out the deleted alerts
            NSMutableArray *arrResponses = [NSMutableArray arrayWithArray:objects];
            weakSelf.arrResponses = [C411StaticHelper rideResponseArrayByRemovingInvalidObjectsFromArray:arrResponses];
            
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
                    [weakSelf.tblVuRideResponses reloadData];
                    
                }
                else{
                    
                    ///Some error occured
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                    
                }
                
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
            }];

        }
        else {
            
            ///show the error
            if (error) {
                
                if(![AppDelegate handleParseError:error]){
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                }
            }
            
            ///hide the hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

            
        }
    }];

}


-(void)spamUser:(PFUser *)user
{
    ///change color and disable spam button
    self.strSpammingUserObjectId = user.objectId;
    [self.tblVuRideResponses reloadData];
    
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
                 [weakSelf.tblVuRideResponses reloadData];
                 
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
                                 [weakSelf.tblVuRideResponses reloadData];
                                 
                                 ///post notification to observers
                                 [[NSNotificationCenter defaultCenter]postNotificationName:kUserBlockedNotification object:user.objectId];

                                 
                             }
                             else{
                                 ///Unable to create SPAM_ADD task
                                 if (error) {
                                     if(![AppDelegate handleParseError:error]){
                                         ///show error
                                         NSString *errorString = [error userInfo][@"error"];
                                         [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                     }
                                 }
                                 
                                 ///Clear the iVar
                                 weakSelf.strSpammingUserObjectId = nil;
                                 [weakSelf.tblVuRideResponses reloadData];
                                 
                             }
                             
                             
                         }];
                         
                     }
                     else{
                         ///some error occured marking user as spam
                         if (error) {
                             if(![AppDelegate handleParseError:error]){
                                 ///show error
                                 NSString *errorString = [error userInfo][@"error"];
                                 [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                             }
                         }
                         
                         ///Clear the iVar
                         weakSelf.strSpammingUserObjectId = nil;
                         [weakSelf.tblVuRideResponses reloadData];
                         
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
             [weakSelf.tblVuRideResponses reloadData];
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
#pragma mark - UITableViewDatasource and Delegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrResponses.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    
    static NSString *cellId = @"C411RideResponseCell";
    C411RideResponseCell *rideResponseCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (rowIndex < self.arrResponses.count) {
        
        PFObject *rideResponse = [self.arrResponses objectAtIndex:rowIndex];
        
        ///Get the ride responder(driver)
        PFUser *driver = rideResponse[kRideResponseRespondedByKey];
        ///set image for driver
//        [C411StaticHelper getAvatarForUser:driver shouldFallbackToGravatar:YES ofSize:rideResponseCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//            
//            if (success && image) {
//                
//                ///Got the image, set it to the imageview
//                rideResponseCell.imgVuAvatar.image = image;
//            }
//            
//        }];
        BOOL isUserDeleted = [C411StaticHelper isUserDeleted:driver];
        if (isUserDeleted) {
            ///Grey out the name
            rideResponseCell.lblResponderName.textColor = [C411ColorHelper sharedInstance].deletedUserTextColor;
            
        }
        else{
            ///Set primary text color
            rideResponseCell.lblResponderName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
            ///Show profile pic
            [rideResponseCell.imgVuAvatar setAvatarForUser:driver shouldFallbackToGravatar:YES ofSize:rideResponseCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        }
        
        
        
        ///Set the driver name
        NSString *strDriverFullName = [C411StaticHelper getFullNameUsingFirstName:driver[kUserFirstnameKey] andLastName:driver[kUserLastnameKey]];
        rideResponseCell.lblResponderName.text = strDriverFullName;
        
        ///Show selection status
        NSString *strRideResponseStatus = rideResponse[kRideResponseStatusKey];
        if ([strRideResponseStatus isEqualToString:kRideResponseStatusConfirmed]) {
            
            rideResponseCell.lblStatus.text = NSLocalizedString(@"Confirmed", nil);
            ///set color to green
            rideResponseCell.lblStatus.textColor = [UIColor greenColor];
            
        }
        else if ([strRideResponseStatus isEqualToString:kRideResponseStatusRejected]) {
            
            rideResponseCell.lblStatus.text = NSLocalizedString(@"Rejected", nil);
            
            ///set color to red
            rideResponseCell.lblStatus.textColor = [UIColor redColor];
            
        }
        else{
            
            rideResponseCell.lblStatus.text = NSLocalizedString(@"Waiting", nil);
            
            ///set color to orange
            rideResponseCell.lblStatus.textColor = self.lblRideSelectionStatus.textColor;
            
            
        }

        
        ///Show the full timestamp
        NSDate *responseDate = rideResponse.createdAt;
        rideResponseCell.lblTimestamp.text = [C411StaticHelper getFormattedTimeFromDate:responseDate withFormat:TimeStampFormatDateAndTime];

        NSString *strDriverId = driver.objectId;
        
        ///Show /hide spam flag and manage request indicator image
        if (strDriverId.length > 0) {
            
            ///Handle Spam Flag
            if ([self.strSpammingUserObjectId isEqualToString:strDriverId]) {
                
                [rideResponseCell.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:FLAG_DISABLED_COLOR]];
                rideResponseCell.btnFlag.enabled = NO;
                
            }
            else if ([[self.dictSpammedUsers objectForKey:strDriverId]boolValue]) {
                
                ///This person is already spammed, hide the spam flag
                rideResponseCell.btnFlag.hidden = YES;
                
            }
            else if ([strDriverId isEqualToString:[AppDelegate getLoggedInUser].objectId]){
                
                ///this alert is issued by current user, so hide the flag as current user cannot spam himself
                rideResponseCell.btnFlag.hidden = YES;
                
            }
            else if (isUserDeleted) {
                ///This user is deleted, so hide the spam flag as there is no benifit of spamming deleted user
                rideResponseCell.btnFlag.hidden = YES;
            }
            else{
                
                ///Show the spam flag
                rideResponseCell.btnFlag.hidden = NO;
                rideResponseCell.btnFlag.enabled = YES;
                [rideResponseCell.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:FLAG_ENABLED_COLOR]];
                
                ///set the selector to be performed
                rideResponseCell.btnFlag.tag = rowIndex;
                [rideResponseCell.btnFlag addTarget:self action:@selector(btnFlagTapped:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
            
            
        }
        
        
        
        
    }
    
    return rideResponseCell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < self.arrResponses.count) {
        
        PFObject *selectedRideResponse = [self.arrResponses objectAtIndex:rowIndex];
        
        ///make the alert notification payload using the ride response object
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        ///set common properties
        alertNotificationPayload.strAlertType = kPayloadAlertTypeRideInterested;
        alertNotificationPayload.createdAtInMillis = [selectedRideResponse.createdAt timeIntervalSince1970]*1000;
        PFUser *driver = selectedRideResponse[kRideResponseRespondedByKey];
        alertNotificationPayload.strUserId = driver.objectId;
        ///Ride request properties
        alertNotificationPayload.strAdditionalNote = selectedRideResponse[kRideResponseAdditionalNoteKey];
        alertNotificationPayload.strRideRequestId = selectedRideResponse[kRideResponseRideRiquestIdKey];
        alertNotificationPayload.strRideResponseId = selectedRideResponse.objectId;
        alertNotificationPayload.strFullName = [C411StaticHelper getFullNameUsingFirstName:driver[kUserFirstnameKey] andLastName:driver[kUserLastnameKey]];
        ///Set the pickup location
        alertNotificationPayload.pickUpLat = self.pickUpCoordinate.latitude;
        alertNotificationPayload.pickUpLon = self.pickUpCoordinate.longitude;
        
        ///Set the drop location
        alertNotificationPayload.dropLat = self.dropCoordinate.latitude;
        alertNotificationPayload.dropLon = self.dropCoordinate.longitude;

        ///set cost
        alertNotificationPayload.strCost = selectedRideResponse[kRideResponseCostKey];
        
        ///Get top vc reference
        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
        ///Load popup view from nib
        C411RideResponsePopup *vuRideResponsePopup = [[[NSBundle mainBundle] loadNibNamed:@"C411RideResponsePopup" owner:self options:nil] lastObject];
        vuRideResponsePopup.alertPayload = alertNotificationPayload;///this must be the last property to be set
        vuRideResponsePopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
            
            ///Do anything on close
            
            
        };
        ///Set view frame
        vuRideResponsePopup.frame = rootVC.view.bounds;
        ///Add popup view in next run loop
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            [rootVC.view addSubview:vuRideResponsePopup];
            [rootVC.view bringSubviewToFront:vuRideResponsePopup];
            
        }];

        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnCancelRequestTapped:(UIButton *)sender {
    
    ///Save the ride status as cancelled on Parse
    self.rideRequest[kRideRequestStatusKey] = kRideRequestStatusCancelled;
    __weak typeof(self) weakSelf = self;
    [self.rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
            
            ///save it eventually if error occured
            [weakSelf.rideRequest saveEventually];
            
        }

        
    }];
    
    ///Reset the ride status and UI
    ///set status as cancelled
    self.lblRideSelectionStatus.text = NSLocalizedString(@"Cancelled", nil);
    
    ///Hide cancel button
    self.cnsCancelButtonTS.constant = 0;
    self.cnsCancelRequestHeight.constant = 0;
    
    ///Post notification to hide overlay if shown for this ride request
    [[NSNotificationCenter defaultCenter]postNotificationName:kHideRideOverlayNotification object:self.rideRequest.objectId];

}

-(void)btnFlagTapped:(UIButton *)sender {
    
    NSUInteger rowIndex = sender.tag;
    if (rowIndex >= self.arrResponses.count) {
        ///out of bounds
        return;
    }
    
    PFObject *selectedRideResponse = [self.arrResponses objectAtIndex:rowIndex];
    
    ///User agreed to flag the selected user as spam
    PFUser *driver = selectedRideResponse[kRideResponseRespondedByKey];
    
    ///show the confirmation dialog first
    NSString *strDriverName = [C411StaticHelper getFullNameUsingFirstName:driver[kUserFirstnameKey] andLastName:driver[kUserLastnameKey]];
    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to flag %@ as a spammer?",nil),strDriverName];
    UIAlertController *confirmSpamAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///user said No, do nothing
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///User opted to spam the user
        [self spamUser:driver];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [confirmSpamAlert addAction:noAction];
    [confirmSpamAlert addAction:yesAction];
    //[self presentViewController:confirmSpamAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmSpamAlert];
    
    
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
        [self.tblVuRideResponses reloadData];
        
    }
}

-(void)didBlockedUser:(NSNotification *)notif
{
    NSString *strBlockedUserId = notif.object;
    if (strBlockedUserId.length > 0) {
        
        ///add this object id to spammed users list
        [self.dictSpammedUsers setObject:@(YES) forKey:strBlockedUserId];
        
        ///refresh the list
        [self.tblVuRideResponses reloadData];
        
    }
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
