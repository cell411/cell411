//
//  C411MapVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411MapVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "C411LocationManager.h"
#import "Constants.h"
#import "ConfigConstants.h"
#import "C411AppDefaults.h"
#import "AppDelegate.h"
#import <OpenInGoogleMaps/OpenInGoogleMapsController.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411StaticHelper.h"
#import <OBShapedButton/OBShapedButton.h>
#import "UIButton+FAB.h"
#import "C411LocationPickerVC.h"
#import "UIImage+ResizeAdditions.h"
#import "C411SendAlertPopupVC.h"
#import "EmailInfoProvider.h"
#import "C411PublicCellSelectionVC.h"
#import "ServerUtility.h"
#import "MAAlertPresenter.h"
#import "C411PanicButtonAlertOverlay.h"
#import "C411RequestRideVC.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411RideStatusOverlay.h"
#import "C411RideRequestsVC.h"
#import "C411Enums.h"
#import "C411Alert.h"
#import "C411Audience.h"
#import "UITextField+CustomProperty.h"
#import "C411SendAlertVC.h"
#import "C411ColorHelper.h"
#import "C411MapObjectiveDetailVC.h"
#import "C411OSMObjective.h"
#import "C411OSMObjectiveDetailVC.h"
#import "C411PanicAlertSettings.h"

#if VIDEO_STREAMING_ENABLED
#import "C411VideoStreamPopupVC.h"
#import "VideoPlayerViewController.h"
#endif

#if RIDE_HAILING_ENABLED
#import "C411ReceivedRideResponsesVC.h"
#import "C411RideDetailVC.h"
#endif

#if NON_APP_USERS_ENABLED
#import "C411NonAppUsersSelectionVC.h"
#endif


//#define kIsRelaunchKey  @"isRelaunch"

#define TXT_TAG_INIT_ALERT_ADDITIONAL_NOTE         201




static UIImage *defaultPinImage;

@interface C411MapVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,GMSMapViewDelegate,C411SendAlertPopupVCDelegate,C411PublicCellSelectionVCDelegate,C411SendAlertVCDelegate
#if VIDEO_STREAMING_ENABLED
,C411VideoStreamPopupVCDelegate,VideoPlayerViewControllerDelegate
#endif
#if NON_APP_USERS_ENABLED
,C411NonAppUsersSelectionVCDelegate
#endif
>

@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *btnFABToggleCenterUserLocation;
@property (weak, nonatomic) IBOutlet UIView *vuRadialMenu;
@property (weak, nonatomic) IBOutlet UIView *vuRO112RadialMenu;
@property (weak, nonatomic) IBOutlet UIView *vuOuterRadialMenu;
@property (weak, nonatomic) IBOutlet UIView *vuRO112OuterRadialMenu;
@property (weak, nonatomic) IBOutlet UIView *vuInnerRadialMenu;
@property (weak, nonatomic) IBOutlet UIView *vuRO112InnerRadialMenu;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnPhotoSlice;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnPhotoSliceWider;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnVideoSlice;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnHijackSlice;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnFireSlice;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnPoliceArrestSlice;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnPreAuthorizationSlice;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnPulledOverSlice;
@property (weak, nonatomic) IBOutlet OBShapedButton *btnBulliedSlice;
@property (weak, nonatomic) IBOutlet UIButton *btnFABRequestRide;
@property (weak, nonatomic) IBOutlet C411RideStatusOverlay *vuRideStatusOverlay;


- (IBAction)btnFABToggleCenterUserLocationTapped:(UIButton *)sender;
- (IBAction)btnInitiateAlertTapped:(OBShapedButton *)sender;
- (IBAction)barBtnChangeMapTypeTapped:(UIBarButtonItem *)sender;
- (IBAction)btnFABRequestRideTapped:(UIButton *)sender;

@property (nonatomic,strong) GMSMarker *currentLocationMarker;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, assign, getter=isFirstTime) BOOL firstTime;

///Defering location update in BG to conserve battery
//@property (nonatomic, assign) BOOL isDefferingLocationUpdate;


///Get location for the first time
//@property (nonatomic, strong) CLLocationManager *oneTimeLocManager;
@property (nonatomic, assign, getter=didReceivedFirstLocationUpdate) BOOL receivedFirstLocationUpdate;

///It will hold the custom location picked by user for issuing alert when dispatch mode is on
@property (nonatomic, assign) CLLocationCoordinate2D dispatchLocation;

#if VIDEO_STREAMING_ENABLED

///It will hold the reference of the videoStream Popup VC
@property (nonatomic, strong) C411VideoStreamPopupVC *videoStreamPopupVC;


#endif

///It will hold the PFPush object for sending Push notification regarding Video Streaming only when streaming start broadcasting
@property (nonatomic, strong) PFPush *videoPush;

///It will hold the reference of the empty cell411Alert object saved on parse for live streaming, which will be used later to update its status from PROC_VID to LIVE and then finally VOD. Also this object will be updated to provide data to this empty object using cell411AlertForVdoStreamingWithData when updating status to LIVE.
@property (nonatomic, strong) PFObject *cell411AlertForVdoStreaming;

///It will hold the reference of the cell411Alert object having data to be used to update the corresponding empty object(cell411AlertForVdoStreaming) on parse for live streaming.
@property (nonatomic, strong) PFObject *cell411AlertForVdoStreamingWithData;

///It will hold the png representation PFFileObject of photo to used for photo alert
@property (nonatomic, strong) PFFileObject *photoFile;

///It will hold the png representation NSData of photo to used for sending photo alert to public cell
@property (nonatomic, strong) NSData *photoData;

///It will hold the image to used for sending photo alert to Facebook
@property (nonatomic, strong) UIImage *photoImage;


@property (nonatomic, assign) AudienceType audienceType;
@property (nonatomic, strong) NSArray *arrAlertAudience;
@property (nonatomic, strong) NSArray *arrAlertNauAudience;
@property (nonatomic, assign) NSInteger alertType;
///This will only contain valid object if audienceType is AudienceTypePrivateCellMembers
@property (nonatomic, strong) PFObject *alertRecievingCell;

///Will hold the reference of C411SendAlertPopupVC object when user is initiating a Needy Alert himself
@property (nonatomic, strong) C411SendAlertPopupVC *sendAlertPopupVC;

///Will hold the reference of C411PublicCellSelectionVC object when user is initiating a Needy Alert himself on public cell
@property (nonatomic, strong) C411PublicCellSelectionVC *publicCellSelectionVC;



///reference to the send action method will be stored in this to use it to enable it later when there is some text inputted by user in case of issuing General alert
@property (nonatomic, weak) UIAlertAction *sendAction;


///Background Task identifiers for long running job
//@property (nonatomic, assign) UIBackgroundTaskIdentifier photoUploadTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier sendAlertTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier sendPanicOrFallenAlertTaskId;
@property (nonatomic, strong) UIImageView *tmpImgVu;

@end

@implementation C411MapVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.firstTime = YES;
    [self registerForNotifications];
    [C411LocationManager sharedInstance];///Initialize location manager
    [self initializeOpenInGoogleMapsVC];
    [self configureViews];
    [self setupViews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isFirstTime) {
        
        self.firstTime = NO;
        [self addGoogleMap];
//        [self locationServiceAvailabilitycheck];
        
    }
}

-(void)dealloc
{
    [self unregisterFromNotifications];
    [C411LocationManager clearInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Map", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self.btnFABToggleCenterUserLocation makeFloatingActionButton];
    
#if (!VIDEO_STREAMING_ENABLED)
    ///Hide the video slice
    self.btnVideoSlice.hidden = YES;

#if APP_IER
    
    ///IER Specific settings, i.e show the Hijack and pre authorization slice and hide the police arrest slice
    self.btnPoliceArrestSlice.hidden = YES;
    self.btnHijackSlice.hidden = NO;
    self.btnPreAuthorizationSlice.hidden = NO;
    
#elif APP_RO112

    ///update the ivars to hold reference for RO slices
    self.vuRadialMenu = self.vuRO112RadialMenu;
    self.vuOuterRadialMenu = self.vuRO112OuterRadialMenu;
    self.vuInnerRadialMenu = self.vuRO112InnerRadialMenu;
    
    
#else
    
    ///Cell 411 specific or other apps specific settings
    ///Replace the photo slice with the wider one and hide the video slice
    self.btnPhotoSlice.hidden = YES;
    self.btnPhotoSliceWider.hidden = NO;

#endif

#endif
  
    
#if (!RIDE_HAILING_ENABLED)
    ///Hide the request ride button if it's not enabled
    self.btnFABRequestRide.hidden = YES;
    
#else
    ///make it floating button
    [self.btnFABRequestRide makeFloatingActionButton];
     ///Add tap gesture to ride overlay
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(vuRideOverlayTapped:)];
    [self.vuRideStatusOverlay addGestureRecognizer:tapRecognizer];


#endif
    
#if APP_IER
    
    ///IER Specific settings, i.e show the Fire slice, etc.
    [self.btnFireSlice setImage:[UIImage imageNamed:@"slice_fire_ier"] forState:UIControlStateNormal];
    [self.btnPulledOverSlice setImage:[UIImage imageNamed:@"slice_pulled_over_ier"] forState:UIControlStateNormal];
    [self.btnBulliedSlice setImage:[UIImage imageNamed:@"slice_bullied_ier"] forState:UIControlStateNormal];

#endif
    
    [self applyColors];
}

-(void)updateMapStyle {
    self.mapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
}

-(void)applyColors {
    ///Update map style
    [self updateMapStyle];
    
    ///Set color on fab buttons
    UIColor *fabShadowColor = [C411ColorHelper sharedInstance].fabShadowColor;
#if RIDE_HAILING_ENABLED
    self.btnFABRequestRide.backgroundColor = [C411ColorHelper sharedInstance].rideFabColor;
    self.btnFABRequestRide.tintColor = [UIColor blackColor];
    self.btnFABRequestRide.layer.shadowColor = fabShadowColor.CGColor;
#endif
    self.btnFABToggleCenterUserLocation.layer.shadowColor = fabShadowColor.CGColor;
}

-(void)setupViews
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    ///update the center user location button
    BOOL centerUserLocation = [defaults boolForKey:kCenterUserLocation];
    [self toggleButton:self.btnFABToggleCenterUserLocation toSelected:centerUserLocation];
    
#if RIDE_HAILING_ENABLED
    
    [self showRideOverlayIfRequired];
    
#endif

}

-(void)showRideOverlayIfRequired
{
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSDate *minDate = [[NSDate date]dateByAddingTimeInterval:(-1) * TIME_TO_LIVE_FOR_RIDE_REQ];
    
    ///Check from Parse if there is any pending Ride request from current user
    PFQuery *fetchRideRequestsQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [fetchRideRequestsQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
    [fetchRideRequestsQuery whereKey:kRideRequestRequestedByKey equalTo:currentUser];
    [fetchRideRequestsQuery whereKey:kRideRequestStatusKey equalTo:kRideRequestStatusPending];
    ///finally sort it with the most recent one first
    [fetchRideRequestsQuery orderByDescending:@"createdAt"];
    [fetchRideRequestsQuery includeKey:kRideRequestRequestedByKey];
    
    __weak typeof(self) weakSelf = self;
    [fetchRideRequestsQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (object) {
            
            ///see if it's already dismissed or not
            PFObject *rideRequest = object;
            NSNumber *numOverlayDismissed = rideRequest[kRideRequestOverlayDismissedKey];
            if (!numOverlayDismissed) {
               
                ///set the object in overaly property and show the overlay
                weakSelf.vuRideStatusOverlay.rideRequest = rideRequest;
                weakSelf.vuRideStatusOverlay.overlayType = RideOverlayTypePendingRideRequest;
                weakSelf.vuRideStatusOverlay.hidden = NO;
            }
            
            
        }
        else if(error.code == kPFErrorObjectNotFound){
        
            ///Check from Parse if there is any pending pickup from current user(driver)
            PFQuery *fetchRideResponseQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
            [fetchRideResponseQuery whereKey:@"createdAt" greaterThanOrEqualTo:minDate];
            [fetchRideResponseQuery whereKey:kRideResponseRespondedByKey equalTo:currentUser];
            [fetchRideResponseQuery whereKey:kRideResponseStatusKey equalTo:kRideResponseStatusConfirmed];
            ///finally sort it with the most recent one first
            [fetchRideResponseQuery orderByDescending:@"createdAt"];
            [fetchRideResponseQuery includeKey:kRideResponseRespondedByKey];
            
            [fetchRideResponseQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                if (object) {
                    
                    ///see if it's already dismissed or not
                    PFObject *rideResponse = object;
                    NSNumber *numOverlayDismissed = rideResponse[kRideResponseOverlayDismissedKey];
                    if (!numOverlayDismissed) {
                        
                        ///Get the ride request object
                        NSString *strRideRequestId = rideResponse[kRideResponseRideRiquestIdKey];
                        PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
                        [rideRequestQuery includeKey:kRideRequestRequestedByKey];
                        
                        [rideRequestQuery getObjectInBackgroundWithId:strRideRequestId block:^(PFObject *object,  NSError *error){
                            
                            if (!error && object) {
                                
                                PFObject *rideRequest = object;
                                NSNumber *numPickupReached = rideRequest[kRideRequestPickupReachedKey];
                                NSNumber *numRideCompleted = rideRequest[kRideRequestRideCompletedKey];
                                ///show overlay if driver has not set pickup reached and pickup completed status on Parse
                                if ((!(numPickupReached && [numPickupReached boolValue]))
                                    &&(!(numRideCompleted && [numRideCompleted boolValue]))) {
                                    ///set the object in overaly property and show the overlay
                                    weakSelf.vuRideStatusOverlay.rideResponse = rideResponse;
                                    weakSelf.vuRideStatusOverlay.rideRequest = rideRequest;
                                    weakSelf.vuRideStatusOverlay.overlayType = RideOverlayTypePendingPickup;
                                    weakSelf.vuRideStatusOverlay.hidden = NO;
                                }
                                
                                
                                
                            }
                            else{
                                
                                if(![AppDelegate handleParseError:error]){
                                    
                                    //nslog the eror
                                    NSLog(@"Error:%@",error);
                                }

                            }
                        }];
                        
                    }
                    
                    
                }
                else{
                    
                    if(![AppDelegate handleParseError:error]){
                        
                        //nslog the eror
                        NSLog(@"Error:%@",error);
                    }

                }
                
            }];

        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                
            //nslog the eror
                NSLog(@"Error:%@",error);
            }
        }
        
    }];


    
}

-(void)toggleButton:(UIButton *)button toSelected:(BOOL)shouldSelect
{
    button.selected = shouldSelect;
    if (shouldSelect) {
        button.backgroundColor = [C411ColorHelper sharedInstance].fabSelectedColor;
        button.tintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
    }
    else{
        ///make deselcted color
        button.backgroundColor = [C411ColorHelper sharedInstance].fabDeselectedColor;
        button.tintColor = [C411ColorHelper sharedInstance].fabDeselectedTintColor;
    }
}



-(void)addGoogleMap
{
    ///Get current location
    CLLocation *currentLocation = [[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:YES];
    
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //self.mapView.mapType = kGMSTypeHybrid;
    //[self.mapView animateToLocation:currentLocation.coordinate];
    self.mapView.delegate = self;
    [self updateMapStyle];
    ///set map frame
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.view.bounds.size.width;
    self.mapView.frame = mapFrame;
    [self.vuMapPlaceholder addSubview:self.mapView];
    [self.vuMapPlaceholder sendSubviewToBack:self.mapView];
    
    ///set annotation for user
    if (!self.currentLocationMarker) {
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        
        ///Create current location marker and add it to map
        self.currentLocationMarker=[[GMSMarker alloc]init];
        self.currentLocationMarker.position = currentLocation.coordinate;
        self.currentLocationMarker.groundAnchor = CGPointMake(0.5, 0.5);
        ///Set default image for current user first
        if (!defaultPinImage) {
            defaultPinImage = [UIImage imageNamed:@"default_marker"];
        }
        
        self.currentLocationMarker.icon = defaultPinImage;
        ///Get gravatar for the user
        __weak typeof(self) weakSelf = self;
//        NSString *strEmail = [C411StaticHelper getEmailFromUser:currentUser];
//        if (strEmail.length > 0) {
//            [C411StaticHelper getGravatarForEmail:strEmail ofSize:60 roundedCorners:YES withCompletion:^(BOOL success, UIImage *image) {
//                if (success) {
//                    
//                    ///Update the pin to have gravatar image
//                    weakSelf.currentLocationMarker.icon = image;
//                    
//                }
//                
//            }];
//            
//        }
        
        ///get the latest object of current user
        [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object,  NSError *error){
            
            ///create a temp imageview
            weakSelf.tmpImgVu = [[UIImageView alloc]init];
            [weakSelf.tmpImgVu setAvatarForUser:currentUser shouldFallbackToGravatar:YES ofSize:60 roundedCorners:YES withCompletion:^(BOOL success, UIImage *image) {
                
                if (success) {
                    
                    ///Update the pin to have avatar image
                    weakSelf.currentLocationMarker.icon = image;
 
                }
                weakSelf.tmpImgVu = nil;
            }];

        
        }];

        
        NSString *strUserFristName = currentUser[kUserFirstnameKey];
        self.currentLocationMarker.title=[NSString localizedStringWithFormat:NSLocalizedString(@"%@, tap here to send an alert",nil),strUserFristName];
        
        ///Select the current location marker by default
        self.currentLocationMarker.map = self.mapView;
        self.mapView.selectedMarker = self.currentLocationMarker;
        
        ///Animate map to current location
        [self.mapView animateToLocation:currentLocation.coordinate];
        
        
        
    }
    [self fetchMapObjectives];
    [self fetchAmenities];
}

-(void)fetchMapObjectives {
    PFQuery *fetchMapObjectiveQuery = [PFQuery queryWithClassName:kMapObjectiveClassNameKey];
    ///Get the map object search radius, which will always be saved in miles
    float searchRadius = 100.0f;
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES]];
    [fetchMapObjectiveQuery whereKey:kMapObjectiveGeoTagKey nearGeoPoint:userGeoPoint withinMiles:searchRadius];
    [fetchMapObjectiveQuery includeKey:kMapObjectiveCreatedByKey];
    [fetchMapObjectiveQuery findObjectsInBackgroundWithBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        if (!error) {
            NSLog(@"Total map objectives:%d",(int)objects.count);
            for (PFObject *mapObjective in objects) {
                GMSMarker *mapObjectiveMarker = [[GMSMarker alloc]init];
                PFGeoPoint *mapObjectiveGeoPoint = mapObjective[kMapObjectiveGeoTagKey];
                mapObjectiveMarker.position = CLLocationCoordinate2DMake(mapObjectiveGeoPoint.latitude, mapObjectiveGeoPoint.longitude);
                mapObjectiveMarker.icon = [C411StaticHelper getMapObjectiveMarkerImageForCategory:[mapObjective[kMapObjectiveCategoryKey]intValue]];
                mapObjectiveMarker.userData = mapObjective;
                mapObjectiveMarker.map = self.mapView;
                
            }
        }
        else {
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"Error fetching map objective:%@",errorString);
            }
        }
    }];
}

-(void)fetchAmenities {
    //GMSCoordinateBounds *visibleBounds = self.mapView.cameraTargetBounds;
    NSArray *arrOverpassAmenityTypes = @[
                                         kOverpassAPIAmenityTypePharmacy,
                                         kOverpassAPIAmenityTypeHospital,
                                         kOverpassAPIAmenityTypePolice
                                         ];
    NSInteger searchRadius = 10000;
    CLLocationCoordinate2D currLocCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
    [ServerUtility getOverpassAmenities:arrOverpassAmenityTypes aroundLocation:currLocCoordinate withRadius:searchRadius andCompletion:^(NSError *error, id data) {
        if(error) {
            NSLog(@"Error fetching Objectives using Overpass API:%@", error);
            return;
        }
        if([data isKindOfClass:[NSDictionary class]]) {
            NSArray *arrElements = data[kOverpassAPIElementsKey];
            for (NSDictionary *dictElement in arrElements) {
                C411OSMObjective *osmObjective = [[C411OSMObjective alloc]initWithElement:dictElement];
                GMSMarker *osmObjectiveMarker = [[GMSMarker alloc]init];
                osmObjectiveMarker.position = osmObjective.locCoordinate;
                osmObjectiveMarker.icon = osmObjective.imgMarker;
                osmObjectiveMarker.userData = osmObjective;
                osmObjectiveMarker.map = self.mapView;
            }
        }
    }];
}

-(void)registerForNotifications
{
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cell411AppDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationAccuracyValueChanged:) name:kLocationAccuracyValueChangedNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationUpdateValueChanged:) name:kLocationUpdateValueChangedNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(patrolModeValueChanged:) name:kPatrolModeValueChangedNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newPublicCellCreationAlertValueChanged:) name:kNewPublicCellCreationAlertValueChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(locationManagerDidUpdatedLocation:) name:kLocationUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sendPanicOrFallenAlert:) name:kSendPanicOrFallenAlertNotifocation object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showRideStatusOverlay:) name:kShowRideOverlayNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideRideStatusOverlay:) name:kHideRideOverlayNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];

}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)initializeOpenInGoogleMapsVC
{
    // And let's set our callback URL right away!
    [OpenInGoogleMapsController sharedInstance].callbackURL =
    [NSURL URLWithString:kOpenInGoogleMapCallbackUrlScheme];
    
    // If the user doesn't have Google Maps installed, let's try Chrome. And if they don't
    // have Chrome installed, let's use Apple Maps. This gives us the best chance of having an
    // x-callback-url that points back to our application.
    [OpenInGoogleMapsController sharedInstance].fallbackStrategy =
    kGoogleMapsFallbackChromeThenAppleMaps;
}

-(void)animateRadialMenu
{
    //    CGAffineTransform clockWiseRotationTransform = CGAffineTransformRotate( self.vuOuterRadialMenu.transform,2 * M_PI);
    //    CGAffineTransform antiClockWiseRotationTransform = CGAffineTransformRotate( self.vuInnerRadialMenu.transform,-2 * M_PI);
    //
    //        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    //            self.vuOuterRadialMenu.transform = clockWiseRotationTransform;
    //            self.vuInnerRadialMenu.transform = antiClockWiseRotationTransform;
    //
    //
    //        } completion:^(BOOL finished) {
    //            ///Handle any task after animation
    //        }];
    
    [self animateOuterRadialMenuWithRotateCount:4];
    [self animateInnerRadialMenuWithRotateCount:4];
    
}

-(void)animateOuterRadialMenuWithRotateCount:(int)rotateCount
{
    ///Rotate 360 degree clockwise
    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.vuOuterRadialMenu setTransform:CGAffineTransformRotate(self.vuOuterRadialMenu.transform, M_PI_2)];
    } completion:^(BOOL finished) {
        
        if (finished && rotateCount > 1) {
            [self animateOuterRadialMenuWithRotateCount:rotateCount - 1];
        }
    }];
}

-(void)animateInnerRadialMenuWithRotateCount:(int)rotateCount
{
    ///Rotate 360 degree anti clockwise
    
    [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.vuInnerRadialMenu setTransform:CGAffineTransformRotate(self.vuInnerRadialMenu.transform,-1 * M_PI_2)];
    } completion:^(BOOL finished) {
        if (finished && rotateCount > 1) {
            [self animateInnerRadialMenuWithRotateCount:rotateCount - 1];
        }
    }];
}

-(void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType animated:(BOOL)animated
{
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
    
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    __weak typeof(self) weakSelf = self;
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        [weakSelf.tabBarController presentViewController:imagePickerController animated:animated completion:nil];
    }];
    
}

///Initiate alert helper method
-(void)initiateAlertForAlertButton:(OBShapedButton *)sender
{
    switch (sender.tag) {
        case BTN_ALERT_TAG_PULLED_OVER:
            NSLog(@"Pulled over tapped");
            break;
        case BTN_ALERT_TAG_ARRESTED:
            NSLog(@"arrested tapped");
            break;
        case BTN_ALERT_TAG_MEDICAL_ATTENTION:
            NSLog(@"Medical tapped");
            break;
        case BTN_ALERT_TAG_CAR_BROKE:
            NSLog(@"car broke tapped");
            break;
        case BTN_ALERT_TAG_CRIME:
            NSLog(@"Crime tapped");
            break;
        case BTN_ALERT_TAG_FIRE:
            NSLog(@"Fire tapped");
            break;
        case BTN_ALERT_TAG_DANGER:
            NSLog(@"Danger tapped");
            break;
        case BTN_ALERT_TAG_COP_BLOCKING:
            NSLog(@"Cop blocking tapped");
            break;
        case BTN_ALERT_TAG_BULLIED:
            NSLog(@"Being Bullied tapped");
            break;
        case BTN_ALERT_TAG_GENERAL:
            NSLog(@"General alert tapped");
            break;
        case BTN_ALERT_TAG_VIDEO:
            NSLog(@"Video alert tapped");
#if (!VIDEO_STREAMING_ENABLED)
                ///do nothing and return from this method if video streaming is not enabled but somehow Video Streaming Alert is tried to be issued
                return;
#endif
            break;
        case BTN_ALERT_TAG_PHOTO:
            NSLog(@"Photo alert tapped");
            break;
        case BTN_ALERT_TAG_PANIC:
            NSLog(@"Instant alert tapped");
            break;
        case BTN_ALERT_TAG_HIJACK:
            NSLog(@"Hijack alert tapped");
            break;
        case BTN_ALERT_TAG_PHYSICAL_ABUSE:
            NSLog(@"Physical abuse alert tapped");
            break;
        case BTN_ALERT_TAG_TRAPPED:
            NSLog(@"Trapped alert tapped");
            break;
        case BTN_ALERT_TAG_CAR_ACCIDENT:
            NSLog(@"Car accident alert tapped");
            break;
        case BTN_ALERT_TAG_NATURAL_DISASTER:
            NSLog(@"Natural disaster alert tapped");
            break;
        case BTN_ALERT_TAG_PRE_AUTHORIZATION:
            NSLog(@"Pre Authorization tapped");
            break;
            
        default:
            break;
    }
    
#if USE_OLD_AUDIENCE_SELECTION_POPUP
    ///Show send alert popup
    self.sendAlertPopupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411SendAlertPopupVC"];
    self.sendAlertPopupVC.delegate = self;
    self.sendAlertPopupVC.alertType = sender.tag;
    self.sendAlertPopupVC.arrCellGroups = [C411AppDefaults sharedAppDefaults].arrCells;
    UIView *vuSendAlertPopup = self.sendAlertPopupVC.view;
    UIView *vuRootVC = [AppDelegate sharedInstance].window.rootViewController.view;
    vuSendAlertPopup.frame = vuRootVC.frame;
    [vuRootVC addSubview:vuSendAlertPopup];
    [vuRootVC bringSubviewToFront:vuSendAlertPopup];
    vuSendAlertPopup.translatesAutoresizingMaskIntoConstraints = YES;
#else
    UINavigationController *sendAlertNavC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411SendAlertNavC"];
    C411SendAlertVC *sendAlertVC = [sendAlertNavC.viewControllers firstObject];
    sendAlertVC.delegate = self;
    sendAlertVC.alertType = [C411StaticHelper getAlertTypeFromAlertTypeTag:sender.tag];
    sendAlertVC.dispatchLocation = self.dispatchLocation;
    [self presentViewController:sendAlertNavC animated:YES completion:NULL];
#endif

}

-(void)dismissSendAlertPopup:(C411SendAlertPopupVC *)sendAlertPopup
{
    sendAlertPopup.delegate = nil;
    [sendAlertPopup.view removeFromSuperview];
    self.sendAlertPopupVC = nil;
}

-(void)dismissPublicCellSelectionPopup:(C411PublicCellSelectionVC *)publicCellSelectionVC
{
    publicCellSelectionVC.delegate = nil;
    [publicCellSelectionVC.view removeFromSuperview];
    self.publicCellSelectionVC = nil;
}

-(void)showAdditionalNotePopupForAlert:(C411Alert *)alert
{
    
    ///prepare a title and a message
    ///Create Alert title
    NSString *strAlertTitle = nil;
    NSString *strMessage = nil;
    
    C411Audience *audience = [alert.arrAudiences firstObject];
    
    if (audience.audienceType == AudienceTypePatrolMembers) {
        
        ///This is a Global alert and will be visible to patrol members within the defined patrol radius
        strAlertTitle = NSLocalizedString(@"Send Global Alert?", nil);
        
        ///Get patrol radius and create a message
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
        
        NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
        
        if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
            
            ///current metric is in kms
            float patrolModeRadiusInKm = patrolModeRadius * MILES_TO_KM;
            NSString *strMetric = (patrolModeRadiusInKm <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
            
            strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"You are sending a GLOBAL alert! All %@ users with \"Patrol Mode\" enabled and within a %@ %@ radius will see your alert!",nil),LOCALIZED_APP_NAME,[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadiusInKm) uptoDecimalPlaces:1],strMetric];
        }
        else{
            ///current metric is in miles
            NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
            strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"You are sending a GLOBAL alert! All %@ users with \"Patrol Mode\" enabled and within a %@ %@ radius will see your alert!",nil),LOCALIZED_APP_NAME,[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:1],strMetric];
            
        }
        
        
        
        
    }
    else if (alert.alertType == BTN_ALERT_TAG_GENERAL){
        
        strAlertTitle = NSLocalizedString(@"Add a note", nil);
        
    }
    else{
        
        strAlertTitle = NSLocalizedString(@"Add a note?", nil);
    }
    
    NSString *strPlaceholder = NSLocalizedString(@"Additional text message if any", nil);
    if (alert.alertType == BTN_ALERT_TAG_GENERAL) {
        
        strPlaceholder = NSLocalizedString(@"Enter alert description", nil);
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:strAlertTitle
                                          message:strMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf  = self;
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = strPlaceholder;
         textField.tag = TXT_TAG_INIT_ALERT_ADDITIONAL_NOTE;
         textField.delegate = weakSelf;
         textField.alert = alert;
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped cancel,
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                       
                                   }];
    UIAlertAction *sendAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Send", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     ///User tapped Send
                                     UITextField *txtAdditionalNote = alertController.textFields.firstObject;
                                     NSString *strAdditionalNote = txtAdditionalNote.text;
                                     if (strAdditionalNote.length > 0) {
                                         ///trim the white spaces
                                         strAdditionalNote = [strAdditionalNote stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                     }
                                     
                                     ///Add it to alert modal
                                     alert.strAdditionalNote = strAdditionalNote.length > 0 ? strAdditionalNote : nil;
                                     
                                     __weak typeof(self) weakSelf = self;
                                     [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                         ///Schedule notification sending to next runloop, to avoid present another alert on top of another.
                                         [weakSelf initiateAlert:alert];
                                         
                                     }];
                                     
                                     ///Dequeue the current Alert Controller and allow other to be visible
                                     [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                     
                                     
                                 }];
    
    if (alert.alertType == BTN_ALERT_TAG_GENERAL) {
        ///disable send action if alert type is General and save it's reference in ivar to enable it later
        sendAction.enabled = NO;
        self.sendAction = sendAction;
    }
    
    [alertController addAction:cancelAction];
    [alertController addAction:sendAction];
    //[self presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
    
}

/*OLD CODE
-(void)showAdditionalNotePopup
{
    
    ///prepare a title and a message
    ///Create Alert title
    NSString *strAlertTitle = nil;
    NSString *strMessage = nil;
    
    if (self.audienceType == AudienceTypePatrolMembers) {
        
        ///This is a Global alert and will be visible to patrol members within the defined patrol radius
        strAlertTitle = NSLocalizedString(@"Send Global Alert?", nil);
        
        ///Get patrol radius and create a message
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
        
        NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
        
        if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
            
            ///current metric is in kms
            float patrolModeRadiusInKm = patrolModeRadius * MILES_TO_KM;
            NSString *strMetric = (patrolModeRadiusInKm <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
            
            strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"You are sending a GLOBAL alert! All %@ users with \"Patrol Mode\" enabled and within a %@ %@ radius will see your alert!",nil),LOCALIZED_APP_NAME,[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadiusInKm) uptoDecimalPlaces:1],strMetric];
        }
        else{
            ///current metric is in miles
            NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
            strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"You are sending a GLOBAL alert! All %@ users with \"Patrol Mode\" enabled and within a %@ %@ radius will see your alert!",nil),LOCALIZED_APP_NAME,[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:1],strMetric];
            
        }
        
        
        
        
    }
    else if (self.alertType == BTN_ALERT_TAG_GENERAL){
        
        strAlertTitle = NSLocalizedString(@"Add a note", nil);
        
    }
    else{
        
        strAlertTitle = NSLocalizedString(@"Add a note?", nil);
    }
    
    NSString *strPlaceholder = NSLocalizedString(@"Additional text message if any", nil);
    if (self.alertType == BTN_ALERT_TAG_GENERAL) {
        
        strPlaceholder = NSLocalizedString(@"Enter alert description", nil);
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:strAlertTitle
                                          message:strMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf  = self;
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = strPlaceholder;
         textField.tag = TXT_TAG_INIT_ALERT_ADDITIONAL_NOTE;
         textField.delegate = weakSelf;
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped cancel,
                                       [self clearAlertAssociatedIVars];
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                   }];
    UIAlertAction *sendAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Send", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     ///User tapped Send
                                     UITextField *txtAdditionalNote = alertController.textFields.firstObject;
                                     NSString *strAdditionalNote = txtAdditionalNote.text;
                                     if (strAdditionalNote.length > 0) {
                                         ///trim the white spaces
                                         strAdditionalNote = [strAdditionalNote stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                     }
                                     
                                     __weak typeof(self) weakSelf = self;
                                     [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                         ///Schedule notification sending to next runloop, to avoid present another alert on top of another.
                                         [weakSelf initiateAlertWithNote:strAdditionalNote];
                                         
                                     }];
                                     
                                     ///Dequeue the current Alert Controller and allow other to be visible
                                     [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                     
                                 }];
    
    if (self.alertType == BTN_ALERT_TAG_GENERAL) {
        ///disable send action if alert type is General and save it's reference in ivar to enable it later
        sendAction.enabled = NO;
        self.sendAction = sendAction;
    }
    
    [alertController addAction:cancelAction];
    [alertController addAction:sendAction];
    //[self presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

}
*/

-(void)clearAlertAssociatedIVars
{
    /// CLEAR iVars for sending alert
    self.arrAlertAudience = nil;
    self.arrAlertNauAudience = nil;
    self.alertType = 0;
    self.audienceType = AudienceTypeNone;
    self.alertRecievingCell = nil;
    self.photoFile = nil;
    self.photoData = nil;
    self.photoImage = nil;
}

-(void)initiateAlert:(C411Alert *)alert
{
    __weak typeof(self) weakSelf = self;
    ///get the privilege set for the user
    [C411StaticHelper getPrivilegeForUser:[AppDelegate getLoggedInUser] shouldSetPrivilegeIfUndefined:YES andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
        
        NSString *strPrivilege = string;
        if ((!strPrivilege)
            ||(strPrivilege.length == 0)) {
            
            ///some error occured fetching privilege
            NSLog(@"#error fetching privilege : %@",error.localizedDescription);
            
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, please try again.", nil) onViewController:weakSelf];
            
        }
        else if ([strPrivilege isEqualToString:kPrivilegeTypeBanned]){
            
            ///This user account is banned, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else if ([strPrivilege hasPrefix:kPrivilegeTypeSuspended]){
            
            ///This user account is suspended, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else{
            
            ///privilege is either FIRST, SECOND or SHADOW_BANNED. User with privilege FIRST or SHADOW_BANNED cannot send Global Alerts
            C411Audience *audience = [alert.arrAudiences firstObject];
            if (alert.alertType == BTN_ALERT_TAG_VIDEO)
            {
                ///It's a video alert, handle it as OLD CODE
                ///Show alert if its a private cell member
                weakSelf.audienceType = audience.audienceType;
                weakSelf.alertType = alert.alertType;
                if ((audience.audienceType == AudienceTypePrivateCellMembers)
                    ) {
                    
                    weakSelf.arrAlertAudience = audience.audienceCell[kCellMembersKey];
                    //weakSelf.arrAlertNauAudience = audience.audienceCell[kCellNauMembersKey];
                    weakSelf.alertRecievingCell = audience.audienceCell;
                    
                    if(weakSelf.arrAlertAudience.count > 0){
                        
                        ///Cell members are available in selected cell, so send video alert to them
                        [weakSelf sendNotificationWithType:alert.alertType toMembers:weakSelf.arrAlertAudience nauMembers:nil withAdditionalNote:alert.strAdditionalNote andCompletion:NULL];
                        
                        
                    }
                    else if ([C411AppDefaults canShowSecurityGuardOption]) {
                        
                        ///this is a white label app and security guard option is avaialble so send alert to them by changing the audience typ
                        weakSelf.audienceType = AudienceTypeSecurityGuards;
                        
                        [weakSelf sendNotificationWithType:alert.alertType toMembers:nil nauMembers:nil withAdditionalNote:alert.strAdditionalNote andCompletion:NULL];
                    }
                    else{
                        ///No members in the cell and security guard option is also not available
                        [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"No members in the selected Cell", nil)];
                        
                        
                    }
                    
                    
                }
                else if (audience.audienceType == AudienceTypeAllFriends){
                    
                    ///1.Pick from defaults first if available
                    weakSelf.arrAlertAudience = [C411AppDefaults sharedAppDefaults].arrFriends;
                    
                    if (weakSelf.arrAlertAudience.count > 0) {
                        
                        ///All friends are now available send alert
                        [weakSelf sendNotificationWithType:alert.alertType toMembers:weakSelf.arrAlertAudience nauMembers:nil withAdditionalNote:alert.strAdditionalNote andCompletion:NULL];
                        
                        
                    }
                    else{
                        ///2.Try fetching all friends from parse if available
                        
                        PFUser *currentUser = [AppDelegate getLoggedInUser];
                        PFRelation *getFriendsRelation = [currentUser relationForKey:kUserFriendsKey];
                        [[getFriendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                            
                            if (!error) {
                                
                                if (objects.count > 0) {
                                    
                                    weakSelf.arrAlertAudience = [NSMutableArray arrayWithArray:objects];
                                    ///All friends are now available send alert
                                    [weakSelf sendNotificationWithType:alert.alertType toMembers:weakSelf.arrAlertAudience nauMembers:nil withAdditionalNote:alert.strAdditionalNote andCompletion:NULL];
                                    
                                    
                                }
                                else{
                                    
                                    ///Show no members toast
                                    [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"No members in the selected Cell", nil)];
                                    
                                }
                                
                            }
                            else {
                                
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                }
                                
                                
                            }
                            
                            
                            
                        }];
                        
                    }
                    
                }
                else if (audience.audienceType == AudienceTypePatrolMembers){
                    
                    weakSelf.arrAlertAudience = nil;
                    
                    if ([strPrivilege isEqualToString:kPrivilegeTypeFirst]) {
                        
                        ///user has not such privilege to issue Global alert
                        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You must have at least two friends and must have issued an alert to some Private Cell in order to issue alerts globally.", nil) onViewController:weakSelf];
                        
                    }
                    else if ([strPrivilege isEqualToString:kPrivilegeTypeShadowBanned]){
                        
                        ///user is SHADOW_BANNED, he will not be informed that he cannot send Global Alert, so that he'll be in impression that he can send Global Alerts and this will avoid fake users to send spam alerts.DO NOTHING over here
                        
                        
                    }
                    else{
                        
                        ///user has sufficient privilige to send Global Alerts
                        ///Fetch the patrol members within the given radius
                        ///Get patrol radius
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
                        
                        ///Make a query to fetch users
                        PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:[[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:YES]];

                        PFQuery *fetchGloablUsersQuery = [PFUser query];
                        [fetchGloablUsersQuery whereKey:kUserPatrolModeKey equalTo:PATROL_MODE_VALUE_ON];
                        [fetchGloablUsersQuery whereKey:kUserLocationKey nearGeoPoint:userGeoPoint withinMiles:(double)patrolModeRadius];
                        [fetchGloablUsersQuery whereKey:@"objectId" notEqualTo:[AppDelegate getLoggedInUser].objectId];
                        [fetchGloablUsersQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                            
                            if (!error) {
                                
                                if (objects.count > 0) {
                                    
                                    weakSelf.arrAlertAudience = [NSMutableArray arrayWithArray:objects];
                                    ///All Patrol members within specified miles are now available filter the members who have spammed current user and then send alert
                                    [weakSelf sendNotificationWithType:alert.alertType toMembers:weakSelf.arrAlertAudience nauMembers:nil withAdditionalNote:alert.strAdditionalNote andCompletion:NULL];
                                    
                                    
                                }
                                else{
                                    
                                    ///Show no members alert, as no patrol member available
                                    [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"No members in the selected Cell", nil)];
                                    
                                }
                                
                            }
                            else {
                                
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                }
                                
                                
                            }
                            
                            
                            
                        }];
                        
                        
                    }
                    
                }
                else if (audience.audienceType == AudienceTypeOnlySocialMediaMembers){
                    
                    ///Allow user to stream video if he has no friends and enabled Facebook/YouTube Streaming
                    weakSelf.arrAlertAudience = nil;
                    [weakSelf sendNotificationWithType:alert.alertType toMembers:nil nauMembers:nil withAdditionalNote:alert.strAdditionalNote andCompletion:NULL];
                    
                    
                }
                else if (weakSelf.audienceType == AudienceTypeSecurityGuards){
                    
                    ///Allow user to send alert to security guards
                    weakSelf.arrAlertAudience = nil;
                    [weakSelf sendNotificationWithType:alert.alertType toMembers:nil nauMembers:nil withAdditionalNote:alert.strAdditionalNote andCompletion:NULL];
                }
                
            }
            else{
                
                if (audience.audienceType == AudienceTypePatrolMembers){
                    
                    if ([strPrivilege isEqualToString:kPrivilegeTypeFirst]) {
                        
                        ///user has not such privilege to issue Global alert
                        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You must have at least two friends and must have issued an alert to some Private Cell in order to issue alerts globally.", nil) onViewController:weakSelf];
                        
                    }
                    else if ([strPrivilege isEqualToString:kPrivilegeTypeShadowBanned]){
                        
                        ///user is SHADOW_BANNED, he will not be informed that he cannot send Global Alert, so that he'll be in impression that he can send Global Alerts and this will avoid fake users to send spam alerts.DO NOTHING over here
                        
                        
                    }
                    else{
                        
                        ///Send global alert
                        [weakSelf sendAlert:alert withCompletion:NULL];
                        
                    }
                }
                else if (audience.audienceType == AudienceTypeSecurityGuards){
                    
                    ///Allow user to send alert to security guards
                    weakSelf.audienceType = audience.audienceType;
                    weakSelf.alertType = alert.alertType;
                    weakSelf.arrAlertAudience = nil;
                    [weakSelf sendNotificationWithType:alert.alertType toMembers:nil nauMembers:nil withAdditionalNote:alert.strAdditionalNote andCompletion:NULL];
                }
                else{
                    
                    ///Alert sent to other audience
                    [weakSelf sendAlert:alert withCompletion:NULL];
                    
                }
                
                
                
            }
            
            
            
        }
        
    }];
    
}

/*OLD CODE
-(void)initiateAlertWithNote:(NSString *)strNote
{
    __weak typeof(self) weakSelf = self;
    ///get the privilege set for the user
    [C411StaticHelper getPrivilegeForUser:[AppDelegate getLoggedInUser] shouldSetPrivilegeIfUndefined:YES andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
 
        NSString *strPrivilege = string;
        if ((!strPrivilege)
            ||(strPrivilege.length == 0)) {
 
            ///some error occured fetching privilege
            NSLog(@"#error fetching privilege : %@",error.localizedDescription);
 
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, please try again.", nil) onViewController:weakSelf];
            
        }
        else if ([strPrivilege isEqualToString:kPrivilegeTypeBanned]){
            
            ///This user account is banned, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else if ([strPrivilege hasPrefix:kPrivilegeTypeSuspended]){
            
            ///This user account is suspended, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else{
            
            ///privilege is either FIRST, SECOND or SHADOW_BANNED. User with privilege FIRST or SHADOW_BANNED cannot send Global Alerts
            ///Validate if target audience is available
            if (self.arrAlertAudience.count == 0) {
                ///App Audience is not available, show alert if its a cell member
                if ((self.audienceType == AudienceTypePrivateCellMembers)
                    ) {
                    
                    if(self.arrAlertNauAudience.count > 0){
                        
                        ///Non app members are available in selected cell, so send alert to them
                        [self sendNotificationWithType:self.alertType toMembers:self.arrAlertAudience nauMembers:self.arrAlertNauAudience withAdditionalNote:strNote andCompletion:NULL];

                        
                    }
                    else if ([C411AppDefaults canShowSecurityGuardOption]) {
                        
                        ///this is a white label app and security guard option is avaialble so send alert to them by changing the audience typ
                        self.audienceType = AudienceTypeSecurityGuards;
                        
                        [self sendNotificationWithType:self.alertType toMembers:self.arrAlertAudience nauMembers:self.arrAlertNauAudience withAdditionalNote:strNote andCompletion:NULL];
                    }
                    else{
                        ///No members in the cell and security guard option is also not available
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            
                            ///Do anything required on OK action
                            if (weakSelf.alertType == BTN_ALERT_TAG_VIDEO)
                            {
                                
                                ///Send notification to stream video even if there is no audience
                                [weakSelf sendNotificationWithType:weakSelf.alertType toMembers:[NSMutableArray array] nauMembers:nil withAdditionalNote:strNote andCompletion:NULL];
                            }
                            
                            ///Dequeue the current Alert Controller and allow other to be visible
                            [[MAAlertPresenter sharedPresenter]dequeueAlert];
                            
                        }];
                        
                        [alertController addAction:okAction];
                        //[weakSelf presentViewController:alertController animated:YES completion:NULL];
                        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                        [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                    }
                    
                    
                }
                else if (self.audienceType == AudienceTypeAllFriends){
                    
                    ///1.Pick from defaults first if available
                    self.arrAlertAudience = [C411AppDefaults sharedAppDefaults].arrFriends;
                    
                    if (self.arrAlertAudience.count > 0) {
                        
                        ///All friends are now available send alert
                        [self sendNotificationWithType:self.alertType toMembers:self.arrAlertAudience nauMembers:nil withAdditionalNote:strNote andCompletion:NULL];
                        
                        
                    }
                    else{
                        ///2.Try fetching all friends from parse if available
                        
                        PFUser *currentUser = [AppDelegate getLoggedInUser];
                        PFRelation *getFriendsRelation = [currentUser relationForKey:kUserFriendsKey];
                        [[getFriendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                            
                            if (!error) {
                                
                                if (objects.count > 0) {
                                    
                                    weakSelf.arrAlertAudience = [NSMutableArray arrayWithArray:objects];
                                    ///All friends are now available send alert
                                    [weakSelf sendNotificationWithType:weakSelf.alertType toMembers:weakSelf.arrAlertAudience nauMembers:nil withAdditionalNote:strNote andCompletion:NULL];
                                    
                                    
                                }
                                else{
                                    
                                    ///Show no members alert
                                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                        
                                        ///Do anything required on OK action
                                        if (weakSelf.alertType == BTN_ALERT_TAG_VIDEO)
                                        {
                                            ///Send notification to stream video even if there is no audience
                                            [weakSelf sendNotificationWithType:weakSelf.alertType toMembers:[NSMutableArray array] nauMembers:nil withAdditionalNote:strNote andCompletion:NULL];
                                            
                                        }
                                        
                                        ///Dequeue the current Alert Controller and allow other to be visible
                                        [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                        
                                    }];
                                    
                                    [alertController addAction:okAction];
                                    //[weakSelf presentViewController:alertController animated:YES completion:NULL];
                                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                                    
                                    
                                }
                                
                            }
                            else {
                                
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                }
                                
                                
                            }
                            
                            
                            
                        }];
                        
                    }
                    
                }
                else if (self.audienceType == AudienceTypePatrolMembers){
                    
                    if ([strPrivilege isEqualToString:kPrivilegeTypeFirst]) {
                        
                        ///user has not such privilege to issue Global alert
                        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You must have at least two friends and must have issued an alert to some private Cell in order to issue alerts globally.", nil) onViewController:weakSelf];
                        
                    }
                    else if ([strPrivilege isEqualToString:kPrivilegeTypeShadowBanned]){
                        
                        ///user is SHADOW_BANNED, he will not be informed that he cannot send Global Alert, so that he'll be in impression that he can send Global Alerts and this will avoid fake users to send spam alerts.DO NOTHING over here
                        
                        
                    }
                    else{
                        
                        ///user has sufficient privilige to send Global Alerts
                        ///Fetch the patrol members within the given radius
                        ///Get patrol radius
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
                        
                        ///Make a query to fetch users
                        PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:[LocationManager sharedInstance].currentLocation];
                        if ([defaults boolForKey:kDispatchMode]
                            && weakSelf.alertType != BTN_ALERT_TAG_VIDEO
                            && weakSelf.alertType != BTN_ALERT_TAG_PHOTO) {
                            
                            ///Update current userGeoPoint to custom location picked for dispatch mode
                            userGeoPoint = [PFGeoPoint geoPointWithLatitude:weakSelf.dispatchLocation.latitude longitude:weakSelf.dispatchLocation.longitude];
                            
                        }
                        PFQuery *fetchGloablUsersQuery = [PFUser query];
                        [fetchGloablUsersQuery whereKey:kUserPatrolModeKey equalTo:PATROL_MODE_VALUE_ON];
                        [fetchGloablUsersQuery whereKey:kUserLocationKey nearGeoPoint:userGeoPoint withinMiles:(double)patrolModeRadius];
                        [fetchGloablUsersQuery whereKey:@"objectId" notEqualTo:[AppDelegate getLoggedInUser].objectId];
                        [fetchGloablUsersQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                            
                            if (!error) {
                                
                                if (objects.count > 0) {
                                    
                                    weakSelf.arrAlertAudience = [NSMutableArray arrayWithArray:objects];
                                    ///All Patrol members within specified miles are now available filter the members who have spammed current user and then send alert
                                    [weakSelf sendNotificationWithType:weakSelf.alertType toMembers:weakSelf.arrAlertAudience nauMembers:nil withAdditionalNote:strNote andCompletion:NULL];
                                    
                                    
                                }
                                else{
                                    
                                    ///Show no members alert, as no patrol member available
                                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                        
                                        ///Do anything required on OK action
                                        if (weakSelf.alertType == BTN_ALERT_TAG_VIDEO)
                                        {
                                            ///Send notification to stream video even if there is no audience
                                            [weakSelf sendNotificationWithType:weakSelf.alertType toMembers:[NSMutableArray array] nauMembers:nil withAdditionalNote:strNote andCompletion:NULL];
                                            
                                        }
                                        
                                        ///Dequeue the current Alert Controller and allow other to be visible
                                        [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                    }];
                                    
                                    [alertController addAction:okAction];
                                    //[weakSelf presentViewController:alertController animated:YES completion:NULL];
                                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                                }
                                
                            }
                            else {
                                
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                }
                                
                                
                            }
                            
                            
                            
                        }];
                        
                        
                    }
                    
                }
                else if (self.alertType == BTN_ALERT_TAG_VIDEO && self.audienceType == AudienceTypeOnlySocialMediaMembers){

                    ///Allow user to stream video if he has no friends and enabled Facebook/YouTube Streaming
                    [self sendNotificationWithType:self.alertType toMembers:self.arrAlertAudience nauMembers:nil withAdditionalNote:strNote andCompletion:NULL];
                   
                    
                }
                else if (self.audienceType == AudienceTypeSecurityGuards){
                    
                    ///Allow user to send alert to security guards
                    [self sendNotificationWithType:self.alertType toMembers:self.arrAlertAudience nauMembers:nil withAdditionalNote:strNote andCompletion:NULL];
                }
                
                
                
                
            }
            else{
                
                ///members are available send alert, this will not issue global alerts so there is no need to check for privilege here
                NSArray *arrNauMembers = (self.audienceType == AudienceTypePrivateCellMembers) ? self.arrAlertNauAudience : nil;
                
                [self sendNotificationWithType:self.alertType toMembers:self.arrAlertAudience nauMembers:arrNauMembers withAdditionalNote:strNote andCompletion:NULL];
                
            }
            
            
        }
        
    }];
    
}
*/

-(void)sendAlertWithAlertParams:(NSDictionary *)dictAlertParams andCompletion:(PFBooleanResultBlock)completion
{
 
    NSError *err = nil;
    NSData *alertJsonData = [NSJSONSerialization dataWithJSONObject:dictAlertParams options:NSJSONWritingPrettyPrinted error:&err];
    if (!err && alertJsonData) {
        
        NSString *strAlertJson = [[NSString alloc]initWithData:alertJsonData encoding:NSUTF8StringEncoding];
        if (strAlertJson.length > 0) {
            
            NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
            dictParams[kSendAlertV3FuncParamAlertKey] = strAlertJson;

            AlertType alertType = (AlertType)[dictAlertParams[kSendAlertV3FuncParamAlertIdKey]integerValue];
            if(alertType == AlertTypePhoto){
                
                dictParams[kSendAlertV3FuncParamImageBytesKey] = self.photoData;
                
                ///clear the ivar
                self.photoData = nil;
                
            }
                __weak typeof(self) weakSelf = self;
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                // Request a background execution task to allow us to finish saving the cell411Alert object  even if the app is backgrounded, especially in case of Photo alert which may take time
                self.sendAlertTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    [[UIApplication sharedApplication] endBackgroundTask:self.sendAlertTaskId];
                }];

                [C411StaticHelper sendAlertV3WithDetails:dictParams andCompletion:^(id object, NSError * error) {
                    
                    if(!error){
                        
                        ///Read the alert id from json string returned from cloud function as object and publish on facebook if allowed
                        NSDictionary *dictCloudResp = nil;
                        if (object && [object isKindOfClass:[NSString class]]) {
                            
                            NSData *jsonData = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
                            NSError *err = nil;
                            dictCloudResp = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                            if (err) {
                                
                                NSLog(@"Error retriving data from send alert cloud response, error -> %@",err.localizedDescription);
                            }
                        }
                        
                        if([dictCloudResp isKindOfClass:[NSDictionary class]]){
                            
                            [weakSelf finalizeAlertWithAlertParams:dictAlertParams result:dictCloudResp andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                                
                                ///Hide the progress hud
                                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                
                                ///Call the completion block
                                if(completion != NULL){
                                    
                                    completion(YES, error);
                                }
                                
                                ///End background task
                                [[UIApplication sharedApplication] endBackgroundTask:weakSelf.sendAlertTaskId];
                            }];
                        }
                        else{
                            
                            ///Hide the progress hud
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            
                            ///Call the completion block
                            if(completion != NULL){
                                
                                completion(YES, error);
                            }
                            
                            ///End background task
                            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.sendAlertTaskId];
                        }
                        
//#if VIDEO_STREAMING_ENABLED
//                        ///Show stream video Popup
//                        if(alertType != AlertTypePhoto
//                           && alertType != AlertTypeVideo){
//                            ///Update the alert Id, title and type flags
//                            NSMutableDictionary *dictVideoAlertParams = (NSMutableDictionary *)dictAlertParams;
//                            dictVideoAlertParams[kSendAlertV3FuncParamAlertIdKey] = @(AlertTypeVideo);
//                            dictVideoAlertParams[kSendAlertV3FuncParamTitleKey] = [C411StaticHelper getAlertTypeStringUsingAlertType:AlertTypeVideo];
//                            dictVideoAlertParams[kSendAlertV3FuncParamTypeKey] = kPayloadAlertTypeVideo;
//
//                            [dictVideoAlertParams removeObjectForKey:kSendAlertV3FuncParamAdditionalNoteKey];
//
//                            ///Show show Stream video popup
//                            [weakSelf showStreamVideoPopupForAlertWithAlertParams:dictVideoAlertParams];
//
//                        }
//#endif

                        
                    }
                    else{
                        
                        ///Hide the progress hud
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        
                        ///show error
                        [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                        
                        if(completion != NULL){
                            
                            completion(NO, nil);
                        }
                        
                        ///End background task
                        [[UIApplication sharedApplication] endBackgroundTask:weakSelf.sendAlertTaskId];
                        
                    }
                }];
            
        }
        else{
            [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Some error occurred, please try again.", nil)];
            if(completion != NULL){
                
                completion(NO, nil);
            }
        }
    }
    else{
        [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Some error occurred, please try again.", nil)];
        if(completion != NULL){
            
            completion(NO, nil);
        }
    }
    
    
}

-(void)finalizeAlertWithAlertParams:(NSDictionary *)dictAlertParams result:(NSDictionary *)dictResult andCompletion:(PFBooleanResultBlock)completion
{
    
    AlertType alertType = (AlertType)[dictAlertParams[kSendAlertV3FuncParamAlertIdKey]integerValue];
    

//    NSString *strCell411AlertId = dictResult[kSendAlertV3FuncRespCell411AlertIdKey];
//    if(![C411StaticHelper canUseJsonObject:strCell411AlertId]
//       || strCell411AlertId.length == 0){
//        
//        strCell411AlertId = nil;
//    }
    
    NSString *strPhotoUrl = dictResult[kSendAlertV3FuncRespPhotoUrlKey];
    if(![C411StaticHelper canUseJsonObject:strPhotoUrl]
       || strPhotoUrl.length == 0){
        
        strPhotoUrl = nil;
    }
    
//    double alertGenerationTimeInMillis = [dictResult[kSendAlertV3FuncRespCreatedAtKey]doubleValue];
    
    NSInteger targetMembersCount = [dictResult[kSendAlertV3FuncRespTargetMembersCountKey]integerValue];
    NSInteger targetNauMembersCount = [dictResult[kSendAlertV3FuncRespTargetNauMembersCountKey]integerValue];
    
    
    ///Show Alert sent successfully message
    NSInteger alertReceiversCount = targetMembersCount + targetNauMembersCount;
    NSString *strToastMsg = nil;
    if(alertReceiversCount == 0){
        
        ///TODO: Prepare correct toast message for no members
        strToastMsg = NSLocalizedString(@"No members in the selected Cell", nil);
    }
    else{
        
        NSString *strAlertAudienceSuffix = nil;
        if(alertReceiversCount == 1){
            
            strAlertAudienceSuffix = NSLocalizedString(@"1 user", nil);
        }
        else{
            
            strAlertAudienceSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"%d users",nil),alertReceiversCount];
            
        }
        
        NSString *strMsgPrefix = NSLocalizedString(@"Alert", nil);
        if (alertType == AlertTypePhoto){
            
            strMsgPrefix = NSLocalizedString(@"Photo", nil);
        }
        
        strToastMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to %@",nil),strMsgPrefix,strAlertAudienceSuffix];
    }
    
    [AppDelegate showToastOnView:nil withMessage:strToastMsg];
    
    ///set SECOND privilege if applicable
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    [C411StaticHelper setSecondPrivilegeIfApplicableForUser:currentUser];
  
#if (VIDEO_STREAMING_ENABLED)
    ///Show post alert Popup
    [self showAlertSentPopupWithAlertParams:dictAlertParams andResult:dictResult];
#endif

    
#if APP_IER
    NSString *strAlertType = [C411StaticHelper getAlertTypeStringUsingAlertType:alertType];
    NSString *strAdditionalNote = dictAlertParams[kSendAlertV3FuncParamAdditionalNoteKey];
    CLLocationCoordinate2D locCoord = CLLocationCoordinate2DMake([dictAlertParams[kSendAlertV3FuncParamLatKey]doubleValue], [dictAlertParams[kSendAlertV3FuncParamLongKey]doubleValue]);
    [self sendIERAlertFromIssuerWithId:currentUser.objectId alertType:strAlertType additionalNote:strAdditionalNote locationCoordinate:locCoord andPhotoUrl:strPhotoUrl andCompletion:^(NSError *error, id data) {
        
        ///Do anything on completion
        
    }];

#endif
    
    if (alertType == AlertTypeMedical) {
        
        ///Flash the medical details of the user
        NSMutableString *strMedicalDetails = [NSMutableString stringWithString:@""];
        
        NSString *strBloodType = currentUser[kUserBloodTypeKey];
        if (strBloodType.length > 0) {
            ///Append Blood type info
            [strMedicalDetails appendFormat:@"\n%@: %@",NSLocalizedString(@"Blood Type", nil),strBloodType];
        }
        NSString *strAllergies = currentUser[kUserAllergiesKey];
        if (strAllergies.length > 0) {
            
            ///Append Allergies info
            [strMedicalDetails appendFormat:@"\n%@: %@",NSLocalizedString(@"Allergies", nil),strAllergies];
            
        }
        
        NSString *strOMC = currentUser[kUserOtherMedicalCondtionsKey];
        if (strOMC.length > 0) {
            
            ///Append Other Medical Conditions info
            [strMedicalDetails appendFormat:@"\n%@: %@",NSLocalizedString(@"Other Medical Conditions", nil),strOMC];
        }
        
        if (strMedicalDetails.length > 0) {
            
            ///Show alert screen if any medical detail is available
            [C411StaticHelper showAlertWithTitle:NSLocalizedString(@"Medical Details", nil) message:strMedicalDetails onViewController:self];
            
        }
        
    }

    ///Call the completion block
    if(completion != NULL){
        
        completion(YES, nil);
    }
}


-(void)sendAlert:(C411Alert *)alert withCompletion:(PFBooleanResultBlock)completion{
    
    ///NOTE: This method considers that it will not be called for Video, panic, fallen and for security guards as OLD CODE will be used for that purpose
#if (!VIDEO_STREAMING_ENABLED)
    ///return from this method if video streaming is not supported and somehow this method is called to issue video streaming alert
    if (alert.alertType == BTN_ALERT_TAG_VIDEO) {
        
        return;
    }
    
#endif
    
    //    ///show hud on screen if it's not a panic or fallen alert
    //    if (alert.alertType != BTN_ALERT_TAG_PANIC
    //        && alert.alertType != BTN_ALERT_TAG_FALLEN
    //        ) {
    ///Show hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //    }
    
    // Request a background execution task to allow us to finish saving the cell411Alert object  even if the app is backgrounded, especially in case of Photo alert which may take time
    self.sendAlertTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.sendAlertTaskId];
    }];
    
    
    ///Add missing values to alert
    ///TODO: These values should be inserted before calling this method
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kDispatchMode]
        && alert.alertType != BTN_ALERT_TAG_PHOTO) {
        
        alert.dispatched = YES;
        alert.alertLocationCoordinate = self.dispatchLocation;
    }
    else{
        alert.alertLocationCoordinate = [[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
        
    }
    
    if(alert.alertType == BTN_ALERT_TAG_PHOTO) {
        
        alert.photoData = self.photoData;
        
    }
    
    ///Create alert params to issue alert
    PFUser *alertIssuer = [AppDelegate getLoggedInUser];
    alert.alertIssuer = alertIssuer;
    
    NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:alertIssuer[kUserFirstnameKey] andLastName:alertIssuer[kUserLastnameKey]];
    
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *dictAlert = [NSMutableDictionary dictionary];
    dictAlert[kSendAlertV2FuncParamTitleKey] =  alert.strAlertType;
    dictAlert[kSendAlertV2FuncParamAdditionalNoteKey] = alert.strAdditionalNote ? alert.strAdditionalNote : @"";
    
    if(alert.isDispatched){
        
        dictAlert[kSendAlertV2FuncParamIsDispatchedKey] = @(YES);
    }
    
    dictAlert[kSendAlertV2FuncParamLatKey] = @(alert.alertLocationCoordinate.latitude);
    dictAlert[kSendAlertV2FuncParamLongKey] = @(alert.alertLocationCoordinate.longitude);
    
    NSMutableDictionary *dictAudience = [NSMutableDictionary dictionary];
    dictAlert[kSendAlertV2FuncParamAudienceKey] = dictAudience;
    
    ///Set the audience and other audience dependent data
    C411Audience *audience = [alert.arrAudiences firstObject];
    NSString *strAlertMsgPrefix = strFullName;
    
    if((audience.audienceType == AudienceTypePatrolMembers)
       || (audience.audienceType == AudienceTypeAllFriends)
       || (audience.audienceType == AudienceTypePrivateCellMembers)){
        
        ///Set type
        if (alert.alertType == BTN_ALERT_TAG_PHOTO) {
            
            dictAlert[kSendAlertV2FuncParamTypeKey] = kPayloadAlertTypePhoto;
            
            ///Set imageBytes
            if (alert.photoData) {
                
                dictParams[kSendAlertV2FuncParamImageBytesKey] = alert.photoData;
                
            }
            
        }
        else{
            
            dictAlert[kSendAlertV2FuncParamTypeKey] = kPayloadAlertTypeNeedy;
        }
        
        ///Set audience
        if(audience.audienceType == AudienceTypePatrolMembers){
            
            ///Set radius
            dictAlert[kSendAlertV2FuncParamMetricKey] = kSendAlertV2FuncMetricValueMiles;
            
            ///TODO: Need to review if we can move patrolModeRadius to alert modal object
            float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
            
            dictAlert[kSendAlertV2FuncParamRadiusKey] = @(patrolModeRadius);
            
            ///Update Alert msg prefix
            strAlertMsgPrefix = [NSString localizedStringWithFormat:NSLocalizedString(@"%@, someone in your area", nil),strFullName];
            
            ///Set audience type Global to YES
            dictAudience[kSendAlertV2FuncParamGlobalKey] = @(YES);
            
            
        }
        else if (audience.audienceType == AudienceTypeAllFriends){
            
            ///Set audience type AllFriends
            dictAudience[kSendAlertV2FuncParamAllFriendsKey] = @(YES);
            
        }
        else if (audience.audienceType == AudienceTypePrivateCellMembers){
            
            ///Set array of private Cell ids
            dictAudience[kSendAlertV2FuncParamPrivateCellsKey] = @[audience.audienceCell.objectId];
            
        }
        
    }
    else if (audience.audienceType == AudienceTypePublicCellMembers){
        
        ///Set type
        if (alert.alertType == BTN_ALERT_TAG_PHOTO) {
            
            dictAlert[kSendAlertV2FuncParamTypeKey] = kPayloadAlertTypePhotoCell;
            
            ///Set imageBytes
            if (alert.photoData) {
                
                dictParams[kSendAlertV2FuncParamImageBytesKey] = alert.photoData;
            }
        }
        else{
            
            dictAlert[kSendAlertV2FuncParamTypeKey] = kPayloadAlertTypeNeedyCell;
        }
        
        ///Set array of public Cell ids
        dictAudience[kSendAlertV2FuncParamPublicCellsKey] = @[audience.audienceCell.objectId];
        
    }
    
    NSString *strAlertMsg = nil;
    NSString *strAlertName = [C411StaticHelper getLocalizedAlertTypeStringFromString:alert.strAlertType];
    
#if APP_CELL411
    strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 411 alert",nil),strAlertMsgPrefix,strAlertName];
    
#elif APP_RO112
    strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ 112 alert",nil),strAlertMsgPrefix,strAlertName];
    
#else
    strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ issued a %@ alert",nil),strAlertMsgPrefix,strAlertName];
#endif
    
    if (audience.audienceType == AudienceTypePublicCellMembers){
        
        ///Append public cell name
        NSString *strCellName = audience.audienceCell[kPublicCellNameKey];
        strAlertMsg = [strAlertMsg stringByAppendingString:[NSString localizedStringWithFormat:NSLocalizedString(@" on %@",nil),strCellName]];
        
    }
    
    dictAlert[kSendAlertV2FuncParamMsgKey] = strAlertMsg;
    
    NSError *err = nil;
    NSData *alertJsonData = [NSJSONSerialization dataWithJSONObject:dictAlert options:NSJSONWritingPrettyPrinted error:&err];
    if (!err && alertJsonData) {
        
        NSString *strAlertJson = [[NSString alloc]initWithData:alertJsonData encoding:NSUTF8StringEncoding];
        if (strAlertJson.length > 0) {
            
            dictParams[kSendAlertV2FuncParamAlertKey] = strAlertJson;
            
            
            __weak typeof(self) weakSelf = self;
            [C411StaticHelper sendAlertV2WithDetails:dictParams andCompletion:^(id object, NSError * error) {
                
                if(!error){
                    
                    ///Read the alert id from json string returned from cloud function as object and publish on facebook if allowed
                    NSDictionary *dictCloudResp = nil;
                    if (object && [object isKindOfClass:[NSString class]]) {
                        
                        NSData *jsonData = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *err = nil;
                        dictCloudResp = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                        if (err) {
                            
                            NSLog(@"Error retriving data from send alert cloud response, error -> %@",err.localizedDescription);
                        }
                    }
                    
                    if([dictCloudResp isKindOfClass:[NSDictionary class]]){
                        
                        NSString *strCell411AlertId = dictCloudResp[kSendAlertV2FuncRespCell411AlertIdKey];
                        if([C411StaticHelper canUseJsonObject:strCell411AlertId]
                           && strCell411AlertId.length > 0){
                            
                            alert.strAlertId = strCell411AlertId;
                        }
                        
                        if(alert.alertType == BTN_ALERT_TAG_PHOTO){
                            
                            NSString *strPhotoUrl = dictCloudResp[kSendAlertV2FuncRespPhotoUrlKey];
                            
                            if([C411StaticHelper canUseJsonObject:strPhotoUrl]
                               && strPhotoUrl.length > 0){
                                
                                alert.strPhotoUrl = strPhotoUrl;
                            }
                        }
                        
                        alert.alertGenerationTimeInMillis = [dictCloudResp[kSendAlertV2FuncRespCreatedAtKey]doubleValue];
                        
                        alert.targetMembersCount = [dictCloudResp[kSendAlertV2FuncRespTargetMembersCountKey]integerValue];
                        alert.targetNauMembersCount = [dictCloudResp[kSendAlertV2FuncRespTargetNauMembersCountKey]integerValue];
                        
                        
                        [weakSelf finalizeAlert:alert withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                            
                            ///Hide the progress hud
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            
                            ///Call the completion block
                            if(completion != NULL){
                                
                                completion(succeeded, error);
                            }
                            
                            ///End background task
                            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.sendAlertTaskId];
                            
                        }];
                        
                    }
                    
                    
                }
                else{
                    
                    ///Hide the progress hud
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    ///show error
                    [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
                    
                    if(completion != NULL){
                        
                        completion(NO, nil);
                    }
                    
                    ///End background task
                    [[UIApplication sharedApplication] endBackgroundTask:weakSelf.sendAlertTaskId];
                    
                }
                
#if VIDEO_STREAMING_ENABLED
                ///Show stream video Popup
                C411Audience *audience = [alert.arrAudiences firstObject];
                if((audience.audienceType != AudienceTypePublicCellMembers)
                   && (alert.alertType != BTN_ALERT_TAG_PHOTO)){
                    
                    ///Alert sent, show Stream video popup
                    C411Alert *videoAlert = [[C411Alert alloc]init];
                    videoAlert.alertType = BTN_ALERT_TAG_VIDEO;
                    videoAlert.arrAudiences = alert.arrAudiences;
                    [weakSelf showStreamVideoPopupForAlert:videoAlert];
                    
                }
#endif
                
                
                
            }];
        }
        else{
            
            ///Some error occured
            ///Hide the progress hud
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            ///show error
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, try again later.", nil) onViewController:self];
            
            if(completion != NULL){
                
                completion(NO, nil);
            }
            
        }
    }
    else{
        
        ///Some error occured
        ///Hide the progress hud
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        ///show error
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Some error occurred, try again later.", nil) onViewController:self];
        
        if(completion != NULL){
            
            completion(NO, nil);
        }
        
    }
    
}

-(void)finalizeAlert:(C411Alert *)alert withCompletion:(PFBooleanResultBlock)completion
{
    
    ///Show Alert sent successfully message
    NSInteger alertReceiversCount = alert.targetMembersCount + alert.targetNauMembersCount;
    NSString *strToastMsg = nil;
    if(alertReceiversCount == 0){
        
        ///TODO: Prepare correct toast message for no members
        strToastMsg = NSLocalizedString(@"No members in the selected Cell", nil);
    }
    else{
        
        NSString *strAlertAudienceSuffix = nil;
        if(alertReceiversCount == 1){
        
            strAlertAudienceSuffix = NSLocalizedString(@"1 user", nil);
        }
        else{
        
            strAlertAudienceSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"%d users",nil),alertReceiversCount];

        }
        
        NSString *strMsgPrefix = NSLocalizedString(@"Alert", nil);
        if (alert.alertType == BTN_ALERT_TAG_PHOTO){
            
            strMsgPrefix = NSLocalizedString(@"Photo", nil);
        }
        
        strToastMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to %@",nil),strMsgPrefix,strAlertAudienceSuffix];
    }
    
    [AppDelegate showToastOnView:nil withMessage:strToastMsg];
    
    
    
    if ([C411AppDefaults canShowSecurityGuardOption]) {
        
        ///security Guard option is available for the app
        ///Check if include security guard option is enabled or not, if yes send alert to securtiy guards as well along with others
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL shouldIncludeSecGuards = [[defaults objectForKey:kIncludeSecurityGuards]boolValue];
        
        if (shouldIncludeSecGuards) {
            
            [self sendAlertToSecurityGuards:alert];
            
        }
        
        
    }

    ///set SECOND privilege if applicable
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    [C411StaticHelper setSecondPrivilegeIfApplicableForUser:currentUser];
    
    
#if APP_IER

    [self sendAlertToIERCallCenter:alert];
#endif
    
    
    ///Call the completion block
    if(completion != NULL){
        
        completion(YES, nil);
    }
}

-(void)sendAlertToSecurityGuards:(C411Alert *)alert
{
    ///Make an API call to notify Security Guards
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    
    [dictParams setObject:alert.strAlertId forKey:ALERT_PORTAL_USERS_API_PARAM_ALERT_ID];
    [dictParams setObject:alert.alertIssuer.objectId forKey:ALERT_PORTAL_USERS_API_PARAM_ISSUER_ID];
    [dictParams setObject:CLIENT_FIRM_ID forKey:API_PARAM_CLIENT_FIRM_ID];
    [dictParams setObject:IS_APP_LIVE forKey:API_PARAM_IS_LIVE];
    
    NSString *strMsgPrefix = (alert.alertType == BTN_ALERT_TAG_PHOTO) ?  NSLocalizedString(@"Photo", nil) : NSLocalizedString(@"Alert", nil);
    
    [ServerUtility sendAlertToSecurityGuardsWithDetails:dictParams andCompletion:^(NSError *error, id data) {
        
        if (!error) {
            
            ///show message that alert sent to security guards
            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to Security Guards",nil),strMsgPrefix];
            [AppDelegate showToastOnView:nil withMessage:strMessage];
            
        }
        else{
            
            ///show error
            NSString *strTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"Error Sending %@ to Security Guards",nil),strMsgPrefix];
            [C411StaticHelper showAlertWithTitle:strTitle message:error.localizedDescription onViewController:self];
        }
        
    }];

}

#if APP_IER
-(void)sendAlertToIERCallCenter:(C411Alert *)alert
{
    
        ///Make an IER API call as well for alerts
        if (alert.alertType == BTN_ALERT_TAG_PHOTO)
        {
            if (alert.strPhotoUrl.length > 0) {
                    
                    ///Make an IER API call as well for photo alerts
                    [self sendIERAlertFromIssuerWithId:alert.alertIssuer.objectId alertType:alert.strAlertType additionalNote:alert.strAdditionalNote locationCoordinate:alert.alertLocationCoordinate andPhotoUrl:alert.strPhotoUrl andCompletion:^(NSError *error, id data) {
                        
                        ///Do anything on completion
                        
                    }];
                    
                }
                
           
        }
        else{
            
            ///Make an IER API call as well for alerts other than Photo here
            [self sendIERAlertFromIssuerWithId:alert.alertIssuer.objectId alertType:alert.strAlertType additionalNote:alert.strAdditionalNote locationCoordinate:alert.alertLocationCoordinate andPhotoUrl:nil andCompletion:^(NSError *error, id data) {
                
                ///Do anything on completion
                
            }];
            
        }
        
        

    
}
#endif


-(void)sendNotificationWithType:(NSInteger)alertType toMembers:(NSArray *)arrAudience nauMembers:(NSArray *)arrNauAudience withAdditionalNote:(NSString *)strAdditionalNote andCompletion:(PFBooleanResultBlock)completion
{
    
#if (!VIDEO_STREAMING_ENABLED)
    ///return from this method if video streaming is not supported and somehow this method is called to issue video streaming alert
    if (alertType == BTN_ALERT_TAG_VIDEO) {
        
        return;
    }
    
#endif
    
    ///show hud on screen if it's not a panic or fallen alert
    if (alertType != BTN_ALERT_TAG_PANIC
        &&alertType != BTN_ALERT_TAG_FALLEN
        ) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    }
    
    PFUser *alertIssuer = [AppDelegate getLoggedInUser];
    NSString *alertIssuerFirstName = alertIssuer[kUserFirstnameKey];
    NSString *alertIssuerLastName = alertIssuer[kUserLastnameKey];
    NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:alertIssuerFirstName andLastName:alertIssuerLastName];
    //    NSString *strSubject = @"";
    //    NSString *strShareText = @"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    if ([defaults boolForKey:kPublishOnFB]
    //        && alertType != BTN_ALERT_TAG_VIDEO
    //        && alertType != BTN_ALERT_TAG_PHOTO) {
    //        ///Make sharing subject and text only if social media sharing is on and alert is not of video type or photo type
    //        strSubject = [NSString stringWithFormat:@"%@ %@",strFullName,kPayloadAlertMsgSuffix];
    //        strShareText = [C411StaticHelper getShareTextForUserWithName:strFullName alertType:alertType andAdditionalNote:strAdditionalNote];
    //    }
    
    __weak typeof(self) weakSelf = self;
    
    ///Make entry on Cell 411 alert table if user is streaming Video to Social Media or audience is greater than 0 or there is Nau members and send push only if audience is greater than 0
    if ((alertType == BTN_ALERT_TAG_VIDEO && self.audienceType == AudienceTypeOnlySocialMediaMembers)
        || self.audienceType == AudienceTypeSecurityGuards
        || arrAudience.count > 0
        || (arrNauAudience && arrNauAudience.count > 0)) {
        
        ///Filter the audience by removing the members who have spammed current user
        [[AppDelegate sharedInstance]filteredArrayByRemovingMembersInSpammedByRelationFromArray:arrAudience withCompletion:^(id result, NSError *error) {
            NSArray *arrFilteredAudience = (NSArray *)result;
            ///Update the audience array with this non spammed users
            weakSelf.arrAlertAudience = arrFilteredAudience;
            if ((alertType == BTN_ALERT_TAG_VIDEO && self.audienceType == AudienceTypeOnlySocialMediaMembers)
                || self.audienceType == AudienceTypeSecurityGuards
                || arrFilteredAudience.count > 0
                || (arrNauAudience && arrNauAudience.count > 0)) {
                ///Send alert to target audience
                
                ///1. Save it to Cell411Alert Table first
                
                ///Create object and initialize it
                PFObject *cell411Alert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                cell411Alert[kCell411AlertAdditionalNoteKey] = strAdditionalNote ? strAdditionalNote : @"";
                cell411Alert[kCell411AlertAlertTypeKey] = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
                cell411Alert[kCell411AlertIssuedByKey] = alertIssuer;
                cell411Alert[kCell411AlertIssuerFirstNameKey] = strFullName;
                cell411Alert[kCell411AlertIssuerIdKey] = alertIssuer.objectId;
                CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;

                if ([defaults boolForKey:kDispatchMode]
                    && alertType != BTN_ALERT_TAG_PANIC
                    && alertType != BTN_ALERT_TAG_FALLEN
                    && alertType != BTN_ALERT_TAG_VIDEO
                    && alertType != BTN_ALERT_TAG_PHOTO) {
                    
                    ///1.Update current location coordinate to custom location picked for dispatch mode
                    currentLocationCoordinate = weakSelf.dispatchLocation;
                    
                    ///2.Set dispatchMode key value to 1
                    cell411Alert[kCell411AlertDispatchModeKey] = @1;
                }
                cell411Alert[kCell411AlertLocationKey] = [PFGeoPoint geoPointWithLatitude:currentLocationCoordinate.latitude longitude:currentLocationCoordinate.longitude];
                
                cell411Alert[kCell411AlertTargetMembersKey] = arrFilteredAudience;
                if(arrNauAudience && arrNauAudience.count > 0)
                {
                    cell411Alert[kCell411AlertTargetNauMembersKey] = arrNauAudience;
                }
                if (alertType == BTN_ALERT_TAG_VIDEO) {
                    ///Set video streaming status
                    cell411Alert[kCell411AlertStatusKey] = kAlertStatusLive;
                }
                else if (alertType == BTN_ALERT_TAG_PHOTO
                         && weakSelf.photoFile){
                    ///Set photo file
                    cell411Alert[kCell411AlertPhotoKey] = weakSelf.photoFile;
                    
                    
                }
                
                ///Set isGloabl to 1 if this being sent to patrol members else 0
                NSNumber *isGlobalAlert = (weakSelf.audienceType == AudienceTypePatrolMembers) ? @1 : @0;
                cell411Alert[kCell411AlertIsGlobalKey] = isGlobalAlert;
                
                if (alertType != BTN_ALERT_TAG_PANIC
                    &&alertType != BTN_ALERT_TAG_FALLEN){
                    
                    
                    // Request a background execution task to allow us to finish saving the cell411Alert object  even if the app is backgrounded, especially in case of Photo alert which may take time
                    weakSelf.sendAlertTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                        [[UIApplication sharedApplication] endBackgroundTask:weakSelf.sendAlertTaskId];
                    }];
                
                }

                if (alertType == BTN_ALERT_TAG_VIDEO){
                    
                    ///1.Save this cell411Alert with data to update the empty cell411Alert record later when video status will be changed to LIVE from PROC_VID
                    weakSelf.cell411AlertForVdoStreamingWithData = cell411Alert;
                    
                    ///2.Make an empty PFObject for cell411Alert with status as PROC_VID in case of Video alerts as they will be under processing stage till 10 secs and then will be updated to LIVE status with above data and push will be send then to handle streaming errors.
                    cell411Alert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
                    cell411Alert[kCell411AlertStatusKey] = kAlertStatusProcessingVideo;
                    
                }
                //Save in background
                [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    
                    if (succeeded) {
                        if ((alertType != BTN_ALERT_TAG_VIDEO)
                            &&(alertType != BTN_ALERT_TAG_PHOTO)) {
                            
                            ///1. Show all ok option and save its associated data in App Delegate if alert is other than video streaming
                            //                            [AppDelegate sharedInstance].lastIssuedNeedyAlert = cell411Alert;
                            //                            [AppDelegate sharedInstance].showAllOkOption = YES;
                            //                            weakSelf.btnAllOk.hidden = NO;
                            
                        }
                        
                        ///2.An entry has been made successfully on Cell411Alert table regarding the notification and now you can send the notification to the target members
                        ///Get alert generation time in milliseconds
                        double alertGenerationTimeInMillis = [cell411Alert.createdAt timeIntervalSince1970] * 1000;
                        
                        if (alertType != BTN_ALERT_TAG_PANIC
                            &&alertType != BTN_ALERT_TAG_FALLEN){
                            
                            ///Show notification delivered alert
                            NSString *strAlertAudienceSuffix = nil;
                            
                            if (weakSelf.audienceType == AudienceTypeAllFriends) {
                                
                                strAlertAudienceSuffix = NSLocalizedString(@"All Friends", nil);
                            }
                            else if (weakSelf.audienceType == AudienceTypePrivateCellMembers){
                                
                                strAlertAudienceSuffix = [C411StaticHelper getLocalizedNameForCell:weakSelf.alertRecievingCell];
                            }
                            else if (weakSelf.audienceType == AudienceTypePatrolMembers){
                                
                                if (arrFilteredAudience.count == 1)
                                {
                                    strAlertAudienceSuffix = NSLocalizedString(@"1 user", nil);
                                    
                                }
                                else{
                                    
                                    strAlertAudienceSuffix = [NSString localizedStringWithFormat:NSLocalizedString(@"%d users",nil),(int)arrFilteredAudience.count];
                                }
                            }
                            
                            
                            NSString *strMsgPrefix = NSLocalizedString(@"Alert", nil);
                            if (alertType == BTN_ALERT_TAG_VIDEO) {
                                
                                strMsgPrefix = NSLocalizedString(@"Video link", nil);
                            }
                            else if (alertType == BTN_ALERT_TAG_PHOTO){
                                
                                strMsgPrefix = NSLocalizedString(@"Photo", nil);
                            }
                            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to %@",nil),strMsgPrefix,strAlertAudienceSuffix];
                            //M[C411StaticHelper showAlertWithTitle:nil andMessage:strMessage];
                            
                            if (alertType == BTN_ALERT_TAG_VIDEO) {
#if VIDEO_STREAMING_ENABLED
                                ///don't show any alertview if type is Video
                                ///1.Make stream name using format <objectId of current user>_<Cell411Alert object's createdAt milliseconds>
                                NSString *strStreamName = [NSString stringWithFormat:@"%@_%.0lf",alertIssuer.objectId,alertGenerationTimeInMillis];
                                ///2.save cell411alert object to be used to update status to LIVE/VOD when streaming screen closes
                                weakSelf.cell411AlertForVdoStreaming = cell411Alert;
                                
                                
                                ///3.Video link sent, Start streaming Video
                                [weakSelf startVideoStreamingWithStreamName:strStreamName];
#endif
                                
                            }
                            else if (weakSelf.audienceType != AudienceTypeSecurityGuards) {
                                ///show alert sent to if audience type is not security guards as that will be handled below
                                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                    
                                    ///Do anything required on OK action
                                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                        if(alertType != BTN_ALERT_TAG_PHOTO){
                                            
                                            ///Alert sent, show Stream video popup
                                            [weakSelf showStreamVideoPopup];
                                            
                                        }
                                        
                                        
                                    }];
                                    
                                    ///Dequeue the current Alert Controller and allow other to be visible
                                    [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                    
                                }];
                                
                                [alertController addAction:okAction];
                                //[weakSelf presentViewController:alertController animated:YES completion:NULL];
                                ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                                [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

                        
                        
                            }

                            if ([C411AppDefaults canShowSecurityGuardOption]) {
                                
                                ///security Guard option is available for the app
                                ///Check if include security guard option is enabled or not, if yes send alert to securtiy guards as well along with others
                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                BOOL shouldIncludeSecGuards = [[defaults objectForKey:kIncludeSecurityGuards]boolValue];
                                
                                if (self.audienceType == AudienceTypeSecurityGuards
                                    || shouldIncludeSecGuards) {
                                    
                                    ///Alert is especially sent to Security Guards or it's included with other option, Make an API call to notify Security Guards
                                    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
                                    
                                    [dictParams setObject:cell411Alert.objectId forKey:ALERT_PORTAL_USERS_API_PARAM_ALERT_ID];
                                    [dictParams setObject:alertIssuer.objectId forKey:ALERT_PORTAL_USERS_API_PARAM_ISSUER_ID];
                                    [dictParams setObject:CLIENT_FIRM_ID forKey:API_PARAM_CLIENT_FIRM_ID];
                                    [dictParams setObject:IS_APP_LIVE forKey:API_PARAM_IS_LIVE];
                                    
                                    
                                    [ServerUtility sendAlertToSecurityGuardsWithDetails:dictParams andCompletion:^(NSError *error, id data) {
                                        
                                        if (!error) {
                                            
                                            ///show message that alert sent to security guards
                                            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to Security Guards",nil),strMsgPrefix];
                                            [AppDelegate showToastOnView:weakSelf.view withMessage:strMessage];
                                            
                                        }
                                        else{
                                            
                                            ///show error
                                            NSString *strTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"Error Sending %@ to Security Guards",nil),strMsgPrefix];
                                            [C411StaticHelper showAlertWithTitle:strTitle message:error.localizedDescription onViewController:weakSelf];
                                        }
                                        
                                    }];
                                }
                               
                                
                            }

                        
                        
                        }
     
                        ///Send push notification and set privilege only if members are greater than 0
                        if (arrFilteredAudience.count > 0) {
                            
                            ///Create Payload data
                            NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                            NSString *strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"issued an emergency alert!", nil)];
                            if (alertType == BTN_ALERT_TAG_VIDEO) {

                                strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"is streaming live video!", nil)];
                            }
                            else if (alertType == BTN_ALERT_TAG_PHOTO){
                                
                                strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"issued a photo alert!", nil)];
                            }
                            else if (alertType == BTN_ALERT_TAG_PANIC){
                                
                                strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"issued a panic alert!", nil)];
                            }
                            else if (alertType == BTN_ALERT_TAG_FALLEN){
                                
                                strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"issued a fallen alert!", nil)];
                            }
                            
                            dictData[kPayloadAlertKey] = strAlertMsg;
                            dictData[kPayloadAlertRegardingKey] = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
                            dictData[kPayloadUserIdKey] = alertIssuer.objectId;
                            dictData[kPayloadCell411AlertIdKey] = cell411Alert.objectId;
                            dictData[kPayloadLatKey] = @(currentLocationCoordinate.latitude);
                            dictData[kPayloadLonKey] = @(currentLocationCoordinate.longitude);
                            dictData[kPayloadAdditionalNoteKey] = strAdditionalNote ? strAdditionalNote : @"";
                            
                            dictData[kPayloadCreatedAtKey] = @(alertGenerationTimeInMillis);
                            dictData[kPayloadFirstNameKey] = strFullName;
                            if (alertType == BTN_ALERT_TAG_VIDEO) {
                                
                                dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeVideo;
                            }
                            else if (alertType == BTN_ALERT_TAG_PHOTO) {
                                
                                dictData[kPayloadAlertTypeKey] = kPayloadAlertTypePhoto;
                            }
                            else{
                                
                                dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeNeedy;
                            }
                            
                            dictData[kPayloadSoundKey] = @"default";///To play default sound
                            dictData[kPayloadIsGlobalKey] = isGlobalAlert;///Set GloablAlert value
                            dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                            
                            if ([defaults boolForKey:kDispatchMode]
                                && alertType != BTN_ALERT_TAG_PANIC
                                && alertType != BTN_ALERT_TAG_FALLEN
                                && alertType != BTN_ALERT_TAG_VIDEO
                                && alertType != BTN_ALERT_TAG_PHOTO) {
                                
                                ///1.Set dispatchMode key value to 1 to payload data, otherwise do not set
                                dictData[kPayloadDispatchModeKey] = @1;
                            }
                            
                            
                            // Create our Installation query
                            PFQuery *pushQuery = [PFInstallation query];
                            [pushQuery whereKey:kInstallationUserKey containedIn:arrFilteredAudience];
                            
                            // Send push notification to query
                            PFPush *push = [[PFPush alloc] init];
                            [push setQuery:pushQuery]; // Set our Installation query
                            [push setData:dictData];
                            if (alertType == BTN_ALERT_TAG_VIDEO) {
                                ///Save its reference to send push after video start streaming
                                weakSelf.videoPush = push;
                            }
                            else{
                                
                                ///Send Push notification
                                [push sendPushInBackground];
                            }
                            
                            ///set Second privilege if applicable
                            NSString *strPrivilege = alertIssuer[kUserPrivilegeKey];
                            
                            if (([isGlobalAlert intValue] !=1)
                                &&((!strPrivilege)
                                   || (strPrivilege.length == 0)
                                   ||([strPrivilege isEqualToString:kPrivilegeTypeFirst]))) {
                                    ///this is an alert other than Global alert and privilege is either FIRST or unset
                                    ///get the friends count for current user
                                    [C411StaticHelper getFriendCountForUser:alertIssuer withCompletion:^(int number, NSError * _Nullable error) {
                                        
                                        ///check the friend count
                                        if (!error) {
                                            
                                            if (number >= MIN_FRIENDS_FOR_SECOND_PRIVILEGE) {
                                                
                                                ///save the privilege as SECOND
                                                [C411StaticHelper savePrivilege:kPrivilegeTypeSecond forUser:alertIssuer withOptionalCompletion:NULL];
                                                
                                            }
                                            
                                            
                                        }
                                        else{
                                            ///show error
                                            NSString *errorString = [error userInfo][@"error"];
                                            NSLog(@"issue alert check privilege -> error getting friend count %@",errorString);
                                            
                                        }
                                        
                                    }];
                                    
                                }
                            
                        }

#if NON_APP_USERS_ENABLED

                        ///Send alert to NAU Members if available
                        if(arrNauAudience
                           && arrNauAudience.count > 0
                           && alertType != BTN_ALERT_TAG_VIDEO){
                            
                            if(alertType == BTN_ALERT_TAG_PANIC
                               || alertType == BTN_ALERT_TAG_FALLEN){
                            
                                ///Call Panic cloud function to send panic or fallen alert to Nau Contacts
                                [weakSelf sendPanicOrFallenAlertToNauCellWithAlertType:alertType cell411AlertObjectId:cell411Alert.objectId andNauMembers:arrNauAudience];
                            }
                            else{
                                
                                ///Call Sms and email v2 cloud function to send other alerts except panic, fallen and video alert to Nau Contact
                                [weakSelf sendAlertToNauCellWithAlertType:alertType cellId:weakSelf.alertRecievingCell.objectId cell411AlertObjectId:cell411Alert.objectId andImgUrl:weakSelf.photoFile.url];
                                
                            }
                            
                        }
 
#endif
                        
#if APP_IER
     
                        ///Make an IER API call as well for alerts
                        NSString *strAlertTypeForIER = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
                        NSString *strImgUrl = nil;
                        if (alertType == BTN_ALERT_TAG_PHOTO
                            && weakSelf.photoFile){
                            ///Set photo url
                            strImgUrl = weakSelf.photoFile.url;
                            
                            
                        }
                        [weakSelf sendIERAlertFromIssuerWithId:alertIssuer.objectId alertType:strAlertTypeForIER additionalNote:strAdditionalNote locationCoordinate:currentLocationCoordinate andPhotoUrl:strImgUrl andCompletion:^(NSError *error, id data) {
                            
                            ///Do anything on completion
                            
                        }];
                        
#endif
                        
                        if (alertType != BTN_ALERT_TAG_PANIC
                            &&alertType != BTN_ALERT_TAG_FALLEN){
                            
                            ///End background task
                            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.sendAlertTaskId];
                        }

                        
                        if (completion != NULL) {
                            
                            ///call the completion block
                            completion(YES,nil);
                        }
                        
                    }
                    else{
                        
                        if (alertType != BTN_ALERT_TAG_PANIC
                            &&alertType != BTN_ALERT_TAG_FALLEN){
                            
                            ///End background task
                            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.sendAlertTaskId];
                            
                            if (error) {
                                if(![AppDelegate handleParseError:error]){
                                    ///show error
                                    NSString *errorString = [error userInfo][@"error"];
                                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:errorString preferredStyle:UIAlertControllerStyleAlert];
                                
                                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                    
                                        ///Do anything required on OK action
                                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                                            if ((alertType != BTN_ALERT_TAG_VIDEO)
                                                &&(alertType != BTN_ALERT_TAG_PHOTO)) {
                                                ///Show  streaming option only if error occured while making entry on Cell411Alert table for alertType other than Video or Photo
                                                ///Show popup asking to stream video
                                                [self showStreamVideoPopup];
                                            
                                            }
                                        
                                        
                                        }];
                                    
                                        ///Dequeue the current Alert Controller and allow other to be visible
                                        [[MAAlertPresenter sharedPresenter]dequeueAlert];
                                    
                                    }];
                                
                                    [alertController addAction:okAction];
                                    //[weakSelf presentViewController:alertController animated:YES completion:NULL];
                                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
                                }
                                
                            }
                            
                        }
                        
                        if (completion != NULL) {
                            
                            ///call the completion block
                            completion(NO,nil);
                        }
                        
                    }
                    
                    if (alertType != BTN_ALERT_TAG_PANIC
                        &&alertType != BTN_ALERT_TAG_FALLEN){
                       
                        ///remove the hud
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    }
                    
                    

                    
                }];
                
                
            }
            else{
                
                ///remove the hud and do other handling if it's not a panic or fallen alert
                if (alertType != BTN_ALERT_TAG_PANIC
                    &&alertType != BTN_ALERT_TAG_FALLEN){
                    
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    ///Show no members alert
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                        ///Do anything required on OK action
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            
                            if (alertType != BTN_ALERT_TAG_PHOTO) {
                                ///Try to stream only if its not photo alert
                                ///Show popup asking to stream video
                                [self showStreamVideoPopup];
                            }
                            
                            
                        }];
                        
                        ///Dequeue the current Alert Controller and allow other to be visible
                        [[MAAlertPresenter sharedPresenter]dequeueAlert];
                        
                    }];
                    
                    [alertController addAction:okAction];
                    //[weakSelf presentViewController:alertController animated:YES completion:NULL];
                    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
                    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
                    

                    
                }
                else{
                    
#if APP_IER
                    
                    ///Make an IER API call as well for panic or fallen alerts
                    
                    NSString *strAlertType = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
                    CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;

                    [self sendIERAlertFromIssuerWithId:alertIssuer.objectId alertType:strAlertType additionalNote:strAdditionalNote locationCoordinate:currentLocationCoordinate andPhotoUrl:nil andCompletion:^(NSError *error, id data) {
                        
                        ///Do anything on completion
                        
                    }];
                    
#endif
                    
                }

                if (completion != NULL) {
                    
                    ///call the completion block
                    completion(NO,nil);
                }

                
            }
        }];
        
        
        
        
    }
    else{
        
        ///remove the hud and do other handling if it's not a panic or fallen alert
        if (alertType != BTN_ALERT_TAG_PANIC
            &&alertType != BTN_ALERT_TAG_FALLEN){
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            ///Show no members alert
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"No members in the selected Cell", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                ///Do anything required on OK action
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    
                    if (alertType != BTN_ALERT_TAG_PHOTO) {
                        ///Try to stream only if its not photo alert
                        ///Show popup asking to stream video
                        [self showStreamVideoPopup];
                    }
                    
                    
                    
                }];
                
                ///Dequeue the current Alert Controller and allow other to be visible
                [[MAAlertPresenter sharedPresenter]dequeueAlert];
                
            }];
            
            [alertController addAction:okAction];
            //[weakSelf presentViewController:alertController animated:YES completion:NULL];
            ///Enqueue the alert controller object in the presenter queue to be displayed one by one
            [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];
            

        }
        else{
            
#if APP_IER

            ///Make an IER API call as well for panic or fallen alerts
            
            NSString *strAlertType = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
            CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;

            [self sendIERAlertFromIssuerWithId:alertIssuer.objectId alertType:strAlertType additionalNote:strAdditionalNote locationCoordinate:currentLocationCoordinate andPhotoUrl:nil andCompletion:^(NSError *error, id data) {
                
                ///Do anything on completion
                
            }];
            
#endif

        }
        
        
        if (completion != NULL) {
            
            ///call the completion block
            completion(NO,nil);
        }
        
    }
    

    
    //    NSString *strAlertMessage = @"";
//    COMMENTING IT AS IT IS NOT ALLOWING OTHRE ALERTS TO BE PRESENTED DUE TO THE RESTRICTION IN UIALERTCONTROLLER WHICH SUPPRESS OTHRE ALERTS FROM DISPLAYING IF ONE ALERT IS ON SCREEN
//     if (alertType == BTN_ALERT_TAG_MEDICAL_ATTENTION) {
//     
//     ///Flash the medical details of the user
//     NSMutableString *strMedicalDetails = [NSMutableString stringWithString:@""];
//     
//     NSString *strBloodType = alertIssuer[kUserBloodTypeKey];
//     if (strBloodType.length > 0) {
//     ///Append Blood type info
//     [strMedicalDetails appendFormat:@"\n%@: %@",NSLocalizedString(@"Blood Type", nil),strBloodType];
//     }
//     NSString *strAllergies = alertIssuer[kUserAllergiesKey];
//     if (strAllergies.length > 0) {
//     
//     ///Append Allergies info
//     [strMedicalDetails appendFormat:@"\n%@: %@",NSLocalizedString(@"Allergies", nil),strAllergies];
//     
//     }
//     
//     NSString *strOMC = alertIssuer[kUserOtherMedicalCondtionsKey];
//     if (strOMC.length > 0) {
//     
//     ///Append Other Medical Conditions info
//     [strMedicalDetails appendFormat:@"\n%@: %@",NSLocalizedString(@"Other Medical Conditions", nil),strOMC];
//     }
//     
//     if (strMedicalDetails.length > 0) {
//     
//     ///Show alert screen if any medical detail is available
//     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Medical Details", nil) message:strMedicalDetails preferredStyle:UIAlertControllerStyleAlert];
//     UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//     
//     ///Do anything required on OK action
//     
//     }];
//     
//     [alertController addAction:okAction];
//     [weakSelf presentViewController:alertController animated:YES completion:NULL];
//     
//     
//     }
//     
//     }
    
    
}

-(void)showAlertSentPopupWithAlertParams:(NSDictionary *)dictAlertParams andResult:(NSDictionary *)dictResult
{
#if (VIDEO_STREAMING_ENABLED)
    
    AlertType alertType = (AlertType)[dictAlertParams[kSendAlertV3FuncParamAlertIdKey]integerValue];
    BOOL canShowVideoStreamOption = NO;
    if(alertType != AlertTypePhoto
       && alertType != AlertTypeVideo){
        canShowVideoStreamOption = YES;
    }
    
    if(canShowVideoStreamOption){
        ///It will show stream video Popup and if user cancel it then clear the associated iVars
        self.videoStreamPopupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411VideoStreamPopupVC"];
        self.videoStreamPopupVC.delegate = self;
        NSString *strPopupTitle = NSLocalizedString(@"Do you also want to start streaming live video?", nil);
        
        self.videoStreamPopupVC.strPopupTitle = strPopupTitle;
        self.videoStreamPopupVC.dictAlertParams = dictAlertParams;
        self.videoStreamPopupVC.dictResult = dictResult;
        self.videoStreamPopupVC.canShowVideoStreamOption = canShowVideoStreamOption;
        UIView *vuVideoStreamPopup = self.videoStreamPopupVC.view;
        //UIView *vuRootVC = [AppDelegate sharedInstance].window.rootViewController.view;
        UIView *vuTabBarController = self.tabBarController.view;
        vuVideoStreamPopup.frame = vuTabBarController.frame;
        [vuTabBarController addSubview:vuVideoStreamPopup];
        [vuTabBarController bringSubviewToFront:vuVideoStreamPopup];
        vuVideoStreamPopup.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
#endif
}

//-(void)showStreamVideoPopupForAlertWithAlertParams:(NSDictionary *)dictAlertParams
//{
//#if VIDEO_STREAMING_ENABLED
//
//    ///It will show stream video Popup and if user cancel it then clear the associated iVars
//    self.videoStreamPopupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411VideoStreamPopupVC"];
//    self.videoStreamPopupVC.delegate = self;
//    NSString *strPopupTitle = NSLocalizedString(@"Do you also want to start streaming live video?", nil);
//
//    self.videoStreamPopupVC.strPopupTitle = strPopupTitle;
//    self.videoStreamPopupVC.dictAlertParams = dictAlertParams;
//    UIView *vuVideoStreamPopup = self.videoStreamPopupVC.view;
//    UIView *vuRootVC = [AppDelegate sharedInstance].window.rootViewController.view;
//    vuVideoStreamPopup.frame = vuRootVC.frame;
//    [vuRootVC addSubview:vuVideoStreamPopup];
//    [vuRootVC bringSubviewToFront:vuVideoStreamPopup];
//    vuVideoStreamPopup.translatesAutoresizingMaskIntoConstraints = YES;
//#endif
//
//}


-(void)showStreamVideoPopupForAlert:(C411Alert *)alert
{
#if VIDEO_STREAMING_ENABLED
    
    ///It will show stream video Popup and if user cancel it then clear the associated iVars
    self.videoStreamPopupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411VideoStreamPopupVC"];
    self.videoStreamPopupVC.delegate = self;
    NSString *strPopupTitle = NSLocalizedString(@"Do you also want to start streaming live video?", nil);
    C411Audience *audience = [alert.arrAudiences firstObject];
    if (audience.audienceType == AudienceTypePatrolMembers) {
        
        strPopupTitle = NSLocalizedString(@"Do you also want to start streaming live video globally?", nil);
    }
    else if (audience.audienceType == AudienceTypeAllFriends){
        
        strPopupTitle = NSLocalizedString(@"Do you also want to start streaming live video to all friends?", nil);
    }
    else if (audience.audienceType == AudienceTypePrivateCellMembers){
        
        NSString *strCellName = [C411StaticHelper getLocalizedNameForCell:audience.audienceCell];
        if (strCellName.length > 0) {
            
            strPopupTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"Do you also want to start streaming live video to the %@ Cell?",nil),strCellName];
        }
    }
    self.videoStreamPopupVC.strPopupTitle = strPopupTitle;
    self.videoStreamPopupVC.alert = alert;
    UIView *vuVideoStreamPopup = self.videoStreamPopupVC.view;
    UIView *vuRootVC = [AppDelegate sharedInstance].window.rootViewController.view;
    vuVideoStreamPopup.frame = vuRootVC.frame;
    [vuRootVC addSubview:vuVideoStreamPopup];
    [vuRootVC bringSubviewToFront:vuVideoStreamPopup];
    vuVideoStreamPopup.translatesAutoresizingMaskIntoConstraints = YES;
#endif
    
}


-(void)showStreamVideoPopup
{
#if VIDEO_STREAMING_ENABLED

    ///It will show stream video Popup and if user cancel it then clear the associated iVars
    self.videoStreamPopupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411VideoStreamPopupVC"];
    self.videoStreamPopupVC.delegate = self;
    NSString *strPopupTitle = NSLocalizedString(@"Do you also want to start streaming live video?", nil);
    if (self.audienceType == AudienceTypePatrolMembers) {
        
        strPopupTitle = NSLocalizedString(@"Do you also want to start streaming live video globally?", nil);
    }
    else if (self.audienceType == AudienceTypeAllFriends){
        
        strPopupTitle = NSLocalizedString(@"Do you also want to start streaming live video to all friends?", nil);
    }
    else if (self.audienceType == AudienceTypePrivateCellMembers){
        
        NSString *strCellName = [C411StaticHelper getLocalizedNameForCell:self.alertRecievingCell];
        if (strCellName.length > 0) {
            
            strPopupTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"Do you also want to start streaming live video to the %@ Cell?",nil),strCellName];
        }
    }
    self.videoStreamPopupVC.strPopupTitle = strPopupTitle;
    
    UIView *vuVideoStreamPopup = self.videoStreamPopupVC.view;
    UIView *vuRootVC = [AppDelegate sharedInstance].window.rootViewController.view;
    vuVideoStreamPopup.frame = vuRootVC.frame;
    [vuRootVC addSubview:vuVideoStreamPopup];
    [vuRootVC bringSubviewToFront:vuVideoStreamPopup];
    vuVideoStreamPopup.translatesAutoresizingMaskIntoConstraints = YES;
#endif
    
}

#if VIDEO_STREAMING_ENABLED
-(void)dismissVideoStreamPopup:(C411VideoStreamPopupVC *)videoStreamPopup
{
    videoStreamPopup.delegate = nil;
    [videoStreamPopup.view removeFromSuperview];
    self.videoStreamPopupVC = nil;
}


-(void)startVideoStreamingWithStreamName:(NSString *)strStreamName
{
    ///It will start the video streaming and finally will clear the associated iVars
    
    ///1.Stream video
    //C411VideoBroadcastingVC *videoBroadcastingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411VideoBroadcastingVC"];
    VideoPlayerViewController *videoBroadcastingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
    
    videoBroadcastingVC.strStreamName = strStreamName;
    videoBroadcastingVC.delegate = self;
    ///push the vidoeBroadcastingVC on mainInterface navigation controller which is the root viewController, this will hide all the tabs and will not allow user to change tab or do anything else while recording
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:videoBroadcastingVC animated:YES];
    
    ///2.Clear the alert associated ivars only if sending alert for video, otherwise it will be cleared on cancel of streaming popup
    [self clearAlertAssociatedIVars];
    
    ///Don't allow the app to sleep if idle, as streaming is in progress
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}

-(void)streamVideoWithAlertParams:(NSDictionary *)dictAlertParams
{
    ///TODO:
    ///Create object and initialize it
    PFObject *cell411Alert = [PFObject objectWithClassName:kCell411AlertClassNameKey];
    cell411Alert[kCell411AlertStatusKey] = kAlertStatusProcessingVideo;
    
    //Save in background
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [cell411Alert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (succeeded) {
            
            ///1.Make stream name using format <objectId of current user>_<Cell411Alert object's createdAt milliseconds>
            PFUser *currentUser = [AppDelegate getLoggedInUser];
            double alertGenerationTimeInMillis = [cell411Alert.createdAt timeIntervalSince1970] * 1000;
            NSString *strStreamName = [NSString stringWithFormat:@"%@_%.0lf",currentUser.objectId,alertGenerationTimeInMillis];
            
            ///2.save cell411alert objectId to be used to update status to LIVE/VOD when streaming screen closes
            weakSelf.cell411AlertForVdoStreaming = cell411Alert;
            NSMutableDictionary *dictVideoAlertParams = (NSMutableDictionary *)dictAlertParams;
            dictVideoAlertParams[kSendAlertV3FuncParamCell411AlertIdKey] = cell411Alert.objectId;
            
            
            ///3.start the video streaming and finally will clear the associated iVars
            VideoPlayerViewController *videoBroadcastingVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"VideoPlayerViewController"];
            
            videoBroadcastingVC.strStreamName = strStreamName;
            videoBroadcastingVC.dictAlertParams = dictVideoAlertParams;
            videoBroadcastingVC.delegate = weakSelf;
            ///push the vidoeBroadcastingVC on mainInterface navigation controller which is the root viewController, this will hide all the tabs and will not allow user to change tab or do anything else while recording
            UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
            [rootNavC pushViewController:videoBroadcastingVC animated:YES];
            
            ///Don't allow the app to sleep if idle, as streaming is in progress
            [UIApplication sharedApplication].idleTimerDisabled = YES;

        }
        else if (error) {
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
            }
        }
    }];
    
}

#endif

//-(void)updateOneTimeLocationUsingStandardLocationProvider
//{
//
//    ///create a one time location manager to get user's location instantly for the first time or when app comes to Foreground as the Pathsense is taking time to deliver location update for the first time. Stop this location update once fetched
//    if (!_oneTimeLocManager) {
//
//        _oneTimeLocManager = [[CLLocationManager alloc]init];
//        ///fetch the location accurate to within 100 meters
//        _oneTimeLocManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//        ///Help improve battery life
//        _oneTimeLocManager.pausesLocationUpdatesAutomatically = YES;
//        _oneTimeLocManager.delegate = self;
//        [_oneTimeLocManager startUpdatingLocation];
//
//    }
//
//}

-(void)sendAlertToPublicCellWithAdditionalNote:(NSString *)strAdditionalNote alertType:(NSInteger)alertType onCellWithId:(NSString *)strCellId cellName:(NSString *)strCellName shouldCallIEREndPoint:(BOOL)shouldCallIEREndPoint
{
    PFUser *alertIssuer = [AppDelegate getLoggedInUser];
    NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:alertIssuer[kUserFirstnameKey] andLastName:alertIssuer[kUserLastnameKey]];
    
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kSendAlertFuncParamNameKey] = strFullName;
    dictParams[kSendAlertFuncParamIssuerIdKey] = alertIssuer.objectId;
    NSInteger weakAlertTypeTag = alertType;
    NSString *strAlertType = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
    dictParams[kSendAlertFuncParamAlertTypeKey] =  strAlertType;
    dictParams[kSendAlertFuncParamAdditionalNoteKey] = strAdditionalNote;
    dictParams[kSendAlertFuncParamCellObjectIdKey] = strCellId;
    dictParams[kSendAlertFuncParamCellNameKey] = strCellName;
    if (alertType == BTN_ALERT_TAG_PHOTO) {
        
        dictParams[kSendAlertFuncParamIsPhotoAlertKey] = @(YES);
        if (self.photoData) {
            
            dictParams[kSendAlertFuncParamImageBytesKey] = self.photoData;
            
        }
    }
    else{
        dictParams[kSendAlertFuncParamIsPhotoAlertKey] = @(NO);
    }
    
    CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kDispatchMode]
        && alertType != BTN_ALERT_TAG_PHOTO
        && alertType != BTN_ALERT_TAG_PANIC
        && alertType != BTN_ALERT_TAG_FALLEN) {
        
        dictParams[kSendAlertFuncParamDispatchModeKey] = @(1);
        currentLocationCoordinate = self.dispatchLocation;
    }
    else{
        dictParams[kSendAlertFuncParamDispatchModeKey] = @(2);
    }
    dictParams[kSendAlertFuncParamLatKey] = @(currentLocationCoordinate.latitude);
    dictParams[kSendAlertFuncParamLongKey] = @(currentLocationCoordinate.longitude);
    __weak typeof(self) weakSelf = self;

    [C411StaticHelper sendAlertWithDetails:dictParams andCompletion:^(id object, NSError *error) {
        
        if (!error) {
            
            if (weakAlertTypeTag != BTN_ALERT_TAG_PANIC
                && weakAlertTypeTag != BTN_ALERT_TAG_FALLEN) {
                
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Alert sent successfully", nil)];
            }
            
            
            ///Read the alert id from json string returned from cloud function as object and publish on facebook if allowed
            NSDictionary *dictCloudResp = nil;
            if (object && [object isKindOfClass:[NSString class]]) {
                
                NSData *jsonData = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err = nil;
                dictCloudResp = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                if (err) {
                    
                    NSLog(@"Error retriving data from Public Cell cloud response, error -> %@",err.localizedDescription);
                }
            }
            
            if ([C411AppDefaults canShowSecurityGuardOption]
                && (weakAlertTypeTag != BTN_ALERT_TAG_VIDEO)
                && (weakAlertTypeTag != BTN_ALERT_TAG_PANIC)
                && (weakAlertTypeTag != BTN_ALERT_TAG_FALLEN)
                && ([dictCloudResp isKindOfClass:[NSDictionary class]])) {
                
                ///security Guard option is available for the app
                ///Check if include security guard option is enabled or not, if yes send alert to securtiy guards as well along with others
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                BOOL shouldIncludeSecGuards = [[defaults objectForKey:kIncludeSecurityGuards]boolValue];
                
                if (shouldIncludeSecGuards) {
                    
                    ///Send alert to Security Guards is included with other option, Make an API call to notify Security Guards
                    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
                    
                    NSString *strCell411AlertId = dictCloudResp[kSendAlertFuncRespCell411AlertIdKey];
                    [dictParams setObject:strCell411AlertId forKey:ALERT_PORTAL_USERS_API_PARAM_ALERT_ID];
                    [dictParams setObject:alertIssuer.objectId forKey:ALERT_PORTAL_USERS_API_PARAM_ISSUER_ID];
                    [dictParams setObject:CLIENT_FIRM_ID forKey:API_PARAM_CLIENT_FIRM_ID];
                    [dictParams setObject:IS_APP_LIVE forKey:API_PARAM_IS_LIVE];
                    

                    
                    [ServerUtility sendAlertToSecurityGuardsWithDetails:dictParams andCompletion:^(NSError *error, id data) {
                        
                        NSString *strMsgPrefix = NSLocalizedString(@"Alert", nil);
                        if (alertType == BTN_ALERT_TAG_PHOTO){
                            
                            strMsgPrefix = NSLocalizedString(@"Photo", nil);
                        }
                        if (!error) {
    
                            ///show message that alert sent to security guards
                            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ sent to Security Guards",nil),strMsgPrefix];
                            [AppDelegate showToastOnView:weakSelf.view withMessage:strMessage];
                            
                        }
                        else{
                            
                            ///show error
                            NSString *strTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"Error Sending %@ to Security Guards",nil),strMsgPrefix];
                            [C411StaticHelper showAlertWithTitle:strTitle message:error.localizedDescription onViewController:weakSelf];
                        }
                        
                    }];
                }
                
                
            }
      
#if APP_IER
            
            if (shouldCallIEREndPoint) {
                
                ///Make an IER API call as well for alerts
                if (weakAlertTypeTag == BTN_ALERT_TAG_PHOTO)
                {
                    if ([dictCloudResp isKindOfClass:[NSDictionary class]]) {
                        
                        ///add image url if available
                        NSString *strPhotoUrl = dictCloudResp[kSendAlertFuncRespPhotoUrlKey];
                        if ([C411StaticHelper canUseJsonObject:strPhotoUrl] && strPhotoUrl.length > 0) {
                            
                            ///Make an IER API call as well for photo alerts
                            [weakSelf sendIERAlertFromIssuerWithId:alertIssuer.objectId alertType:strAlertType additionalNote:strAdditionalNote locationCoordinate:currentLocationCoordinate andPhotoUrl:strPhotoUrl andCompletion:^(NSError *error, id data) {
                                
                                ///Do anything on completion
                                
                            }];
                            
                        }
                        
                    }
                    
                }
                else{
                    
                    ///Make an IER API call as well for alerts other than Photo here
                    [weakSelf sendIERAlertFromIssuerWithId:alertIssuer.objectId alertType:strAlertType additionalNote:strAdditionalNote locationCoordinate:currentLocationCoordinate andPhotoUrl:nil andCompletion:^(NSError *error, id data) {
                        
                        ///Do anything on completion
                        
                    }];
                    
                }
                
                
            }
#endif
        }
        else{
            
            ///show error
            if (weakAlertTypeTag != BTN_ALERT_TAG_PANIC
                && weakAlertTypeTag != BTN_ALERT_TAG_FALLEN) {
                
                [C411StaticHelper showAlertWithTitle:nil message:error.localizedDescription onViewController:weakSelf];
            }
            else{
                
                ///Log the error
                NSLog(@"Error sending alert on Public Cell %@->%@",strCellName,error.localizedDescription);
            }
        }
        
        if (weakAlertTypeTag != BTN_ALERT_TAG_PANIC
            && weakAlertTypeTag != BTN_ALERT_TAG_FALLEN) {
            
            ///Clear ivars only if it's not a panic or fallen alert
            [weakSelf clearAlertAssociatedIVars];

        }
        
        
    }];
    
}


-(void)showPanicOrFallenAlertWithAlertType:(NSInteger)alertType
{
    
    ///Fetch the user priviliges and validate that first
    ///Show progress hud
    UIView *rootView = [AppDelegate sharedInstance].window.rootViewController.view;
    [MBProgressHUD showHUDAddedTo:rootView animated:YES];
    
    __weak typeof(self) weakSelf = self;
    ///get the privilege set for the user
    [C411StaticHelper getPrivilegeForUser:[AppDelegate getLoggedInUser] shouldSetPrivilegeIfUndefined:YES andCompletion:^(NSString * _Nullable string, NSError * _Nullable error) {
        
        ///Hide the hud
        [MBProgressHUD hideHUDForView:rootView animated:YES];
        
        NSString *strPrivilege = string;
        if ((!strPrivilege)
            ||(strPrivilege.length == 0)) {
            
            ///some error occured fetching privilege
            NSLog(@"#error fetching privilege : %@",error.localizedDescription);
            
        }
        
        if ([strPrivilege isEqualToString:kPrivilegeTypeBanned]){
            
            ///This user account is banned, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else if ([strPrivilege hasPrefix:kPrivilegeTypeSuspended]){
            
            ///This user account is suspended, log him out of the app
            [[AppDelegate sharedInstance]userDidLogout];
            
        }
        else{
            
            ///privilege is either FIRST, SECOND or SHADOW_BANNED.
            ///TODO:User can issue Panic or fallen alert, show the popup with the timer
            C411PanicButtonAlertOverlay *vuPanicButtonAlertOverlay = [[[NSBundle mainBundle] loadNibNamed:@"C411PanicButtonAlertOverlay" owner:weakSelf options:nil] lastObject];
            ///alertType should be called last
            vuPanicButtonAlertOverlay.alertType = alertType;
            UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
            ///Set view frame
            vuPanicButtonAlertOverlay.frame = rootVC.view.bounds;
            ///add view
            [rootVC.view addSubview:vuPanicButtonAlertOverlay];
            [rootVC.view bringSubviewToFront:vuPanicButtonAlertOverlay];

        }
        
    }];
    
    
}


-(void)getPrivateCellMembersOfCellsWithIds:(NSArray *)arrPrivateCellIds withCompletion:(PFIdResultBlock)completion
{
    
    PFQuery *getCellsQuery = [PFQuery queryWithClassName:kCellClassNameKey];
    [getCellsQuery includeKey:kCellMembersKey];
    [getCellsQuery includeKey:kCellNauMembersKey];
    [getCellsQuery whereKey:@"objectId" containedIn:arrPrivateCellIds];
    [getCellsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        NSMutableArray *arrAllPrivateCellMembers = nil;
        NSMutableArray *arrAllPrivateCellNauMembers = nil;

        if (!error) {
            
            ///Iterate the array of cells and append the cell members
            arrAllPrivateCellMembers = [NSMutableArray array];
            arrAllPrivateCellNauMembers = [NSMutableArray array];
            for (PFObject *cell in objects) {
                
                ///Get the cell members
                NSArray *arrCellMembers = cell[kCellMembersKey];
                if (arrCellMembers && arrCellMembers.count > 0) {
                    
                    [arrAllPrivateCellMembers addObjectsFromArray:arrCellMembers];
                    
                }
                
                ///Get the cell nau members
                NSArray *arrCellNauMembers = cell[kCellNauMembersKey];
                if (arrCellNauMembers && arrCellNauMembers.count > 0) {
                    
                    [arrAllPrivateCellNauMembers addObjectsFromArray:arrCellNauMembers];
                    
                }
                
            }
            
        }
        else{
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"error fetching private cells --> %@",errorString);
            }
            
        }
        
        ///Call the completion block
        if (completion != NULL) {
            
            NSMutableDictionary *dictCellMembers = [NSMutableDictionary dictionary];
            
            ///Set private cell members if available
            if(arrAllPrivateCellMembers.count > 0){
                
                [dictCellMembers setObject:arrAllPrivateCellMembers forKey:kCellMembersKey];
                
            }
            
            ///Set private cell nau members if available
            if(arrAllPrivateCellNauMembers.count > 0){
                
                [dictCellMembers setObject:arrAllPrivateCellNauMembers forKey:kCellNauMembersKey];
                
            }
            
            ///Call the completion block
            completion(dictCellMembers,error);
        }
        
    }];
    
}

-(void)getAllFriendsWithCompletion:(PFArrayResultBlock)completion
{
    ///1.Pick from defaults first if available
    NSArray *arrFriends = [C411AppDefaults sharedAppDefaults].arrFriends;
    
    if (arrFriends.count > 0) {
        
        ///All friends are now available call completion block
        completion(arrFriends,nil);
        
    }
    else{
        ///2.Try fetching all friends from parse if available
        
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        PFRelation *getFriendsRelation = [currentUser relationForKey:kUserFriendsKey];
        [[getFriendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
            
            if (error){
                
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"error fetching friends--> %@",errorString);
                }
                
            }
            
            ///call completion block
            if (completion != NULL) {
                completion(objects,error);
            }
            
        }];
        
    }
    
    
    
}

-(void)getPatrolMembersWithCompletion:(PFArrayResultBlock)completion
{
    ///Fetch the patrol members within the given radius
    ///Get patrol radius
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];
    
    ///Make a query to fetch users
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES]];
    //    if ([defaults boolForKey:kDispatchMode]
    //        && self.alertType != BTN_ALERT_TAG_PANIC
    //        && self.alertType != BTN_ALERT_TAG_FALLEN
    //        && self.alertType != BTN_ALERT_TAG_VIDEO
    //        && self.alertType != BTN_ALERT_TAG_PHOTO) {
    //
    //        ///Update current userGeoPoint to custom location picked for dispatch mode
    //        userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.dispatchLocation.latitude longitude:self.dispatchLocation.longitude];
    //
    //    }
    PFQuery *fetchGloablUsersQuery = [PFUser query];
    [fetchGloablUsersQuery whereKey:kUserPatrolModeKey equalTo:PATROL_MODE_VALUE_ON];
    [fetchGloablUsersQuery whereKey:kUserLocationKey nearGeoPoint:userGeoPoint withinMiles:(double)patrolModeRadius];
    [fetchGloablUsersQuery whereKey:@"objectId" notEqualTo:[AppDelegate getLoggedInUser].objectId];
    [fetchGloablUsersQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (error){
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"error fetching patrol members--> %@",errorString);
            }
            
        }
        
        ///call completion block
        if (completion != NULL) {
            completion(objects,error);
        }
        
    }];
    
    
}


-(void)handleCompletionOfPanicOrFallenAlertWithAlertType:(NSInteger)alertType
{
    ///End background task
    [[UIApplication sharedApplication] endBackgroundTask:self.sendPanicOrFallenAlertTaskId];
    
    
}

#if APP_IER
-(void)sendIERAlertFromIssuerWithId:(NSString *)strAlertIssuerId alertType:(NSString *)strAlertType additionalNote:(NSString *)strAdditionalNote locationCoordinate:(CLLocationCoordinate2D)currentLocationCoordinate andPhotoUrl:(NSString *)strPhotoUrl andCompletion:(C411WebServiceHandler)completion
{
    ///Make an IER API call as well for alerts
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    
    ///set object id of alert issuer
    [dictParams setObject:strAlertIssuerId forKey:IER_API_PARAM_USER_ID];
    
    
    ///set alert type
    [dictParams setObject:strAlertType forKey:IER_API_PARAM_ALERT_TYPE];
    
    
    ///set additional note
    NSString *strIERAdditionalNote = strAdditionalNote ? strAdditionalNote : @"";
    [dictParams setObject:strIERAdditionalNote forKey:IER_API_PARAM_NOTE];
    
    
    ///Set geo location
    NSString *strGeoLocation = [NSString stringWithFormat:@"%f,%f",currentLocationCoordinate.latitude,currentLocationCoordinate.longitude];
    [dictParams setObject:strGeoLocation forKey:IER_API_PARAM_GEO_LOCATION];
    
    ///Set image url if available
    if (strPhotoUrl.length > 0) {
        [dictParams setObject:strPhotoUrl forKey:IER_API_PARAM_IMG_URL];
    }
    
    [ServerUtility postIERAlertWithDetails:dictParams andCompletion:^(NSError *error, id data) {
        
        //NSLog(@"IER--> %@",data);
        if (completion != NULL) {
            
            completion(error, data);
        }
    }];

}
#endif

#if NON_APP_USERS_ENABLED

-(void)sendAlertToNauCellWithAlertType:(NSInteger)alertType cellId:(NSString *)strCellId cell411AlertObjectId:(NSString *)strCell411AlertObjectId andImgUrl:(NSString *)strImgUrl
{
    
    ///Call a cloud function to send alert to NAU members of this cell
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kSendSMSAndEmailAlertFuncParamTitleKey] = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
    dictParams[kSendSMSAndEmailAlertFuncParamCellObjectIdKey] = strCellId;
    dictParams[kSendSMSAndEmailAlertFuncParamCell411AlertObjectIdKey] = strCell411AlertObjectId;
    if (alertType == BTN_ALERT_TAG_PHOTO) {
        
        dictParams[kSendSMSAndEmailAlertFuncParamIsPhotoAlertKey] = @(YES);
        if (strImgUrl) {
            
            dictParams[kSendSMSAndEmailAlertFuncParamImageUrlKey] = strImgUrl;
            
        }
    }
    else{
        dictParams[kSendSMSAndEmailAlertFuncParamIsPhotoAlertKey] = @(NO);
    }
    
    CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kDispatchMode]
        && alertType != BTN_ALERT_TAG_PHOTO) {
        
        dictParams[kSendSMSAndEmailAlertFuncParamDispatchModeKey] = @(1);
        currentLocationCoordinate = self.dispatchLocation;
    }
    else{
        dictParams[kSendSMSAndEmailAlertFuncParamDispatchModeKey] = @(2);
    }
    dictParams[kSendSMSAndEmailAlertFuncParamLatKey] = @(currentLocationCoordinate.latitude);
    dictParams[kSendSMSAndEmailAlertFuncParamLongKey] = @(currentLocationCoordinate.longitude);
    [C411StaticHelper sendSMSAndEmailAlertWithDetails:dictParams cloudFuncName:kSendSMSAndEmailAlertV2FuncNameKey andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
        
        
        NSLog(@"Sms and email V2 response:%@ error:%@",object,error);
        
    }];
    
    
}

-(void)sendPanicOrFallenAlertToNauCellWithAlertType:(NSInteger)alertType cell411AlertObjectId:(NSString *)strCell411AlertObjectId andNauMembers:(NSArray *)arrNauMembers
{
    
    ///Call a cloud function to send alert to NAU members of this cell
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kSendSMSAndEmailAlertFuncParamTitleKey] = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
    dictParams[kSendSMSAndEmailAlertFuncParamCell411AlertObjectIdKey] = strCell411AlertObjectId;

    CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
    dictParams[kSendSMSAndEmailAlertFuncParamDispatchModeKey] = @(2);
    dictParams[kSendSMSAndEmailAlertFuncParamLatKey] = @(currentLocationCoordinate.latitude);
    dictParams[kSendSMSAndEmailAlertFuncParamLongKey] = @(currentLocationCoordinate.longitude);
    
    NSError *err = nil;
    NSData *nauMembersJsonData = [NSJSONSerialization dataWithJSONObject:arrNauMembers options:NSJSONWritingPrettyPrinted error:&err];
    if (!err && nauMembersJsonData) {
        
        NSString *strJsonArrNauMembers = [[NSString alloc]initWithData:nauMembersJsonData encoding:NSUTF8StringEncoding];
        if (strJsonArrNauMembers.length > 0) {
            
            dictParams[kSendSMSAndEmailAlertFuncParamNauMembersKey] = strJsonArrNauMembers;
            [C411StaticHelper sendSMSAndEmailAlertWithDetails:dictParams cloudFuncName:kSendSMSAndEmailPanicAlertFuncNameKey andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
                
                NSLog(@"Sms and email Panic response:%@ error:%@",object,error);
                
            }];
            
        }
    }
}



/*
-(void)sendAlertToNauCellWithAlertType:(NSInteger)alertType andCellId:(NSString *)strCellId
{
    
    ///Call a cloud function to send alert to NAU members of this cell
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kSendSMSAndEmailAlertFuncParamTitleKey] = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
    dictParams[kSendSMSAndEmailAlertFuncParamNAUCellObjectIdKey] = strCellId;
    if (alertType == BTN_ALERT_TAG_PHOTO) {
        
        dictParams[kSendSMSAndEmailAlertFuncParamIsPhotoAlertKey] = @(YES);
        if (self.photoData) {
            
            dictParams[kSendSMSAndEmailAlertFuncParamImageBytesKey] = self.photoData;
            
        }
    }
    else{
        dictParams[kSendSMSAndEmailAlertFuncParamIsPhotoAlertKey] = @(NO);
    }
    
    CLLocationCoordinate2D currentLocationCoordinate = [LocationManager sharedInstance].currentLocation.coordinate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kDispatchMode]
        && alertType != BTN_ALERT_TAG_PHOTO
        && alertType != BTN_ALERT_TAG_PANIC
        && alertType != BTN_ALERT_TAG_FALLEN) {
        
        dictParams[kSendSMSAndEmailAlertFuncParamDispatchModeKey] = @(1);
        currentLocationCoordinate = self.dispatchLocation;
    }
    else{
        dictParams[kSendSMSAndEmailAlertFuncParamDispatchModeKey] = @(2);
    }
    dictParams[kSendSMSAndEmailAlertFuncParamLatKey] = @(currentLocationCoordinate.latitude);
    dictParams[kSendSMSAndEmailAlertFuncParamLongKey] = @(currentLocationCoordinate.longitude);
    [C411StaticHelper sendSMSAndEmailAlertWithDetails:dictParams andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
        
        
    }];
    
    
}
*/

#endif


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnFABToggleCenterUserLocationTapped:(UIButton *)sender {
    
    BOOL shouldCenter = !sender.isSelected;
    ///Update the button state
    [self toggleButton:sender toSelected:shouldCenter];
    
    ///save it in defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:shouldCenter forKey:kCenterUserLocation];
    [defaults synchronize];
    
    if (shouldCenter) {
        
        ///Animate map to current location
        [self.mapView animateToLocation:[[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];
        
        ///Show toast that user location will always be displayed on Center
        [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Real time location ACTIVATED", nil)];
        
    }
    else{
        ///Show toast that user location will not always be displayed on center
        [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Location DEACTIVATED - last known location will be displayed", nil)];
    }
    
}

- (IBAction)btnInitiateAlertTapped:(OBShapedButton *)sender{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(sender.tag == BTN_ALERT_TAG_PANIC){
        
        ///show panic alert overlay and send after wait time
        [self showPanicOrFallenAlertWithAlertType:BTN_ALERT_TAG_PANIC];
    }
    else if(sender.tag == BTN_ALERT_TAG_CALL_112){
        
        ///Dial 112
        [C411StaticHelper callOnNumber:@"112"];
        
    }
    else if ([defaults boolForKey:kDispatchMode]
             &&(sender.tag != BTN_ALERT_TAG_VIDEO)
             &&(sender.tag != BTN_ALERT_TAG_PHOTO)) {
        ///Show Custom location picker VC for dispatch mode
        C411LocationPickerVC *locationPickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411LocationPickerVC"];
        locationPickerVC.currentLocation = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES];
        //locationPickerVC.delegate = self;
        __weak typeof(self) weakSelf = self;
        locationPickerVC.completionHandler = ^(id customObject) {
            CLLocation *dispatchLoc = (CLLocation *)customObject;
            weakSelf.dispatchLocation = dispatchLoc.coordinate;
            ///Show cell selection prompt with accurate title as per alert type, behind the location picker vc
            [weakSelf initiateAlertForAlertButton:sender];

        };
        
        [self presentViewController:locationPickerVC animated:YES completion:^{
            
        }];
    }
    else if (sender.tag == BTN_ALERT_TAG_PHOTO){
        ///Show photo picker selection action sheet
        UIAlertController *photoPickerType = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        __weak typeof(self) weakSelf = self;
        
        ///Add Camera action
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [weakSelf showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera animated:YES];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [photoPickerType addAction:cameraAction];
        
        ///Add Gallery action
        UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Gallery", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [weakSelf showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary animated:YES];
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [photoPickerType addAction:galleryAction];
        
        ///Add cancel button action
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            ///Do anything to be done on cancel
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];

        }];
        
        [photoPickerType addAction:cancelAction];
        
        ///Present action sheet
        //[self presentViewController:photoPickerType animated:YES completion:NULL];
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:photoPickerType];

        
    }
#if APP_IER
    ///TODO: Check if this condition is required for SendAlertV3 or not
    else if ((sender.tag == BTN_ALERT_TAG_VIDEO)
             &&(//([defaults boolForKey:kStreamVideoOnFBWall])||
                ([defaults boolForKey:kStreamVideoOnFBPage])
                ||([defaults boolForKey:kStreamVideoOnUserYTChannel])
                ||([defaults boolForKey:kStreamVideoOnCell411YTChannel]))){
#if VIDEO_STREAMING_ENABLED
                 
                 ///If user don't have any friends and has enabled streaming to either Facebook/YouTube then don't show prompt for Cell selection and allow user to stream video, else continue with the existing flow
                 if ([C411AppDefaults sharedAppDefaults].arrFriends.count > 0) {
                     ///User has friends, show cell selection prompt with accurate title as per alert type
                     [self initiateAlertForAlertButton:sender];

                     
                 }
                 else{
                     ///Try fetching all friends from parse if available
                     ///Show Progress Hud
                     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     __weak typeof(self) weakSelf = self;
                     
                     PFUser *currentUser = [AppDelegate getLoggedInUser];
                     PFRelation *getFriendsRelation = [currentUser relationForKey:kUserFriendsKey];
                     [[getFriendsRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                         
                         ///Remove the hud
                         [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                         
                         if (!error) {
                             
                             if (objects.count > 0) {
                                 
                                 ///User has friends, show cell selection prompt with accurate title as per alert type
                                 [self initiateAlertForAlertButton:sender];
                                 
                                 
                             }
                             else{
                                 
                                 ///User don't have any friend, continue with streaming without showing cell selection prompt
                                 ///save info regarding notification
                                 C411Audience *alertAudience = [[C411Audience alloc]init];
                                 alertAudience.audienceType = AudienceTypeOnlySocialMediaMembers;
                                 
                                 C411Alert *alert = [[C411Alert alloc]init];
                                 alert.alertType = BTN_ALERT_TAG_VIDEO;
                                 [alert.arrAudiences addObject:alertAudience];
                                 [weakSelf initiateAlert:alert];
                                 
                                 /*OLD CODE
                                 self.arrAlertAudience = nil;///alertAudience will be nil this time as we user don't have any friends.
                                 self.audienceType = AudienceTypeOnlySocialMediaMembers;
                                 self.alertType = BTN_ALERT_TAG_VIDEO;

                                 [weakSelf initiateAlertWithNote:nil];
                                 */
                                 
                                 
                             }
                             
                         }
                         else {
                             
                             if(![AppDelegate handleParseError:error]){
                                 ///show error
                                 NSString *errorString = [error userInfo][@"error"];
                                 [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                             }
                             
                             
                         }
                         
                         
                     }];
                     
                 }
#endif
 
             }
#endif
    else{
        
#if (!VIDEO_STREAMING_ENABLED)
        
        if (sender.tag == BTN_ALERT_TAG_VIDEO)
        {
            ///do nothing and return from this method if video streaming is not enabled but somehow Video Streaming Alert is tried to be issued
            return;
        }
        
#endif
        ///Show cell selection prompt with accurate title as per alert type
        [self initiateAlertForAlertButton:sender];
    }
    
}

- (IBAction)barBtnChangeMapTypeTapped:(UIBarButtonItem *)sender {
    
    UIAlertController *mapTypePicker = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Map Type", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    ///Add Map types action
    ///1.Standard
    UIAlertAction *standardMapAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Standard", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        weakSelf.mapView.mapType = kGMSTypeNormal;
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    [mapTypePicker addAction:standardMapAction];
    
    ///2. Satellite
    UIAlertAction *satelliteMapAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Satellite", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        weakSelf.mapView.mapType = kGMSTypeSatellite;
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    [mapTypePicker addAction:satelliteMapAction];
    
    ///3. Hybrid
    UIAlertAction *hybridMapAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Hybrid", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        weakSelf.mapView.mapType = kGMSTypeHybrid;
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    [mapTypePicker addAction:hybridMapAction];
    
    
    ///Add cancel button action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///Do anything to be done on cancel
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];

    }];
    
    [mapTypePicker addAction:cancelAction];
    
    ///Present action sheet
    //[self presentViewController:mapTypePicker animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:mapTypePicker];

}

- (IBAction)btnFABRequestRideTapped:(UIButton *)sender {

    UIAlertController *rideOptionSelectionAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Ride Hailing", nil) message:NSLocalizedString(@"What would you like to do?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *seeRequestAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"See Requests", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///user said see requests, show the ride requests VC
        ///User said to request new ride,show request ride VC
        C411RideRequestsVC *rideRequestsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RideRequestsVC"];
        //UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
        //[rootNavC pushViewController:requestRideVC animated:YES];
        [self.navigationController pushViewController:rideRequestsVC animated:YES];

        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    UIAlertAction *requestNewRideAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Request New Ride", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ///User said to request new ride,show request ride VC
        C411RequestRideVC *requestRideVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RequestRideVC"];
        //UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
        //[rootNavC pushViewController:requestRideVC animated:YES];
        [self.navigationController pushViewController:requestRideVC animated:YES];

        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        ///User tapped cancel,
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];

    [rideOptionSelectionAlert addAction:seeRequestAction];
    [rideOptionSelectionAlert addAction:requestNewRideAction];
    [rideOptionSelectionAlert addAction:cancelAction];
    //[self presentViewController:confirmSpamAlert animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:rideOptionSelectionAlert];

    
}



//****************************************************
#pragma mark - Gesture Method
//****************************************************

-(void)vuRideOverlayTapped:(UITapGestureRecognizer *)tapGesture
{
    ///show the corresponding screen
#if RIDE_HAILING_ENABLED
    
    C411RideStatusOverlay *vuRideStatusOverlay = (C411RideStatusOverlay *)tapGesture.view;
    if (vuRideStatusOverlay.overlayType == RideOverlayTypePendingRideRequest) {
        
        ///Pending Ride Request:Show the received responses screen
        C411ReceivedRideResponsesVC *receivedRideResponsesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ReceivedRideResponsesVC"];
        receivedRideResponsesVC.rideRequest = vuRideStatusOverlay.rideRequest;
        [self.navigationController pushViewController:receivedRideResponsesVC animated:YES];

    }
    else if (vuRideStatusOverlay.overlayType == RideOverlayTypePendingPickup) {
        
        ///show the Ride detail VC
        C411RideDetailVC *rideDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RideDetailVC"];
        rideDetailVC.rider = vuRideStatusOverlay.rideRequest[kRideRequestRequestedByKey];
        rideDetailVC.alertPayload = vuRideStatusOverlay.alertNotificationPayload;
        
        [self.navigationController pushViewController:rideDetailVC animated:YES];
        
    }
    
#endif
    
}

//****************************************************
#pragma mark - GMSMapViewDelegate Methods
//****************************************************

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    if (marker == self.currentLocationMarker) {
        ///Animate map to current location
        //[self.mapView animateToLocation:[[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];
        ///Snap to current location without animation
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setTarget:[[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];
        [self.mapView moveCamera:cameraUpdate];
        self.vuRadialMenu.hidden = NO;
        //        CGPoint center = mapView_.center;
        //
        //        self.vuRadialMenu.center = center;
        //        self.vuRadialMenu.translatesAutoresizingMaskIntoConstraints = YES;
        //
        //        ///Set patrol mode status
        //        PFUser *currentUser = [AppDelegate getLoggedInUser];
        //        self.btnPatrolMode.selected = [currentUser[kUserPatrolModeKey]boolValue];
        //
        //        ///Toggle All OK button visibility
        //        self.btnAllOk.hidden = ![AppDelegate sharedInstance].shouldShowAllOkOption;
        
        [self animateRadialMenu];
        self.mapView.selectedMarker = nil;
        //return NO;
    }
    else if([marker.userData isKindOfClass:[PFObject class]]) {
        PFObject *mapObjective = marker.userData;
        UINavigationController *mapObjectiveDetailNavC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411MapObjectiveDetailNavC"];
        C411MapObjectiveDetailVC *mapObjectiveDetailVC = mapObjectiveDetailNavC.viewControllers.firstObject;
        mapObjectiveDetailVC.mapObjective = mapObjective;
        [self presentViewController:mapObjectiveDetailNavC animated:YES completion:NULL];
    }
    else if([marker.userData isKindOfClass:[C411OSMObjective class]]) {
        C411OSMObjective *osmObjective = marker.userData;
        UINavigationController *osmObjectiveDetailNavC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411OSMObjectiveDetailNavC"];
        C411OSMObjectiveDetailVC *osmObjectiveDetailVC = osmObjectiveDetailNavC.viewControllers.firstObject;
        osmObjectiveDetailVC.osmObjective = osmObjective;
        [self presentViewController:osmObjectiveDetailNavC animated:YES completion:NULL];
    }
    return YES;
}

//-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
//{
//   if (coordinate.latitude == mapView.myLocation.coordinate.latitude && coordinate.longitude == mapView.myLocation.coordinate.longitude) {
//
//        self.vuRadialMenu.hidden = NO;
//
//    }
//}



-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.vuRadialMenu.hidden == NO) {
        
        self.vuRadialMenu.hidden = YES;
    }
    mapView.selectedMarker = self.currentLocationMarker;
}

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    if(gesture) {
        if (self.vuRadialMenu.hidden == NO) {
            
            self.vuRadialMenu.hidden = YES;
        }
        mapView.selectedMarker = self.currentLocationMarker;
    }
}
//****************************************************
#pragma mark - UIImagePickerControllerDelegate
//****************************************************

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    ///Get selected image if image is picked or clicked
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage = [selectedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(self.view.bounds.size.width * 2, self.view.bounds.size.height * 2) interpolationQuality:kCGInterpolationHigh];

    ///Compress the image
    float compressionQuality = 0.7;
    self.photoData = UIImageJPEGRepresentation(resizedImage, compressionQuality);
    resizedImage = [UIImage imageWithData:self.photoData];

    self.photoImage = resizedImage;
    BOOL showError = NO;
    if (self.photoData) {
        ///Create photo file and save it
        self.photoFile = [PFFileObject fileObjectWithName:@"photo_alert.png" data:self.photoData];
        if (self.photoFile) {
            /*
            ///Save photo file
            // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
            self.photoUploadTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.photoUploadTaskId];
            }];
            ///upload photofile in background
            [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.photoUploadTaskId];
                } else {
                    [[UIApplication sharedApplication] endBackgroundTask:self.photoUploadTaskId];
                }
            }];
            */
            
            ///Show cell selection popup
#if VIDEO_STREAMING_ENABLED
            [self initiateAlertForAlertButton:self.btnPhotoSlice];

#else
            [self initiateAlertForAlertButton:self.btnPhotoSliceWider];

#endif
            
        }
        else{
            ///Show alert unable to send photo alert
            showError = YES;
        }
    }
    else{
        ///Unable to make PNG data from captured pic
        showError = YES;
    }
    
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (showError) {
            ///Show photo alert error
            [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Unable to send photo alert. Please try again.", nil) onViewController:weakSelf];
        }
        
    }];
}


//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.tag == TXT_TAG_INIT_ALERT_ADDITIONAL_NOTE)
        && textField.alert.alertType == BTN_ALERT_TAG_GENERAL) {
        
        ///Send button for general alert can only be available if there is additional note
        NSString *strAdditionalNote = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (strAdditionalNote.length > 0) {
            
            self.sendAction.enabled = YES;
        }
        else{
            
            self.sendAction.enabled = NO;
            
        }
        
        
    }

    /* OLD CODE
    if ((textField.tag == TXT_TAG_INIT_ALERT_ADDITIONAL_NOTE)
        && self.alertType == BTN_ALERT_TAG_GENERAL) {
        
        ///Send button for general alert can only be available if there is additional note
        NSString *strAdditionalNote = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (strAdditionalNote.length > 0) {
            
            self.sendAction.enabled = YES;
        }
        else{
            
            self.sendAction.enabled = NO;
            
        }
        
        
    }
    */
    
    return YES;
    
}

//****************************************************
#pragma mark - C411SendAlertVCDelegate Methods
//****************************************************

-(void)sendAlertWithParams:(NSDictionary *)dictAlertParams
{
    NSLog(@"%s-->\n%@",__PRETTY_FUNCTION__, dictAlertParams);
    AlertType alertType = (AlertType)[dictAlertParams[kSendAlertV3FuncParamAlertIdKey]integerValue];
    if(alertType == AlertTypeVideo){
#if VIDEO_STREAMING_ENABLED

        [self streamVideoWithAlertParams:dictAlertParams];
#endif
    }
    else{
        [self sendAlertWithAlertParams:dictAlertParams andCompletion:NULL];
    }
    
}

//****************************************************
#pragma mark - C411SendAlertPopupVCDelegate Methods
//****************************************************

-(void)sendAlertPopupDidSelectGlobalAlert:(C411SendAlertPopupVC *)alertPopupVC
{
    /*
     if (alertPopupVC.isForwardingAlert) {
     
     ///User has selected to forward someone's alert globally to patrol members
     NSDictionary *dictAlertData = alertPopupVC.dictAlertData;
     PFUser *originalAlertIssuer = alertPopupVC.needyPerson;///This is the actual person who issued the alert, which is being forwarded by current user
     PFObject *cell411AlertToFwd = alertPopupVC.cell411AlertToFwd; ///This is the actual Cell411Alert being forwarded by current user
     alertPopupVC.delegate = nil;
     
     ///Dismiss popup
     [alertPopupVC.view removeFromSuperview];
     ///Clear the alert data hold as a strong refernce and remove the popup from queue
     alertPopupVC.dictAlertData = nil;
     alertPopupVC.needyPerson = nil;
     alertPopupVC.cell411AlertToFwd = nil;
     [self.arrFwdAlertPopupVCQueue removeObject:alertPopupVC];
     
     ///Initiate alert forwarding to Patrol members, alertAudience will be nil as it will be retrived in the method called below.
     [self initiateAlertForwardingWithData:dictAlertData audienceType:AudienceTypePatrolMembers alertAudience:nil onCell:nil fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
     
     }
     else{
     */
    ///User is trying to send his own alert globally to patrol members
    ///save info regarding notification
    C411Audience *alertAudience = [[C411Audience alloc]init];
    alertAudience.audienceType = AudienceTypePatrolMembers;
    
    C411Alert *alert = [[C411Alert alloc]init];
    alert.alertType = alertPopupVC.alertType;
    [alert.arrAudiences addObject:alertAudience];
    
    alertPopupVC.delegate = nil;
    
    ///Dismiss popup
    [self dismissSendAlertPopup:alertPopupVC];
    
    if (alert.alertType == BTN_ALERT_TAG_VIDEO) {
        ///Send video alert without asking for additional note
        [self initiateAlert:alert];
    }
    else{
        ///show additional note alert
        [self showAdditionalNotePopupForAlert:alert];
    }
    
    
    
    /*OLD CODE
    self.arrAlertAudience = nil;///alertAudience will be nil this time as we will fetch the patrol members if user taps on send.
    self.audienceType = AudienceTypePatrolMembers;
    self.alertType = alertPopupVC.alertType;
    
    alertPopupVC.delegate = nil;
    
    
    ///Dismiss popup
    [self dismissSendAlertPopup:alertPopupVC];
    
    if (self.alertType == BTN_ALERT_TAG_VIDEO) {
        ///Send video alert without asking for additional note
        [self initiateAlertWithNote:nil];
    }
    else{
        ///show additional note alert
        [self showAdditionalNotePopup];
    }
    */
    
    //    }
    
}


-(void)sendAlertPopupDidSelectAllFriends:(C411SendAlertPopupVC *)alertPopupVC
{
    /*
     if (alertPopupVC.isForwardingAlert) {
     
     ///User has selected to forward someone's alert to all friends
     NSDictionary *dictAlertData = alertPopupVC.dictAlertData;
     PFUser *originalAlertIssuer = alertPopupVC.needyPerson;///This is the actual person who issued the alert, which is being forwarded by current user
     PFObject *cell411AlertToFwd = alertPopupVC.cell411AlertToFwd; ///This is the actual Cell411Alert being forwarded by current user
     
     alertPopupVC.delegate = nil;
     
     ///Dismiss popup
     [alertPopupVC.view removeFromSuperview];
     ///Clear the alert data hold as a strong refernce and remove the popup from queue
     alertPopupVC.dictAlertData = nil;
     alertPopupVC.needyPerson = nil;
     alertPopupVC.cell411AlertToFwd = nil;
     [self.arrFwdAlertPopupVCQueue removeObject:alertPopupVC];
     
     ///Initiate alert forwarding to All friends.
     NSArray *arrAlertAudience = [C411AppDefaults sharedAppDefaults].arrFriends;
     
     [self initiateAlertForwardingWithData:dictAlertData audienceType:AudienceTypeAllFriends alertAudience:arrAlertAudience onCell:nil fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
     
     }
     else{*/
    ///User is trying to send his own alert to all friends
    
    ///save info regarding notification to all friend
    C411Audience *alertAudience = [[C411Audience alloc]init];
    alertAudience.audienceType = AudienceTypeAllFriends;
    alertAudience.arrMembers = [C411AppDefaults sharedAppDefaults].arrFriends;
    
    C411Alert *alert = [[C411Alert alloc]init];
    alert.alertType = alertPopupVC.alertType;
    [alert.arrAudiences addObject:alertAudience];
    
    alertPopupVC.delegate = nil;
    
    ///Dismiss popup
    [self dismissSendAlertPopup:alertPopupVC];
    
    if (alert.alertType == BTN_ALERT_TAG_VIDEO) {
        ///Send video alert without asking for additional note
        [self initiateAlert:alert];
    }
    else{
        ///show additional note alert
        [self showAdditionalNotePopupForAlert:alert];
    }
    
    
    
    /*OLD CODE

    self.arrAlertAudience = [C411AppDefaults sharedAppDefaults].arrFriends;
    self.audienceType = AudienceTypeAllFriends;
    self.alertType = alertPopupVC.alertType;
    
    alertPopupVC.delegate = nil;
    
    
    ///Dismiss popup
    [self dismissSendAlertPopup:alertPopupVC];
    
    if (self.alertType == BTN_ALERT_TAG_VIDEO) {
        ///Send video alert without asking for additional note
        [self initiateAlertWithNote:nil];
    }
    else{
        ///show additional note alert
        [self showAdditionalNotePopup];
    }
    */
    
    //    }
    
    
}

-(void)sendAlertPopup:(C411SendAlertPopupVC *)alertPopupVC didSelectCell:(PFObject *)cell
{
    /*
     if (alertPopupVC.isForwardingAlert) {
     
     ///User has selected to forward someone's alert to members of a particular cell
     NSDictionary *dictAlertData = alertPopupVC.dictAlertData;
     PFUser *originalAlertIssuer = alertPopupVC.needyPerson;///This is the actual person who issued the alert, which is being forwarded by current user
     PFObject *cell411AlertToFwd = alertPopupVC.cell411AlertToFwd; ///This is the actual Cell411Alert being forwarded by current user
     
     alertPopupVC.delegate = nil;
     
     ///Dismiss popup
     [alertPopupVC.view removeFromSuperview];
     ///Clear the alert data hold as a strong refernce and remove the popup from queue
     alertPopupVC.dictAlertData = nil;
     alertPopupVC.needyPerson = nil;
     alertPopupVC.cell411AlertToFwd = nil;
     [self.arrFwdAlertPopupVCQueue removeObject:alertPopupVC];
     
     ///Initiate alert forwarding to All friends.
     NSArray *arrAlertAudience = cell[kCellMembersKey];
     
     [self initiateAlertForwardingWithData:dictAlertData audienceType:AudienceTypePrivateCellMembers alertAudience:arrAlertAudience onCell:cell fromOriginalIssuer:originalAlertIssuer andOriginalAlertToFwd:cell411AlertToFwd];
     
     }
     else{*/
    ///User is trying to send his own alert to members of a particular cell.
    ///save info regarding  notification to all members of this cell
    C411Audience *alertAudience = [[C411Audience alloc]init];
    alertAudience.audienceType = AudienceTypePrivateCellMembers;
    alertAudience.audienceCell = cell;
    
    C411Alert *alert = [[C411Alert alloc]init];
    alert.alertType = alertPopupVC.alertType;
    [alert.arrAudiences addObject:alertAudience];
    
    alertPopupVC.delegate = nil;
    
    ///Dismiss popup
    [self dismissSendAlertPopup:alertPopupVC];
    
    if (alert.alertType == BTN_ALERT_TAG_VIDEO) {
        ///Send video alert without asking for additional note
        [self initiateAlert:alert];
    }
    else{
        ///show additional note alert
        [self showAdditionalNotePopupForAlert:alert];
    }
    
    
    
    /*OLD CODE
    self.arrAlertAudience = cell[kCellMembersKey];
    self.arrAlertNauAudience = cell[kCellNauMembersKey];
    self.audienceType = AudienceTypePrivateCellMembers;
    self.alertType = alertPopupVC.alertType;
    self.alertRecievingCell = cell;
    
    ///Dismiss popup
    [self dismissSendAlertPopup:alertPopupVC];
    
    if (self.alertType == BTN_ALERT_TAG_VIDEO) {
        ///Send video alert without asking for additional note
        [self initiateAlertWithNote:nil];
    }
    else{
        ///show additional note alert
        [self showAdditionalNotePopup];
    }
    */
    
    //    }
    
    
}

-(void)sendAlertPopupDidSelectSecurityGuard:(C411SendAlertPopupVC *)alertPopupVC
{
    if ([C411AppDefaults canShowSecurityGuardOption]) {
        
        ///Security option is available, send alert to security guards
        ///User is trying to send his own alert to security guards
        
        ///save info regarding notification to security guards
        C411Audience *alertAudience = [[C411Audience alloc]init];
        alertAudience.audienceType = AudienceTypeSecurityGuards;
        
        C411Alert *alert = [[C411Alert alloc]init];
        alert.alertType = alertPopupVC.alertType;
        [alert.arrAudiences addObject:alertAudience];
        
        alertPopupVC.delegate = nil;
        
        ///Dismiss popup
        [self dismissSendAlertPopup:alertPopupVC];
        
        if (alert.alertType == BTN_ALERT_TAG_VIDEO) {
            ///Send video alert without asking for additional note
            [self initiateAlert:alert];
        }
        else{
            ///show additional note alert
            [self showAdditionalNotePopupForAlert:alert];
        }
        
        
        
        /*OLD CODE

        self.arrAlertAudience = nil;
        self.audienceType = AudienceTypeSecurityGuards;
        self.alertType = alertPopupVC.alertType;
        
        alertPopupVC.delegate = nil;
        
        
        ///Dismiss popup
        [self dismissSendAlertPopup:alertPopupVC];
        
        if (self.alertType == BTN_ALERT_TAG_VIDEO) {
            ///Send video alert without asking for additional note
            [self initiateAlertWithNote:nil];
        }
        else{
            ///show additional note alert
            [self showAdditionalNotePopup];
        }
        
        */

    }
}

-(void)sendAlertPopupDidCancel:(C411SendAlertPopupVC *)alertPopupVC
{
    /*
     if (alertPopupVC.isForwardingAlert) {
     ///User cancelled to forward the alert
     alertPopupVC.delegate = nil;
     
     ///Dismiss popup
     [alertPopupVC.view removeFromSuperview];
     
     ///Clear the alert data hold as a strong refernce and remove the popup from queue
     alertPopupVC.dictAlertData = nil;
     alertPopupVC.needyPerson = nil;
     alertPopupVC.cell411AlertToFwd = nil;
     [self.arrFwdAlertPopupVCQueue removeObject:alertPopupVC];
     }
     else{*/
    ///user cancelled to send the alert
    ///Dismiss popup
    [self dismissSendAlertPopup:alertPopupVC];
    
    ///Clear photo data if its available in case of photo alert
    self.photoFile = nil;
    self.photoData = nil;
    self.photoImage = nil;
    
    //    }
    
}

-(void)sendAlertPopupDidSelectPublicCells:(C411SendAlertPopupVC *)alertPopupVC
{
    ///Make Public Cell selection popup
    self.publicCellSelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411PublicCellSelectionVC"];
    self.publicCellSelectionVC.strAlertTitle = alertPopupVC.lblAlertTitle.text;
    self.publicCellSelectionVC.alertType = alertPopupVC.alertType;
    self.publicCellSelectionVC.delegate = self;
    
    
    ///Dismiss popup
    alertPopupVC.delegate = nil;
    [self dismissSendAlertPopup:alertPopupVC];
    
    //show the popup
    UIView *vuPublicCellSelectionPopup = self.publicCellSelectionVC.view;
    UIView *vuRootVC = [AppDelegate sharedInstance].window.rootViewController.view;
    vuPublicCellSelectionPopup.frame = vuRootVC.frame;
    [vuRootVC addSubview:vuPublicCellSelectionPopup];
    [vuRootVC bringSubviewToFront:vuPublicCellSelectionPopup];
    vuPublicCellSelectionPopup.translatesAutoresizingMaskIntoConstraints = YES;
    
}

#if NON_APP_USERS_ENABLED
-(void)sendAlertPopupDidSelectNonAppUserCells:(C411SendAlertPopupVC *)alertPopupVC
{
    
    C411NonAppUsersSelectionVC *nonAppUserSelectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411NonAppUsersSelectionVC"];
    nonAppUserSelectionVC.sendAlertPopupVC = alertPopupVC;
    nonAppUserSelectionVC.delegate = self;
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC pushViewController:nonAppUserSelectionVC animated:YES];
    
    
    

}



//****************************************************
#pragma mark - C411NonAppUsersSelectionVCDelegate Methods
//****************************************************
-(void)nonAppUsersSelectionVC:(C411NonAppUsersSelectionVC *)nonAppUsersSelectionVC didSelectNonAppUsers:(NSArray *)arrContacts
{
    
    if (arrContacts.count > 0) {
        
        ///User selected NAU members from his/her phone contacts so send the array of contacts to whom alert needs to be sent
        NSInteger alertType = nonAppUsersSelectionVC.sendAlertPopupVC.alertType;
        
        NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
        dictParams[kSendSMSAndEmailAlertFuncParamTitleKey] = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
        if (alertType == BTN_ALERT_TAG_PHOTO) {
            
            dictParams[kSendSMSAndEmailAlertFuncParamIsPhotoAlertKey] = @(YES);
            if (self.photoData) {
                
                dictParams[kSendSMSAndEmailAlertFuncParamImageBytesKey] = self.photoData;
                
            }
        }
        else{
            dictParams[kSendSMSAndEmailAlertFuncParamIsPhotoAlertKey] = @(NO);
        }
        
        CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:kDispatchMode]
            && alertType != BTN_ALERT_TAG_PHOTO) {
            
            dictParams[kSendSMSAndEmailAlertFuncParamDispatchModeKey] = @(1);
            currentLocationCoordinate = self.dispatchLocation;
        }
        else{
            dictParams[kSendSMSAndEmailAlertFuncParamDispatchModeKey] = @(2);
        }
        dictParams[kSendSMSAndEmailAlertFuncParamLatKey] = @(currentLocationCoordinate.latitude);
        dictParams[kSendSMSAndEmailAlertFuncParamLongKey] = @(currentLocationCoordinate.longitude);
        
        NSError *err = nil;
        NSData *arrContactsJsonData = [NSJSONSerialization dataWithJSONObject:arrContacts options:NSJSONWritingPrettyPrinted error:&err];
        if (!err && arrContactsJsonData) {
            
            NSString *strJsonArrContacts = [[NSString alloc]initWithData:arrContactsJsonData encoding:NSUTF8StringEncoding];
            if (strJsonArrContacts.length > 0) {
                
                dictParams[kSendSMSAndEmailAlertFuncParamContactArrayKey] = strJsonArrContacts;
                
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                __weak typeof(self) weakSelf = self;
                [C411StaticHelper sendSMSAndEmailAlertWithDetails:dictParams cloudFuncName:kSendSMSAndEmailAlertFuncNameKey andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
                    
                    if(!error){
                        
                        [AppDelegate showToastOnView:nil withMessage:NSLocalizedString(@"Alert sent successfully", nil)];
                    }
                    else{
                        
                        [C411StaticHelper showAlertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription onViewController:weakSelf];
                    }
                    
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                }];
                
            }
        }
        
    }
    
    ///Clear photo data if its available in case of photo alert
    self.photoFile = nil;
    self.photoData = nil;
    self.photoImage = nil;

    ///Dismiss the send alert popup
    [self dismissSendAlertPopup:nonAppUsersSelectionVC.sendAlertPopupVC];
    
    ///Pop the non app users selection vc
    UINavigationController *rootNavC = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    [rootNavC popViewControllerAnimated:YES];
    
}



#endif



//****************************************************
#pragma mark - C411PublicCellSelectionVCDelegate Methods
//****************************************************

-(void)publicCellSelectionVC:(C411PublicCellSelectionVC *)publicCellSelectionVC didSelectPublicCell:(PFObject *)publicCell
{
    ///save values
    C411Audience *alertAudience = [[C411Audience alloc]init];
    alertAudience.audienceType = AudienceTypePublicCellMembers;
    alertAudience.audienceCell = publicCell;
    
    C411Alert *alert = [[C411Alert alloc]init];
    alert.alertType = publicCellSelectionVC.alertType;
    [alert.arrAudiences addObject:alertAudience];
    
    ///remove the popup
    [self dismissPublicCellSelectionPopup:publicCellSelectionVC];
    
    [self showAdditionalNotePopupForAlert:alert];
    
}


/*OLD CODE
-(void)publicCellSelectionVC:(C411PublicCellSelectionVC *)publicCellSelectionVC didSelectPublicCell:(PFObject *)publicCell
{
    ///save values
    NSInteger alertType = publicCellSelectionVC.alertType;
    PFObject *alertRecievingCell = publicCell;
    
    ///remove the popup
    [self dismissPublicCellSelectionPopup:publicCellSelectionVC];
    
    
    ///Create Alert title
    NSString *strAlertTitle = nil;
    NSString *strMessage = nil;
    
    
    strAlertTitle = NSLocalizedString(@"Add a note?", nil);
    
    NSString *strPlaceholder = NSLocalizedString(@"Additional text message if any", nil);
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:strAlertTitle
                                          message:strMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = strPlaceholder;
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       ///User tapped cancel,
                                       [self clearAlertAssociatedIVars];
                                       
                                       ///Dequeue the current Alert Controller and allow other to be visible
                                       [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                   }];
    UIAlertAction *sendAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Send", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     ///User tapped Send, make the params dict and send it to a cloud function
                                     
                                     UITextField *txtAdditionalNote = alertController.textFields.firstObject;
                                     NSString *strAdditionalNote = txtAdditionalNote.text;
                                     if (strAdditionalNote.length > 0) {
                                         ///trim the white spaces
                                         strAdditionalNote = [strAdditionalNote stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                     }
                                     
                                     strAdditionalNote = strAdditionalNote ? strAdditionalNote : @"";
                                     NSString *strCellId = alertRecievingCell.objectId;
                                     NSString *strCellName = alertRecievingCell[kPublicCellNameKey];
                                     ///by default IER endpoint should not be called
                                     BOOL shouldCallIEREndPoint = NO;
#if APP_IER
                                     ///IER endpoint should be called
                                     shouldCallIEREndPoint = YES;
#endif
                                     [self sendAlertToPublicCellWithAdditionalNote:strAdditionalNote alertType:alertType onCellWithId:strCellId cellName:strCellName shouldCallIEREndPoint:shouldCallIEREndPoint];
                                     
                                     ///Dequeue the current Alert Controller and allow other to be visible
                                     [[MAAlertPresenter sharedPresenter]dequeueAlert];

                                 }];
    [alertController addAction:cancelAction];
    [alertController addAction:sendAction];
    //[self presentViewController:alertController animated:YES completion:NULL];
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

    
}
*/

-(void)publicCellSelectionVCDidCancel:(C411PublicCellSelectionVC *)publicCellSelectionVC
{
    
    ///remove the popup
    [self dismissPublicCellSelectionPopup:publicCellSelectionVC];
    
    ///Clear photo data if its available in case of photo alert
    self.photoFile = nil;
    self.photoData = nil;
    self.photoImage = nil;
}


#if VIDEO_STREAMING_ENABLED

//****************************************************
#pragma mark - C411VideoStreamPopupVCDelegate Methods
//****************************************************

-(void)videoStreamPopupVCDidTappedStreamVideo:(C411VideoStreamPopupVC *)videoStreamPopupVC
{
    ///Get the alert params
    NSDictionary *dictAlertParams = videoStreamPopupVC.dictAlertParams;
    
    ///Get the alert object
    C411Alert *alert = videoStreamPopupVC.alert;
    
    ///Start streaming
    if(dictAlertParams){
        ///Popup displayed from SendAlertV3 implementation(sendAlertWithAlertParams: method)
    
        ///Remove popup
        videoStreamPopupVC.delegate = nil;
        [self dismissVideoStreamPopup:videoStreamPopupVC];
        ///Update the alert Id, title and type flags
        NSMutableDictionary *dictVideoAlertParams = [dictAlertParams mutableCopy];
        dictVideoAlertParams[kSendAlertV3FuncParamAlertIdKey] = @(AlertTypeVideo);
        dictVideoAlertParams[kSendAlertV3FuncParamTitleKey] = [C411StaticHelper getAlertTypeStringUsingAlertType:AlertTypeVideo];
        dictVideoAlertParams[kSendAlertV3FuncParamTypeKey] = kPayloadAlertTypeVideo;
        
        [dictVideoAlertParams removeObjectForKey:kSendAlertV3FuncParamAdditionalNoteKey];

        [self streamVideoWithAlertParams:dictVideoAlertParams];
        
    }
    else if(alert){
        ///Popup displayed from new implementation(sendAlert: method to issue alert via cloud code)
        ///Remove popup
        videoStreamPopupVC.delegate = nil;
        [self dismissVideoStreamPopup:videoStreamPopupVC];

        [self initiateAlert:alert];
    }
    else{
        ///Popup displayed from old implementation(sendNotificationWithType:toMembers:nauMembers:withAdditionalNote:andCompletion method to issue alert via cloud code)
        ///Remove popup
        videoStreamPopupVC.delegate = nil;
        [self dismissVideoStreamPopup:videoStreamPopupVC];

        [self sendNotificationWithType:BTN_ALERT_TAG_VIDEO toMembers:self.arrAlertAudience nauMembers:nil withAdditionalNote:nil andCompletion:NULL];
        
    }
    
}

-(void)videoStreamPopupVCDidTappedCancel:(C411VideoStreamPopupVC *)videoStreamPopupVC
{
    ///Remove popup
    videoStreamPopupVC.delegate = nil;
    [self dismissVideoStreamPopup:videoStreamPopupVC];
    
    ///Clear iVars
    [self clearAlertAssociatedIVars];
    
}
#endif

#if VIDEO_STREAMING_ENABLED
//****************************************************
#pragma mark - VideoPlayerViewControllerDelegate Methods
//****************************************************

-(void)videoBroadcastingVCDidClosed:(VideoPlayerViewController *)videoBroadcastingVC
{
    ///update the status
    if (self.cell411AlertForVdoStreaming) {
        
        ///Hold the local reference of iVar and clear the iVar
        PFObject * cell411AlertForVdoStreaming = self.cell411AlertForVdoStreaming;
        self.cell411AlertForVdoStreaming = nil;
        
        ///Update the status to VOD if its LIVE, which means user has streamed video for more than 10 secs and its data has been updated on Parse with status updated to LIVE from PROC_VID
        if ([cell411AlertForVdoStreaming[kCell411AlertStatusKey]isEqualToString:kAlertStatusLive]) {
            ///set status from LIVE to VOD
            cell411AlertForVdoStreaming[kCell411AlertStatusKey] = kAlertStatusVOD;
            
            [cell411AlertForVdoStreaming saveEventually];
            NSLog(@"m->updating to VOD");
        }
        else if([cell411AlertForVdoStreaming[kCell411AlertStatusKey]isEqualToString:kAlertStatusProcessingVideo]) {
            ///Delete this alert as user has not streamed for more than 10 seconds
            [cell411AlertForVdoStreaming deleteEventually];
            NSLog(@"m->deleting");
            
        }
        
        
        
    }
    
    videoBroadcastingVC.delegate = nil;
    self.videoPush = nil;
    self.cell411AlertForVdoStreamingWithData = nil;
    
    ///Allow the app to sleep again if idle, as streaming is stopped
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void)videoBroadcastingVCDidStartBroadcasting:(VideoPlayerViewController *)videoBroadcastingVC
{
    if(videoBroadcastingVC.dictAlertParams){
        
        __weak typeof(self) weakSelf = self;
        [self sendAlertWithAlertParams:videoBroadcastingVC.dictAlertParams andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                weakSelf.cell411AlertForVdoStreaming[kCell411AlertStatusKey] = kAlertStatusLive;
            }
        }];
    }
    else if (self.cell411AlertForVdoStreamingWithData && self.cell411AlertForVdoStreaming) {
        
        ///Update empty cell411alert object with saved data and its status to LIVE from PROC_VID
        ///1. copy data to empty alert object
        self.cell411AlertForVdoStreaming[kCell411AlertAdditionalNoteKey] = self.cell411AlertForVdoStreamingWithData[kCell411AlertAdditionalNoteKey];
        self.cell411AlertForVdoStreaming[kCell411AlertAlertTypeKey] = self.cell411AlertForVdoStreamingWithData[kCell411AlertAlertTypeKey];
        self.cell411AlertForVdoStreaming[kCell411AlertIssuedByKey] = self.cell411AlertForVdoStreamingWithData[kCell411AlertIssuedByKey];
        self.cell411AlertForVdoStreaming[kCell411AlertIssuerFirstNameKey] = self.cell411AlertForVdoStreamingWithData[kCell411AlertIssuerFirstNameKey];
        self.cell411AlertForVdoStreaming[kCell411AlertIssuerIdKey] = self.cell411AlertForVdoStreamingWithData[kCell411AlertIssuerIdKey];
        
        self.cell411AlertForVdoStreaming[kCell411AlertLocationKey] = self.cell411AlertForVdoStreamingWithData[kCell411AlertLocationKey];
        
        self.cell411AlertForVdoStreaming[kCell411AlertTargetMembersKey] = self.cell411AlertForVdoStreamingWithData[kCell411AlertTargetMembersKey];
        ///Set video streaming status
        self.cell411AlertForVdoStreaming[kCell411AlertStatusKey] = kAlertStatusLive;
        
        
        ///Set isGloabl to 1 if this being sent to patrol members else 0
        self.cell411AlertForVdoStreaming[kCell411AlertIsGlobalKey] = self.cell411AlertForVdoStreamingWithData[kCell411AlertIsGlobalKey];
        
        ///2.Save this alert in background with callback handler and in success callback send the push, if error occurs then save it eventually as its updation on parse is really necessary.
        
        // Request a background execution task to allow us to finish updating the cell411Alert object  even if the app is backgrounded.
        self.sendAlertTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.sendAlertTaskId];
        }];
        
        __weak typeof(self) weakSelf = self;
        //Get local reference of video push iVar and clear iVar reference
        PFPush *videoPush = self.videoPush;
        self.videoPush = nil;
        NSLog(@"m->Setting VOD");
        [self.cell411AlertForVdoStreaming saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            
            if (succeeded) {
                
                ///3.Send video push
                if (videoPush) {
                    
                    ///Send Push Notification for video broadcasting
                    ///2.Send Push in Background
                    [videoPush sendPushInBackground];
                    NSLog(@"m->sending Video Push");
                }
                NSLog(@"m->Setting VOD succeed");
                
            }
            else{
                
                ///Some error occured, save object eventually.
                [weakSelf.cell411AlertForVdoStreaming saveEventually];
                NSLog(@"m->error occurred");
            }
            ///End background task
            [[UIApplication sharedApplication] endBackgroundTask:self.sendAlertTaskId];
            
        }];
        
        
        ///Release the reference of cell411AlertForVdoStreamingWithData hold in iVar
        self.cell411AlertForVdoStreamingWithData = nil;
        
        
    }
    
}
#endif

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)locationManagerDidUpdatedLocation:(NSNotification *)notif
{
    CLLocation *currentLocation = notif.object;
    
    ///update user location
    [self.currentLocationMarker setPosition:currentLocation.coordinate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ((!self.didReceivedFirstLocationUpdate)
        ||([defaults boolForKey:kCenterUserLocation])) {
        
        ///Animate map to current location if the center map location button is on or if the location update has been received first time
        [self.mapView animateToLocation:currentLocation.coordinate];
        
    }
    
    ///Set the flag to Yes as the location update has been received
    self.receivedFirstLocationUpdate = YES;

}

//-(void)locationAccuracyValueChanged:(NSNotification *)notif
//{
//    /*
//     NSNumber *locationAccuracy = notif.object;
//     if (locationAccuracy) {
//
//     BOOL isLocationAccuracyOn = [locationAccuracy boolValue];
//     if (isLocationAccuracyOn) {
//
//     [LocationManager sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//
//     }
//     else{
//
//     [LocationManager sharedInstance].locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//     }
//
//     }
//     */
//}
//
//-(void)locationUpdateValueChanged:(NSNotification *)notif
//{
//    ///TODO:Commented for now, need to handle this
////    NSNumber *updateLocation = notif.object;
////    if (updateLocation) {
////
////        BOOL shouldUpdateLocation = [updateLocation boolValue];
////        if (shouldUpdateLocation) {
////
////            //[[LocationManager sharedInstance].locationManager startUpdatingLocation];
////            [[LocationManager sharedInstance].ambientLocationManager startMonitoringAmbientLocationChanges];
////
////        }
////        else{
////
////            //[[LocationManager sharedInstance].locationManager stopUpdatingLocation];
////            [[LocationManager sharedInstance].ambientLocationManager stopMonitoringAmbientLocationChanges];
////
////        }
////
////    }
//
//
//}
//
//-(void)patrolModeValueChanged:(NSNotification *)notif
//{
//    /*
//     NSNumber *patrolModeValue = notif.object;
//     if (patrolModeValue) {
//
//     BOOL shouldEnablePatrolMode = [patrolModeValue boolValue];
//     PFUser *currentUser = [AppDelegate getLoggedInUser];
//     BOOL shouldNotifyOnNewPublicCellCreation = [currentUser[kUserNewPublicCellAlertKey] boolValue];
//
//     if (shouldEnablePatrolMode && !shouldNotifyOnNewPublicCellCreation) {
//     ///Both Patrol Mode and New Public Cell Creation options were off and now Patrol mode is turned on, so retrieve location in BG and when app is killed
//     //            [[LocationManager sharedInstance].significantLocationManager startMonitoringSignificantLocationChanges];
//     [[LocationManager sharedInstance].ambientLocationManager startMonitoringAmbientLocationChanges];
//     [self updateAllowBackgroundLocationUpdate:YES];
//
//     }
//     else if (!shouldEnablePatrolMode && !shouldNotifyOnNewPublicCellCreation){
//     ///New Public Cell Creation option was already off and user has turned off patrol mode as well, so stop retrieving user location in BG and when app is killed
//     //            [[LocationManager sharedInstance].significantLocationManager stopMonitoringSignificantLocationChanges];
//     [[LocationManager sharedInstance].ambientLocationManager stopMonitoringAmbientLocationChanges];
//
//
//     [self updateAllowBackgroundLocationUpdate:NO];
//     }
//     }
//     */
//
//}
//
//-(void)newPublicCellCreationAlertValueChanged:(NSNotification *)notif
//{
//    /*
//     NSNumber *notifyOnNewPublicCellValue = notif.object;
//     if (notifyOnNewPublicCellValue) {
//
//     BOOL shouldNotifyOnNewPublicCellCreation = [notifyOnNewPublicCellValue boolValue];
//
//     PFUser *currentUser = [AppDelegate getLoggedInUser];
//     BOOL isPatrolModeEnabled = [currentUser[kUserPatrolModeKey]boolValue];
//
//
//     if (shouldNotifyOnNewPublicCellCreation && !isPatrolModeEnabled) {
//     ///Both Patrol Mode and New Public Cell Creation options were off and New Public Cell Creation option is turned on, so retrieve location in BG and when app is killed
//     //            [[LocationManager sharedInstance].significantLocationManager startMonitoringSignificantLocationChanges];
//
//     [[LocationManager sharedInstance].ambientLocationManager startMonitoringAmbientLocationChanges];
//
//
//     [self updateAllowBackgroundLocationUpdate:YES];
//
//     }
//     else if (!shouldNotifyOnNewPublicCellCreation && !isPatrolModeEnabled){
//     /// patrol mode was already off and user has turned off New Public Cell Creation option as well, so stop retrieving user location in BG and when app is killed
//     //            [[LocationManager sharedInstance].significantLocationManager stopMonitoringSignificantLocationChanges];
//
//     [[LocationManager sharedInstance].ambientLocationManager stopMonitoringAmbientLocationChanges];
//
//     [self updateAllowBackgroundLocationUpdate:NO];
//     }
//     }
//     */
//
//}

-(void)sendPanicOrFallenAlert:(NSNotification *)notif
{
    NSNumber *numAlertType = [notif.userInfo objectForKey:kPanicOrFallenAlertTypeKey];
    if (numAlertType) {
        
        // Request a background execution task to allow us to finish saving the cell411Alert object  even if the app is backgrounded
        self.sendPanicOrFallenAlertTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.sendPanicOrFallenAlertTaskId];
        }];

        NSInteger alertType = numAlertType.integerValue;
        ///Get the panic alert settings
        C411PanicAlertSettings *panicAlertSettings = [C411PanicAlertSettings getPanicAlertSettings];
        NSString *strAdditionalNote = panicAlertSettings.strAdditionalNote ? panicAlertSettings.strAdditionalNote : @"";
       
        ///send public alerts if selected and enabled
        NSDictionary *dictPublicCells = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPublicCellsMembersKey];
        if (dictPublicCells && [[dictPublicCells objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
            
            ///Public Cells option is selected
            ///1. Get the selected Public Cells Array
            NSArray *arrSelectedPublicCells = [dictPublicCells objectForKey:kPanicAlertRecipientSelectedCellsKey];
            
            ///Iterate the array and send alert on public cell without calling iER end point even for iER app as it will send multiple request, also the iER endpoint will be called if sendNotificationWithType:toMembers:withAdditionalNote:andCompletion: get's called from iER app
            
            for (NSDictionary *dictSelectedPublicCell in arrSelectedPublicCells) {
                
                NSString *strCellId = [dictSelectedPublicCell objectForKey:kPanicAlertRecipientSelectedCellIdKey];
                NSString *strCellName = [dictSelectedPublicCell objectForKey:kPanicAlertRecipientSelectedCellNameKey];
                [self sendAlertToPublicCellWithAdditionalNote:strAdditionalNote alertType:alertType onCellWithId:strCellId cellName:strCellName shouldCallIEREndPoint:NO];
                
            }
            
            
        }
        
        
        ///Get the members of private cells or all friends and near by if they are enabled and send alert
        BOOL allFriendsSelected = NO;
        BOOL privateCellsSelected = NO;
        BOOL nearBySelected = NO;
        
        NSDictionary *dictAllFriends = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientAllFriendsKey];
        if (dictAllFriends && [[dictAllFriends objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
            
            ///All friends option is selected
            allFriendsSelected = YES;
            
        }
        else{
            
            ///2.Check for Private Cell option is selected or not. Both All Friends and Private Cell are Mutually Exclusive
            NSDictionary *dictPrivateCells = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey];
            if (dictPrivateCells && [[dictPrivateCells objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
                
                ///Private Cells option is selected
                privateCellsSelected = YES;
                
            }
            
            
        }
        
        ///3. Check for near by option
        NSDictionary *dictNearBy = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientNearMeKey];
        if (dictNearBy && [[dictNearBy objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
            
            ///Near me option is selected
            nearBySelected = YES;
            
        }

        if (allFriendsSelected
            ||privateCellsSelected
            ||nearBySelected) {
            
            ///clear the presaved ivars
            [self clearAlertAssociatedIVars];
            
            if (allFriendsSelected) {
                ///Get all friends
               __weak typeof(self) weakSelf = self;
                [self getAllFriendsWithCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    ///Get friends array
                    NSArray *arrFriends = nil;
                    if (objects && objects.count > 0) {
                        
                        arrFriends = objects;
                    }
                    
                    ///Get near by if it's enabled
                    if (nearBySelected) {
                        
                        [weakSelf getPatrolMembersWithCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                            
                            ///Get patrol members array
                            NSArray *arrPatrolMembers = nil;
                            if (objects && objects.count > 0) {
                                
                                arrPatrolMembers = objects;
                            
                            }

                            ///make the alert recipients array
                            NSArray *arrAlertRecipients = nil;
                            if (arrFriends.count > 0 && arrPatrolMembers.count > 0) {
                                
                                ///merge friends and patrol members
                                NSArray *arrRecipientsWithDuplicates = [arrFriends arrayByAddingObjectsFromArray:arrPatrolMembers];
                                
                                ///Get the unique array by removing duplicate objects
                                arrAlertRecipients = [C411StaticHelper getUniqueParseObjectsFromArray:arrRecipientsWithDuplicates];

                            }
                            else if (arrFriends.count > 0){
                                ///send alert to friends
                                arrAlertRecipients = arrFriends;
                            }
                            else{
                                ///send alert to patrol members
                                arrAlertRecipients = arrPatrolMembers;
                            }
                            
                            ///send alert to alert recipients
                            [weakSelf sendNotificationWithType:alertType toMembers:arrAlertRecipients nauMembers:nil withAdditionalNote:strAdditionalNote andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                                
                                ///Handle completion of panic alert
                                [weakSelf handleCompletionOfPanicOrFallenAlertWithAlertType:alertType];
                                
                            }];
                            
                        }];
                    }
                    else{
                        
                        ///near by option is not selected, send alert to all friends
                        
                        [weakSelf sendNotificationWithType:alertType toMembers:arrFriends nauMembers:nil withAdditionalNote:strAdditionalNote andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                            
                            ///Handle completion of panic alert
                            [weakSelf handleCompletionOfPanicOrFallenAlertWithAlertType:alertType];

                            
                        }];
                    }
                    
                }];
                
            }
            else if (privateCellsSelected){
            
                __weak typeof(self) weakSelf = self;
                NSMutableArray *arrSelectedPrivateCellIds = [NSMutableArray array];
                NSDictionary *dictPrivateCells = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey];
                if (dictPrivateCells) {
                   
                    ///Get the array of the selected Private Cells
                    NSArray *arrSelectedPrivateCells = [dictPrivateCells objectForKey:kPanicAlertRecipientSelectedCellsKey];
                    ///Iterate the array and make another array of cell ids
                    for (NSDictionary *dictSelectedPrivateCell in arrSelectedPrivateCells) {
                        
                        NSString *strCellId = [dictSelectedPrivateCell objectForKey:kPanicAlertRecipientSelectedCellIdKey];
                        [arrSelectedPrivateCellIds addObject:strCellId];
                        
                    }

                
                }
                [self getPrivateCellMembersOfCellsWithIds:arrSelectedPrivateCellIds withCompletion:^(id _Nullable object, NSError * _Nullable error) {
                    
                    ///Get private cells members array
                    NSArray *arrPrivateCellsMembers = nil;
                    NSArray *arrPrivateCellsNauMembers = nil;
                    if (object) {
                        
                        NSDictionary *dictPrivateCellsMembers = (NSDictionary *)object;
                        
                        arrPrivateCellsMembers = dictPrivateCellsMembers[kCellMembersKey];
                        arrPrivateCellsNauMembers = dictPrivateCellsMembers[kCellNauMembersKey];
                    }
                    
                    ///Get near by if it's enabled
                    if (nearBySelected) {
                        
                        [weakSelf getPatrolMembersWithCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                            
                            ///Get patrol members array
                            NSArray *arrPatrolMembers = nil;
                            if (objects && objects.count > 0) {
                                
                                arrPatrolMembers = objects;
                                
                            }
                            
                            ///make the alert recipients array
                            NSArray *arrAlertRecipients = nil;
                            if (arrPrivateCellsMembers.count > 0 && arrPatrolMembers.count > 0) {
                                
                                ///merge Private Cells Members and patrol members
                                NSArray *arrRecipientsWithDuplicates = [arrPrivateCellsMembers arrayByAddingObjectsFromArray:arrPatrolMembers];
                                
                                ///Get the unique array by removing duplicate objects
                                arrAlertRecipients = [C411StaticHelper getUniqueParseObjectsFromArray:arrRecipientsWithDuplicates];
                                
                            }
                            else if (arrPrivateCellsMembers.count > 0){
                                ///send alert to unique Private Cells Members
                                arrAlertRecipients = [C411StaticHelper getUniqueParseObjectsFromArray:arrPrivateCellsMembers];
                            }
                            else{
                                ///send alert to patrol members
                                arrAlertRecipients = arrPatrolMembers;
                            }
                            
                            ///send alert to alert recipients
                            [weakSelf sendNotificationWithType:alertType toMembers:arrAlertRecipients nauMembers:arrPrivateCellsNauMembers withAdditionalNote:strAdditionalNote andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                                
                                ///Handle completion of panic alert
                                [weakSelf handleCompletionOfPanicOrFallenAlertWithAlertType:alertType];
                                
                            }];
                            
                        }];
                    }
                    else{
                        
                        ///near by option is not selected, get the unique members of priviate cells membars array and send alert to them
                        
                        NSArray *arrAlertRecipients = [C411StaticHelper getUniqueParseObjectsFromArray:arrPrivateCellsMembers];
                        
                        [weakSelf sendNotificationWithType:alertType toMembers:arrAlertRecipients nauMembers:arrPrivateCellsNauMembers withAdditionalNote:strAdditionalNote andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                            
                            ///Handle completion of panic alert
                            [weakSelf handleCompletionOfPanicOrFallenAlertWithAlertType:alertType];
                            
                        }];
                    }
                    
                }];

                
            }
            else if (nearBySelected){
                
                __weak typeof(self) weakSelf = self;
                [self getPatrolMembersWithCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    ///Get patrol members array
                    NSArray *arrPatrolMembers = nil;
                    if (objects && objects.count > 0) {
                        
                        arrPatrolMembers = objects;
                        
                    }
                    
                    
                    ///send alert to patrol members
                    [weakSelf sendNotificationWithType:alertType toMembers:arrPatrolMembers nauMembers:nil withAdditionalNote:strAdditionalNote andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        ///Handle completion of panic alert
                        [weakSelf handleCompletionOfPanicOrFallenAlertWithAlertType:alertType];


                        
                    }];
                    
                    
                }];
            }
            
        }
        else{
            
            //sendNotificationWithType:toMembers:withAdditionalNote:andCompletion: is not called so call iER end point for iER APP
#if APP_IER
            
            ///Make an IER API call as well for alerts
            PFUser *alertIssuer = [AppDelegate getLoggedInUser];
            NSString *strAlertType = [C411StaticHelper getAlertTypeStringUsingAlertTypeTag:alertType];
            CLLocationCoordinate2D currentLocationCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
            [self sendIERAlertFromIssuerWithId:alertIssuer.objectId alertType:strAlertType additionalNote:strAdditionalNote locationCoordinate:currentLocationCoordinate andPhotoUrl:nil andCompletion:^(NSError *error, id data) {
                
                ///Do anything on completion
            
            }];
            
#endif
            ///Handle completion of panic alert
            [self handleCompletionOfPanicOrFallenAlertWithAlertType:alertType];
        }

    }
    
    
    
}

-(void)showRideStatusOverlay:(NSNotification *)notif
{
    [self showRideOverlayIfRequired];
    
}

-(void)hideRideStatusOverlay:(NSNotification *)notif
{
    NSString *strRideRequestId = notif.object;
    if ([strRideRequestId isEqualToString:self.vuRideStatusOverlay.rideRequest.objectId]) {
        
        [self.vuRideStatusOverlay hideOverlay];
 
    }
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
