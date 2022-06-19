//
//  GoogleDirectionProvider.h
//  cell411
//
//  Created by Milan Agarwal on 19/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
@import MapKit;

typedef enum
{
    StatusCode_NotDownloaded = 0, // If direction information not be available
    StatusCode_OK = 1, // If direction request was successful
    StatusCode_UnDetermined = 2 // Not aware
} DirectionStatusCode;

@class GoogleDirectionProvider;

@protocol GoogleDirectionProviderDelegate <NSObject>

-(void)directionProviderBeginFetching:(GoogleDirectionProvider *)provider;
-(void)directionProviderWillResetDirectionData:(GoogleDirectionProvider *)provider;
-(void)directionProviderRouteNotPossible:(GoogleDirectionProvider *)provider;
-(void)directionProviderEndFetching:(GoogleDirectionProvider *)provider;
-(void)directionProvider:(GoogleDirectionProvider *)provider receivedErrorFetching:(NSError *)error;

@end

@interface DirectionLeg : NSObject
@property (nonatomic, strong) NSString *distanceText;
@property (nonatomic, strong) NSString *timeText;
@property (nonatomic, strong) NSString *startAddresss;
@property (nonatomic, strong) NSString *endAddresss;

@property (nonatomic, strong) NSNumber *distanceValue;
@property (nonatomic, strong) NSNumber *timevalue;

//@property (nonatomic, strong) NSMutableArray *steps;

@property (nonatomic, assign) CLLocationCoordinate2D startLocation;
@property (nonatomic, assign) CLLocationCoordinate2D endLocation;


-(NSString *)formatedDistanceTimeString;

//@property (nonatomic, strong) NSMutableArray *polylines;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface GoogleDirectionProvider : NSObject

///An alert data to be used by the delegate
@property (nonatomic, strong) NSDictionary *dictAlertData;

///Contains CLLocation objects for Destinations
@property (nonatomic, strong) NSMutableArray *destinations;

@property (nonatomic, assign) CLLocationCoordinate2D userlocationUsedToGetRoute;

@property (nonatomic, strong) GMSCoordinateBounds *boundRegion;
//@property (nonatomic, assign)   MKCoordinateRegion boundRegion;
@property (nonatomic, assign)   NSString *copywirte;
@property (nonatomic, strong)   MKPolyline *polyline;
@property (nonatomic, strong)   NSArray *warnings;
@property (nonatomic, strong)   NSString *summaryTitle;
@property (nonatomic, strong)   NSString *status;
@property (nonatomic, strong)   NSString *distanceText;
@property (nonatomic, strong)   NSString *durationText;

@property (nonatomic, assign)   DirectionStatusCode statusCode;

@property (nonatomic, strong)   GMSPolyline *overviewPolyline;

//@property (nonatomic, strong)   NSMutableArray *annotations;
@property (nonatomic, strong)   NSMutableArray *routelegs; // A complete route of one source detination or, source - waypoint, etc.
@property (nonatomic, assign) float totalDistance;
@property (nonatomic, assign) float totalDurationInSeconds;
@property (nonatomic, strong) NSString *strFormattedDistanceText;
@property (nonatomic, strong) NSString *strFormattedDurationText;

//@property (nonatomic, strong)   NSString *formatedOverAllDistanceTimeString;

@property (nonatomic, weak) id<GoogleDirectionProviderDelegate>directionDelegate;

-(instancetype)initWithDirectionsFromSourceLocation:(CLLocationCoordinate2D)source andDestinations:(NSMutableArray *)destinations;

-(void)startFetchingDirections;

-(void)updateDestinations:(NSMutableArray *)destinations;

-(void)reset;


@end
