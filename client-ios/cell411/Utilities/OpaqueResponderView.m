//
//  OpaqueResponderView.m
//  cell411
//
//  Created by Milan Agarwal on 05/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "OpaqueResponderView.h"

@implementation OpaqueResponderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self && self.onlyRespondToTouchesInSubviews) return nil;
    return hitView;
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    return hitView;
}

 
@end
