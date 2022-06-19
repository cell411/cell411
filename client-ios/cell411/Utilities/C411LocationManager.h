//
//  C411LocationManager.h
//  cell411
//
//  Created by Milan Agarwal on 16/06/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@class CLLocation;

@interface C411LocationManager : NSObject

@property(nonatomic,readonly,getter=isShowingEnableLocationPopup)BOOL showingLocationEnablePopup;
+(instancetype)sharedInstance;
+(void)clearInstance;
+(BOOL)isLocationDependentServiceTemporarilyDisabled:(NSInteger)locationDependentService;
-(BOOL)isLocationAccessAllowed;
-(void)startUpdatingLocations;
-(void)stopUpdatingLocation;
-(CLLocation *)getCurrentLocationWithFallbackToOtherAvailableLocation:(BOOL)shouldFallbackToOtherAvailableLocation;
-(void)showEnableLocationPopupWithCustomMessagePrefix:(NSString *)strMsgPrefix cancelActionHandler:(popupActionHandler)cancelActionHandler andSettingsActionHandler:(popupActionHandler)settingsActionHandler;


@end
