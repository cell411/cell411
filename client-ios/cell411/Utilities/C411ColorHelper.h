//
//  C411ColorHelper.h
//  cell411
//
//  Created by Milan Agarwal on 13/04/19.
//  Copyright © 2019 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "C411Enums.h"
@import UIKit;
NS_ASSUME_NONNULL_BEGIN

@interface C411ColorHelper : NSObject
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) UIColor *cardColor;
@property (nonatomic, readonly) UIColor *lightCardColor;
@property (nonatomic, readonly) UIColor *primaryTextColor;
@property (nonatomic, readonly) UIColor *secondaryTextColor;
@property (nonatomic, readonly) UIColor *disabledTextColor;
@property (nonatomic, readonly) UIColor *primaryBGTextColor;
@property (nonatomic, readonly) UIColor *primaryBGPlaceholderTextColor;
@property (nonatomic, readonly) UIColor *hintIconColor;
@property (nonatomic, readonly) UIColor *darkHintIconColor;
@property (nonatomic, readonly) UIColor *separatorColor;
@property (nonatomic, readonly) UIColor *themeColor;
@property (nonatomic, readonly) UIColor *lightThemeColor;
@property (nonatomic, readonly) UIColor *darkThemeColor;
@property (nonatomic, readonly) UIColor *loginGradientLightColor;
@property (nonatomic, readonly) UIColor *primaryColor;
@property (nonatomic, readonly) UIColor *darkPrimaryColor;
@property (nonatomic, readonly) UIColor *secondaryColor;
@property (nonatomic, readonly) UIColor *darkSecondaryColor;
@property (nonatomic, readonly) UIColor *fabSelectedColor;
@property (nonatomic, readonly) UIColor *fabDeselectedColor;
@property (nonatomic, readonly) UIColor *fabShadowColor;
@property (nonatomic, readonly) UIColor *fabSelectedTintColor;
@property (nonatomic, readonly) UIColor *fabDeselectedTintColor;
@property (nonatomic, readonly) UIColor *rideFabColor;
@property (nonatomic, readonly) UIColor *tabItemNormalColor;
@property (nonatomic, readonly) UIColor *tabItemSelectedColor;
@property (nonatomic, readonly) UIColor *knowYourRightsIconBorderColor;
@property (nonatomic, readonly) UIColor *popupCrossButtonColor;
@property (nonatomic, readonly) UIColor *deletedUserTextColor;


@property (nonatomic, readonly) UIImage *imgGalleryBG;
@property (nonatomic, readonly) UIImage *imgNavHeader;
@property (nonatomic, readonly) UIImage *imgChatBG;

@property (nonatomic, readonly) UIKeyboardAppearance keyboardAppearance;
@property (nonatomic, readonly) UIBarStyle barStyle;
@property (nonatomic, readonly) UIStatusBarStyle statusBarStyle;
@property (nonatomic, readonly) NSURL *aboutURL;
@property (nonatomic, readonly) NSURL *mapStyleURL;


+(instancetype)sharedInstance;
-(NSString *)getSplashImageNameAtIndex:(NSInteger)index;
-(UIColor *)getMapObjectiveColorForCategory:(MapObjectiveCategory)category;
-(UIColor *)getOSMObjectiveColorForAmenity:(NSString *)strAmenity;
@end

NS_ASSUME_NONNULL_END
