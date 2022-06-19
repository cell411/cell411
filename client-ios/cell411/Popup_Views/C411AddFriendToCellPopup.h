//
//  C411AddFriendToCellPopup.h
//  cell411
//
//  Created by Milan Agarwal on 10/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Constants.h"
#import "C411PopupBaseView.h"

@interface C411AddFriendToCellPopup : C411PopupBaseView

@property (nonatomic, strong) PFObject *userFriend;
@property (nonatomic, strong) NSArray *arrCellGroups;
@property (nonatomic, copy) popupActionHandler actionHandler;

-(void)setupViews;

@end
