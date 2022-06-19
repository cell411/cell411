//
//  C411NonAppUsersSelectionVC.h
//  cell411
//
//  Created by Milan Agarwal on 31/08/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class C411NonAppUsersSelectionVC,PFObject, C411SendAlertPopupVC, C411AlertSettings;

@protocol C411NonAppUsersSelectionVCDelegate <NSObject>

-(void)nonAppUsersSelectionVC:(C411NonAppUsersSelectionVC *)nonAppUsersSelectionVC didSelectNonAppUsers:(NSArray *)arrNonAppUsers;

@end

@interface C411NonAppUsersSelectionVC : UIViewController

@property (nonatomic, assign) id<C411NonAppUsersSelectionVCDelegate> delegate;
///Will contain a valid object if this screen is opened to update members on this Cell
@property (nonatomic, weak) PFObject *myPrivateCell;

///Will contain a valid object if this screen is opened through send alert popup
@property (nonatomic, weak) C411SendAlertPopupVC *sendAlertPopupVC;

///Will contain a valid object if this screen is opened through send alert vc
@property (nonatomic, weak) C411AlertSettings *alertSettings;

@end
