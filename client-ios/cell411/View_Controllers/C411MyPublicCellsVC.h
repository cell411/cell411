//
//  C411MyPublicCellsVC.h
//  cell411
//
//  Created by Milan Agarwal on 29/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicCellsDelegate.h"

@interface C411MyPublicCellsVC : UIViewController

@property (nonatomic, assign) id<PublicCellsDelegate> publicCellsDelegate;

@end
