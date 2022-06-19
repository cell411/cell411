//
//  MAGProgressLayer.m
//  CustomProgressBar
//
//  Created by Milan Agarwal on 26/06/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "MAGProgressLayer.h"
#import "MAGProgressView.h"

@implementation MAGProgressLayer

- (void)drawInContext:(CGContextRef)ctx
{
    // clip
    UIBezierPath *switchOutline = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                             cornerRadius:self.bounds.size.height * self.progressView.curvaceousness / 2.0];
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextClip(ctx);
    
    // 1) fill the track
    CGContextSetFillColorWithColor(ctx,self.progressView.trackTintColor.CGColor);
    CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextFillPath(ctx);
    
    // 2) fill the highlighed range
    /*CGContextSetFillColorWithColor(ctx, self.slider.trackEndHighlightColour.CGColor);
     float lower = [self.slider positionForValue:self.slider.lowerValue];
     float upper = [self.slider positionForValue:self.slider.upperValue];
     CGContextFillRect(ctx, CGRectMake(lower, 0, upper - lower, self.bounds.size.height));*/
    
    // 3) add a highlight over the track
    /*CGRect highlight = CGRectMake(cornerRadius/2, self.bounds.size.height/2,
     self.bounds.size.width - cornerRadius, self.bounds.size.height/2);
     UIBezierPath *highlightPath = [UIBezierPath bezierPathWithRoundedRect:highlight
     cornerRadius:highlight.size.height * self.slider.curvaceousness / 2.0];
     CGContextAddPath(ctx, highlightPath.CGPath);
     CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.4].CGColor);
     CGContextFillPath(ctx);*/
    
    // 4) inner shadow
    /*CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2.0), 3.0, [UIColor grayColor].CGColor);
     CGContextAddPath(ctx, switchOutline.CGPath);
     CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
     CGContextStrokePath(ctx);*/
    
    // 5) outline the track
    /*CGContextAddPath(ctx, switchOutline.CGPath);
     CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
     CGContextSetLineWidth(ctx, 0.5);
     CGContextStrokePath(ctx);*/
    CGRect highlightRect = self.bounds;
    highlightRect.size.width = self.bounds.size.width * self.progressView.progress;
//    CGRect rect = CGRectInset(highlightRect, 2.0, 2.0);
    CGRect rect = highlightRect;
    if(self.progressView.displayGradient)
    {
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                            cornerRadius:rect.size.height * self.progressView.curvaceousness / 2.0];
        
        clipPath = switchOutline;
        CGGradientRef myGradient;
        CGColorSpaceRef myColorspace;
        CGFloat locations[2] = { 0.0, 1.0 };
        
        myColorspace = CGColorSpaceCreateDeviceRGB();
        NSArray *colors = @[(__bridge id)self.progressView.progressTintColor.CGColor , (__bridge id) self.progressView.progressTintGradientEndColor.CGColor];
        myGradient = CGGradientCreateWithColors(myColorspace, (__bridge CFArrayRef)colors, locations);
        
        CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
        
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, clipPath    .CGPath);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, myGradient, startPoint, endPoint, 0);
        
        CGGradientRelease(myGradient);
        CGColorSpaceRelease(myColorspace);
        CGContextRestoreGState(ctx);
        
    }
    else
    {
        CGContextSetFillColorWithColor(ctx, self.progressView.progressTintColor.CGColor);
        CGContextFillRect(ctx, highlightRect);
    }
}

@end
