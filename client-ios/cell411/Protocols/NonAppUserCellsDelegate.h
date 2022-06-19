//
//  NonAppUserCellsDelegate.h
//  cell411
//
//  Created by Milan Agarwal on 01/09/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#if NON_APP_USERS_ENABLED
@protocol NonAppUserCellsDelegate <NSObject>

@property(nonatomic, readonly) NSArray *arrNonAppUserCells;

-(void)addNonAppUserCell:(id)NAUCell;
-(void)removeNonAppUserCellAtIndex:(NSUInteger)index;

@optional
-(void)updateNonAppUserCells;


@end
#endif
