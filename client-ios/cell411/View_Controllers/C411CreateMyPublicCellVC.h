//
//  C411CreateMyPublicCellVC.h
//  cell411
//
//  Created by Milan Agarwal on 01/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicCellsDelegate.h"

@class PFObject;

@interface C411CreateMyPublicCellVC : UIViewController

@property (nonatomic, assign) id<PublicCellsDelegate> publicCellsDelegate;@property (nonatomic, assign, getter=isInEditMode) BOOL inEditMode;
///Will hold a valid object if this VC is opened in edit mode and inEditMode property is set to YES
@property (nonatomic, weak) PFObject *publicCellObj;


@end
