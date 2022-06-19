//
//  GoogleDirectionProvider.m
//  cell411
//
//  Created by Milan Agarwal on 19/07/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "GoogleDirectionProvider.h"
#import "Downloader.h"
#import "C411StaticHelper.h"

#define GoogleMapDirectionBaseApi_JSON @"https://maps.googleapis.com/maps/api/directions/json?"


@interface DirectionsCommon : NSObject
+(CLLocationCoordinate2D)coordinateFromGoogleLocationDict:(NSDictionary *)dict;
@end

@implementation DirectionsCommon

+(CLLocationCoordinate2D)coordinateFromGoogleLocationDict:(NSDictionary *)dict
{
    CLLocationDegrees lat = [[dict valueForKey:@"lat"] doubleValue];
    CLLocationDegrees lng = [[dict valueForKey:@"lng"] doubleValue];
    return CLLocationCoordinate2DMake(lat, lng);
}

/*
+(NSMutableArray *)polyLineUsingDirectionStep:(NSMutableArray *)steps
{
    NSMutableArray *polyLines = [NSMutableArray array];
    for (DirectionStep *step in steps) {
        if (step.polyline) {
            [polyLines addObject:step.polyline];
        }
    }
    return polyLines;
}
*/

@end

//****************************************************
#pragma mark - DirectionLeg class implementation
//****************************************************

@implementation DirectionLeg

-(NSString *)formatedDistanceTimeString
{
    return [NSString localizedStringWithFormat:NSLocalizedString(@"%@ in around %@",nil),_distanceText,_timeText];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    NSDictionary *distanceDict      = [dictionary valueForKey:@"distance"];
    NSDictionary *durationDict      =[ dictionary valueForKey:@"duration"];
    NSDictionary *end_location      = [dictionary valueForKey:@"end_location"];
    NSDictionary *start_location    = [dictionary valueForKey:@"start_location"];
   // NSArray *stepsDictArray         = [dictionary valueForKey:@"steps"];
    
    self.distanceText   = [distanceDict valueForKey:@"text"];
    self.distanceValue  = [distanceDict valueForKey:@"value"];
    self.timeText       = [durationDict valueForKey:@"text"];
    self.timevalue      = [durationDict valueForKey:@"value"];
    self.startAddresss  = [dictionary valueForKey:@"start_address"];
    self.endAddresss    = [dictionary valueForKey:@"end_address"];
    
    self.endLocation    = [DirectionsCommon coordinateFromGoogleLocationDict:end_location];
    self.startLocation  = [DirectionsCommon coordinateFromGoogleLocationDict:start_location];
//    self.steps          = [NSMutableArray array];
//    int stepNumber = 1;
//    for (NSDictionary *stepDict in stepsDictArray)
//    {
//        DirectionStep *step = [[DirectionStep alloc] initWithDictionary:stepDict stepNumberInLag:stepNumber];
//        [_steps addObject:step];
//        stepNumber++;
//    }
//    self.polylines = [DirectionsCommon polyLineUsingDirectionStep:_steps];
    
    return self;
}

@end




@interface GoogleDirectionProvider ()<DownloaderDelegate>

@property (nonatomic, strong) Downloader *directionDownloader;

-(NSString *)latlongString:(CLLocationCoordinate2D)coordinate;
-(NSString *)originUserLocationString;
-(NSString *)destinationLocationString;
-(NSString *)wayPointsLocationString;
-(NSString *)requestPathString;

-(void)setRegionUsingBound:(NSDictionary *)bound;
-(void)setOverViewPolylineWithRouteDict:(NSDictionary *)route;
//-(void)setAnnoationsUsingDirectionLegs;
//-(void)calculateOverAllJourneyDistanceAndTime;

@end

@implementation GoogleDirectionProvider

//****************************************************
#pragma mark - Private methods
//****************************************************

-(NSString *)latlongString:(CLLocationCoordinate2D)coordinate
{
    return [NSString stringWithFormat:@"%@,%@",[@(coordinate.latitude) stringValue],[@(coordinate.longitude) stringValue]];
}


-(NSString *)originUserLocationString
{
    return [NSString stringWithFormat:@"origin=%@",[self latlongString:self.userlocationUsedToGetRoute]];
}

-(NSString *)destinationLocationString
{
    CLLocationCoordinate2D destinationCoordinates = [(CLLocation *)[_destinations lastObject] coordinate];
    return [NSString stringWithFormat:@"destination=%@",[self latlongString:destinationCoordinates]];
}

-(NSString *)wayPointsLocationString
{
    NSString *wayPoints = Nil;
    if (_destinations.count>1) {
        wayPoints = @"waypoints=";
        int wayPointCount = (int)_destinations.count-1;
        for (int index = 0; index<wayPointCount;index ++)
        {
            CLLocation *location = [_destinations objectAtIndex:index];
            CLLocationCoordinate2D waypointCoordinate = location.coordinate;
            wayPoints = [wayPoints stringByAppendingString:[self latlongString:waypointCoordinate]];
            if ((index+1)<wayPointCount) {
                wayPoints = [wayPoints stringByAppendingString:@"|"];
            }
        }
    }
    return wayPoints;
}

-(NSString *)requestPathString
{
    NSString *source = [self originUserLocationString];
    NSString *destination = [self destinationLocationString];
    NSString *waypoints = [self wayPointsLocationString];
    
    NSString *path = nil;
    if (waypoints) {
        
        path = [GoogleMapDirectionBaseApi_JSON stringByAppendingString:
                [NSString stringWithFormat:@"%@&%@&%@&sensor=false&alternatives=false",source,destination,waypoints]];
    }else{
        path = [GoogleMapDirectionBaseApi_JSON stringByAppendingString:
                [NSString stringWithFormat:@"%@&%@&sensor=false&alternatives=false",source,destination]];
    }
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return path;
}




-(void)setRegionUsingBound:(NSDictionary *)bound
{
    
    NSDictionary *northeastDict = [bound valueForKey:@"northeast"];
    NSDictionary *southwestDict = [bound valueForKey:@"southwest"];
    
    CLLocationCoordinate2D northeast = [DirectionsCommon coordinateFromGoogleLocationDict:northeastDict];
    CLLocationCoordinate2D southwest = [DirectionsCommon coordinateFromGoogleLocationDict:southwestDict];
    self.boundRegion = [[GMSCoordinateBounds alloc]initWithCoordinate:northeast coordinate:southwest];
/*
    MapRegionBoundary boundary = {southwest.latitude,southwest.longitude,northeast.latitude,northeast.longitude};
    MKCoordinateRegion region = [C411StaticHelper regionForBoundary:boundary marginSpanPercent:CGPointMake(.15f, .05f)];
    
    
    self.boundRegion = region;
    */
    
}

-(void)setOverViewPolylineWithRouteDict:(NSDictionary *)route
{
    NSDictionary *overview_polyline = [route valueForKey:@"overview_polyline"];
    NSString *encodepoints = [overview_polyline valueForKey:@"points"];
    GMSPolyline *polyline = [C411StaticHelper googlePolylineWithGoogleEncoded:encodepoints];
    self.overviewPolyline = polyline;
}

/*
-(void)setAnnoationsUsingDirectionLegs
{
    NSMutableArray *annotationsarr = [NSMutableArray arrayWithCapacity:_destinations.count];
    for (int index = 0; index<_destinations.count; index++) {
        CLLocation *location = [_destinations objectAtIndex:index];
        DirectionAnnotation *directionAnnotation = [[DirectionAnnotation alloc] initWithCoordinate:listing.coordinate listing:listing];
        directionAnnotation.legIndex = index;
        [annotationsarr addObject:directionAnnotation];
    }
    
    self.annotations = annotationsarr;
}
*/

-(void)calculateOverAllJourneyDistanceAndTime
{
    float timeLeg        = 0;
    float distanceLeg    = 0;
    
    for (DirectionLeg *directionLeg in _routelegs) {
        timeLeg += [directionLeg.timevalue floatValue];
        distanceLeg += [directionLeg.distanceValue floatValue];
    }
    //meters,km
    float kms = distanceLeg/1000.f;
    NSString *distanceText = Nil;
    if (kms>1.f) {
        distanceText = [NSString stringWithFormat:@"%.1f %@",kms,NSLocalizedString(@"kms.", nil)];
    }else
    {
        distanceText = [NSString stringWithFormat:@"%d meters",(int)distanceLeg,NSLocalizedString(@"meter", nil)];
    }
    
    self.totalDistance = distanceLeg;
    self.strFormattedDistanceText = distanceText;
    
    // Get Time breakups
    int hours = timeLeg/3600.f;
    float minutes = timeLeg/60.f;
    minutes = [C411StaticHelper roundOffToHigherSide:minutes];
    minutes = ((int)minutes%60);
    
    NSString *hourText = nil;
    
    if (hours>0) {
        if (minutes>0.f) {
            hourText = [NSString stringWithFormat:@"%d %@ %d %@",hours,NSLocalizedString(@"hours", nil),(int)minutes,NSLocalizedString(@"mins.", nil)];
        }else
        {
            hourText = [NSString stringWithFormat:@"%d %@",hours, NSLocalizedString(@"hours", nil)];
        }
    }else{
        hourText = [NSString stringWithFormat:@"%d %@",(int)minutes,NSLocalizedString(@"mins.", nil)];
    }
    
    self.totalDurationInSeconds = timeLeg;
    self.strFormattedDurationText = hourText;
//    self.formatedOverAllDistanceTimeString = [NSString stringWithFormat:@"%@ %@ %@",distanceText,NSLocalizedString(@"in around", nil),hourText];
}
 


//****************************************************
#pragma mark - Public methods
//****************************************************

-(instancetype)initWithDirectionsFromSourceLocation:(CLLocationCoordinate2D)source andDestinations:(NSMutableArray *)destinations;
{
    self = [super init];
    self.userlocationUsedToGetRoute = source;
    self.destinations = [NSMutableArray arrayWithArray:destinations];
    return self;
}

-(void)startFetchingDirections
{
    NSURL *url = [NSURL URLWithString:[self requestPathString]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.];
    [_directionDownloader cancel];
    self.directionDownloader = [[Downloader alloc] initWithRequest:request delegate:self];
    
    [_directionDownloader download];
}

-(void)updateDestinations:(NSMutableArray *)destinations
{
    [_directionDownloader cancel];
    self.destinations = [NSMutableArray arrayWithArray:destinations];
    [self reset];
    [self startFetchingDirections];
}

-(void)reset
{
    [_directionDownloader cancel];
    
    [_directionDelegate directionProviderWillResetDirectionData:self];
    
    self.polyline = nil;
    self.copywirte = nil;
    self.warnings = nil;
    self.summaryTitle = nil;
    self.status = nil;
    self.statusCode = StatusCode_NotDownloaded;
    self.overviewPolyline = nil;
   // self.annotations = nil;
   // self.routelegs = nil;
   // self.formatedOverAllDistanceTimeString = nil;
    self.directionDownloader = nil;
}

//****************************************************
#pragma mark - Downloader Call backs
//****************************************************

-(void)downloader:(Downloader *)downloader didFinishLoadingWithData:(NSData *)data
{
   // manuevers = [[NSMutableSet alloc] init];
    [_directionDelegate directionProviderWillResetDirectionData:self];
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:Nil];
    NSArray *routes = [dictionary valueForKey:@"routes"];
    
    self.status = [dictionary valueForKey:@"status"];
    if ([_status isEqualToString:@"OK"]) {
        self.statusCode = StatusCode_OK;
    }else {
        self.statusCode =StatusCode_UnDetermined;
    }
    
    if (routes.count>0) {
        NSDictionary *route = [routes objectAtIndex:0];
        self.copywirte = [route valueForKey:@"copyrights"];
        
        NSArray *legArray   = [route valueForKey:@"legs"];
        self.routelegs = [NSMutableArray arrayWithCapacity:legArray.count];
        for (NSDictionary *legDict in legArray) {
            [_routelegs addObject:[[DirectionLeg alloc] initWithDictionary:legDict]];
        }
        [self setRegionUsingBound:[route valueForKey:@"bounds"]];
        [self setOverViewPolylineWithRouteDict:route];
//        [self setAnnoationsUsingDirectionLegs];
        self.durationText   = @"45 mins.";
        self.distanceText   = @"17.4 km.";
        self.summaryTitle = [route valueForKey:@"summary"];
        [self calculateOverAllJourneyDistanceAndTime];
        [_directionDelegate directionProviderEndFetching:self];
    }else{
        [_directionDelegate directionProviderRouteNotPossible:self];
    }
    
//    NSLog(@"Manuevers :\n%@",manuevers);
}

-(void)downloader:(Downloader *)downloader didFailWithError:(NSError *)error
{
    [_directionDelegate directionProvider:self receivedErrorFetching:error];
    
}

-(void)downloader:(Downloader *)downloader didRecievedResponse:(NSURLResponse *)response
{
    
}

-(void)downloaderDidBeginDownloading:(Downloader *)downloader
{
    [_directionDelegate directionProviderBeginFetching:self];
}



@end
