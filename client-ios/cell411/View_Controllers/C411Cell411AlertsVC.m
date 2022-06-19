//
//  C411Cell411AlertsVC.m
//  cell411
//
//  Created by Milan Agarwal on 30/09/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411Cell411AlertsVC.h"
#import "C411AlertCell.h"
//#import "DateHelper.h"
#import "AppDelegate.h"
#import "NSFileManager+DoNotBackUp.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
#import "FileDownloader.h"
#import "UITableView+RemoveTopPadding.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Constants.h"
#import "ConfigConstants.h"
#import "C411AppDefaults.h"
#import "C411StaticHelper.h"
#import "C411ViewAlertDetailPopup.h"
#import "MAAlertPresenter.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ChatHelper.h"
#import "C411ChatVC.h"
#import "C411UserProfilePopup.h"
#import "C411MyProfileVC.h"
#import "C411ViewPhotoVC.h"
#import "C411ColorHelper.h"

#define VIDEO_DOWNLOAD_BASEURL  @"http://"CNAME":81/"
#define FLAG_DISABLED_COLOR @"A4A4A4"
#define FLAG_ENABLED_COLOR  @"FF0000"
#define MIN_ROW_HEIGHT  110.0f

@interface C411Cell411AlertsVC ()<UITableViewDataSource,UITableViewDelegate,NSURLSessionDownloadDelegate,C411ViewAlertDetailPopupDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblVuAlerts;

@property (nonatomic, strong) NSMutableArray *arrAlerts;
// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) id runtimeErrorHandlingObserver;

@property (nonatomic, assign, getter=isAlertDetailVisible) BOOL alertDetailVisible;
@property (nonatomic, assign, getter=shouldIgnoreRefresh) BOOL ignoreRefresh;

@property (nonatomic, strong) NSMutableDictionary *dictSpammedUsers;
@property (nonatomic, strong) NSString *strSpammingUserObjectId;


@end

@implementation C411Cell411AlertsVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///Remove top padding of 15 pixel
    //[self.tblVuAlerts removeTopPadding];
    self.tblVuAlerts.estimatedRowHeight = MIN_ROW_HEIGHT;
    self.tblVuAlerts.rowHeight = UITableViewAutomaticDimension;
    
    ///setup AV Capture if fakeDelete option is enabled by user
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kFakeDelete]) {
        
        [self setupAvCapture];
    
    }
    ///Set this class as delegate of file downloader
    [FileDownloader sharedDownloader].downloaderDelegate = self;
    
    [self registerForNotifications];
    [self applyColors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    ///Start Session if fakeDelete option is enabled by user
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kFakeDelete]) {
        
        ///Start Session
        [self startSession];
        
    }

    if ((!self.isAlertDetailVisible)
        &&(!self.shouldIgnoreRefresh)) {
        ///refresh alert list only if alert detail is not visible and refreshing is not set to ignore
        [self refreshViews];
        
    }
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    ///Stop Session if fakeDelete option is enabled by user
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kFakeDelete]) {
        
        ///Stop Session
        [self stopSession];
        
    }
    
    [super viewDidDisappear:animated];
}


-(void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    ///remove self as a downloader delegate
    [FileDownloader sharedDownloader].downloaderDelegate = nil;
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
    self.arrAlerts = nil;
    [self.tblVuAlerts reloadData];
    
    //show loading indicator
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ///make a query on cell411alert class to fetch the recent alerts
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *fetchRecentIssuedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchRecentIssuedAlertsQuery whereKey:kCell411AlertTargetMembersKey containsAllObjectsInArray:@[currentUser]];
    ///Will fetch all new alerts(Normal and forwarded both) sent to multiple audience
    PFQuery *fetchRecentIssuedAlertsMultipleAudienceQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchRecentIssuedAlertsMultipleAudienceQuery whereKey:kCell411AlertAudienceAUKey equalTo:currentUser];
    [fetchRecentIssuedAlertsMultipleAudienceQuery whereKeyExists:kCell411AlertAlertIdKey];


    
    PFQuery *fetchNeedyPublicAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchNeedyPublicAlertsQuery whereKey:kCell411AlertCellMembersKey equalTo:currentUser];
    
    PFQuery *fetchSelfIssuedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchSelfIssuedAlertsQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
    [fetchSelfIssuedAlertsQuery whereKeyExists:kCell411AlertAlertTypeKey];
    [fetchSelfIssuedAlertsQuery whereKeyDoesNotExist:kCell411AlertToKey];
    //[fetchSelfVideoAlertsQuery whereKey:kCell411AlertAlertTypeKey equalTo:kAlertTypeVideo];
    
    PFQuery *fetchSelfIssuedAlertsMultipleAudienceQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchSelfIssuedAlertsMultipleAudienceQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
    [fetchSelfIssuedAlertsMultipleAudienceQuery whereKeyExists:kCell411AlertAlertIdKey];
    [fetchSelfIssuedAlertsMultipleAudienceQuery whereKeyDoesNotExist:kCell411AlertToKey];

    
    PFQuery *fetchSelfForwardedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchSelfForwardedAlertsQuery whereKey:kCell411AlertForwardedByKey equalTo:currentUser];
    [fetchSelfForwardedAlertsQuery whereKeyExists:kCell411AlertAlertTypeKey];
    [fetchSelfForwardedAlertsQuery whereKeyDoesNotExist:kCell411AlertToKey];

    PFQuery *fetchSelfForwardedAlertsMultipleAudienceQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchSelfForwardedAlertsMultipleAudienceQuery whereKey:kCell411AlertForwardedByKey equalTo:currentUser];
    [fetchSelfForwardedAlertsMultipleAudienceQuery whereKeyExists:kCell411AlertAlertIdKey];
    [fetchSelfForwardedAlertsMultipleAudienceQuery whereKeyDoesNotExist:kCell411AlertToKey];
 
    
    PFQuery *fetchNeedyForwardedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [fetchNeedyForwardedAlertsQuery whereKey:kCell411AlertForwardedToMembersKey containsAllObjectsInArray:@[currentUser]];
    
    PFQuery *fetchRecentAlertsQuery = [PFQuery orQueryWithSubqueries:@[
                                                                       fetchRecentIssuedAlertsMultipleAudienceQuery,
                                                                       fetchSelfIssuedAlertsMultipleAudienceQuery,
                                                                       fetchSelfForwardedAlertsMultipleAudienceQuery,
                                                                       fetchRecentIssuedAlertsQuery,
                                                                       fetchNeedyPublicAlertsQuery,
                                                                       fetchSelfIssuedAlertsQuery,
                                                                       fetchSelfForwardedAlertsQuery,
                                                                       fetchNeedyForwardedAlertsQuery
                                                                       ]];
    
    [fetchRecentAlertsQuery includeKey:kCell411AlertIssuedByKey];
    [fetchRecentAlertsQuery includeKey:kCell411AlertForwardedByKey];
    [fetchRecentAlertsQuery orderByDescending:@"createdAt"];
    fetchRecentAlertsQuery.limit = 50;
    __weak typeof(self) weakSelf = self;
    
    [fetchRecentAlertsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        if (!error) {
            
            ///Filter out the deleted alerts
            NSMutableArray *arrAlerts = [NSMutableArray arrayWithArray:objects];
            weakSelf.arrAlerts = [C411StaticHelper alertsArrayByRemovingInvalidObjectsFromArray:arrAlerts isForwardedAlert:NO];
            [weakSelf filterAlertsArray];
            
            
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
                    [weakSelf.tblVuAlerts reloadData];
                    
                }
                else{
                    
                    ///Some error occured
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                    
                }
                
                
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
            }];
            
            
            
        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#error fetching cell411alert :%@",errorString);
            }
            ///hide loading screen
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
        }
        
        
    }];
    
    
    
}


-(void)filterAlertsArray
{
    ///This will remove the alerts from the alerts array that has been deleted
    ///Iterate the deleted alerts object id
    for (NSString *strDeletedAlertId in [C411AppDefaults sharedAppDefaults].arrFakeDeletedVideos) {
        NSInteger matchIndex = -1;
        ///iterate the recents alerts fetched from parse
        for (NSInteger index = 0; index < self.arrAlerts.count; index++) {
            
            PFObject *cell411Alert = [self.arrAlerts objectAtIndex:index];
            if ([cell411Alert.objectId isEqualToString:strDeletedAlertId]) {
                ///Found the deleted alert
                matchIndex = index;
                break;
            }
            
        }
        
        if (matchIndex!= -1 && matchIndex < self.arrAlerts.count) {
            
            ///Remove this alert from recent alerts, as this has been deleted by user for current session
            [self.arrAlerts removeObjectAtIndex:matchIndex];
            
        }
        
    }
    
    if (self.arrAlerts) {
        ///Iterate the alerts array and remove the alerts issued by Deleted User
        NSMutableArray *arrFilteredAlerts = [NSMutableArray array];
        for (PFObject *alert in self.arrAlerts) {
            PFUser *alertIssuer = alert[kCell411AlertIssuedByKey];
            if (![C411StaticHelper isUserDeleted:alertIssuer]) {
                [arrFilteredAlerts addObject:alert];
            }
        }
        self.arrAlerts = arrFilteredAlerts;
    }
    
}

-(void)fakeDeleteVideoAtIndex:(NSInteger)rowIndex
{
    if (rowIndex < self.arrAlerts.count) {
        ///Get the video alert object
        PFObject *videoAlert = [self.arrAlerts objectAtIndex:rowIndex];
        ///remove it from array of alerts
        [self.arrAlerts removeObjectAtIndex:rowIndex];
        ///Save it in a singleton to maintain its deletion for a session
        [[C411AppDefaults sharedAppDefaults].arrFakeDeletedVideos addObject:videoAlert.objectId];
        ///Update tableview
        [self.tblVuAlerts reloadData];
        
        
        ///disable capture shutter sound
        //        float deviceVolume = [self setDeviceVolume:0.1];
        ///take the snap using the front camera
        [self snapStillImageWithCompletionHanlder:^(UIImage *stillImage, NSError *error) {
            
            if (!error && stillImage) {
                
                ///Save it in a local photo gallery
                UIImageWriteToSavedPhotosAlbum(stillImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            
        }];
        
        ///Send alert to all friends with the photo and the video url
        
        
    }
}

-(void)downloadVideoAtIndex:(NSInteger)rowIndex
{
    if (rowIndex < self.arrAlerts.count) {
        
        ///Get the associated cell411Alert object
        PFObject *cell411Alert = [self.arrAlerts objectAtIndex:rowIndex];
        
        ///Get the video url associated to it
        NSURL *videoURL = [self videoURLForAlert:cell411Alert];
        if (videoURL) {
            
            ///Check the download progess
            NSNumber *downloadProgress = [[FileDownloader sharedDownloader].progressBuffer objectForKey:[videoURL absoluteString]];
            if (!downloadProgress || [downloadProgress intValue] == 1) {
                
                ///Download has not been initiated yet for this video or has been completed, start downloading
                [[[FileDownloader sharedDownloader].session downloadTaskWithURL:videoURL]resume];
                
                // Update Progress Buffer
                [[FileDownloader sharedDownloader].progressBuffer setObject:@(0.0) forKey:[videoURL absoluteString]];
            }
            else{
                ///File downloaded or is in progress
                NSLog(@"%@ is already being downloaded with progress percent %.2f",videoURL,[downloadProgress floatValue] * 100.0);
            }
            
            
        }
    }
}

-(NSURL *)videoURLForIndexPath:(NSIndexPath *)indexPath
{
    NSURL *videoURL = nil;
    if (indexPath) {
        
        NSInteger rowIndex = indexPath.row;
        if (rowIndex < self.arrAlerts.count) {
            
            PFObject *cell411Alert = [self.arrAlerts objectAtIndex:rowIndex];
            
            videoURL = [self videoURLForAlert:cell411Alert];
            
        }
    }
    
    return videoURL;
}

-(NSURL *)videoURLForAlert:(PFObject *)cell411Alert
{
    NSURL *videoURL = nil;
    if (cell411Alert) {
        BOOL isVideoAlert = NO;
        NSNumber *numAlertType = cell411Alert[kCell411AlertAlertIdKey];
        if(numAlertType){
            AlertType alertType = (AlertType)[numAlertType integerValue];
            isVideoAlert = (alertType == AlertTypeVideo);
        }
        else if ([cell411Alert[kCell411AlertAlertTypeKey] isEqualToString:kAlertTypeVideo]){
            isVideoAlert = YES;
        }
        if (isVideoAlert) {
            ///This is a video alert, create the url
            NSTimeInterval createdAtInMillis = [cell411Alert.createdAt timeIntervalSince1970] * 1000;
            NSString *strVideoAlertIssuerId = cell411Alert[kCell411AlertIssuerIdKey];
            NSString *strFileName = [NSString stringWithFormat:@"%@_%.0lf.mp4",strVideoAlertIssuerId,createdAtInMillis];
            NSString *strVideoURL = [NSString stringWithFormat:@"%@%@",VIDEO_DOWNLOAD_BASEURL,strFileName];
            videoURL = [NSURL URLWithString:strVideoURL];
            
        }
        
        
    }
    
    return videoURL;
}

-(void)spamUser:(PFUser *)user
{
    ///change color and disable spam button
    self.strSpammingUserObjectId = user.objectId;
    [self.tblVuAlerts reloadData];
    
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
                 [weakSelf.tblVuAlerts reloadData];
                 
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
                                 [weakSelf.tblVuAlerts reloadData];
                                 
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
                                 [weakSelf.tblVuAlerts reloadData];
                                 
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
                         [weakSelf.tblVuAlerts reloadData];
                         
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
             [weakSelf.tblVuAlerts reloadData];
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


-(void)handleInternalUrl:(NSURL *)url
{
    
    ///Parse the url and get the type value to take corresponding action
    NSDictionary *dictParams = [ServerUtility getParamsFromUrl:url];
    
    if (dictParams) {
        
        ///get the type value
        NSString *strType = dictParams[kInternalLinkParamType];
        if ([strType isEqualToString:kInternalLinkParamTypeShowUserProfile]
            || [strType isEqualToString:kInternalLinkParamTypeShowAlertForwarderProfile]) {
            
            ///get the index
            NSString *strIndex = dictParams[kInternalLinkParamRefIndex];
            if (strIndex) {
                
                NSInteger index = [strIndex integerValue];
                if (index < self.arrAlerts.count) {
                    
                    PFObject *cell411Alert = [self.arrAlerts objectAtIndex:index];
                    
                    PFUser  *alertPerson = cell411Alert[kCell411AlertIssuedByKey];
                    
                    if ([strType isEqualToString:kInternalLinkParamTypeShowAlertForwarderProfile]) {
                        
                        ///show user profile of alert forwarder
                        alertPerson = cell411Alert[kCell411AlertForwardedByKey];
                        
                        
                    }
                    
                    if (alertPerson) {
                        
                        ///show user profile if alertPerson holds valid user object
                        if ([alertPerson.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
                            
                            /* Open it to Show profile of current user
                            C411MyProfileVC *myProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411MyProfileVC"];
                            [self.navigationController pushViewController:myProfileVC animated:YES];
                            */
                            
                        }
                        else{
                            
                            ///show profile of other user
                            [self showUserProfile:alertPerson];
                        }
                    }

                    
                }
                
            }
        }
        else if ([strType isEqualToString:kInternalLinkParamTypeShowAlertDetail]){
            
            ///get the index
            NSString *strIndex = dictParams[kInternalLinkParamRefIndex];
            if (strIndex) {
                
                NSInteger index = [strIndex integerValue];
                
                [self showAlertDetailAtIndex:index];
            }
            
        }
        
    }
    
    
}


-(void)showAlertDetailAtIndex:(NSInteger)rowIndex
{
    
    if (rowIndex < self.arrAlerts.count) {
        
        PFObject *selectedCell411Alert = [self.arrAlerts objectAtIndex:rowIndex];
        
        ///Tthis is not a Custom Alert (i.e Informational Message) and neither a friend/cell request, show alert detail screen on tap
        
        C411AlertCell *alertCell = (C411AlertCell *)[self.tblVuAlerts cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
        NSAttributedString *strMsgOnCell = alertCell.txtVuAlertTitle.attributedText;
        NSString *strAlertTimeStamp = alertCell.lblAlertTimestamp.text;
        ///set alert detail is visible flag to Yes, so that it will not stop the AVCaptureSession to capture video of the person trying to delete video
        self.alertDetailVisible = YES;
        
        
        ///show alert detail popup
        ///Get top vc reference
        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
        ///Load popup view from nib
        C411ViewAlertDetailPopup *vuAlertDetailPopup = [[[NSBundle mainBundle] loadNibNamed:@"C411ViewAlertDetailPopup" owner:self options:nil] lastObject];
        vuAlertDetailPopup.strAlertTitle = strMsgOnCell;
        vuAlertDetailPopup.strAlertTimestamp = strAlertTimeStamp;
        vuAlertDetailPopup.imgAlertType = alertCell.imgVuAlertType.image;
        vuAlertDetailPopup.alertRowIndex = rowIndex;
        vuAlertDetailPopup.alertDetailPopupDelegate = self;
        vuAlertDetailPopup.selectedCell411Alert = selectedCell411Alert;///this must be the last property to be set
        __weak typeof(self) weakSelf = self;
        vuAlertDetailPopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
            
            ///Do anything on close
            weakSelf.alertDetailVisible = NO;
            
            
        };
        ///Set view frame
        vuAlertDetailPopup.frame = rootVC.view.bounds;
        ///Add popup view
        [rootVC.view addSubview:vuAlertDetailPopup];
        [rootVC.view bringSubviewToFront:vuAlertDetailPopup];
        

    }


}

-(void)showUserProfile:(PFUser *)user
{
    
    ///Show user profile popup
    C411UserProfilePopup *vuUserProfilePopup = [[[NSBundle mainBundle] loadNibNamed:@"C411UserProfilePopup" owner:self options:nil] lastObject];
    ///set alert detail is visible flag to Yes, so that it will not stop the AVCaptureSession to capture video of the person trying to delete video
    self.alertDetailVisible = YES;

    vuUserProfilePopup.user = user;
    __weak typeof(self) weakSelf = self;
    vuUserProfilePopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
        
        ///Do anything on close
        weakSelf.alertDetailVisible = NO;
        
        
    };

    UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
    ///Set view frame
    vuUserProfilePopup.frame = rootVC.view.bounds;
    ///add view
    [rootVC.view addSubview:vuUserProfilePopup];
    [rootVC.view bringSubviewToFront:vuUserProfilePopup];
    
}


-(void)addTapGestureOnImageView:(UIView *)imgVu
{
    ///Enable user interaction to listen tap event
    imgVu.userInteractionEnabled = YES;
    
    ///remove old tap gestures first
    for (UIGestureRecognizer *gestureRecognizer in imgVu.gestureRecognizers) {
        
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            
            [imgVu removeGestureRecognizer:gestureRecognizer];
        }
        
    }
    
    ///Add tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgVuAvatarTapped:)];
    [imgVu addGestureRecognizer:tapRecognizer];
}


//****************************************************
#pragma mark - UITableViewDataSource and UITableViewDelegate Methods
//****************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrAlerts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowIndex = indexPath.row;
    
    static NSString *cellId = @"C411AlertCell";
    C411AlertCell *alertCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (rowIndex < self.arrAlerts.count) {
        
        PFObject *cell411Alert = [self.arrAlerts objectAtIndex:rowIndex];
        NSString *strAlertType = nil;
        NSNumber *numAlertType = cell411Alert[kCell411AlertAlertIdKey];
        if(numAlertType){
            AlertType alertType = (AlertType)[numAlertType integerValue];
            strAlertType = [C411StaticHelper getAlertTypeStringUsingAlertType:alertType];
        }
        else{
            strAlertType = cell411Alert[kCell411AlertAlertTypeKey];
        }
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
            if(![C411StaticHelper isUserDeleted:alertForwardedBy]) {
                [alertCell.imgVuAvatar setAvatarForUser:alertForwardedBy shouldFallbackToGravatar:YES ofSize:alertCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
            }
        }
        else{
            ///This is an alert issued by a user, show the gravatar of the issuer
            if (![C411StaticHelper isUserDeleted:alertIssuedBy]) {
                [alertCell.imgVuAvatar setAvatarForUser:alertIssuedBy shouldFallbackToGravatar:YES ofSize:alertCell.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
            }
        }

        ///Set tap gesture on image view
        alertCell.imgVuAvatar.tag = rowIndex;
        [self addTapGestureOnImageView:alertCell.imgVuAvatar];

        
        
//        if (strGravatarEmail.length > 0) {
//            ///Grab avatar image and place it here
//            static UIImage *placeHolderImage = nil;
//            if (!placeHolderImage) {
//                
//                placeHolderImage = [UIImage imageNamed:@"logo"];
//            }
//            alertCell.imgVuAvatar.email = strGravatarEmail;
//            alertCell.imgVuAvatar.placeholder = placeHolderImage;
//            alertCell.imgVuAvatar.defaultGravatar = RFDefaultGravatarUrlSupplied;
//            NSURL *defaultGravatarUrl = [NSURL URLWithString:DEFAULT_GRAVATAR_URL];
//            alertCell.imgVuAvatar.defaultGravatarUrl = defaultGravatarUrl;
//            
//            alertCell.imgVuAvatar.size = alertCell.imgVuAvatar.bounds.size.width * 3;
//            [alertCell.imgVuAvatar load];
//            
//        }

        ///set alert image
        alertCell.strAlertType = strAlertType;
        
        ///Make alert title
        [self tableView:tableView configureCell:alertCell atIndexPath:indexPath];
        
        ///Show /hide spam flag
        PFUser *alertPerson = alertForwardedBy ? alertForwardedBy : alertIssuedBy;
        NSString *strAlertPersonId = alertPerson.objectId;
        if (strAlertPersonId.length > 0) {
            
            if ([self.strSpammingUserObjectId isEqualToString:strAlertPersonId]) {
                
                [alertCell.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:FLAG_DISABLED_COLOR]];
                alertCell.btnFlag.enabled = NO;
                
            }
            else if ([[self.dictSpammedUsers objectForKey:strAlertPersonId]boolValue]) {
                
                ///This person is already spammed, hide the spam flag
                alertCell.btnFlag.hidden = YES;
                
            }
            else if ([strAlertPersonId isEqualToString:[AppDelegate getLoggedInUser].objectId]){
                
                ///this alert is issued by current user, so hide the flag as current user cannot spam himself
                alertCell.btnFlag.hidden = YES;
                
            }
            else if ([C411StaticHelper isUserDeleted:alertPerson]) {
                ///This user is deleted, so hide the spam flag as there is no benifit of spamming deleted user
                alertCell.btnFlag.hidden = YES;
            }
            else{
                
                ///Show the spam flag
                alertCell.btnFlag.hidden = NO;
                alertCell.btnFlag.enabled = YES;
                [alertCell.btnFlag setBackgroundColor:[C411StaticHelper colorFromHexString:FLAG_ENABLED_COLOR]];
                
                ///set the selector to be performed
                alertCell.btnFlag.tag = rowIndex;
                [alertCell.btnFlag addTarget:self action:@selector(btnFlagTapped:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
        }
        
        ///Show/hide chat button
#if CHAT_ENABLED
        ///set target on chat button
        alertCell.btnChat.tag = rowIndex;
        [alertCell.btnChat addTarget:self action:@selector(btnChatTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        ///show chat button if chat time is not expired
        NSTimeInterval alertCreatedAtInMillis = [cell411Alert.createdAt timeIntervalSince1970] * 1000;
        
        BOOL isChatExpired = ![C411ChatHelper canChatOnAlertIssuedAt:alertCreatedAtInMillis];
        
        if (isChatExpired) {
            ///chat is expired, don't show chat bubble
            alertCell.btnChat.hidden = YES;

        }
        else{
            ///chat is not expired, show chat bubble
            alertCell.btnChat.hidden = NO;
        }
        
#else
        alertCell.btnChat.hidden = YES;
#endif
        
        
    }
    
    return alertCell;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSInteger rowIndex = indexPath.row;
    if (rowIndex < self.arrAlerts.count) {
        
        ///Return height of Alert Cell
        ///Create a static cell for each reuse identifier
        static C411AlertCell *alertCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            alertCell = [tableView dequeueReusableCellWithIdentifier:@"C411AlertCell"];
            
        });
        
        
        [self tableView:self.tblVuAlerts configureCell:alertCell atIndexPath:indexPath];
        
        ///Calculate height
        return [self tableView:tableView calculateHeightForConfiguredSizingCell:alertCell];
        
    }
    else{
        
        return 0;
    }
    
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    [self showAlertDetailAtIndex:rowIndex];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

//****************************************************
#pragma mark - tableView:cellForRowAtIndexPath Helper Methods
//****************************************************

-(void)tableView:(UITableView *)tableView configureCell:(C411AlertCell *)alertCell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowIndex = indexPath.row;
    
    if (rowIndex < self.arrAlerts.count) {
        
        PFObject *cell411Alert = [self.arrAlerts objectAtIndex:rowIndex];
        NSString *strAlertType = nil;
        NSNumber *numAlertType = cell411Alert[kCell411AlertAlertIdKey];
        if(numAlertType){
            AlertType alertType = (AlertType)[numAlertType integerValue];
            strAlertType = [C411StaticHelper getAlertTypeStringUsingAlertType:alertType];
        }
        else{
            strAlertType = cell411Alert[kCell411AlertAlertTypeKey];
        }
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
        
        if ([strAlertType isEqualToString:kAlertTypeVideo]) {
            
            ///This is a video alert
            BOOL isLive = [cell411Alert[kCell411AlertStatusKey] isEqualToString:kAlertStatusLive] ? YES : NO;
            
            if ([alertIssuedBy.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
                
                ///Video alert issued by self
                //isAlertIssuedBySelf = YES;
                
                ///1.Update status to VOD if its left to do so due to any internet issue
                if (isLive) {
                    cell411Alert[kCell411AlertStatusKey] = kAlertStatusVOD;
                    [cell411Alert saveEventually];
                }
                
                
            }
            
            
        }
        
        NSMutableAttributedString *attribStrAlertTitle = nil;
        if (strAlertType.length > 0) {

            NSString *strAlertName = [C411StaticHelper getLocalizedAlertTypeStringFromString:strAlertType];
            float fontSize = alertCell.txtVuAlertTitle.font.pointSize;
            NSDictionary *dictMainAttr = @{
                                           NSFontAttributeName:[UIFont systemFontOfSize: fontSize],
                                           NSForegroundColorAttributeName: [C411ColorHelper sharedInstance].primaryTextColor
                                           };
#if APP_CELL411
            attribStrAlertTitle = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 411 alert",nil),strIssuerName,strAlertName] attributes:dictMainAttr];

#elif APP_RO112
            attribStrAlertTitle = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 112 alert",nil),strIssuerName,strAlertName] attributes:dictMainAttr];

#else
            attribStrAlertTitle = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ alert",nil),strIssuerName,strAlertName] attributes:dictMainAttr];

            
#endif
            
            
            NSDictionary *dictSubAttr = @{
                                          NSFontAttributeName:[UIFont boldSystemFontOfSize: fontSize],
                                          NSForegroundColorAttributeName: [C411ColorHelper sharedInstance].primaryTextColor
                                          
                                          };
            NSDictionary *dictDeletedUserAttr = @{
                                                  NSFontAttributeName:[UIFont systemFontOfSize: fontSize],
                                                  NSForegroundColorAttributeName: [C411ColorHelper sharedInstance].deletedUserTextColor
                                                  };
            if (![alertIssuedBy.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
                
                ///set attributes on Issuer Name if it's not current user
                ///1. make name range
                NSRange issuerNameRange = NSMakeRange(0, strIssuerName.length);
                if([C411StaticHelper isUserDeleted:alertIssuedBy]) {
                    ///2. Set delete user text color attribute
                    [attribStrAlertTitle setAttributes:dictDeletedUserAttr range:issuerNameRange];
                }
                else{
                    ///2. set bold attribute
                    [attribStrAlertTitle setAttributes:dictSubAttr range:issuerNameRange];
                    
                    ///3. add link attribute for issuer name
                    NSDictionary *dictParams = @{kInternalLinkParamType:kInternalLinkParamTypeShowUserProfile,
                                                 kInternalLinkParamRefIndex:@(rowIndex)};
                    NSURL *url = [NSURL URLWithString:[ServerUtility stringByAppendingParams:dictParams toUrlString:kInternalLinkBaseURL]];
                    [attribStrAlertTitle addAttribute:NSLinkAttributeName value:url range:issuerNameRange];
                }
            }

            
            ///set attribute on alert type
            ///1. make alert type range
            NSRange alertTypeRange = [attribStrAlertTitle.string rangeOfString:strAlertName];
            if (alertTypeRange.location != NSNotFound) {
                
                ///2. set bold attribute
                [attribStrAlertTitle setAttributes:dictSubAttr range:alertTypeRange];
                
                ///3.add link attribute for alert detail
                NSDictionary *dictParams = @{kInternalLinkParamType:kInternalLinkParamTypeShowAlertDetail,
                               kInternalLinkParamRefIndex:@(rowIndex)};
                NSURL *url = [NSURL URLWithString:[ServerUtility stringByAppendingParams:dictParams toUrlString:kInternalLinkBaseURL]];
                [attribStrAlertTitle addAttribute:NSLinkAttributeName value:url range:alertTypeRange];
            }
            PFUser *alertForwardedBy = cell411Alert[kCell411AlertForwardedByKey];
            NSString *strCellName = cell411Alert[kCell411AlertCellNameKey];
            if (alertForwardedBy) {
                
                ///This is an Needy alert forwarded by someone.
                ///append the forwarder Name
                NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:alertForwardedBy[kUserFirstnameKey] andLastName:alertForwardedBy[kUserLastnameKey]];
                
                NSAttributedString *attribStrForwardedBy =[[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@", forwarded by %@",nil),strFullName] attributes:dictMainAttr];
                
                ///get the length of title string before adding forwarded by text
                NSInteger partialTitleLength = attribStrAlertTitle.length;
                [attribStrAlertTitle appendAttributedString:attribStrForwardedBy];
                
                
                ///set attributes on Forwarder Name
                ///1. make forwarder name range
                NSRange forwarderNameRange = [attribStrForwardedBy.string rangeOfString:strFullName];
                if (forwarderNameRange.location != NSNotFound) {
                    
                    ///append the length of attribStrAlertTitle to location before adding forwardedby name
                    forwarderNameRange.location = forwarderNameRange.location + partialTitleLength;
                    
                    if ([C411StaticHelper isUserDeleted:alertForwardedBy]) {
                        ///2. set bold attribute
                        [attribStrAlertTitle setAttributes:dictDeletedUserAttr range:forwarderNameRange];
                        
                    }
                    else {
                        ///2. set bold attribute
                        [attribStrAlertTitle setAttributes:dictSubAttr range:forwarderNameRange];
                        
                        ///3. add link attribute for issuer name
                        NSDictionary *dictParams = @{kInternalLinkParamType:kInternalLinkParamTypeShowAlertForwarderProfile,
                                                     kInternalLinkParamRefIndex:@(rowIndex)};
                        NSURL *url = [NSURL URLWithString:[ServerUtility stringByAppendingParams:dictParams toUrlString:kInternalLinkBaseURL]];
                        [attribStrAlertTitle addAttribute:NSLinkAttributeName value:url range:forwarderNameRange];
                    }
                }
            }
            else if (strCellName.length > 0)
            {
                ///This is a public alert, append cell name
                NSAttributedString *attribStrCellName = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@" on %@",nil),strCellName] attributes:dictMainAttr];
                ///get the length of title string before adding Cell name
                //NSInteger partialTitleLength = attribStrAlertTitle.length;
                
                [attribStrAlertTitle appendAttributedString:attribStrCellName];
                
                /* OPEN it to set link on Cell Name set attributes on Cell Name
                ///1. make Cell name range
                NSRange cellNameRange = [attribStrCellName.string rangeOfString:strCellName];
                if (cellNameRange.location != NSNotFound) {
                    
                    ///append the length of attribStrAlertTitle to location before adding cell name
                    cellNameRange.location = cellNameRange.location + partialTitleLength;
                    
                    ///2. set bold attribute
                    [attribStrAlertTitle setAttributes:dictSubAttr range:cellNameRange];
                    
                    ///3. add link attribute for issuer name
                    NSURL *url = [NSURL URLWithString:@"http://www.wiselysoft.com/cell"];
                    [attribStrAlertTitle addAttribute:NSLinkAttributeName value:url range:cellNameRange];
                    
                }
                */
            }
        }
        //alertCell.lblAlertTitle.attributedText = attribStrAlertTitle;
        alertCell.txtVuAlertTitle.attributedText = attribStrAlertTitle;
        alertCell.txtVuAlertTitle.delegate = self;
    }
}

//****************************************************
#pragma mark - tableView:heightForRowAtIndexPath Helper Methods
//****************************************************


- (CGFloat)tableView:(UITableView *)tableView calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    float height = size.height + 1.0f; // Add 1.0f for the cell separator height
    
    height = height < MIN_ROW_HEIGHT ? MIN_ROW_HEIGHT : height;
    
    return height;
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

-(void)btnFlagTapped:(UIButton *)sender {
    
    NSUInteger rowIndex = sender.tag;
    if (rowIndex >= self.arrAlerts.count) {
        ///out of bounds
        return;
    }
    
    PFObject *selectedCell411Alert = [self.arrAlerts objectAtIndex:rowIndex];
    
    ///User agreed to flag the selected user as spam
    PFUser *alertPerson = selectedCell411Alert[kCell411AlertIssuedByKey];
    PFUser *alertForwardedBy = selectedCell411Alert[kCell411AlertForwardedByKey];
    
    if (alertForwardedBy) {
        
        ///This is an Needy alert forwarded by someone. Update selected user so that it can be spammed
        alertPerson = alertForwardedBy;
        
    }
    
    ///show the confirmation dialog first
    NSString *strAlertPersonName = [C411StaticHelper getFullNameUsingFirstName:alertPerson[kUserFirstnameKey] andLastName:alertPerson[kUserLastnameKey]];
    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to flag %@ as a spammer?",nil),strAlertPersonName];
    UIAlertController *confirmSpamAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///user said No, do nothing
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///User opted to spam the user
        [self spamUser:alertPerson];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [confirmSpamAlert addAction:noAction];
    [confirmSpamAlert addAction:yesAction];
    //[self presentViewController:confirmSpamAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmSpamAlert];
    
    
}


-(void)btnChatTapped:(UIButton *)sender
{
    
    NSUInteger rowIndex = sender.tag;
    if (rowIndex >= self.arrAlerts.count) {
        ///out of bounds
        return;
    }
    
    PFObject *selectedCell411Alert = [self.arrAlerts objectAtIndex:rowIndex];

    C411ChatVC *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
    chatVC.entityType = ChatEntityTypeAlert;
    chatVC.strEntityId = selectedCell411Alert.objectId;
    NSString *strEntityName = nil;
    NSNumber *numAlertType = selectedCell411Alert[kCell411AlertAlertIdKey];
    if(numAlertType){
        AlertType alertType = (AlertType)[numAlertType integerValue];
        strEntityName = [C411StaticHelper getAlertTypeStringUsingAlertType:alertType];
    }
    else{
        strEntityName = selectedCell411Alert[kCell411AlertAlertTypeKey];
    }
    chatVC.strEntityName = strEntityName;
    chatVC.entityCreatedAtInMillis = [selectedCell411Alert.createdAt timeIntervalSince1970] * 1000;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:chatVC animated:YES];

}

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    
    UIImageView *imgVuAvatar = (UIImageView *) sender.view;
    NSInteger rowIndex = imgVuAvatar.tag;
    if (rowIndex < self.arrAlerts.count) {
        
        PFObject *cell411Alert = [self.arrAlerts objectAtIndex:rowIndex];
        
        ///This is an alert other than Custom alert
        PFUser *alertIssuedBy = cell411Alert[kCell411AlertIssuedByKey];
        PFUser *alertForwardedBy = cell411Alert[kCell411AlertForwardedByKey];
        PFUser *alertPerson = nil;
        
        if (alertForwardedBy) {
            ///This is an alert forwarded by someone, show the gravatar of the forwardedBy person
            alertPerson = alertForwardedBy;
        }
        else{
            ///This is an alert issued by a user, show the gravatar of the issuer
            alertPerson = alertIssuedBy;
        }
        
        if (![C411StaticHelper isUserDeleted:alertPerson]) {
            ///set refresh ignore flag to yes to ignore refreshing of list when coming back from photo vc
            self.ignoreRefresh = YES;
            
            ///observe Photo vc closed notification to handle refreshing
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClosedViewPhotoVC:) name:kDidClosedPhotoVCNotification object:nil];
            
            ///Show photo VC to view photo alert
            UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
            C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
            viewPhotoVC.user = alertPerson;
            [navRoot pushViewController:viewPhotoVC animated:YES];
        }
    }
}



//****************************************************
#pragma mark - NSURLSessionDownloadDelegate Methods
//****************************************************

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    // Calculate Progress
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    // Update Table View Cell
    //    C411AlertCell *cell = [self cellForDownloadTask:downloadTask];
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        cell.downloadProgress = progress;
    //    });
    
    if (self.alertDetailVisible) {
        
        ///Post notification for download progress, as it could be required on that Screen
        NSMutableDictionary *dictDownloadProg = [NSMutableDictionary dictionary];
        NSURL *downloadUrl = [[downloadTask originalRequest] URL];
        if (downloadUrl) {
            
            [dictDownloadProg setObject:@(progress) forKey:downloadUrl];
            
            ///post notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kDidUpdateVideoDownloadProgressNotification object:dictDownloadProg];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    //    // Update Table View Cell
    //    C411AlertCell *cell = [self cellForDownloadTask:downloadTask];
    //
    //    ///Update the progressView
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        cell.downloadProgress = 1.0;
    //    });
    
    if (self.alertDetailVisible) {
        
        ///Post notification for download finish, as it could be required on that Screen
        NSURL *downloadUrl = [[downloadTask originalRequest] URL];
        if (downloadUrl) {
            
            ///post notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kDidFinishDownloadingVideoNotification object:downloadUrl];
        }
    }
    
    
}



//****************************************************
#pragma mark - Fake Delete Image Capture Setup
//****************************************************
-(void)setupAvCapture
{
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setCaptureSession:session];
    
    
    ///Setup preset
    if ([session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    // Setup the preview view
    //[[self vuCamPreview] setSession:session];
    
    // Check for device authorization
    //[self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        
        NSError *error = nil;
        
        ////Setup Preview Video Input
        AVCaptureDevice *videoDevice = [[self class] deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            // dispatch_async(dispatch_get_main_queue(), ^{
            // Why are we dispatching this to the main queue?
            // Because AVCaptureVideoPreviewLayer is the backing layer for VMVCamPreviewView and UIView can only be manipulated on main thread.
            // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
            
            // [[(AVCaptureVideoPreviewLayer *)[[self vuCamPreview] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            //});
        }
        
        
        ////Setup Still Image Output
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
    
    ///Show Full screen preview
    
    //    CGRect bounds=self.view.layer.bounds;
    //    [(AVCaptureVideoPreviewLayer *)self.vuCamPreview.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //    self.vuCamPreview.layer.bounds=bounds;
    //    self.vuCamPreview.layer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    
    //    NSLog(@"Preview layer frames%@,%@",NSStringFromCGRect(self.vuCamPreview.layer.bounds),NSStringFromCGRect(self.vuCamPreview.layer.frame));
    
}


-(void)startSession
{
    dispatch_async([self sessionQueue], ^{
        //        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak C411Cell411AlertsVC *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self captureSession] queue:nil usingBlock:^(NSNotification *note) {
            C411Cell411AlertsVC *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf captureSession] startRunning];
            });
        }]];
        [[self captureSession] startRunning];
    });
}

-(void)stopSession
{
    dispatch_async([self sessionQueue], ^{
        [[self captureSession] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        //        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
    });
    
}

-(void)snapStillImageWithCompletionHanlder:(void(^)(UIImage *stillImage, NSError *error))completionHandler
{
    dispatch_async([self sessionQueue], ^{
        // Update the orientation on the still image output video connection before capturing.
        //[[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self vuCamPreview] layer] connection] videoOrientation]];
        [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
        
        // Flash set to Auto for Still Capture
        [[self class] setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
        
        // Capture a still image.
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            UIImage *image = nil;
            
            if (imageDataSampleBuffer)
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                image = [[UIImage alloc] initWithData:imageData];
                //				[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
            }
            
            if (completionHandler != NULL) {
                completionHandler(image, error);
            }
            
            
        }];
    });
    
}

/*
 - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 {
 if (context == CapturingStillImageContext)
 {
 BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
 
 if (isCapturingStillImage)
 {
 [self disableCaptureShutterSound];
 }
 }
 else
 {
 [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
 }
 }
 */

//****************************************************
#pragma mark - Notification Methods
//****************************************************
- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

-(void)didUnblockedUser:(NSNotification *)notif
{
    NSString *strUnblockedUserId = notif.object;
    if (strUnblockedUserId.length > 0) {
        
        ///remove this object id from spammed users list
        [self.dictSpammedUsers removeObjectForKey:strUnblockedUserId];
        
        ///refresh the list
        [self.tblVuAlerts reloadData];
        
    }
}

-(void)didBlockedUser:(NSNotification *)notif
{
    NSString *strBlockedUserId = notif.object;
    if (strBlockedUserId.length > 0) {
        
        ///add this object id to spammed users list
        [self.dictSpammedUsers setObject:@(YES) forKey:strBlockedUserId];
        
        ///refresh the list
        [self.tblVuAlerts reloadData];
        
    }
}

-(void)didClosedViewPhotoVC:(NSNotification *)notif
{
    ///stop observing Photo vc closed notification
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDidClosedPhotoVCNotification object:nil];

    
    ///reset the refresh ignore flag to NO after some delay
    __weak typeof(self) weakSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        weakSelf.ignoreRefresh = NO;

    });
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


//****************************************************
#pragma mark - Device Configuration Methods
//****************************************************

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

//****************************************************
#pragma mark - Save Image Done Selector
//****************************************************

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo{
    
    NSString *strMessage = NSLocalizedString(@"Image Saved Successfully",nil);
    
    if (error) {
        
        strMessage = error.localizedDescription;
        
    }
    
    NSLog(@"%@",strMessage);
    
    
    
}



//****************************************************
#pragma mark - C411ViewAlertDetailPopupDelegate Methods
//****************************************************

-(void)alertDetailPopup:(C411ViewAlertDetailPopup *)alertDetailPopup fakeDeleteVideoAtIndex:(NSInteger)rowIndex
{
    [self fakeDeleteVideoAtIndex:rowIndex];
    self.alertDetailVisible = NO;
}

-(NSURL *)alertDetailPopup:(C411ViewAlertDetailPopup *)alertDetailPopup didRequireVideoURLForAlert:(PFObject *)cell411Alert
{
    return [self videoURLForAlert:cell411Alert];
}

-(void)alertDetailPopup:(C411ViewAlertDetailPopup *)alertDetailPopup downloadVideoAtIndex:(NSInteger)rowIndex
{
    [self downloadVideoAtIndex:rowIndex];
}



//****************************************************
#pragma mark - UITextViewDelegate Methods
//****************************************************

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    // Call your method here.
    [self handleInternalUrl:URL];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    // Call your method here.
    [self handleInternalUrl:URL];
    return NO;

}


@end
