//
//  C411UserJoinedPopup.h
//  cell411
//
//  Created by Milan Agarwal on 18/01/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C411PopupBaseView.h"
#import "Constants.h"

@class PFUser;


@interface C411UserJoinedPopup : C411PopupBaseView

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, copy) popupActionHandler actionHandler;

@end
