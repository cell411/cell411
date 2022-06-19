//
//  ToggleImageView.m
//  gullyfood
//
//  Created by Milan Agarwal on 14/11/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "ToggleImageView.h"
#import "C411ColorHelper.h"

#define SELECTED_IMAGE_NAME     @"ic_radio_selected"
#define UNSELECTED_IMAGE_NAME   @"ic_radio"

@implementation ToggleImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected) {
 
        ///Set selected Image
        static UIImage *selectedImage = nil;
        if (!selectedImage) {
            selectedImage = [UIImage imageNamed:SELECTED_IMAGE_NAME];
        }
        self.tintColor = [C411ColorHelper sharedInstance].secondaryColor;

        self.image = selectedImage;
    }
    else{
       
        ///Set unselected Image
        static UIImage *unselectedImage = nil;
        if (!unselectedImage) {
            unselectedImage = [UIImage imageNamed:UNSELECTED_IMAGE_NAME];
        }
        self.image = unselectedImage;

    }
}

@end
