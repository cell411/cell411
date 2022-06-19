//
//  UIButton+FAB.m
//  cell411
//
//  Created by Milan Agarwal on 27/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "UIButton+FAB.h"

@implementation UIButton (FAB)

-(void)makeFloatingActionButton
{
    self.layer.cornerRadius = self.bounds.size.width / 2;
    self.layer.shadowColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0].CGColor;
    self.layer.shadowOffset = CGSizeMake(-3, -3);
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 5;
    self.layer.masksToBounds = NO;
}

@end
