//
//  C411RequestRideVC.m
//  cell411
//
//  Created by Milan Agarwal on 22/09/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RequestRideVC.h"
#import "UIButton+FAB.h"
#import "C411StaticHelper.h"
#import "C411LocationManager.h"
#import "ServerUtility.h"
#import "Constants.h"
#import "MAAlertPresenter.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "C411ColorHelper.h"
@import GooglePlaces;


@interface C411RequestRideVC ()<GMSMapViewDelegate,GMSAutocompleteViewControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *vuPickupAddressBase;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnSearchPickupAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnPickupAddressSelector;
@property (weak, nonatomic) IBOutlet UIView *vuDropAddressBase;
@property (weak, nonatomic) IBOutlet UILabel *lblDropAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnSearchDropAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnDropAddressSelector;
@property (weak, nonatomic) IBOutlet UIButton *btnFABCenterCurrentLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnAdjustZoomToShowAllPins;
@property (weak, nonatomic) IBOutlet UIButton *btnRequestRide;
@property (strong, nonatomic) IBOutlet UIView *vuAddNoteAndRadiusSelectionPopupBase;
@property (weak, nonatomic) IBOutlet UIView *vuAddNoteAndRadiusSelectionPopup;
@property (weak, nonatomic) IBOutlet UILabel *lblAddNoteAndRadiusSelectionPopupTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAddNoteAndRadiusSelectionPopupSubtitle;
@property (weak, nonatomic) IBOutlet UITextField *txtAdditionalNote;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNoteSeparator;
@property (weak, nonatomic) IBOutlet UIView *vuLookupRadiusSelection;
@property (weak, nonatomic) IBOutlet UILabel *lblRadiusSelectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRadiusRange;
@property (weak, nonatomic) IBOutlet UIView *vuSelectedRadius;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedRadius;
@property (weak, nonatomic) IBOutlet UISlider *sldrLookupRadius;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UIView *vuDistanceAndCostEstimate;
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceAndCostEstimate;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsDistanceAndCostEstimateViewHeight;
- (IBAction)btnSelectPickupAddressTapped:(UIButton *)sender;
- (IBAction)btnSearchPickupAddressTapped:(UIButton *)sender;
- (IBAction)btnSelectDropAddressTapped:(UIButton *)sender;
- (IBAction)btnSearchDropAddressTapped:(UIButton *)sender;
- (IBAction)btnFABCenterCurentLocationTapped:(UIButton *)sender;
- (IBAction)btnAdjustZoomToShowAllPinsTapped:(UIButton *)sender;
- (IBAction)btnRequestRideTapped:(UIButton *)sender;
- (IBAction)barBtnChangeMapTypeTapped:(UIBarButtonItem *)sender;
- (IBAction)sldrLookupRadiusChanged:(UISlider *)sender;
- (IBAction)btnCancelTapped:(UIButton *)sender;
- (IBAction)btnContinueTapped:(UIButton *)sender;

@property (nonatomic, assign, getter=isFirstTime) BOOL firstTime;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSURLSessionDataTask *getLocationTask;
@property (nonatomic, strong) GMSMarker *pickupMarker;
@property (nonatomic, strong) GMSMarker *dropAtMarker;
@property (nonatomic, weak) UIButton *btnSelectedAddressSelector;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpToDropDistanceMatrixTask;

@end

@implementation C411RequestRideVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [self setInitialSettings];
    self.firstTime = YES;
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    ///Unhide the navigation bar
//    self.navigationController.navigationBarHidden = NO;
//    
//}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isFirstTime) {
        
        self.firstTime = NO;
        ///add google map
        CLLocationCoordinate2D currentLocCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;

        [self addGoogleMapWithAlertCoordinate:currentLocCoordinate];
        
        ///Add pickup address marker to current location
        if (!self.pickupMarker) {
            ///Create current location marker and add it to map
            self.pickupMarker=[[GMSMarker alloc]init];
            self.pickupMarker.position = currentLocCoordinate;
            //self.currentLocationMarker.groundAnchor = CGPointMake(0.5, 0.5);
            ///Select the current location marker by default
            self.pickupMarker.map = self.mapView;
            self.pickupMarker.icon = [UIImage imageNamed:@"ic_pin_pick_up_from"];
            
            [self centerMapToCoordinate:currentLocCoordinate];
        }
    }
}

-(void)dealloc
{
    [self.pickUpToDropDistanceMatrixTask cancel];
    self.pickUpToDropDistanceMatrixTask = nil;
    [self unregisterFromNotifications];
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
    self.title = NSLocalizedString(@"Request Ride", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    ///Set rounded corners
    self.vuDistanceAndCostEstimate.layer.cornerRadius = 3.0;
    self.vuDistanceAndCostEstimate.layer.masksToBounds = YES;
    self.vuPickupAddressBase.layer.cornerRadius = 3.0;
    self.vuPickupAddressBase.layer.masksToBounds = YES;
    self.vuDropAddressBase.layer.cornerRadius = 3.0;
    self.vuDropAddressBase.layer.masksToBounds = YES;
    self.btnSearchPickupAddress.layer.cornerRadius = 3.0;
    self.btnSearchPickupAddress.layer.masksToBounds = YES;
    self.btnSearchDropAddress.layer.cornerRadius = 3.0;
    self.btnSearchDropAddress.layer.masksToBounds = YES;
    self.btnRequestRide.layer.cornerRadius = 3.0;
    self.btnRequestRide.layer.masksToBounds = YES;
    self.vuAddNoteAndRadiusSelectionPopup.layer.cornerRadius = 3.0;
    self.vuAddNoteAndRadiusSelectionPopup.layer.masksToBounds = YES;
    self.vuLookupRadiusSelection.layer.cornerRadius = 3.0;
    self.vuLookupRadiusSelection.layer.masksToBounds = YES;
    
    ///Make button as FAB buttons
    [self.btnFABCenterCurrentLocation makeFloatingActionButton];
    
    [self.btnAdjustZoomToShowAllPins makeFloatingActionButton];
    
    self.vuPickupAddressBase.layer.borderWidth = 0;
    self.vuDropAddressBase.layer.borderWidth = 0;
    ///make circular views
    [C411StaticHelper makeCircularView:self.btnInfo];

    ///set current patrol radius value container corner radius
    self.vuSelectedRadius.layer.cornerRadius = self.vuSelectedRadius.bounds.size.height / 2;
    self.vuSelectedRadius.layer.masksToBounds = YES;
    
    
    [self applyColors];
}

-(void)updateMapStyle {
    self.mapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
}

-(void)applyColors {
    ///Update map style
    [self updateMapStyle];
    
    ///Set background color
    UIColor *backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    self.vuPickupAddressBase.backgroundColor = backgroundColor;
    self.vuDropAddressBase.backgroundColor = backgroundColor;
    self.vuDistanceAndCostEstimate.backgroundColor = backgroundColor;
    self.vuAddNoteAndRadiusSelectionPopup.backgroundColor = backgroundColor;
    
    ///Set theme colors on buttons
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnSearchPickupAddress.backgroundColor = themeColor;
    self.btnSearchDropAddress.backgroundColor = themeColor;
    self.btnRequestRide.backgroundColor = themeColor;
    self.vuPickupAddressBase.layer.borderColor = themeColor.CGColor;
    self.vuDropAddressBase.layer.borderColor = themeColor.CGColor;
    
    ///Set light theme color
    UIColor *lightThemeColor = [C411ColorHelper sharedInstance].lightThemeColor;
    self.btnInfo.backgroundColor = lightThemeColor;

    ///Set primaryBgText color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.btnSearchPickupAddress.tintColor = primaryBGTextColor;
    self.btnSearchDropAddress.tintColor = primaryBGTextColor;
    [self.btnRequestRide setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    ///Set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblDistanceAndCostEstimate.textColor = primaryTextColor;
    self.lblPickupAddress.textColor = primaryTextColor;
    self.lblDropAddress.textColor = primaryTextColor;
    self.lblAddNoteAndRadiusSelectionPopupTitle.textColor = primaryTextColor;
    self.lblAddNoteAndRadiusSelectionPopupSubtitle.textColor = primaryTextColor;
    self.txtAdditionalNote.textColor = primaryTextColor;
    self.lblRadiusSelectionTitle.textColor = primaryTextColor;

    ///Set disabled color for placeholder text
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtAdditionalNote];
    
    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuAdditionalNoteSeparator.backgroundColor = separatorColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblRadiusRange.textColor = secondaryTextColor;
    
    ///set card light color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuLookupRadiusSelection.backgroundColor = lightCardColor;
    
    ///set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    self.sldrLookupRadius.minimumTrackTintColor = secondaryColor;
    self.sldrLookupRadius.maximumTrackTintColor = secondaryColor;
    self.sldrLookupRadius.thumbTintColor = secondaryColor;
    [self.btnCancel setTitleColor:secondaryColor forState:UIControlStateNormal];
    [self.btnContinue setTitleColor:secondaryColor forState:UIControlStateNormal];
    
    ///Set fab selected color
    UIColor *fabSelectedColor = [C411ColorHelper sharedInstance].fabSelectedColor;
    self.btnFABCenterCurrentLocation.backgroundColor = fabSelectedColor;
    self.btnAdjustZoomToShowAllPins.backgroundColor = fabSelectedColor;

    ///set fab shadow color
    UIColor *fabShadowColor = [C411ColorHelper sharedInstance].fabShadowColor;
    self.btnFABCenterCurrentLocation.layer.shadowColor = fabShadowColor.CGColor;
    self.btnAdjustZoomToShowAllPins.layer.shadowColor = fabShadowColor.CGColor;

    ///Set fab selected tint color
    UIColor *fabSelectedTintColor = [C411ColorHelper sharedInstance].fabSelectedTintColor;
    self.btnFABCenterCurrentLocation.tintColor = fabSelectedTintColor;
    self.btnAdjustZoomToShowAllPins.tintColor = fabSelectedTintColor;
    
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setInitialSettings
{
    ///select pickup from address by default
    //self.btnPickupAddressSelector.selected = YES;
    self.btnSelectedAddressSelector = self.btnPickupAddressSelector;
    [self updateLocationSelection];
    
    ///set current address as the pickup address initially
    [self updateLocationonLabel:self.lblPickupAddress usingCoordinate:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];

    if (!self.dropAtMarker) {
        
        ///Hide the adjust zoom button
        self.btnAdjustZoomToShowAllPins.hidden = YES;
        
        ///Hide the info view
        self.cnsDistanceAndCostEstimateViewHeight.constant = 0;
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ///Get metric chosen by user
    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
    ///Set patrol mode radius
    int patrolModeRadius = [[defaults objectForKey:kPatrolModeRadius]floatValue];///will be in miles as it will always be saved in miles in user defaults
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///set values in kms
        ///convert patrol mode radius to km
        patrolModeRadius = patrolModeRadius * MILES_TO_KM;
        NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
        
        self.lblSelectedRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:2],strMetric];
        self.sldrLookupRadius.minimumValue = PATROL_MODE_MIN_RADIUS;
        self.sldrLookupRadius.maximumValue = PATROL_MODE_MAX_RADIUS * MILES_TO_KM;
        self.sldrLookupRadius.value = patrolModeRadius;
        
        self.lblRadiusRange.text = NSLocalizedString(@"(1-80 kms)", nil);
        
    }
    else{
        
        ///Set values in miles
        NSString *strMetric = (patrolModeRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
        self.lblSelectedRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(patrolModeRadius) uptoDecimalPlaces:2],strMetric];
        self.sldrLookupRadius.minimumValue = PATROL_MODE_MIN_RADIUS;
        self.sldrLookupRadius.maximumValue = PATROL_MODE_MAX_RADIUS;
        self.sldrLookupRadius.value = patrolModeRadius;
        
        self.lblRadiusRange.text = NSLocalizedString(@"(1-50 miles)", nil);
        
    }

    
}


-(void)updateLocationSelection
{
    if (self.btnSelectedAddressSelector == self.btnPickupAddressSelector) {
        
        ///Show border on pickup address view
        [self showBorderOnView:self.vuPickupAddressBase];
        
        ///hide border on drop address
        [self hideBorderOnView:self.vuDropAddressBase];
        
     }
    else if (self.btnSelectedAddressSelector == self.btnDropAddressSelector){
        
        ///Show border on drop address view
        [self showBorderOnView:self.vuDropAddressBase];
        
        ///hide border on pickup address
        [self hideBorderOnView:self.vuPickupAddressBase];


    }
    else{
        
        ///hide border on pickup address
        [self hideBorderOnView:self.vuPickupAddressBase];
        
        ///hide border on drop address
        [self hideBorderOnView:self.vuDropAddressBase];
        
        
    }
}

-(void)showBorderOnView:(UIView *)view
{
    view.layer.borderWidth = 1.0;
    
}

-(void)hideBorderOnView:(UIView *)view
{
    view.layer.borderWidth = 0;
}

-(void)centerMapToCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    ///Animate map to provided location
    [self.mapView animateToLocation:locCoordinate];

}

-(void)addGoogleMapWithAlertCoordinate:(CLLocationCoordinate2D)alertCoordinate
{
    
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:alertCoordinate.latitude longitude:alertCoordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.delegate = self;
    //self.mapView.mapType = kGMSTypeHybrid;
    [self.mapView animateToLocation:alertCoordinate];
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.view.bounds.size.width;
    self.mapView.frame = mapFrame;
    [self.vuMapPlaceholder addSubview:self.mapView];
    [self.vuMapPlaceholder sendSubviewToBack:self.mapView];
    [self updateMapStyle];
}


-(void)updateLocationonLabel:(UILabel *)lblSelectedAddress usingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    ///cancel previous request
    [self.getLocationTask cancel];
    self.getLocationTask = nil;
    
    ///make a new request
    NSString *strLatLong = [NSString stringWithFormat:@"%f,%f",locCoordinate.latitude,locCoordinate.longitude];
    
//    UILabel *lblSelectedAddress = nil;
//    if (self.btnPickupAddressSelector.isSelected) {
//        
//        lblSelectedAddress = self.lblPickupAddress;
//    }
//    else{
//        
//        lblSelectedAddress = self.lblDropAddress;
//    }

    self.getLocationTask = [ServerUtility getAddressForCoordinate:strLatLong andCompletion:^(NSError *error, id data) {
        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
        
        if (!error && data) {
            
            NSArray *results=[data objectForKey:kGeocodeResultsKey];
            
            if([results count]>0){
                
                NSDictionary *address=[results firstObject];
                ///set the formatted address on the label
                //lblSelectedAddress = formattedaddress;
                
                NSString *strFormattedAddress = [address objectForKey:kFormattedAddressKey];
                lblSelectedAddress.text = strFormattedAddress;
                
            }
            else{
                
                lblSelectedAddress.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        
    }];
}

-(void)sendRideRequestFromLocation:(CLLocationCoordinate2D)pickUpLocation toLocation:(CLLocationCoordinate2D)dropLocation toDriversWithinRadius:(float)driverLookupRadius withAdditionalNote:(NSString *)strAdditionalNote
{
    ///Show the progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    
    ///get the drivers within the lookup radius
    [self getDriversWithinRadius:driverLookupRadius withCompletion:^(NSArray * objects, NSError * error) {
        
        if (!error) {
            
            if (objects.count > 0) {
                
                ///Filter the array by removing members who have spammed current user
                [[AppDelegate sharedInstance]filteredArrayByRemovingMembersInSpammedByRelationFromArray:objects withCompletion:^(id result, NSError *error) {
                    
                    NSArray *arrSpammedByFilteredDrivers = (NSArray *)result;
                    if (arrSpammedByFilteredDrivers.count > 0) {
                        
                        ///Filter the array by removing members who have been spammed by current user
                        [[AppDelegate sharedInstance]filteredArrayByRemovingMembersInSpammedUsersRelationFromArray:arrSpammedByFilteredDrivers withCompletion:^(id result, NSError *error) {
                            
                             NSArray *arrFilteredDrivers = (NSArray *)result;
                            if (arrFilteredDrivers.count > 0) {
                            
                                ///make an entry in RideRequest Table
                                PFObject *rideRequest = [PFObject objectWithClassName:kRideRequestClassNameKey];
                                PFUser *currentUser = [AppDelegate getLoggedInUser];
                                rideRequest[kRideRequestRequestedByKey] = currentUser;
                                rideRequest[kRideRequestPickupLocationKey] = [PFGeoPoint geoPointWithLatitude:pickUpLocation.latitude longitude:pickUpLocation.longitude];
                                NSString *strDropLocLatLong = [NSString stringWithFormat:@"%f,%f",dropLocation.latitude,dropLocation.longitude];
                                rideRequest[kRideRequestDropLocationKey] = strDropLocLatLong;
                                rideRequest[kRideRequestTargetMembersKey] = arrFilteredDrivers;
                                if (strAdditionalNote.length > 0) {
                                    
                                    rideRequest[kRideRequestAdditionalNoteKey] = strAdditionalNote;
                                }
                                rideRequest[kRideRequestStatusKey] = kRideRequestStatusPending;
                                [rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                                    
                                    if (succeeded) {
                                        
                                        ///make payload and send push
                                        NSString *userFirstName = currentUser[kUserFirstnameKey];
                                        NSString *userLastName = currentUser[kUserLastnameKey];
                                        NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:userFirstName andLastName:userLastName];
                                        
                                        NSString *strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"is requesting a ride", nil)];
                                        NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                                        dictData[kPayloadAlertKey] = strAlertMsg;
                                        dictData[kPayloadUserIdKey] = currentUser.objectId;
                                        dictData[kPayloadRideRequestIdKey] = rideRequest.objectId;
                                        dictData[kPayloadPickUpLatKey] = @(pickUpLocation.latitude);
                                        dictData[kPayloadPickUpLongKey] = @(pickUpLocation.longitude);
                                        dictData[kPayloadDropLatKey] = @(dropLocation.latitude);
                                        dictData[kPayloadDropLongKey] = @(dropLocation.longitude);
                                        dictData[kPayloadAdditionalNoteKey] = strAdditionalNote ? strAdditionalNote : @"";
                                        
                                        ///Get ride request time in milliseconds
                                        double rideRequestTimeInMillis = [rideRequest.createdAt timeIntervalSince1970] * 1000;
                                        dictData[kPayloadCreatedAtKey] = @(rideRequestTimeInMillis);
                                        dictData[kPayloadNameKey] = strFullName;
                                        dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeRideRequest;
                                        dictData[kPayloadSoundKey] = @"default";///To play default sound
                                        dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                                        
                                        // Create our Installation query
                                        PFQuery *pushQuery = [PFInstallation query];
                                        [pushQuery whereKey:kInstallationUserKey containedIn:arrFilteredDrivers];
                                        
                                        // Send push notification to query
                                        PFPush *push = [[PFPush alloc] init];
                                        [push setQuery:pushQuery]; // Set our Installation query
                                        [push setData:dictData];
                                        
                                        ///Send Push notification
                                        [push sendPushInBackground];
                                        
                                        ///post notification to show overlay
                                        [[NSNotificationCenter defaultCenter]postNotificationName:kShowRideOverlayNotification object:nil];
                                        
                                        
                                        
                                        ///remove the hud
                                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                        
                                        ///show toast message
                                        NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"Request sent to %d drivers",nil),(int)arrFilteredDrivers.count];
                                        [AppDelegate showToastOnView:weakSelf.view withMessage:strMessage];

                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            
                                            ///remove the view controller after 1 sec
                                            [weakSelf.navigationController popViewControllerAnimated:YES];
                                            
                                        });
                                        
                                        
                                    }
                                    else{
                                        
                                        if (error) {
                                            if(![AppDelegate handleParseError:error]){
                                                ///show error
                                                NSString *errorString = [error userInfo][@"error"];
                                                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                                            }
                                        }
                                        
                                        
                                        ///remove the hud
                                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

                                    }
                                    
                                    
                                }];
                                
                            }
                            else{
                                ///remove the hud
                                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                                
                                ///There is no driver available on the given radius
                                NSString *strMessage = NSLocalizedString(@"Oops! There is no driver available. Try increasing the radius.", nil);
                                [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf];
                            }
                            
                        }];
                        
                       
                        
                        
                    }
                    else{
                        ///remove the hud
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        
                        ///There is no driver available on the given radius
                        NSString *strMessage = NSLocalizedString(@"Oops! There is no driver available. Try increasing the radius.", nil);
                        [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf];
                    }
                    
                }];

            }
            else{
                ///remove the hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                ///There is no driver available on the given radius
                NSString *strMessage = NSLocalizedString(@"Oops! There is no driver available. Try increasing the radius.", nil);
                [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:weakSelf];
                
            }
            
        }
        else{
            ///remove the hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
        }
        
    }];
}

-(void)getDriversWithinRadius:(float)driverLookupRadius withCompletion:(PFArrayResultBlock)completion
{
    ///Fetch the drivers within the given radius
    
    ///Make a query to fetch users
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.pickupMarker.position.latitude longitude:self.pickupMarker.position.longitude];
    PFQuery *fetchNearbyDriversQuery = [PFUser query];
    [fetchNearbyDriversQuery whereKey:kUserRideRequestAlertKey equalTo:@(YES)];
    [fetchNearbyDriversQuery whereKey:kUserLocationKey nearGeoPoint:userGeoPoint withinMiles:(double)driverLookupRadius];
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    [fetchNearbyDriversQuery whereKey:@"objectId" notEqualTo:currentUser.objectId];

    [fetchNearbyDriversQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
        
        if (error){
            
            if(![AppDelegate handleParseError:error]){
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"error fetching nearby drivers--> %@",errorString);
            }
            
        }
        
        ///call completion block
        if (completion != NULL) {
            completion(objects,error);
        }
        
    }];
    
    
}

-(void)updateDistanceMatrixAndCostEstimateForLabel:(UILabel *)lblRideEstimate fromPickupLocation:(CLLocationCoordinate2D)pickupCoordinate toDropLocation:(CLLocationCoordinate2D)dropCoordinate
{
    ///make a new request
    [self.pickUpToDropDistanceMatrixTask cancel];
    self.pickUpToDropDistanceMatrixTask = nil;
    

    NSString *strOriginLatLong = [NSString stringWithFormat:@"%f,%f",pickupCoordinate.latitude,pickupCoordinate.longitude];
    NSString *strDestLatLong = [NSString stringWithFormat:@"%f,%f",dropCoordinate.latitude,dropCoordinate.longitude];
    lblRideEstimate.text = NSLocalizedString(@"Retrieving Info...", nil);
    
    self.pickUpToDropDistanceMatrixTask = [ServerUtility getDistanceAndDurationMatrixFromLocation:strOriginLatLong toLocation:strDestLatLong andCompletion:^(NSError *error, id data) {
        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
        
        if (!error && data) {
            
            NSDictionary *dictDistanceMatrix = [C411StaticHelper getDistanceAndDurationFromDistanceMatrixResponse:data];
            NSNumber *numDistanceValueInMeters = [dictDistanceMatrix objectForKey:kDistanceMatrixDistanceKey];
            NSNumber *numDuration = [dictDistanceMatrix objectForKey:kDistanceMatrixDurationKey];
            if(numDistanceValueInMeters && numDuration){
              
                NSString *strDistMatrix = nil;
                float distanceInKms = [numDistanceValueInMeters integerValue] / 1000.0;
                float distanceInMiles = distanceInKms/MILES_TO_KM;
                
                ///Set data according to the selected metric system
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                ///Get metric chosen by user
                NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
                if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
                    
                    ///set values in kms
                    NSString *strMetricSuffix = (distanceInKms <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
                    strDistMatrix = [NSString stringWithFormat:@"%0.1f %@",distanceInKms,strMetricSuffix];

                }
                else{
                    
                    ///Set values in miles
                    NSString *strMetricSuffix = (distanceInMiles <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
                    strDistMatrix = [NSString stringWithFormat:@"%0.1f %@",distanceInMiles,strMetricSuffix];

                    
                }

//                NSString *strMetricSuffix = NSLocalizedString(@"Km", nil);
//                if (distanceInKms > 1) {
//                    
//                    strMetricSuffix = NSLocalizedString(@"Kms", nil);
//                }
                
                int seconds = [numDuration intValue];
                int hours = (int)seconds / (60 * 60);
                int remainingSec = seconds % (60 * 60);
                int mins = remainingSec / 60;
                
                NSString *strHourSuffix = hours > 1 ? NSLocalizedString(@"hrs", nil):NSLocalizedString(@"hr", nil);
                NSString *strMinSuffix = mins > 1 ? NSLocalizedString(@"mins", nil):NSLocalizedString(@"min", nil);
                
                NSString *strDuration = nil;
                if (hours > 0 && mins > 0) {
                    
                    ///show hours and mins
                    strDuration = [NSString localizedStringWithFormat:@"%d %@ %d %@",hours,strHourSuffix,mins,strMinSuffix];
                    
                }
                else if (hours > 0){
                    
                    ///show hours
                    strDuration = [NSString localizedStringWithFormat:@"%d %@",hours,strHourSuffix];
                    
                }
                else{
                    
                    ///show mins
                    strDuration = [NSString localizedStringWithFormat:@"%d %@",mins,strMinSuffix];
                    
                }
                
                
                ///Get the suggested cost using default values
                int totalMinutes = seconds / 60;
                
                float suggestedCost = [C411StaticHelper calculateRideCostForDistance:distanceInMiles duration:totalMinutes usingPickupCost:DEFAULT_PICKUP_COST costPerMin:DEFAULT_PER_MIN_COST andCostPerMile:DEFAULT_PER_MILE_COST];
                
                NSString *strSuggestedCost = [NSString stringWithFormat:@"$%@",[C411StaticHelper getDecimalStringFromNumber:@(suggestedCost) uptoDecimalPlaces:2]];
                
                ///Make the estimate string and set it on label
                NSString *strRideEstimates = [NSString localizedStringWithFormat:NSLocalizedString(@"Distance is %@ and can be covered in around %@ with an estimated cost of %@",nil),strDistMatrix,strDuration,strSuggestedCost];
                lblRideEstimate.text = strRideEstimates;
                
                
            }
            else{
                
                lblRideEstimate.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        else{
            lblRideEstimate.text = NSLocalizedString(@"N/A", nil);
            
        }
        
    }];
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnSelectPickupAddressTapped:(UIButton *)sender {
    
//    sender.selected = YES;
//    if (self.btnDropAddressSelector.isSelected) {
//        
//        self.btnDropAddressSelector.selected = NO;
//    }
    self.btnSelectedAddressSelector = sender;
    [self updateLocationSelection];
    
    if (self.pickupMarker) {
        
        ///center map to the pickup marker
        [self centerMapToCoordinate:self.pickupMarker.position];
        
    }

}

- (IBAction)btnSearchPickupAddressTapped:(UIButton *)sender {
    
    ///Select the pickup address if it's not selected
    if (self.btnSelectedAddressSelector != self.btnPickupAddressSelector) {
        
//        self.btnPickupAddressSelector.selected = YES;
//        self.btnDropAddressSelector.selected = NO;
        self.btnSelectedAddressSelector = self.btnPickupAddressSelector;
        [self updateLocationSelection];

    }
    
    ///Show GMSAutocompleteViewController for location search
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
    
}

- (IBAction)btnSelectDropAddressTapped:(UIButton *)sender {
    
//    sender.selected = YES;
//    if (self.btnPickupAddressSelector.isSelected) {
//        
//        self.btnPickupAddressSelector.selected = NO;
//    }
    
    self.btnSelectedAddressSelector = sender;
    [self updateLocationSelection];

    if (self.dropAtMarker) {
        
        ///center map to the drop at marker
        [self centerMapToCoordinate:self.dropAtMarker.position];
        
    }

}

- (IBAction)btnSearchDropAddressTapped:(UIButton *)sender {
    
    ///Select the drop address if it's not selected
    if (self.btnSelectedAddressSelector != self.btnDropAddressSelector) {
        
//        self.btnDropAddressSelector.selected = YES;
//        self.btnPickupAddressSelector.selected = NO;
        self.btnSelectedAddressSelector = self.btnDropAddressSelector;
        [self updateLocationSelection];
        
    }
    
    ///Show GMSAutocompleteViewController for location search
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
 
}

- (IBAction)btnFABCenterCurentLocationTapped:(UIButton *)sender {
    
    [self centerMapToCoordinate:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];
}

- (IBAction)btnAdjustZoomToShowAllPinsTapped:(UIButton *)sender {
    
    self.btnSelectedAddressSelector = nil;
    [self updateLocationSelection];
    
    NSArray *arrMarkers = @[self.pickupMarker,
                            self.dropAtMarker];
    [C411StaticHelper focusMap:self.mapView toShowAllMarkers:arrMarkers];
    
}

- (IBAction)btnRequestRideTapped:(UIButton *)sender {
    
    if (self.dropAtMarker) {
        
        ///show a popup asking for additional note and lookup radius selection
        UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
        self.vuAddNoteAndRadiusSelectionPopupBase.frame = rootVC.view.bounds;
        [rootVC.view addSubview:self.vuAddNoteAndRadiusSelectionPopupBase];
        [rootVC.view bringSubviewToFront:self.vuAddNoteAndRadiusSelectionPopupBase];

    }
    else{
        
        ///show toast to enter drop location
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Please enter drop location", nil)];
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

- (IBAction)sldrLookupRadiusChanged:(UISlider *)sender {
    
    float driverLookupRadius = (int)sender.value;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ///Get metric chosen by user
    NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
    
    if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
        
        ///set values in kms
        ///Patrol mode radius we get is in km
        NSString *strMetric = (driverLookupRadius <= 1) ? NSLocalizedString(@"km", nil) : NSLocalizedString(@"kms", nil);
        self.lblSelectedRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(driverLookupRadius) uptoDecimalPlaces:2],strMetric];
        
    }
    else{
        
        ///Set values in miles
        ///Patrol mode radius we get is in miles
        NSString *strMetric = (driverLookupRadius <= 1) ? NSLocalizedString(@"mile", nil) : NSLocalizedString(@"miles", nil);
        self.lblSelectedRadius.text = [NSString localizedStringWithFormat:@"%@ %@",[C411StaticHelper getDecimalStringFromNumber:@(driverLookupRadius) uptoDecimalPlaces:2],strMetric];
    }

}

- (IBAction)btnCancelTapped:(UIButton *)sender {
    
    ///Remove the popup
    [self.vuAddNoteAndRadiusSelectionPopupBase removeFromSuperview];
    
}

- (IBAction)btnContinueTapped:(UIButton *)sender {
    
    ///Show the alert and on yes open the Google Directions app
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attention", nil) message:NSLocalizedString(@"Issuing unnecessary ride requests can lead to being blocked for abuse or your account being suspended. Do you want to continue?", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///User tapped cancel
        ///remove the popup from screen
        [self.vuAddNoteAndRadiusSelectionPopupBase removeFromSuperview];

        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///User wants to continue sending ride request
        ///remove the popup from screen
        [self.vuAddNoteAndRadiusSelectionPopupBase removeFromSuperview];

        ///get the selected driver lookup radius in miles
        float driverLookupRadius = (int)self.sldrLookupRadius.value;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        ///Get metric chosen by user
        NSString *strMetricSystem = [defaults objectForKey:kMetricSystem];
        
        if ([strMetricSystem isEqualToString:kMetricSystemKms]) {
            
            ///Convert to miles from km
            driverLookupRadius = driverLookupRadius / MILES_TO_KM;
            
        }
        
        
        ///Send the ride request
        [self sendRideRequestFromLocation:self.pickupMarker.position toLocation:self.dropAtMarker.position toDriversWithinRadius:driverLookupRadius withAdditionalNote:self.txtAdditionalNote.text];

        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:continueAction];
    
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

    
    
}


//****************************************************
#pragma mark - GMSMapViewDelegate Methods
//****************************************************

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)position
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    if (self.btnSelectedAddressSelector) {
        
        CLLocationCoordinate2D locCoord = mapView.camera.target;
        if (self.btnSelectedAddressSelector == self.btnPickupAddressSelector) {
            
            [self updateLocationonLabel:self.lblPickupAddress usingCoordinate:locCoord];
            
            self.pickupMarker.position = locCoord;
            
            
        }
        else if (self.btnSelectedAddressSelector == self.btnDropAddressSelector){
            
            [self updateLocationonLabel:self.lblDropAddress usingCoordinate:locCoord];
            
            if (!self.dropAtMarker) {
                ///Create drop location marker and add it to map
                self.dropAtMarker=[[GMSMarker alloc]init];
                self.dropAtMarker.map = self.mapView;
                self.dropAtMarker.icon = [UIImage imageNamed:@"ic_pin_drop_at"];
                
                self.btnAdjustZoomToShowAllPins.hidden = NO;
                
                ///unhide the disctance and cost estimate view
                self.cnsDistanceAndCostEstimateViewHeight.constant = 40;
            }
            
            self.dropAtMarker.position = locCoord;

        }
        
        if (self.dropAtMarker) {
            
            ///Update the estimate lable
            [self updateDistanceMatrixAndCostEstimateForLabel:self.lblDistanceAndCostEstimate fromPickupLocation:self.pickupMarker.position toDropLocation:self.dropAtMarker.position];
        }

    }

}

//****************************************************
#pragma mark -GMSAutocompleteViewControllerDelegate Methods
//****************************************************

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CLLocationCoordinate2D locCoord = place.coordinate;
        if (self.btnSelectedAddressSelector == self.btnPickupAddressSelector) {
            
            self.lblPickupAddress.text = place.formattedAddress;
            self.pickupMarker.position = locCoord;
            
            if (self.dropAtMarker) {
                
                ///Update the estimate lable
                [self updateDistanceMatrixAndCostEstimateForLabel:self.lblDistanceAndCostEstimate fromPickupLocation:self.pickupMarker.position toDropLocation:self.dropAtMarker.position];
            }

            
        }
        else if (self.btnSelectedAddressSelector == self.btnDropAddressSelector){
            
            self.lblDropAddress.text = place.formattedAddress;
            if (!self.dropAtMarker) {
                ///Create drop location marker and add it to map
                self.dropAtMarker=[[GMSMarker alloc]init];
                self.dropAtMarker.map = self.mapView;
                self.dropAtMarker.icon = [UIImage imageNamed:@"ic_pin_drop_at"];
                
                self.btnAdjustZoomToShowAllPins.hidden = NO;
                
                ///unhide the disctance and cost estimate view
                self.cnsDistanceAndCostEstimateViewHeight.constant = 40;
                

            }
            
            self.dropAtMarker.position = locCoord;
            
            ///Update the estimate lable
            [self updateDistanceMatrixAndCostEstimateForLabel:self.lblDistanceAndCostEstimate fromPickupLocation:self.pickupMarker.position toDropLocation:self.dropAtMarker.position];
            
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self centerMapToCoordinate:locCoord];
        });
     
    });
    


}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
