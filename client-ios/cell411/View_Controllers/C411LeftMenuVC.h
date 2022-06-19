//
//  C411LeftMenuVC.h
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    
    LeftMenuActionMyProfileTapped = 0,
    LeftMenuActionGenerateQRCodeTapped,
    LeftMenuActionScanQRCodeTapped,
    LeftMenuActionSettingsTapped,
    LeftMenuActionNotificationsTapped,
    LeftMenuActionKnowYourRightsTapped,
    LeftMenuActionShareThisAppTapped,
    LeftMenuActionRateThisAppTapped,
    LeftMenuActionFAQTapped,
    LeftMenuActionChangePasswordTapped,
    LeftMenuActionBroadcastMessageTapped,
    LeftMenuActionAboutTapped,
    LeftMenuActionLogoutTapped
    
}LeftMenuAction;

@protocol C411LeftMenuVCActionDelegate <NSObject>

@required

///This will notify the delegate i.e Split VC of the action taken by user
-(void)userDidPerformAction:(LeftMenuAction)leftMenuAction;

@end

@interface C411LeftMenuVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *vuLeftMenuContainer;
@property (nonatomic, assign) id<C411LeftMenuVCActionDelegate> leftMenuActionDelegate;

@end
