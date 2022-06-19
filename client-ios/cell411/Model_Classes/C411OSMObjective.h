//
//  C411OSMObjective.h
//  cell411
//
//  Created by Milan Agarwal on 14/06/19.
//  Copyright © 2019 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface C411OSMObjective : NSObject
@property (nonatomic, readonly) NSString *strName;
@property (nonatomic, readonly) NSString *strAmenity;
@property (nonatomic, readonly) NSString *strWebsite;
@property (nonatomic, readonly) NSString *strOpeningHours;
@property (nonatomic, readonly) NSString *strTags;
@property (nonatomic, readonly) CLLocationCoordinate2D locCoordinate;
@property (nonatomic, readonly) UIImage *imgMarker;
@property (nonatomic, readonly) UIImage *imgAmenity;

-(instancetype)initWithElement:(NSDictionary *)dictElement;
@end

NS_ASSUME_NONNULL_END
