//
//  AppDelegate.h
//  cell411
//
//  Created by Milan Agarwal on 15/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C411Enums.h"
@class PFUser;

typedef enum{
    
    SpamStatusUnknown = 0,
    SpamStatusIsSpammed,
    SpamStatusIsNotSpammed
}SpamStatus;


typedef void(^C411SpamStatusBlock)(SpamStatus status,NSError *error);
typedef void(^C411ResultBlock)(id result,NSError *error);

@interface UIDevice (OrientationSupport)
-(void)setOrientation:(UIInterfaceOrientation)orientation;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

///Helper property to rotate a video broadcasting VC
@property (assign, nonatomic) BOOL shouldRotate;

@property (copy, nonatomic) void (^backgroundSessionCompletionHandler)();

///Will hold Yes if app is launched due to location update recieved for significant change location service and UIApplicationLaunchOptionsLocationKey is available in launchOptions dictionary of application: didFinishLaunchingWithOptions: method
@property (nonatomic, assign, getter=isLocationAvailableInLaunchOptions) BOOL locationAvailableInLaunchOptions;

-(void)userDidLogin;
-(void)userDidCreatedAccountWithSignUpType:(SignUpType)signUpType;
-(void)userDidLogout;
+(instancetype)sharedInstance;
+(PFUser *)getLoggedInUser;
-(void)getCurrentUserSpammedByMembersWithCompletion:(C411ResultBlock)completion;
-(void)getUsersSpammedByCurrentUserWithCompletion:(C411ResultBlock)completion;
-(void)didCurrentUserSpammedUserWithId:(NSString *)strUserId andCompletion:(C411SpamStatusBlock)completion;
-(void)didCurrentUserSpammedByUserWithId:(NSString *)strUserId andCompletion:(C411SpamStatusBlock)completion;
-(void)didCurrentUserSpammedByUserWithEmail:(NSString *)strEmail andCompletion:(C411SpamStatusBlock)completion;

///It will return the filtered array by removing the members in the provided array which exist in current user's spammedBy relation, if any error occurs it will return the same array with error
-(void)filteredArrayByRemovingMembersInSpammedByRelationFromArray:(NSArray *)arrMembers withCompletion:(C411ResultBlock)completion;
///It will return the filtered array by removing the members in the provided array which exist in current user's spamUsers relation, if any error occurs it will return the same array with error
-(void)filteredArrayByRemovingMembersInSpammedUsersRelationFromArray:(NSArray *)arrMembers withCompletion:(C411ResultBlock)completion;
+(void)showToastOnView:(UIView *)view withMessage:(NSString *)strMessage;
+(BOOL)handleParseError:(NSError *)error;
#if CHAT_ENABLED
+(void)logUserToFirebaseWithCompletion:(C411ResultBlock)completion;
#endif

@end

