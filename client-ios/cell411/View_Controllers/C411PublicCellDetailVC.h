//
//  C411PublicCellDetailVC.h
//  cell411
//
//  Created by Milan Agarwal on 02/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "C411Enums.h"
#import "PublicCellsDelegate.h"
#import "MAGBackActionCallbackVC.h"

@interface C411PublicCellDetailVC : MAGBackActionCallbackVC

@property (nonatomic, strong) PFObject *publicCellObj;
@property (nonatomic, assign, getter=isOwner) BOOL owner;
///Will contain the valid publicCellDelegate object containing array of owned cells only if owner property is YES.
@property (nonatomic, assign) id<PublicCellsDelegate> publicCellsDelegate;

//@property (nonatomic, strong) NSString *strBarBtnRightTitle;
@property (nonatomic, assign) CellMembershipStatus cellMembershipStatus;


@end
