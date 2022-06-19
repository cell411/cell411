//
//  MAGProgressBar.h
//  CustomProgressBar
//
//  Created by Milan Agarwal on 26/06/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAGProgressView : UIView
@property(nonatomic) float progress;                        // 0.0 .. 1.0, default is 0.0. values outside are pinned.
@property(nonatomic, strong, nullable) UIColor* progressTintColor;
@property(nonatomic, strong, nullable) UIColor* trackTintColor;
@property (nonatomic) float curvaceousness;
@property (nonatomic, assign) BOOL displayGradient;
@property(nonatomic, strong, nullable) UIColor* progressTintGradientEndColor;

- (id)initWithFrame:(CGRect)frame withDivisions:(NSUInteger)divisions;

@end
