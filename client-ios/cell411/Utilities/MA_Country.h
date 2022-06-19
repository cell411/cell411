//
//  MA_Country.h
//  cell411
//
//  Created by Milan Agarwal on 09/06/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface MA_Country : NSObject

@property (strong, nonatomic) NSString* dialingCode;
@property (strong, nonatomic) NSString* isoCode;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) UIImage* flag;

///Returns an array of UFTCountry objects
+(NSArray *)getListOfAllCountries;

+(instancetype)defaultCountry;
+(instancetype)getCountryWithDialingCode:(NSString *)strDialingCode;

///Helper Methods
+(NSString *)countryNameFromCountryISOCode:(NSString *)isoCode;
+(NSString *)isoCodeFromCountryName:(NSString *)countryName;
+(NSString *)dialingCodeFromISOCode:(NSString *)isoCode;
+(NSString *)dialingCodeFromCountryName:(NSString *)countryName;
+(NSDictionary *)getCountryISOAndDialingCodeMappingDictionary;


@end
