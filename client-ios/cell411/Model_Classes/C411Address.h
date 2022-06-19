//
//  C411Address.h
//  cell411
//
//  Created by Milan Agarwal on 27/06/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface C411Address : NSObject
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, strong) NSString *strCity;
@property(nonatomic, strong) NSString *strCountry;
@property(nonatomic, strong) NSString *strFullAddress;
@end
