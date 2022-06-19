//
//  UIButton+FABMenu.h
//  Cell 411
//
//  Created by Milan Agarwal on 17/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LGPlusButtonsView;

@interface UIButton (FABMenu)

+ (LGPlusButtonsView *)plusButtonsViewWithNumberOfButtons:(NSUInteger)numberOfButtons
                                         withButtonsTitle:(NSArray *)arrButtonTitles
                                       buttonsDescription:(NSArray *)arrButtonsDescription
                                        buttonsImage:(NSArray *)arrbuttonsImage
                                            actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler;

@end
