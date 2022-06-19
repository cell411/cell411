//
//  C411CellsSelectionPopup.h
//  cell411
//
//  Created by Milan Agarwal on 20/04/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C411AlertSettings;

@protocol C411CellsSelectionPopupDelegate <NSObject>
@required
-(void)incrementTotalMembersCountBy:(NSInteger)incrementVal;
-(void)decrementTotalMembersCountBy:(NSInteger)decrementVal;
@optional
-(void)cellsSelectionPopupDidTappedBack;
@end
@interface C411CellsSelectionPopup : UIView
@property (nonatomic, weak) NSArray *arrFilteredPrivateCells;
@property (nonatomic, weak) NSMutableDictionary *dictFilteredDeselectedPrivateCells;
@property (nonatomic, weak) NSMutableDictionary *dictFilteredDeselectedPublicCells;
@property (nonatomic, weak) C411AlertSettings *alertSettings;
@property (nonatomic, assign) id<C411CellsSelectionPopupDelegate> delegate;

-(void)reloadData;

@end
