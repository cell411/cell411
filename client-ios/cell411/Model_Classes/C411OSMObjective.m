//
//  C411OSMObjective.m
//  cell411
//
//  Created by Milan Agarwal on 14/06/19.
//  Copyright © 2019 Milan Agarwal. All rights reserved.
//

#import "C411OSMObjective.h"
#import "Constants.h"

static NSMutableDictionary *dictMarkerImagesCache;
static NSMutableDictionary *dictAmenityImagesCache;

@interface C411OSMObjective()
@property (nonatomic, readwrite) NSString *strName;
@property (nonatomic, readwrite) NSString *strAmenity;
@property (nonatomic, readwrite) NSString *strWebsite;
@property (nonatomic, readwrite) NSString *strOpeningHours;
@property (nonatomic, readwrite) NSString *strTags;
@property (nonatomic, readwrite) CLLocationCoordinate2D locCoordinate;
@property (nonatomic, readwrite) UIImage *imgMarker;
@property (nonatomic, readwrite) UIImage *imgAmenity;
@end

@implementation C411OSMObjective

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************
-(instancetype)initWithElement:(NSDictionary *)dictElement {
    if (self = [super init]) {
        double lat = [dictElement[kOverpassAPILatKey] doubleValue];
        double lon = [dictElement[kOverpassAPILonKey] doubleValue];
        self.locCoordinate = CLLocationCoordinate2DMake(lat, lon);
        self.strTags = @"";
        NSDictionary *dictTags = dictElement[kOverpassAPITagsKey];
        __weak typeof(self) weakSelf = self;
        [dictTags enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if([key isEqualToString:kOverpassAPINameKey]){
                weakSelf.strName = obj;
            }
            else if([key isEqualToString:kOverpassAPIOpeningHoursKey]){
                weakSelf.strOpeningHours = obj;
            }
            else if([key isEqualToString:kOverpassAPIAmenityKey]){
                weakSelf.strAmenity = obj;
            }
            else if([key isEqualToString:kOverpassAPIWebsiteKey]){
                weakSelf.strWebsite = obj;
            }
            else {
                weakSelf.strTags = [weakSelf.strTags stringByAppendingFormat:@"%@: %@\n",key, obj];
            }
        }];
    }
    return self;
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************
-(UIImage *)imgMarker {
    return [[self class] getMarkerImageForAmenity:self.strAmenity];
}

-(UIImage *)imgAmenity {
    return [[self class] getImageForAmenity:self.strAmenity];
}
//****************************************************
#pragma mark - Private Methods
//****************************************************
+(UIImage *)getMarkerImageForAmenity:(NSString *)strAmenity {
    if(strAmenity.length > 0) {
        ///Create cache if not exist
        if(!dictMarkerImagesCache) {
            dictMarkerImagesCache = [NSMutableDictionary dictionary];
        }
        ///Fetch it from cache
        UIImage *imgMarker = dictMarkerImagesCache[strAmenity];
        if(!imgMarker) {
            ///Fetch it from resource file
            if ([strAmenity isEqualToString:kOverpassAPIAmenityTypePharmacy]) {
                imgMarker = [UIImage imageNamed:@"pin_osm_pharmacy"];
            }
            else if ([strAmenity isEqualToString:kOverpassAPIAmenityTypeHospital]) {
                imgMarker = [UIImage imageNamed:@"pin_osm_hospital"];
            }
            else if ([strAmenity isEqualToString:kOverpassAPIAmenityTypePolice]) {
                imgMarker = [UIImage imageNamed:@"pin_osm_police"];
            }
            else {
                imgMarker = [UIImage imageNamed:@"pin_osm_unrecognized"];
            }
            
            ///store in cache
            dictMarkerImagesCache[strAmenity] = imgMarker;
        }
        
        ///return the image
        return imgMarker;
    }
    return nil;
}

+(UIImage *)getImageForAmenity:(NSString *)strAmenity {
    if(strAmenity.length > 0) {
        ///Create cache if not exist
        if(!dictAmenityImagesCache) {
            dictAmenityImagesCache = [NSMutableDictionary dictionary];
        }
        ///Fetch it from cache
        UIImage *imgAmenity = dictAmenityImagesCache[strAmenity];
        if(!imgAmenity) {
            ///Fetch it from resource file
            if ([strAmenity isEqualToString:kOverpassAPIAmenityTypePharmacy]) {
                imgAmenity = [UIImage imageNamed:@"ic_pharmacy"];
            }
            else if ([strAmenity isEqualToString:kOverpassAPIAmenityTypeHospital]) {
                imgAmenity = [UIImage imageNamed:@"ic_hospital"];
            }
            else if ([strAmenity isEqualToString:kOverpassAPIAmenityTypePolice]) {
                imgAmenity = [UIImage imageNamed:@"ic_police"];
            }
            else {
                imgAmenity = [UIImage imageNamed:@"ic_unrecognized"];
            }
            
            ///store in cache
            dictAmenityImagesCache[strAmenity] = imgAmenity;
        }
        
        ///return the image
        return imgAmenity;
    }
    return nil;
}

@end
