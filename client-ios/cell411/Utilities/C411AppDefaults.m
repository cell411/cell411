//
//  C411AppDefaults.m
//  cell411
//
//  Created by Milan Agarwal on 21/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411AppDefaults.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "AppDelegate.h"
#import "C411AlertNotificationPayload.h"
#import "C411AddFriendToCellPopup.h"
#import "C411EmergencyAlertPopup.h"
#import "ConfigConstants.h"
#import "C411ViewPhotoVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MAAlertPresenter.h"
#import "C411RideRequestPopup.h"
#import "C411RideResponsePopup.h"
#import "C411RideSelectedPopup.h"
#import "C411ChatHelper.h"
#import "C411UserJoinedPopup.h"

#define TXT_TAG_ALERT_EMAIL         301


static C411AppDefaults *appDefaults;
@interface C411AppDefaults ()<UITextFieldDelegate>

@property(nonatomic, readwrite) NSMutableArray *arrFriends;
@property(nonatomic, readwrite) NSMutableArray *arrCells;

#if NON_APP_USERS_ENABLED
@property(nonatomic, readwrite) NSMutableArray *arrNonAppUserCells;
#endif

///reference to the submit action method will be stored in this to use it to enable it later when there is some text inputted by user in update email popup
@property (nonatomic, weak) UIAlertAction *submitAction;

@end

@implementation C411AppDefaults


//****************************************************
#pragma mark - Public Methods
//****************************************************

+(instancetype)sharedAppDefaults
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!appDefaults) {
            
            appDefaults = [[C411AppDefaults alloc]init];
            
        }
        
    });
    
    return appDefaults;
    
}

-(void)clearUserData
{
    self.arrCells = nil;
    self.arrFriends = nil;
    self.arrFakeDeletedVideos = nil;
#if NON_APP_USERS_ENABLED
    self.arrNonAppUserCells = nil;
#endif
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kDisableDownloadMyDataUntilKey];
    [defaults synchronize];
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceivedFriendRequestAlert:) name:kRecivedAlertForFriendRequestNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceivedFriendApprovedAlert:) name:kRecivedAlertForFriendApprovedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedHelperAlert:) name:kRecivedAlertFromHelperNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedRejectorAlert:) name:kRecivedAlertFromRejectorNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedNeedyAlert:) name:kRecivedAlertFromNeedyNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedVideoStreamingAlert:) name:kRecivedVideoStreamingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedPhotoAlert:) name:kRecivedPhotoAlertNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceivedJoinPublicCellRequest:) name:kRecivedAlertToJoinPublicCellNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceivedNewPublicCellCreatedAlert:) name:kRecivedAlertForNewPublicCellCreatedNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedRideRequest:) name:kReceivedRideRequestNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedRideInterestedResponseFromDriver:) name:kReceivedRideInterestedNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedRideConfirmedFromRider:) name:kReceivedRideConfirmedNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedRideRejectedFromRider:) name:kReceivedRideRejectedNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRecievedRideSelectedFromRider:) name:kReceivedRideSelectedNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didUserRemovedFromCell:) name:kRecivedAlertForUserRemovedFromCellNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userDidJoined:) name:kRecivedUserJoinedNotification object:nil];
    

}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)createDefaultCells
{
    ///Create an array of cells
    if (!_arrCells) {
        _arrCells = [NSMutableArray array];
        
    }
    
    ///Add Default Cells
    NSDictionary *dictDefaultCellMapping = [C411StaticHelper getDefaultCellsLocalizedNameAndTypeMapping];
    for (NSNumber *numCellType in [dictDefaultCellMapping allKeys]) {
        
        ///Create a default Cell object without name
        PFObject *cell = [PFObject objectWithClassName:kCellClassNameKey];
        cell[kCellCreatedByKey] = [PFUser currentUser];///This should be fetched from parse only as it is created at the time of signup and before setting isLoggedIn flag
        cell[kCellTypeKey] = numCellType;
        [cell saveEventually];
        [self.arrCells addObject:cell];
        
    }
    
    ///6.Post notification that cell list updated
    [[NSNotificationCenter defaultCenter]postNotificationName:kCellsListUpdatedNotification object:nil];
}


-(void)addFriendWithEmailId:(NSString *)strEmailId
{
    
    ///1.Check if email id is empty
    if (strEmailId.length == 0) {
        
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Please enter a valid email address", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
        return;
        
    }
    
    ///2.check if user is not trying add self as a friend
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *currentUserEmailId = [C411StaticHelper getEmailFromUser:currentUser];
    currentUserEmailId = [currentUserEmailId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (currentUserEmailId.length > 0 && [strEmailId.lowercaseString isEqualToString:currentUserEmailId.lowercaseString]) {
        
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You cannot add yourself as friend", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
        return;
        
        
    }
    
    ///3.Check if this friend is already added or not
    for (PFUser *user in self.arrFriends) {
        NSString *strFriendEmail = [C411StaticHelper getEmailFromUser:user];
        strFriendEmail = [strFriendEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([strFriendEmail.lowercaseString isEqualToString:strEmailId.lowercaseString]) {
            
            ///friend exist with this email id
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"This friend already added", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
            return;
            
        }
        
    }
    
    ///Create weak reference of self
    __weak typeof(self) weakSelf = self;
    
    ///get user with given email id to check if user is using the app or not, if not send email invite otherwise send friend request
    [C411StaticHelper getUserWithEmail:strEmailId.lowercaseString andCompletion:^(PFObject *object,  NSError *error){
        
        if (!error){
            
            ///Found user having matching email id,
            PFUser *friendObject = (PFUser *)object;
            NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:friendObject[kUserFirstnameKey] andLastName:friendObject[kUserLastnameKey]];
            
            ///Send friend request to this user
            [weakSelf sendFriendRequestToUser:friendObject withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (succeeded) {
                    
                    ///Friend request is sent successfully
                    NSString *strMessage = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"A friend invite is sent to", nil), strUserFullName,NSLocalizedString(@"for approval", nil)];
                    [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];

                    
                }
                else if (error){
                    
                    ///Some error occured sending friend request to this user
                    if(![AppDelegate handleParseError:error]){
                        
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        
                    }

                    
                }
                else{
                    
                    ///there is no error but operation doesn't get succeeded, could be the case that user to whom friend request is being sent has spammed current user
                    
                }
                
            }];
            
        }
        
        /*{
            
            ///Found user having matching email id,
            PFUser *friendObject = (PFUser *)object;
            
            ///Check if the user(friendObject) to be added as  a friend has spammed current user or not, if spammed then show message that "Sorry, we cannot send friend request to this user on your behalf" else proceed with further checks required to add friend
            [[AppDelegate sharedInstance]didCurrentUserSpammedByUserWithId:friendObject.objectId andCompletion:^(SpamStatus status, NSError *error) {
                
                if (status == SpamStatusIsSpammed) {
                    
                    ///Show message that this user cannot be added as friend
                    [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Sorry, we cannot send friend request to this user on your behalf", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                else{
                    ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to perform other steps required to send friend request
                    if (error) {
                        ///Log the error if any
                        NSLog(@"%@",error.localizedDescription);
                        
                    }
                    
                    ///Make entry on Cell411Alert table and send push notification for Friend Request either for the first time or re invite case.
                    NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                    ///1. make an entry in Cell411Alert table for Friend Request
                    PFObject *sendFRAlert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                    sendFRAlert[kCell411AlertIssuedByKey] = currentUser;
                    sendFRAlert[kCell411AlertIssuerFirstNameKey] = strUserFullName;
                    sendFRAlert[kCell411AlertToKey] = friendObject.username;
                    sendFRAlert[kCell411AlertStatusKey] = kAlertStatusPending;
                    sendFRAlert[kCell411AlertEntryForKey] = kEntryForFriendRequest;
                    [sendFRAlert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            
                            ///Friend Request entry made in parse, now send a push notification
                            NSString *strMessage = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"A friend invite was send to", nil), strEmailId,NSLocalizedString(@"for approval", nil)];
                            [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
                            
                            
                            ///Create Payload data
                            NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                            NSString *strPayloadFRMsgSuffix = nil;
#if APP_IER
                            
                            ///iER values
                            strPayloadFRMsgSuffix = NSLocalizedString(@"has sent you an iER friend request!", nil);
                            
#else
                            
                            ///Cell 411 Values
                            strPayloadFRMsgSuffix = NSLocalizedString(@"has sent you a Cell 411 friend request!", nil);
#endif

                            dictData[kPayloadAlertKey] = [NSString stringWithFormat:@"%@ %@",strUserFullName,strPayloadFRMsgSuffix];
                            dictData[kPayloadUserIdKey] = currentUser.objectId;
                            dictData[kPayloadNameKey] = strUserFullName;
                            dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeFriendRequest;
                            dictData[kPayloadSoundKey] = @"default";///To play default sound
                            dictData[kPayloadFRObjectIdKey] = sendFRAlert.objectId;
                            dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                            
                            // Create our Installation query
                            PFQuery *pushQuery = [PFInstallation query];
                            [pushQuery whereKey:kInstallationUserKey equalTo:friendObject];
                            
                            // Send push notification to query
                            PFPush *push = [[PFPush alloc] init];
                            [push setQuery:pushQuery]; // Set our Installation query
                            [push setData:dictData];
                            [push sendPushInBackground];
                            
                            
                            
                        }
                        else{
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                            
                                }
                            }
                        }
                        
                    }];
                    
                    
                    
                }
                
            }];
            
            
        }*/
        else if (error.code == kPFErrorObjectNotFound){
            ///User does not exist, show invite friend alert
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:nil
                                                  message:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ is not using %@. Do you want to send them an email invitation to join you?",nil),strEmailId, LOCALIZED_APP_NAME]
                                                  preferredStyle:UIAlertControllerStyleAlert];
            BOOL isTakingEmailInput = NO;
            
            if (!currentUserEmailId || currentUserEmailId.length == 0) {
                
                ///Take user email as well and update it first
                isTakingEmailInput = YES;
                NSString *strPlaceholder = NSLocalizedString(@"Enter your email", nil);
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
                 {
                     textField.placeholder = strPlaceholder;
                     textField.tag = TXT_TAG_ALERT_EMAIL;
                     textField.delegate = weakSelf;
                 }];

            }
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               ///user canceled to send invite, do nothing
                                               ///Dequeue the current Alert Controller and allow other to be visible
                                               [[MAAlertPresenter sharedPresenter]dequeueAlert];
 
                                           }];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", nil)
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                          ///user tapped ok
                                           if (isTakingEmailInput) {
                                               
                                               UITextField *txtEmail = alertController.textFields.firstObject;
                                               NSString *strEmail = txtEmail.text;
                                               if (strEmail.length > 0) {
                                                   ///trim the white spaces
                                                   strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                               }
                                               
                                               [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                                   ///Do other task in next runloop, to avoid present another alert on top of another.Update current user email
                                                   ///show the progress hud
                                                   UIView *hudSuperView = [AppDelegate sharedInstance].window.rootViewController.view;
                                                   
                                                   [MBProgressHUD showHUDAddedTo:hudSuperView animated:YES];
                                                   
                                                   [C411StaticHelper updateEmail:strEmail.lowercaseString forUser:currentUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                                                       
                                                       if (error) {
                                                           
                                                           ///show error
                                                           NSString *errorString = [error userInfo][@"error"];
                                                           [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                                           
                                                           
                                                           
                                                       }
                                                       else{
                                                           
                                                           ///User email updated, Send friend invite.
                                                           [weakSelf inviteFriendWithEmailId:strEmailId shouldShowMessageOnSuccessOrError:YES withCompletion:NULL];
                                                       }
                                                       
                                                       ///Hide hud
                                                       [MBProgressHUD hideHUDForView:hudSuperView animated:YES];
                                                       
                                                       
                                                   }];
                                                   
                                               }];

                                           }
                                           else{
                                               
                                               ///Current user already have email, send friend invite from his email id
                                               [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                                   ///Do other task in next runloop, to avoid present another alert on top of another.Send friend invite.
                                                   [weakSelf inviteFriendWithEmailId:strEmailId shouldShowMessageOnSuccessOrError:YES withCompletion:NULL];
                                               }];

                                               
                                           }
                                           
                                           ///Dequeue the current Alert Controller and allow other to be visible
                                           [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                           
                                       }];
            
            if (!currentUserEmailId || currentUserEmailId.length == 0) {
                ///disable ok action if email textfield is there and save it's reference in submitAction ivar to enable it later
                okAction.enabled = NO;
                self.submitAction = okAction;

            }
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
            ///Enqueue the alert controller object in the presenter queue to be displayed one by one
            [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

        }
        else{
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
        }
        
    }];
    
}

-(void)checkUser:(PFUser *)user isFriendWithCompletion:(PFBooleanResultBlock)completion
{
    ///Friend list is available, whether this user is a friend of current user or not in this list
    if(!_arrFriends){
        __weak typeof(self) weakSelf = self;
        
        [self getFriendsinBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (!error) {
                
                weakSelf.arrFriends = [NSMutableArray arrayWithArray:objects];
                
                ///Post notification that friend list updated
                [[NSNotificationCenter defaultCenter]postNotificationName:kFriendListUpdatedNotification object:nil];
                
                ///Call recursively same function to check relationship
                [weakSelf checkUser:user isFriendWithCompletion:completion];
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
                
            }

            
        }];
    }
    else{
        
        BOOL isFriend = NO;
        
        for (PFUser *friend in self.arrFriends) {
            if ([friend.objectId isEqualToString:user.objectId]) {
                
                ///This user is already a friend of current user
                isFriend = YES;
                break;
                
                
            }
            
        }
        
        completion(isFriend, nil);
        
    }
    

}

-(void)sendFriendRequestToUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion
{
    __weak typeof(self) weakSelf = self;
    
    [self checkUser:user isFriendWithCompletion:^(BOOL isFriend, NSError * _Nullable error) {
        
        if(isFriend){
            
            ///friend exist with this email id
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"This friend already added", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
            if (completion != NULL) {
                
                ///call the completion block
                completion(NO, nil);
                
            }
            
        }
        else{
            
            ///Check if the user(friend Object) to be added as  a friend has spammed current user or not, if spammed then show message that "Sorry, we cannot send friend request to this user on your behalf" else proceed with further checks required to add friend
            
            [[AppDelegate sharedInstance]didCurrentUserSpammedByUserWithId:user.objectId andCompletion:^(SpamStatus status, NSError *error) {
                
                if (status == SpamStatusIsSpammed) {
                    
                    ///Show message that this user cannot be added as friend
                    [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Sorry, we cannot send friend request to this user on your behalf", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                    if (completion != NULL) {
                        
                        ///call the completion block
                        completion(NO, error);
                        
                    }
                    
                }
                else{
                    ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to perform other steps required to send friend request
                    if (error) {
                        ///Log the error if any
                        NSLog(@"%@",error.localizedDescription);
                        
                    }
                    
                    ///Check if friend request/invite has already been sent to this user/email id or not by current user
                    PFQuery *fetchFriendReqQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                    PFUser *currentUser = [AppDelegate getLoggedInUser];
                    [fetchFriendReqQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
                    
                    if ([user.username respondsToSelector:@selector(lowercaseString)]) {
                        
                        [fetchFriendReqQuery whereKey:kCell411AlertToKey equalTo:user.username.lowercaseString];
                        
                    }
                    else{
                        
#warning Milan->: Some how we are getting username as null which is crashing the app calling lowercaseString method on it
                        // NSLog(@"%@",currentUser.username);
                        ///fetch the current user
                        [user fetchIfNeeded];
                        [fetchFriendReqQuery whereKey:kCell411AlertToKey equalTo:user.username];
                        
                    }
                    [fetchFriendReqQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite]];
                    [fetchFriendReqQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
                    NSMutableArray *arrSubQueries = [NSMutableArray array];
                    
                    if ([C411StaticHelper getSignUpTypeOfUser:user] == SignUpTypeFacebook) {
                        
                        ///Create a query to fetch FRIEND_REQUEST/FRIEND_INVITE alerts for Facebook users
                        
                        ///1. update query to retrieve friend request, friend invite using username(without lowercase string)
                        ///clear reference of first query
                        fetchFriendReqQuery = nil;
                        
                        
                        fetchFriendReqQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                        [fetchFriendReqQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
                        [fetchFriendReqQuery whereKey:kCell411AlertToKey equalTo:user.username];
                        [fetchFriendReqQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite]];
                        [fetchFriendReqQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
                        
                        ///make sub queries if facebook user has email to check for email also
                        NSString *strUserEmail = [C411StaticHelper getEmailFromUser:user];
                        strUserEmail = [strUserEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if (strUserEmail.length > 0) {
                            
                            ///1. get reference of first query
                            PFQuery *fetchFriendReqWithUsernameSubQuery = fetchFriendReqQuery;
                            ///clear fetchFriendReqQuery
                            fetchFriendReqQuery = nil;
                            
                            ///2. Make another sub query to look for user email as well, as user email is entered while sending friend request or friend invite from Invite Contacts screen.
                            
                            PFQuery *fetchFriendReqWithEmailSubQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                            [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
                            [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertToKey equalTo:strUserEmail.lowercaseString];
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
                    ///Check if mobile number of this user is available and is verified or not
                    NSString *strContactNumber = user[kUserMobileNumberKey];
                    strContactNumber = [C411StaticHelper getNumericStringFromString:strContactNumber];
                    BOOL isPhoneVerified = [user[kUserPhoneVerifiedKey]boolValue];
                    if ((strContactNumber.length > 0) && isPhoneVerified) {
                        
                        ///make a subquery to fetch FR/FI on this number
                        PFQuery *fetchFriendReqWithPhoneNumberSubQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                        [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
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
                    
                    
                    [fetchFriendReqQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                        
                        if (!error) {
                            
                            ///Friend request/Invite has already been sent to this user before. Don't make an entry on Cell411Alert table and just send push notification again
                            PFObject *sendFRAlert = object;
                            [weakSelf sendFriendRequestPushNotificationToUser:user usingAlert:sendFRAlert];
                            if (completion != NULL) {
                                
                                ///call the completion block
                                completion(YES, error);
                                
                            }
                            
                            
                            
                        }
                        else if (error.code == kPFErrorObjectNotFound){
                            
                            ///Friend request/Invite email has never been sent to this user/email id
                            ///#Make entry on Cell411Alert table and send push notification for Friend Request either for the first time or re invite case.
                            NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                            ///1. make an entry in Cell411Alert table for Friend Request
                            PFObject *sendFRAlert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                            sendFRAlert[kCell411AlertIssuedByKey] = currentUser;
                            sendFRAlert[kCell411AlertIssuerFirstNameKey] = strUserFullName;
                            sendFRAlert[kCell411AlertToKey] = user.username;
                            sendFRAlert[kCell411AlertStatusKey] = kAlertStatusPending;
                            sendFRAlert[kCell411AlertEntryForKey] = kEntryForFriendRequest;
                            [sendFRAlert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                
                                if (succeeded) {
                                    
                                    ///Friend Request entry made in parse, now send a push notification
                                    [weakSelf sendFriendRequestPushNotificationToUser:user usingAlert:sendFRAlert];
                                    
                                }
                                
                                if (completion != NULL) {
                                    
                                    ///call the completion block
                                    completion(succeeded, error);
                                    
                                }
                                
                            }];
                            
                        }
                        else{
                            
                            if(![AppDelegate handleParseError:error]){
                                
                                ///log error
                                NSString *errorString = [error userInfo][@"error"];
                                NSLog(@"Error fetching FR data: %@",errorString);
                                
                            }
                            
                            if (completion != NULL) {
                                
                                ///call the completion block
                                completion(NO, error);
                                
                            }
                            
                        }
                        
                    }];
                    
                    
                    
                }
                
            }];
            
        }
        
    }];
    
    
    
    
}


-(void)sendFriendRequestPushNotificationToUser:(PFUser *)user usingAlert:(PFObject *)sendFRAlert
{
    ///Create Payload data
    NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
    NSString *strPayloadFRMsgSuffix = nil;
#if APP_IER
    
    ///iER values
    strPayloadFRMsgSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"has sent you an %@ friend request!",nil),LOCALIZED_APP_NAME];
    
#else
    
    ///Cell 411 Values
    strPayloadFRMsgSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"has sent you a %@ friend request!",nil),LOCALIZED_APP_NAME];
#endif
 
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];

    dictData[kPayloadAlertKey] = [NSString stringWithFormat:@"%@ %@",strUserFullName,strPayloadFRMsgSuffix];
    dictData[kPayloadUserIdKey] = currentUser.objectId;
    dictData[kPayloadNameKey] = strUserFullName;
    dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeFriendRequest;
    dictData[kPayloadSoundKey] = @"default";///To play default sound
    dictData[kPayloadFRObjectIdKey] = sendFRAlert.objectId;
    dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:kInstallationUserKey equalTo:user];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:dictData];
    [push sendPushInBackground];
    

}

-(void)inviteFriendWithEmailId:(NSString *)strEmailId shouldShowMessageOnSuccessOrError:(BOOL)showMessageOnSuccessOrError withCompletion:(PFBooleanResultBlock)completion
{
    
    ///1.Check if email id is empty
    if (strEmailId.length == 0) {
        
        if (showMessageOnSuccessOrError) {
            
            ///Show message if it's asked to be shown
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Please enter a valid email address", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];

        }
        
        if (completion != NULL) {
            
            completion(NO, nil);
 
        }
         return;
        
    }
    
    ///Send an invite email first
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];

    NSString *currentUserEmailId = [C411StaticHelper getEmailFromUser:currentUser];
    currentUserEmailId = [currentUserEmailId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [C411StaticHelper sendInviteEmailTo:strEmailId from:strUserFullName withSenderEmail:currentUserEmailId andCompletion:^(id object, NSError *error) {
        
        
        if (!error) {
            
            ///Email sent successfully
            
            ///Check if invite has previously been sent to this email id or not
            PFQuery *checkInviteQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [checkInviteQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
            [checkInviteQuery whereKey:kCell411AlertToKey equalTo:strEmailId.lowercaseString];
            [checkInviteQuery whereKey:kCell411AlertEntryForKey equalTo:kEntryForFriendInvite];
            [checkInviteQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                
                if (!error) {
                    
                    ///Invite has previously been sent to this user before. Don't make an entry on Cell411Alert table again
                    
                    if (showMessageOnSuccessOrError) {
                        
                        ///As the email is sent so show the message to user that Invite is sent successfully
                        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Invite sent successfully", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    }
                    
                    if (completion != NULL) {
                        
                        completion(YES, nil);
                    }
                   
                }
                else if (error.code == kPFErrorObjectNotFound){
                    
                    ///Invite email has never been sent to this email id earlier
                    ///1. make an entry in Cell411Alert table for Invite
                    PFObject *sendInviteAlert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                    sendInviteAlert[kCell411AlertIssuedByKey] = currentUser;
                    sendInviteAlert[kCell411AlertIssuerFirstNameKey] = strUserFullName;
                    sendInviteAlert[kCell411AlertToKey] = strEmailId.lowercaseString;
                    sendInviteAlert[kCell411AlertStatusKey] = kAlertStatusPending;
                    sendInviteAlert[kCell411AlertEntryForKey] = kEntryForFriendInvite;
                    [sendInviteAlert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            
                            ///Invite entry made in parse
                            
                        }
                        else{
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    
                                    ///log the error
                                    NSString *errorString = [error userInfo][@"error"];
                                    NSLog(@"Error making email invite entry: %@",errorString);
                                    
                                }
                                
                            }
                            
                            ///Save it eventually
                            [sendInviteAlert saveEventually];
                            
                        }
                        
                        if (showMessageOnSuccessOrError) {
                            
                            ///As the email is sent so show the message to user that Invite is sent successfully
                            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Invite sent successfully", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                            
                        }
                        
                        if (completion != NULL) {
                            
                            completion(YES, nil);
                        }

                        
                    }];
                    
                }
                else{
                    
                    if(![AppDelegate handleParseError:error]){
                        
                        ///log the error
                        NSString *errorString = [error userInfo][@"error"];
                        //[C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        NSLog(@"Error checking whether email invite is previously sent or not: %@",errorString);
                    }
                    
                    if (showMessageOnSuccessOrError) {
                        
                        ///As the email is sent so show the message to user that Invite is sent successfully
                        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Invite sent successfully", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        
                    }
                    
                    
                    if (completion != NULL) {
                        
                        completion(YES, nil);
                    }

                }
                
            }];

            
        }
        else{
            ///Error sending email, show error
            if(showMessageOnSuccessOrError){
        
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];

            }
            
            if (completion != NULL) {
                
                completion(NO,error);
            }
        
        }
        
        
    }];

}

-(void)sendSMSInviteToFriendWithPhoneNumber:(NSString *)strPhoneNumber withCompletion:(PFBooleanResultBlock)completion
{
    
    ///1.Check if phone number is empty
    if (strPhoneNumber.length == 0) {
        
        NSLog(@"Phone number is empty");
        if (completion != NULL) {
            
            completion(NO, nil);
            
        }
        return;
        
    }
    
    ///Send an invite sms first
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
    NSString *strContactNumber = strPhoneNumber;
    if (![strContactNumber hasPrefix:@"+"]) {
        ///Add + if it's not there
        strContactNumber = [@"+" stringByAppendingString:strContactNumber];
    }
    
    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ invited you to install %@ to respond to emergencies: %@", nil),strUserFullName,LOCALIZED_APP_NAME,DOWNLOAD_APP_URL];
    [ServerUtility sendSms:strMessage onNumber:strContactNumber withCompletion:^(NSError *error, id data) {
        
        if (!error) {
            
            ///SMS sent successfully
            
            ///Check if invite has previously been sent to this phone number or not
            PFQuery *checkInviteQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [checkInviteQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
            [checkInviteQuery whereKey:kCell411AlertToKey equalTo:strPhoneNumber];
            [checkInviteQuery whereKey:kCell411AlertEntryForKey equalTo:kEntryForFriendInvite];
            [checkInviteQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                
                if (!error) {
                    
                    ///Invite has previously been sent to this number before. Don't make an entry on Cell411Alert table again
                    
                    if (completion != NULL) {
                        
                        completion(YES, nil);
                    }
                    
                }
                else if (error.code == kPFErrorObjectNotFound){
                    
                    ///Invite sms has never been sent to this phone number earlier
                    ///1. make an entry in Cell411Alert table for Invite
                    PFObject *sendInviteAlert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                    sendInviteAlert[kCell411AlertIssuedByKey] = currentUser;
                    sendInviteAlert[kCell411AlertIssuerFirstNameKey] = strUserFullName;
                    sendInviteAlert[kCell411AlertToKey] = strPhoneNumber;
                    sendInviteAlert[kCell411AlertStatusKey] = kAlertStatusPending;
                    sendInviteAlert[kCell411AlertEntryForKey] = kEntryForFriendInvite;
                    [sendInviteAlert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            
                            ///Invite entry made in parse
                            
                        }
                        else{
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    
                                    ///log the error
                                    NSString *errorString = [error userInfo][@"error"];
                                    NSLog(@"Error making email invite entry: %@",errorString);
                                    
                                }
                                
                            }
                            
                            ///Save it eventually
                            [sendInviteAlert saveEventually];
                            
                        }
                        
                        
                        if (completion != NULL) {
                            
                            completion(YES, nil);
                        }
                        
                        
                    }];
                    
                }
                else{
                    
                    if(![AppDelegate handleParseError:error]){
                        
                        ///log the error
                        NSString *errorString = [error userInfo][@"error"];
                        //[C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        NSLog(@"Error checking whether email invite is previously sent or not: %@",errorString);
                    }
                    
                    if (completion != NULL) {
                        
                        completion(YES, nil);
                    }
                    
                }
                
            }];
            
            
        }
        else{
            
            ///Error sending sms, show error
            if (completion != NULL) {
                
                completion(NO,error);
            }
            
        }

        
    }];
    
}

/*
-(void)inviteFriendWithEmailId:(NSString *)strEmailId
{
    
    ///1.Check if email id is empty
    if (strEmailId.length == 0) {
        
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Please enter a valid email address", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
        return;
        
    }
    
    
    ///Check if invite has already been sent to this email id or not
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *currentUserEmailId = [C411StaticHelper getEmailFromUser:currentUser];
    currentUserEmailId = [currentUserEmailId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    PFQuery *checkInviteQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [checkInviteQuery whereKey:kCell411AlertIssuedByKey equalTo:currentUser];
    [checkInviteQuery whereKey:kCell411AlertToKey equalTo:strEmailId.lowercaseString];
    [checkInviteQuery whereKey:kCell411AlertEntryForKey equalTo:kEntryForFriendInvite];
    [checkInviteQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (!error) {
            
            ///Invite has already been sent to this user before. Don't make an entry on Cell411Alert table and just send invite email again
            [C411StaticHelper sendInviteEmailTo:strEmailId from:[C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]] withSenderEmail:currentUserEmailId andCompletion:^(id object, NSError *error) {
                
                
                if (!error) {
                    
                    ///Invite sent successfully
                    [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Invite sent successfully", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                }
                else{
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
                
            }];
            
            
        }
        else if (error.code == kPFErrorObjectNotFound){
            
            ///Invite email has never been sent to this email id
            NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
            ///1. make an entry in Cell411Alert table for Invite
            PFObject *sendInviteAlert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
            sendInviteAlert[kCell411AlertIssuedByKey] = currentUser;
            sendInviteAlert[kCell411AlertIssuerFirstNameKey] = strUserFullName;
            sendInviteAlert[kCell411AlertToKey] = strEmailId.lowercaseString;
            sendInviteAlert[kCell411AlertStatusKey] = kAlertStatusPending;
            sendInviteAlert[kCell411AlertEntryForKey] = kEntryForFriendInvite;
            [sendInviteAlert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                
                if (succeeded) {
                    
                    ///Invite entry made in parse, now send an invite email

                    [C411StaticHelper sendInviteEmailTo:strEmailId from:strUserFullName withSenderEmail:currentUserEmailId andCompletion:^(id object, NSError *error) {
                        
                        
                        if (!error) {
                            
                            ///Invite sent successfully
                            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Invite sent successfully", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                            
                        }
                        else{
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        }
                        
                        
                    }];
                    
                    
                }
                else{
                    
                    if (error) {
                        if(![AppDelegate handleParseError:error]){
                            
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        }
                    }
                    
                }
                
            }];
            
        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            }
            
        }
        
    }];
    
    
}
*/


-(void)showUpdateEmailPopupForUser:(PFUser *)user fromViewController:(UIViewController *)viewController withCompletion:(PFBooleanResultBlock)completion
{
    
    NSString *strAlertTitle = NSLocalizedString(@"Email Required", nil);
    NSString *strMessage = NSLocalizedString(@"Please update your email.", nil);
    NSString *strPlaceholder = NSLocalizedString(@"Enter your email", nil);

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:strAlertTitle
                                          message:strMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf  = self;
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = strPlaceholder;
         textField.tag = TXT_TAG_ALERT_EMAIL;
         textField.delegate = weakSelf;
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped cancel,
                                       if (completion != NULL) {
                                           
                                           ///Pass no, as user cancelled
                                           completion(NO, nil);
                                           
                                       }
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
 
                                   }];
    UIAlertAction *submitAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Submit", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     ///User tapped Submit
                                     UITextField *txtEmail = alertController.textFields.firstObject;
                                     NSString *strEmail = txtEmail.text;
                                     if (strEmail.length > 0) {
                                         ///trim the white spaces
                                         strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                     }
                                     
                                     [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                         ///Do other task in next runloop, to avoid present another alert on top of another.Update current user email
                                         ///show the progress hud
                                         [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
                                         
                                        [C411StaticHelper updateEmail:strEmail.lowercaseString forUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                                            
                                            if (error) {
                                                
                                                ///show error
                                                NSString *errorString = [error userInfo][@"error"];
                                                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:viewController];
                                                
                                                    
                                               
                                            }
                                            
                                            ///Hide hud
                                            [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                                            
                                            ///call completion block if provided and pass the result
                                            if (completion != NULL) {
                                                
                                                completion(succeeded, error);
                                                
                                            }
                                            
                                        }];
                                         
                                     }];
                                    
                                     ///Dequeue the current Alert Controller and allow other to be visible
                                     [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                     
                                 }];
    
        ///disable submit action and save it's reference in ivar to enable it later
        submitAction.enabled = NO;
        self.submitAction = submitAction;
    
    [alertController addAction:cancelAction];
    [alertController addAction:submitAction];
    //[viewController presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

    
}

+(NSArray *)getSupportedVideoResolutions
{
    return @[ @"320x240"
             ,@"352x288"
             ,@"640x480"
             ,@"HD (720p)"
             ,@"HD (1080p)"
             ];
}

+(NSString *)getDefaultVideoResolution
{
    return @"640x480";
}

+(CGSize)getVideoSizeForResolution:(NSString *)strVideoResolution
{
    CGSize videoSize = CGSizeZero;
    
    if ([strVideoResolution isEqualToString:@"320x240"]) {
        
        videoSize = (CGSize){320,240};
    }
    else if ([strVideoResolution isEqualToString:@"352x288"]) {
        
        videoSize = (CGSize){352,288};
    }
    else if ([strVideoResolution isEqualToString:@"640x480"]) {
        
        videoSize = (CGSize){640,480};
    }
    else if ([strVideoResolution isEqualToString:@"HD (720p)"]) {
        
        videoSize = (CGSize){1280,729};
    }
    else if ([strVideoResolution isEqualToString:@"HD (1080p)"]) {
        
        videoSize = (CGSize){1920,1080};
    }
    
    return videoSize;
}

+(BOOL)canShowSecurityGuardOption
{
    
#if ALERT_TO_PORTAL_USERS
    ///Yes for apps, that allows sending alert to Portal Users(or Security Guards)
    return YES;
    
#else
    ///No for apps that don't allow sending alert to Portal Users(or Security Guards)
    return NO;
    
#endif
    
}

+(BOOL)isBroadcastEnabled
{

#if BROADCAST_ENABLED
    ///Yes for apps, that allows super admin to broadcast custom alert(For General information) to all the users of the app
    return YES;
    
#else
    ///No for apps that don't allow broadcasting custom alert(For General information) to all the users of the app
    return NO;
    
#endif
    
}


-(void)rejectFriendRequest:(PFObject *)friendRequest withCompletion:(PFBooleanResultBlock)completion
{

    ///Save deny status to friend request object
    friendRequest[kCell411AlertStatusKey] = kAlertStatusDenied;
    
    ///Save it in background
    [friendRequest saveEventually];
    
    if (completion != NULL) {
        
        completion(YES,nil);
    }

}

-(void)approveFriendRequestWithId:(NSString *)strFriendRequestId fromUserWithId:(NSString *)strUserId fullName:(NSString *)strFullName andCompletion:(PFBooleanResultBlock)completion
{
    
    ///User Approved the friend request
    __weak typeof(self) weakSelf = self;
    
    ///1.make an entry in the Task table
    PFObject *addFriendTask = [PFObject objectWithClassName:kTaskClassNameKey];
    addFriendTask[kTaskAssigneeUserIdKey] = [AppDelegate getLoggedInUser].objectId;
    addFriendTask[kTaskUserIdKey] = strUserId;
    addFriendTask[kTaskTaskKey] = kTaskFriendAdd;
    addFriendTask[kTaskStatusKey] = kTaskStatusPending;
    [addFriendTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (succeeded) {
            ///An entry has been made on task table to add friend, now make the status to approved on Cell411Alert table
            ///2.Get Cell411Alert object
            PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [getCell411AlertQuery whereKey:@"objectId" equalTo:strFriendRequestId];
            [getCell411AlertQuery selectKeys:@[kCell411AlertStatusKey]];
            [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                
                if (!error && objects.count > 0) {
                    ///Object found, now update the status to approved
                    PFObject *cell411Alert = [objects firstObject];
                    
                    cell411Alert[kCell411AlertStatusKey] = kAlertStatusApproved;
                    
                    ///3.Save status in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            ///Status saved successfully
                            ///4.Send FRIEND_APPROVED push notification
                            ///Create Payload data
                            PFUser *currentUser = [AppDelegate getLoggedInUser];
                            NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                            
                            NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                            dictData[kPayloadAlertKey] = [NSString stringWithFormat:@"%@ %@",strUserFullName,NSLocalizedString(@"approved your friend request!", nil)];
                            dictData[kPayloadUserIdKey] = currentUser.objectId;
                            dictData[kPayloadTaskIdKey] = addFriendTask.objectId;
                            dictData[kPayloadNameKey] = strUserFullName;
                            dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeFriendApproved;
                            dictData[kPayloadSoundKey] = @"default";///To play default sound
                            dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                            
                            // Create our Installation query
                            PFQuery *pushQuery = [PFInstallation query];
                            PFQuery *innerQuery = [PFUser query];
                            [innerQuery whereKey:@"objectId" equalTo:strUserId];
                            [pushQuery whereKey:kInstallationUserKey matchesQuery:innerQuery];
                            
                            
                            
                            // Send push notification to query
                            PFPush *push = [[PFPush alloc] init];
                            [push setQuery:pushQuery]; // Set our Installation query
                            [push setData:dictData];
                            [push sendPushInBackground];
                            
                            ///5. Show add friend back alert, if needed
                            if(strUserId.length >0){
                                
                                ///1.Check if the user with is Id is already a friend of current user, if its not in the friendlist of current user then only display the add friend back alert
                                if (self.arrFriends) {
                                    ///friends array available, so check it locally
                                    BOOL isAlreadyFriend = NO;
                                    for (PFUser *friend in self.arrFriends) {
                                        
                                        if ([friend.objectId isEqualToString:strUserId]) {
                                            ///This user is already current user's friend
                                            isAlreadyFriend = YES;
                                            break;
                                            
                                        }
                                        
                                    }
                                    
                                    if (!isAlreadyFriend) {
                                        ///Show add friend alert as this is not in user's friend list
                                        [weakSelf showAddFriendBackAlertForUserWithId:strUserId andName:strFullName];
                                    }
                                    
                                }
                                else{
                                    
                                    ///Friends array is not available, so verify from parse whether this user is added or not
                                    PFRelation *friendRelation = [[AppDelegate getLoggedInUser] relationForKey:kUserFriendsKey];
                                    PFQuery *getFriendQuery = [friendRelation query];
                                    [getFriendQuery whereKey:@"objectId" equalTo:strUserId];
                                    [getFriendQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                                        
                                        if (!error) {
                                            
                                            
                                            ///The user who sent friend request is already current user's friend, so don't show add friend back alert
                                            PFUser *user = (PFUser *)object;
                                            NSLog(@"This user is already in a current user's friend list, %@,%@",user.username,user.objectId);
                                            
                                        }
                                        else if (error.code == kPFErrorObjectNotFound){
                                            
                                            ///The user who sent friend request is not current user's friend, so show add friend back alert
                                            [weakSelf showAddFriendBackAlertForUserWithId:strUserId andName:strFullName];
                                            
                                        }
                                        else{
                                            
                                            if(![AppDelegate handleParseError:error]){
                                                ///Some error occured, do nothing
                                                NSString *errorString = [error userInfo][@"error"];
                                                NSLog(@"#Error: %@",errorString);
                                            }
                                        }
                                        
                                    }];
                                    
                                }
                            }
                            
                            
                            
                            
                            
                        }
                        else {
                            
                            if(![AppDelegate handleParseError:error]){
                                ///Error occured saving approved status on Cell411Alert object, show error
                                NSString *errorString = [error userInfo][@"error"];
                                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                NSLog(@"#error fetching cell411alert :%@",errorString);
                            }
                            ///remove task set earlier,because FR status couldn't be set to APPROVED and thus this task doesn't makes sense. The user will be displayed FR alert again in the future and to handle this again
                            [addFriendTask deleteEventually];
                            
                            
                            
                        }
                        
                        ///Call the completion block without waiting for showing add friend back alert (if success) as that's an independednt operation
                        if (completion != NULL) {
                            
                            completion(succeeded, error);
                        }
                        
                        
                    }];
                    
                }
                else {
                    
                    if(![AppDelegate handleParseError:error]){
                        ///Error occured finding Cell411Alert object, show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        NSLog(@"#error fetching cell411alert :%@",errorString);
                        
                    }
                    
                    ///remove task set earlier,because FR status couldn't be set to APPROVED and thus this task doesn't makes sense. The user will be displayed FR alert again in the future and to handle this again
                    [addFriendTask deleteEventually];
                    
                    ///Call the completion block
                    if (completion != NULL) {
                        
                        completion(NO, error);
                    }
                    
                }
                
                
                
            }];
            
            
            
            
        }
        else{
            
            if (error) {
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
                ///Call the completion block
                if (completion != NULL) {
                    
                    completion(NO, error);
                }
            }
            
        }
        
        
    }];
    
    
}

-(void)getCellsInBackgroundWithBlock:(PFArrayResultBlock)completion
{
    
    PFUser *currentUser = [PFUser currentUser];///This should be fetched from parse only as it is created at the time of signup and before setting isLoggedIn flag
    PFQuery *getCellsQuery = [PFQuery queryWithClassName:kCellClassNameKey];
    [getCellsQuery includeKey:kCellMembersKey];
    [getCellsQuery whereKey:kCellCreatedByKey equalTo:currentUser];
    ///Append clause to ignore Default Cell named as Friends
    [getCellsQuery whereKey:kCellTypeKey notEqualTo:@(PrivateCellTypeFriends)];
    [getCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
    }];
    
}

-(void)getFriendsinBackgroundWithBlock:(PFArrayResultBlock)completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFRelation *getFriendsRelation = [currentUser relationForKey:kUserFriendsKey];
    [[getFriendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
        
    }];
}

-(void)addPvtCellWithName:(NSString *)strCellName
{
    
    ///1.Check if cell name is empty
    if (strCellName.length == 0) {
        ///Show toast on root view controller by passing nil as view
        [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Please enter Cell name", nil)];
        
        return;
        
    }
    
    ///Create weak reference of self
    __weak typeof(self) weakSelf = self;

    ///Check if cell list is available or not making sure that property initializer doesn't get called
    if (!_arrCells) {
        
        ///Private cells list is not yet fetched, get the private cells first
        [weakSelf getCellsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (!error) {
                
                weakSelf.arrCells = [NSMutableArray arrayWithArray:objects];
                
                ///Post notification that cell list updated
                [[NSNotificationCenter defaultCenter]postNotificationName:kCellsListUpdatedNotification object:nil];
                
                ///Call recursively same function to create cell
                [weakSelf addPvtCellWithName:strCellName];
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
                
            }

        }];
        
    }
    else{
        
        ///2.Private Cells list available check if this cell is already added or not
        for (PFObject *cell in self.arrCells) {
            
            if ([[[C411StaticHelper getLocalizedNameForCell:cell]lowercaseString] isEqualToString:strCellName.lowercaseString]) {
                
                ///cell exist with this name
                NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ already created",nil),strCellName];
                ///Show toast on root view controller by passing nil as view
                [AppDelegate showToastOnView:nil withMessage:strMessage];
                
                return;
                
            }
            
        }
        
        
        ///Create a Cell object
        PFObject *cell = [PFObject objectWithClassName:kCellClassNameKey];
        cell[kCellCreatedByKey] = [AppDelegate getLoggedInUser];
        cell[kCellNameKey] = strCellName;
        
        ///Save it in background
        [cell saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            
            if (succeeded) {
                
                ///1.Ask cells delegate to add this cell to its array and post notification when added to update the cells list
                [weakSelf addCell:cell];
                
            }
            else{
                
                if (error) {
                    if(![AppDelegate handleParseError:error]){
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    }
                }
                
            }
            
            
        }];
        
    }
    
    
}

-(void)setCurrentUserHasSeenAlert:(PFObject *)cell411Alert
{
    PFRelation *seenByRelation = [cell411Alert relationForKey:kCell411AlertSeenByKey];
    [seenByRelation addObject:[AppDelegate getLoggedInUser]];
    ///Save it in background
    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
            
            ///save it eventually if error occured
            [cell411Alert saveEventually];
            
        }
        
    }];
}

-(BOOL)canDownloadMyData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *numDisableUntil = [defaults objectForKey:kDisableDownloadMyDataUntilKey];
    if (numDisableUntil) {
        NSTimeInterval disableUntil = [numDisableUntil doubleValue];
        NSTimeInterval nowTime = [[NSDate date]timeIntervalSince1970];
        return (nowTime > disableUntil);
    }
    return YES;
}

-(void)recordMyDataDownloadTime {
    ///Get time till next download is disabled
    NSTimeInterval disableUntil = [[NSDate date]timeIntervalSince1970] + DOWNLOAD_DATA_TIME_LIMIT;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(disableUntil) forKey:kDisableDownloadMyDataUntilKey];
    [defaults synchronize];
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(NSMutableArray *)arrFriends
{
    if (!_arrFriends) {
        __weak typeof(self) weakself = self;
        [self getFriendsinBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                weakself.arrFriends = [NSMutableArray arrayWithArray:objects];
                
                ///Post notification that friend list updated
                [[NSNotificationCenter defaultCenter]postNotificationName:kFriendListUpdatedNotification object:nil];
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
                
            }
            
            
            
        }];
        
    }
    
    return _arrFriends;
}


-(NSMutableArray *)arrCells
{
    if (!_arrCells) {
        __weak typeof(self) weakself = self;
        //        PFUser *currentUser = [AppDelegate getLoggedInUser];
        //        PFQuery *getCellsQuery = [PFQuery queryWithClassName:kCellClassNameKey];
        //        [getCellsQuery includeKey:kCellMembersKey];
        //        [getCellsQuery whereKey:kCellCreatedByKey equalTo:currentUser];
        [self getCellsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                weakself.arrCells = [NSMutableArray arrayWithArray:objects];
                
                ///Post notification that cell list updated
                [[NSNotificationCenter defaultCenter]postNotificationName:kCellsListUpdatedNotification object:nil];
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
                
            }
            
            
            
        }];
        
    }
    
    return _arrCells;
}

-(NSMutableArray *)arrFakeDeletedVideos
{
    if (!_arrFakeDeletedVideos) {
        
        _arrFakeDeletedVideos = [NSMutableArray array];
    }
    
    return _arrFakeDeletedVideos;
    
}

#if NON_APP_USERS_ENABLED
-(NSMutableArray *)arrNonAppUserCells
{
    if (!_arrNonAppUserCells) {
        __weak typeof(self) weakself = self;
        [self getNonAppUserCellsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                weakself.arrNonAppUserCells = [NSMutableArray arrayWithArray:objects];
                
                ///Post notification that cell list updated
                [[NSNotificationCenter defaultCenter]postNotificationName:kNonAppUserCellsListUpdatedNotification object:nil];
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
            }
            
            
            
        }];
        
    }
    
    return _arrNonAppUserCells;
}
#endif


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)removeFriendFromUserCells:(PFUser *)friend
{
    BOOL isDirty = NO;
    
    for (PFObject *cell in self.arrCells) {
        
        NSMutableArray *arrCellMembers = cell[kCellMembersKey];
        ///Iterate the members of the cell and remove friend if exist
        for (NSUInteger index = 0; index < arrCellMembers.count; index++) {
            
            PFUser *member = [arrCellMembers objectAtIndex:index];
            if ([member.objectId isEqualToString:friend.objectId]) {
                ///remove friend from cell
                [arrCellMembers removeObjectAtIndex:index];
                cell[kCellMembersKey] = arrCellMembers;
                [cell saveEventually];
                isDirty = YES;
                break;
            }
            
        }
        
    }
    
    if (isDirty) {
        ///Friend was available in some cells and has been removed now
        [[NSNotificationCenter defaultCenter]postNotificationName:kCellsMembersUpdatedNotification object:nil];
        
    }
}


-(void)rejectFriendRequestWithId:(NSString *)strFriendRequestId  andCompletion:(PFBooleanResultBlock)completion
{

    ///User tapped Deny, i.e rejected the friend request
    //1. update this on parse
    PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [getCell411AlertQuery whereKey:@"objectId" equalTo:strFriendRequestId];
    [getCell411AlertQuery selectKeys:@[kCell411AlertStatusKey]];
    __weak typeof(self) weakSelf = self;
    [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (!error && objects.count > 0) {

            PFObject *cell411Alert = [objects firstObject];

            [weakSelf rejectFriendRequest:cell411Alert withCompletion:completion];
            
        }
        else {
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            }
            
            if (completion != NULL) {
                ///Call the completion block
                completion(NO,error);
                
            }
        }
        
        
        
    }];

}

-(void)showAddFriendBackAlertForUserWithId:(NSString *)strUserId andName:(NSString *)strFullName
{
    
    if (strUserId.length > 0) {
        
        ///1. Create title and msg
        NSString *strFirstName = [[strFullName componentsSeparatedByString:@" "]firstObject];
        NSString *strAlertTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"Friend %@",nil),strFirstName];
        NSString *strMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"Do you also want to add %@ back as a %@ friend?",nil), strFullName,LOCALIZED_APP_NAME];
        
        ///2.Create action button titles
        NSString *strNo = NSLocalizedString(@"No", nil);
        NSString *strAdd =[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Add", nil),strFirstName];
        
        
        ///Show alert message
        UIAlertController *addFAAlert = [UIAlertController alertControllerWithTitle:strAlertTitle message:strMsg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:strNo style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            ///User tapped No, so he don't want to add this friend back to his/her friend list
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:strAdd style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            ///User tapped on Add,so add this friend to user's friend list
            
            ///1. Get friend with user id
            __weak typeof(self) weakSelf = self;
            PFQuery *getUserQuery = [PFUser query];
            [getUserQuery whereKey:@"objectId" equalTo:strUserId];
            [getUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                
                if (!error) {
                    
                    ///Found user object
                    ///2. Update the current user's friend relation column by adding this user
                    PFUser *userFriend = (PFUser *)object;
                    PFUser *currentUser = [AppDelegate getLoggedInUser];
                    PFRelation *friendRelation = [currentUser relationForKey:kUserFriendsKey];
                    ///add friend to relation
                    [friendRelation addObject:userFriend];
                    
                    ///save current user object
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            ///Friend Added back successfully
                            ///3.Refresh the friend list
                            [weakSelf updateFriends];
                            
                            ///set SECOND privilege if applicable
                            [C411StaticHelper setSecondPrivilegeIfApplicableForUser:currentUser];
                            
                            ///Show add friend to cell popup
                            [weakSelf showAddFriendToCellPopup:userFriend];
                            
                        }
                        else{
                            ///some error occured adding friend back to current user's friend list
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                }
                            }
                            
                        }
                        
                    }];
                    
                    
                }
                else if (error.code == kPFErrorObjectNotFound){
                    
                }
                else{
                    
                    if(![AppDelegate handleParseError:error]){
                        
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    }
                    
                }
                
            }];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [addFAAlert addAction:noAction];
        [addFAAlert addAction:addAction];
        //[[AppDelegate sharedInstance].window.rootViewController presentViewController:addFAAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:addFAAlert];

        
    }
    
}


-(void)showAddFriendToCellPopup:(PFObject *)userFriend
{
    
    if (userFriend) {
        
        ///Get top vc reference
        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
        ///Load popup view from nib
        C411AddFriendToCellPopup *vuAddFriendToCellPopup = [[[NSBundle mainBundle] loadNibNamed:@"C411AddFriendToCellPopup" owner:self options:nil] lastObject];
        vuAddFriendToCellPopup.arrCellGroups = self.arrCells;
        vuAddFriendToCellPopup.userFriend = userFriend;
        [vuAddFriendToCellPopup setupViews];
       ///Set view frame
        vuAddFriendToCellPopup.frame = rootVC.view.bounds;
        
        NSInteger cancelIndex = 0;
        
        vuAddFriendToCellPopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
            
            if (actionIndex == cancelIndex) {
                
                ///user chosen not now option, do nothing
                
            }
            else{
                
                ///User chose Add this friend to selected cell
                PFObject *cell = customObject;
                if (cell) {
                    ///1. Get cell members array
                    NSMutableArray *arrCellMembers = cell[kCellMembersKey];
                    ///2. Create array if its nil
                    if (!arrCellMembers) {
                        arrCellMembers = [NSMutableArray array];
                    }
                    ///3. Add this friend
                    [arrCellMembers addObject:userFriend];
                    ///4.update cell members array
                    cell[kCellMembersKey] = arrCellMembers;
                    [cell saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            
                            ///Post notification that cell members has been updated
                            [[NSNotificationCenter defaultCenter]postNotificationName:kCellsMembersUpdatedNotification object:nil];
                            
                            
                            ///User saved to cell
                            NSLog(@"Friend added successfully");
                            
                        }
                        else{
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                }
                            }
                            
                        }
                        
                        
                    }];
                    
                    
                }
                
            }
            
            
        };
        
        ///Add popup view in next run loop
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            [rootVC.view addSubview:vuAddFriendToCellPopup];
            [rootVC.view bringSubviewToFront:vuAddFriendToCellPopup];
           
        }];
        
        
    }
    
}


-(void)showNeedyAlertWithAlertPayload:(C411AlertNotificationPayload *)alertPayload andCanRespondToAlert:(BOOL)canRespondToAlert
{
    
    if (alertPayload && alertPayload.strCell411AlertId) {
        
        ///get the Cell 411 alert object from parse associated to alert
        __weak typeof(self) weakSelf = self;
        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
        [getCell411AlertQuery selectKeys:@[
                                           kCell411AlertIssuedByKey,
                                           kCell411AlertInitiatedByKey,
                                           kCell411AlertRejectedByKey,
                                           kCell411AlertSeenByKey
                                           ]];
        [getCell411AlertQuery includeKeys:@[kCell411AlertIssuedByKey]];
        [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
            
            if (!error && object) {
                
                if(![AppDelegate getLoggedInUser]){
                    ///Return if user is not logged in
                    return;
                }
                
                ///User found pass it emergency popup class
                PFObject *cell411Alert = object;
                PFUser *alertIssuer = cell411Alert[kCell411AlertIssuedByKey];
                
                ///Get top vc reference
                UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
                ///Load popup view from nib
                C411EmergencyAlertPopup *vuEmergencyAlertPopup = [[[NSBundle mainBundle] loadNibNamed:@"C411EmergencyAlertPopup" owner:weakSelf options:nil] lastObject];
                
                vuEmergencyAlertPopup.canRespondToAlert = canRespondToAlert;
                vuEmergencyAlertPopup.cell411Alert = cell411Alert;
                vuEmergencyAlertPopup.alertIssuer = alertIssuer;
                vuEmergencyAlertPopup.alertPayload = alertPayload;///this must be the last property to be set
                vuEmergencyAlertPopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
                
                    ///Do anything on close
                    
                    
                };
                ///Set view frame
                vuEmergencyAlertPopup.frame = rootVC.view.bounds;
                ///Add popup view in next run loop
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    
                    [rootVC.view addSubview:vuEmergencyAlertPopup];
                    [rootVC.view bringSubviewToFront:vuEmergencyAlertPopup];
                    
                }];

            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
        }];

        
    }
    
    
    
}

///Helper notification Helper method
-(void)showHelperAlertWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    if (alertPayload) {
        
        NSString *strAlertMsgPrefix = alertPayload.strFullName;
        if (alertPayload.strCellName.length > 0) {
            
            ///help recieved from public cell member
            strAlertMsgPrefix = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, a member of %@",nil),alertPayload.strFullName, alertPayload.strCellName];
            
        }
        if (alertPayload.strForwardedBy.length > 0) {
            ///Help recieved from forwarded alert, modify the message
            strAlertMsgPrefix = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, a friend of %@",nil),alertPayload.strFullName, alertPayload.strForwardedBy];
        }
        else if ([alertPayload.strUserType isEqualToString:kUserTypeFacebook]){
            
            ///Alert responded by anonymous(logged out) facebook user
            strAlertMsgPrefix = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, a Facebook user",nil),alertPayload.strFullName];
        }
        NSMutableString *strAlertMessage = alertPayload.strDuration.length > 0 ? [NSMutableString localizedStringWithFormat:NSLocalizedString(@"%@ is %@ away and is on the way to help you out",nil),strAlertMsgPrefix,alertPayload.strDuration]:[NSMutableString localizedStringWithFormat:NSLocalizedString(@"%@ is on the way to help you out",nil),strAlertMsgPrefix];
        
        alertPayload.strAdditionalNote.length > 0 ? [strAlertMessage appendFormat:@": %@",alertPayload.strAdditionalNote] : [strAlertMessage appendString:@"."];
        [C411StaticHelper showAlertWithTitle:nil message:strAlertMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
    }
    
    
}

///Rejector notification Helper method
-(void)showRejectorAlertWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    if (alertPayload) {
        NSString *strAlertMessage = alertPayload.strAdditionalNote.length > 0 ? [NSString localizedStringWithFormat:NSLocalizedString(@"%@ can't help you this time: %@",nil),alertPayload.strFullName,alertPayload.strAdditionalNote]:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ can't help you this time.",nil),alertPayload.strFullName];
       [C411StaticHelper showAlertWithTitle:nil message:strAlertMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
    }
    
}

-(void)updateAdditonalNoteTable:(NSString *)strTableName withAdditionalNoteId:(NSString *)strAdditionalNoteId andSeenStatus:(NSNumber *)seen
{
    ///set status as seen for additional Note
    PFQuery *fetchAdditionalNoteQuery = [PFQuery queryWithClassName:strTableName];
    [fetchAdditionalNoteQuery whereKey:@"objectId" equalTo:strAdditionalNoteId];
    [fetchAdditionalNoteQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            PFObject *additonalNote = object;
            additonalNote[kAdditionalNoteSeenKey] = seen;
            [additonalNote saveEventually];
            
        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#error fetching cell411alert :%@",errorString);
            }
            
        }
        
    }];
    
    
}

-(void)updateRideResponseWithId:(NSString *)strRideResponseId withSeenByDriverStatus:(NSNumber *)seenByDriver
{
    ///set seenByDriver on RideResponse Table
    PFQuery *fetchRideResponseQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
    [fetchRideResponseQuery whereKey:@"objectId" equalTo:strRideResponseId];
    [fetchRideResponseQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            PFObject *rideResponse = object;
            rideResponse[kRideResponseSeenByDriverKey] = seenByDriver;
            [rideResponse saveEventually];
            
        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#error fetching rideResponse :%@",errorString);
            }
            
        }
        
    }];
    
    
}


///Video Streaming notification helper method
-(void)showVideoStreamingAlertWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    if (alertPayload && alertPayload.strCell411AlertId) {
        
        ///get the Cell 411 alert object from parse associated to alert
        __weak typeof(self) weakSelf = self;
        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
        [getCell411AlertQuery selectKeys:@[
                                           kCell411AlertInitiatedByKey,
                                           kCell411AlertRejectedByKey,
                                           kCell411AlertSeenByKey
                                           ]];
        [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
            
            if (!error && object) {
                PFUser *currentUser = [AppDelegate getLoggedInUser];
                if(!currentUser){
                    ///Return if user is not logged in
                    return;
                }
                
                ///Alert found, show it to user
                PFObject *cell411Alert = object;
                ///Update seenBy
                [weakSelf setCurrentUserHasSeenAlert:cell411Alert];
                NSString *strAlertTitle = NSLocalizedString(@"Video Streaming Alert", nil);
                
                ///3.Create Alert Message
                NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is streaming live video. Would you like to watch it? You can also watch this video later from Alerts tab",nil),alertPayload.strFullName];
                
                if ([alertPayload.strStatus isEqualToString:kAlertStatusVOD]) {
                    
                    strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ has streamed live video. Would you like to watch it? You can also watch this video later from Alerts tab",nil),alertPayload.strFullName];
                }

                ///Append an informational msg as a prefix to alert msg if global alert is issued so that no one get confused
                if (alertPayload.isGlobalAlert) {
                    
                    if ([currentUser[kUserPatrolModeKey]boolValue]) {
                        
                        ///Patrol mode is still on
                        strMessage = [NSMutableString stringWithFormat:@"%@. %@",NSLocalizedString(@"You are in a Patrol Mode and recieved a Global Alert", nil),strMessage];
                        
                    }
                    else{
                        
                        ///Patrol mode is now off
                        strMessage = [NSMutableString stringWithFormat:@"%@. %@",NSLocalizedString(@"You recieved a Global Alert", nil),strMessage];
                    }
                }
                
                ///4.Create action button titles
                NSString *strLater = NSLocalizedString(@"Later", nil);
                
                NSString *strWatchNow = NSLocalizedString(@"Watch Now", nil);
                
                ///Show alert message
                UIAlertController *videoStreamingAlert = [UIAlertController alertControllerWithTitle:strAlertTitle message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *laterAction = [UIAlertAction actionWithTitle:strLater style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    ///User tapped to watch video Later
                    //1. update this on parse
                    PFRelation *rejectedRelation = [cell411Alert relationForKey:kCell411AlertRejectedByKey];
                    [rejectedRelation addObject:currentUser];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (error) {
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                        }
                    }];
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                }];

                UIAlertAction *watchNowAction = [UIAlertAction actionWithTitle:strWatchNow style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    ///User Initiated to watch video now
                    ///1. update this on parse
                    PFRelation *initiatedByRelation = [cell411Alert relationForKey:kCell411AlertInitiatedByKey];
                    [initiatedByRelation addObject:currentUser];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                            
                        }
                        
                        
                    }];
                    
                    ///Show the video
                    ///1.Make url
                    
                    NSString *strVideoStreamUrl = nil;
                    NSString *strStreamName = [NSString stringWithFormat:@"%@_%.0lf",alertPayload.strUserId,alertPayload.createdAtInMillis];
                    //                if ([alertPayload.strStatus isEqualToString:kAlertStatusLive]) {
                    //
                    //                    strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/live/%@/playlist.m3u8",CNAME,strStreamName];
                    //                }
                    //                else if ([alertPayload.strStatus isEqualToString:kAlertStatusVOD]) {
                    //
                    //                    strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/vod/%@/playlist.m3u8",CNAME,strStreamName];
                    //                }
                    ///using dvr now to fix url issue when switcing to live/vod. dvr option will work for both with same url
                    strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/%@/%@/playlist.m3u8?DVR",CNAME,WZA_APP_NAME,strStreamName];
                    
                    ///2.Play video
                    if (strVideoStreamUrl.length > 0) {
                        
                        NSURL *videoStreamUrl = [NSURL URLWithString:strVideoStreamUrl];
                        if ([[UIApplication sharedApplication]canOpenURL:videoStreamUrl]) {
                            
                            [[UIApplication sharedApplication]openURL:videoStreamUrl];
                            
                        }
                    }
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                    
                    
                }];
                
                [videoStreamingAlert addAction:laterAction];
                [videoStreamingAlert addAction:watchNowAction];
                //[[AppDelegate sharedInstance].window.rootViewController presentViewController:videoStreamingAlert animated:YES completion:NULL];
                ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                [[MAAlertPresenter sharedPresenter]enqueueAlert:videoStreamingAlert];


            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
        }];
        
        
    }

/*
    if (alertPayload) {
        
        ///Show alert using this payload
        
        
        NSString *strAlertTitle = NSLocalizedString(@"Video Streaming Alert", nil);
        
        ///3.Create Alert Message
        NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is streaming live video. Would you like to watch it? You can also watch this video later from Alerts tab",nil),alertPayload.strFullName];
        
        if ([alertPayload.strStatus isEqualToString:kAlertStatusVOD]) {
            
            strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ has streamed live video. Would you like to watch it? You can also watch this video later from Alerts tab",nil),alertPayload.strFullName];
        }
        
        ///Append an informational msg as a prefix to alert msg if global alert is issued so that no one get confused
        if (alertPayload.isGlobalAlert) {
            
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            if ([currentUser[kUserPatrolModeKey]boolValue]) {
                
                ///Patrol mode is still on
                strMessage = [NSMutableString stringWithFormat:@"%@. %@",NSLocalizedString(@"You are in a Patrol Mode and recieved a Global Alert", nil),strMessage];
                
            }
            else{
                
                ///Patrol mode is now off
                strMessage = [NSMutableString stringWithFormat:@"%@. %@",NSLocalizedString(@"You recieved a Global Alert", nil),strMessage];
            }
            
            
        }
        
        
        ///4.Create action button titles
        NSString *strLater = NSLocalizedString(@"Later", nil);
        
        NSString *strWatchNow = NSLocalizedString(@"Watch Now", nil);
        
        ///Show alert message
        UIAlertController *videoStreamingAlert = [UIAlertController alertControllerWithTitle:strAlertTitle message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:strLater style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            ///User tapped to watch video Later
            //1. update this on parse
            
            PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
            [getCell411AlertQuery selectKeys:@[kCell411AlertRejectedByKey]];
            [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                
                if (!error && objects.count > 0) {
                    
                    PFObject *cell411Alert = [objects firstObject];
                    
                    PFRelation *rejectedRelation = [cell411Alert relationForKey:kCell411AlertRejectedByKey];
                    [rejectedRelation addObject:[AppDelegate getLoggedInUser]];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                            
                        }
                        
                        
                    }];

                    
                    
                }
                else {
                    
                    if(![AppDelegate handleParseError:error]){
                        
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"#error fetching cell411alert :%@",errorString);
                    }
                    
                }
                
                
                
            }];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

            
        }];
        
        UIAlertAction *watchNowAction = [UIAlertAction actionWithTitle:strWatchNow style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            ///User Initiated to watch video now
            
            ///1. update this on parse
            PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
            [getCell411AlertQuery selectKeys:@[kCell411AlertInitiatedByKey]];
            [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                
                if (!error && objects.count > 0) {
                    
                    PFObject *cell411Alert = [objects firstObject];
                    
                    PFRelation *initiatedByRelation = [cell411Alert relationForKey:kCell411AlertInitiatedByKey];
                    [initiatedByRelation addObject:[AppDelegate getLoggedInUser]];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                            
                        }
                        
                        
                    }];

                    
                    
                }
                else {
                    
                    if (error) {
                        
                        if(![AppDelegate handleParseError:error]){
                          
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            NSLog(@"#error fetching cell411alert :%@",errorString);
                            
                            
                        }
                    }
                   
                    
                }
                
                ///Show the video
                ///1.Make url
                
                NSString *strVideoStreamUrl = nil;
                NSString *strStreamName = [NSString stringWithFormat:@"%@_%.0lf",alertPayload.strUserId,alertPayload.createdAtInMillis];
//                if ([alertPayload.strStatus isEqualToString:kAlertStatusLive]) {
//                    
//                    strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/live/%@/playlist.m3u8",CNAME,strStreamName];
//                }
//                else if ([alertPayload.strStatus isEqualToString:kAlertStatusVOD]) {
//                    
//                    strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/vod/%@/playlist.m3u8",CNAME,strStreamName];
//                }
                ///using dvr now to fix url issue when switcing to live/vod. dvr option will work for both with same url
                strVideoStreamUrl = [NSString stringWithFormat:@"http://%@:1935/%@/%@/playlist.m3u8?DVR",CNAME,WZA_APP_NAME,strStreamName];

                ///2.Play video
                if (strVideoStreamUrl.length > 0) {
                    
                    NSURL *videoStreamUrl = [NSURL URLWithString:strVideoStreamUrl];
                    if ([[UIApplication sharedApplication]canOpenURL:videoStreamUrl]) {
                        
                        [[UIApplication sharedApplication]openURL:videoStreamUrl];
                        
                    }
                }
                
            }];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

            
        }];
        
        [videoStreamingAlert addAction:laterAction];
        [videoStreamingAlert addAction:watchNowAction];
        //[[AppDelegate sharedInstance].window.rootViewController presentViewController:videoStreamingAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:videoStreamingAlert];

        
        
    }
 */
}

///Photo alert notification helper method
-(void)showPhotoAlertWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    if (alertPayload && alertPayload.strCell411AlertId) {
        
        ///get the Cell 411 alert object from parse associated to alert
        __weak typeof(self) weakSelf = self;
        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
        [getCell411AlertQuery selectKeys:@[
                                           kCell411AlertInitiatedByKey,
                                           kCell411AlertRejectedByKey,
                                           kCell411AlertSeenByKey
                                           ]];
        [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
            
            if (!error && object) {
                PFUser *currentUser = [AppDelegate getLoggedInUser];
                if(!currentUser){
                    ///Return if user is not logged in
                    return;
                }
                
                ///Alert found, show it to user
                PFObject *cell411Alert = object;
                ///Update seenBy
                [weakSelf setCurrentUserHasSeenAlert:cell411Alert];
                ///Show alert using this payload
                NSString *strAlertTitle = NSLocalizedString(@"Photo Alert", nil);
                
                ///1.Create Alert Message
                NSString *strMessageSuffix = NSLocalizedString(@"issued a photo alert. Would you like to view it? You can also view it later from Alerts tab", nil);
                NSString *strMessage = [NSString stringWithFormat:@"%@ %@",alertPayload.strFullName,strMessageSuffix];
                if ([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypePhotoCell.lowercaseString]) {
                    
                    strMessage = [NSString stringWithFormat:@"%@, %@ %@ %@",alertPayload.strFullName,NSLocalizedString(@"a member of", nil),alertPayload.strCellName,strMessageSuffix];
                }
                
                ///Append an informational msg as a prefix to alert msg if global alert is issued so that no one get confused
                if (alertPayload.isGlobalAlert) {
                    
                    if ([currentUser[kUserPatrolModeKey]boolValue]) {
                        
                        ///Patrol mode is still on
                        strMessage = [NSMutableString stringWithFormat:@"%@. %@",NSLocalizedString(@"You are in a Patrol Mode and recieved a Global Alert", nil),strMessage];
                        
                    }
                    else{
                        
                        ///Patrol mode is now off
                        strMessage = [NSMutableString stringWithFormat:@"%@. %@",NSLocalizedString(@"You recieved a Global Alert", nil),strMessage];
                    }
                    
                    
                }
                
                
                ///4.Create action button titles
                NSString *strLater = NSLocalizedString(@"Later", nil);
                
                NSString *strView = NSLocalizedString(@"View", nil);
                ///Show alert message
                UIAlertController *photoAlert = [UIAlertController alertControllerWithTitle:strAlertTitle message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *laterAction = [UIAlertAction actionWithTitle:strLater style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    ///User tapped to view photo Later
                    //1. update this on parse
                    PFRelation *rejectedRelation = [cell411Alert relationForKey:kCell411AlertRejectedByKey];
                    [rejectedRelation addObject:currentUser];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (error) {
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                        }
                    }];
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                }];
                
                UIAlertAction *viewAction = [UIAlertAction actionWithTitle:strView style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    ///User Initiated to view photo now
                    ///1.Push PhotoVC and do updation of cell411alert object behind the scene
                    [weakSelf showPhotoVCUsingAlertPayload:alertPayload];
                    
                    ///2. update this on parse
                    PFRelation *initiatedByRelation = [cell411Alert relationForKey:kCell411AlertInitiatedByKey];
                    [initiatedByRelation addObject:currentUser];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                        }
                    }];
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                    
                }];
                
                [photoAlert addAction:laterAction];
                [photoAlert addAction:viewAction];
                //[[AppDelegate sharedInstance].window.rootViewController presentViewController:photoAlert animated:YES completion:NULL];
                ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                [[MAAlertPresenter sharedPresenter]enqueueAlert:photoAlert];
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
        }];
    }
    
/*
    if (alertPayload) {
        
        ///Show alert using this payload
        NSString *strAlertTitle = NSLocalizedString(@"Photo Alert", nil);
        
        ///1.Create Alert Message
        NSString *strMessageSuffix = NSLocalizedString(@"issued a photo alert. Would you like to view it? You can also view it later from Alerts tab", nil);
        NSString *strMessage = [NSString stringWithFormat:@"%@ %@",alertPayload.strFullName,strMessageSuffix];
        if ([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypePhotoCell.lowercaseString]) {
            
            strMessage = [NSString stringWithFormat:@"%@, %@ %@ %@",alertPayload.strFullName,NSLocalizedString(@"a member of", nil),alertPayload.strCellName,strMessageSuffix];
        }
        
        ///Append an informational msg as a prefix to alert msg if global alert is issued so that no one get confused
        if (alertPayload.isGlobalAlert) {
            
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            if ([currentUser[kUserPatrolModeKey]boolValue]) {
                
                ///Patrol mode is still on
                strMessage = [NSMutableString stringWithFormat:@"%@. %@",NSLocalizedString(@"You are in a Patrol Mode and recieved a Global Alert", nil),strMessage];
                
            }
            else{
                
                ///Patrol mode is now off
                strMessage = [NSMutableString stringWithFormat:@"%@. %@",NSLocalizedString(@"You recieved a Global Alert", nil),strMessage];
            }
            
            
        }
        
        
        ///4.Create action button titles
        NSString *strLater = NSLocalizedString(@"Later", nil);
        
        NSString *strView = NSLocalizedString(@"View", nil);
        
        ///Show alert message
        UIAlertController *photoAlert = [UIAlertController alertControllerWithTitle:strAlertTitle message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *laterAction = [UIAlertAction actionWithTitle:strLater style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            ///User tapped to view photo Later
            //1. update this on parse
            
            PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
            [getCell411AlertQuery selectKeys:@[kCell411AlertRejectedByKey]];
            [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                
                if (!error && objects.count > 0) {
                    
                    PFObject *cell411Alert = [objects firstObject];
                    
                    PFRelation *rejectedRelation = [cell411Alert relationForKey:kCell411AlertRejectedByKey];
                    [rejectedRelation addObject:[AppDelegate getLoggedInUser]];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                            
                        }
                        
                        
                    }];

                    
                    
                }
                else {
                    
                    if(![AppDelegate handleParseError:error]){
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"#error fetching cell411alert :%@",errorString);
                    }
                    
                }
                
                
                
            }];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

            
        }];
        
        UIAlertAction *viewAction = [UIAlertAction actionWithTitle:strView style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
            ///User Initiated to view photo now
            ///1.Push PhotoVC and do updation of cell411alert object behind the scene
            [self showPhotoVCUsingAlertPayload:alertPayload andUpdateInitiatedBy:YES];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [photoAlert addAction:laterAction];
        [photoAlert addAction:viewAction];
        //[[AppDelegate sharedInstance].window.rootViewController presentViewController:photoAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:photoAlert];

        
        
    }
*/
}

-(void)showPhotoVCUsingAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    ///Show photo VC to view photo alert
    C411ViewPhotoVC *viewPhotoVC = [[AppDelegate sharedInstance].window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
    viewPhotoVC.photoFile = alertPayload.photoFile;
    viewPhotoVC.strAdditionalNote = alertPayload.strAdditionalNote;
    viewPhotoVC.strCell411AlertId = alertPayload.strCell411AlertId;
    ///since root vc is the navigation controller so we can push photo vc on it
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:viewPhotoVC animated:YES];
}

/*
-(void)showPhotoVCUsingAlertPayload:(C411AlertNotificationPayload *)alertPayload andUpdateInitiatedBy:(BOOL)updateInitiatedBy
{
    
    ///Show photo VC to view photo alert
    C411ViewPhotoVC *viewPhotoVC = [[AppDelegate sharedInstance].window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
    viewPhotoVC.photoFile = alertPayload.photoFile;
    viewPhotoVC.strAdditionalNote = alertPayload.strAdditionalNote;
    viewPhotoVC.strCell411AlertId = alertPayload.strCell411AlertId;
    ///since root vc is the navigation controller so we can push photo vc on it
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:viewPhotoVC animated:YES];

    if (updateInitiatedBy) {
        
        ///update initiated By on Parse
        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
        ///Fetch only initiated by relation now
        [getCell411AlertQuery selectKeys:@[kCell411AlertInitiatedByKey]];
        
        [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error && objects.count > 0) {
                
                PFObject *cell411Alert = [objects firstObject];
                
                PFRelation *initiatedByRelation = [cell411Alert relationForKey:kCell411AlertInitiatedByKey];
                [initiatedByRelation addObject:[AppDelegate getLoggedInUser]];
                
                ///Save it in background
                [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if (error) {
                        
                        ///save it eventually if error occured
                        [cell411Alert saveEventually];
                        
                    }
                    
                    
                }];
                
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error fetching cell411alert :%@",errorString);
                }
                
            }
            
            
            
        }];


        
    }
}
*/

-(void)handleUserResponseToCellRequestWithAlertPayload:(C411AlertNotificationPayload *)alertPayload andApproveStatus:(BOOL)approved
{
    
    
    ///Get the user object
    PFQuery *getUserQuery = [PFUser query];
    [getUserQuery whereKey:@"objectId" equalTo:alertPayload.strUserId];
    [getUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (!error) {
            
            ///Found user object
            PFUser *requestSender = (PFUser *)object;
            if (approved) {
                
                ///User approved the cell request, retrieve the public cell object
                PFQuery *getPublicCellQuery = [PFQuery queryWithClassName:kPublicCellClassNameKey];
                [getPublicCellQuery whereKey:@"objectId" equalTo:alertPayload.strCellId];
                [getPublicCellQuery selectKeys:@[kPublicCellMembersKey,kPublicCellTotalMembersKey]];
                [getPublicCellQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                    
                    if (!error) {
                        
                        PFObject *publicCell = object;
                        ///Add user to members relation
                        PFRelation *cellMembersRelation = [publicCell relationForKey:kPublicCellMembersKey];
                        [cellMembersRelation addObject:requestSender];
                        ///Increment total members by 1
                        [publicCell incrementKey:kPublicCellTotalMembersKey byAmount:@(1)];
                        
                        ///Save it in background
                        [publicCell saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                            
                            if (succeeded) {
                                
                                ///Member added to Public Cell,retrieve the Cell411Alert object
                                PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                                [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCellRequestObjectId];
                                [getCell411AlertQuery selectKeys:@[kCell411AlertStatusKey]];
                                [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                                    
                                    if (!error) {
                                        
                                        ///Update the Status as approved and save it eventually
                                        PFObject *cell411Alert = object;
                                        cell411Alert[kCell411AlertStatusKey] = kAlertStatusApproved;
                                        [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                            
                                            if (error) {
                                                
                                                ///save it eventually if error occured
                                                [cell411Alert saveEventually];
                                                
                                            }
                                            
                                            
                                        }];

                                        
                                        ///create push payload data
                                        NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                                        dictData[kPayloadAlertKey] = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"The owner of Cell", nil),alertPayload.strCellName,NSLocalizedString(@"approved your request to join the Cell!", nil)];
                                        PFUser *currentUser = [AppDelegate getLoggedInUser];
                                        dictData[kPayloadUserIdKey] = currentUser.objectId;
                                        NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                                        dictData[kPayloadNameKey] = strUserFullName;
                                        dictData[kPayloadCellNameKey] = alertPayload.strCellName;
                                        dictData[kPayloadCellIdKey] = alertPayload.strCellId;
                                        dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeCellApproved;
                                        dictData[kPayloadSoundKey] = @"default";///To play default sound
                                        dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                                        
                                        ///Send Push notification to user who had sent this request
                                        PFQuery *pushQuery = [PFInstallation query];
                                        
                                        [pushQuery whereKey:kInstallationUserKey equalTo:requestSender];
                                        
                                        
                                        
                                        // Send push notification to query
                                        PFPush *push = [[PFPush alloc] init];
                                        [push setQuery:pushQuery]; // Set our Installation query
                                        [push setData:dictData];
                                        [push sendPushInBackground];
                                        
                                    }
                                    else if (error.code == kPFErrorObjectNotFound){
                                        
                                    }
                                    else{
                                        
                                        if(![AppDelegate handleParseError:error]){
                                            ///show error
                                            NSString *errorString = [error userInfo][@"error"];
                                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                        }
                                        
                                    }
                                    
                                }];
                                
                            }
                            else{
                                
                                if (error) {
                                    if(![AppDelegate handleParseError:error]){
                                        ///show error
                                        NSString *errorString = [error userInfo][@"error"];
                                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                    }
                                }
                                
                            }
                            
                            
                        }];
                        
                        
                        
                    }
                    else {
                        
                        if(![AppDelegate handleParseError:error]){
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            NSLog(@"#error fetching cell411alert :%@",errorString);
                        }
                        
                    }
                    
                    
                    
                }];
                
            }
            else{
                
                ///User denied the cell request, retrieve the Cell411Alert object
                PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCellRequestObjectId];
                [getCell411AlertQuery selectKeys:@[kCell411AlertStatusKey]];
                [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                    
                    if (!error) {
                        
                        ///Update the Status as denied and save it eventually
                        PFObject *cell411Alert = object;
                        cell411Alert[kCell411AlertStatusKey] = kAlertStatusDenied;
                        [cell411Alert saveEventually];
                        
                        ///create push payload data
                        NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                        dictData[kPayloadAlertKey] = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"The owner of Cell", nil),alertPayload.strCellName,NSLocalizedString(@"denied your request to join the Cell!", nil)];
                        PFUser *currentUser = [AppDelegate getLoggedInUser];
                        dictData[kPayloadUserIdKey] = currentUser.objectId;
                        NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                        dictData[kPayloadNameKey] = strUserFullName;
                        dictData[kPayloadCellNameKey] = alertPayload.strCellName;
                        dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeCellDenied;
                        dictData[kPayloadSoundKey] = @"default";///To play default sound
                        dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                        
                        ///Send Push notification to user who had sent this request
                        PFQuery *pushQuery = [PFInstallation query];
                        
                        [pushQuery whereKey:kInstallationUserKey equalTo:requestSender];
                        
                        
                        
                        // Send push notification to query
                        PFPush *push = [[PFPush alloc] init];
                        [push setQuery:pushQuery]; // Set our Installation query
                        [push setData:dictData];
                        [push sendPushInBackground];
                        
                    }
                    else if (error.code == kPFErrorObjectNotFound){
                        
                    }
                    else{
                        
                        if(![AppDelegate handleParseError:error]){
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        }
                        
                    }
                    
                }];
                
            }
            
            
        }
        else if (error.code == kPFErrorObjectNotFound){
            
        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            }
        }
        
    }];
    
    
}

-(void)joinPublicCellUsingPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    PFUser *joinee = [AppDelegate getLoggedInUser];
    NSString *strJoineeFullName = [C411StaticHelper getFullNameUsingFirstName:joinee[kUserFirstnameKey] andLastName:joinee[kUserLastnameKey]];
    NSString *strOwnerId = alertPayload.strUserId;
    NSString *strPublicCellId = alertPayload.strCellId;
    
    ///get the latest Public Cell object to see whether it still exist or not
    [C411StaticHelper getPublicCellWithObjectId:strPublicCellId andCompletion:^(PFObject *object, NSError *error){
        
        if (!error) {
            
            ///get the refreshed object
            PFObject *publicCellObj = object;
            
            [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strOwnerId andCompletion:^(SpamStatus status, NSError *error) {
                
                if (status == SpamStatusIsSpammed) {
                    
                    ///Cell owner is spammed by current user, show error message
                    [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Sorry, we cannot send Cell join request to this user on your behalf", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                }
                else{
                    ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to send request
                    if (error) {
                        ///Log the error if any but send the request even if SpamStatus is SpamStatusUnknown
                        NSLog(@"%@",error.localizedDescription);
                        
                    }
                    
                    ///Get the user object for public cell owner
                    PFUser *cellOwner = publicCellObj[kPublicCellCreatedByKey];
                    ///1.Create a Cell411Alert object
                    
                    PFObject *cell411Alert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                    cell411Alert[kCell411AlertIssuedByKey] = joinee;
                    cell411Alert[kCell411AlertEntryForKey] = kEntryForCellRequest;
                    cell411Alert[kCell411AlertStatusKey] = kAlertStatusPending;
                    
                    cell411Alert[kCell411AlertCellIdKey] = strPublicCellId;
                    cell411Alert[kCell411AlertToKey] = cellOwner.username;
                    cell411Alert[kCell411AlertIssuerFirstNameKey] = strJoineeFullName;
                    NSString *strCellName = alertPayload.strCellName;
                    cell411Alert[kCell411AlertCellNameKey] = strCellName;
                    
                    ///Save in Background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            
                            ///2.An entry has been made successfully on Cell411Alert table regarding the notification and now you can send the notification to the cell owner
                            
                            ///Create Payload data
                            NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                            NSString *strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ has sent you a Cell join request on %@ Cell!",nil),strJoineeFullName,strCellName];
                            
                            dictData[kPayloadAlertKey] = strAlertMsg;
                            dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeCellRequest;
                            dictData[kPayloadUserIdKey] = joinee.objectId;
                            dictData[kPayloadCellRequestObjectIdKey] = cell411Alert.objectId;
                            
                            dictData[kPayloadNameKey] = strJoineeFullName;
                            dictData[kPayloadCellIdKey] = strPublicCellId;
                            dictData[kPayloadCellNameKey] = strCellName;
                            
                            dictData[kPayloadSoundKey] = @"default";///To play default sound
                            dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                            
                            
                            
                            // Create our Installation query
                            PFQuery *pushQuery = [PFInstallation query];
                            [pushQuery whereKey:kInstallationUserKey equalTo:cellOwner];
                            
                            // Send push notification to query
                            PFPush *push = [[PFPush alloc] init];
                            [push setQuery:pushQuery]; // Set our Installation query
                            [push setData:dictData];
                            ///Send Push notification
                            [push sendPushInBackground];
                            
                            ///Show toast
                            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"A Cell join request is sent to the owner of %@ Cell for approval",nil),strCellName];
                            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                [C411StaticHelper  showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
                            }];
                            
                            
                            ///Send notification that Cell is joined along with refreshed Public Cell Object
                            NSMutableDictionary *dictUserInfo = [NSMutableDictionary dictionary];
                            [dictUserInfo setObject:publicCellObj forKey:kRefreshedPublicCellKey];
                            [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellJoinedNotification object:cell411Alert userInfo:dictUserInfo];
                            
                            
                        }
                        else{
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                }
                            }
                            
                        }
                        
                        
                    }];
                    
                    
                }
                
            }];
        }
        else if (error.code == kPFErrorObjectNotFound){
            
            ///this public cell has been deleted by the owner, send notification to remove it from the list as well
            [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellDoesNotExistNotification object:strPublicCellId];
            
            ///show the alert
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Oops!!! This Cell no longer exist.", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
            
            
        }
        else{
            
            ///show the error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
        }
    }];
    
    
}

-(void)showRideRequestWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    if (alertPayload) {
        
        ///Get top vc reference
        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
        ///Load popup view from nib
        C411RideRequestPopup *vuRideRequestPopup = [[[NSBundle mainBundle] loadNibNamed:@"C411RideRequestPopup" owner:self options:nil] lastObject];
        vuRideRequestPopup.showNevermindAsClose = NO;
        vuRideRequestPopup.alertPayload = alertPayload;///this must be the last property to be set
        vuRideRequestPopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
            
            ///Do anything on close
            
            
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

-(void)showRideResponseWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    if (alertPayload) {
        
        ///Get top vc reference
        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
        ///Load popup view from nib
        C411RideResponsePopup *vuRideResponsePopup = [[[NSBundle mainBundle] loadNibNamed:@"C411RideResponsePopup" owner:self options:nil] lastObject];
        vuRideResponsePopup.alertPayload = alertPayload;///this must be the last property to be set
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
    
    
    
}

-(void)showRideConfirmedWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    if (alertPayload) {
        
        ///Get top vc reference
        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
        ///Load ride confirmed popup view from nib
        C411RideSelectedPopup *vuRideSelectedPopup = [[[NSBundle mainBundle] loadNibNamed:@"C411RideSelectedPopup" owner:self options:nil] lastObject];
        vuRideSelectedPopup.alertPayload = alertPayload;///this must be the last property to be set
        vuRideSelectedPopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
            
            ///Do anything on close
            
            
        };
        ///Set view frame
        vuRideSelectedPopup.frame = rootVC.view.bounds;
        ///Add popup view in next run loop
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            [rootVC.view addSubview:vuRideSelectedPopup];
            [rootVC.view bringSubviewToFront:vuRideSelectedPopup];
            
        }];
        
        ///Post notification to show overlay if required
        [[NSNotificationCenter defaultCenter]postNotificationName:kShowRideOverlayNotification object:nil];
        
    }
    
    
    
}


-(void)showRideRejectedWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    if (alertPayload) {
        
        NSMutableString *strAlertMessage = [NSMutableString localizedStringWithFormat:@"%@ %@",alertPayload.strFullName,NSLocalizedString(@"has rejected your ride :(",nil)];
        
        alertPayload.strAdditionalNote.length > 0 ? [NSString localizedStringWithFormat:NSLocalizedString(@"%@\nAdditional Note: %@",nil),strAlertMessage,alertPayload.strAdditionalNote] : strAlertMessage;
        [C411StaticHelper showAlertWithTitle:NSLocalizedString(@"Ride not selected", nil) message:strAlertMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];

    }
    
    
    
}


-(void)showRideSelectedWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    ///someone else is selected
    if (alertPayload) {
        
        NSString *strAlertMessage = alertPayload.strAlert;
        [C411StaticHelper showAlertWithTitle:nil message:strAlertMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];

    }
    
    
    
}

-(void)showUserJoinedPopupWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    if (alertPayload && alertPayload.strUserId) {
        
        ///get the user object from parse
        __weak typeof(self) weakSelf = self;
        PFQuery *getUserQuery = [PFUser query];
        [getUserQuery getObjectInBackgroundWithId:alertPayload.strUserId block:^(PFObject *object,  NSError *error){
            
            if (!error && object) {
                
                ///User found pass it emergency popup class
                PFUser *joinedUser = (PFUser *)object;
                
                ///Get top vc reference
                UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
                ///Load popup view from nib
                C411UserJoinedPopup *vuUserJoinedPopup = [[[NSBundle mainBundle] loadNibNamed:@"C411UserJoinedPopup" owner:weakSelf options:nil] lastObject];
                
                
                vuUserJoinedPopup.user = joinedUser;
                
                NSInteger cancelIndex = 0;
                
                vuUserJoinedPopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
                    
                    ///Do anything on close
                    if (actionIndex == cancelIndex) {
                        
                        ///user chosen decide later option, do nothing
                        
                    }
                    else{
                        
                        ///User chosen add friend option, so send friend request
                        [weakSelf sendFriendRequestToUser:joinedUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                            
                            if (succeeded) {
                                
                                ///Friend request is sent successfully
                                [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Friend request sent.", nil)];
                                
                                
                            }
                            else if (error){
                                
                                ///Some error occured sending friend request to this user
                                if(![AppDelegate handleParseError:error]){
                                    
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [AppDelegate showToastOnView:nil withMessage:errorString];
                                    
                                }
                                
                                
                            }
                            else{
                                
                                ///there is no error but operation doesn't get succeeded, could be the case that user to whom friend request is being sent has spammed current user
                                
                            }
                            
                        }];

                        
                        
                    }
                    
                    
                };
                ///Set view frame
                vuUserJoinedPopup.frame = rootVC.view.bounds;
                ///Add popup view in next run loop
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    
                    [rootVC.view addSubview:vuUserJoinedPopup];
                    [rootVC.view bringSubviewToFront:vuUserJoinedPopup];
                    
                }];
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
        }];
        
        
    }
    
    
    
}



#if NON_APP_USERS_ENABLED
-(void)getNonAppUserCellsInBackgroundWithBlock:(PFArrayResultBlock)completion
{
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *getNAUCellsQuery = [PFQuery queryWithClassName:kNonAppUserCellClassNameKey];
    [getNAUCellsQuery includeKey:kNonAppUserCellMembersKey];
    [getNAUCellsQuery whereKey:kNonAppUserCellCreatedByKey equalTo:currentUser];
    [getNAUCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (completion != NULL) {
            
            completion(objects,error);
        }
        
    }];
    
}
#endif


//****************************************************
#pragma mark - FriendsDelegate Methods
//****************************************************

-(void)addFriend:(id)userFriend
{
    if ([C411StaticHelper canUseJsonObject:userFriend]) {
        ///Add this object to friends array
        [self.arrFriends addObject:userFriend];
        
        ///Post notification that friend list updated
        [[NSNotificationCenter defaultCenter]postNotificationName:kFriendListUpdatedNotification object:nil];
        
    }
    
}

-(void)removeFriendAtIndex:(NSUInteger)index
{
    if (index < self.arrFriends.count) {
        
        ///Get friend object
        PFUser *userFriend = [self.arrFriends objectAtIndex:index];
        
        ///Remove friend object at given index
        [self.arrFriends removeObjectAtIndex:index];
        
        ///Post notification that friend list updated
        [[NSNotificationCenter defaultCenter]postNotificationName:kFriendListUpdatedNotification object:nil];
        
        ///remove friend from cell if exist
        if (_arrCells.count > 0) {
            
            ///Cells has been already fetched successfully, we can remove friend from cell
            [self removeFriendFromUserCells:userFriend];
            
        }
        else{
            
            ///Fetch cells first
            __weak typeof(self) weakself = self;
            [self getCellsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                
                if (!error) {
                    
                    weakself.arrCells = [NSMutableArray arrayWithArray:objects];
                    
                    ///Post notification that cell list updated
                    [[NSNotificationCenter defaultCenter]postNotificationName:kCellsListUpdatedNotification object:nil];
                    
                    ///remove friend from cell
                    [weakself removeFriendFromUserCells:userFriend];
                    
                }
                else {
                    
                    if(![AppDelegate handleParseError:error]){
                        ///log error, this is the situation where the friend has been removed but unable to check whether that friend is available in user's cell as well, if exist then it will be missed from getting removed from cell
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"Error getting cells %@",errorString);
                    }
                    
                }
                
                
                
            }];
        }
    }
}


-(void)removeFriend:(id)userFriend{
    
    PFUser *friend = (PFUser *)userFriend;
    NSInteger matchedIndex = -1;
    for (NSInteger index = 0; index < self.arrFriends.count; index++){
        PFUser *user = [self.arrFriends objectAtIndex:index];
        if ([friend.objectId isEqualToString:user.objectId]) {
            
            ///found matching user
            matchedIndex = index;
            break;
            
        }
        
    }
    
    if (matchedIndex != -1) {
        
        ///remove the friend from the matched index
        [self removeFriendAtIndex:matchedIndex];
        
    }
    
    
}


-(void)updateFriends
{
    ///clear the array of friends
    _arrFriends = nil;
    
    ///reload all data of freinds putting its value in temp array
    NSArray *tempFriends = self.arrFriends;
    tempFriends = nil;
    
}

//****************************************************
#pragma mark - CellsDelegate
//****************************************************

-(void)addCell:(id)cell
{
    if ([C411StaticHelper canUseJsonObject:cell]) {
        ///Add this object to cells array
        [self.arrCells addObject:cell];
        
        ///Post notification that cell list updated
        [[NSNotificationCenter defaultCenter]postNotificationName:kCellsListUpdatedNotification object:nil];
        
    }
    
}

-(void)removeCellAtIndex:(NSUInteger)index
{
    if (index < self.arrCells.count) {
        
        ///Remove cell object at given index
        [self.arrCells removeObjectAtIndex:index];
        
        ///Post notification that cell list updated
        [[NSNotificationCenter defaultCenter]postNotificationName:kCellsListUpdatedNotification object:nil];
        
    }
}

-(void)updateCells
{
    ///clear the array of cells
    _arrCells = nil;
    
    ///reload all data of cells putting its value in temp array
    NSArray *tempCells = self.arrCells;
    tempCells = nil;
    
}

#if NON_APP_USERS_ENABLED

//****************************************************
#pragma mark - NonAppUserCellsDelegate Methods
//****************************************************

-(void)addNonAppUserCell:(id)NAUCell
{
    if ([C411StaticHelper canUseJsonObject:NAUCell]) {
        ///Add this object to non app user cells array
        [self.arrNonAppUserCells addObject:NAUCell];
        
        ///Post notification that non app user cell list updated
        [[NSNotificationCenter defaultCenter]postNotificationName:kNonAppUserCellsListUpdatedNotification object:nil];
        
    }
    
}

-(void)removeNonAppUserCellAtIndex:(NSUInteger)index
{
    if (index < self.arrNonAppUserCells.count) {
        
        ///Remove NAUCell object at given index
        [self.arrNonAppUserCells removeObjectAtIndex:index];
        
        ///Post notification that non app user cell list updated
        [[NSNotificationCenter defaultCenter]postNotificationName:kNonAppUserCellsListUpdatedNotification object:nil];
        
    }
}

-(void)updateNonAppUserCells
{
    ///clear the array of non app user cells
    _arrNonAppUserCells = nil;
    
    ///reload all data of non app usercells putting its value in temp array
    NSArray *tempCells = self.arrNonAppUserCells;
    tempCells = nil;
    
}


#endif


//**********************************************************
#pragma mark - C411CellMembersSelectionVCDelegate Methods
//**********************************************************

-(void)didSelectMembers:(NSArray *)arrSelectedMembers ForCell:(PFObject *)privateCell
{
    ///1. Check if members list is updated,this may reduce the numbers of calls made to parse but comes with the cost of performance to iterate heavy arrays, so I am avoiding it for now and just making call to parse each time
    BOOL membersUpdated = YES;
    
    ///2. Update members if list is changed
    if (membersUpdated) {
        
        ///Save this array on parse for members
        NSArray *arrOldMembers = privateCell[kCellMembersKey];
        privateCell[kCellMembersKey] = arrSelectedMembers;
        
        [privateCell saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            
            if (succeeded) {
                
                ///Do anything after save you want, like post notification to members interested in updaed list of members,etc.
                
            }
            else{
                
                if (error) {
                    if(![AppDelegate handleParseError:error]){
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    }
                }
                
                ///Revert the cell to have old members
                privateCell[kCellMembersKey] = arrOldMembers;
                
            }
            
            
            
        }];
        
    }
}

//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == TXT_TAG_ALERT_EMAIL) {
        
        ///Submit button can only be available if there is email
        NSString *strEmail = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (strEmail.length > 0 && [C411StaticHelper isValidEmail:strEmail]) {
            
            self.submitAction.enabled = YES;
        }
        else{
            
            self.submitAction.enabled = NO;
            
        }
        
        
    }
    
    return YES;
    
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)didReceivedFriendRequestAlert:(NSNotification *)notif
{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        ///Show alert using this payload
        ///1.check if this alert is recieved from user who has been spammed by current user i.e present in spamUsers relation, if this is true then do not show the alert
        NSString *strAlertSenderUserId = alertPayload.strUserId;
        __weak typeof(self) weakSelf = self;
        
        [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
            
            if (status == SpamStatusIsSpammed) {
                
                ///This user is spammed by current user so the alert will not be shown
                
                
            }
            else{
                ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                if (error) {
                    ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                    NSLog(@"%@",error.localizedDescription);
                    
                }
                
                ///1.Create Alert Message
                NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ wants to add you as a friend in the %@ network. If approved, this user will be able to send you emergency alerts.",nil),alertPayload.strFullName,LOCALIZED_APP_NAME];
                
                ///2.Create action button titles
                NSString *strDeny = NSLocalizedString(@"Deny", nil);
                NSString *strApprove = NSLocalizedString(@"Approve", nil);
                NSString *strLater = NSLocalizedString(@"Later", nil);
                
                
                ///Show alert message
                UIAlertController *frAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *denyAction = [UIAlertAction actionWithTitle:strDeny style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    ///User tapped Deny, i.e rejected the friend request
                    //1. update this on parse
                    [weakSelf rejectFriendRequestWithId:alertPayload.strCell411AlertId andCompletion:NULL];
                    
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];

                    
                }];
                
                UIAlertAction *approveAction = [UIAlertAction actionWithTitle:strApprove style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    ///User Approved the friend request
                    [weakSelf approveFriendRequestWithId:alertPayload.strCell411AlertId fromUserWithId:alertPayload.strUserId fullName:alertPayload.strFullName andCompletion:NULL];
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];

                    
                }];
                
                UIAlertAction *laterAction = [UIAlertAction actionWithTitle:strLater style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    ///User tapped later, i.e will decide later. Do nothing
                    ///Save current user object in seenBy relation
                    PFUser *currentUser = [AppDelegate getLoggedInUser];
                    if (currentUser) {
                        ///User is logged in, save current user in seen by relation
                        PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                        [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
                        [getCell411AlertQuery selectKeys:@[kCell411AlertSeenByKey]];
                        [getCell411AlertQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                            
                            if (!error && objects.count > 0) {
                                
                                PFObject *cell411Alert = [objects firstObject];
                                
                                PFRelation *seenByRelation = [cell411Alert relationForKey:kCell411AlertSeenByKey];
                                [seenByRelation addObject:[AppDelegate getLoggedInUser]];
                                
                                ///save it eventually
                                [cell411Alert saveEventually];
                                
                                
                                
                                
                            }
                            else {
                                
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    NSLog(@"#error fetching cell411alert :%@",errorString);
                                }
                                
                            }
                            
                            
                            
                        }];
                        
                    }
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                    
                    
                }];

                
                [frAlert addAction:approveAction];
                [frAlert addAction:denyAction];
                [frAlert addAction:laterAction];
                //[[AppDelegate sharedInstance].window.rootViewController presentViewController:frAlert animated:YES completion:NULL];
                ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                [[MAAlertPresenter sharedPresenter]enqueueAlert:frAlert];

                
            }
            
        }];
        
        
    }
    
}

-(void)didReceivedFriendApprovedAlert:(NSNotification *)notif
{
    
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload && alertPayload.strTaskId.length > 0) {
        __weak typeof(self) weakSelf = self;
        
        ///1. Get Task
        PFQuery *getAddFriendTaskQuery = [PFQuery queryWithClassName:kTaskClassNameKey];
        
        [getAddFriendTaskQuery getObjectInBackgroundWithId:alertPayload.strTaskId block:^(PFObject *object,  NSError *error){
            
            if (!error) {
                ///Found the associated task
                PFObject *task = (PFObject *)object;
                ///2. fetch the user who approved the request, i.e assignee
                PFQuery *getUserQuery = [PFUser query];
                [getUserQuery getObjectInBackgroundWithId:alertPayload.strUserId block:^(PFObject *object,  NSError *error){
                    
                    if (!error) {
                        ///Fetched the user
                        ///3. Add this user to current user's friend
                        PFUser *userFriend = (PFUser *)object;
                        PFUser *currentUser = [AppDelegate getLoggedInUser];
                        PFRelation *friendRelation = [currentUser relationForKey:kUserFriendsKey];
                        ///add friend to relation
                        [friendRelation addObject:userFriend];
                        
                        ///save current user object
                        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                            
                            if (succeeded) {
                                ///Friend Added successfully
                                
                                //4. remove the task as its done
                                [task deleteEventually];
                                
                                ///5.Refresh the friend list
                                [weakSelf updateFriends];
                                
                                ///6. set SECOND privilege if applicable
                                [C411StaticHelper setSecondPrivilegeIfApplicableForUser:currentUser];
                                
                                ///7. show alert to user
                                NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:userFriend[kUserFirstnameKey] andLastName:userFriend[kUserLastnameKey]];
                                NSString *strMessage = [NSString stringWithFormat:@"%@ %@",strUserFullName,NSLocalizedString(@"approved your friend request!", nil)];
                                
                                UIAlertController *FAAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                    
                                    ///Do anything required on OK action
                                    [self showAddFriendToCellPopup:userFriend];
                                    
                                    ///Dequeue the current Alert Controller and allow other to be visible
                                    [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                }];
                                
                                [FAAlert addAction:okAction];
                                //[[AppDelegate sharedInstance].window.rootViewController presentViewController:FAAlert animated:YES completion:NULL];
                               
                                ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                                [[MAAlertPresenter sharedPresenter]enqueueAlert:FAAlert];

                                
                            }
                            else{
                                ///some error occured adding friend back to current user's friend list
                                if (error) {
                                    if(![AppDelegate handleParseError:error]){
                                            ///show error
                                        NSString *errorString = [error userInfo][@"error"];
                                        NSLog(@"#Error: %@",errorString);
                                    }
                                }
                                
                            }
                            
                        }];
                        
                    }
                    else{
                        ///some error occured fetching user
                        if (error) {
                            if(![AppDelegate handleParseError:error]){
                                ///show error
                                NSString *errorString = [error userInfo][@"error"];
                                NSLog(@"#Error: %@",errorString);
                            }
                            
                        }
                    }
                    
                }];
                
                
            }
            else{
                
                if(![AppDelegate handleParseError:error]){
                    ///Some error occured, do nothing
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#Error: %@",errorString);
                }
            }
            
        }];
        
        
    }
    
}


-(void)didRecievedHelperAlert:(NSNotification *)notif
{
    ///check if this alert is recieved from user who has been spammed by current user i.e present is spamUsers relation, if this is true then do not show the alert
    
    ///Check if this alert is recieved from user who has spammed current user i.e present in spammedBy relation, if this is true then do not show the alert
    ///NOTE: Ideally the above two checks is not required as if someone has spammed me then I cannot send that user a needy alert and without needy alert he cannot send me helper alert or make any entry in additional notes table. Or if I spammed someone then I can send needy alert to that person but when he will tap on Help or reject No action will be taken further that means No alert will be generated from the other end. The above checks are only added to avoid any bug to be occured while handling alerts from too many places.
    
    
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        NSString *strAlertSenderUserId = alertPayload.strUserId;
        __weak typeof(self) weakSelf = self;
        
        ///1.check if this alert is recieved from user who has been spammed by current user i.e present in spamUsers relation, if this is true then do not show the alert
        [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
            
            if (status == SpamStatusIsSpammed) {
                
                ///This user is spammed by current user so the alert will not be shown
                
                
            }
            else{
                ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                if (error) {
                    ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                    NSLog(@"%@",error.localizedDescription);
                    
                }
                
                ///2.Check if this alert is recieved from user who has spammed current user i.e present in spammedBy relation, if this is true then do not show the alert
                [[AppDelegate sharedInstance]didCurrentUserSpammedByUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
                    
                    if (status == SpamStatusIsSpammed) {
                        
                        ///This user has spammed current user so the alert will not be shown
                        
                    }
                    else{
                        ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                        if (error) {
                            ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                            NSLog(@"%@",error.localizedDescription);
                            
                        }
                        
                        [weakSelf showHelperAlertWithAlertPayload:alertPayload];
                        
                    }
                    
                }];
            }
            
        }];
        
        
        
        ///Set seen status to 1 for all case to avoid getting same notification again
        if (alertPayload.strAdditionalNoteId.length > 0) {
            ///Update seen status to 1 for this Note
            [self updateAdditonalNoteTable:kAdditionalNoteClassNameKey withAdditionalNoteId:alertPayload.strAdditionalNoteId andSeenStatus:@(1)];
            
        }
    }
    
    
}

-(void)didRecievedRejectorAlert:(NSNotification *)notif
{
    ///check if this alert is recieved from user who has been spammed by current user i.e present is spamUsers relation, if this is true then do not show the alert
    
    ///Check if this alert is recieved from user who has spammed current user i.e present in spammedBy relation, if this is true then do not show the alert
    ///NOTE: Ideally the above two checks is not required as if someone has spammed me then I cannot send that user a needy alert and without needy alert he cannot send me helper alert or make any entry in additional notes table. Or if I spammed someone then I can send needy alert to that person but when he will tap on Help or reject No action will be taken further that means No alert will be generated from the other end. The above checks are only added to avoid any bug to be occured while handling alerts from too many places.
    
    
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        NSString *strAlertSenderUserId = alertPayload.strUserId;
        __weak typeof(self) weakSelf = self;
        
        ///1.check if this alert is recieved from user who has been spammed by current user i.e present in spamUsers relation, if this is true then do not show the alert
        [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
            
            if (status == SpamStatusIsSpammed) {
                
                ///This user is spammed by current user so the alert will not be shown
                
                
            }
            else{
                ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                if (error) {
                    ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                    NSLog(@"%@",error.localizedDescription);
                    
                }
                
                ///2.Check if this alert is recieved from user who has spammed current user i.e present in spammedBy relation, if this is true then do not show the alert
                [[AppDelegate sharedInstance]didCurrentUserSpammedByUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
                    
                    if (status == SpamStatusIsSpammed) {
                        
                        ///This user has spammed current user so the alert will not be shown
                        
                    }
                    else{
                        ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                        if (error) {
                            ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                            NSLog(@"%@",error.localizedDescription);
                            
                        }
                        
                        [weakSelf showRejectorAlertWithAlertPayload:alertPayload];
                        
                    }
                    
                }];
            }
            
        }];
        
        
        if (alertPayload.strAdditionalNoteId.length > 0) {
            ///Update seen status to 1 for this Note
            [self updateAdditonalNoteTable:kAdditionalNoteClassNameKey withAdditionalNoteId:alertPayload.strAdditionalNoteId andSeenStatus:@(1)];
        }
        
    }
    
    
}


-(void)didRecievedNeedyAlert:(NSNotification *)notif
{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        if ([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyForwarded.lowercaseString]) {
            
            ///Do not check for spam here as this is a NEEDY_FORWARDED alert and would have been already checked by the sender
            [self showNeedyAlertWithAlertPayload:alertPayload andCanRespondToAlert:YES];
            
        }
        else if ([alertPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyCell.lowercaseString]) {
            
            ///Do not check for spam here as this is a NEEDY_CELL alert and would have been already checked by the cloud function
            [self showNeedyAlertWithAlertPayload:alertPayload andCanRespondToAlert:YES];
            
        }
        else{
            
            ///This is a NEEDY alert, check for spam here for playing safe
            
            NSString *strAlertSenderUserId = alertPayload.strUserId;
            __weak typeof(self) weakSelf = self;
            
            ///1.check if this alert is recieved from user who has been spammed by current user i.e present in spamUsers relation, if this is true then do not show the alert
            [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
                
                if (status == SpamStatusIsSpammed) {
                    
                    ///This user is spammed by current user so the alert will not be shown
                    if (alertPayload.isDeepLinked) {
                        
                        ///show message that you have spammed this user and you cannot respond to this alert
                        NSString *strMessage = NSLocalizedString(@"You cannot respond to this alert.", nil);
                        [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        
                    }
                    
                }
                else{
                    ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                    if (error) {
                        ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                        NSLog(@"%@",error.localizedDescription);
                        
                    }
                    
                    ///2.///Check if this alert is recieved from user who has spammed current user i.e present in spammedBy relation, if this is true then show the alert but set its delegate to nil to avoid doing any action further
                    [[AppDelegate sharedInstance]didCurrentUserSpammedByUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
                        
                        if (status == SpamStatusIsSpammed) {
                            
                            ///This user has spammed current user so the alert will be shown but will not be able to respond or forward the alert
                            
                            [weakSelf showNeedyAlertWithAlertPayload:alertPayload andCanRespondToAlert:NO];
                            
                        }
                        else{
                            ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                            if (error) {
                                ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                                NSLog(@"%@",error.localizedDescription);
                                
                            }
                            
                            [weakSelf showNeedyAlertWithAlertPayload:alertPayload andCanRespondToAlert:YES];
                            
                        }
                        
                    }];
                }
                
            }];
        }
        
        
    }
    
}

-(void)didRecievedVideoStreamingAlert:(NSNotification *)notif
{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        NSString *strAlertSenderUserId = alertPayload.strUserId;
        __weak typeof(self) weakSelf = self;
        
        ///1.check if this alert is recieved from user who has been spammed by current user i.e present in spamUsers relation, if this is true then do not show the alert
        [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
            
            if (status == SpamStatusIsSpammed) {
                
                ///This user is spammed by current user so the alert will not be shown
                
                
            }
            else{
                ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                if (error) {
                    ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                    NSLog(@"%@",error.localizedDescription);
                    
                }
                
                ///Show the alert without checking whether the current user is spammedBy the person streaming the video, as the video can be watched in either case, and hence the entry for initiated (if he choses to watch video) or rejected(if he choses later option) will be made in Cell411Alert table in either case.
                [weakSelf showVideoStreamingAlertWithAlertPayload:alertPayload];
            }
            
        }];
        
    }
    
}

-(void)didRecievedPhotoAlert:(NSNotification *)notif
{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if(alertPayload.isDeepLinked){
        
        ///Photo alert opened through Facebook, as this is an alert which can only be viewed so let it be viewed by anyone.i.e if photo alert is opened through Facebook so a person can view his own posted alert or from the one whom current user has spammed or from sent by any user. Also anonymous user can also view photo alert opened from facebook like other alerts
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        if (currentUser && ![alertPayload.strUserId isEqualToString:currentUser.objectId]) {
            
            ///Update the initiatedBy and seenBy relation as well if the user is logged in and he/she is not the owner of the alert, so that user will not see that alert from app notification if he is the member of the receiving cell
            PFQuery *getCell411AlertQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [getCell411AlertQuery whereKey:@"objectId" equalTo:alertPayload.strCell411AlertId];
            [getCell411AlertQuery selectKeys:@[kCell411AlertInitiatedByKey,
                                               kCell411AlertSeenByKey
                                               ]];
            [getCell411AlertQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
                
                if (!error && object) {
                    PFUser *loggedInUser = [AppDelegate getLoggedInUser];
                    if(!loggedInUser){
                        ///Return if user is not logged in
                        return;
                    }
                    
                    ///Alert found, show it to user
                    PFObject *cell411Alert = object;
                    
                    ///2. update this on parse
                    PFRelation *initiatedByRelation = [cell411Alert relationForKey:kCell411AlertInitiatedByKey];
                    [initiatedByRelation addObject:currentUser];
                    
                    ///Update seenBy on Parse
                    PFRelation *seenByRelation = [cell411Alert relationForKey:kCell411AlertSeenByKey];
                    [seenByRelation addObject:currentUser];
                    
                    ///Save it in background
                    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            ///save it eventually if error occured
                            [cell411Alert saveEventually];
                        }
                    }];
                    
                }
                else {
                    
                    if(![AppDelegate handleParseError:error]){
                        
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"#error: %@",errorString);
                    }
                    
                }
            }];

        }
        
        ///show photo vc
        [self showPhotoVCUsingAlertPayload:alertPayload];

    }
    else if (alertPayload) {
        
        NSString *strAlertSenderUserId = alertPayload.strUserId;
        __weak typeof(self) weakSelf = self;
        
        ///1.check if this alert is recieved from user who has been spammed by current user i.e present in spamUsers relation, if this is true then do not show the alert
        [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
            
            if (status == SpamStatusIsSpammed) {
                
                ///This user is spammed by current user so the alert will not be shown
                
                
            }
            else{
                ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                if (error) {
                    ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                    NSLog(@"%@",error.localizedDescription);
                    
                }
                
                ///Show the alert without checking whether the current user is spammedBy the person sending photo alert, as the photo can be viewed in either case, and hence the entry for initiated (if he choses to view photo) or rejected(if he choses later option) will be made in Cell411Alert table in either case.
                [weakSelf showPhotoAlertWithAlertPayload:alertPayload];
            }
            
        }];
        
    }
    
}

-(void)didReceivedJoinPublicCellRequest:(NSNotification *)notif
{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        ///Make a message
        NSString *strMessage = [NSString stringWithFormat:@"%@ %@ %@. %@.",alertPayload.strFullName,NSLocalizedString(@"wants to join your Cell", nil),alertPayload.strCellName,NSLocalizedString(@"If approved, this member will be able to send emergency alerts to the members of this Cell", nil)];
        ///Show alert message
        UIAlertController *cellRequestAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *denyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Deny", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            ///User denied the join request
            [self handleUserResponseToCellRequestWithAlertPayload:alertPayload andApproveStatus:NO];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        UIAlertAction *approveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Approve", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            ///User approved the join request
            [self handleUserResponseToCellRequestWithAlertPayload:alertPayload andApproveStatus:YES];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [cellRequestAlert addAction:denyAction];
        [cellRequestAlert addAction:approveAction];
        //[[AppDelegate sharedInstance].window.rootViewController presentViewController:cellRequestAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:cellRequestAlert];

        
    }
}

-(void)didReceivedNewPublicCellCreatedAlert:(NSNotification *)notif
{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        __weak typeof(self) weakSelf = self;
        
        ///get the latest Public Cell object to see whether it still exist or not
        [C411StaticHelper getPublicCellWithObjectId:alertPayload.strCellId andCompletion:^(PFObject *object, NSError *error){
            
            if (!error && object[kPublicCellCreatedByKey]) {
                ///Make a message
                NSString *strMessage = [NSString stringWithFormat:@"%@ %@ %@.",NSLocalizedString(@"A new Public Cell called", nil),alertPayload.strCellName,NSLocalizedString(@"has just been created in your area. Tap on Join Cell to join this Public Cell, or Cancel to ignore", nil)];
                ///Show alert message
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    ///User tapped Cancel, refresh cells
                    ///Post notification
                    [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshPublicCellListingNotification object:nil];

                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];

                }];
                
                UIAlertAction *joinCellAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Join Cell", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    ///User tapped join cell, join the cell
                    [self joinPublicCellUsingPayload:alertPayload];

                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];

                }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:joinCellAction];
                //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
                ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                
            }
            else if (error.code == kPFErrorObjectNotFound){
                
                ///this public cell has been deleted by the owner
                ///log the error
                NSLog(@"Oops!!! This cell no longer exist.");
                
                
            }
            else{
                
                ///Log the error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"Error refreshing Public Cell object%@",errorString);
                
            }
        }];
        
        
        
        
    }
    
}

-(void)didRecievedRideRequest:(NSNotification *)notif
{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
            ///This is a RIDE_REQUEST alert, check for spam here for playing safe
            
            NSString *strAlertSenderUserId = alertPayload.strUserId;
            __weak typeof(self) weakSelf = self;
            
            ///1.check if this alert is recieved from user who has been spammed by current user i.e present in spamUsers relation, if this is true then do not show the ride request
            [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
                
                if (status == SpamStatusIsSpammed) {
                    
                    ///This user is spammed by current user so the alert will not be shown
                    
                }
                else{
                    ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show alert
                    if (error) {
                        ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                        NSLog(@"%@",error.localizedDescription);
                        
                    }
                    
                    ///2.///Check if this alert is recieved from user who has spammed current user i.e present in spammedBy relation, if this is true then also don't show the ride request
                    [[AppDelegate sharedInstance]didCurrentUserSpammedByUserWithId:strAlertSenderUserId andCompletion:^(SpamStatus status, NSError *error) {
                        
                        if (status == SpamStatusIsSpammed) {
                            
                            ///This user has spammed current user so the request will not be shown
                            
                        }
                        else{
                            ///The status is either SpamStatusUnknown or SpamStatusIsNotSpammed, we consider both cases to show ride request
                            if (error) {
                                ///Log the error if any but show the alert even if SpamStatus is SpamStatusUnknown
                                NSLog(@"%@",error.localizedDescription);
                                
                            }
                            
                            [weakSelf showRideRequestWithAlertPayload:alertPayload];
                            
                        }
                        
                    }];
                }
                
            }];
        
        
    }
    
}


-(void)didRecievedRideInterestedResponseFromDriver:(NSNotification *)notif{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        ///This is a RIDE_INTERESTED alert, no need to check for spam as driver will not get the request if he has been spammed by current user or he has spammed current user
        [self showRideResponseWithAlertPayload:alertPayload];
        
        
    }
    
}

-(void)didRecievedRideConfirmedFromRider:(NSNotification *)notif{
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
    
        ///Show ride confirmed alert
        [self showRideConfirmedWithAlertPayload:alertPayload];
        
    }
    
    ///Set seenByDriver to True for all case to avoid getting same notification again
    if (alertPayload.strRideResponseId.length > 0) {
        ///Update seenByDriver status to True for this response
        [self updateRideResponseWithId:alertPayload.strRideResponseId withSeenByDriverStatus:@(YES)];
        
    }

}

-(void)didRecievedRideRejectedFromRider:(NSNotification *)notif{
   
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        ///Show ride confirmed alert
        [self showRideRejectedWithAlertPayload:alertPayload];
        
        ///Set seenByDriver to True for all case to avoid getting same notification again
        if (alertPayload.strRideResponseId.length > 0) {
            ///Update seenByDriver status to True for this response
            [self updateRideResponseWithId:alertPayload.strRideResponseId withSeenByDriverStatus:@(YES)];
            
        }
        
    }

    
}

-(void)didRecievedRideSelectedFromRider:(NSNotification *)notif{
    
    C411AlertNotificationPayload *alertPayload = notif.object;
    if (alertPayload) {
        
        [self showRideSelectedWithAlertPayload:alertPayload];
        
    }

}

-(void)didUserRemovedFromCell:(NSNotification *)notif
{
    if ([AppDelegate getLoggedInUser]) {
        
        C411AlertNotificationPayload *alertPayload = notif.object;
        if (alertPayload) {
            
            ///set isRemoved for the particular cell id to disable chat for this user
            [C411ChatHelper handleUserRemovedFromEntityWithId:alertPayload.strCellId];
            
            ///Show the notification alert
             [C411StaticHelper showAlertWithTitle:nil message:alertPayload.strAlert onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
            ///Post notification to refresh public cells
            [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshPublicCellListingNotification object:nil];
            

        }

    }
}

-(void)userDidJoined:(NSNotification *)notif
{
    if ([AppDelegate getLoggedInUser]) {
        
        C411AlertNotificationPayload *alertPayload = notif.object;
        [self showUserJoinedPopupWithAlertPayload:alertPayload];
        
    }
}

@end
