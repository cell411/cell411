//
//  AppDelegate.m
//  cell411
//
//  Created by Milan Agarwal on 15/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "AppDelegate.h"
//#import <GoogleMaps/GoogleMaps.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
#import "ConfigConstants.h"
#import "Constants.h"
#import "C411AppDefaults.h"
#import "C411AlertNotificationPayload.h"
#import "C411StaticHelper.h"
#import "C411PanicAlertSettings.h"
#import "ServerUtility.h"
#import "MAAlertPresenter.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "C411AlertSettings.h"
#import "C411PrivacyPolicyVC.h"

#if PHONE_VERIFICATION_ENABLED

#import "C411AddPhoneVC.h"
#import "C411PhoneVerificationVC.h"

#endif

#if FB_ENABLED

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "PFFacebookUtils.h"
#import <Bolts/Bolts.h>
//#import "C411PublishToUserWallPopup.h"

#endif

#if CHAT_ENABLED

#import "C411ChatManager.h"
#import "C411ChatHelper.h"
#import "C411ChatVC.h"
@import Firebase;

#endif

#if NOTIFICATION_ACK_ENABLED

#import "C411AlertHelper.h"

#endif

#if APP_RO112
#import "C411ActivateAccountVC.h"
#endif

@import UserNotifications;
@import GooglePlaces;

#define TIME_TO_LIVE 2*60*60  ///IN seconds


@interface AppDelegate ()<UNUserNotificationCenterDelegate>

///This will contain the Cell411AlertId/TaskId from alert notification payload to avoid displaying the tapped notification twice when fetching notifications from parse
@property (nonatomic, strong) NSString *tappedNotificationAlertId;
@property (nonatomic, strong) NSString * tappedNotifAdditionalNoteId;
@property (nonatomic, strong) NSString *tappedRideRequestId;
@property (nonatomic, strong) NSString *tappedRideResponseId;
@property (nonatomic, strong) NSString * tappedRideResponseFromRiderId;
//@property (nonatomic, assign) BOOL isLinkingToFB;

@end

@implementation AppDelegate


//****************************************************
#pragma mark - Life cycle Methods
//****************************************************


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
#if (CHAT_ENABLED || NOTIFICATION_ACK_ENABLED)
    [FIRApp configure];
#endif

    ///Setup Crashlytics
    [Fabric with:@[[Crashlytics class]]];
    
    ///Setup Parse
    //[Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = PARSE_APP_ID;
        configuration.clientKey = PARSE_CLIENT_KEY;
        configuration.server = @"https://parseapi.back4app.com";
        configuration.localDatastoreEnabled = YES; // If you need to enable local data store
    }]];
 
    [PFUser enableRevocableSessionInBackground];
    
#if FB_ENABLED
   
    ///Initialize Facebook through parse API
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [self validateFBAccessToken];
#endif
    
    ///Setup Google Map
    [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
    ///Setup Places SDK
    [GMSPlacesClient provideAPIKey:GOOGLE_MAP_API_KEY];
    
    ///set initial settings
    [self setInitialSettings];
    
    NSNumber *locationAvailable = [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey];
    if (locationAvailable) {
        ///App launched in killed state to deliver location updates for Significant Change Location Service
        self.locationAvailableInLaunchOptions = [locationAvailable boolValue];
        
    }

    if ([self canShowMainInterface]) {
        [self showMainInterface];
    }
    
#if APP_RO112
    ///Check for account activation
    [self checkForAccountActivation];
#endif

    ///Check for app versions
    [self handleVersionCheck];
    
    ///Setup Remote Notifications
    [self setupRemoteNotifications];

    ///Reset badge number on launch
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    ///Register notifications for AppDefaults
    [[C411AppDefaults sharedAppDefaults]registerForNotifications];
   
    
    // Extract the notification data for iOS versions below iOS 10 as from iOS 10 it can be handled through userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler method
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        
        NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (notificationPayload) {
            ///App launched by tapping on notification, give some time to observer to register itself before sending notification
            __weak typeof(self) weakSelf = self;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [weakSelf processNotificationUserInfo:notificationPayload];
                
            });
        }

    }
    
    
    ///fetch needy alert from server as well, whenever app launches as this time applicationWillEnterForeground method will not get called
    [self fetchAlerts];
    
    

    
    ///Clear Image cache to load Gravatar from web on each session
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];

    ///Clear notifications from tray and badge
    [self resetBadgeAndNotificationsFromTray];
    
    ///verify user privileges
    [self verifyUserPrivileges];
    

    return YES;
}

#if FB_ENABLED

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    /*
    else if([[url absoluteString] containsString:@"http://reset_password"]){
        
        NSString *strUrl = [url absoluteString];
        NSLog(@"host:%@\npath:%@\nparameterString:%@\nquery:%@",url.host, url.path, url.parameterString,url.query);
        NSString *substring = nil;
        NSRange newlineRange = [strUrl rangeOfString:@"="];
        if(newlineRange.location != NSNotFound) {
            substring = [strUrl substringFromIndex:newlineRange.location+1];
        }
        
        ///Dispatch reset password notification after 0.5 sec
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kResetPasswordNotification
             object:substring];

        });
        
        return YES;

    }
     */
    return [[FBSDKApplicationDelegate sharedInstance] application:application
            
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    
}

#endif

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   
    ///Clear iVar holding tapped notification alert id and additionalNoteId
    self.tappedNotificationAlertId = nil;
    self.tappedNotifAdditionalNoteId = nil;

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    ///Check version on foreground
    [self handleVersionCheck];

    ///fetch needy alert from server as well, whenever app comes in forground
    [self fetchAlerts];
    
    ///Clear notifications from tray and badge
    [self resetBadgeAndNotificationsFromTray];
    
    ///verify user privileges
    [self verifyUserPrivileges];

#if FB_ENABLED
//    if(!self.isLinkingToFB){
        [self validateFBAccessToken];
//    }
#endif

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
#if FB_ENABLED
      [FBSDKAppEvents activateApp];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    [self setBackgroundSessionCompletionHandler:completionHandler];
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(BOOL)canShowMainInterface
{

    if ([AppDelegate getLoggedInUser]) {
        ///User exists
        return YES;
        
    }
    else{
        ///User doesn't exists
        return NO;
        
    }
}

-(void)showMainInterface
{
    UINavigationController *mainInterfaceNavC = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"MainInterfaceNavC"];
    self.window.rootViewController = mainInterfaceNavC;
    
    ///Log user to crashlytics
    [self logUserToCrashlytics];
    
#if CHAT_ENABLED
    ///Log user to firebase
    [AppDelegate logUserToFirebaseWithCompletion:NULL];
#endif
    
    ///Check for Privacy Policy Update
    [self checkPrivacyPolicyUpdate];
    
}

-(void)showWelcomeGalleryScreen
{
    UINavigationController *welcomeGalleryNavC = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"C411WelcomeGalleryNavC"];
    self.window.rootViewController = welcomeGalleryNavC;
    
}

-(void)handleVersionCheck
{
//#if DEBUG
//    return;
//#endif
    [ServerUtility getAppVersionsWithCompletion:^(NSError *error, id data) {
        
        if (!error) {
            
            NSString *strRespType = [(NSDictionary *)data objectForKey:kResponseTypeKey];
            if ([strRespType.lowercaseString isEqualToString:kResponseTypeData.lowercaseString]) {
                ///Response is valid
                NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
                //float appVersion = [appVersionString floatValue];
                
                
                NSString *strMinVersion = [data objectForKey:API_PARAM_MIN_VERSION];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                ///check for minimum version
                NSComparisonResult minVersionCheckResult = [C411StaticHelper compareVersionString:appVersionString withString:strMinVersion];
                if (minVersionCheckResult != NSOrderedAscending) {
                    
                    ///app version is greater than min version required, now check if current version is a bad version or not
                    
                    NSArray *arrBadVersions = [data objectForKey:API_PARAM_BAD_VERSIONS];
                    BOOL isCurrentVersionBad = NO;
                    NSString *strBadVersionMsg = @"";
                    for (NSDictionary *dictBadVersion in arrBadVersions) {
                        NSString *strBadVersion = [dictBadVersion objectForKey:API_PARAM_VERSION];
                        if ([strBadVersion isEqualToString:appVersionString]) {
                            
                            isCurrentVersionBad = YES;
                            strBadVersionMsg = [dictBadVersion objectForKey:API_PARAM_DESCRIPTION];
                            break;
                        }
                    }
                    
                    if (!isCurrentVersionBad) {
                        ///Current version is good to use,
                        
                        ///1. Show custom message if available for this version
                        NSArray *arrCustomMsgs = [data objectForKey:API_PARAM_MESSAGES];
                        [self showCustomMessageIfAvailable:arrCustomMsgs];
                        
                        ///2.now check for any recommended version
                        NSString *strRecommendedVersion = [data objectForKey:API_PARAM_RECOMMENDED_VERSION];
                        NSComparisonResult recomVersionCheckResult = [C411StaticHelper compareVersionString:appVersionString withString:strRecommendedVersion];
                        if (recomVersionCheckResult != NSOrderedAscending) {
                            
                            ///User is already on or above the recommended version, check for any major version
                            NSString *strMajorVersion = [data objectForKey:API_PARAM_MAJOR_VERSION];
                            NSComparisonResult majorVersionCheckResult = [C411StaticHelper compareVersionString:appVersionString withString:strMajorVersion];
                            if (majorVersionCheckResult != NSOrderedAscending) {
                                
                                ///User is already on or above major version, check for current version
                                NSString *strCurrentVersion = [data objectForKey:API_PARAM_CURRENT_VERSION];
                                NSComparisonResult currentVersionCheckResult = [C411StaticHelper compareVersionString:appVersionString withString:strCurrentVersion];
                                if (currentVersionCheckResult == NSOrderedAscending) {
                                    
                                    ///Display a message to the user informing about a new release and provide them options: Update and Later (If user taps on later, don't prompt them again for the same version to update, this has to be managed locally)
                                    NSDictionary *dictCurrentVerPopupDetails = [defaults objectForKey:API_PARAM_CURRENT_VERSION];
                                    NSString *strLastCurrentVersion = [dictCurrentVerPopupDetails objectForKey:kVersionNumberKey];
                                    
                                    if ((!strLastCurrentVersion) || ([C411StaticHelper compareVersionString:strCurrentVersion withString:strLastCurrentVersion] == NSOrderedDescending)) {
                                        
                                        ///there is a new version released which is not yet informed to user
                                        
                                        NSString *strMessage = [data objectForKey:API_PARAM_DESC_CURRENT_VERSION];
                                        [C411StaticHelper showUpdateAppNowOrLaterAlertWithMessage:strMessage];
                                        
                                        ///save the entry on defaults
                                        NSTimeInterval popupDisplayTimestamp = [[NSDate date]timeIntervalSince1970];
                                        NSDictionary *dictCurrVersion = @{kVersionNumberKey:strCurrentVersion,
                                                                         kPopupDisplayTimestampKey:@(popupDisplayTimestamp)};
                                        [defaults setObject:dictCurrVersion forKey:API_PARAM_CURRENT_VERSION];
                                        [defaults synchronize];
                                        
                                    }

                                }
                                else{
                                    
                                    ///User is using the latest version, don't show any alert and let him use the app
                                    NSLog(@"User is on latest version");
                                }
                                
                            }
                            else{
                                
                                ///Display a teaser content once to the user about the new major release features and ask them to update
                                
                                NSString *strMajorVersion = [data objectForKey:API_PARAM_MAJOR_VERSION];
                                    NSDictionary *dictMajorVerPopupDetails = [defaults objectForKey:API_PARAM_MAJOR_VERSION];
                                    NSString *strLastMajorVersion = [dictMajorVerPopupDetails objectForKey:kVersionNumberKey];
                                    
                                    if ((!strLastMajorVersion) || ([C411StaticHelper compareVersionString:strMajorVersion withString:strLastMajorVersion] == NSOrderedDescending)) {
                                        
                                        ///there is a major version released which is not yet informed to user
                                        
                                        NSString *strMessage = [data objectForKey:API_PARAM_DESC_MAJOR_VERSION];
                                        [C411StaticHelper showUpdateAppNowOrLaterAlertWithMessage:strMessage];
                                        
                                        ///save the entry on defaults
                                        NSTimeInterval popupDisplayTimestamp = [[NSDate date]timeIntervalSince1970];
                                        NSDictionary *dictMajVersion = @{kVersionNumberKey:strMajorVersion,
                                                                         kPopupDisplayTimestampKey:@(popupDisplayTimestamp)};
                                        [defaults setObject:dictMajVersion forKey:API_PARAM_MAJOR_VERSION];
                                        [defaults synchronize];
                                        
                                    }
                                    else{
                                        
                                        ///User has already seen  major version alert, check for current version
                                        NSString *strCurrentVersion = [data objectForKey:API_PARAM_CURRENT_VERSION];
                                        NSDictionary *dictCurrentVerPopupDetails = [defaults objectForKey:API_PARAM_CURRENT_VERSION];
                                        NSString *strLastCurrentVersion = [dictCurrentVerPopupDetails objectForKey:kVersionNumberKey];
                                        if (([C411StaticHelper compareVersionString:strCurrentVersion withString:strMajorVersion] == NSOrderedDescending) && ([C411StaticHelper compareVersionString:strCurrentVersion withString:strLastCurrentVersion] == NSOrderedDescending)) {
                                            
                                            ///Display a message to the user informing about a new release and provide them options: Update and Later (If user taps on later, don't prompt them again for the same version to update, this has to be managed locally)
                                            
                                            ///there is a new version released which is not yet informed to user
                                            
                                            NSString *strMessage = [data objectForKey:API_PARAM_DESC_CURRENT_VERSION];
                                            [C411StaticHelper showUpdateAppNowOrLaterAlertWithMessage:strMessage];
                                            
                                            ///save the entry on defaults
                                            NSTimeInterval popupDisplayTimestamp = [[NSDate date]timeIntervalSince1970];
                                            NSDictionary *dictCurrVersion = @{kVersionNumberKey:strCurrentVersion,
                                                                              kPopupDisplayTimestampKey:@(popupDisplayTimestamp)};
                                            [defaults setObject:dictCurrVersion forKey:API_PARAM_CURRENT_VERSION];
                                            [defaults synchronize];
                                            
                                            
                                        }
                                        else{
                                            
                                            ///User is using the latest version, don't show any alert and let him use the app
                                            NSLog(@"User is on latest version");
                                        }
                                        
                                        
                                    }
                               
                            }
                            
                        }
                        else{
                            
                            ///Get the grace period
                            NSInteger gracePeriod = [[data objectForKey:API_PARAM_REMAINING_DAYS]integerValue];
                            if (gracePeriod > 0) {
                                
                                ///Display a screen once asking users to update their app, user can also skip to update for the time being [PROCEED TO APP]
                                
                                NSDictionary *dictRecVerPopupDetails = [defaults objectForKey:API_PARAM_RECOMMENDED_VERSION];
                                NSString *strLastRecommendedVersion = [dictRecVerPopupDetails objectForKey:kVersionNumberKey];
                                NSTimeInterval lastPopupDisplayTimestamp = [[dictRecVerPopupDetails objectForKey:kPopupDisplayTimestampKey]doubleValue];
                                if ((!strLastRecommendedVersion)
                                    ||([C411StaticHelper compareVersionString:strLastRecommendedVersion withString:strRecommendedVersion] == NSOrderedAscending)
                                    ||(([C411StaticHelper compareVersionString:strLastRecommendedVersion withString:strRecommendedVersion] == NSOrderedSame)
                                       &&([[NSDate date]timeIntervalSince1970] - lastPopupDisplayTimestamp >= 24*60*60))) {
                                   
                                    ///show recommended version popup as it's not shown yet for this version or 24 hours have been passed when it's displayed last
                                    NSString *strMessage = [data objectForKey:API_PARAM_DESC_RECOMMENDED_VERSION];
                                    [C411StaticHelper showUpdateAppNowOrLaterAlertWithMessage:strMessage];
                                    
                                    ///save the entry on defaults
                                    NSTimeInterval popupDisplayTimestamp = [[NSDate date]timeIntervalSince1970];
                                    NSDictionary *dictRecVersion = @{kVersionNumberKey:strRecommendedVersion,
                                                                     kPopupDisplayTimestampKey:@(popupDisplayTimestamp)};
                                    [defaults setObject:dictRecVersion forKey:API_PARAM_RECOMMENDED_VERSION];
                                    [defaults synchronize];

                                }
                                else{
                                    ///recommended version popup is already shown, check if there is any higher major version available and not informed to user
                                    NSString *strMajorVersion = [data objectForKey:API_PARAM_MAJOR_VERSION];
                                    NSDictionary *dictMajorVerPopupDetails = [defaults objectForKey:API_PARAM_MAJOR_VERSION];
                                    NSString *strLastMajorVersion = [dictMajorVerPopupDetails objectForKey:kVersionNumberKey];
                                    
                                    if (([C411StaticHelper compareVersionString:strMajorVersion withString:strRecommendedVersion] == NSOrderedDescending) && ([C411StaticHelper compareVersionString:strMajorVersion withString:strLastMajorVersion] == NSOrderedDescending)) {
                                        
                                        ///there is a major version released after the recommended version, which is not yet informed to user
                                        
                                        NSString *strMessage = [data objectForKey:API_PARAM_DESC_MAJOR_VERSION];
                                        [C411StaticHelper showUpdateAppNowOrLaterAlertWithMessage:strMessage];
                                        
                                        ///save the entry on defaults
                                        NSTimeInterval popupDisplayTimestamp = [[NSDate date]timeIntervalSince1970];
                                        NSDictionary *dictMajVersion = @{kVersionNumberKey:strMajorVersion,
                                                                         kPopupDisplayTimestampKey:@(popupDisplayTimestamp)};
                                        [defaults setObject:dictMajVersion forKey:API_PARAM_MAJOR_VERSION];
                                        [defaults synchronize];

                                    }
                                    else{
                                       
                                        ///User has already seen recommended and major version alert, check for current version
                                        NSString *strCurrentVersion = [data objectForKey:API_PARAM_CURRENT_VERSION];
                                        NSDictionary *dictCurrentVerPopupDetails = [defaults objectForKey:API_PARAM_CURRENT_VERSION];
                                        NSString *strLastCurrentVersion = [dictCurrentVerPopupDetails objectForKey:kVersionNumberKey];
                                        if (([C411StaticHelper compareVersionString:strCurrentVersion withString:strMajorVersion] == NSOrderedDescending) && ([C411StaticHelper compareVersionString:strCurrentVersion withString:strLastCurrentVersion] == NSOrderedDescending)) {
                                            
                                            ///Display a message to the user informing about a new release and provide them options: Update and Later (If user taps on later, don't prompt them again for the same version to update, this has to be managed locally)
                                           
                                            ///there is a new version released which is not yet informed to user
                                                
                                                NSString *strMessage = [data objectForKey:API_PARAM_DESC_CURRENT_VERSION];
                                                [C411StaticHelper showUpdateAppNowOrLaterAlertWithMessage:strMessage];
                                                
                                                ///save the entry on defaults
                                                NSTimeInterval popupDisplayTimestamp = [[NSDate date]timeIntervalSince1970];
                                                NSDictionary *dictCurrVersion = @{kVersionNumberKey:strCurrentVersion,
                                                                                  kPopupDisplayTimestampKey:@(popupDisplayTimestamp)};
                                                [defaults setObject:dictCurrVersion forKey:API_PARAM_CURRENT_VERSION];
                                                [defaults synchronize];
                                                
                                                
                                        }
                                        else{
                                            
                                            ///User is using the latest version, don't show any alert and let him use the app
                                            NSLog(@"User is on latest version");
                                        }

                                        
                                    }
                                    
                                }
                                
                                
                            }
                            else{
                                
                                ///Display a screen asking users to update their app, user can not skip to update [STOP THE APP]
                                NSString *strMessage = [data objectForKey:API_PARAM_DESC_RECOMMENDED_VERSION_PERIOD_OVER];
                                [C411StaticHelper showUpdateAppAlertWithMessage:strMessage];
                                

                            }
                            
                        }
                        
                    }
                    else{
                        
                        ///Show the bad version alert and stop the app
                        [C411StaticHelper showUpdateAppAlertWithMessage:strBadVersionMsg];

                    }
                    
                }
                else{
                    
                    ///show the minimum version alert and stop the app
                   NSString *strMessage = [data objectForKey:API_PARAM_DESC_MIN_VERSION];
                    [C411StaticHelper showUpdateAppAlertWithMessage:strMessage];
                 

                    
                }
                
            }
            else if ([strRespType.lowercaseString isEqualToString:kResponseTypeErrorDisplay.lowercaseString]) {
                ///Some error occured
                
                NSString *strErrorMsg = [data objectForKey:kMessageKey];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:strErrorMsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    
                    ///Dequeue the current Alert Controller and allow other to be visible
                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                    
                    ///Terminate the app
                    exit(0);
                    

                    
                }];
                
                [alertController addAction:okAction];
                //[viewController presentViewController:alertController animated:YES completion:NULL];
                ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
                
            }
            else {
                ///Some thing else happened, let the user use the app
                NSLog(@"#response%@",data);
            }

        }
        else{
            
            NSLog(@"Error checking app version:%@",error.localizedDescription);
        }
        
    }];
}

-(void)showCustomMessageIfAvailable:(NSArray *)arrVersionMsgs
{
    ///now check if there is any custom message for current version or not
    BOOL isCurrentVersionMsgExist = NO;
    NSString *strVersionMsg = @"";
    NSString *strPromptFreq = @"";
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    for (NSDictionary *dictVersionMsgs in arrVersionMsgs) {
        NSString *strVersion = [dictVersionMsgs objectForKey:API_PARAM_VERSION];
        if ([strVersion isEqualToString:appVersionString]) {
            
            isCurrentVersionMsgExist = YES;
            strVersionMsg = [dictVersionMsgs objectForKey:API_PARAM_DESCRIPTION];
            strPromptFreq = [dictVersionMsgs objectForKey:API_PARAM_PROMPT_FREQUENCY];
            break;
        }
    }
    
    if (isCurrentVersionMsgExist) {
       
        ///There is a msg available for current version, check the prompt frequency
        if ([strPromptFreq isEqualToString:API_PROMPT_FREQUENCY_VALUE_ALWAYS]) {
            
            ///Show message to user if user has not tapped on Don't show again for this version message
            if ([self canShowCustomMessagePopupForPromtFrequency:strPromptFreq]) {
                
                ///Show the custom message popup with dont's show again button
                [C411StaticHelper showCustomVersionSpecificAlertWithMessage:strVersionMsg shouldDisplayDontShowOption:YES forDefaultsKey:API_PARAM_MESSAGES];
            }
            
        }
        else if ([strPromptFreq isEqualToString:API_PROMPT_FREQUENCY_VALUE_DAILY]) {
            
            ///Show message to user if user has not tapped on Don't show again for this version message and time difference when it was displayed last is greater than 24 hours
            if ([self canShowCustomMessagePopupForPromtFrequency:strPromptFreq]) {
                
                ///Show the custom message popup with dont's show again button
                [C411StaticHelper showCustomVersionSpecificAlertWithMessage:strVersionMsg shouldDisplayDontShowOption:YES forDefaultsKey:API_PARAM_MESSAGES];
            }

            
        }
        else if ([strPromptFreq isEqualToString:API_PROMPT_FREQUENCY_VALUE_ONCE]) {
            
            ///Show message to user if it's not shown for this version
            if ([self canShowCustomMessagePopupForPromtFrequency:strPromptFreq]) {
                
                ///Show the custom message popup with ok button only
                [C411StaticHelper showCustomVersionSpecificAlertWithMessage:strVersionMsg shouldDisplayDontShowOption:NO forDefaultsKey:API_PARAM_MESSAGES];
            }

        }
        
        
    
    }

}

-(BOOL)canShowCustomMessagePopupForPromtFrequency:(NSString *)strPromptFreq
{
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictCustomMessagePopupDetails = [defaults objectForKey:API_PARAM_MESSAGES];
    NSString *strLastCustomMessageVersion = [dictCustomMessagePopupDetails objectForKey:kVersionNumberKey];
    NSTimeInterval lastPopupDisplayTimestamp = [[dictCustomMessagePopupDetails objectForKey:kPopupDisplayTimestampKey]doubleValue];
    BOOL dontShow = [[dictCustomMessagePopupDetails objectForKey:kDontShowPopupKey]boolValue];
    
    if ((!strLastCustomMessageVersion)
        ||([C411StaticHelper compareVersionString:strLastCustomMessageVersion withString:appVersionString] == NSOrderedAscending)) {
            
            ///Custom Message popup has not been displayed for this version yet, so it can be displayed. This also accounts for prompt frequency as once
            
            return YES;
        
        }
    else if (([C411StaticHelper compareVersionString:strLastCustomMessageVersion withString:appVersionString] == NSOrderedSame)
             &&(![strPromptFreq isEqualToString:API_PROMPT_FREQUENCY_VALUE_ONCE])){
        
        ///Custom message has beed already displayed for this version and the prompt frequency is not once, so do additional checks
        
        if (dontShow) {
            ///User has said not to show this message again for this version, so it should not be displayed
            return NO;
        }
        else if ([strPromptFreq isEqualToString:API_PROMPT_FREQUENCY_VALUE_ALWAYS]){
            
            ///Prompt frequency is always, so this message can be shown again
            return YES;
            
        }
        else if (([strPromptFreq isEqualToString:API_PROMPT_FREQUENCY_VALUE_DAILY])
                 &&([[NSDate date]timeIntervalSince1970] - lastPopupDisplayTimestamp >= 24*60*60)){
            
            ///Prompt frequency is daily and 24 hours have been passed when it displayed last, so this message can be shown again
            
            return YES;
        }
    }
    
    
    return NO;

}

-(void)setInitialSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:kDidSetLocationSettings]) {
        
        ///Set initial settings for location
        [defaults setBool:YES forKey:kLocationAccuracyOn];
        [defaults setBool:YES forKey:kLocationUpdateOn];
        ///Set flag to indicate initial settings is set
        [defaults setBool:YES forKey:kDidSetLocationSettings];
        
        [defaults synchronize];
    }
    /*
     if (![defaults objectForKey:kPublishOnFB]) {
     
     ///Set social Media sharing to On by default
     [defaults setObject:@(YES) forKey:kPublishOnFB];
     [defaults synchronize];
     
     ///Note: I am not using setBool because, I need to know whether this key exist in the defaults or not, if not social sharing needs to be Yes by default
     }
     */
    ///Set patrol mode radius
    if (![defaults objectForKey:kPatrolModeRadius]) {
        
        ///Set patrol mode radius to 50 by default
        [defaults setObject:@(PATROL_MODE_DEFAULT_RADIUS) forKey:kPatrolModeRadius];
        [defaults synchronize];
        
    }
#if VIDEO_STREAMING_ENABLED
    ///Set default resolution of video streaming if not set
    if (![defaults objectForKey:kVideoStreamingResolution]) {
        
        [defaults setObject:[C411AppDefaults getDefaultVideoResolution] forKey:kVideoStreamingResolution];
        [defaults synchronize];
    }
    
    ///Set default Server Url for User's Live youtube channel if not set
    if (![defaults objectForKey:kUserLiveYTChannelServerUrl]) {
        
        [defaults setObject:kUserLiveYTChannelDefaultServerUrl forKey:kUserLiveYTChannelServerUrl];
        [defaults synchronize];
    }

#endif

    ///Set patrol mode to on and new public cell alert notification to on if there is current user and its not set on parse
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        ///Get all the keys of user object
        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object,  NSError *error){
            
            if (!error && object) {
                
                PFUser *currentUserWithFullData = (PFUser *)object;
                NSNumber *newPublicCellCreationAlert = currentUserWithFullData[kUserNewPublicCellAlertKey];
                NSNumber *patrolMode = currentUserWithFullData[kUserPatrolModeKey];
                
                BOOL shouldUpdate = NO;
                BOOL isLocationUpdateRequired = NO;
#if PATROL_FEATURE_ENABLED
                
                if (!patrolMode) {
                    
                    ///This key has not been yet initialised on the parse, enable it by default and save the user object
                    currentUserWithFullData[kUserPatrolModeKey] = PATROL_MODE_VALUE_ON;
                    
                    shouldUpdate = YES;
                    
                }
                else if ([patrolMode boolValue]){
                    isLocationUpdateRequired = YES;
                }
#else
                if (patrolMode && [patrolMode boolValue]) {
                    
                    ///Patrol mode is some how enabled,let's disable it as this feature is not allowed
                    currentUserWithFullData[kUserPatrolModeKey] = PATROL_MODE_VALUE_OFF;
                    
                    shouldUpdate = YES;

                }
                
#endif
                if (!newPublicCellCreationAlert) {
                    
                    ///This key has not been yet initialised on the parse, enable it by default and save the user object
                    currentUserWithFullData[kUserNewPublicCellAlertKey] = NEW_PUBLIC_CELL_ALERT_VALUE_ON;
                    
                    shouldUpdate = YES;
                    
                }
                else if ([newPublicCellCreationAlert boolValue]){
                    isLocationUpdateRequired = YES;
                }
#if RIDE_HAILING_ENABLED
               
                NSNumber *rideRequestAlert = currentUserWithFullData[kUserRideRequestAlertKey];
                if (!rideRequestAlert) {
                    
                    ///This key has not been yet initialised on the parse, enable it by default and save the user object
                    currentUserWithFullData[kUserRideRequestAlertKey] = [NSNumber numberWithBool:YES];
                    
                    shouldUpdate = YES;
                    
                }
                else if ([rideRequestAlert boolValue]){
                    isLocationUpdateRequired = YES;
                }
                
#endif
                if(isLocationUpdateRequired && (![defaults boolForKey:kLocationUpdateOn])){
                    ///enable location update as well, as location update must be on if it's dependent features are on
                    [defaults setBool:YES forKey:kLocationUpdateOn];
                    
                    [defaults synchronize];
                }
                
                if (shouldUpdate) {
                    
                    [currentUserWithFullData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            ///Patrol mode set successfully
                            NSLog(@"Patrol mode updated successfully");
                            
                            ///enable location update as well, as location update must be on if it's dependent features are on
                            [defaults setBool:YES forKey:kLocationUpdateOn];
                            
                            [defaults synchronize];
                            
                        }
                        else{
                            ///some error occured initializing patrol mode
                            if (error) {
                                
                                if(![AppDelegate handleParseError:error]){
                                    
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    NSLog(@"error updating patrol mode %@",errorString);
                                }
                            }
                            
                        }
                        
                    }];

                }
                
            }
            else{
                ///some error occured fetching user object
                if (error) {
                    
                    if(![AppDelegate handleParseError:error]){
                
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"error fetching user object %@",errorString);
                        
                    }
                    
                }
                
            }
            
            
        }];
        
        ///Cache Friends and Private cells of current user in advance in app defaults singleton
        NSArray *arrFriends = [C411AppDefaults sharedAppDefaults].arrFriends;
        NSArray *arrCells = [C411AppDefaults sharedAppDefaults].arrCells;
        arrFriends = nil;
        arrCells = nil;
    }
    
    
    ///Set public cell visibility radius
    if (![defaults objectForKey:kPublicCellVisibilityRadius]) {
        
        ///Set public cell visibilty radius to default radius
        [defaults setObject:@(PUBLIC_CELL_VISIBILITY_DEFAULT_RADIUS) forKey:kPublicCellVisibilityRadius];
        [defaults synchronize];
        
    }
    
    ///Set metric system if not set
    if (![defaults objectForKey:kMetricSystem]) {
        ///set kms as default metric system
        [defaults setObject:kMetricSystemKms forKey:kMetricSystem];
        [defaults synchronize];
        
    }

    
    ///set the Include Security Guard Option to Yes if it's not set
    if (([C411AppDefaults canShowSecurityGuardOption])
        &&(![defaults objectForKey:kIncludeSecurityGuards])) {
        
        ///Set the include security guards option to YES by default
        [defaults setObject:@(YES) forKey:kIncludeSecurityGuards];
        [defaults synchronize];
        
    }
    
    
    ///set the Center user location to Yes by default if it's not set
    if (![defaults objectForKey:kCenterUserLocation]) {
        
        ///Set the Center user location option to YES by default
        [defaults setObject:@(YES) forKey:kCenterUserLocation];
        [defaults synchronize];
        
    }

#if NOTIFICATION_ACK_ENABLED
    
    if (currentUser) {
        
        [C411AlertHelper saveLoggedInUserId:currentUser.objectId];
        
    }
    
#endif

    
}

-(void)setCurrentUserOnInstallation
{
    ///Set user on Installation object
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    
    if (currentUser) {
        
        ///Save this user object for the installation object
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        currentInstallation[kInstallationUserKey] = currentUser;
        
        [currentInstallation saveEventually];
        
    }
    
}

-(void)processNotificationUserInfo:(NSDictionary *)dictUserInfo
{
    NSString *alertType = dictUserInfo[kPayloadAlertTypeKey];
    
    if (([alertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedy.lowercaseString])
        ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypeVideo.lowercaseString])
        ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypePhoto.lowercaseString])
        ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyForwarded.lowercaseString])
        ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyCell.lowercaseString])
        ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypePhotoCell.lowercaseString])) {
        
        ///A needy has issued an alert or streaming a video or shared a photo
        NSNumber *createdAt = dictUserInfo[kPayloadCreatedAtKey];
        BOOL isPhotoAlert = NO;
        if (([alertType.lowercaseString isEqualToString:kPayloadAlertTypePhoto.lowercaseString])
            ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypePhotoCell.lowercaseString])) {
            isPhotoAlert = YES;
        }
        
        if (isPhotoAlert || [self isAlertNotificationValid:createdAt]) {
            ///Show alert if its a photo alert or if its a valid needy/video/needyForwarded alert
            ///Get Cell411AlertId and save it in iVar to avoid duplicacy
            self.tappedNotificationAlertId = dictUserInfo[kPayloadCell411AlertIdKey];
            
            ///Check whether the issuer exist on the DB or not
            NSString *strFullName = dictUserInfo[kPayloadFirstNameKey];
            NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
            
            if ([C411StaticHelper validateUserUsingObjectId:strUserId]
                && [C411StaticHelper validateUserUsingFullName:strFullName]) {
            
                ///if this alert is forwarded by someone then check for Forwarded by user as well for it's existence
                BOOL canShowNotification = NO;
                if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeNeedyForwarded.lowercaseString]) {
                    
                    NSString *strForwardedByName = dictUserInfo[kPayloadForwardedByKey];
                    canShowNotification = [C411StaticHelper validateUserUsingFullName:strForwardedByName];
                    
                }
                else{
                    ///This is not a forwarded alert, so no need to check for forwardedBy person's existence
                    canShowNotification = YES;
                }
                
                if (canShowNotification) {
                    
                    ///Notification is valid, create a notification payload
                    C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
                    ///set common properties
                    alertNotificationPayload.strAlertType = alertType;
                    alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
                    alertNotificationPayload.createdAtInMillis = [createdAt doubleValue];
                    alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
                    ///Needy,PHOTO,VIDEO,NEEDY_FORWARDED or NEEDY_CELL properties
                    alertNotificationPayload.strAdditionalNote = dictUserInfo[kPayloadAdditionalNoteKey];
                    //NSString *strAlertRegarding = nil;
                    NSNumber *numAlertType = dictUserInfo[kPayloadAlertIdKey];
                    if(numAlertType){
                        AlertType alertType = (AlertType)[numAlertType integerValue];
                        alertNotificationPayload.strAlertRegarding = [C411StaticHelper getAlertTypeStringUsingAlertType:alertType];
                    }
                    else{
                        alertNotificationPayload.strAlertRegarding = dictUserInfo[kPayloadAlertRegardingKey];
                    }
                    alertNotificationPayload.strCell411AlertId = dictUserInfo[kPayloadCell411AlertIdKey];
                    alertNotificationPayload.strFullName = dictUserInfo[kPayloadFirstNameKey];
                    C411Address *alertAddress = [[C411Address alloc]init];
                    alertAddress.coordinate = CLLocationCoordinate2DMake([dictUserInfo[kPayloadLatKey]doubleValue], [dictUserInfo[kPayloadLonKey]doubleValue]);
                    alertAddress.strCity = dictUserInfo[kPayloadCityKey];
                    alertAddress.strCountry = dictUserInfo[kPayloadCountryKey];
                    alertAddress.strFullAddress = dictUserInfo[kPayloadFullAddressKey];
                    alertNotificationPayload.alertAddress = alertAddress;
                    alertNotificationPayload.isGlobalAlert = [dictUserInfo[kPayloadIsGlobalKey]intValue];
                    NSNumber *dispatchMode = dictUserInfo[kPayloadDispatchModeKey];
                    if (dispatchMode) {
                        
                        alertNotificationPayload.dispatchMode = [dispatchMode intValue];
                    }
                    alertNotificationPayload.strForwardedBy = dictUserInfo[kPayloadForwardedByKey];
                    alertNotificationPayload.strForwardingAlertId = dictUserInfo[kPayloadForwardingAlertIdKey];
                    alertNotificationPayload.strCellId = dictUserInfo[kPayloadCellIdKey];
                    alertNotificationPayload.strCellName = dictUserInfo[kPayloadCellNameKey];
                    
                    ///Set VIDEO specific properties and send notification
                    if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeVideo.lowercaseString]) {
                        ///Set status as Live as this is the notification generated when user in FG, it may be the case user has tapped a notification few hours later after streaming is stopped but we are considering it as LIVE for now.
                        alertNotificationPayload.strStatus = kAlertStatusLive;
                        
                        ///Post VIDEO Streaming notification
                        [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedVideoStreamingNotification object:alertNotificationPayload];
                    }
                    else if (isPhotoAlert){
                        
                        ///Set PHOTO specific properties and send notification
                        ///There is no specific property for PHOTO other than photoFile (photo column) which is not available through push notification and need to be fetched from parse
                        ///Send PHOTO notification
                        [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedPhotoAlertNotification object:alertNotificationPayload];
                    }
                    else{
                        
                        ///Post NEEDY or NEEDY_FORWARDED or NEEDY_CELL notification
                        [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertFromNeedyNotification object:alertNotificationPayload];
                    }

                    
                }
            
            }
            
            
            
        }
        
    }
    else if (([alertType.lowercaseString isEqualToString:kPayloadAlertTypeHelper.lowercaseString])
             ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypeRejector.lowercaseString])){
        
        ///A Helper has accepted to help you out or Rejector cannot help you out right now
        NSNumber *createdAt = dictUserInfo[kPayloadCreatedAtKey];
        if ([self isAlertNotificationValid:createdAt]) {
            
            
            ///Get AdditionalNoteId and save it in iVar to avoid duplicacy of additionalNote
            self.tappedNotifAdditionalNoteId = dictUserInfo[kPayloadAdditionalNoteIdKey];
            ///Check whether the issuer exist on the DB or not
            NSString *strFullName = dictUserInfo[kPayloadNameKey];
            NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
            
            if ([C411StaticHelper validateUserUsingObjectId:strUserId]
                && [C411StaticHelper validateUserUsingFullName:strFullName]) {
                
                ///Notification is valid, create a notification payload
                C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
                ///set common properties
                alertNotificationPayload.strAlertType = alertType;
                alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
                alertNotificationPayload.createdAtInMillis = [createdAt doubleValue];
                alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
                
                ///Helper Keys
                alertNotificationPayload.strDuration = dictUserInfo[kPayloadDurationKey];
                alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
                alertNotificationPayload.strUserType = dictUserInfo[kPayloadUserTypeKey];
                
                ///Responder (i.e Helper or Rejector) keys for Additonal Note
                alertNotificationPayload.strAdditionalNote = dictUserInfo[kPayloadAdditionalNoteKey];
                alertNotificationPayload.strAdditionalNoteId = dictUserInfo[kPayloadAdditionalNoteIdKey];
                
                ///ForwardedBy key
                alertNotificationPayload.strForwardedBy = dictUserInfo[kPayloadForwardedByKey];
                
                ///Post notification
                if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeHelper.lowercaseString]){
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertFromHelperNotification object:alertNotificationPayload];
                }
                else if([alertType.lowercaseString isEqualToString:kPayloadAlertTypeRejector.lowercaseString]){
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertFromRejectorNotification object:alertNotificationPayload];
                    
                }
                

            }

            
            
        }
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeFriendRequest.lowercaseString]){
        
        ///Some one wants your approval to add you in his/her friends list,create a notification payload
        ///Get Cell411AlertId and save it in iVar to avoid duplicacy
        self.tappedNotificationAlertId = dictUserInfo[kPayloadFRObjectIdKey];
        
        ///Check whether the issuer exist on the DB or not
        NSString *strFullName = dictUserInfo[kPayloadNameKey];
        NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
        
        if ([C411StaticHelper validateUserUsingObjectId:strUserId]
            && [C411StaticHelper validateUserUsingFullName:strFullName]) {
            
            C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
            ///set common properties
            alertNotificationPayload.strAlertType = alertType;
            alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
            alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
            
            ///FRIEND_REQUEST Keys
            alertNotificationPayload.strCell411AlertId = dictUserInfo[kPayloadFRObjectIdKey];
            alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
            
            ///Post notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertForFriendRequestNotification object:alertNotificationPayload];
            

        }
        
        
        
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeFriendApproved.lowercaseString]){
        
        ///Your friend request has been approved
        ///Get TaskId and save it in iVar to avoid duplicacy
        self.tappedNotificationAlertId = dictUserInfo[kPayloadTaskIdKey];
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        ///set common properties
        alertNotificationPayload.strAlertType = alertType;
        alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
        alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
        if (alertNotificationPayload.strUserId.length == 0) {
            
            ///The FRIEND_APPROVED alert may have been sent from the android user using version earlier than 2.1. Check for assigneeUserId key as well
            alertNotificationPayload.strUserId = dictUserInfo[@"assigneeUserId"];
        }
        ///FRIEND_APPROVED Keys
        alertNotificationPayload.strTaskId = dictUserInfo[kPayloadTaskIdKey];
        alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
        
        ///Post notification
        [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertForFriendApprovedNotification object:alertNotificationPayload];
        
        ///Note: No need to check whether the request is recieved from valid user or not as it's already handled by the Notification Observer
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeSafe.lowercaseString]){
        
        ///This is All OK alert, just show the alert message for now
        NSString *notificationMessage = [[dictUserInfo objectForKey:@"aps"]objectForKey:@"alert"];
        [C411StaticHelper showAlertWithTitle:nil message:notificationMessage onViewController:self.window.rootViewController];
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeCellRequest.lowercaseString]){
        
        ///Some one wants to join the public cell created by you,create a notification payload
        ///Get cellRequestObjectId and save it in iVar to avoid duplicacy
        self.tappedNotificationAlertId = dictUserInfo[kPayloadCellRequestObjectIdKey];
        
        ///Check whether the issuer exist on the DB or not
        NSString *strFullName = dictUserInfo[kPayloadNameKey];
        NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
        
        if ([C411StaticHelper validateUserUsingObjectId:strUserId]
            && [C411StaticHelper validateUserUsingFullName:strFullName]) {
            
            C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
            ///set common properties
            alertNotificationPayload.strAlertType = alertType;
            alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
            alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
            alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
            ///CELL_REQUEST Keys
            alertNotificationPayload.strCellRequestObjectId = dictUserInfo[kPayloadCellRequestObjectIdKey];
            alertNotificationPayload.strCellId = dictUserInfo[kPayloadCellIdKey];
            alertNotificationPayload.strCellName = dictUserInfo[kPayloadCellNameKey];
            
            ///Post notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertToJoinPublicCellNotification object:alertNotificationPayload];

        }
        
        
        
    }
    else if (([alertType.lowercaseString isEqualToString:kPayloadAlertTypeCellApproved.lowercaseString])
             ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypeCellDenied.lowercaseString])){
        
        ///This is a Cell Approved or Denied alert
        NSString *notificationMessage = [[dictUserInfo objectForKey:@"aps"]objectForKey:@"alert"];
        [C411StaticHelper showAlertWithTitle:nil message:notificationMessage onViewController:self.window.rootViewController];
        
        ///Post notification
        [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshPublicCellListingNotification object:nil];

        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeNewPublicCell.lowercaseString]){
        
        ///A new public cell has been created within 50 miles, show this info to user and ask if he wants to join it
        
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        ///set common properties
        alertNotificationPayload.strAlertType = alertType;
        alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
        alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
        alertNotificationPayload.strCellId = dictUserInfo[kPayloadCellIdKey];
        alertNotificationPayload.strCellName = dictUserInfo[kPayloadCellNameKey];
        
        ///Post notification
        [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertForNewPublicCellCreatedNotification object:alertNotificationPayload];
        
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeRideRequest.lowercaseString]){
        
        ///A ride request has been initiated by someone nearby as current user has enabled to receive ride requests, show this request to current user if it's not expired and ask whether he is interested or not
        NSNumber *createdAt = dictUserInfo[kPayloadCreatedAtKey];
        ///Show alert if its a valid Ride request
        ///Get rideRequestId and save it in iVar to avoid duplicacy
            self.tappedRideRequestId = dictUserInfo[kPayloadRideRequestIdKey];
            
            ///Check whether the issuer exist on the DB or not
            NSString *strFullName = dictUserInfo[kPayloadNameKey];
            NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
            
            if ([C411StaticHelper validateUserUsingObjectId:strUserId]
                && [C411StaticHelper validateUserUsingFullName:strFullName]) {
                
                ///Notification is valid, create a notification payload
                C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
                ///set common properties
                alertNotificationPayload.strAlertType = alertType;
                alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
                alertNotificationPayload.createdAtInMillis = [createdAt doubleValue];
                alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
                ///Ride request properties
                alertNotificationPayload.strAdditionalNote = dictUserInfo[kPayloadAdditionalNoteKey];
                alertNotificationPayload.strRideRequestId = dictUserInfo[kPayloadRideRequestIdKey];
                alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
                alertNotificationPayload.pickUpLat = [dictUserInfo[kPayloadPickUpLatKey]doubleValue];
                alertNotificationPayload.pickUpLon = [dictUserInfo[kPayloadPickUpLongKey]doubleValue];
                alertNotificationPayload.dropLat = [dictUserInfo[kPayloadDropLatKey]doubleValue];
                alertNotificationPayload.dropLon = [dictUserInfo[kPayloadDropLongKey]doubleValue];
                ///Post RIDE_REQUEST notification
                [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideRequestNotification object:alertNotificationPayload];
                
                
            }
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeRideInterested.lowercaseString]){
        
        ///Some driver has offered the ride to current user(rider)
        
        NSNumber *createdAt = dictUserInfo[kPayloadCreatedAtKey];
        ///Show alert for the ride response and let the rider take selection decision
        ///Get rideResponseId and save it in iVar to avoid duplicacy
        self.tappedRideResponseId = dictUserInfo[kPayloadRideResponseIdKey];
        
        ///Check whether the issuer exist on the DB or not
        NSString *strFullName = dictUserInfo[kPayloadNameKey];
        NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
        
        if ([C411StaticHelper validateUserUsingObjectId:strUserId]
            && [C411StaticHelper validateUserUsingFullName:strFullName]) {
            
            ///Notification is valid, create a notification payload
            C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
            ///set common properties
            alertNotificationPayload.strAlertType = alertType;
            alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
            alertNotificationPayload.createdAtInMillis = [createdAt doubleValue];
            alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
            ///Ride request properties
            alertNotificationPayload.strAdditionalNote = dictUserInfo[kPayloadAdditionalNoteKey];
            alertNotificationPayload.strRideRequestId = dictUserInfo[kPayloadRideRequestIdKey];
            alertNotificationPayload.strRideResponseId = dictUserInfo[kPayloadRideResponseIdKey];
            alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
            alertNotificationPayload.pickUpLat = [dictUserInfo[kPayloadPickUpLatKey]doubleValue];
            alertNotificationPayload.pickUpLon = [dictUserInfo[kPayloadPickUpLongKey]doubleValue];
            alertNotificationPayload.dropLat = [dictUserInfo[kPayloadDropLatKey]doubleValue];
            alertNotificationPayload.dropLon = [dictUserInfo[kPayloadDropLongKey]doubleValue];
            alertNotificationPayload.strCost = dictUserInfo[kPayloadCostKey];
            
            ///Post RIDE_INTERESTED notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideInterestedNotification object:alertNotificationPayload];
            
            
        }
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeRideConfirmed.lowercaseString]){
        
        ///Rider has confirmed your ride offer
        
        NSNumber *createdAt = dictUserInfo[kPayloadCreatedAtKey];
        ///Show alert for the ride confirmed
        ///Get RideResponse Id and save it in iVar to avoid duplicacy
        self.tappedRideResponseFromRiderId = dictUserInfo[kPayloadRideResponseIdKey];
        
        ///Check whether the issuer exist on the DB or not
        NSString *strFullName = dictUserInfo[kPayloadNameKey];
        NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
        
        if ([C411StaticHelper validateUserUsingObjectId:strUserId]
            && [C411StaticHelper validateUserUsingFullName:strFullName]) {
            
            ///Notification is valid, create a notification payload
            C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
            ///set common properties
            alertNotificationPayload.strAlertType = alertType;
            alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
            alertNotificationPayload.createdAtInMillis = [createdAt doubleValue];
            alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
            ///Ride confirmed properties
            alertNotificationPayload.strAdditionalNote = dictUserInfo[kPayloadAdditionalNoteKey];
            alertNotificationPayload.strRideResponseId = dictUserInfo[kPayloadRideResponseIdKey];
            alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
            alertNotificationPayload.pickUpLat = [dictUserInfo[kPayloadPickUpLatKey]doubleValue];
            alertNotificationPayload.pickUpLon = [dictUserInfo[kPayloadPickUpLongKey]doubleValue];
            alertNotificationPayload.dropLat = [dictUserInfo[kPayloadDropLatKey]doubleValue];
            alertNotificationPayload.dropLon = [dictUserInfo[kPayloadDropLongKey]doubleValue];
            
            ///Post RIDE_CONFIRMED notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideConfirmedNotification object:alertNotificationPayload];
            
            
        }
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeRideRejected.lowercaseString]){
        
        ///Rider has rejected your ride offer
        
        NSNumber *createdAt = dictUserInfo[kPayloadCreatedAtKey];
        ///Show alert for the ride rejected
        ///Get RideResponse Id and save it in iVar to avoid duplicacy
        self.tappedRideResponseFromRiderId = dictUserInfo[kPayloadRideResponseIdKey];
        
        ///Check whether the issuer exist on the DB or not
        NSString *strFullName = dictUserInfo[kPayloadNameKey];
        NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
        
        if ([C411StaticHelper validateUserUsingObjectId:strUserId]
            && [C411StaticHelper validateUserUsingFullName:strFullName]) {
            
            ///Notification is valid, create a notification payload
            C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
            ///set common properties
            alertNotificationPayload.strAlertType = alertType;
            alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
            alertNotificationPayload.createdAtInMillis = [createdAt doubleValue];
            alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
            ///Ride rejected properties
            alertNotificationPayload.strAdditionalNote = dictUserInfo[kPayloadAdditionalNoteKey];
            alertNotificationPayload.strRideResponseId = dictUserInfo[kPayloadRideResponseIdKey];
            alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
            
            ///Post RIDE_REJECTED notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideRejectedNotification object:alertNotificationPayload];
            
            
        }
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeRideSelected.lowercaseString]){
        
        ///Rider has selected someone else ride offer instead of yours
        
        NSNumber *createdAt = dictUserInfo[kPayloadCreatedAtKey];
        ///Show alert for the ride selected
        ///Check whether the issuer exist on the DB or not
        NSString *strFullName = dictUserInfo[kPayloadNameKey];
        NSString *strUserId = dictUserInfo[kPayloadUserIdKey];
        
        if ([C411StaticHelper validateUserUsingObjectId:strUserId]
            && [C411StaticHelper validateUserUsingFullName:strFullName]) {
            
            ///Notification is valid, create a notification payload
            C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
            ///set common properties
            alertNotificationPayload.strAlertType = alertType;
            alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
            alertNotificationPayload.createdAtInMillis = [createdAt doubleValue];
            alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
            alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
            
            ///Post RIDE_SELECTED notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideSelectedNotification object:alertNotificationPayload];
            
            
        }
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeMessage.lowercaseString]){
    
        ///Ignore the processing of this notification for now as it's only a local notification for chat message
        
        if([AppDelegate getLoggedInUser]){
#if CHAT_ENABLED
            UINavigationController *rootNavC = self.window.rootViewController;
            UIViewController *rootVC = [rootNavC.viewControllers firstObject];
            rootVC.tabBarController.selectedIndex = 4;
            
            UIViewController *visibleVC = [rootNavC.viewControllers lastObject];
            if ([visibleVC isKindOfClass:[C411ChatVC class]]) {
                
                C411ChatVC *visibleChatVC = (C411ChatVC *)visibleVC;
                if (![visibleChatVC.strEntityId isEqualToString:dictUserInfo[kPayloadChatEntityObjectIdKey]]) {
                    
                    ///Show the Chat VC
                    C411ChatVC *chatVC = [visibleVC.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
                    chatVC.entityType = [C411ChatHelper getChatEntityTypeFromString:dictUserInfo[kPayloadChatEntityTypeKey]];
                    chatVC.strEntityId = dictUserInfo[kPayloadChatEntityObjectIdKey];
                    chatVC.strEntityName = dictUserInfo[kPayloadChatEntityNameKey];
                    chatVC.entityCreatedAtInMillis = [dictUserInfo[kPayloadChatEntityCreatedAtKey]doubleValue];
                    [rootNavC pushViewController:chatVC animated:YES];

                }
                
            }
            else{
                
                ///Show the chat VC
                C411ChatVC *chatVC = [visibleVC.storyboard instantiateViewControllerWithIdentifier:@"C411ChatVC"];
                chatVC.entityType = [C411ChatHelper getChatEntityTypeFromString:dictUserInfo[kPayloadChatEntityTypeKey]];
                chatVC.strEntityId = dictUserInfo[kPayloadChatEntityObjectIdKey];
                chatVC.strEntityName = dictUserInfo[kPayloadChatEntityNameKey];
                chatVC.entityCreatedAtInMillis = [dictUserInfo[kPayloadChatEntityCreatedAtKey]doubleValue];
                [rootNavC pushViewController:chatVC animated:YES];
            }
#endif
            
        }
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeCellRemoved.lowercaseString]
             ||[alertType.lowercaseString isEqualToString:kPayloadAlertTypeCellDeleted.lowercaseString]){
    
        ///Create a notification payload
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        ///set common properties
        alertNotificationPayload.strAlertType = alertType;
        alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
        alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
        alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
        alertNotificationPayload.strCellId = dictUserInfo[kPayloadCellIdKey];
        alertNotificationPayload.strCellName = dictUserInfo[kPayloadCellNameKey];

        
        ///Post User removed from cell notification
        [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertForUserRemovedFromCellNotification object:alertNotificationPayload];

    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeCellChanged.lowercaseString]){
        
        ///This is a Cell Changed alert
        NSString *notificationMessage = [[dictUserInfo objectForKey:@"aps"]objectForKey:@"alert"];
        [C411StaticHelper showAlertWithTitle:nil message:notificationMessage onViewController:self.window.rootViewController];
        
        ///Post notification
        [[NSNotificationCenter defaultCenter]postNotificationName:kRefreshPublicCellListingNotification object:nil];
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeUserJoined.lowercaseString]){
        
        ///This a user joined notification received beacuse I have synced my contact and someone from my contact has signed up with the app
        ///Create a notification payload
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        ///set common properties
        alertNotificationPayload.strAlertType = alertType;
        alertNotificationPayload.strAlert = dictUserInfo[@"aps"][kPayloadAlertKey];
        alertNotificationPayload.strUserId = dictUserInfo[kPayloadUserIdKey];
        alertNotificationPayload.strFullName = dictUserInfo[kPayloadNameKey];
        alertNotificationPayload.strUsername = dictUserInfo[kPayloadUsernameKey];
        
        
        
        ///Post User joined notification
        [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedUserJoinedNotification object:alertNotificationPayload];

        
    }
    else if (([alertType.lowercaseString isEqualToString:kPayloadAlertTypeCellVerified.lowercaseString])
             ||([alertType.lowercaseString isEqualToString:kPayloadAlertTypeCellRejected.lowercaseString])){
        
        ///This is a Cell Verified or Cell Rejected alert for the verification request being sent by the owner of the cell
        NSString *notificationMessage = [[dictUserInfo objectForKey:@"aps"]objectForKey:@"alert"];
        [C411StaticHelper showAlertWithTitle:nil message:notificationMessage onViewController:self.window.rootViewController];
        
        ///TODO: Post notification to update UI as well.
        
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeBackground.lowercaseString]){
        ///Handle tasks need to be done in Background
        
    }
    else if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeCustom.lowercaseString]){
        
        ///This is a CUSTOM alert sent through Parse Push Console to display informational message
        NSString *notificationMessage = [[dictUserInfo objectForKey:@"aps"]objectForKey:@"alert"];
        [C411StaticHelper showAlertWithTitle:nil message:notificationMessage onViewController:self.window.rootViewController];
        
    }
    else{
        
        ///This is some other alert which the app doesn't recognize might be due to version incompatibilty. Show the alert to user to download the new version.
        [self showOldAppVersionDialog];
        
    }
}

-(BOOL)isAlertNotificationValid:(NSNumber *)createdAtInMillis
{
    if (createdAtInMillis) {
        
        double currentTimeInMillis = [[NSDate date]timeIntervalSince1970] * 1000;///Multiply by 1000 to convert it from second to millisecond
        
        double timeElaplsedInMillis = currentTimeInMillis - [createdAtInMillis doubleValue];
        
        if (timeElaplsedInMillis <= ((TIME_TO_LIVE)*1000.0)) {
            
            ///Notification is valid
            return YES;
            
        }
        
    }
    
    return NO;
}

//-(BOOL)isRideRequestValid:(NSNumber *)createdAtInMillis
//{
//    if (createdAtInMillis) {
//        
//        double currentTimeInMillis = [[NSDate date]timeIntervalSince1970] * 1000;///Multiply by 1000 to convert it from second to millisecond
//        
//        double timeElaplsedInMillis = currentTimeInMillis - [createdAtInMillis doubleValue];
//        
//        if (timeElaplsedInMillis <= ((TIME_TO_LIVE_FOR_RIDE_REQ)*1000.0)) {
//            
//            ///Notification is valid
//            return YES;
//            
//        }
//        
//    }
//    
//    return NO;
//}



///It will fetch the alerts in one call to parse.Fetch Helper is yet to be done as there are various use cases needs to be handled
-(void)fetchAlerts
{
    ///Make a query on Cell411Alert table to fetch all alerts which contain
    ///1.current user as target members and has not been initated and rejected by this user for needy alerts, also the issuerId notEqualTo any objectId of the members in spammedBy relation of current User(to avoid displaying same alert multiple time from the user who has spammed current user), also the status is notEqualTo ALL_OK, also the alertType is not equal to Photo,  and filter the records where createdAt key is within TIME_TO_LIVE,
    ///2.or the alertType is equal to Photo, also current user as target members and has not been initated and rejected by this user for photo alerts, also the issuerId notEqualTo any objectId of the members in spammedBy relation of current User(to avoid displaying same alert multiple time from the user who has spammed current user)
    
    ///3.or the members with issuerId as current user and having atleast one object in initiatedBy relation for helper and filter the records where createdAt key is within TIME_TO_LIVE.
    ///4.or where to contains current user's username and entryFor is FR/FI and status is PENDING For FREIND_REQUEST ,
    ///5.Create composite query
    ///6. Set limit to max limit
    ///7.finally sort it with the most recent one first
    ///8.Create another query for Fetching FRIEND_APPROVED alerts, where userId is current user, task is FRIEND_ADD and status is PENDING
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];

    if (currentUser) {
        ///If user is logged in then only try to fetch from parse
        NSDate *minDate = [[NSDate date]dateByAddingTimeInterval:(-1) * TIME_TO_LIVE];
        
        
        ///1.1Query to fetch Needy and video except photo
        PFQuery *fetchNeedyAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchNeedyAlertsQuery whereKey:kCell411AlertStatusKey  notEqualTo:kAlertStatusAllOk];
        [fetchNeedyAlertsQuery whereKey:kCell411AlertAlertTypeKey notEqualTo:kAlertTypePhoto];
        [fetchNeedyAlertsQuery whereKey:kCell411AlertTargetMembersKey containsAllObjectsInArray:[NSArray arrayWithObject:currentUser]];
        [fetchNeedyAlertsQuery whereKey:kCell411AlertInitiatedByKey notEqualTo:currentUser];
        [fetchNeedyAlertsQuery whereKey:kCell411AlertRejectedByKey notEqualTo:currentUser];
        [fetchNeedyAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
        ///create a subquery which will give the current user's spammedBy relation members, (in order to optimise we only retrieve one custom field hence we'll get only one custom field and other default fileds including objectId)
        PFRelation *spammedByRelation = [currentUser relationForKey:kUserSpammedByKey];
        PFQuery *spammedByUsersSubQuery = [spammedByRelation query];
        ///optimize query to return only firstname as we need only objectId of User table
        [spammedByUsersSubQuery selectKeys:@[kUserFirstnameKey]];
        ///Add the sub query created above to filter the needy alerts to be fetched which are issued by someone who has spammed current user. This way it will not fecth same alert always.
        [fetchNeedyAlertsQuery whereKey:kCell411AlertIssuedByKey doesNotMatchKey:@"objectId" inQuery:spammedByUsersSubQuery];
        
        ///1.2Query to fetch NEEDY_CELL alerts issued on Public Cell except photo
        PFQuery *fetchNeedyPublicAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchNeedyPublicAlertsQuery whereKey:kCell411AlertStatusKey  notEqualTo:kAlertStatusAllOk];
        [fetchNeedyPublicAlertsQuery whereKey:kCell411AlertAlertTypeKey notEqualTo:kAlertTypePhoto];
        [fetchNeedyPublicAlertsQuery whereKey:kCell411AlertCellMembersKey equalTo:currentUser];
        [fetchNeedyPublicAlertsQuery whereKey:kCell411AlertInitiatedByKey notEqualTo:currentUser];
        [fetchNeedyPublicAlertsQuery whereKey:kCell411AlertRejectedByKey notEqualTo:currentUser];
        [fetchNeedyPublicAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
        ///Add the sub query created above to filter the needy alerts to be fetched which are issued by someone who has spammed current user. This way it will not fecth same alert always.
        [fetchNeedyPublicAlertsQuery whereKey:kCell411AlertIssuedByKey doesNotMatchKey:@"objectId" inQuery:spammedByUsersSubQuery];
        
        
        ///TODO:2 Create helper query to fetch helpers along with needers in one call
        
        ///2.1 Create a query to fetch new photo alerts without any time limit
        PFQuery *fetchPhotoAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchPhotoAlertsQuery whereKey:kCell411AlertAlertTypeKey equalTo:kAlertTypePhoto];
        [fetchPhotoAlertsQuery whereKey:kCell411AlertTargetMembersKey containsAllObjectsInArray:[NSArray arrayWithObject:currentUser]];
        [fetchPhotoAlertsQuery whereKey:kCell411AlertInitiatedByKey notEqualTo:currentUser];
        [fetchPhotoAlertsQuery whereKey:kCell411AlertRejectedByKey notEqualTo:currentUser];
        ///Add the sub query created above to filter out the photo alerts to be fetched which are issued by someone who has spammed current user. This way it will not fecth same alert always.
        [fetchPhotoAlertsQuery whereKey:kCell411AlertIssuedByKey doesNotMatchKey:@"objectId" inQuery:spammedByUsersSubQuery];
        
        ///2.2 Create a query to fetch new photo public alerts without any time limit
        PFQuery *fetchPhotoPubicAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchPhotoPubicAlertsQuery whereKey:kCell411AlertAlertTypeKey equalTo:kAlertTypePhoto];
        [fetchPhotoPubicAlertsQuery whereKey:kCell411AlertCellMembersKey equalTo:currentUser];
        [fetchPhotoPubicAlertsQuery whereKey:kCell411AlertInitiatedByKey notEqualTo:currentUser];
        [fetchPhotoPubicAlertsQuery whereKey:kCell411AlertRejectedByKey notEqualTo:currentUser];
        ///Add the sub query created above to filter out the photo alerts to be fetched which are issued by someone who has spammed current user. This way it will not fecth same alert always.
        [fetchPhotoPubicAlertsQuery whereKey:kCell411AlertIssuedByKey doesNotMatchKey:@"objectId" inQuery:spammedByUsersSubQuery];
        
        ///3.Create a query to fetch all Cell411Alerts issued by current user within 24 hours, but not a forwarded alert nor a public alert
        ///TODO: Verify whether fetchCurrUserIssuedAlertsQuery is required or not, if not required then remove it
        NSDate *dateWith24HrLimit = [[NSDate date]dateByAddingTimeInterval:(-1) * (24*60*60)];
        PFQuery *fetchCurrUserIssuedAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchCurrUserIssuedAlertsQuery whereKey:kCell411AlertIssuerIdKey equalTo:currentUser.objectId];
        [fetchCurrUserIssuedAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:dateWith24HrLimit];
        [fetchCurrUserIssuedAlertsQuery whereKeyDoesNotExist:kCell411AlertForwardedByKey];
        [fetchCurrUserIssuedAlertsQuery whereKeyDoesNotExist:kCell411AlertCellNameKey];
        
        ///4. Create a query to fetch new implementation of alerts which can be sent to multiple audiences
        PFQuery *fetchMultipleAudienceAlertsQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchMultipleAudienceAlertsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
        [fetchMultipleAudienceAlertsQuery whereKeyExists:kCell411AlertAlertIdKey];
        [fetchMultipleAudienceAlertsQuery whereKeyDoesNotExist:kCell411AlertForwardedAlertKey];
        [fetchMultipleAudienceAlertsQuery whereKey:kCell411AlertStatusKey  notEqualTo:kAlertStatusAllOk];
        [fetchMultipleAudienceAlertsQuery whereKey:kCell411AlertAudienceAUKey equalTo:currentUser];
        [fetchMultipleAudienceAlertsQuery whereKey:kCell411AlertSeenByKey notEqualTo:currentUser];
        [fetchMultipleAudienceAlertsQuery whereKey:kCell411AlertIssuedByKey doesNotMatchKey:@"objectId" inQuery:spammedByUsersSubQuery];

        
        ///4.Create a query to fetch FRIEND_REQUEST/FRIEND_INVITE/CELL_REQUEST alerts
        ///for email users
        PFQuery *fetchFriendReqQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
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
        [fetchFriendReqQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite,kEntryForCellRequest]];
        [fetchFriendReqQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
        [fetchFriendReqQuery whereKey:kCell411AlertSeenByKey notEqualTo:currentUser];
        NSMutableArray *arrSubQueries = [NSMutableArray array];

        if ([C411StaticHelper getSignUpTypeOfUser:currentUser] == SignUpTypeFacebook) {
            
            ///Create a query to fetch FRIEND_REQUEST/FRIEND_INVITE/CELL_REQUEST alerts for Facebook users
            
            ///1. update query to retrieve friend request, friend invite and cell request using username(without lowercase string)
            ///clear reference of first query
            fetchFriendReqQuery = nil;
            

            fetchFriendReqQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [fetchFriendReqQuery whereKey:kCell411AlertToKey equalTo:currentUser.username];
            [fetchFriendReqQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite,kEntryForCellRequest]];
            [fetchFriendReqQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
            [fetchFriendReqQuery whereKey:kCell411AlertSeenByKey notEqualTo:currentUser];
            
            ///make sub queries if facebook user has email to check for email also
            NSString *strCurrentUserEmail = [C411StaticHelper getEmailFromUser:currentUser];
            strCurrentUserEmail = [strCurrentUserEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (strCurrentUserEmail.length > 0) {
                
                ///1. get reference of first query
                PFQuery *fetchFriendReqOrCellReqWithUsernameSubQuery = fetchFriendReqQuery;
                ///clear fetchFriendReqQuery
                fetchFriendReqQuery = nil;
                
                ///2. Make another sub query to look for current user email as well, as user email is entered while sending friend request or friend invite from Invite Contacts screen. NOTE: No need to look for Cell request here as it will always be send to username

                PFQuery *fetchFriendReqWithEmailSubQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
                [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertToKey equalTo:strCurrentUserEmail.lowercaseString];
                [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendRequest,kEntryForFriendInvite]];
                [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
                [fetchFriendReqWithEmailSubQuery whereKey:kCell411AlertSeenByKey notEqualTo:currentUser];
                
                ///or query with sub queries
                //fetchFriendReqQuery = [PFQuery orQueryWithSubqueries:@[fetchFriendReqOrCellReqWithUsernameSubQuery,fetchFriendReqWithEmailSubQuery]];
                ///Add queries to subqueries
                [arrSubQueries addObject:fetchFriendReqOrCellReqWithUsernameSubQuery];
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
            [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertSeenByKey notEqualTo:currentUser];

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

        
        ///5. Create a composite query
        PFQuery *fetchAlertsQuery = [PFQuery orQueryWithSubqueries:@[fetchMultipleAudienceAlertsQuery,fetchNeedyAlertsQuery,fetchNeedyPublicAlertsQuery,fetchPhotoAlertsQuery,fetchPhotoPubicAlertsQuery,fetchCurrUserIssuedAlertsQuery,fetchFriendReqQuery]];
        
        if (self.tappedNotificationAlertId.length > 0) {
            
            ///Add query to remove alert with id which has been tapped to open the app, as it has been already displayed
            [fetchAlertsQuery whereKey:@"objectId" notEqualTo:self.tappedNotificationAlertId];
            
            
        }
        
        
        ///6.Set max limit
        fetchAlertsQuery.limit = 1000;
        
        ///7.finally sort it with the most recent one first, this should not be removed else the OK status being checked will not work
        [fetchAlertsQuery orderByDescending:@"createdAt"];
        
        ///Include the issuedBy person object as well
        [fetchAlertsQuery includeKey:kCell411AlertIssuedByKey];

        
        __weak typeof(self) weakSelf = self;
        ///fetch the list of alerts from Cell411Alerts table
        [fetchAlertsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                if (objects.count > 0) {
                    ///filter the objects to remove invalid alerts
                    NSArray *arrFilteredAlerts = [C411StaticHelper alertsArrayByRemovingInvalidObjectsFromArray:objects isForwardedAlert:NO];
                    [weakSelf processC411AlertObjects:arrFilteredAlerts];
                    
                }
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
            
            
            
        }];
        
        ///8.Create another query for Fetching task to be performed by current user i.e for showing FRIEND_APPROVED alerts associated to FRIEND_ADD task or updating SpammedBy relation associated to SPAM_ADD task, whose status is still PENDING
        
        //So Create a query where userId is current user, task is FRIEND_ADD or SPAM_ADD and status is PENDING
        PFQuery *pendingTaskQuery = [PFQuery queryWithClassName:kTaskClassNameKey];
        [pendingTaskQuery whereKey:kTaskUserIdKey equalTo:currentUser.objectId];
        [pendingTaskQuery whereKey:kTaskTaskKey containedIn:@[kTaskFriendAdd,kTaskSpamAdd,kTaskSpamRemove]];
        [pendingTaskQuery whereKey:kTaskStatusKey equalTo:kTaskStatusPending];
        pendingTaskQuery.limit = 1000;
        [pendingTaskQuery orderByDescending:@"createdAt"];
        ///fetch the list of Tasks from Task table correspoding to Friend_Approved alert or SpammedBy someone
        [pendingTaskQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                if (objects.count > 0) {
                    
                    [weakSelf processPendingTaskObjects:objects];
                    
                }
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
            
            
            
        }];
        
        ///9.Create another query for Fetching Additional Notes being sent to the needy alerts generated by current user,using query on AdditionalNote Table such as where seen equalTo 0 and cell411AlertId matchesKey ObjectId of the result set returned from the subquery on Cell411Alert table which is, the members with issuerId as current user filtered by the records where createdAt key is within TIME_TO_LIVE.
        ///9.1 Create a subquery from Cell411Alert table
        PFQuery *fetchResponderAlertsSubQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchResponderAlertsSubQuery whereKey:kCell411AlertIssuerIdKey equalTo:currentUser.objectId];
        [fetchResponderAlertsSubQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
        ///optimize query to return only issuerId as we need only objectId of Cell411Alert table
        [fetchResponderAlertsSubQuery selectKeys:@[kCell411AlertIssuerIdKey]];
        
        ///9.2.Create a query to fetch unseen AdditionalNotes designated for current user
        PFQuery *fetchAdditionalNotesQuery = [PFQuery queryWithClassName:kAdditionalNoteClassNameKey];
        [fetchAdditionalNotesQuery whereKey:kAdditionalNoteSeenKey equalTo:@(0)];
        [fetchAdditionalNotesQuery whereKey:kAdditionalNoteCell411AlertIdKey matchesKey:@"objectId" inQuery:fetchResponderAlertsSubQuery];
        if (self.tappedNotifAdditionalNoteId.length > 0) {
            
            ///Add query to remove additionalNote with id which has been tapped to open the app, as it has been already displayed
            [fetchAdditionalNotesQuery whereKey:@"objectId" notEqualTo:self.tappedNotifAdditionalNoteId];
            
            
        }
        
        
        ///9.3.Set max limit
        fetchAdditionalNotesQuery.limit = 1000;
        
        ///fetch the additionalNotes from responder matching the fetchAdditionalNotesQuery from AdditonalNote Table
        [fetchAdditionalNotesQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                if (objects.count > 0) {
                    
                    [weakSelf processNeedyResponderAdditionalNoteObjects:objects];
                    
                }
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
            
            
            
        }];
        
        
        ///10.Create another Query to fetch NEEDY_FORWARDED except photo and video as video and photo alerts will not be forwarded
        PFQuery *fetchNeedyForwardedAlertsMultipleAudienceQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchNeedyForwardedAlertsMultipleAudienceQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
        [fetchNeedyForwardedAlertsMultipleAudienceQuery whereKeyExists:kCell411AlertForwardedAlertKey];
        [fetchNeedyForwardedAlertsMultipleAudienceQuery whereKeyExists:kCell411AlertAlertIdKey];
        [fetchNeedyForwardedAlertsMultipleAudienceQuery whereKey:kCell411AlertAudienceAUKey equalTo:currentUser];
        [fetchNeedyForwardedAlertsMultipleAudienceQuery whereKey:kCell411AlertSeenByKey notEqualTo:currentUser];
        [fetchNeedyForwardedAlertsMultipleAudienceQuery whereKey:kCell411AlertAlertIdKey notEqualTo:@(AlertTypePhoto)];
        [fetchNeedyForwardedAlertsMultipleAudienceQuery whereKey:kCell411AlertAlertIdKey notEqualTo:@(AlertTypeVideo)];
        
        PFQuery *fetchNeedyForwardedAlertsSingleAudienceQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
        [fetchNeedyForwardedAlertsSingleAudienceQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
        [fetchNeedyForwardedAlertsSingleAudienceQuery whereKeyExists:kCell411AlertForwardedAlertKey];
        [fetchNeedyForwardedAlertsSingleAudienceQuery whereKey:kCell411AlertAlertTypeKey notEqualTo:kAlertTypePhoto];
        [fetchNeedyForwardedAlertsSingleAudienceQuery whereKey:kCell411AlertAlertTypeKey notEqualTo:kAlertTypeVideo];
        [fetchNeedyForwardedAlertsSingleAudienceQuery whereKey:kCell411AlertForwardedToMembersKey containsAllObjectsInArray:[NSArray arrayWithObject:currentUser]];
        
        PFQuery *fetchNeedyForwardedAlertsQuery = [PFQuery orQueryWithSubqueries:@[fetchNeedyForwardedAlertsMultipleAudienceQuery, fetchNeedyForwardedAlertsSingleAudienceQuery]];
        
        ///10.2.Set max limit
        fetchNeedyForwardedAlertsQuery.limit = 1000;
        
        ///10.3.finally sort it with the most recent one first
        [fetchNeedyForwardedAlertsQuery orderByDescending:@"createdAt"];
        
        ///10.4 Include the keys in the forwardedAlert
        [fetchNeedyForwardedAlertsQuery includeKey:kCell411AlertForwardedAlertKey];
        [fetchNeedyForwardedAlertsQuery includeKey:kCell411AlertForwardedByKey];
        
        ///Include the issuedBy person object
        [fetchNeedyForwardedAlertsQuery includeKey:kCell411AlertIssuedByKey];

        ///10.5 Fetch the NEEDY_FORWARDED data
        [fetchNeedyForwardedAlertsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                if (objects.count > 0) {
                    
                    ///filter the objects to remove invalid alerts
                    NSArray *arrFilteredAlerts = [C411StaticHelper alertsArrayByRemovingInvalidObjectsFromArray:objects isForwardedAlert:YES];
                    ///Execute this method in background, as it
                    [weakSelf performSelectorInBackground:@selector(processNeedyForwardedCell411Objects:) withObject:arrFilteredAlerts];
                    
                }
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
            
            
            
        }];
        
#if RIDE_HAILING_ENABLED
        ///Fetch ride alerts if it's enabled
        [self fetchRideAlerts];
#endif

        
    }
    
    
    
}

///Fetch the friend invite requests being sent to current user, will be useful when user registered for the app
-(void)fetchFriendInviteRequests
{
    ///get the email of the user as anyone will send invite to a non existing user using his/her email address only
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser){
        NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
        NSString *strTrimmedEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        

        PFQuery *fetchFriendInviteQuery = nil;
        if (strTrimmedEmail.length > 0) {
            
            fetchFriendInviteQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [fetchFriendInviteQuery whereKey:kCell411AlertToKey equalTo:strTrimmedEmail.lowercaseString];
            [fetchFriendInviteQuery whereKey:kCell411AlertEntryForKey equalTo:kEntryForFriendInvite];
            [fetchFriendInviteQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
            [fetchFriendInviteQuery whereKey:kCell411AlertSeenByKey notEqualTo:currentUser];
        }
        
        
#if PHONE_VERIFICATION_ENABLED
        ///Check if mobile number of current user is available and is verified or not
        NSString *strContactNumber = currentUser[kUserMobileNumberKey];
        strContactNumber = [C411StaticHelper getNumericStringFromString:strContactNumber];
        BOOL isPhoneVerified = [currentUser[kUserPhoneVerifiedKey]boolValue];
        if ((strContactNumber.length > 0) && isPhoneVerified) {
            
            ///make a subquery to fetch FI on this number
            PFQuery *fetchFriendReqWithPhoneNumberSubQuery = [PFQuery queryWithClassName:kCell411AlertClassNameKey];
            [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertToKey equalTo:strContactNumber];
            [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertEntryForKey containedIn:@[kEntryForFriendInvite]];
            [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertStatusKey equalTo:kAlertStatusPending];
            [fetchFriendReqWithPhoneNumberSubQuery whereKey:kCell411AlertSeenByKey notEqualTo:currentUser];
            
            if (fetchFriendInviteQuery) {
                
                ///Create a new fetchFriendInviteQuery using subqueries
                fetchFriendInviteQuery = [PFQuery orQueryWithSubqueries:@[fetchFriendInviteQuery,fetchFriendReqWithPhoneNumberSubQuery]];
                
            }
            else{
                
                ///Use phone number query for fetching friend invite
                fetchFriendInviteQuery = fetchFriendReqWithPhoneNumberSubQuery;
                
            }
            
        }
#endif

        
        if (fetchFriendInviteQuery) {
            
            ///5.Set max limit
            fetchFriendInviteQuery.limit = 1000;
            
            ///6.finally sort it with the most recent one first
            [fetchFriendInviteQuery orderByDescending:@"createdAt"];
            
            ///Include the issuedBy person object
            [fetchFriendInviteQuery includeKey:kCell411AlertIssuedByKey];
            
            
            __weak typeof(self) weakSelf = self;
            ///fetch the list of invite alerts from Cell411Alerts table
            [fetchFriendInviteQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                
                if (!error) {
                    
                    if (objects.count > 0) {
                        ///filter the objects to remove invalid alerts
                        NSArray *arrFilteredAlerts = [C411StaticHelper alertsArrayByRemovingInvalidObjectsFromArray:objects isForwardedAlert:NO];
                        [weakSelf processC411AlertObjects:arrFilteredAlerts];
                        
                    }
                    
                    
                    
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
    
}

-(void)fetchRideAlerts
{
#if RIDE_HAILING_ENABLED
   
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    
    if (currentUser) {
        ///If user is logged in then only try to fetch from parse
        ///1.Make a query to fetch ride requests which is still pending and not yet expired
        NSDate *minDate = [[NSDate date]dateByAddingTimeInterval:(-1) * TIME_TO_LIVE_FOR_RIDE_REQ];
        
        PFQuery *fetchRideRequestsQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
        [fetchRideRequestsQuery whereKey:kRideRequestTargetMembersKey containsAllObjectsInArray:[NSArray arrayWithObject:currentUser]];
        [fetchRideRequestsQuery whereKey:kRideRequestInitiatedByKey notEqualTo:currentUser];
        [fetchRideRequestsQuery whereKey:kRideRequestRejectedByKey notEqualTo:currentUser];
        [fetchRideRequestsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
        [fetchRideRequestsQuery whereKey:kRideRequestStatusKey equalTo:kRideRequestStatusPending];
        
        if (self.tappedRideRequestId.length > 0) {
            
            ///Add query to remove ride request with id which has been tapped to open the app, as it has been already displayed
            [fetchRideRequestsQuery whereKey:@"objectId" notEqualTo:self.tappedRideRequestId];
            
            
        }
        
        
        ///Set max limit
        fetchRideRequestsQuery.limit = 1000;
        
        ///Include the requestedBy person object as well
        [fetchRideRequestsQuery includeKey:kRideRequestRequestedByKey];
        
        
        __weak typeof(self) weakSelf = self;
        ///fetch the list of alerts from Cell411Alerts table
        [fetchRideRequestsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                if (objects.count > 0) {
                    ///filter the objects to remove invalid alerts
                    NSArray *arrFilteredRequests = [C411StaticHelper rideRequestArrayByRemovingInvalidObjectsFromArray:objects];
                    [weakSelf processRideRequests:arrFilteredRequests];
                    
                }
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
            
            
            
        }];

        ///2.Make a query to fetch ride interested responses from driver
        PFQuery *fetchSelfRideRequestsSubQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
        [fetchSelfRideRequestsSubQuery whereKey:kRideRequestRequestedByKey equalTo:currentUser];
        [fetchSelfRideRequestsSubQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
        [fetchSelfRideRequestsSubQuery whereKey:kRideRequestStatusKey equalTo:kRideRequestStatusPending];

        PFQuery *fetchRideResponseQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
        [fetchRideResponseQuery whereKey:kRideResponseRideRiquestIdKey matchesKey:@"objectId" inQuery:fetchSelfRideRequestsSubQuery];
        [fetchRideResponseQuery whereKey:kRideResponseSeenKey equalTo:@(NO)];
        if (self.tappedRideResponseId.length > 0) {
            
            ///Add query to remove ride response with id which has been tapped to open the app, as it has been already displayed
            [fetchRideResponseQuery whereKey:@"objectId" notEqualTo:self.tappedRideResponseId];
            
            
        }

        ///Set max limit
        fetchRideResponseQuery.limit = 1000;
        
        ///Include the respondedBy person object as well
        [fetchRideResponseQuery includeKey:kRideResponseRespondedByKey];
        
        
        ///fetch the list of alerts from Cell411Alerts table
        [fetchRideResponseQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                if (objects.count > 0) {
                    ///filter the objects to remove invalid alerts
                    NSArray *arrFilteredResponse = [C411StaticHelper rideResponseArrayByRemovingInvalidObjectsFromArray:objects];
                    
                    ///Execute this method in background, as it will fetch ride requests as well
                    [weakSelf performSelectorInBackground:@selector(processRideResponses:) withObject:arrFilteredResponse];
                }
                
                
            }
            else {
                
                if(![AppDelegate handleParseError:error]){
                    
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#error: %@",errorString);
                }
                
            }
            
            
            
        }];

        
        ///3.Make a query to fetch unseen ride confirmed/ride rejected responses from rider
        PFQuery *fetchUnseenRideConfirmedResponseSubQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
        [fetchUnseenRideConfirmedResponseSubQuery whereKey:kRideResponseRespondedByKey equalTo:currentUser];
        [fetchUnseenRideConfirmedResponseSubQuery whereKey:kRideResponseStatusKey equalTo:kRideResponseStatusConfirmed];
        [fetchUnseenRideConfirmedResponseSubQuery whereKey:kRideResponseSeenByDriverKey equalTo:@(NO)];
        [fetchSelfRideRequestsSubQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];

        PFQuery *fetchUnseenRideRejectedResponseSubQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
        [fetchUnseenRideRejectedResponseSubQuery whereKey:kRideResponseRespondedByKey equalTo:currentUser];
        [fetchUnseenRideRejectedResponseSubQuery whereKey:kRideResponseStatusKey equalTo:kRideResponseStatusRejected];
        [fetchUnseenRideRejectedResponseSubQuery whereKey:kRideResponseSeenByDriverKey equalTo:@(NO)];
        [fetchUnseenRideRejectedResponseSubQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];

        PFQuery *fetchUnseenRideResponseFromRiderQuery = [PFQuery orQueryWithSubqueries:@[fetchUnseenRideConfirmedResponseSubQuery,fetchUnseenRideRejectedResponseSubQuery]];
        
        if (self.tappedRideResponseFromRiderId.length > 0) {
            
            ///Add query to remove ride response with id which has been tapped to open the app, as it has been already displayed
            [fetchUnseenRideResponseFromRiderQuery whereKey:@"objectId" notEqualTo:self.tappedRideResponseFromRiderId];
            
            
        }
        
        ///Set max limit
        fetchUnseenRideResponseFromRiderQuery.limit = 1000;
        ///fetch the list of alerts from Cell411Alerts table
        [fetchUnseenRideResponseFromRiderQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (!error) {
                
                if (objects.count > 0) {
                    NSArray *arrResponseFromRider = objects;
                    
                    ///Execute this method in background, as it will fetch additional notes as well
                    [weakSelf performSelectorInBackground:@selector(processUnseenRideResponseFromRider:) withObject:arrResponseFromRider];
                }
                
                
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
    
    
    
    
    
#endif
    
}

-(void)processRideRequests:(NSArray *)arrRideRequests
{
    for (PFObject *rideRequest in arrRideRequests) {
        
        NSString *rideRequestId = rideRequest.objectId;
        if (self.tappedRideRequestId.length > 0 && [rideRequestId isEqualToString:self.tappedRideRequestId]){
            
            ///Ignore this request as this has already been displayed to user
            continue;
        }
        
        ///Make a ride request payload and post notification to observer
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        ///set common properties
        alertNotificationPayload.strAlertType = kPayloadAlertTypeRideRequest;
        alertNotificationPayload.createdAtInMillis = [rideRequest.createdAt timeIntervalSince1970]*1000;
        PFUser *rider = rideRequest[kRideRequestRequestedByKey];
        alertNotificationPayload.strUserId = rider.objectId;
        ///Ride request properties
        alertNotificationPayload.strAdditionalNote = rideRequest[kRideRequestAdditionalNoteKey];
        alertNotificationPayload.strRideRequestId = rideRequest.objectId;
        alertNotificationPayload.strFullName = [C411StaticHelper getFullNameUsingFirstName:rider[kUserFirstnameKey] andLastName:rider[kUserLastnameKey]];
        ///Set the pickup location
        PFGeoPoint *pickUpGeoPoint = rideRequest[kRideRequestPickupLocationKey];
        alertNotificationPayload.pickUpLat = pickUpGeoPoint.latitude;
        alertNotificationPayload.pickUpLon = pickUpGeoPoint.longitude;
        
        ///Set the drop location
        NSString *strDropLocation = rideRequest[kRideRequestDropLocationKey];
        NSArray *arrDropLocation = [strDropLocation componentsSeparatedByString:@","];
        if (arrDropLocation.count == 2) {
            
            alertNotificationPayload.dropLat = [[arrDropLocation firstObject]doubleValue];
            alertNotificationPayload.dropLon = [[arrDropLocation lastObject]doubleValue];
            
        }

        ///Post RIDE_REQUEST notification
        [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideRequestNotification object:alertNotificationPayload];

    }

}

-(void)processRideResponses:(NSArray *)arrRideResponses
{
    NSMutableDictionary *dictRideRequest = [NSMutableDictionary dictionary];
    for (PFObject *rideResponse in arrRideResponses) {
        
        NSString *rideResponseId = rideResponse.objectId;
        if (self.tappedRideResponseId.length > 0 && [rideResponseId isEqualToString:self.tappedRideResponseId]){
            
            ///Ignore this request as this has already been displayed to user
            continue;
        }
        
        ///Make a ride response payload and post notification to observer
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        ///set common properties
        alertNotificationPayload.strAlertType = kPayloadAlertTypeRideInterested;
        alertNotificationPayload.createdAtInMillis = [rideResponse.createdAt timeIntervalSince1970]*1000;
        PFUser *driver = rideResponse[kRideResponseRespondedByKey];
        alertNotificationPayload.strUserId = driver.objectId;
        ///Ride request properties
        alertNotificationPayload.strAdditionalNote = rideResponse[kRideResponseAdditionalNoteKey];
        NSString *strRideRequestId = rideResponse[kRideResponseRideRiquestIdKey];
        alertNotificationPayload.strRideRequestId = strRideRequestId;
        alertNotificationPayload.strRideResponseId = rideResponse.objectId;
        alertNotificationPayload.strFullName = [C411StaticHelper getFullNameUsingFirstName:driver[kUserFirstnameKey] andLastName:driver[kUserLastnameKey]];
        
        ///set cost
        alertNotificationPayload.strCost = rideResponse[kRideResponseCostKey];

        ///Get the ride request object for pickup and drop location
        PFObject *rideRequest = [dictRideRequest objectForKey:strRideRequestId];
        if (!rideRequest) {
            
            ///Get the corresponding ride request object from parse and save in local dictionary
            PFQuery *fetchRideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
            rideRequest = [fetchRideRequestQuery getObjectWithId:strRideRequestId];
            if (rideRequest) {
                
                ///save in dictionary
                [dictRideRequest setObject:rideRequest forKey:strRideRequestId];
            }
            
        }
        ///Set the pickup location
        PFGeoPoint *pickUpGeoPoint = rideRequest[kRideRequestPickupLocationKey];
        CLLocationCoordinate2D pickUpCoordinate = CLLocationCoordinate2DMake(pickUpGeoPoint.latitude, pickUpGeoPoint.longitude);
        alertNotificationPayload.pickUpLat = pickUpCoordinate.latitude;
        alertNotificationPayload.pickUpLon = pickUpCoordinate.longitude;

        ///Set the drop location
        NSString *strDropLocation = rideRequest[kRideRequestDropLocationKey];
        NSArray *arrDropLocation = [strDropLocation componentsSeparatedByString:@","];
        if (arrDropLocation.count == 2) {
            
            CLLocationCoordinate2D dropCoordinate = CLLocationCoordinate2DMake([[arrDropLocation firstObject]doubleValue], [[arrDropLocation lastObject]doubleValue]);
            
            ///Set the drop location
            alertNotificationPayload.dropLat = dropCoordinate.latitude;
            alertNotificationPayload.dropLon = dropCoordinate.longitude;

            
        }
        
       ///Post notification on main thread as this is an asyncronous method
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            
            ///Post RIDE_INTERESTED notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideInterestedNotification object:alertNotificationPayload];
            
        }];

    }
    
}

-(void)processUnseenRideResponseFromRider:(NSArray *)arrRideResponsesFromRider
{
    NSMutableDictionary *dictRideRequest = [NSMutableDictionary dictionary];
    for (PFObject *rideResponseFromRider in arrRideResponsesFromRider) {
        
        NSString *rideResponseId = rideResponseFromRider.objectId;
        if (self.tappedRideResponseFromRiderId.length > 0 && [rideResponseId isEqualToString:self.tappedRideResponseFromRiderId]){
            
            ///Ignore this request as this has already been displayed to user
            continue;
        }
        
        ///make a ride confirmed or ride rejected payload and post notification to observer
        C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
        

        ///set common properties
        alertNotificationPayload.createdAtInMillis = [rideResponseFromRider.createdAt timeIntervalSince1970]*1000;
        alertNotificationPayload.strRideResponseId = rideResponseFromRider.objectId;
        ///Get the ride request object
        NSString *strRideRequestId = rideResponseFromRider[kRideResponseRideRiquestIdKey];
        PFObject *rideRequest = [dictRideRequest objectForKey:strRideRequestId];
        if (!rideRequest) {
            
            ///Get the corresponding ride request object from parse and save in local dictionary
            PFQuery *fetchRideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
            [fetchRideRequestQuery includeKey:kRideRequestRequestedByKey];
            rideRequest = [fetchRideRequestQuery getObjectWithId:strRideRequestId];
            if (rideRequest) {
                
                ///save in dictionary
                [dictRideRequest setObject:rideRequest forKey:strRideRequestId];
            }
            
        }
        
        PFUser *rider = rideRequest[kRideRequestRequestedByKey];
        alertNotificationPayload.strUserId = rider.objectId;
        alertNotificationPayload.strFullName = [C411StaticHelper getFullNameUsingFirstName:rider[kUserFirstnameKey] andLastName:rider[kUserLastnameKey]];
        
        ///Make a query to get the additional note
        PFQuery *fetchAdditionalNote4RideQuery = [PFQuery queryWithClassName:kAdditionalNote4RideClassNameKey];
        [fetchAdditionalNote4RideQuery whereKey:kAddNote4RideRideResponseIdKey equalTo:rideResponseFromRider.objectId];
        PFObject *addNote4Ride = [fetchAdditionalNote4RideQuery getFirstObject];
        if (addNote4Ride) {
            
            ///set the additional note as well
            alertNotificationPayload.strAdditionalNote = addNote4Ride[kAddNote4RideNoteKey];
        }

        NSString *strResponseStatus = rideResponseFromRider[kRideResponseStatusKey];
        if ([strResponseStatus isEqualToString:kRideResponseStatusConfirmed]) {
            
            ///Rider confirmed the driver's response
            alertNotificationPayload.strAlertType = kPayloadAlertTypeRideConfirmed;

            ///Set the pickup location
            PFGeoPoint *pickUpGeoPoint = rideRequest[kRideRequestPickupLocationKey];
            CLLocationCoordinate2D pickUpCoordinate = CLLocationCoordinate2DMake(pickUpGeoPoint.latitude, pickUpGeoPoint.longitude);
            alertNotificationPayload.pickUpLat = pickUpCoordinate.latitude;
            alertNotificationPayload.pickUpLon = pickUpCoordinate.longitude;
            
            ///Set the drop location
            NSString *strDropLocation = rideRequest[kRideRequestDropLocationKey];
            NSArray *arrDropLocation = [strDropLocation componentsSeparatedByString:@","];
            if (arrDropLocation.count == 2) {
                
                CLLocationCoordinate2D dropCoordinate = CLLocationCoordinate2DMake([[arrDropLocation firstObject]doubleValue], [[arrDropLocation lastObject]doubleValue]);
                
                ///Set the drop location
                alertNotificationPayload.dropLat = dropCoordinate.latitude;
                alertNotificationPayload.dropLon = dropCoordinate.longitude;
                
                
            }
            
            ///Post notification on main thread as this is an asyncronous method
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                
                ///Post RIDE_CONFIRMED notification
                [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideConfirmedNotification object:alertNotificationPayload];
                
            }];

        }
        else{
            ///Rider rejected the driver's response
            alertNotificationPayload.strAlertType = kPayloadAlertTypeRideRejected;
            
            ///Post notification on main thread as this is an asyncronous method
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                
                ///Post RIDE_REJECTED notification
                [[NSNotificationCenter defaultCenter]postNotificationName:kReceivedRideRejectedNotification object:alertNotificationPayload];
                
            }];


        }
        

        
        
    }
    
}


-(void)processC411AlertObjects:(NSArray *)arrC411Alerts
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *currentUserObjectId = currentUser.objectId;
//    NSString *currentUserUsername = currentUser.username;
//    PFObject *recentNeedyAlertIssuedByCurrUser = nil;CODE_FOR_ALL_OK_FEATURE
    
    for (PFObject *cell411Alert in arrC411Alerts) {
        
        NSString *cell411AlertId = cell411Alert.objectId;
        if (self.tappedNotificationAlertId.length > 0 && [cell411AlertId isEqualToString:self.tappedNotificationAlertId]){
            
            ///Ignore this alert as this has already been displayed to user
            continue;
        }
///Replacing below condition as username is not required to check, if it's required then add one more conditon to check username(without lowercase) or email for facebook user
//        if (([[cell411Alert[kCell411AlertToKey]lowercaseString]isEqualToString:currentUserUsername.lowercaseString])
//            &&(([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForFriendRequest])
//               ||([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForFriendInvite])
//               ||([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForCellRequest]))) {
        if (([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForFriendRequest])
               ||([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForFriendInvite])
               ||([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForCellRequest])) {

                ///You can add pending status check as well but its not required as it has already been used at the time of querying to parse
                if (([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForFriendRequest])
                    ||([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForFriendInvite])) {
                    ///This is a Friend request/invite alert,Some one wants your approval to add you in his/her friends list,create a notification payload
                    ///NOTE: Friend Invite (FI) will also be treated as Freind Request(FR) to show alert to user and adding friends.
                    NSString *strIssuerFirstName = cell411Alert[kCell411AlertIssuerFirstNameKey];
                    C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
                    ///set common properties
                    alertNotificationPayload.strAlertType = kPayloadAlertTypeFriendRequest;
                    NSString *strPayloadFRMsgSuffix = nil;
#if APP_IER
                    
                    ///iER values to use 'an' article
                    strPayloadFRMsgSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"has sent you an %@ friend request!",nil),LOCALIZED_APP_NAME];
                    
#else
                    
                    ///Other app Values
                    strPayloadFRMsgSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"has sent you a %@ friend request!",nil),LOCALIZED_APP_NAME];
#endif

                    alertNotificationPayload.strAlert = [NSString stringWithFormat:@"%@ %@",strIssuerFirstName,strPayloadFRMsgSuffix];
                    alertNotificationPayload.strUserId = [cell411Alert[kCell411AlertIssuedByKey]objectId];
                    
                    ///FRIEND_REQUEST Keys
                    alertNotificationPayload.strCell411AlertId = cell411Alert.objectId;
                    alertNotificationPayload.strFullName = strIssuerFirstName;
                    
                    ///Post notification
                    [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertForFriendRequestNotification object:alertNotificationPayload];
                }
                else if ([cell411Alert[kCell411AlertEntryForKey]isEqualToString:kEntryForCellRequest]){
                    
                    ///This is a Cell request alert so someone want to join your public cell,create a notification payload
                    ///NOTE: Friend Invite (FI) will also be treated as Freind Request(FR) to show alert to user and adding friends.
                    NSString *strIssuerFullName = cell411Alert[kCell411AlertIssuerFirstNameKey];
                    NSString *strCellName = cell411Alert[kCell411AlertCellNameKey];
                    C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
                    ///set common properties
                    alertNotificationPayload.strAlertType = kPayloadAlertTypeCellRequest;
                    alertNotificationPayload.strAlert = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ has sent you a Cell join request on %@ Cell!",nil),strIssuerFullName,strCellName];
                    alertNotificationPayload.strUserId = [cell411Alert[kCell411AlertIssuedByKey]objectId];
                    alertNotificationPayload.strFullName = strIssuerFullName;
                    
                    ///CELL_REQUEST Keys
                    alertNotificationPayload.strCellRequestObjectId = cell411Alert.objectId;
                    alertNotificationPayload.strCellId = cell411Alert[kCell411AlertCellIdKey];
                    alertNotificationPayload.strCellName = strCellName;
                    
                    ///Post notification
                    [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertToJoinPublicCellNotification object:alertNotificationPayload];
                    
                    
                }
                
                
                
                
            }
        else if ([cell411Alert[kCell411AlertIssuerIdKey] isEqualToString:currentUserObjectId]) {
            
            ///This alert has been issued by current user,other than forwarded or public alert
 /*CODE_FOR_ALL_OK_FEATURE
            //check if there is any person who initiated to the request
            ///Alert from Helper
            NSString *strAlertTypeKey = cell411Alert[kCell411AlertAlertTypeKey];
            if ((![strAlertTypeKey isEqualToString:kAlertTypeVideo])
                &&(![strAlertTypeKey isEqualToString:kAlertTypePhoto])) {
                
                ///Acquire the most recent alert except video/photo issued by current user, this would be used at the end of iteration to check for OK status
                if (recentNeedyAlertIssuedByCurrUser) {
                    ///if current alert is more recent one save this reference
                    if ([recentNeedyAlertIssuedByCurrUser.createdAt compare:cell411Alert.createdAt] == NSOrderedAscending) {
                        
                        recentNeedyAlertIssuedByCurrUser = cell411Alert;
                        
                    }
                    
                }
                else{
                    ///if this is the first alert save it.
                    recentNeedyAlertIssuedByCurrUser = cell411Alert;
                }
                
            }
*/
            
            
        }
        else if ([cell411Alert[kCell411AlertIssuerIdKey]length] > 0){
            
            ///This is the alert regarding to someone who is needy or has streamed video or has sent photo alert. Create a needy/NEEDY_CELL/VIDEO/PHOTO/PHOTO_CELL payload if its not duplicate
            ///Alert from Needy/NEEDY_CELL/VIDEO/PHOTO/PHOTO_CELL
            
            ///Create a Needy/NEEDY_CELL/VIDEO/PHOTO/PHOTO_CELL payload and notify the observer to display it
            NSString *strIssuerFirstName = cell411Alert[kCell411AlertIssuerFirstNameKey];
            
            C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
            
            
            ///set common properties
            alertNotificationPayload.createdAtInMillis = [cell411Alert.createdAt timeIntervalSince1970] * 1000;
            alertNotificationPayload.strUserId = cell411Alert[kCell411AlertIssuerIdKey];
            
            ///Needy properties
            alertNotificationPayload.strAdditionalNote = cell411Alert[kCell411AlertAdditionalNoteKey];
            NSString *strAlertRegarding = nil;
            NSNumber *numAlertType = cell411Alert[kCell411AlertAlertIdKey];
            if(numAlertType){
                AlertType alertType = (AlertType)[numAlertType integerValue];
                strAlertRegarding = [C411StaticHelper getAlertTypeStringUsingAlertType:alertType];
            }
            else{
                strAlertRegarding = cell411Alert[kCell411AlertAlertTypeKey];
            }
            alertNotificationPayload.strAlertRegarding = strAlertRegarding;
            alertNotificationPayload.strCell411AlertId = cell411Alert.objectId;
            alertNotificationPayload.strFullName = strIssuerFirstName;
            
            C411Address *alertAddress = [[C411Address alloc]init];
            alertAddress.coordinate = CLLocationCoordinate2DMake([cell411Alert[kCell411AlertLocationKey]latitude], [cell411Alert[kCell411AlertLocationKey]longitude]);
            alertAddress.strCity = cell411Alert[kCell411AlertCityKey];
            alertAddress.strCountry = cell411Alert[kCell411AlertCountryKey];
            alertAddress.strFullAddress = cell411Alert[kCell411AlertFullAddressKey];
            alertNotificationPayload.alertAddress = alertAddress;
            alertNotificationPayload.isGlobalAlert = [cell411Alert[kCell411AlertIsGlobalKey]intValue];
            NSNumber *dispatchMode = cell411Alert[kCell411AlertDispatchModeKey];
            if (dispatchMode) {
                
                alertNotificationPayload.dispatchMode = [dispatchMode intValue];
            }
            if ([strAlertRegarding isKindOfClass:[NSString class]] && [strAlertRegarding isEqualToString:kAlertTypeVideo]) {
                
                ///this is a video alert, set video specific keys
                alertNotificationPayload.strAlertType = kPayloadAlertTypeVideo;
                alertNotificationPayload.strAlert = NSLocalizedString(@"Video Streaming Alert", nil);
                alertNotificationPayload.strStatus = cell411Alert[kCell411AlertStatusKey];
                
                ///Post notification
                [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedVideoStreamingNotification object:alertNotificationPayload];
            }
            else if ([strAlertRegarding isKindOfClass:[NSString class]] && [strAlertRegarding isEqualToString:kAlertTypePhoto]) {
                
                ///This is a photo alert, set photo specific keys
                NSString *strPublicCellId = cell411Alert[kCell411AlertCellIdKey];
                if (strPublicCellId.length > 0) {
                    
                    alertNotificationPayload.strAlertType = kPayloadAlertTypePhotoCell;
                    alertNotificationPayload.strCellId = cell411Alert[kCell411AlertCellIdKey];
                    alertNotificationPayload.strCellName = cell411Alert[kCell411AlertCellNameKey];
                }
                else{
                    alertNotificationPayload.strAlertType = kPayloadAlertTypePhoto;
                    
                }
                alertNotificationPayload.strAlert = [NSString stringWithFormat:@"%@ %@",strIssuerFirstName, NSLocalizedString(@"issued a photo alert!", nil)];
                alertNotificationPayload.photoFile = cell411Alert[kCell411AlertPhotoKey];
                ///Post notification
                [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedPhotoAlertNotification object:alertNotificationPayload];
            }
            else{
                
                ///This is a needy alert, set needy alert specific keys
                NSString *strPublicCellId = cell411Alert[kCell411AlertCellIdKey];
                if (strPublicCellId.length > 0) {
                    
                    alertNotificationPayload.strAlertType = kPayloadAlertTypeNeedyCell;
                    alertNotificationPayload.strCellId = cell411Alert[kCell411AlertCellIdKey];
                    alertNotificationPayload.strCellName = cell411Alert[kCell411AlertCellNameKey];
                }
                else{
                    alertNotificationPayload.strAlertType = kPayloadAlertTypeNeedy;
                    
                }
                
                alertNotificationPayload.strAlert = [NSString stringWithFormat:@"%@ %@",strIssuerFirstName, NSLocalizedString(@"issued an emergency alert!", nil)];
                ///Post notification
                [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertFromNeedyNotification object:alertNotificationPayload];
            }
            
            
            
            
            
            
        }
        
    }

    /*CODE_FOR_ALL_OK_FEATURE
    ///If there is any alert issued by current user within 24 hour check its OK status
    if (recentNeedyAlertIssuedByCurrUser) {
        
        ///yes an alert has been issued by current user
        ///Check for OK status
        if ([recentNeedyAlertIssuedByCurrUser[kCell411AlertStatusKey]isEqualToString:kAlertStatusAllOk]) {
            ///Latest alert issued by current user's status has been set to OK, update the values accordingly
            if (self.shouldShowAllOkOption) {
                
                ///Turn it to NO as the status is OK
                self.showAllOkOption = NO;
                self.lastIssuedNeedyAlert = nil;
                
                ///notify the observers as there is change
                [[NSNotificationCenter defaultCenter]postNotificationName:kAllOkValueChangedNotification object:@(self.shouldShowAllOkOption)];
                
            }
            else{
                
                ///Its already conforming to OK status in the app, just clear the lastIssuedNeedyAlert for playing safe
                self.lastIssuedNeedyAlert = nil;
                
                
            }
            
            
        }
        else{
            
            ///Latest alert issued by current user's status has been not been set to OK, update the values accordingly
            if (self.shouldShowAllOkOption) {
                
                ///Its already conforming to OK status in the app, just set the lastIssuedNeedyAlert for playing safe
                self.lastIssuedNeedyAlert = recentNeedyAlertIssuedByCurrUser;
                
            }
            else{
                
                ///Turn it to Yes as the status is OK
                self.showAllOkOption = YES;
                self.lastIssuedNeedyAlert = recentNeedyAlertIssuedByCurrUser;
                
                ///notify the observers as there is change
                [[NSNotificationCenter defaultCenter]postNotificationName:kAllOkValueChangedNotification object:@(self.shouldShowAllOkOption)];
                
                
            }
            
            
            
            
        }
        
    }
    else{
        
        ///No alert has been issued by current user
        if (self.shouldShowAllOkOption) {
            
            ///Turn it to NO
            self.showAllOkOption = NO;
            self.lastIssuedNeedyAlert = nil;
            
            ///notify the observers as there is change
            [[NSNotificationCenter defaultCenter]postNotificationName:kAllOkValueChangedNotification object:@(self.shouldShowAllOkOption)];
            
        }
        
        
    }
     */
    
}

-(void)processPendingTaskObjects:(NSArray *)arrTasks
{
    for (PFObject *task in arrTasks) {
        
        NSString *taskId = task.objectId;
        if (self.tappedNotificationAlertId.length > 0 && [taskId isEqualToString:self.tappedNotificationAlertId]){
            
            ///Ignore this alert as this has already been displayed to user
            continue;
        }
        
        NSString *taskType = task[kTaskTaskKey];
        NSString *taskStatus = task[kTaskStatusKey];
        if ([taskType isEqualToString:kTaskFriendAdd] && [taskStatus isEqualToString:kTaskStatusPending]) {
            
            ///This is a FRIEND_ADD task associated to FRIEND_APPROVED alert
            
            C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
            ///set common properties
            ///Set friend approved as alert type so that it can be processed as FRIEND_APPROVED alert
            alertNotificationPayload.strAlertType = kPayloadAlertTypeFriendApproved;
            alertNotificationPayload.strAlert = nil;///Can't set this as assignee object need to be fetched, it can be done by notification observer
            alertNotificationPayload.strUserId = task[kTaskAssigneeUserIdKey];
            
            ///FRIEND_APPROVED Keys
            alertNotificationPayload.strTaskId = taskId;
            alertNotificationPayload.strFullName = nil;///Can't set this as assignee object need to be fetched for this, it can be done by notification observer
            
            ///Post notification
            [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertForFriendApprovedNotification object:alertNotificationPayload];
            
        }
        else if ([taskType isEqualToString:kTaskSpamAdd] && [taskStatus isEqualToString:kTaskStatusPending]) {
            
            ///This is a SPAM_ADD task associated to SpammedBy someone
            ///Get Assignee of this task as this is the person who spammed current user, once we get this object we add it to current user's spammedBy relation
            NSString *strSpammedByUserId = task[kTaskAssigneeUserIdKey];
            
            PFQuery *getUserQuery = [PFUser query];
            [getUserQuery getObjectInBackgroundWithId:strSpammedByUserId block:^(PFObject *object,  NSError *error){
                
                if (!error && object) {
                    
                    ///User found, add it to current user's spammedBy relation
                    PFUser *spammedByUser = (PFUser *)object;
                    
                    PFUser *currentUser = [AppDelegate getLoggedInUser];
                    PFRelation *spammedByRelation = [currentUser relationForKey:kUserSpammedByKey];
                    [spammedByRelation addObject:spammedByUser];
                    
                    ///save current user object
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            ///spammedByUser added to current user's spammedBy list
                            [task deleteEventually];
                            NSLog(@"user added to spammedBy list");
                        }
                        else{
                            ///some error occured adding user to spammedBy list
                            if (error) {
                                ///show error
                                NSString *errorString = [error userInfo][@"error"];
                                NSLog(@"error adding to SpammedBy relation %@",errorString);
                            }
                            
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
        else if ([taskType isEqualToString:kTaskSpamRemove] && [taskStatus isEqualToString:kTaskStatusPending]) {
            
            ///This is a SPAM_REMOVE task associated to SpammedBy someone
            ///Get Assignee of this task as this is the person who unspammed current user, once we get this object we remove it from current user's spammedBy relation
            NSString *strSpammedByUserId = task[kTaskAssigneeUserIdKey];
            
            PFQuery *getUserQuery = [PFUser query];
            [getUserQuery getObjectInBackgroundWithId:strSpammedByUserId block:^(PFObject *object,  NSError *error){
                
                if (!error && object) {
                    
                    ///User found, remove it from current user's spammedBy relation
                    PFUser *unSpammedByUser = (PFUser *)object;
                    
                    PFUser *currentUser = [AppDelegate getLoggedInUser];
                    PFRelation *spammedByRelation = [currentUser relationForKey:kUserSpammedByKey];
                    [spammedByRelation removeObject:unSpammedByUser];
                    
                    ///save current user object
                    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        
                        if (succeeded) {
                            ///unSpammedByUser removed from current user's spammedBy list
                            [task deleteEventually];
                            NSLog(@"user removed from spammedBy list");
                        }
                        else{
                            ///some error occured removing user from spammedBy list
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    NSLog(@"error removing from SpammedBy relation %@",errorString);
                                }
                            }
                            
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
        
        
        
        
    }
    
}

///This method will handle the additonal notes sent by the responder for the needy alert along with Help or Cannot Help option
-(void)processNeedyResponderAdditionalNoteObjects:(NSArray *)arrAdditionalNotes
{
    for (PFObject *additionalNote in arrAdditionalNotes) {
        
        NSString *additionalNoteId = additionalNote.objectId;
        if (self.tappedNotifAdditionalNoteId.length > 0 && [additionalNoteId isEqualToString:self.tappedNotifAdditionalNoteId]){
            
            ///Ignore this note as this has already been displayed to user
            continue;
        }
        
        NSNumber *seenValue = additionalNote[kAdditionalNoteSeenKey];
        if (seenValue && [seenValue intValue] == 0) {
            
            ///Check whether the issuer exist on the DB or not
            NSString *strFullName = additionalNote[kAdditionalNoteWriterNameKey];
            NSString *strUserId = additionalNote[kAdditionalNoteWriterIdKey];
            
            if ([C411StaticHelper validateUserUsingObjectId:strUserId]
                && [C411StaticHelper validateUserUsingFullName:strFullName]) {

                ///This additionalNote is still unseen and should be shown to user
                
                C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
                
                ///set common properties
                alertNotificationPayload.strAlertType = additionalNote[kAdditionalNoteAlertTypeKey];
                alertNotificationPayload.strAlert = nil;///It can be created at notification observer end using the alertType and additional Note
                alertNotificationPayload.createdAtInMillis = [additionalNote.createdAt timeIntervalSince1970] * 1000;
                alertNotificationPayload.strUserId = additionalNote[kAdditionalNoteWriterIdKey];
                
                ///Helper Keys
                alertNotificationPayload.strDuration = additionalNote[kAdditionalNoteWriterDurationKey];
                alertNotificationPayload.strFullName = additionalNote[kAdditionalNoteWriterNameKey];
                alertNotificationPayload.strUserType = additionalNote[kAdditionalNoteUserTypeKey];
                
                ///Responder (i.e Helper or Rejector) keys for Additonal Note
                alertNotificationPayload.strAdditionalNote = additionalNote[kAdditionalNoteNoteKey];
                alertNotificationPayload.strAdditionalNoteId = additionalNote.objectId;
                
                
                ///Post notification
                if ([alertNotificationPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeHelper.lowercaseString]){
                    
                    ///Add ForwardedBy member if available
                    alertNotificationPayload.strForwardedBy = additionalNote[kAdditionalNoteForwardedByKey];
                    
                    ///Add cellid and cellname if available
                    alertNotificationPayload.strCellId = additionalNote[kAdditionalNoteCellIdKey];
                    alertNotificationPayload.strCellName = additionalNote[kAdditionalNoteCellNameKey];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertFromHelperNotification object:alertNotificationPayload];
                }
                else if([alertNotificationPayload.strAlertType.lowercaseString isEqualToString:kPayloadAlertTypeRejector.lowercaseString]){
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertFromRejectorNotification object:alertNotificationPayload];
                    
                }
                

            }
            
            
        }
        
        
    }
    
}


///This method will handle the forwarded(NEEDY_FORWARDED) alerts sent by the someone on recieving the needy alert
-(void)processNeedyForwardedCell411Objects:(NSArray *)arrForwardedCell411Alerts
{
    NSString *currentUserObjectId = [AppDelegate getLoggedInUser].objectId;
    
    for (PFObject *forwardedCell411Alert in arrForwardedCell411Alerts) {
        
        PFObject *actualAlert = forwardedCell411Alert[kCell411AlertForwardedAlertKey];
        NSString *cell411AlertId = actualAlert.objectId;
        if (self.tappedNotificationAlertId.length > 0 && [cell411AlertId isEqualToString:self.tappedNotificationAlertId]){
            
            ///Ignore this alert as this has already been displayed to user
            continue;
        }
        
        
        ///This is the alert forwarded by someone who recieved needy alert. Create a NEEDY_FORWARDED payload if its valid and not duplicate
        double createdAtInMillis = [actualAlert.createdAt timeIntervalSince1970] * 1000;
        NSString *strAlertStatus = actualAlert[kCell411AlertStatusKey];
        
        ///Check if original alert issued is within 2 hours limit or not and alert status is not ok
        if ([self isAlertNotificationValid:@(createdAtInMillis)] && ![strAlertStatus isEqualToString:kAlertStatusAllOk]) {
            
            PFRelation *initiatedByRelation = [actualAlert relationForKey:kCell411AlertInitiatedByKey];
            PFQuery *initiatedByQuery = [initiatedByRelation query];
            [initiatedByQuery whereKey:@"objectId" equalTo:currentUserObjectId];
            NSError *error = nil;
            ///get the object synchronously as this method is running asynchronously
            PFObject *helperUserObject = [initiatedByQuery getFirstObject:&error];
            if (!error) {
                
                ///Current user has already initiated the alert, so do nothing
                NSLog(@"This user has already intiated the alert");
            }
            else if (error.code == kPFErrorObjectNotFound){
                
                ///Current user has not yet initiated the alert, but he may have rejected the alert. So let's check that
                PFRelation *rejectedByRelation = [actualAlert relationForKey:kCell411AlertRejectedByKey];
                PFQuery *rejectedByQuery = [rejectedByRelation query];
                [rejectedByQuery whereKey:@"objectId" equalTo:currentUserObjectId];
                error = nil;
                ///get the object synchronously as this method is running asynchronously
                PFObject *rejectorUserObject = [rejectedByQuery getFirstObject:&error];
                if (!error) {
                    
                    ///Current user has already rejected the alert, so do nothing
                    NSLog(@"This user has already rejected the alert");
                }
                else if (error.code == kPFErrorObjectNotFound){
                    
                    ///Current user has neither initiated the alert nor rejected the alert. So make the alert payload for NEEDY_FORWARDED and post notification on main thread
                    
                    NSString *strIssuerFirstName = forwardedCell411Alert[kCell411AlertIssuerFirstNameKey];
                    
                    C411AlertNotificationPayload *alertNotificationPayload = [[C411AlertNotificationPayload alloc]init];
                    
                    
                    ///set common properties
                    alertNotificationPayload.createdAtInMillis = createdAtInMillis;
                    alertNotificationPayload.strUserId = forwardedCell411Alert[kCell411AlertIssuerIdKey];
                    
                    ///Needy properties
                    alertNotificationPayload.strAdditionalNote = forwardedCell411Alert[kCell411AlertAdditionalNoteKey];
                    NSNumber *numAlertType = forwardedCell411Alert[kCell411AlertAlertIdKey];
                    if(numAlertType){
                        AlertType alertType = (AlertType)[numAlertType integerValue];
                        alertNotificationPayload.strAlertRegarding = [C411StaticHelper getAlertTypeStringUsingAlertType:alertType];
                    }
                    else{
                        alertNotificationPayload.strAlertRegarding = forwardedCell411Alert[kCell411AlertAlertTypeKey];
                    }
                    alertNotificationPayload.strCell411AlertId = actualAlert.objectId;
                    alertNotificationPayload.strFullName = strIssuerFirstName;
                    
                    C411Address *alertAddress = [[C411Address alloc]init];
                    alertAddress.coordinate = CLLocationCoordinate2DMake([forwardedCell411Alert[kCell411AlertLocationKey]latitude], [forwardedCell411Alert[kCell411AlertLocationKey]longitude]);
                    alertAddress.strCity = forwardedCell411Alert[kCell411AlertCityKey];
                    alertAddress.strCountry = forwardedCell411Alert[kCell411AlertCountryKey];
                    alertAddress.strFullAddress = forwardedCell411Alert[kCell411AlertFullAddressKey];
                    alertNotificationPayload.alertAddress = alertAddress;
                    
                    alertNotificationPayload.isGlobalAlert = [forwardedCell411Alert[kCell411AlertIsGlobalKey]intValue];
                    NSNumber *dispatchMode = forwardedCell411Alert[kCell411AlertDispatchModeKey];
                    if (dispatchMode) {
                        
                        alertNotificationPayload.dispatchMode = [dispatchMode intValue];
                    }
                    
                    ///This is a NEEDY_FORWARDED alert, set NEEDY_FORWARDED alert specific keys
                    alertNotificationPayload.strAlertType = kPayloadAlertTypeNeedyForwarded;
                    PFUser *forwardedByUser = forwardedCell411Alert[kCell411AlertForwardedByKey];
                    NSString *strForwardedBy = [C411StaticHelper getFullNameUsingFirstName:forwardedByUser[kUserFirstnameKey] andLastName:forwardedByUser[kUserLastnameKey]];
                    
                    alertNotificationPayload.strForwardedBy = strForwardedBy;
                    alertNotificationPayload.strForwardingAlertId = forwardedCell411Alert.objectId;
                    alertNotificationPayload.strAlert = [NSString stringWithFormat:@"%@ %@",strForwardedBy,NSLocalizedString(@"forwarded an emergency alert!", nil)];
                    
                    ///Post notification on main thread as this is an asyncronous method
                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:kRecivedAlertFromNeedyNotification object:alertNotificationPayload];
                    }];
                    
                    
                    
                }
                else{
                    
                    ///Some error occured retrieving object for rejector, do nothing
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"#Error Rejector: %@",errorString);
                    
                }
                
            }
            else{
                
                ///Some error occured retrieving object for initiatedBy, do nothing
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"#Error InitiatedBy: %@",errorString);
                
            }
            
            
            
        }
        
    }
    
    
}


-(void)resetBadgeAndNotificationsFromTray
{
    ///reset badge
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    ///This will reset the badge locally from device as well as from Parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [currentInstallation saveEventually];
            }
        }];
    }
    
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

    [[UNUserNotificationCenter currentNotificationCenter]removeAllDeliveredNotifications];
    
#endif
    
}


-(void)verifyUserPrivileges
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        __weak typeof(self) weakSelf = self;
        ///get the privilege set for the user
        [C411StaticHelper getPrivilegeForUser:currentUser shouldSetPrivilegeIfUndefined:NO andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
            
            NSString *strPrivilege = string;
            if (error) {
                
                if (error.domain == PFParseErrorDomain && error.code == kPFErrorObjectNotFound) {
                    
                    ///User doesn't exist on Parse or has been deleted,log them out and don't allow them to use the app further and show welcome screen
                    
                    [weakSelf userDidLogout];

                }
                else if(![AppDelegate handleParseError:error]){
                    
                    ///It's some other kind of error, log it
                    NSLog(@"Some other error occured:%@",error);
                }
                
                
            }
            else if ((!strPrivilege)
                ||(strPrivilege.length == 0)) {
                
                ///some error occured fetching privilege
                NSLog(@"#error fetching privilege : %@",error.localizedDescription);
                
            }
            else if ([strPrivilege isEqualToString:kPrivilegeTypeBanned]){
                
                ///This user account is banned, log him out of the app
                [weakSelf userDidLogout];
                
            }
            else if ([strPrivilege hasPrefix:kPrivilegeTypeSuspended]){
                
                ///This user account is suspended, log him out of the app
                [weakSelf userDidLogout];
                
            }
            else{
                
                ///privilege is either FIRST, SECOND or SHADOW_BANNED. User with privilege FIRST or SHADOW_BANNED cannot send Global Alerts. No need to do anything here
                
                
            }
        }];
        
        
    }
    
}

-(void)showOldAppVersionDialog
{
    NSString *notificationMessage = NSLocalizedString(@"Please install the latest version to view this alert", nil);
    [C411StaticHelper showAlertWithTitle:nil message:notificationMessage onViewController:self.window.rootViewController];

}

-(void)validateFBAccessToken
{
#if FB_ENABLED
   
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser && [PFFacebookUtils isLinkedWithUser:currentUser]) {
        
        ///There is a logged in user linked with Facebook
        ///1. check if token is expired or not
        NSDate *tokenExpirationDate = [FBSDKAccessToken currentAccessToken].expirationDate;
        if([tokenExpirationDate timeIntervalSince1970] < [[NSDate date]timeIntervalSince1970]){
            
            ///token is expired
            [self handleInvalidFBAccessToken];
            
        }
        else{
            
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"first_name"}];
            [request setGraphErrorRecoveryDisabled:YES];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // handle successful response, token is valid...

                } else if ([[error userInfo][@"com.facebook.sdk:FBSDKGraphRequestErrorParsedJSONResponseKey"][@"body"][@"error"][@"type"] isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                    NSLog(@"The facebook session was invalidated");
                    
                    [self handleInvalidFBAccessToken];

                    
                    
                } else {
                    NSLog(@"Some other error validating facebook token, ignore it for now: %@", error);
                }
            }];
        }
        
        
    }

#endif
}

-(void)handleInvalidFBAccessToken
{
    
#if FB_ENABLED
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser && [PFFacebookUtils isLinkedWithUser:currentUser]) {
        
        ///This is a logged in user linked with Facebook
        ///check whether user has initially signed up using facebook or using default signup option
        if ([C411StaticHelper getSignUpTypeOfUser:currentUser] == SignUpTypeFacebook) {
            
            ///user has initially signed up using facebook as in this case the username will not be human readable and we'll never change username in this case, show an alert and log him out.NOTE:if user is signed Up using facebook then username is automatically created by Parse and we are assuming that it will not contain '@' symbol
            ///Perform logout operation without showing welcome screen first
            [[AppDelegate sharedInstance]performLogoutAndDoCleanup];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Session Expired", nil) message:NSLocalizedString(@"Your Facebook session is expired, please login again to continue.", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                ///Show welcome screen on OK action
                [[AppDelegate sharedInstance]showWelcomeGalleryScreen];
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]removeAllAlertsFromQueue];
                
                
            }];
            
            [alertController addAction:okAction];
            //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
            ///Enqueue the alert controller object in the presenter queue to be displayed one by one
            [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

            
            
        }
        else{
            
            ///User has initially signed up using email but has linked to facebook through settings connect to facebook button,unlink and show him a message to link again
            
            
            ///1. Unlink the current user from facebook
            __weak typeof(self) weakSelf = self;
            
            [PFFacebookUtils unlinkUserInBackground:currentUser block:^(BOOL succeeded, NSError * _Nullable error) {
                
                ///2. if success,clear access token, turn off Publish to Facebook option as well and show the alert to connect to Facebook again
                
                if (!error) {
                    
                    if (succeeded) {
                        
                        ///2.1 clear access token
                        [FBSDKAccessToken setCurrentAccessToken:nil];
                                                
                    }
                    else{
                        ///Mshow toast
                        NSLog(@"Some error occurred unlinking invalid fb user.", nil);
                        
                    }
                    
                }
                else{
                    
                    ///show error
                    NSLog(@"Error unlinking invalid fb user:%@",error.localizedDescription);
                    
                }

            
            
            }];

        
        }
    }
    
#endif

    
    
}

-(void)performPostLoginTask
{
    __weak typeof(self) weakSelf = self;
    [self handleAccountActivationWithCompletion:^{
        ///Set the ILI(isLoggedIn) flag to YES
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(YES) forKey:kIsLoggedIn];
        [defaults synchronize];
        
        [weakSelf showMainInterface];
        
        [weakSelf setCurrentUserOnInstallation];
        
        ///fetch alert from server as well, whenever user login
        [weakSelf fetchAlerts];
        
        [weakSelf setInitialSettings];
        
#if FB_ENABLED
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        if([PFFacebookUtils isLinkedWithUser:currentUser] && [C411StaticHelper getSignUpTypeOfUser:currentUser] != SignUpTypeFacebook){
            
            ///user logged in as email user and is linked with facebook, so validate it's token
            [weakSelf validateFBAccessToken];
        }
        
#endif

    }];
    
}

-(void)performPostSignupTaskForUserWithSignupType:(SignUpType)signUpType
{
    __weak typeof(self) weakSelf = self;
    [self handleAccountActivationWithCompletion:^{
        ///Set the ILI(isLoggedIn) flag to YES
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(YES) forKey:kIsLoggedIn];
        [defaults synchronize];
        
        PFUser *currentUser = [PFUser currentUser];
        [weakSelf showMainInterface];
        
        [weakSelf setCurrentUserOnInstallation];
        
        [weakSelf setInitialSettings];
        
        ///Fetch friend Invites alerts and show to user
        [weakSelf fetchFriendInviteRequests];
        
    }];
    
}

-(void)logUserToCrashlytics
{

    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        [CrashlyticsKit setUserIdentifier:currentUser.objectId];
        [CrashlyticsKit setUserName:currentUser.username];

    }

}

#if IS_CONTACTS_SYNCING_ENABLED

-(void)sendJoinedNotification
{
    
    [C411StaticHelper sendJoinedNotificationWithCompletion:NULL];
    
}

#endif

#if CHAT_ENABLED
+(void)logoutFromFirebase
{
    NSError *err = nil;
    [[FIRAuth auth]signOut:&err];
    if(err){
        NSLog(@"Error signing out from firebase: %@", err);
    }
}
#endif

-(void) checkPrivacyPolicyUpdate
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if(currentUser){
        ///Fetch latest Privacy Policy data
        PFQuery *fetchLatestPrivacyPolicyQuery = [PFQuery queryWithClassName:kPrivacyPolicyClassNameKey];
        [fetchLatestPrivacyPolicyQuery orderByDescending:@"createdAt"];
        [fetchLatestPrivacyPolicyQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(!error && object){
                PFObject *privacyPolicy = object;
                ///Check if user accepted this privacy policy or not
                PFQuery *fetchUserConsentQuery = [PFQuery queryWithClassName:kUserConsentClassNameKey];
                [fetchUserConsentQuery whereKey:kUserConsentUserIdKey equalTo:currentUser.objectId];
                [fetchUserConsentQuery whereKey:kUserConsentPrivacyPolicyIdKey equalTo:privacyPolicy.objectId];
                [fetchUserConsentQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if(!error && object){
                        ///User has already accepted this privacy policy
                    }
                    else if (error.domain == PFParseErrorDomain && error.code == kPFErrorObjectNotFound){
                        ///User has not accepted this privacy policy yet, show the privacy policy screen
                        C411PrivacyPolicyVC *privacyPolicyVC = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"C411PrivacyPolicyVC"];
                        privacyPolicyVC.strPrivacyPolicyId = privacyPolicy.objectId;
                        privacyPolicyVC.strPrivacyPolicyUrl = privacyPolicy[kPrivacyPolicyUrlKey];
                        privacyPolicyVC.strTermsAndConditionsUrl = privacyPolicy[kPrivacyPolicyTermsOfServiceUrlKey];
                        [self.window.rootViewController presentViewController:privacyPolicyVC animated:YES completion:NULL];
                    }
                    else{
                        ///Some error occured fetching user consent
                        NSLog(@"Error fetching user consent:%@",error);
                    }
                }];
            }
            else{
                ///Some error occured fetching privacy policy data
                NSLog(@"Error fetching privacy policy data:%@",error);
            }
        }];
    }
    
}

#if APP_RO112
-(void)checkForAccountActivation {
    PFUser *currentUser = [PFUser currentUser];///It has to be currentUser from parse
    if(currentUser){
        BOOL shouldCheckIsActive = YES;
#if PHONE_VERIFICATION_ENABLED
        ///Check if current user has phone number set and it's verified or not
        BOOL isPhoneVerified = [currentUser[kUserPhoneVerifiedKey]boolValue];
        ///Check for account activation only if phone is verified
        shouldCheckIsActive = isPhoneVerified ? YES : NO;
#endif
        if(shouldCheckIsActive){
            UIView *vuSnapshot = nil;
            if(![self canShowMainInterface]) {
                ///Show launch screen view until we fetch the current user
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RO112_LaunchScreen" bundle:[NSBundle mainBundle]];
                UIViewController *initialVC = [storyBoard instantiateInitialViewController];
                vuSnapshot = initialVC.view;
                UIViewController *rootVC = self.window.rootViewController;
                [rootVC.view addSubview:vuSnapshot];

            }
            __weak typeof(self) weakSelf = self;
            [currentUser fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if(!error){
                    BOOL isActive = [currentUser[kUserIsActiveKey]boolValue];
                    if(!isActive){
                        ///Set the ILI(isLoggedIn) flag to NO and show account activation screen
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:@(NO) forKey:kIsLoggedIn];
                        [defaults synchronize];
                        
                        [weakSelf handleAccountActivationWithCompletion:^{
                            [weakSelf performPostLoginTask];
                        }];
                    }
                    else if(![weakSelf canShowMainInterface]){
                        ///Show main interface if not visible
                        [weakSelf performPostLoginTask];
                    }
                    
                }
                else{
                    ///Remove the snapshot view
                    [vuSnapshot removeFromSuperview];
                }
            }];
        }
        
    }
}
#endif

-(void)handleAccountActivationWithCompletion:(SuccessCompletionHandler)completion {
#if APP_RO112
    ///Get the current user
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser){
        ///Check whether account is activated or not
        BOOL isActive = [currentUser[kUserIsActiveKey]boolValue];
        if(isActive) {
            ///User is logged in and account is activated
            if(completion != NULL) {
                ///Call the completion Block
                completion();
            }
        }
        else{
            ///Logout current user
            [self performLogoutAndDoCleanup];
            
            ///Show the activate acoount screen
            UIViewController *rootVC = self.window.rootViewController;
            C411ActivateAccountVC *activateAccountVC = [rootVC.storyboard instantiateViewControllerWithIdentifier:@"C411ActivateAccountVC"];
//            activateAccountVC.activationCompletionHandler = ^{
//                if(completion != NULL) {
//                    ///Call the completion Block
//                    completion();
//                }
//            };
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                [rootVC presentViewController:activateAccountVC animated:YES completion:NULL];
            }];
            
        }
    }
    else{
        ///User is not logged in or sign up
        if(completion != NULL) {
            ///Call the completion Block
            completion();
        }
    }
#else
    if(completion != NULL) {
        ///Call the completion Block
        completion();
    }
#endif
    
}

//****************************************************
#pragma mark - Public Methods
//****************************************************

-(void)userDidLogin
{
#if PHONE_VERIFICATION_ENABLED
    
    ///Check if current user has phone number set and it's verified or not
    PFUser *currentUser = [PFUser currentUser];
    NSString *strMobileNumber = currentUser[kUserMobileNumberKey];
    BOOL isPhoneVerified = [currentUser[kUserPhoneVerifiedKey]boolValue];
    if (isPhoneVerified) {
        
        ///Phone number is already verified so perform post login task
        [self performPostLoginTask];

    }
    else{
        
        ///Show edit phone screen to update and verify phone
        UINavigationController *rootNavC = (UINavigationController *)self.window.rootViewController;
        C411AddPhoneVC *updatePhoneVC = [rootNavC.storyboard instantiateViewControllerWithIdentifier:@"C411AddPhoneVC"];
        updatePhoneVC.strContactNumber = strMobileNumber;
        updatePhoneVC.inEditMode = YES;
        __weak typeof(self) weakSelf = self;
        updatePhoneVC.verificationCompletionHandler = ^{
            
            [weakSelf performPostLoginTask];
            
#if IS_CONTACTS_SYNCING_ENABLED
            ///Call the cloud function to send joined notification
            [weakSelf sendJoinedNotification];
#endif

        };
        [rootNavC pushViewController:updatePhoneVC animated:YES];
    }
    
#else
    
    [self performPostLoginTask];

#endif
}

-(void)userDidCreatedAccountWithSignUpType:(SignUpType)signUpType
{
    ///save FIRST privilege on account creation
    PFUser *currentUser = [PFUser currentUser];///This should be fetched from parse only as it is created at the time of signup and before setting isLoggedIn flag

    [C411StaticHelper savePrivilege:kPrivilegeTypeFirst forUser:currentUser withOptionalCompletion:NULL];
    [[C411AppDefaults sharedAppDefaults]createDefaultCells];
    
#if PHONE_VERIFICATION_ENABLED
    
    ///Check if current user has phone number set and it's verified or not
    NSString *strMobileNumber = currentUser[kUserMobileNumberKey];
    UINavigationController *rootNavC = (UINavigationController *)self.window.rootViewController;
    __weak typeof(self) weakSelf = self;

    if (signUpType == SignUpTypeFacebook) {
        
        ///Show edit phone screen to update and verify phone
        C411AddPhoneVC *updatePhoneVC = [rootNavC.storyboard instantiateViewControllerWithIdentifier:@"C411AddPhoneVC"];
        updatePhoneVC.strContactNumber = strMobileNumber;
        updatePhoneVC.inEditMode = YES;
        updatePhoneVC.verificationCompletionHandler = ^{
            
            [weakSelf performPostSignupTaskForUserWithSignupType:signUpType];
            
#if IS_CONTACTS_SYNCING_ENABLED
            ///Call the cloud function to send joined notification
            [weakSelf sendJoinedNotification];
#endif
        };
        [rootNavC pushViewController:updatePhoneVC animated:YES];

        
    }
    else{
        
        ///Show phone verification screen to verify phone
        C411PhoneVerificationVC *phoneVerificationVC = [rootNavC.storyboard instantiateViewControllerWithIdentifier:@"C411PhoneVerificationVC"];
        phoneVerificationVC.strContactNumber = strMobileNumber;
        phoneVerificationVC.verificationCompletionHandler = ^{
            
            [weakSelf performPostSignupTaskForUserWithSignupType:signUpType];
            
#if IS_CONTACTS_SYNCING_ENABLED
            ///Call the cloud function to send joined notification
            [weakSelf sendJoinedNotification];
#endif
            
        };
        [rootNavC pushViewController:phoneVerificationVC animated:YES];

        
    }

    
#else
    
    [self performPostSignupTaskForUserWithSignupType:signUpType];
    
#endif

}

-(void)performLogoutAndDoCleanup
{
#if FB_ENABLED
    ///remove current access token if facebook is linked
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        [[PFFacebookUtils facebookLoginManager]logOut];
        //[FBSDKAccessToken setCurrentAccessToken:nil];
        
    }
    
#endif
    
    [PFUser logOutInBackground];
    ///remove user object from installation object
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObjectForKey:kInstallationUserKey];
    [currentInstallation saveEventually];
    
    ///Clear cell and friends data saved in singleton
    [[C411AppDefaults sharedAppDefaults]clearUserData];
    
    ///Reset Panic Settings
    [C411PanicAlertSettings removeSavedSettings];
    
    ///Reset Alert Settings
    [C411AlertSettings removeSavedSettings];

#if CHAT_ENABLED
    ///Reset Recent Chats data
    [C411ChatHelper clearRecentChatsData];
    [[self class] logoutFromFirebase];
#endif
    
#if NOTIFICATION_ACK_ENABLED
    
    ///Reset Notification acknowledgement data
    [C411AlertHelper clearNotificationAckData];
    
#endif
    
    ///Lastly, set the ILI(isLoggedIn) flag to NO
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(NO) forKey:kIsLoggedIn];
    [defaults synchronize];

}

-(void)userDidLogout
{
    [self showWelcomeGalleryScreen];

    [self performLogoutAndDoCleanup];
}

+(instancetype)sharedInstance
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+(PFUser *)getLoggedInUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (![defaults objectForKey:kIsLoggedIn]) {
        ///set the isLoggedIn flag as it's not set yet
        PFUser *currentUser = [PFUser currentUser];
        if(currentUser){
            
            ///Set the ILI(isLoggedIn) flag to YES
            [defaults setObject:@(YES) forKey:kIsLoggedIn];
            
            
        }
        else{
            
            ///Set the ILI(isLoggedIn) flag to NO
            [defaults setObject:@(NO) forKey:kIsLoggedIn];
            
            
        }
        
        [defaults synchronize];
        
        return currentUser;
    }
    else{
        ///Get the isLoggedIn flag value and return current user only if it's YES
        BOOL isLoggedIn = [[defaults objectForKey:kIsLoggedIn]boolValue];
        if(isLoggedIn)
        {
            return [PFUser currentUser];
        }

    }

    return nil;
}

-(void)getCurrentUserSpammedByMembersWithCompletion:(C411ResultBlock)completion
{
    
    ///Get spammedBy relation members of current user
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        PFRelation *getSpammedByRelation = [currentUser relationForKey:kUserSpammedByKey];
        [[getSpammedByRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (completion) {
                completion(objects,error);
            }
            
            
        }];
        
        
    }
    else{
        
        ///Current user doesn't exist
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"Cell411ErrorDomain" code:-1001 userInfo:@{@"error":NSLocalizedString(@"User must be logged in", nil)}];
            completion(nil,error);
        }
        
    }
    
    
    
}


-(void)getUsersSpammedByCurrentUserWithCompletion:(C411ResultBlock)completion
{
    ///Get spamUsers relation members of current user
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        PFRelation *getSpamUsersRelation = [currentUser relationForKey:kUserSpamUsersKey];
        [[getSpamUsersRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (completion) {
                completion(objects,error);
            }
            
            
        }];
        
        
    }
    else{
        
        ///Current user doesn't exist
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"Cell411ErrorDomain" code:-1001 userInfo:@{@"error":NSLocalizedString(@"User must be logged in", nil)}];
            completion(nil,error);
        }
        
    }
    
    
}

-(void)didCurrentUserSpammedUserWithId:(NSString *)strUserId andCompletion:(C411SpamStatusBlock)completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        [self getUsersSpammedByCurrentUserWithCompletion:^(id result, NSError *error) {
            
            if (!error) {
                
                ///Got members spammed by current user successfully
                NSArray *arrSpamUsers = (NSArray *)result;
                
                ///Iterate the array and check whether provided user is spammed by current user
                SpamStatus status = SpamStatusIsNotSpammed;
                
                for (PFUser *user in arrSpamUsers) {
                    
                    if ([user.objectId isEqualToString:strUserId]) {
                        ///Yes the given user with strUserId exist is current user's spamUsers list hence provided user is spammed by current user
                        status = SpamStatusIsSpammed;
                        break;
                    }
                    
                }
                
                ///Send the spam status
                if (completion) {
                    completion(status,nil);
                }
                
            }
            else{
                
                ///Some error occured
                
                if (completion) {
                    completion(SpamStatusUnknown,error);
                }
            }
            
        }];
        
        
    }
    else{
        
        ///Current user doesn't exist
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"Cell411ErrorDomain" code:-1001 userInfo:@{@"error":NSLocalizedString(@"User must be logged in", nil)}];
            completion(SpamStatusUnknown,error);
        }
        
    }
    
}


-(void)didCurrentUserSpammedByUserWithId:(NSString *)strUserId andCompletion:(C411SpamStatusBlock)completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        [self getCurrentUserSpammedByMembersWithCompletion:^(id result, NSError *error) {
            
            if (!error) {
                
                ///Got spam members successfully
                NSArray *arrSpammedByMembers = (NSArray *)result;
                
                ///Iterate the array and check whether current user is spammed by provided user
                SpamStatus status = SpamStatusIsNotSpammed;
                
                for (PFUser *user in arrSpammedByMembers) {
                    
                    if ([user.objectId isEqualToString:strUserId]) {
                        ///Yes the given user with strUserId exist is current user's spammedBy members hence current user is spammed by this user
                        status = SpamStatusIsSpammed;
                        break;
                    }
                    
                }
                
                ///Send the spam status
                if (completion) {
                    completion(status,nil);
                }
                
            }
            else{
                
                ///Some error occured
                
                if (completion) {
                    completion(SpamStatusUnknown,error);
                }
            }
            
        }];
        
        
    }
    else{
        
        ///Current user doesn't exist
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"Cell411ErrorDomain" code:-1001 userInfo:@{@"error":NSLocalizedString(@"User must be logged in", nil)}];
            completion(SpamStatusUnknown,error);
        }
        
    }
    
}

-(void)didCurrentUserSpammedByUserWithEmail:(NSString *)strEmail andCompletion:(C411SpamStatusBlock)completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        [self getCurrentUserSpammedByMembersWithCompletion:^(id result, NSError *error) {
            
            if (!error) {
                
                ///Got spam members successfully
                NSArray *arrSpammedByMembers = (NSArray *)result;
                
                ///Iterate the array and check whether current user is spammed by provided user
                SpamStatus status = SpamStatusIsNotSpammed;
                
                for (PFUser *user in arrSpammedByMembers) {
                    
                    if ([user.username.lowercaseString isEqualToString:strEmail.lowercaseString]
                        ||[user.email.lowercaseString isEqualToString:strEmail.lowercaseString]) {
                        ///Yes the given user with strUsername exist is current user's spammedBy members hence current user is spammed by this user
                        status = SpamStatusIsSpammed;
                        break;
                    }
                    
                }
                
                ///Send the spam status
                if (completion) {
                    completion(status,nil);
                }
                
            }
            else{
                
                ///Some error occured
                
                if (completion) {
                    completion(SpamStatusUnknown,error);
                }
            }
            
        }];
        
        
    }
    else{
        
        ///Current user doesn't exist
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"Cell411ErrorDomain" code:-1001 userInfo:@{@"error":NSLocalizedString(@"User must be logged in", nil)}];
            completion(SpamStatusUnknown,error);
        }
        
    }
    
}


-(void)filteredArrayByRemovingMembersInSpammedByRelationFromArray:(NSArray *)arrMembers withCompletion:(C411ResultBlock)completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        
        [self getCurrentUserSpammedByMembersWithCompletion:^(id result, NSError *error) {
            
            if (!error) {
                
                ///Got spammedBy members successfully
                NSArray *arrSpammedByMembers = (NSArray *)result;
                
                ///Iterate the members array and check whether they are in the arrSpammedByMembers, if No add it to new array
                NSMutableArray *arrFilteredMembers = [NSMutableArray array];
                for (PFUser *member in arrMembers) {
                    
                    SpamStatus status = SpamStatusIsNotSpammed;
                    
                    for (PFUser *user in arrSpammedByMembers) {
                        
                        if ([user.objectId isEqualToString:member.objectId]) {
                            ///Yes the current iterating member exist in current user's spammedBy members
                            status = SpamStatusIsSpammed;
                            break;
                        }
                        
                    }
                    
                    if (status == SpamStatusIsNotSpammed) {
                        ///add the member in new array which is not in spammedByMember list
                        [arrFilteredMembers addObject:member];
                        
                    }
                    
                    
                }
                
                ///Send the filtered members
                if (completion) {
                    completion(arrFilteredMembers,nil);
                }
                
            }
            else{
                
                ///Some error occured
                
                if (completion) {
                    completion(arrMembers,error);
                }
            }
            
        }];
        
        
    }
    else{
        
        ///Current user doesn't exist
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"Cell411ErrorDomain" code:-1001 userInfo:@{@"error":NSLocalizedString(@"User must be logged in", nil)}];
            completion(arrMembers,error);
        }
        
    }
    
}

-(void)filteredArrayByRemovingMembersInSpammedUsersRelationFromArray:(NSArray *)arrMembers withCompletion:(C411ResultBlock)completion
{
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    if (currentUser) {
        [self getUsersSpammedByCurrentUserWithCompletion:^(id result, NSError *error) {
            
            if (!error) {
                
                ///Got spammedUsers members successfully
                NSArray *arrSpammedUsers = (NSArray *)result;
                
                ///Iterate the members array and check whether they are in the arrSpammedUsers, if No add it to new array
                NSMutableArray *arrFilteredMembers = [NSMutableArray array];
                for (PFUser *member in arrMembers) {
                    
                    SpamStatus status = SpamStatusIsNotSpammed;
                    
                    for (PFUser *user in arrSpammedUsers) {
                        
                        if ([user.objectId isEqualToString:member.objectId]) {
                            ///Yes the current iterating member exist in current user's spammedUsers members
                            status = SpamStatusIsSpammed;
                            break;
                        }
                        
                    }
                    
                    if (status == SpamStatusIsNotSpammed) {
                        ///add the member in new array which is not in spammedUsers list
                        [arrFilteredMembers addObject:member];
                        
                    }
                    
                    
                }
                
                ///Send the filtered members
                if (completion) {
                    completion(arrFilteredMembers,nil);
                }
                
            }
            else{
                
                ///Some error occured
                
                if (completion) {
                    completion(arrMembers,error);
                }
            }
            
        }];
        
        
    }
    else{
        
        ///Current user doesn't exist
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"Cell411ErrorDomain" code:-1001 userInfo:@{@"error":NSLocalizedString(@"User must be logged in", nil)}];
            completion(arrMembers,error);
        }
        
    }
    
}


+(void)showToastOnView:(UIView *)view withMessage:(NSString *)strMessage
{
    UIView *toastSuperView = view ? view : [AppDelegate sharedInstance].window.rootViewController.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:toastSuperView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = strMessage;
    hud.labelFont = [UIFont boldSystemFontOfSize:10.f];
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.opacity = 0.6f;
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:3];
}

+(BOOL)handleParseError:(NSError *)error
{
    if (error.domain == PFParseErrorDomain) {
        
        if ((error.code == kPFErrorInvalidSessionToken)
            ||(error.code == kPFErrorUserCannotBeAlteredWithoutSession)) {
            ///Return Yes as it's handled
            [self handleInvalidSessionTokenError];
            return YES;
        }
        else{
            ///Retrun NO as it's not an error that we are handling
            return NO;
        }
    }
    else{
        ///Retrun NO as it's not a Parse error
        return NO;
    }
}

+(void)handleInvalidSessionTokenError
{
    
    ///Perform logout operation without showing welcome screen first
    [[AppDelegate sharedInstance]performLogoutAndDoCleanup];
    NSString *strMsg = NSLocalizedString(@"We are sorry, you have been logged out, please login again.", nil);
#if DEBUG
    ///Append Stack trace as well
    strMsg = [strMsg stringByAppendingFormat:@"\n---STACK TRACE---\n%@",[NSThread callStackSymbols]];
    
#endif
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Session Expired", nil) message:strMsg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///Show welcome screen on OK action
        [[AppDelegate sharedInstance]showWelcomeGalleryScreen];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]removeAllAlertsFromQueue];

        
    }];
    
    [alertController addAction:okAction];
    //[[AppDelegate sharedInstance].window.rootViewController presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

}

#if CHAT_ENABLED
+(void)logUserToFirebaseWithCompletion:(C411ResultBlock)completion
{
    [[FIRAuth auth]signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error signing to Firebase:%@",error);
        }
        if(completion != NULL){
            completion(authResult, error);
        }
    }];
}
#endif


//****************************************************
#pragma mark - Remote Notifications Setup
//****************************************************

-(void)setupRemoteNotifications
{
    ///RegisterRemoteNotification settings

//    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
//    return;
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            // For iOS 10 display notification (sent via APNS)
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
                
            }];
            
#endif
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }

}

//****************************************************
#pragma mark - Push Notifications
//****************************************************

//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
//    //register to receive notifications
//    [application registerForRemoteNotifications];
//}
//
////For interactive notification only
//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
//{
//    //handle the actions
//    if ([identifier isEqualToString:@"declineAction"]){
//    }
//    else if ([identifier isEqualToString:@"answerAction"]){
//    }
//}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSLog(@"My token is: %@", deviceToken);
    
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    [currentInstallation saveInBackground];
    
    //    NSString* token = [[[[deviceToken description]stringByReplacingOccurrencesOfString: @"<" withString: @""]stringByReplacingOccurrencesOfString: @">" withString: @""]stringByReplacingOccurrencesOfString: @" " withString: @""];
    //    NSLog(@"%@",token);
    //    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //    [defaults setObject:token forKey:@"deviceToken"];
    //    [defaults synchronize];
    //[C411StaticHelper showAlertWithTitle:nil message:[NSString stringWithFormat:@"Registered remote notification with device token:%@",deviceToken] onViewController:self.window.rootViewController];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"Failed to get token, error: %@", error);
    //[C411StaticHelper showAlertWithTitle:nil message:[NSString stringWithFormat:@"Failed to get token, error: %@", error] onViewController:self.window.rootViewController];

}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    ///called upto iOS 9
    NSLog(@"Recieved push notifications");
    NSLog(@"%@",[userInfo description]);
    [self processNotificationUserInfo:userInfo];
    [self resetBadgeAndNotificationsFromTray];
    
    
    /*
     if ( application.applicationState == UIApplicationStateActive )
     {
     // app was already in the foreground
     
     //        [self showMessage:[[userInfo objectForKey:@"aps"]objectForKey:@"alert"] withTitle:@"New Notification" cancelButtonTitle:@"OK" otherButtonTitles:nil];
     }
     else
     {
     // app was just brought from background to foreground
     }
     */
    
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /*
    ///For silent notification
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // Handle data of notification
    return;
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"%@",[userInfo description]);

    BOOL isSilentNotification = [[[userInfo objectForKey:@"aps"]objectForKey:@"content-available"]integerValue] == 1;
    if (isSilentNotification) {
        
        ///Hanlde this silent notification
        NSString *alertType = userInfo[kPayloadAlertTypeKey];

        if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeMessage.lowercaseString]){

#if CHAT_ENABLED
             ///Handle silent notification for Chat Message
            [[C411ChatManager sharedInstance]handleSilentNotification:userInfo withFetchCompletionHandler:completionHandler];
#endif
            
        }
        
    }
    else{
        
        ///It could be some other notification, process it though it could be very rare
        [self processNotificationUserInfo:userInfo];
        [self resetBadgeAndNotificationsFromTray];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    */
    

}

// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSLog(@"%@",[notification description]);
    [self resetBadgeAndNotificationsFromTray];

    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    
        NSDictionary *dictUserInfo = notification.request.content.userInfo;
        NSString *alertType = dictUserInfo[kPayloadAlertTypeKey];
        if ([alertType.lowercaseString isEqualToString:kPayloadAlertTypeMessage.lowercaseString]){
#if CHAT_ENABLED

            ///Post notification to refresh recent chats
            [[NSNotificationCenter defaultCenter]postNotificationName:kNewChatMessageArrivedNotification object:nil];
            
            
            UINavigationController *rootNavC = (UINavigationController *)self.window.rootViewController;
            UIViewController *visibleVC = [rootNavC.viewControllers lastObject];
            if ([visibleVC isKindOfClass:[C411ChatVC class]]) {
                
                C411ChatVC *visibleChatVC = (C411ChatVC *)visibleVC;
                if (![visibleChatVC.strEntityId isEqualToString:dictUserInfo[kPayloadChatEntityObjectIdKey]]) {
                    
                    ///Show the notification as user is not on this chat
                    // Change this to your preferred presentation option
                    completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
                }
                else{
                    
                    // Change this to your preferred presentation option
                    completionHandler(UNNotificationPresentationOptionNone);
                }
                
            }
            else{
                
                ///Show the notification as user is not on this chat
                // Change this to your preferred presentation option
                completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
            }

            
#endif
            

        }
        else{
            
            [self processNotificationUserInfo:notification.request.content.userInfo];
            // Change this to your preferred presentation option
            completionHandler(UNNotificationPresentationOptionNone);

        }
            
    
    }
    

    
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    
    if ([response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier]) {
        // The user dismissed the notification without taking action.
    }
    else{
        
        ///The user tapped on custom action or default action
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        NSLog(@"Custom Action:%s",__PRETTY_FUNCTION__);
        NSLog(@"%@",[userInfo description]);
        NSString *notifId = response.notification.request.identifier;
        if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            
            
            ///User tapped on a remote notification
            [self processNotificationUserInfo:userInfo];
            
        }
        else{
            
//            else if ([notifId isEqualToString:[NSString stringWithFormat:@"%@%@",kLocalNotificationIdentifier,kChatMessageLocalNotifIdentifier]]) {
//                
//                ///User tapped on Chat Message local notification
//                NSLog(@"User tapped on Chat Message local notification");
//                
//                if([AppDelegate getLoggedInUser]){
//                
//                    UINavigationController *rootNavC = self.window.rootViewController;
//                    UIViewController *rootVC = [rootNavC.viewControllers firstObject];
//                    rootVC.tabBarController.selectedIndex = 4;
//                
//                }
//            }
            
        }
        
       
        [self resetBadgeAndNotificationsFromTray];

    }
    
    completionHandler();
}
#endif
// [END ios_10_message_handling]

//****************************************************
#pragma mark - Local Notifications
//****************************************************

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        //[C411StaticHelper showAlertWithTitle:@"recieve from delegate BG" message:notification.alertBody onViewController:self.window.rootViewController];

    }
    else{
        
        //[C411StaticHelper showAlertWithTitle:@"recieve from delegate active" message:notification.alertBody onViewController:self.window.rootViewController];
        NSLog(@"recieve from delegate FG");

    }
}

@end
