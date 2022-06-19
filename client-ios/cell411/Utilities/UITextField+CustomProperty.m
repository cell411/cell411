//
//  UITextField+CustomProperty.m
//  cell411
//
//  Created by Milan Agarwal on 21/02/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "UITextField+CustomProperty.h"
#import <objc/runtime.h>

@implementation UITextField (CustomProperty)

static char UITF_ALERT_KEY;

@dynamic alert;

-(void)setAlert:(C411Alert *)alert
{
    objc_setAssociatedObject(self, &UITF_ALERT_KEY, alert, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(C411Alert *)alert
{
    return (C411Alert *)objc_getAssociatedObject(self, &UITF_ALERT_KEY);
}



@end
