//
//  UIButton+CustomProperty.m
//  UMNO
//
//  Created by Milan Agarwal on 06/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "UIButton+CustomProperty.h"
#import <objc/runtime.h>

@implementation UIButton (CustomProperty)

static char UIB_CONTACT_KEY;

@dynamic contact;

-(void)setContact:(ContactsData *)contact
{
    objc_setAssociatedObject(self, &UIB_CONTACT_KEY, contact, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(ContactsData *)contact
{
    return (ContactsData*)objc_getAssociatedObject(self, &UIB_CONTACT_KEY);
}

@end
