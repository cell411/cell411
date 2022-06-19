//
//  C411ViewAlertDetailPopup.h
//  cell411
//
//  Created by Milan Agarwal on 13/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Constants.h"
#import "C411PopupBaseView.h"

@class C411ViewAlertDetailPopup;

@protocol C411ViewAlertDetailPopupDelegate <NSObject>

-(void)alertDetailPopup:(C411ViewAlertDetailPopup *)alertDetailPopup fakeDeleteVideoAtIndex:(NSInteger)rowIndex;
-(NSURL *)alertDetailPopup:(C411ViewAlertDetailPopup *)alertDetailPopup didRequireVideoURLForAlert:(PFObject *)cell411Alert;
-(void)alertDetailPopup:(C411ViewAlertDetailPopup *)alertDetailPopup downloadVideoAtIndex:(NSInteger)rowIndex;

@end

@interface C411ViewAlertDetailPopup : C411PopupBaseView

@property (nonatomic, strong) NSAttributedString *strAlertTitle;
@property (nonatomic, strong) NSString *strAlertTimestamp;
@property (nonatomic, strong) UIImage *imgAlertType;
@property (nonatomic, weak) PFObject *selectedCell411Alert;
@property (nonatomic, assign) NSInteger alertRowIndex;
@property (nonatomic, assign) id<C411ViewAlertDetailPopupDelegate> alertDetailPopupDelegate;
@property (nonatomic, copy) popupActionHandler actionHandler;

@end
