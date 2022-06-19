//
//  CellsDelegate.h
//  cell411
//
//  Created by Milan Agarwal on 18/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

@protocol CellsDelegate <NSObject>

@property(nonatomic, readonly) NSArray *arrCells;

-(void)addCell:(id)cell;
-(void)removeCellAtIndex:(NSUInteger)index;

@optional
-(void)updateCells;
//-(void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath;


@end
