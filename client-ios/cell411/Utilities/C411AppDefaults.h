//
//  C411AppDefaults.h
//  cell411
//
//  Created by Milan Agarwal on 21/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendsDelegate.h"
#import "CellsDelegate.h"
#import "C411PvtCellMembersSelectionVC.h"
#if NON_APP_USERS_ENABLED
#import "NonAppUserCellsDelegate.h"
#endif

@interface C411AppDefaults : NSObject<FriendsDelegate,CellsDelegate,C411PvtCellMembersSelectionVCDelegate
#if NON_APP_USERS_ENABLED
,NonAppUserCellsDelegate
#endif
>

@property (nonatomic, strong) NSMutableArray *arrFakeDeletedVideos;

+(instancetype)sharedAppDefaults;
-(void)clearUserData;
-(void)registerForNotifications;
-(void)unregisterFromNotifications;
-(void)createDefaultCells;
-(void)addFriendWithEmailId:(NSString *)strEmailId;
-(void)sendFriendRequestToUser:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion;
-(void)inviteFriendWithEmailId:(NSString *)strEmailId shouldShowMessageOnSuccessOrError:(BOOL)showMessageOnSuccessOrError withCompletion:(PFBooleanResultBlock)completion;
-(void)sendSMSInviteToFriendWithPhoneNumber:(NSString *)strPhoneNumber withCompletion:(PFBooleanResultBlock)completion;
-(void)showUpdateEmailPopupForUser:(PFUser *)user fromViewController:(UIViewController *)viewController withCompletion:(PFBooleanResultBlock)completion;
-(void)rejectFriendRequest:(PFObject *)friendRequest withCompletion:(PFBooleanResultBlock)completion;
-(void)approveFriendRequestWithId:(NSString *)strFriendRequestId fromUserWithId:(NSString *)strUserId fullName:(NSString *)strFullName andCompletion:(PFBooleanResultBlock)completion;
-(void)getCellsInBackgroundWithBlock:(PFArrayResultBlock)completion;
-(void)getFriendsinBackgroundWithBlock:(PFArrayResultBlock)completion;
-(void)addPvtCellWithName:(NSString *)strCellName;
-(void)setCurrentUserHasSeenAlert:(PFObject *)cell411Alert;
-(BOOL)canDownloadMyData;
-(void)recordMyDataDownloadTime;



+(NSArray *)getSupportedVideoResolutions;
+(NSString *)getDefaultVideoResolution;
+(CGSize)getVideoSizeForResolution:(NSString *)strVideoResolution;
+(BOOL)canShowSecurityGuardOption;
+(BOOL)isBroadcastEnabled;
@end
