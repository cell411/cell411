//
//  C411PvtCellMembersSelectionVC.h
//  cell411
//
//  Created by Milan Agarwal on 03/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol C411PvtCellMembersSelectionVCDelegate <NSObject>

-(void)didSelectMembers:(NSArray *)arrSelectedMembers ForCell:(PFObject *)C411Cell;

@end

@interface C411PvtCellMembersSelectionVC : UIViewController

@property (nonatomic, weak) PFObject *myPrivateCell;

@property (nonatomic, assign) id<C411PvtCellMembersSelectionVCDelegate> membersSelectionDelegate;


@end
