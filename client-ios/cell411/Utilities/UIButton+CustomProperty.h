//
//  UIButton+CustomProperty.h
//  UMNO
//
//  Created by Milan Agarwal on 06/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsData.h"

@interface UIButton (CustomProperty)
@property (nonatomic, strong) ContactsData *contact;
@end
