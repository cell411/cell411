//
//  C411ColorHelper.m
//  cell411
//
//  Created by Milan Agarwal on 13/04/19.
//  Copyright © 2019 Milan Agarwal. All rights reserved.
//

#import "C411ColorHelper.h"
#import "C411StaticHelper.h"
#import "Constants.h"

#define ALPHA(hex) (0x##hex/255.0)

@interface C411ColorHelper()

@property (nonatomic, readwrite) UIColor *backgroundColor;
@property (nonatomic, readwrite) UIColor *cardColor;
@property (nonatomic, readwrite) UIColor *lightCardColor;
@property (nonatomic, readwrite) UIColor *primaryTextColor;
@property (nonatomic, readwrite) UIColor *primaryBGPlaceholderTextColor;
@property (nonatomic, readwrite) UIColor *secondaryTextColor;
@property (nonatomic, readwrite) UIColor *disabledTextColor;
@property (nonatomic, readwrite) UIColor *primaryBGTextColor;
@property (nonatomic, readwrite) UIColor *hintIconColor;
@property (nonatomic, readwrite) UIColor *darkHintIconColor;
@property (nonatomic, readwrite) UIColor *separatorColor;
@property (nonatomic, readwrite) UIColor *themeColor;
@property (nonatomic, readwrite) UIColor *lightThemeColor;
@property (nonatomic, readwrite) UIColor *darkThemeColor;
@property (nonatomic, readwrite) UIColor *loginGradientLightColor;
@property (nonatomic, readwrite) UIColor *primaryColor;
@property (nonatomic, readwrite) UIColor *darkPrimaryColor;
@property (nonatomic, readwrite) UIColor *secondaryColor;
@property (nonatomic, readwrite) UIColor *darkSecondaryColor;
@property (nonatomic, readwrite) UIColor *fabSelectedColor;
@property (nonatomic, readwrite) UIColor *fabDeselectedColor;
@property (nonatomic, readwrite) UIColor *fabShadowColor;
@property (nonatomic, readwrite) UIColor *fabSelectedTintColor;
@property (nonatomic, readwrite) UIColor *fabDeselectedTintColor;
@property (nonatomic, readwrite) UIColor *rideFabColor;
@property (nonatomic, readwrite) UIColor *tabItemNormalColor;
@property (nonatomic, readwrite) UIColor *tabItemSelectedColor;
@property (nonatomic, readwrite) UIColor *knowYourRightsIconBorderColor;
@property (nonatomic, readwrite) UIColor *popupCrossButtonColor;
@property (nonatomic, readwrite) UIColor *deletedUserTextColor;

@property (nonatomic, readwrite) UIImage *imgGalleryBG;
@property (nonatomic, readwrite) UIImage *imgNavHeader;
@property (nonatomic, readwrite) UIImage *imgChatBG;

@property (nonatomic, readwrite) UIKeyboardAppearance keyboardAppearance;
@property (nonatomic, readwrite) UIBarStyle barStyle;
@property (nonatomic, readwrite) UIStatusBarStyle statusBarStyle;

@property (nonatomic, readwrite) NSURL *aboutURL;
@property (nonatomic, readwrite) NSURL *mapStyleURL;

@property (nonatomic, assign, getter=isNightModeEnabled) BOOL nightModeEnabled;
@end

@implementation C411ColorHelper
+(instancetype)sharedInstance {
    static C411ColorHelper *colorHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorHelper = [[C411ColorHelper alloc]init];
    });
    return colorHelper;
}

-(NSString *)getSplashImageNameAtIndex:(NSInteger)index {
    NSString *strSuffix = self.isNightModeEnabled ? @"_night" : @"";
    NSString *strSplashImageName = [NSString stringWithFormat:@"splash_%d%@",(int)index + 1,strSuffix];
    return strSplashImageName;
}

-(UIColor *)getMapObjectiveColorForCategory:(MapObjectiveCategory)category {
    NSString *strColorHex = nil;
    switch(category) {
        case MapObjectiveCategoryPharmacy:
            strColorHex = @"005e20";
            break;
        case MapObjectiveCategoryHospital:
            strColorHex = @"9b1c20";
            break;
        case MapObjectiveCategoryPolice:
            strColorHex = @"002b49";
            break;
        default:
            strColorHex = @"8d6e63";
            break;
    }
    return [C411StaticHelper colorFromHexString:strColorHex];
}

-(UIColor *)getOSMObjectiveColorForAmenity:(NSString *)strAmenity {
    NSString *strColorHex = nil;
    if ([strAmenity isEqualToString:kOverpassAPIAmenityTypePharmacy]) {
        strColorHex = @"005e20";
    }
    else if ([strAmenity isEqualToString:kOverpassAPIAmenityTypeHospital]) {
        strColorHex = @"9b1c20";
    }
    else if ([strAmenity isEqualToString:kOverpassAPIAmenityTypePolice]) {
        strColorHex = @"002b49";
    }
    else {
        strColorHex = @"8d6e63";
    }
    return [C411StaticHelper colorFromHexString:strColorHex];
}

-(BOOL)isNightModeEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:kDarkMode]) {
        return YES;
    }
    return NO;
}

-(UIColor *)backgroundColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"303030"];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"FFFFFF"];
    }
}

-(UIColor *)cardColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"424242"];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"E1E1E1"];
    }
}

-(UIColor *)lightCardColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"5F5F5F"];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"F3F3F3"];
    }
}

-(UIColor *)primaryTextColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"FFFFFF"];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"000000" andAlpha:ALPHA(DE)];
    }
}

-(UIColor *)secondaryTextColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"FFFFFF" andAlpha:ALPHA(B3)];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"000000" andAlpha:ALPHA(8A)];
    }
}
-(UIColor *)disabledTextColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"FFFFFF" andAlpha:ALPHA(80)];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"000000" andAlpha:ALPHA(61)];
    }
}

-(UIColor *)primaryBGTextColor {
    return [C411StaticHelper colorFromHexString:@"FFFFFF"];
}

-(UIColor *)primaryBGPlaceholderTextColor {
    return [C411StaticHelper colorFromHexString:@"FFFFFF" andAlpha:ALPHA(80)];
}

-(UIColor *)hintIconColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"FFFFFF" andAlpha:ALPHA(80)];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"000000" andAlpha:ALPHA(61)];
    }
}

-(UIColor *)darkHintIconColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"FFFFFF" andAlpha:ALPHA(AF)];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"000000" andAlpha:ALPHA(90)];
    }
}

-(UIColor *)separatorColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"FFFFFF" andAlpha:ALPHA(1F)];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"000000" andAlpha:ALPHA(1F)];
    }
}


-(UIColor *)themeColor {
#if APP_IER
    return [C411StaticHelper colorFromHexString:@"D71E25"];
#elif APP_GTA
    return [C411StaticHelper colorFromHexString:@"222d32"];
#elif APP_RO112
    return [C411StaticHelper colorFromHexString:@"D71E25"];
#else
    return [C411StaticHelper colorFromHexString:@"2196F3"];
#endif
}

-(UIColor *)lightThemeColor {
#if APP_IER
    return [C411StaticHelper colorFromHexString:@"F3BBBD"];
#elif APP_GTA
    return [C411StaticHelper colorFromHexString:@"BCC0C1"];
#elif APP_RO112
    return [C411StaticHelper colorFromHexString:@"F3BBBD"];
#else
    return [C411StaticHelper colorFromHexString:@"C3E4ff"];
#endif
}

-(UIColor *)darkThemeColor {
#if APP_IER
    return [C411StaticHelper colorFromHexString:@"C11B21"];
#elif APP_GTA
    return [C411StaticHelper colorFromHexString:@"181F23"];
#elif APP_RO112
    return [C411StaticHelper colorFromHexString:@"C11B21"];
#else
    return [C411StaticHelper colorFromHexString:@"1976D2"];
#endif
}

-(UIColor *)loginGradientLightColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"555555"];
    }
    else {
#if APP_IER
        return [C411StaticHelper colorFromHexString:@"E57373"];
#elif APP_GTA
        return [C411StaticHelper colorFromHexString:@"737373"];
#elif APP_RO112
        return [C411StaticHelper colorFromHexString:@"E57373"];
#else
        return [C411StaticHelper colorFromHexString:@"64B5F6"];
#endif
    }
}

-(UIColor *)primaryColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"212121"];
    }
    else {
        return self.themeColor;
    }
}

-(UIColor *)darkPrimaryColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"000000"];
    }
    else {
#if APP_IER
        return [C411StaticHelper colorFromHexString:@"9B1C20"];
#elif APP_GTA
        return [C411StaticHelper colorFromHexString:@"323232"];
#elif APP_RO112
        return [C411StaticHelper colorFromHexString:@"9B1C20"];
#else
        return [C411StaticHelper colorFromHexString:@"008FF7"];
#endif
    }
}

-(UIColor *)secondaryColor {
#if APP_IER
    return [C411StaticHelper colorFromHexString:@"E2BA23"];
#elif APP_GTA
    return [C411StaticHelper colorFromHexString:@"009688"];
#elif APP_RO112
    return [C411StaticHelper colorFromHexString:@"2E49BD"];
#else
    return [C411StaticHelper colorFromHexString:@"5CC2A1"];
#endif
}

-(UIColor *)darkSecondaryColor {
#if APP_IER
    return [C411StaticHelper colorFromHexString:@"C0A22F"];
#elif APP_GTA
    return [C411StaticHelper colorFromHexString:@"007D71"];
#elif APP_RO112
    return [C411StaticHelper colorFromHexString:@"2941A8"];
#else
    return [C411StaticHelper colorFromHexString:@"0D8C62"];
#endif
}

-(UIColor *)fabSelectedColor {
    return self.secondaryColor;
}

-(UIColor *)fabDeselectedColor {
    return [C411StaticHelper colorFromHexString:@"D7D7D7"];
}

-(UIColor *)fabShadowColor {
    if(self.isNightModeEnabled) {
        return [C411StaticHelper colorFromHexString:@"424242"];
    }
    else {
        return [C411StaticHelper colorFromHexString:@"9A9A9A"];
    }
}

-(UIColor *)fabSelectedTintColor {
    return [C411StaticHelper colorFromHexString:@"FFFFFF"];
}

-(UIColor *)fabDeselectedTintColor {
    return [C411StaticHelper colorFromHexString:@"A0A0A0"];
}

-(UIColor *)rideFabColor {
    return [C411StaticHelper colorFromHexString:@"FFEB3B"];
}

-(UIColor *)tabItemNormalColor {
    return [C411StaticHelper colorFromHexString:@"F5F5F5"];
}

-(UIColor *)tabItemSelectedColor {
    return [C411StaticHelper colorFromHexString:@"FFFFFF"];
}

-(UIColor *)knowYourRightsIconBorderColor {
    return [C411StaticHelper colorFromHexString:@"FFCB00"];
}

-(UIColor *)popupCrossButtonColor {
    return [C411StaticHelper colorFromHexString:@"FF0000"];
}

-(UIColor *)deletedUserTextColor {
    return self.hintIconColor;
}

-(UIImage *)imgGalleryBG {
    if(self.isNightModeEnabled) {
        return [UIImage imageNamed:@"bg_gallery_night"];
    }
    else {
        return [UIImage imageNamed:@"bg_gallery"];
    }
}

-(UIImage *)imgNavHeader {
    if(self.isNightModeEnabled) {
        return [UIImage imageNamed:@"bg_nav_header_night"];
    }
    else {
        return [UIImage imageNamed:@"bg_nav_header"];
    }
}

-(UIImage *)imgChatBG {
    if(self.isNightModeEnabled) {
        return [UIImage imageNamed:@"bg_chat_night"];
    }
    else {
        return [UIImage imageNamed:@"bg_chat"];
    }
}

-(UIKeyboardAppearance)keyboardAppearance {
    if(self.isNightModeEnabled) {
        return UIKeyboardAppearanceDark;
    }
    else {
        return UIKeyboardAppearanceDefault;
    }
}

-(UIBarStyle)barStyle {
    if(self.isNightModeEnabled) {
        return UIBarStyleBlack;
    }
    else {
        return UIBarStyleDefault;
    }
}

-(UIStatusBarStyle)statusBarStyle {
    if(self.isNightModeEnabled) {
        return UIStatusBarStyleLightContent;
    }
    else {
        return UIStatusBarStyleDefault;
    }
}

-(NSURL *)aboutURL {
    if(self.isNightModeEnabled) {
        return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"about_night" ofType:@"html"]];
    }
    else {
        return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"about" ofType:@"html"]];
    }
}

-(NSURL *)mapStyleURL {
    if(self.isNightModeEnabled) {
        return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"map_style_aubergine" ofType:@"json"]];
    }
    else {
        return [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"map_style_standard" ofType:@"json"]];
    }
}
@end
