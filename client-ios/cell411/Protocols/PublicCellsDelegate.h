//
//  PublicCellsDelegate.h
//  cell411
//
//  Created by Milan Agarwal on 26/02/16.
//  Copyright (c) 2016 Milan Agarwal. All rights reserved.
//

#import <Parse/Parse.h>

@protocol PublicCellsDelegate <NSObject>

///For joined and pending cells
@property (nonatomic, readonly) NSArray *arrJoinedOrPendingCells;
-(void)getPendingOrJoinedPublicCellsWithCompletion:(PFArrayResultBlock)completion;
-(void)addObjectToPendingOrJoinedCellsArray:(PFObject *)cell411Alert;

///For owned Cells
@property (nonatomic, readonly) NSArray *arrOwnedPublicCells;
-(void)getOwnedPublicCellWithCompletion:(PFArrayResultBlock)completion;
-(void)addOwnedPublicCell:(id)cell;
-(void)removeOwnedPublicCellAtIndex:(NSUInteger)index;



@end
