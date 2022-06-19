//
//  C411EmergencyAlertPopup.h
//  cell411
//
//  Created by Milan Agarwal on 10/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C411AlertNotificationPayload.h"
#import "Constants.h"
#import "C411PopupBaseView.h"

@interface C411EmergencyAlertPopup : C411PopupBaseView

@property (nonatomic, strong) PFObject *cell411Alert;
@property (nonatomic, strong) PFUser *alertIssuer;
@property (nonatomic, assign) BOOL canRespondToAlert;

///this should be the last property(or second last if you prefer to set actionHandler in last) to be set as the initialization code is written on this setter
@property (nonatomic, strong) C411AlertNotificationPayload *alertPayload;
@property (nonatomic, copy) popupActionHandler actionHandler;

@end
