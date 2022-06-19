//
//  C411RideSelectedPopup.m
//  cell411
//
//  Created by Milan Agarwal on 17/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideSelectedPopup.h"
#import "ServerUtility.h"
#import <GoogleMaps/GoogleMaps.h>
#import "C411StaticHelper.h"
#import "C411LocationManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import <OpenInGoogleMaps/OpenInGoogleMapsController.h>
#import "MAAlertPresenter.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ViewPhotoVC.h"
#import "C411RideReviewsVC.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411RideSelectedPopup ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertHead;
@property (weak, nonatomic) IBOutlet UILabel *lblResponseTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuRider;
@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *vuSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRideStatusHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNote;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteValue;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDropAddress;
@property (weak, nonatomic) IBOutlet UIView *vuPickupDistanceMatrix;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupDistanceMatrix;
@property (weak, nonatomic) IBOutlet UIView *vuPickupToDropDistanceMatrix;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupToDropDistanceMatrix;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocationHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupLocationHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupLocationHeading2;
@property (weak, nonatomic) IBOutlet UILabel *lblDropLocationHeading;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigateToPickupAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigateToDropAddress;
@property (weak, nonatomic) IBOutlet UIView *vuAvgRatingBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuStar;
@property (weak, nonatomic) IBOutlet UILabel *lblAvgRating;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPickUpAddressTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAlertBaseViewTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAlertBaseViewBS;
- (IBAction)btnCloseTapped:(UIButton *)sender;
- (IBAction)btnCallTapped:(UIButton *)sender;
- (IBAction)btnNavigateToPickupAddressTapped:(UIButton *)sender;
- (IBAction)btnNavigateToDropAddressTapped:(UIButton *)sender;
- (IBAction)btnShowRatingTapped:(UIButton *)sender;

@property (nonatomic, assign, getter=isInitialized) BOOL initialized;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *dropLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpDistanceMatrixTask;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpToDropDistanceMatrixTask;
@property (nonatomic, strong) PFUser *rider;
@property (nonatomic, assign) CLLocationCoordinate2D pickUpCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D dropCoordinate;

@end

@implementation C411RideSelectedPopup

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self configureViews];
    [self registerForNotifications];
    [C411StaticHelper removeOnScreenKeyboard];

}

-(void)dealloc
{
    [self.pickUpLocationTask cancel];
    self.pickUpLocationTask = nil;
    [self.dropLocationTask cancel];
    self.dropLocationTask = nil;
    [self.pickUpDistanceMatrixTask cancel];
    self.pickUpDistanceMatrixTask = nil;
    [self.pickUpToDropDistanceMatrixTask cancel];
    self.pickUpToDropDistanceMatrixTask = nil;
    
    [self unregisterFromNotifications];
    
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    _alertPayload = alertPayload;
    
    if (!self.isInitialized) {
        
        [self initializeViewWithAlertPayload:alertPayload];
        self.initialized = YES;
        
    }
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)addTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgVuAvatarTapped:)];
    [self.imgVuRider addGestureRecognizer:tapRecognizer];
}

-(void)configureViews
{
    ///Update constraints
    [self updateLayoutConstraints];

    ///Set corner radius
    self.vuAlertBase.layer.cornerRadius = 5.0;
    self.vuAlertBase.layer.masksToBounds = YES;
    self.btnCall.layer.cornerRadius = 2.0;
    self.btnCall.layer.masksToBounds = YES;
    self.btnClose.layer.cornerRadius = 2.0;
    self.btnClose.layer.masksToBounds = YES;
    self.vuPickupDistanceMatrix.layer.cornerRadius = 3.0;
    self.vuPickupDistanceMatrix.layer.masksToBounds = YES;
    self.vuPickupToDropDistanceMatrix.layer.cornerRadius = 3.0;
    self.vuPickupToDropDistanceMatrix.layer.masksToBounds = YES;
    
    
    ///make circular views
    [C411StaticHelper makeCircularView:self.imgVuRider];
    [C411StaticHelper makeCircularView:self.btnNavigateToPickupAddress];
    [C411StaticHelper makeCircularView:self.btnNavigateToDropAddress];
    [C411StaticHelper makeCircularView:self.vuAvgRatingBase];

    ///set initial strings for localization
    self.lblRideStatusHeading.text = [NSString localizedStringWithFormat:@"%@:",NSLocalizedString(@"Ride Status", nil)];
    self.lblCurrentStatus.text = NSLocalizedString(@"LOADING...", nil);
    self.lblAdditionalNote.text = [NSString localizedStringWithFormat:@"%@:",NSLocalizedString(@"ADDITIONAL NOTE", nil)];
    self.lblAdditionalNoteValue.text = NSLocalizedString(@"LOADING...", nil);
    self.lblPickUpAddress.text = NSLocalizedString(@"Retreiving", nil);
    self.lblDropAddress.text = NSLocalizedString(@"Retreiving", nil);
    self.lblPickupDistanceMatrix.text = NSLocalizedString(@"LOADING...", nil);
    self.lblPickupToDropDistanceMatrix.text = NSLocalizedString(@"LOADING...", nil);
    self.lblCurrentLocationHeading.text = NSLocalizedString(@"CURRENT LOCATION", nil);
    self.lblPickupLocationHeading.text = NSLocalizedString(@"PICK UP LOCATION", nil);
    self.lblPickupLocationHeading2.text = NSLocalizedString(@"PICK UP LOCATION", nil);
    self.lblDropLocationHeading.text = NSLocalizedString(@"DROP LOCATION", nil);
    [self.btnCall setTitle:NSLocalizedString(@"Call", nil) forState:UIControlStateNormal];
    [self.btnClose setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];

    [self applyColors];
}

-(void)updateMapStyle {
    self.mapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
}

-(void)applyColors {
    ///Update map style
    [self updateMapStyle];
    ///Set background color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuAlertBase.backgroundColor = lightCardColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTitle.textColor = primaryTextColor;
    self.lblRideStatusHeading.textColor = primaryTextColor;
    self.lblAdditionalNote.textColor = primaryTextColor;
    self.lblCurrentLocationHeading.textColor = primaryTextColor;
    self.lblPickupLocationHeading.textColor = primaryTextColor;
    self.lblPickupLocationHeading2.textColor = primaryTextColor;
    self.lblDropLocationHeading.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblResponseTime.textColor = secondaryTextColor;
    self.lblPickUpAddress.textColor = secondaryTextColor;
    self.lblDropAddress.textColor = secondaryTextColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuSeparator.backgroundColor = themeColor;
    self.vuAvgRatingBase.backgroundColor = themeColor;
    self.btnClose.backgroundColor = themeColor;
    self.btnCall.backgroundColor = themeColor;
    
    ///Set primaryBGTextColor
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblAvgRating.textColor = primaryBGTextColor;
    self.imgVuStar.tintColor = primaryBGTextColor;
    [self.btnClose setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnCall setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
}

-(void)registerForNotifications
{
    [super registerForNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)updateLayoutConstraints
{
    if (@available(iOS 11, *)) {
        ///Deactivate top and bottom constraint added via storyboard
        [NSLayoutConstraint deactivateConstraints:@[
                                                    self.cnsAlertBaseViewTS,
                                                    self.cnsAlertBaseViewBS
                                                    ]];
        
        ///Activate constraint using safeAreaLayoutGuide
        UILayoutGuide *guide = self.safeAreaLayoutGuide;
        NSLayoutConstraint *topConstraint = [self.vuAlertBase.topAnchor constraintEqualToAnchor:guide.topAnchor constant:42.0f];
        NSLayoutConstraint *bottomConstraint = [guide.bottomAnchor constraintEqualToAnchor:self.vuAlertBase.bottomAnchor constant:20.0f];
        
        [NSLayoutConstraint activateConstraints:@[
                                                  topConstraint,
                                                  bottomConstraint
                                                  ]];
    }
}

-(void)initializeViewWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    ///Load mapview zoomed to pickup and drop location
    ///Add mapview
    [self addGoogleMapWithAlertCoordinate:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];
    ///add markers
    self.pickUpCoordinate = CLLocationCoordinate2DMake(alertPayload.pickUpLat, alertPayload.pickUpLon);
    GMSMarker *pickupMarker = [C411StaticHelper addMarkerOnMap:self.mapView atPosition:self.pickUpCoordinate withImage:[UIImage imageNamed:@"ic_pin_pick_up_from"] andTitle:nil];
    self.dropCoordinate = CLLocationCoordinate2DMake(alertPayload.dropLat, alertPayload.dropLon);
    GMSMarker *dropMarker = [C411StaticHelper addMarkerOnMap:self.mapView atPosition:self.dropCoordinate withImage:[UIImage imageNamed:@"ic_pin_drop_at"] andTitle:nil];
    NSArray *arrMarkers = @[pickupMarker,
                            dropMarker];
    ///zoom map to show markers
    [C411StaticHelper focusMap:self.mapView toShowAllMarkers:arrMarkers];
    
    
    ///Show the timestamp
    NSDate *rideResponseDate = [NSDate dateWithTimeIntervalSince1970:(alertPayload.createdAtInMillis / 1000)];
    self.lblResponseTime.text = [C411StaticHelper getFormattedTimeFromDate:rideResponseDate withFormat:TimeStampFormatDateOrTime];
    
    ///show the title
    CGFloat fontSize = self.lblAlertTitle.font.pointSize;
    NSString *strTitleMidText = NSLocalizedString(@"approved your", nil);
    NSString *strTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ %@ ride",nil),alertPayload.strFullName,strTitleMidText];
    NSRange unboldTextRange = NSMakeRange(alertPayload.strFullName.length + 1, strTitleMidText.length);
    self.lblAlertTitle.attributedText = [C411StaticHelper getSemiboldAttributedStringWithString:strTitle ofSize:fontSize withUnboldTextInRange:unboldTextRange];

    ///Show the user image
    __weak typeof(self) weakSelf = self;
    ///get the user object from parse and save it locally as well
     PFQuery *getUserQuery = [PFUser query];
    [getUserQuery getObjectInBackgroundWithId:alertPayload.strUserId block:^(PFObject *object,  NSError *error){
        if (!error && object) {
            ///User found, get the avatar for this user
            PFUser *parseUser = (PFUser *)object;
            weakSelf.rider = parseUser;
            if([C411StaticHelper isUserDeleted:parseUser]){
                ///Set Deleted attribute for name of rider
                NSDictionary *dictDeletedUserAttr = @{
                                                      NSFontAttributeName:[UIFont systemFontOfSize: fontSize],
                                                      NSForegroundColorAttributeName: [C411ColorHelper sharedInstance].deletedUserTextColor
                                                      };
                ///1. make name range
                NSRange riderNameRange = NSMakeRange(0, alertPayload.strFullName.length);
                ///2. set deleted user attribute
                NSMutableAttributedString *attrTitle = weakSelf.lblAlertTitle.attributedText.mutableCopy;
                [attrTitle setAttributes:dictDeletedUserAttr range:riderNameRange];
                weakSelf.lblAlertTitle.attributedText = attrTitle;
            }
            else {
                ///Set profile pic
                [weakSelf.imgVuRider setAvatarForUser:parseUser shouldFallbackToGravatar:YES ofSize:weakSelf.imgVuRider.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
                ///Add Tap Gesture on image
                [weakSelf addTapGesture];
            }
        }
        else {
            ///log error
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"#error: %@",errorString);
        }
    }];

    
    ///Show the additional Note
    if (alertPayload.strAdditionalNote.length > 0) {
        
        self.lblAdditionalNoteValue.text = alertPayload.strAdditionalNote;
        
    }
    else{
        
        ///hide the additional note label as well
        self.lblAdditionalNote.text = nil;
        self.lblAdditionalNoteValue.text = nil;
        self.cnsPickUpAddressTS.constant = 0;
        
    }
    
    ///Set the current status for ride
    self.lblCurrentStatus.text = NSLocalizedString(@"Selected", nil);
    
    ///Get the address for pickup and drop locations
    self.pickUpLocationTask = [C411StaticHelper updateLocationonLabel:self.lblPickUpAddress usingCoordinate:self.pickUpCoordinate];
    self.dropLocationTask = [C411StaticHelper updateLocationonLabel:self.lblDropAddress usingCoordinate:self.dropCoordinate];
    
    ///Get the distance matrix for pickup and drop locations
    self.pickUpDistanceMatrixTask = [C411StaticHelper updateDistanceMatrixOnLabel:self.lblPickupDistanceMatrix usingOriginCoordinate:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate destinationCoordinate:self.pickUpCoordinate withCompletion:NULL];
    self.pickUpToDropDistanceMatrixTask = [C411StaticHelper updateDistanceMatrixOnLabel:self.lblPickupToDropDistanceMatrix usingOriginCoordinate:self.pickUpCoordinate destinationCoordinate:self.dropCoordinate withCompletion:NULL];
    
    ///Show avg rating of rider
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kAverageStarsFuncParamUserIdKey] = alertPayload.strUserId;
    [C411StaticHelper setAverageRatingForUserWithDetails:dictParams onLabel:self.lblAvgRating];

    
    [self showGetDirectionsToPickup];
}

-(void)showGetDirectionsToPickup
{
    ///Show the alert and on yes open the Google Directions app
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Do you want directions to the pickup location?", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        ///User tapped no
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ///User wants the direction, show the phone verification screen
        [self btnNavigateToDropAddressTapped:self.btnNavigateToPickupAddress];
        
        ///Dequeue the current Alert Controller and allow other to be visible
        [[MAAlertPresenter sharedPresenter]dequeueAlert];
        
    }];
    
    [alertController addAction:noAction];
    [alertController addAction:yesAction];
    
    ///Enqueue the alert controller object in the presenter queue to be displayed one by one
    [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

}

-(void)addGoogleMapWithAlertCoordinate:(CLLocationCoordinate2D)alertCoordinate
{
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:alertCoordinate.latitude longitude:alertCoordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //self.mapView.mapType = kGMSTypeHybrid;
    
    float hPadding = 20;
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.bounds.size.width - 2 * hPadding;
    self.mapView.frame = mapFrame;
    [self.vuMapPlaceholder addSubview:self.mapView];
    [self.vuMapPlaceholder sendSubviewToBack:self.mapView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ///update map frame to get the correct frame values
        [self updateMapFrame];
    });
    
    
}


-(void)updateMapFrame
{
    float hPadding = 20;
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.bounds.size.width - 2 * hPadding;
    self.mapView.frame = mapFrame;
    self.vuAlertBase.layer.masksToBounds = YES;
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnCallTapped:(UIButton *)sender {
    
    ///Call the rider
    if (self.rider) {
        
        [C411StaticHelper callUser:self.rider];
    }
    else{
        
        ///Get the rider and then call him
       ///show progress hud
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        __weak typeof(self) weakSelf = self;
        ///get the user object from parse and save it locally as well
        PFQuery *getUserQuery = [PFUser query];
        [getUserQuery getObjectInBackgroundWithId:self.alertPayload.strUserId block:^(PFObject *object,  NSError *error){
            
            ///Hide the progress hud
            [MBProgressHUD hideHUDForView:weakSelf animated:YES];
            
            if (!error && object) {
                
                ///User found, get the avatar for this user
                weakSelf.rider = (PFUser *)object;
                
                ///Call the user
                [C411StaticHelper callUser:weakSelf.rider];
                
                ///Try to get the avatar again
//                [C411StaticHelper getAvatarForUser:weakSelf.rider shouldFallbackToGravatar:YES ofSize:weakSelf.imgVuRider.bounds.size.width roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//                    
//                    if (success && image) {
//                        
//                        ///Got the image, set it to the imageview
//                        weakSelf.imgVuRider.image = image;
//                    }
//                    
//                }];
                
                [weakSelf.imgVuRider setAvatarForUser:weakSelf.rider shouldFallbackToGravatar:YES ofSize:weakSelf.imgVuRider.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
            }
            else {
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                
            }
        }];

    }
    
}

- (IBAction)btnCloseTapped:(UIButton *)sender {
    
    if (self.actionHandler != NULL) {
        ///call the Close action handler
        self.actionHandler(sender,0,nil);
        
    }
    
    ///remove the view from superview
    [self removeFromSuperview];
    self.actionHandler = NULL;
    
    
}

- (IBAction)btnNavigateToPickupAddressTapped:(UIButton *)sender {
    
    ///Navigate to the pickup location of the rider
    GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
    definition.destinationPoint = [GoogleDirectionsWaypoint
                                   waypointWithLocation:self.pickUpCoordinate];
    definition.travelMode = kGoogleMapsTravelModeDriving;
    BOOL isOpened = [[OpenInGoogleMapsController sharedInstance] openDirections:definition];
    
    if(!isOpened){
        
        ///Get the cross-platform maps url to open
        NSString *strLatLong = [NSString stringWithFormat:@"%lf,%lf",self.pickUpCoordinate.latitude,self.pickUpCoordinate.longitude];
        NSDictionary *dictParams = @{kGoogleMapsDestinationKey : strLatLong,
                                     kGoogleMapsTravelModeKey : kGoogleMapsTravelModeValueDriving};
        NSURL *directionsUrl = [C411StaticHelper getGoogleMapsDirectionsUrlForAllPlatforms:dictParams];
        
        if([[UIApplication sharedApplication]canOpenURL:directionsUrl]){
            
            [[UIApplication sharedApplication]openURL:directionsUrl];
            
        }
        
    }
    
    
    
}

- (IBAction)btnNavigateToDropAddressTapped:(UIButton *)sender {
    
    
    ///Navigate to the drop location of the rider
    ///Navigate to the pickup location of the rider
    GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
    definition.startingPoint = [GoogleDirectionsWaypoint
                                waypointWithLocation:self.pickUpCoordinate];
    definition.destinationPoint = [GoogleDirectionsWaypoint
                                   waypointWithLocation:self.dropCoordinate];
    definition.travelMode = kGoogleMapsTravelModeDriving;
    BOOL isOpened = [[OpenInGoogleMapsController sharedInstance] openDirections:definition];
    
    if(!isOpened){
        
        ///Get the cross-platform maps url to open
        NSString *strOriginLatLong = [NSString stringWithFormat:@"%lf,%lf",self.pickUpCoordinate.latitude,self.pickUpCoordinate.longitude];
        NSString *strDestLatLong = [NSString stringWithFormat:@"%lf,%lf",self.dropCoordinate.latitude,self.dropCoordinate.longitude];
        NSDictionary *dictParams = @{kGoogleMapsOriginKey : strOriginLatLong,
                                     kGoogleMapsDestinationKey : strDestLatLong,
                                     kGoogleMapsTravelModeKey : kGoogleMapsTravelModeValueDriving};
        NSURL *directionsUrl = [C411StaticHelper getGoogleMapsDirectionsUrlForAllPlatforms:dictParams];
        
        if([[UIApplication sharedApplication]canOpenURL:directionsUrl]){
            
            [[UIApplication sharedApplication]openURL:directionsUrl];
            
        }
        
    }
    
    
    
}

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    ///Show photo VC to view photo alert
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
    viewPhotoVC.imgPhoto = self.imgVuRider.image;
    [navRoot pushViewController:viewPhotoVC animated:YES];
}

- (IBAction)btnShowRatingTapped:(UIButton *)sender {
    
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411RideReviewsVC *rideReviewsVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411RideReviewsVC"];
    rideReviewsVC.rideConfirmed = YES;
    if (self.rider) {
        
        rideReviewsVC.targetUser = self.rider;
    }
    else{
        
        rideReviewsVC.targetUserId = self.alertPayload.strUserId;
    }
    [navRoot pushViewController:rideReviewsVC animated:YES];
    
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
