//
//  MAGProgressBar.m
//  CustomProgressBar
//
//  Created by Milan Agarwal on 26/06/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "MAGProgressView.h"
#import "MAGProgressLayer.h"

#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
- (void)SETTER:(TYPE)PROPERTY { \
if (_##PROPERTY != PROPERTY) { \
_##PROPERTY = PROPERTY; \
[self UPDATER]; \
} \
}

@interface MAGProgressView()
@property (nonatomic, strong) MAGProgressLayer *progressLayer;
@end

@implementation MAGProgressView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withDivisions:0];
}

- (id)initWithFrame:(CGRect)frame withDivisions:(NSUInteger)divisions
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.progressTintColor = [UIColor colorWithRed:0.0 green:0.45 blue:0.94 alpha:1.0];
        self.trackTintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.curvaceousness = 1.0;
        
        self.progressLayer = [MAGProgressLayer layer];
        self.progressLayer.progressView = self;
        [self.layer addSublayer:self.progressLayer];
        self.progressLayer.frame = self.bounds;
        [self.progressLayer setNeedsDisplay];
        
        float gap = self.progressLayer.frame.size.width/(divisions + 1);
        float offset = gap;
        for(int i = 0; i < divisions; i++)
        {
            CALayer *layer = [[CALayer alloc] init];
            layer.backgroundColor = [UIColor whiteColor].CGColor;
            layer.frame = CGRectMake(offset, 0, 1,self.progressLayer.frame.size.height);
            [self.progressLayer addSublayer:layer];
            offset = offset + gap;
        }
    }
    return self;
}

-(void)setProgress:(float)progress
{
    if(_progress != progress){
        if(progress < 0){
            _progress = 0;
        }
        else if (progress > 1.0){
            _progress = 1.0;
        }
        else{
            _progress = progress;
        }
        [self redrawLayers];
    }
}

GENERATE_SETTER(progressTintColor, UIColor*, setProgressTintColor, redrawLayers)

GENERATE_SETTER(trackTintColor, UIColor*, setTrackTintColor, redrawLayers)

GENERATE_SETTER(curvaceousness, float, setCurvaceousness, redrawLayers)

GENERATE_SETTER(displayGradient, BOOL, setDisplayGradient, redrawLayers)

GENERATE_SETTER(progressTintGradientEndColor, UIColor*, setProgressTintGradientEndColor, redrawLayers)

-(void) redrawLayers
{
    [self.progressLayer setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
