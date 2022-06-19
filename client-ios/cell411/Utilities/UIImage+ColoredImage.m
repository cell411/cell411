//
//  UIImage+ColoredImage.m
//  cell411
//
//  Created by Milan Agarwal on 17/07/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "UIImage+ColoredImage.h"

@implementation UIImage (ColoredImage)
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end
