//
//  C411ImportContactsVC.h
//  cell411
//
//  Created by Milan Agarwal on 24/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewPagerController.h"
#import "ImportContactsDelegate.h"

@interface C411ImportContactsVC : ViewPagerController<ImportContactsDelegate>

#if IS_CONTACTS_SYNCING_ENABLED
@property (nonatomic, assign, getter=shouldSyncContacts) BOOL syncContacts;
///Will hold the valid value if syncContacts is YES
@property (nonatomic, weak) UIViewController *parentVC;
#endif


@end
