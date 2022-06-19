//
//  C411UserProfilePopup.m
//  cell411
//
//  Created by Milan Agarwal on 11/05/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "C411UserProfilePopup.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
//#import "ServerUtility.h"
#import "Constants.h"
#import "C411ViewPhotoVC.h"
#import "AppDelegate.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411AppDefaults.h"
#import "MAAlertPresenter.h"
#import "C411ColorHelper.h"

@interface C411UserProfilePopup ()

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuBG;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCity;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertSent;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertsSent;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertResponded;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertsResponded;
@property (weak, nonatomic) IBOutlet UIView *vuAlertsSentBellOuterCircle;
@property (weak, nonatomic) IBOutlet UIView *vuAlertsSentBottomRightCircle;
@property (weak, nonatomic) IBOutlet UIView *vuAlertsRespondedBellOuterCircle;
@property (weak, nonatomic) IBOutlet UIView *vuAlertsRespondedBottomRightCircle;
@property (weak, nonatomic) IBOutlet UIView *vuAlertsSentCounterBase;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertsSentCounter;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *avtAlertsSent;
@property (weak, nonatomic) IBOutlet UIView *vuAlertsRespondedCounterBase;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertsRespondedCounter;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *avtAlertsResponded;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnAddOrRemoveFriend;
@property (weak, nonatomic) IBOutlet UIButton *btnSpam;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
///Vertical center constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAddOrRemoveFriendVC;

- (IBAction)tglBtnAddOrRemoveFriendTapped:(UIButton *)sender;
- (IBAction)btnSpamTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;

@property (nonatomic, assign, getter = isInitialized) BOOL initialized;
//@property (nonatomic, strong) NSURLSessionDataTask *getLocationTask;
@property (nonatomic, assign, getter = isAvatarAvailable) BOOL avatarAvailable;

@end

@implementation C411UserProfilePopup


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self configureViews];
    [self registerForNotifications];
    [C411StaticHelper removeOnScreenKeyboard];
    
}

-(void)dealloc
{
    [self unregisterFromNotifications];
//    [self.getLocationTask cancel];
//    self.getLocationTask = nil;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setUser:(PFUser *)user
{
    _user = user;
    if (!self.isInitialized) {
        
        [self setupUserProfileDetails];
        self.initialized = YES;

    }
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///1. set border color
//    UIColor *whiteColor = [UIColor whiteColor];
//    self.imgVuAvatar.layer.borderColor = whiteColor.CGColor;
//    self.imgVuAvatar.layer.borderWidth = 2.0;
    
    self.vuAlertsSentBellOuterCircle.layer.borderWidth = 2.0;
    self.vuAlertsRespondedBellOuterCircle.layer.borderWidth = 2.0;

    self.vuAlertsSentCounterBase.layer.borderWidth = 2.0;
    self.vuAlertsRespondedCounterBase.layer.borderWidth = 2.0;

    self.tglBtnAddOrRemoveFriend.layer.borderWidth = 2.0;
    self.btnClose.layer.borderWidth = 1.0;
    
    ///2. Make circular views
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    [C411StaticHelper makeCircularView:self.vuAlertsSentBellOuterCircle];
    [C411StaticHelper makeCircularView:self.vuAlertsRespondedBellOuterCircle];
    [C411StaticHelper makeCircularView:self.vuAlertsSentBottomRightCircle];
    [C411StaticHelper makeCircularView:self.vuAlertsRespondedBottomRightCircle];
    [C411StaticHelper makeCircularView:self.btnClose];

    ///3. Set corner radius
    self.vuAlertBase.layer.cornerRadius = 5.0;
    self.vuAlertBase.layer.masksToBounds = YES;
    self.tglBtnAddOrRemoveFriend.layer.cornerRadius = 3.0;
    self.tglBtnAddOrRemoveFriend.layer.masksToBounds = YES;
    self.btnSpam.layer.cornerRadius = 3.0;
    self.btnSpam.layer.masksToBounds = YES;
    self.vuAlertsSentCounterBase.layer.cornerRadius = self.vuAlertsSentCounterBase.bounds.size.height / 2;
    self.vuAlertsSentCounterBase.layer.masksToBounds = YES;
    self.vuAlertsRespondedCounterBase.layer.cornerRadius = self.vuAlertsRespondedCounterBase.bounds.size.height / 2;
    self.vuAlertsRespondedCounterBase.layer.masksToBounds = YES;
    
    ///6. set initial strings for localization
    self.lblCity.text = NSLocalizedString(@"Retreiving City...", nil);
    self.lblAlertsSent.text = NSLocalizedString(@"Alerts Sent", nil);
    self.lblAlertsResponded.text = NSLocalizedString(@"Alerts Responded", nil);

    [self.btnSpam setTitle:NSLocalizedString(@"Spam", nil) forState:UIControlStateNormal];
    [self.tglBtnAddOrRemoveFriend setTitle:NSLocalizedString(@"Add Friend", nil) forState:UIControlStateNormal];
    [self.tglBtnAddOrRemoveFriend setTitle:NSLocalizedString(@"Unfriend", nil) forState:UIControlStateSelected];

    [self applyColors];
}

-(void)applyColors {
    ///set background color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuAlertBase.backgroundColor = lightCardColor;
    
    ///set BG Image
    self.imgVuBG.image = [C411ColorHelper sharedInstance].imgGalleryBG;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblCity.textColor = primaryTextColor;
    self.lblFullName.textColor = primaryTextColor;
    
    ///Set hint icon color
    self.imgVuCity.tintColor = [C411ColorHelper sharedInstance].hintIconColor;

    ///1.1 Set Dark hint icon color
    UIColor *darkHintIconColor = [C411ColorHelper sharedInstance].darkHintIconColor;
    self.vuAlertsSentBellOuterCircle.layer.borderColor = darkHintIconColor.CGColor;
    self.vuAlertsRespondedBellOuterCircle.layer.borderColor = darkHintIconColor.CGColor;
    self.lblAlertsSent.textColor = darkHintIconColor;
    self.lblAlertsResponded.textColor = darkHintIconColor;
    self.imgVuAlertSent.tintColor = darkHintIconColor;
    self.imgVuAlertResponded.tintColor = darkHintIconColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuAlertsSentCounterBase.layer.borderColor = themeColor.CGColor;
    self.vuAlertsRespondedCounterBase.layer.borderColor = themeColor.CGColor;
    self.tglBtnAddOrRemoveFriend.layer.borderColor = themeColor.CGColor;
    self.lblAlertsSentCounter.textColor = themeColor;
    self.lblAlertsRespondedCounter.textColor = themeColor;
    self.vuAlertsSentBottomRightCircle.backgroundColor = themeColor;
    self.vuAlertsRespondedBottomRightCircle.backgroundColor = themeColor;
    [self.tglBtnAddOrRemoveFriend setTitleColor:themeColor forState:UIControlStateSelected];

    ///Set primary BG TEXT color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblFullName.textColor = primaryBGTextColor;
    [self.tglBtnAddOrRemoveFriend setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    UIColor *crossButtonColor = [C411ColorHelper sharedInstance].popupCrossButtonColor;
    self.btnClose.backgroundColor = crossButtonColor;

    ///1.4 border color of cross button
    UIColor *blackColor = [UIColor blackColor];
    self.btnClose.layer.borderColor = blackColor.CGColor;
    
}



-(void)addTapGestureOnImageView:(UIView *)imgVu
{
    ///Enable user interaction to listen tap event
    imgVu.userInteractionEnabled = YES;
    
    ///Add tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgVuAvatarTapped:)];
    [imgVu addGestureRecognizer:tapRecognizer];
}



-(void)setupUserProfileDetails
{
    ///Set tap gesture on avatar imageview
    [self addTapGestureOnImageView:self.imgVuAvatar];
    
    ///set user avatar
    __weak typeof(self) weakSelf = self;
    if (self.user) {
        [self.imgVuAvatar setAvatarForUser:self.user shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
            
            if (success && image) {
                 ///This user has profile picture available
                weakSelf.avatarAvailable = YES;
                
            }
            
        }];
    }
    
    ///Set user full name
    self.lblFullName.text = [C411StaticHelper getFullNameUsingFirstName:self.user[kUserFirstnameKey] andLastName:self.user[kUserLastnameKey]];
    
    ///Set city
    PFGeoPoint *userLocation = self.user[kUserLocationKey];
    [self updateLocationUsingCoordinate:CLLocationCoordinate2DMake(userLocation.latitude, userLocation.longitude)];

    ///update alerts sent counter
    [self updateAlertsSentCounter];
    
    ///update alerts responded counter
    [self updateAlertsRespondedCounter];
    
    ///Hide add friend and spam button until fetched
    self.tglBtnAddOrRemoveFriend.hidden = YES;
    self.btnSpam.hidden = YES;
    
    ///1. check whether this user is friend of this current user
    [self updateRelationshipWithUser];
    
    ///2. Check whether current user has spammed this user or not
    [self hideFlagIfSpammed];
    
}


-(void)updateLocationUsingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    
    GMSGeocoder *geoCoder = [GMSGeocoder geocoder];
    NSLog(@"%s",__PRETTY_FUNCTION__);
    __weak typeof(self) weakSelf = self;
    [geoCoder reverseGeocodeCoordinate:locCoordinate completionHandler:^(GMSReverseGeocodeResponse * _Nullable geoCodeResponse, NSError * _Nullable error) {
        
        if (!error && geoCodeResponse) {
            //NSLog(@"#Succeed: resp= %@\nerr=%@",geoCodeResponse,error);

            ///Get first available address
            GMSAddress *firstAddress = [geoCodeResponse firstResult];
            
            if (!firstAddress && ([geoCodeResponse results].count > 0)) {
                ///Additional handling to fallback to get address from array if in any case first result gives nil
                firstAddress = [[geoCodeResponse results]firstObject];
                
            }
            
            if(firstAddress){
                
                weakSelf.lblCity.text = firstAddress.locality;
            }
            else{
                
                weakSelf.lblCity.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        else{
            
            NSLog(@"#Failed: resp= %@\nerr=%@",geoCodeResponse,error);
        }

        
    }];
    
    /*
    NSLog(@"%s",__PRETTY_FUNCTION__);
    ///cancel previous request
    [self.getLocationTask cancel];
    self.getLocationTask = nil;
    
    ///make a new request
    NSString *strLatLong = [NSString stringWithFormat:@"%f,%f",locCoordinate.latitude,locCoordinate.longitude];
    //__weak typeof(self) weakSelf = self;
    
    self.getLocationTask = [ServerUtility getAddressForCoordinate:strLatLong andCompletion:^(NSError *error, id data) {
        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
        
        if (!error && data) {
            
            NSArray *results=[data objectForKey:kGeocodeResultsKey];
            
            if([results count]>0){
                
                NSDictionary *address=[results firstObject];
                NSArray *addcomponents=[address objectForKey:kGeocodeAddressComponentsKey];
                
                weakSelf.lblCity.text = [C411StaticHelper getAddressCompFromResult:addcomponents forType:kGeocodeTypeLocality useLongName:YES];
            }
            else{
                
                weakSelf.lblCity.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        
    }];
     */
    
}

-(void)updateAlertsSentCounter
{
    ///set the counter label text to nil
    self.lblAlertsSentCounter.text = nil;
    
    ///start animating the activity indicator
    [self.avtAlertsSent startAnimating];
    
    ///make the query the get alerts sent count
    PFQuery *alertsSentCounterQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [alertsSentCounterQuery whereKey:kCell411AlertIssuedByKey equalTo:self.user];
    [alertsSentCounterQuery whereKeyExists:kCell411AlertAlertTypeKey];
    [alertsSentCounterQuery whereKeyDoesNotExist:kCell411AlertToKey];

    __weak typeof(self)weakSelf = self;
    
    [alertsSentCounterQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        
        ///stop animating the activity indicator
        [weakSelf.avtAlertsSent stopAnimating];
        
        if (!error) {
            
            weakSelf.lblAlertsSentCounter.text = [NSString stringWithFormat:@"%d",number];
        }
        else{
            
            weakSelf.lblAlertsSentCounter.text = NSLocalizedString(@"N/A", nil);
        }
        
        
    }];
    
    
}

-(void)updateAlertsRespondedCounter
{
    ///set the counter label text to nil
    self.lblAlertsRespondedCounter.text = nil;
    
    ///start animating the activity indicator
    [self.avtAlertsResponded startAnimating];
    
    ///make the query the get alerts responded count
    PFQuery *alertsRespondedCounterQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
    [alertsRespondedCounterQuery whereKey:kCell411AlertInitiatedByKey equalTo:self.user];
    
    __weak typeof(self)weakSelf = self;
    
    [alertsRespondedCounterQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        
        ///stop animating the activity indicator
        [weakSelf.avtAlertsResponded stopAnimating];
        
        if (!error) {
            
            weakSelf.lblAlertsRespondedCounter.text = [NSString stringWithFormat:@"%d",number];
        }
        else{
            
            weakSelf.lblAlertsRespondedCounter.text = NSLocalizedString(@"N/A", nil);
        }
        
        
    }];
    

}


-(void)updateRelationshipWithUser
{
    ///Will check whether this user is a friend of current user or not
    if ([C411AppDefaults sharedAppDefaults].arrFriends) {
        
        ///Friend list is available, whether this user is a friend of current user or not in this list
        BOOL isFriend = NO;
        
        for (PFUser *user in [C411AppDefaults sharedAppDefaults].arrFriends) {
            if ([self.user.objectId isEqualToString:user.objectId]) {
                ///This user is already a friend of current user
                isFriend = YES;
                break;
            }
            
        }
        
        if (isFriend) {
            
            ///set the friend option as selected to show unfriend button
            self.tglBtnAddOrRemoveFriend.selected = YES;
            
            ///Set White as the background color
            self.tglBtnAddOrRemoveFriend.backgroundColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
            self.tglBtnAddOrRemoveFriend.tintColor = [C411ColorHelper sharedInstance].themeColor;
            
        }
        else{
            
            ///set the friend option as unselected to show add friend button
            self.tglBtnAddOrRemoveFriend.selected = NO;
            
            ///set theme color as background color
            ///Get the theme Color
            UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
            self.tglBtnAddOrRemoveFriend.backgroundColor = themeColor;
             self.tglBtnAddOrRemoveFriend.tintColor = [C411ColorHelper sharedInstance].primaryBGTextColor;

        }

        
    }
    else{
        
        ///Friend list is empty, wait for the friend list updated notification to update the button title.
        ///Do other things if required here
        
    }
}

-(void)sendFriendRequest
{
    
    ///Disable add firend/resend button
    self.tglBtnAddOrRemoveFriend.enabled = NO;

    ///Send friend request to this user
    __weak typeof(self) weakSelf = self;

    [[C411AppDefaults sharedAppDefaults] sendFriendRequestToUser:self.user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (succeeded) {
            
            ///Friend request is sent successfully
            NSString *strMessage = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"A friend invite is sent to", nil), weakSelf.lblFullName.text,NSLocalizedString(@"for approval", nil)];
            [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:[AppDelegate sharedInstance].window.rootViewController];
            
            ///2. update the title to Resend
            [weakSelf.tglBtnAddOrRemoveFriend setTitle:NSLocalizedString(@"Resend", nil) forState:UIControlStateNormal];

            
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
        
        ///Enable add firend/resend button
        weakSelf.tglBtnAddOrRemoveFriend.enabled = YES;

        
    }];

    
}

-(void)unfriendUser
{
    ///Disable unfriend button
    self.tglBtnAddOrRemoveFriend.enabled = NO;
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFRelation *friendsRelation = [currentUser relationForKey:kUserFriendsKey];
    [friendsRelation removeObject:self.user];
    
    __weak typeof(self) weakSelf = self;
    ///save current user object
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (succeeded) {
            
            ///1.Ask app to remove this friend from its array and post notification when removed to update the friends list
            [[C411AppDefaults sharedAppDefaults] removeFriend:weakSelf.user];
            
            ///2. update the title to Add friend again
            [weakSelf.tglBtnAddOrRemoveFriend setTitle:NSLocalizedString(@"Add Friend", nil) forState:UIControlStateNormal];
            
            ///3. change the selected state to show add friend option
            weakSelf.tglBtnAddOrRemoveFriend.selected = NO;
            
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
        
        ///enable the button again
        weakSelf.tglBtnAddOrRemoveFriend.enabled = YES;
        
    }];

}

-(void)hideFlagIfSpammed
{
    
    ///Check if current user has already spammed this user or not
    
    __weak typeof(self) weakSelf = self;
    [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:weakSelf.user.objectId andCompletion:^(SpamStatus status, NSError *error)
     {
         ///Check whether user is already spammed or not
         if (!error) {
             
             if (status == SpamStatusIsSpammed) {
                 
                 ///This user is already spammed, remove spam button
                 [weakSelf removeSpamOption];
                 
             }
         }
         else{
             
             ///Error occured while checking whether this user has been already spammed or not
             ///show error
             NSString *errorString = [error userInfo][@"error"];
             [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
             

         }
         
         ///unhide the add friend button
         self.tglBtnAddOrRemoveFriend.hidden = NO;
         
         ///unhide the spam option
         weakSelf.btnSpam.hidden = NO;


         
     }];
    
}


-(void)removeSpamOption
{
    ///remove the spam button
    [self.btnSpam removeFromSuperview];
    
    ///remove the horizontally center constraint from add/remove friend button
    //[self.tglBtnAddOrRemoveFriend removeConstraint:self.cnsAddOrRemoveFriendVC];
    self.cnsAddOrRemoveFriendVC.active = NO;
    
    ///add the horizontally center constraint to add/remove friend button with respect to superview
    // Center Vertically
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:self.tglBtnAddOrRemoveFriend
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.vuAlertBase
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
    [self.vuAlertBase addConstraint:centerXConstraint];

}


-(void)spamUser:(PFUser *)user
{
    ///change color and disable spam button
//    UIColor *currentColor = self.btnSpam.backgroundColor;
//    [self.btnSpam setBackgroundColor:[C411StaticHelper colorFromHexString:DISABLED_COLOR]];
    self.btnSpam.enabled = NO;
    __weak typeof(self) weakSelf = self;
    
    [[AppDelegate sharedInstance]didCurrentUserSpammedUserWithId:user.objectId andCompletion:^(SpamStatus status, NSError *error)
     {
         ///Check whether user is already spammed or not
         if (!error) {
             
             if (status == SpamStatusIsSpammed) {
                 
                 ///show alert that this user is already spammed
                 NSString *issuerFullName = [C411StaticHelper getFullNameUsingFirstName:user[kUserFirstnameKey] andLastName:user[kUserLastnameKey]];
                 NSString *strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is already blocked.",nil),issuerFullName];
                 [C411StaticHelper showAlertWithTitle:nil message:strAlertMsg onViewController:[AppDelegate sharedInstance].window.rootViewController];
                 
                 ///hide the flag button
                 [weakSelf removeSpamOption];
                 
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
                                 [C411StaticHelper showAlertWithTitle:nil message:strAlertMsg onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                 
                                 ///hide the flag button
                                 [weakSelf removeSpamOption];
                                 
                                 ///post notification to observers
                                 [[NSNotificationCenter defaultCenter]postNotificationName:kUserBlockedNotification object:user.objectId];
                                 
                             }
                             else{
                                 ///Unable to create SPAM_ADD task
                                 if (error) {
                                     ///show error
                                     NSString *errorString = [error userInfo][@"error"];
                                     [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                                 }
                                 
                                  ///Reenable button and set it's color back to old one
                                 weakSelf.btnSpam.enabled = YES;
                                // weakSelf.btnFlag.backgroundColor = currentColor;
                                 
                             }
                             
                             
                         }];
                         
                     }
                     else{
                         ///some error occured marking user as spam
                         if (error) {
                             ///show error
                             NSString *errorString = [error userInfo][@"error"];
                             [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                         }
                         
                         ///Reenable button and set it's color back to old one
                         weakSelf.btnSpam.enabled = YES;
                         //weakSelf.btnFlag.backgroundColor = currentColor;
                         
                     }
                     
                 }];
                 
                 
             }
         }
         else{
             
             ///Error occured while checking whether this user has been already spammed or not
             ///show error
             NSString *errorString = [error userInfo][@"error"];
             [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
             
             ///Reenable button and set it's color back to old one
             weakSelf.btnSpam.enabled = YES;
            // weakSelf.btnFlag.backgroundColor = currentColor;
             
         }
         
     }];
    
}



-(void)registerForNotifications
{
    [super registerForNotifications];
    
    ///register for notification to listen for friend list updation
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(friendListUpdated:) name:kFriendListUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterFromNotifications
{
    
    [super unregisterFromNotifications];

    ///Remove observing from notification attached on this class
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kFriendListUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDarkModeValueChangedNotification object:nil];
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)tglBtnAddOrRemoveFriendTapped:(UIButton *)sender {
    

    if (sender.isSelected) {
        
        ///Unfriend this user
        [self unfriendUser];
        
    }
    else{
        
        ///send friend request to this user
        [self sendFriendRequest];
    }
    
}

- (IBAction)btnSpamTapped:(UIButton *)sender {
    
    ///show the confirmation dialog first
    NSString *strUserFullName = self.lblFullName.text;
    NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Are you sure you want to flag %@ as a spammer?",nil),strUserFullName];
    UIAlertController *confirmSpamAlert = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        ///user said No, do nothing
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///User opted to spam the user
        [self spamUser:self.user];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [confirmSpamAlert addAction:noAction];
    [confirmSpamAlert addAction:yesAction];
    //[[AppDelegate sharedInstance].window.rootViewController presentViewController:confirmSpamAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:confirmSpamAlert];

}

- (IBAction)btnCloseTapped:(UIButton *)sender {
    
    if (self.actionHandler != NULL) {
        ///call the Close action handler
        self.actionHandler(sender,0,nil);
        
    }

        [self removeFromSuperview];
    
}

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    
    ///Show photo VC to view photo alert
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
    if (self.isAvatarAvailable) {
        
        ///set image
        UIImageView *imgVuAvatar = (UIImageView *) sender.view;
        viewPhotoVC.imgPhoto = imgVuAvatar.image;
    }
    else{
        
        ///set user object to be used to fetch avatar
        viewPhotoVC.user = self.user;
        
    }
    [navRoot pushViewController:viewPhotoVC animated:YES];
}


//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)friendListUpdated:(NSNotification *)notif
{
    ///update the relationship with user
    [self updateRelationshipWithUser];
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
