//
//  C411UserProfilePopup.h
//  cell411
//
//  Created by Milan Agarwal on 11/05/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C411PopupBaseView.h"
#import "Constants.h"

@class PFUser;

@interface C411UserProfilePopup : C411PopupBaseView

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, copy) popupActionHandler actionHandler;

@end
