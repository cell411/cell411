//
//  C411RideRequestPopup.h
//  cell411
//
//  Created by Milan Agarwal on 04/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C411AlertNotificationPayload.h"
#import "Constants.h"
#import "C411PopupBaseView.h"

@interface C411RideRequestPopup : C411PopupBaseView

///this should be the last property(or second last if you prefer to set actionHandler in last) to be set as the initialization code is written on this setter
@property (nonatomic, strong) C411AlertNotificationPayload *alertPayload;
@property (nonatomic, copy) popupActionHandler actionHandler;
@property (nonatomic, assign,getter=shouldShowNevermindAsClose) BOOL showNevermindAsClose;
@end
