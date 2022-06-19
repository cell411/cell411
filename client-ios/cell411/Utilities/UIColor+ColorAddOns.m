//
//  UIColor+ColorAddOns.m
//  cell411
//
//  Created by Milan Agarwal on 18/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "UIColor+ColorAddOns.h"

@implementation UIColor (ColorAddOns)

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
    return [UIColor colorWithHue:h
                      saturation:s
                      brightness:MIN(b * 1.3, 1.0)
                           alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
    return [UIColor colorWithHue:h
                      saturation:s
                      brightness:b * 0.75
                           alpha:a];
    return nil;
}

@end
