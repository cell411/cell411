//
//  UINavigationController+OrientaionCategory.h
//  GaurSons
//
//  Created by Milan Agarwal on 14/11/13.
//  Copyright (c) 2013 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (OrientaionCategory)
-(BOOL)shouldAutorotate;
-(NSUInteger)supportedInterfaceOrientations;

@end
