//
//  C411InviteVC.h
//  cell411
//
//  Created by Milan Agarwal on 28/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportContactsDelegate.h"

@interface C411InviteVC : UIViewController

@property (nonatomic, assign) id<ImportContactsDelegate> importContactsDelegate;

@end
