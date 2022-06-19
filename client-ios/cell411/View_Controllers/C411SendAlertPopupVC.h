//
//  C411SendAlertPopupVC.h
//  cell411
//
//  Created by Milan Agarwal on 22/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class C411SendAlertPopupVC;


@protocol C411SendAlertPopupVCDelegate <NSObject>

-(void)sendAlertPopupDidSelectGlobalAlert:(C411SendAlertPopupVC *)alertPopupVC;
-(void)sendAlertPopupDidSelectAllFriends:(C411SendAlertPopupVC *)alertPopupVC;
-(void)sendAlertPopup:(C411SendAlertPopupVC *)alertPopupVC didSelectCell:(PFObject *)cell;
-(void)sendAlertPopupDidCancel:(C411SendAlertPopupVC *)alertPopupVC;

@optional


#if NON_APP_USERS_ENABLED
-(void)sendAlertPopupDidSelectNonAppUserCells:(C411SendAlertPopupVC *)alertPopupVC;
#endif

-(void)sendAlertPopupDidSelectPublicCells:(C411SendAlertPopupVC *)alertPopupVC;
-(void)sendAlertPopupDidSelectSecurityGuard:(C411SendAlertPopupVC *)alertPopupVC;

@end



@interface C411SendAlertPopupVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;

@property (nonatomic, strong) NSArray *arrCellGroups;

///Will hold valid value only if isForwardingAlert = NO
@property (nonatomic, assign) NSInteger alertType;

///Will be YES if user is forwarding the Alert
@property (nonatomic, assign, getter=isForwardingAlert) BOOL forwardingAlert;

///Will hold the data if isForwardingAlert = YES
@property (nonatomic, strong) NSDictionary *dictAlertData;

///Will hold the reference of the actual alert issuer whose alert is being forwarded by current user. Will hold valid data if isForwardingAlert = YES
@property (nonatomic, strong) PFUser *needyPerson;

///It will hold the PFObject reference of the actual cell411Alert object which can be forwarded.Will hold valid data if isForwardingAlert = YES
@property (nonatomic, strong) PFObject *cell411AlertToFwd;

@property (nonatomic, assign) id<C411SendAlertPopupVCDelegate> delegate;
@end
