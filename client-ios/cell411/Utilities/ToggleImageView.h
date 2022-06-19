//
//  ToggleImageView.h
//  gullyfood
//
//  Created by Milan Agarwal on 14/11/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleImageView : UIImageView

@property (nonatomic, assign, getter=isSelected) BOOL selected;
@end
