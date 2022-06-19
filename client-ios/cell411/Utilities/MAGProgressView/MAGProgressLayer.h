//
//  MAGProgressLayer.h
//  CustomProgressBar
//
//  Created by Milan Agarwal on 26/06/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
@class MAGProgressView;
@interface MAGProgressLayer : CALayer
@property (nonatomic, weak) MAGProgressView *progressView;
@end
