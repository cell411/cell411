//
//  C411LocationManager.m
//  cell411
//
//  Created by Milan Agarwal on 16/06/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <PSLocation/PSlocation.h>
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "DateHelper.h"
#import "MAAlertPresenter.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#define kIsRelaunchKey  @"isRelaunch"

static C411LocationManager *sharedLocationManager;

@interface C411LocationManager()<PSLocationManagerDelegate, CLLocationManagerDelegate>
@property (nonatomic, readwrite) PSLocationManager *locationManager;
@property (nonatomic, readwrite) CLLocation *currentLocation;
@property(nonatomic,readwrite,getter=isShowingEnableLocationPopup)BOOL showingLocationEnablePopup;
@property (nonatomic, assign)BOOL isRelaunch;
@end

@implementation C411LocationManager

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

-(instancetype)init
{
    if(self = [super init]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.isRelaunch = [defaults boolForKey:kIsRelaunchKey];
        if(!self.isRelaunch){
            ///Set releaunch flag
            [defaults setBool:YES forKey:kIsRelaunchKey];
            [defaults synchronize];
        }

        [self logMessage:[NSString stringWithFormat:@"Is Location services enabled:%@",[CLLocationManager locationServicesEnabled]?@"Yes":@"No"] shouldSaveLogs:YES];
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined:
                [self logMessage:@"Location status is not determined, requesting when in use authorization" shouldSaveLogs:YES];
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager startUpdatingLocation];
                break;
                
            case kCLAuthorizationStatusDenied:
                [self logMessage:@"Location status is denied" shouldSaveLogs:YES];
                [self showLocationDeniedWarning];
                break;
                
            case kCLAuthorizationStatusRestricted:
                [self logMessage:@"Location status is restricted" shouldSaveLogs:YES];
                [self showLocationDeniedWarning];
                break;
                
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                [self logMessage:@"Location status is when in use, starting standard location service" shouldSaveLogs:YES];
                //[self.locationManager startUpdatingLocation];
                [self startUpdatingLocations];
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways:
                ///Don't use ambient location provider unless it's required to update user location on server and use standard location instead
                /*
                if([self shouldUpdateUserLocationOnServer]){
                    [self logMessage:@"Location status is authorized always, starting ambient location service" shouldSaveLogs:NO];
                    [self.locationManager startMonitoringAmbientLocationChanges];
                }
                else{
                    NSLog(@"start standard location service for always authorization as well as there is no need to access user location on background");
                    [self.locationManager startUpdatingLocation];
                }
                 */
                [self startUpdatingLocations];
                break;
                
            default:
                break;
        }
        
        ///Register for notifications
        [self registerForNotifications];
    }
    return self;
}

-(void)dealloc
{
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Public Interface
//****************************************************

+(instancetype)sharedInstance
{
    ///NOTE: This is not a pure singleton so don't use dispatch_once block
    if (!sharedLocationManager) {
        ///set APP id and Key for Pathsense
        [PSLocation setApiKey:PATHSENSE_API_KEY andClientID:PATHSENSE_CLIENT_ID];
        sharedLocationManager = [[C411LocationManager alloc]init];
    }
    
    return sharedLocationManager;
}

+(void)clearInstance
{
    [sharedLocationManager stopUpdatingLocation];
    sharedLocationManager.locationManager.delegate = nil;
    sharedLocationManager.locationManager = nil;
    sharedLocationManager.currentLocation = nil;
    sharedLocationManager = nil;
}

+(BOOL)isLocationDependentServiceTemporarilyDisabled:(NSInteger)locationDependentService
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arrTempDisabledServices = [defaults objectForKey:kTempDisabledServicesKey];
    for (NSNumber *numServiceType in arrTempDisabledServices) {
        if([numServiceType integerValue] == locationDependentService){
            return YES;
        }
    }
    return NO;
}

-(BOOL)isLocationAccessAllowed
{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return NO;
            break;
        default:
            return YES;
    }
}

-(void)startUpdatingLocations
{
    if([self shouldUpdateUserLocationOnServer] && self.isRelaunch){
        [self escalateLocationServiceAuthorization];
        
        [self logMessage:@"Starting ambient location service" shouldSaveLogs:YES];
        [self.locationManager startMonitoringAmbientLocationChanges];
    }
    else{
        [self logMessage:@"start standard location service as there is no need to access user location on background" shouldSaveLogs:YES];

        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    }
}

-(void)stopUpdatingLocation
{
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        if([weakSelf.locationManager isMonitoringAmbientLocationChanges]){
            [weakSelf logMessage:@"Stopping ambient location service" shouldSaveLogs:YES];
            [weakSelf.locationManager stopMonitoringAmbientLocationChanges];
        }
        else {
            [weakSelf logMessage:@"Stopping standard location service" shouldSaveLogs:YES];
            [weakSelf.locationManager stopUpdatingLocation];
        }
    }];
}


-(CLLocation *)getCurrentLocationWithFallbackToOtherAvailableLocation:(BOOL)shouldFallbackToOtherAvailableLocation
{
    if(self.currentLocation){
        return self.currentLocation;
    }
    else if(shouldFallbackToOtherAvailableLocation){
        CLLocation *lastKnownLocation = [self getLastKnownLocation];
        return (lastKnownLocation ? lastKnownLocation : [self getDefaultLocation]);
    }
    return nil;
}

-(void)showEnableLocationPopupWithCustomMessagePrefix:(NSString *)strMsgPrefix cancelActionHandler:(popupActionHandler)cancelActionHandler andSettingsActionHandler:(popupActionHandler)settingsActionHandler;
{
    ///Set the ivar for showing location enable popup
    self.showingLocationEnablePopup = YES;
    ///Will show the message to user that location is denied and ask user to enable it.
    NSString *strMessagePrefix = (strMsgPrefix.length > 0) ? strMsgPrefix : [NSString localizedStringWithFormat: NSLocalizedString(@"In order to provide reliable service %@ needs your location", nil), LOCALIZED_APP_NAME];
    __weak typeof(self) weakSelf = self;
    if([CLLocationManager locationServicesEnabled]){
        ///User has disabled location access to current app
        UIAlertController *authorizationStatusAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enable Location", nil) message:[NSString localizedStringWithFormat:NSLocalizedString(@"%@.\nPlease go to Settings>Privacy and turn on Location Services for %@ to determine your current location.",nil), strMessagePrefix, LOCALIZED_APP_NAME] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            ///Do anything on cancel
            if(cancelActionHandler != NULL){
                cancelActionHandler(action, 0, nil);
            }
            
            ///Post notification that cancel is tapped
            [[NSNotificationCenter defaultCenter]postNotificationName:kEnableLocationPopupCancelTappedNotification object:nil];
            
            ///reset the ivar
            weakSelf.showingLocationEnablePopup = NO;
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
        }];
        [authorizationStatusAlert addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Enable", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            ///This is iOS 8 and above device, send user to settings app
            [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
            
            if(settingsActionHandler != NULL){
                ///Call the settings action handler
                settingsActionHandler(action, 1, nil);
            }
            
            ///Post notification that enable is tapped
            [[NSNotificationCenter defaultCenter]postNotificationName:kEnableLocationPopupEnableTappedNotification object:nil];
            
            ///reset the ivar
            weakSelf.showingLocationEnablePopup = NO;
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        
        [authorizationStatusAlert addAction:settingsAction];
        //[self presentViewController:authorizationStatusAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:authorizationStatusAlert];
    }
    else{
        ///User has disabled Location access for all apps
        UIAlertController *serviceDisabledAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enable Location", nil) message:[NSString localizedStringWithFormat:NSLocalizedString(@"%@.\nGo to Settings>Privacy and turn on Location Services to determine your current location.", nil), strMessagePrefix] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            ///Do anything on cancel
            if(cancelActionHandler != NULL){
                cancelActionHandler(action, 0, nil);
            }
           
            ///Post notification that cancel is tapped
            [[NSNotificationCenter defaultCenter]postNotificationName:kEnableLocationPopupCancelTappedNotification object:nil];
            
            ///reset the ivar
            weakSelf.showingLocationEnablePopup = NO;
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
        }];
        [serviceDisabledAlert addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Enable", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ///This is iOS 8 and above device, send user to settings app
            [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
            
            if(settingsActionHandler != NULL){
                ///Call the settings action handler
                settingsActionHandler(action, 1, nil);
            }
            
            ///Post notification that enable is tapped
            [[NSNotificationCenter defaultCenter]postNotificationName:kEnableLocationPopupEnableTappedNotification object:nil];
            
            ///reset the ivar
            weakSelf.showingLocationEnablePopup = NO;
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        
        [serviceDisabledAlert addAction:settingsAction];
        //[self presentViewController:serviceDisabledAlert animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:serviceDisabledAlert];
    }
}


//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(PSLocationManager *)locationManager
{
    if(!_locationManager){
        PSLocationManager *locationManager = [[PSLocationManager alloc]init];
        locationManager.maximumLatency = 3;
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 500;
        locationManager.activityType = CLActivityTypeOther;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        locationManager.pausesLocationUpdatesWhenDeviceIsStationary = YES;
        _locationManager = locationManager;
    }
    
    return _locationManager;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)logMessage:(NSString *)strMessage shouldSaveLogs:(BOOL)shouldSaveLogs
{
#if DEBUG
    if([strMessage isKindOfClass:[NSString class]] && strMessage.length > 0){
        NSLog(@"%@", strMessage);
        
        if(shouldSaveLogs){
            ///Append string to log file
            NSString *strDocDirPath = [C411StaticHelper documentDirectoryPath];
            NSString *strFilePath = [strDocDirPath stringByAppendingPathComponent:@"c411_logs.txt"];
            NSString *strTimestamp = [[DateHelper sharedHelper] stringFromDate:[NSDate date] withFormat:@"dd-MM-yyyy HH:mm:ss"];
            NSString *strLog = [NSString stringWithFormat:@"%@: %@",strTimestamp, strMessage];
            [C411StaticHelper appendString:strLog atFilePath:strFilePath];
        }
    }
#endif
}

-(void)displayLogs
{
#if DEBUG
    NSString *strDocDirPath = [C411StaticHelper documentDirectoryPath];
    NSString *strFilePath = [strDocDirPath stringByAppendingPathComponent:@"c411_logs.txt"];
    NSString *strLogs = [[NSString alloc]initWithContentsOfFile:strFilePath encoding:NSUTF8StringEncoding error:NULL];
    NSLog(@"------LOGS------\n%@\n------LOGS------",strLogs);
#endif
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)showLocationDeniedWarning
{
    ///Disable location based services temporarily
    [self disableLocationBasedServicesTemporarily];

    ///Will show the message to user that location is denied and ask user to enable it.
    [self showEnableLocationPopupWithCustomMessagePrefix:nil cancelActionHandler:^(id action, NSInteger actionIndex, id customObject) {
        ///Do anything on cancel
        
    } andSettingsActionHandler:^(id action, NSInteger actionIndex, id customObject) {
        ///Do anything on settings tap
    }];
}

-(void)disableLocationBasedServicesTemporarily
{
    ///Save a flag as disable location services via system when location access is denied to reenable them later if required
    BOOL isLocBasedServiceDisabled = NO;
    NSMutableArray *arrTempDisabledServices = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if([self isLocationUpdateOn]){
        isLocBasedServiceDisabled = YES;
        [arrTempDisabledServices addObject:@(kTempDisabledServiceUpdateLocation)];
        [defaults setBool:NO forKey:kLocationUpdateOn];
    }
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    BOOL shouldUpdateCurrentUser = NO;
    BOOL shouldNotifyOnNewPublicCellCreation = [currentUser[kUserNewPublicCellAlertKey] boolValue];
    if(shouldNotifyOnNewPublicCellCreation){
        isLocBasedServiceDisabled = YES;
        shouldUpdateCurrentUser = YES;
        [arrTempDisabledServices addObject:@(kTempDisabledServiceNewPublicCellAlert)];
        currentUser[kUserNewPublicCellAlertKey] = @(NO);
    }

#if PATROL_FEATURE_ENABLED
    BOOL isPatrolModeEnabled = [currentUser[kUserPatrolModeKey]boolValue];
    if(isPatrolModeEnabled){
        isLocBasedServiceDisabled = YES;
        shouldUpdateCurrentUser = YES;
        [arrTempDisabledServices addObject:@(kTempDisabledServicePatrolMode)];
        currentUser[kUserPatrolModeKey] = @(NO);
    }
#endif
    
#if RIDE_HAILING_ENABLED
    BOOL isRideRequestsEnabled = [currentUser[kUserRideRequestAlertKey]boolValue];
    if(isRideRequestsEnabled){
        isLocBasedServiceDisabled = YES;
        shouldUpdateCurrentUser = YES;
        [arrTempDisabledServices addObject:@(kTempDisabledServiceRideRequests)];
        currentUser[kUserRideRequestAlertKey] = @(NO);
    }
#endif
    
    if(shouldUpdateCurrentUser){
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                ///save it eventually if error occured
                [currentUser saveEventually];
            }
        }];
    }
    
    if(isLocBasedServiceDisabled){
        ///Save the data in preferences
        [defaults setObject:arrTempDisabledServices forKey:kTempDisabledServicesKey];
        [defaults synchronize];
        
        ///Post notification of temporary disabling of location dependent service
        [[NSNotificationCenter defaultCenter]postNotificationName:kLocationBasedFeaturesTemporarilyDisabledNotification object:nil];
    }
    
}

-(void)reenableLocationBasedServices
{
    ///Will reenable the location based services that were temporarily disabled by the system when location access is denied
    BOOL isLocBasedServiceReenabled = NO;
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    BOOL shouldUpdateCurrentUser = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *arrTempDisabledServices = [defaults objectForKey:kTempDisabledServicesKey];
    for (NSNumber *numServiceType in arrTempDisabledServices) {
        
        switch ([numServiceType integerValue]) {
            case kTempDisabledServiceUpdateLocation:
                isLocBasedServiceReenabled = YES;
                [defaults setBool:YES forKey:kLocationUpdateOn];
                break;
                
            case kTempDisabledServiceNewPublicCellAlert:
                isLocBasedServiceReenabled = YES;
                shouldUpdateCurrentUser = YES;
                currentUser[kUserNewPublicCellAlertKey] = @(YES);

#if PATROL_FEATURE_ENABLED
            case kTempDisabledServicePatrolMode:
                isLocBasedServiceReenabled = YES;
                shouldUpdateCurrentUser = YES;
                currentUser[kUserPatrolModeKey] = @(YES);
#endif
                
#if RIDE_HAILING_ENABLED
            case kTempDisabledServiceRideRequests:
                isLocBasedServiceReenabled = YES;
                shouldUpdateCurrentUser = YES;
                currentUser[kUserRideRequestAlertKey] = @(YES);
#endif
                
            default:
                break;
        }
    }
    
    if(shouldUpdateCurrentUser){
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                ///save it eventually if error occured
                [currentUser saveEventually];
            }
        }];
    }

    if(isLocBasedServiceReenabled){
        ///Remove the data from preferences
        [defaults removeObjectForKey:kTempDisabledServicesKey];
        [defaults synchronize];
        
        ///Post notification of reenabling of temporary disabled location dependent service
        [[NSNotificationCenter defaultCenter]postNotificationName:kLocationBasedFeaturesReenabledNotification object:nil];
    }
    
}

-(BOOL)isLocationUpdateOn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL islocUpdateOn = [defaults boolForKey:kLocationUpdateOn];
    
    return islocUpdateOn;
}

-(BOOL)shouldUpdateUserLocationOnServer
{
    ///update user location on parse in background if patrol mode is enabled or new public cell alert is on or ride requests is enabled or Location Updates option is on(For regional cells)
    if([self isLocationUpdateOn]){
        return YES;
    }
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    BOOL shouldNotifyOnNewPublicCellCreation = [currentUser[kUserNewPublicCellAlertKey] boolValue];
    if(shouldNotifyOnNewPublicCellCreation){
        return YES;
    }
    
#if PATROL_FEATURE_ENABLED
    BOOL isPatrolModeEnabled = [currentUser[kUserPatrolModeKey]boolValue];
    if(isPatrolModeEnabled){
        return YES;
    }
#endif
    
#if RIDE_HAILING_ENABLED
    BOOL isRideRequestsEnabled = [currentUser[kUserRideRequestAlertKey]boolValue];
    if(isRideRequestsEnabled){
        return YES;
    }
#endif
    
    return NO;
}

-(void)updateUserLocationOnParseInBackground:(CLLocation *)location
{
    [self logMessage:@"Updating user location on Server" shouldSaveLogs:YES];
    CLLocationCoordinate2D currentLocationCoordinate = location.coordinate;
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    currentUser[kUserLocationKey] = [PFGeoPoint geoPointWithLatitude:currentLocationCoordinate.latitude longitude:currentLocationCoordinate.longitude];
    [currentUser saveInBackground];
    
}


-(void)escalateLocationServiceAuthorization
{
    // Escalate only when the authorization is set to when-in-use
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self logMessage:@"Escalating location access from when in use to always" shouldSaveLogs:YES];
        [self.locationManager requestAlwaysAuthorization];
    }
}


-(CLLocation *)getLastKnownLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictLastLocation = [defaults objectForKey:kLastKnowLocationKey];
    if(dictLastLocation){
        return [[CLLocation alloc]initWithLatitude:[dictLastLocation[kLastKnowLocLatitudeKey]doubleValue] longitude:[dictLastLocation[kLastKnowLocLongitudeKey]doubleValue]];
    }
    return nil;
}

-(void)cacheLastKnownLocation:(CLLocation *)location
{
    [self logMessage:@"Caching Location" shouldSaveLogs:YES];
    if(location){
        ///Update ivar
        self.currentLocation = location;
        
        ///Update Cache
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dictLastLocation = @{
                                           kLastKnowLocLatitudeKey:@(location.coordinate.latitude),
                                           kLastKnowLocLongitudeKey:@(location.coordinate.longitude)
                                           };
        [defaults setObject:dictLastLocation forKey:kLastKnowLocationKey];
        [defaults synchronize];
    }
}

-(CLLocation *)getDefaultLocation
{
    ///Return default location as per App
#if APP_IER
    return [[CLLocation alloc]initWithLatitude:-33.9302225 longitude:18.4773846];
#elif APP_RO112
    return [[CLLocation alloc]initWithLatitude:44.4268 longitude:26.1025];
#else
    return [[CLLocation alloc]initWithLatitude:38.8935128 longitude:-77.1546602];
#endif
}

//****************************************************
#pragma mark - CLLocationManagerDelegate Methods
//****************************************************

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self logMessage:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__] shouldSaveLogs:YES];
    switch(error.code){
        case kCLErrorLocationUnknown:
            [self logMessage:@"Location is unknown" shouldSaveLogs:YES];
            break;
        case kCLErrorDenied:
            if([(PSLocationManager *)manager isMonitoringAmbientLocationChanges]){
                [self logMessage:@"Location is denied for ambient location service" shouldSaveLogs:YES];
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [(PSLocationManager *)manager stopMonitoringAmbientLocationChanges];
                }];
            }
            else{
                [self logMessage:@"Location is denied for standard location service" shouldSaveLogs:YES];
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [manager stopUpdatingLocation];
                }];
            }
            break;
        default:
            [self logMessage:[NSString stringWithFormat:@"Some error occurred: %@",error] shouldSaveLogs:YES];
            break;
            
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self logMessage:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__] shouldSaveLogs:YES];
    CLLocation *location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    [self logMessage:[NSString stringWithFormat:@"Location updated to : %f, %f :%f seconds ago by location manager %@",location.coordinate.latitude, location.coordinate.longitude, howRecent, [(PSLocationManager *)manager isMonitoringAmbientLocationChanges] ? @"Ambient" : @"Standard"] shouldSaveLogs:YES];
    if((fabs(howRecent) < 1.0)){
        if(self.locationManager.desiredAccuracy != kCLLocationAccuracyHundredMeters){
            [self logMessage:@"Lowering the desired accuracy level to hundred meters" shouldSaveLogs:YES];
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        }
        
        if(![self isLocationUpdateOn]){
            [self stopUpdatingLocation];
        }
    }
    ///Update user location on backend
    if ([self shouldUpdateUserLocationOnServer]) {
        [self updateUserLocationOnParseInBackground:location];
    }
    
    ///Cache user location
    [self cacheLastKnownLocation:location];
    
    ///POST notification that location is updated
    [[NSNotificationCenter defaultCenter]postNotificationName:kLocationUpdatedNotification object:location];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [self logMessage:@"Location status changed to Not determined" shouldSaveLogs:YES];
            break;
            
        case kCLAuthorizationStatusDenied:
            [self logMessage:@"Location status changed to denied" shouldSaveLogs:YES];
            [self stopUpdatingLocation];
            [self showLocationDeniedWarning];
            break;
            
        case kCLAuthorizationStatusRestricted:
            [self logMessage:@"Location status changed to restricted" shouldSaveLogs:YES];
            [self stopUpdatingLocation];
            [self showLocationDeniedWarning];
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self logMessage:@"Location Status changed to when in use" shouldSaveLogs:YES];
            /*
            if([(PSLocationManager *)manager isMonitoringAmbientLocationChanges]){
                //NSLog(@"Called by ambient location service");
                NSLog(@"Stopping monitoring ambient location service");
                [(PSLocationManager *)manager stopMonitoringAmbientLocationChanges];
            }
            NSLog(@"Starting updating location using standard location service");
            [self.locationManager startUpdatingLocation];
             */
            [self reenableLocationBasedServices];
            [self startUpdatingLocations];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            [self logMessage:@"Location Status changed to always" shouldSaveLogs:YES];
            [self reenableLocationBasedServices];
            ///Don't use ambient location provider unless it's required to update user location on server or it's already running and use standard location instead
            if([(PSLocationManager *)manager isMonitoringAmbientLocationChanges]){
                [self logMessage:@"Already monitoring location using ambient location service, do nothing" shouldSaveLogs:YES];
            }
            else if([self shouldUpdateUserLocationOnServer]){
                [self logMessage:@"stopping standard location service if it's running" shouldSaveLogs:YES];
                [manager stopUpdatingLocation];
                
                [self logMessage:@"Starting monitoring ambient location changes" shouldSaveLogs:YES];
                [self.locationManager startMonitoringAmbientLocationChanges];
            }
            else {
                [self logMessage:@"start standard location service for always authorization as well as there is no need to access user location on background" shouldSaveLogs:YES];
                [manager startUpdatingLocation];
                
            }
            break;
            
        default:
            break;
    }
    
    ///POST notification that location authorization status is changed
    [[NSNotificationCenter defaultCenter]postNotificationName:kLocationAuthorizationStatusChangedNotification object:@(status)];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)cell411AppWillEnterForeground:(NSNotification *)notif
{
    if ([self isLocationAccessAllowed]) {
        [self startUpdatingLocations];
    }
}


-(void)cell411AppDidEnterBackground:(NSNotification *)notif
{
    if([self isLocationAccessAllowed]
       && ((![self shouldUpdateUserLocationOnServer])
           ||(self.locationManager.isMonitoringAmbientLocationChanges == NO))){
        ///Stop updating location in background if it's running and if location is not required to be updated on server or if it's required to update location on server but is using standard location provider
            [self stopUpdatingLocation];
    }
    
}
@end
