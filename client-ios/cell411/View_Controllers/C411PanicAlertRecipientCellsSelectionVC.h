//
//  C411PanicAlertRecipientSelectionVC.h
//  cell411
//
//  Created by Milan Agarwal on 30/08/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAGBackActionCallbackVC.h"
@class C411PanicAlertRecipientCellsSelectionVC;

typedef enum {
    
    CellSelectionTypePublic = 0,
    CellSelectionTypePrivate,
    CellSelectionTypeNau
    
}CellSelectionType;

@protocol C411PanicAlertRecipientCellsSelectionVCDelegate <NSObject>

-(void)cellSelectionVCDidTapBack:(C411PanicAlertRecipientCellsSelectionVC *)recipientCellsSelectionVC;

@end

@interface C411PanicAlertRecipientCellsSelectionVC : MAGBackActionCallbackVC

@property (nonatomic, assign) CellSelectionType cellSelectionType;
@property (nonatomic, strong) NSMutableArray *arrSelectedCells;
@property (nonatomic, assign) id<C411PanicAlertRecipientCellsSelectionVCDelegate> delegate;


@end
