//
//  C411RideRequestPopup.m
//  cell411
//
//  Created by Milan Agarwal on 04/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideRequestPopup.h"
#import "ServerUtility.h"
#import <GoogleMaps/GoogleMaps.h>
#import "C411StaticHelper.h"
#import "C411LocationManager.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MAAlertPresenter.h"
#import "C411RideSettingsVC.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ViewPhotoVC.h"
#import "C411RideReviewsVC.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411RideRequestPopup ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAlertHead;
@property (weak, nonatomic) IBOutlet UILabel *lblRequestTime;
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
@property (weak, nonatomic) IBOutlet UIButton *btnNotInterested;
@property (weak, nonatomic) IBOutlet UIButton *btnInterested;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNotePopupBase;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNotePopup;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNotePopupHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtAdditionalNote;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNoteSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblRideCost;
@property (weak, nonatomic) IBOutlet UITextField *txtCost;
@property (weak, nonatomic) IBOutlet UIView *vuCostSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIView *vuAvgRatingBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuStar;
@property (weak, nonatomic) IBOutlet UILabel *lblAvgRating;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsPickUpAddressTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAdditonalNotePopupCenterY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAlertBaseViewTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAlertBaseViewBS;

- (IBAction)btnNotInterestedTapped:(UIButton *)sender;
- (IBAction)btnInterestedTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;
- (IBAction)btnSendTapped:(UIButton *)sender;
- (IBAction)btnShowRatingTapped:(UIButton *)sender;


@property (nonatomic, assign, getter=isInitialized) BOOL initialized;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *dropLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpDistanceMatrixTask;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpToDropDistanceMatrixTask;

@property (nonatomic, assign, getter=shouldSaveInRejectedByOnClose) BOOL saveInRejectedByOnClose;
@property (nonatomic, strong) PFUser *rider;

@end

@implementation C411RideRequestPopup

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

-(void)registerForNotifications
{
    [super registerForNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboarWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboarWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

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
    self.vuAdditionalNotePopup.layer.cornerRadius = 5.0;
    self.vuAdditionalNotePopup.layer.masksToBounds = YES;
    self.btnInterested.layer.cornerRadius = 2.0;
    self.btnInterested.layer.masksToBounds = YES;
    self.btnNotInterested.layer.cornerRadius = 2.0;
    self.btnNotInterested.layer.masksToBounds = YES;
    self.btnClose.layer.cornerRadius = 2.0;
    self.btnClose.layer.masksToBounds = YES;
    self.vuPickupDistanceMatrix.layer.cornerRadius = 3.0;
    self.vuPickupDistanceMatrix.layer.masksToBounds = YES;
    self.vuPickupToDropDistanceMatrix.layer.cornerRadius = 3.0;
    self.vuPickupToDropDistanceMatrix.layer.masksToBounds = YES;
    
    
    ///make circular views
    [C411StaticHelper makeCircularView:self.imgVuRider];
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
    [self.btnInterested setTitle:NSLocalizedString(@"Interested", nil) forState:UIControlStateNormal];
    [self.btnNotInterested setTitle:NSLocalizedString(@"Not Interested", nil) forState:UIControlStateNormal];
    [self.btnClose setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    [self.btnSend setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    self.lblAdditionalNotePopupHeading.text = NSLocalizedString(@"Additional Note", nil);
    self.txtAdditionalNote.placeholder = NSLocalizedString(@"Additional text message if any", nil);
    self.lblRideCost.text = [NSString localizedStringWithFormat:@"%@:",NSLocalizedString(@"Ride Cost", nil)];
    self.txtCost.placeholder = NSLocalizedString(@"Cost", nil);
    
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
    self.vuAdditionalNotePopup.backgroundColor = lightCardColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTitle.textColor = primaryTextColor;
    self.lblRideStatusHeading.textColor = primaryTextColor;
    self.lblAdditionalNote.textColor = primaryTextColor;
    self.lblCurrentLocationHeading.textColor = primaryTextColor;
    self.lblPickupLocationHeading.textColor = primaryTextColor;
    self.lblPickupLocationHeading2.textColor = primaryTextColor;
    self.lblDropLocationHeading.textColor = primaryTextColor;
    self.lblAdditionalNotePopupHeading.textColor = primaryTextColor;
    self.lblRideCost.textColor = primaryTextColor;
    self.txtAdditionalNote.textColor = primaryTextColor;
    self.txtCost.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblRequestTime.textColor = secondaryTextColor;
    self.lblPickUpAddress.textColor = secondaryTextColor;
    self.lblDropAddress.textColor = secondaryTextColor;
    self.lblAdditionalNoteTitle.textColor = secondaryTextColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuSeparator.backgroundColor = themeColor;
    self.vuAvgRatingBase.backgroundColor = themeColor;
    self.btnClose.backgroundColor = themeColor;
    self.btnInterested.backgroundColor = themeColor;
    self.btnNotInterested.backgroundColor = themeColor;

    ///Set primaryBGTextColor
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblAvgRating.textColor = primaryBGTextColor;
    self.imgVuStar.tintColor = primaryBGTextColor;
    [self.btnClose setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnInterested setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnNotInterested setTitleColor:primaryBGTextColor forState:UIControlStateNormal];

    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuAdditionalNoteSeparator.backgroundColor = separatorColor;
    self.vuCostSeparator.backgroundColor = separatorColor;
    
    ///set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnSend setTitleColor:secondaryColor forState:UIControlStateNormal];
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
    ///hide the buttons initially
    self.btnInterested.hidden = YES;
    self.btnNotInterested.hidden = YES;
    
    ///Load mapview zoomed to pickup and drop location
    ///Add mapview
    [self addGoogleMapWithAlertCoordinate:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];
    ///add markers
    CLLocationCoordinate2D pickUpCoordinate = CLLocationCoordinate2DMake(alertPayload.pickUpLat, alertPayload.pickUpLon);
    GMSMarker *pickupMarker = [C411StaticHelper addMarkerOnMap:self.mapView atPosition:pickUpCoordinate withImage:[UIImage imageNamed:@"ic_pin_pick_up_from"] andTitle:nil];
    CLLocationCoordinate2D dropCoordinate = CLLocationCoordinate2DMake(alertPayload.dropLat, alertPayload.dropLon);
   GMSMarker *dropMarker = [C411StaticHelper addMarkerOnMap:self.mapView atPosition:dropCoordinate withImage:[UIImage imageNamed:@"ic_pin_drop_at"] andTitle:nil];
    NSArray *arrMarkers = @[pickupMarker,
                            dropMarker];
    ///zoom map to show markers
    [C411StaticHelper focusMap:self.mapView toShowAllMarkers:arrMarkers];
    
    
    ///Show the ride request timestamp
    NSDate *rideRequestDate = [NSDate dateWithTimeIntervalSince1970:(alertPayload.createdAtInMillis / 1000)];
    self.lblRequestTime.text = [C411StaticHelper getFormattedTimeFromDate:rideRequestDate withFormat:TimeStampFormatDateOrTime];
    
    ///Show the user image
    __weak typeof(self) weakSelf = self;
//    [C411StaticHelper getAvatarForUserWithId:alertPayload.strUserId shouldFallbackToGravatar:YES ofSize:self.imgVuRider.bounds.size.width roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//        
//        if (success && image) {
//            
//            ///Got the image, set it to the imageview
//            weakSelf.imgVuRider.image = image;
//        }
//        
//        
//    }];
    ///show the title
    CGFloat fontSize = self.lblAlertTitle.font.pointSize;
    NSString *strTitleMidText = NSLocalizedString(@"requested a", nil);
    NSString *strTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ %@ ride",nil),alertPayload.strFullName,strTitleMidText];
    NSRange unboldTextRange = NSMakeRange(alertPayload.strFullName.length + 1, strTitleMidText.length);
    self.lblAlertTitle.attributedText = [C411StaticHelper getSemiboldAttributedStringWithString:strTitle ofSize:fontSize withUnboldTextInRange:unboldTextRange];
    
    PFQuery *getUserQuery = [PFUser query];
    [getUserQuery getObjectInBackgroundWithId:alertPayload.strUserId block:^(PFObject *object,  NSError *error){
        if (!error && object) {
            ///User found, get the avatar for this user
            PFUser *parseUser = (PFUser *)object;
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

    ///Fetch and set the current status for ride and show the action buttons accordingly
    [self fetchRideStatusAndUpdateUI];
    
    ///Get the address for pickup and drop locations
    self.pickUpLocationTask = [C411StaticHelper updateLocationonLabel:self.lblPickUpAddress usingCoordinate:pickUpCoordinate];
    self.dropLocationTask = [C411StaticHelper updateLocationonLabel:self.lblDropAddress usingCoordinate:dropCoordinate];
    
    ///Get the distance matrix for pickup and drop locations
    self.pickUpDistanceMatrixTask = [C411StaticHelper updateDistanceMatrixOnLabel:self.lblPickupDistanceMatrix usingOriginCoordinate:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate destinationCoordinate:pickUpCoordinate withCompletion:NULL];
    self.pickUpToDropDistanceMatrixTask = [C411StaticHelper updateDistanceMatrixOnLabel:self.lblPickupToDropDistanceMatrix usingOriginCoordinate:pickUpCoordinate destinationCoordinate:dropCoordinate withCompletion:^(NSError *error, id data) {
        
        ///use this data to set the suggested cost on Additional Note popup
        if (!error && data) {
            
            NSDictionary *dictDistanceMatrix = [C411StaticHelper getDistanceAndDurationFromDistanceMatrixResponse:data];
            NSNumber *numDistanceValueInMeters = [dictDistanceMatrix objectForKey:kDistanceMatrixDistanceKey];
            NSNumber *numDuration = [dictDistanceMatrix objectForKey:kDistanceMatrixDurationKey];
            if(numDistanceValueInMeters && numDuration){
                
                ///Get the distance and time required from pickup to drop location
                float distanceInKms = [numDistanceValueInMeters integerValue] / 1000.0;
                float distanceInMiles = distanceInKms/MILES_TO_KM;
                
                int seconds = [numDuration intValue];
                int totalMinutes = seconds / 60;
                
                ///Get the driver profile to get his cost values
                [C411StaticHelper getDriverProfileForUser:[AppDelegate getLoggedInUser] withCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    
                    if (object) {
                        
                        PFObject *driverProfile = (PFObject *)object;
                        float pickupCost = 0;
                        float costPerMin = 0;
                        float costPerMile = 0;
                        
                        ///Get the currency
                        NSString *strCurrency = driverProfile[kDriverProfileCurrencyKey];
                        if (!strCurrency || strCurrency.length == 0) {
                            
                            strCurrency = DEFAULT_RIDE_CURRENCY;
                        }
                        
                        ///set the pickup cost
                        NSNumber *pickUpCostNum = driverProfile[kDriverProfilePickupCostKey];
                        
                        if (pickUpCostNum) {
                            
                            pickupCost = [pickUpCostNum floatValue];
                        }
                        
                        ///set the per min cost
                        NSNumber *perMinCostNum = driverProfile[kDriverProfilePerMinuteCostKey];
                        if (perMinCostNum) {
                            
                            costPerMin = [perMinCostNum floatValue];
                        }
                        
                        ///set the per mile cost
                        NSNumber *perMileCostNum = driverProfile[kDriverProfilePerMileCostKey];
                        if (perMileCostNum) {
                            
                            costPerMile = [perMileCostNum floatValue];
                            
                        }
                        
                        float suggestedCost = [C411StaticHelper calculateRideCostForDistance:distanceInMiles duration:totalMinutes usingPickupCost:pickupCost costPerMin:costPerMin andCostPerMile:costPerMile];
                        
                        weakSelf.txtCost.text = [NSString stringWithFormat:@"%@%@",strCurrency,[C411StaticHelper getDecimalStringFromNumber:@(suggestedCost) uptoDecimalPlaces:2]];
                        
                    }
                    else if (error.code == kPFErrorObjectNotFound){
                        
                        ///set the suggested cost using default values
                        float suggestedCost = [C411StaticHelper calculateRideCostForDistance:distanceInMiles duration:totalMinutes usingPickupCost:DEFAULT_PICKUP_COST costPerMin:DEFAULT_PER_MIN_COST andCostPerMile:DEFAULT_PER_MILE_COST];
                        
                        weakSelf.txtCost.text = [NSString stringWithFormat:@"%@%@",DEFAULT_RIDE_CURRENCY,[C411StaticHelper getDecimalStringFromNumber:@(suggestedCost) uptoDecimalPlaces:2]];
                        
                    }
                    else{
                        
                        ///log the error
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"Error fetching driver profile:%@",errorString);
                    }
                    
                    
                }];

                
                
            }
                
        }
        
        
    }];
    
    ///Show avg rating of rider
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kAverageStarsFuncParamUserIdKey] = alertPayload.strUserId;
    [C411StaticHelper setAverageRatingForUserWithDetails:dictParams onLabel:self.lblAvgRating];
    
    ///set additional note title for popup
    NSString *strRiderFirstName = [[alertPayload.strFullName componentsSeparatedByString:@" "]firstObject];
    self.lblAdditionalNoteTitle.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Do you want to send additional note to %@?",nil),strRiderFirstName];
    
//    self.requestExpired = ![self isRideRequestValid:@(alertPayload.createdAtInMillis)];
//    if (self.isRequestExpired) {
//        
//        ///Show popup that the request is expired
//        [C411StaticHelper showAlertWithTitle:NSLocalizedString(@"Request Expired",nil) message:NSLocalizedString(@"This request is expired!", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
//        
//        ///show close button
//        [self showCloseButton];
//    }
    
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
    ///Update map style
    [self updateMapStyle];
    
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

-(void)fetchRideStatusAndUpdateUI
{
    ///Fetch and set the ride status for ride and show the action buttons accordingly
    __weak typeof(self) weakSelf = self;
    PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [rideRequestQuery includeKey:kRideRequestSelectedUserKey];
    [rideRequestQuery includeKey:kRideRequestRequestedByKey];
    [rideRequestQuery getObjectInBackgroundWithId:self.alertPayload.strRideRequestId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///ride request found
            PFObject *rideRequest = object;
            
            ///Save the rider for showing his reviews
            weakSelf.rider = rideRequest[kRideRequestRequestedByKey];
            
            ///get the status
            NSString *strRideStatus = rideRequest[kRideRequestStatusKey];
            if ([strRideStatus isEqualToString:kRideRequestStatusPending]) {
                
                ///Set the status as Pending
                weakSelf.lblCurrentStatus.text = NSLocalizedString(@"Pending", nil);
                
                NSTimeInterval createdAtInMillis = [rideRequest.createdAt timeIntervalSince1970]*1000;
                BOOL isRequestExpired = ![C411StaticHelper isRideRequestValid:@(createdAtInMillis)];
                
                if (isRequestExpired == NO) {
                    
                    if (weakSelf.shouldShowNevermindAsClose) {
                        ///get the rejectedBy relation for this ride request and see if current user(driver) is already there on rejectedBy relation or not. If not then once user taps on close we need to save current user on rejectedBy relation to avoid displaying same popup again
                        PFRelation *rejectedByRelation = [rideRequest relationForKey:kRideRequestRejectedByKey];
                        [[rejectedByRelation query] findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error){
                            
                            if (!error) {
                                
                                ///Got rejectedBy members successfully
                                NSArray *arrRejectedByMembers = (NSArray *)objects;
                                
                                ///Iterate the array and check whether current user has already rejected the offer or not
                                BOOL hasRejected = NO;
                                NSString *strDriverId = [AppDelegate getLoggedInUser].objectId;
                                for (PFUser *user in arrRejectedByMembers) {
                                    
                                    if ([user.objectId isEqualToString:strDriverId]) {
                                        ///Yes the given user with strDriverId exist
                                        hasRejected = YES;
                                        break;
                                    }
                                    
                                }
                                
                                ///Set whether we need to save current user on RejectedBy relation or not on close
                                weakSelf.saveInRejectedByOnClose = !hasRejected;
                                
                                
                            }
                            else{
                                
                                if(![AppDelegate handleParseError:error]){
                                
                                    NSLog(@"Error:%@",error);
                                
                                }
                            }
                            

                            
                            ///show nevermind button as close, as user opend the popup by tapping on a Ride Request Cell from alerts tab
                            [weakSelf.btnNotInterested setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
                            
                            ///show interested and not interested buttons only if ride request is not expired
                            weakSelf.btnInterested.hidden = NO;
                            
                            weakSelf.btnNotInterested.hidden = NO;

                            
                        }];

                    }
                    else{
                       
                        ///show interested and not interested buttons only if ride request is not expired
                        weakSelf.btnInterested.hidden = NO;
                        
                        weakSelf.btnNotInterested.hidden = NO;
                    }
                    
                    
                    
                }
                else{
                    
                    ///Show popup that the request is expired
                    [C411StaticHelper showAlertWithTitle:NSLocalizedString(@"Request Expired",nil) message:NSLocalizedString(@"This request is expired!", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                    ///show close button
                    [weakSelf showCloseButton];

                }
                
            }
            else{
                
                if ([strRideStatus isEqualToString:kRideRequestStatusCancelled]) {
                    
                    ///Set the status as Cancelled
                    weakSelf.lblCurrentStatus.text = NSLocalizedString(@"Cancelled", nil);
                    
                    ///Show popup that the request is cancelled
                    [C411StaticHelper showAlertWithTitle:NSLocalizedString(@"Request Cancelled",nil) message:NSLocalizedString(@"This request is cancelled.", nil) onViewController:[AppDelegate sharedInstance].window.rootViewController];
                    
                }
                else if ([strRideStatus isEqualToString:kRideRequestStatusSelected]) {
                    
                    ///Set the status as Selected
//                    PFUser *selectedUser = rideRequest[kRideRequestSelectedUserKey];
//                    NSString *strFirstName = selectedUser[kUserFirstnameKey];
//                    NSString *strLastName = selectedUser[kUserLastnameKey];
//                    NSString *strSelectedUserFullName = [C411StaticHelper getFullNameUsingFirstName:strFirstName andLastName:strLastName];
//                    
//                    weakSelf.lblCurrentStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is selected",nil),strSelectedUserFullName];
                    weakSelf.lblCurrentStatus.text = NSLocalizedString(@"Selected", nil);
                }
                
                ///show close button
                [weakSelf showCloseButton];
            }
            
        }
        else {
            
            ///show the error
            if (error) {
                
                if(![AppDelegate handleParseError:error]){
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
            }
            
            ///unable to fetch ride details, show the close button
            [weakSelf showCloseButton];
 
           
            
        }
    }];


}


-(void)showWorkingButton
{
    
    ///show close button with title as working... and disable interaction
    [self.btnClose setTitle:NSLocalizedString(@"Working...", nil) forState:UIControlStateNormal];
    self.userInteractionEnabled = NO;
    self.btnClose.hidden = NO;
    
}

-(void)hideWorkingButton
{
    self.userInteractionEnabled = YES;
    self.btnClose.hidden = YES;
    
}

-(void)showCloseButton
{
    ///update close title and enable interaction
    [self.btnClose setTitle:NSLocalizedString(@"CLOSE", nil) forState:UIControlStateNormal];
    self.userInteractionEnabled = YES;
    self.btnClose.hidden = NO;
}

-(void)saveCurrentUserToRelation:(NSString *)strRelationName withCompletion:(PFBooleanResultBlock)completion
{
    ///add current user to the given relation of the ride request
    PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [rideRequestQuery selectKeys:@[strRelationName]];
    [rideRequestQuery getObjectInBackgroundWithId:self.alertPayload.strRideRequestId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            PFObject *rideRequest = object;
            
            PFRelation *rideRequestRelation = [rideRequest relationForKey:strRelationName];
            [rideRequestRelation addObject:[AppDelegate getLoggedInUser]];
            
            ///Save it in background
            [rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    
                    ///save it eventually if error occured
                    [rideRequest saveEventually];
                    
                }
                
                if (completion != NULL) {
                    
                    completion(succeeded,error);
                }
               
                
                
            }];
            
            
        }
        else {
            
            ///show error
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"#error fetching cell411alert :%@",errorString);
            
            if (completion != NULL) {
                
                completion(NO,error);
            }
            
        }
        
        
        
    }];

}


-(void)sendRideResponseWithAdditionalNote:(NSString *)strAdditionalNote cost:(NSString *)strCost toRiderWithId:(NSString *)strRiderId forRideRequestWithId:(NSString *)strRideRequestId fromPickUpLocation:(CLLocationCoordinate2D)pickUpLocation toDropLocation:(CLLocationCoordinate2D)dropLocation
{
    ///Show the progress hud
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    __weak typeof(self) weakSelf = self;

    ///make an entry in RideResponse Table
    PFObject *rideResponse = [PFObject objectWithClassName:kRideResponseClassNameKey];
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    rideResponse[kRideResponseRespondedByKey] = currentUser;
    if (strAdditionalNote.length > 0) {
        
        rideResponse[kRideResponseAdditionalNoteKey] = strAdditionalNote;
    }
    rideResponse[kRideResponseCostKey] = strCost;
    rideResponse[kRideResponseSeenKey] = @(NO);
    rideResponse[kRideResponseRideRiquestIdKey] = strRideRequestId;
    rideResponse[kRideResponseStatusKey] = kRideResponseStatusWaiting;
    [rideResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        
        ///remove the hud
        [MBProgressHUD hideHUDForView:weakSelf animated:YES];

        if (succeeded) {
            
            ///show toast message
            NSString *strMessage = NSLocalizedString(@"Response sent successfully", nil);
            [AppDelegate showToastOnView:weakSelf withMessage:strMessage];
            
            ///make payload and send push
            NSString *userFirstName = currentUser[kUserFirstnameKey];
            NSString *userLastName = currentUser[kUserLastnameKey];
            NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:userFirstName andLastName:userLastName];
            
            NSString *strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"offered to give you a ride", nil)];
            NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
            dictData[kPayloadAlertKey] = strAlertMsg;
            dictData[kPayloadUserIdKey] = currentUser.objectId;
            dictData[kPayloadRideRequestIdKey] = strRideRequestId;
            dictData[kPayloadRideResponseIdKey] = rideResponse.objectId;
            dictData[kPayloadPickUpLatKey] = @(pickUpLocation.latitude);
            dictData[kPayloadPickUpLongKey] = @(pickUpLocation.longitude);
            dictData[kPayloadDropLatKey] = @(dropLocation.latitude);
            dictData[kPayloadDropLongKey] = @(dropLocation.longitude);
            dictData[kPayloadAdditionalNoteKey] = strAdditionalNote ? strAdditionalNote : @"";
            dictData[kPayloadCostKey] = strCost;
            
            ///Get ride response time in milliseconds
            double rideResponseTimeInMillis = [rideResponse.createdAt timeIntervalSince1970] * 1000;
            dictData[kPayloadCreatedAtKey] = @(rideResponseTimeInMillis);
            dictData[kPayloadNameKey] = strFullName;
            dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeRideInterested;
            dictData[kPayloadSoundKey] = @"default";///To play default sound
            dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
            
            // Create our Installation query
            PFQuery *pushQuery = [PFInstallation query];
            PFQuery *innerQuery = [PFUser query];
            [innerQuery whereKey:@"objectId" equalTo:strRiderId];
            [pushQuery whereKey:kInstallationUserKey matchesQuery:innerQuery];
            
            // Send push notification to query
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery]; // Set our Installation query
            [push setData:dictData];
            
            ///Send Push notification
            [push sendPushInBackground];
            
            ///remove the additional note popup
            weakSelf.vuAdditionalNotePopupBase.hidden = YES;
            
        }
        else{
            
            if (error) {
                if(![AppDelegate handleParseError:error]){
                    ///show error
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
            }
            
        }
        
        
    }];
    
}

-(BOOL)canOfferRide:(PFUser *)driver
{
    BOOL canOffer = YES;
    NSString *strMessage = @"Please complete the below information in order to offer ride:\n";
    
    BOOL isPhoneVerified = [driver[kUserPhoneVerifiedKey]boolValue];
    if (!isPhoneVerified) {
       
        canOffer = NO;
        strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@\n-Verify your phone",nil),strMessage];
    }
    
    NSNumber *imageNameNum = driver[kUserImageNameKey];
    if (!imageNameNum) {
        
        canOffer = NO;
        strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@\n-Upload your profile pic",nil),strMessage];

    }
   
    NSNumber *carImageNum = driver[kUserCarImageNameKey];
    if (!carImageNum) {
        
        canOffer = NO;
        strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@\n-Upload your car image",nil),strMessage];
        
    }
    
    if (!canOffer) {
        
        ///show the alert
        ///Show the alert and on proceed open the ride settings vc
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            ///User tapped cancel
            
            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        UIAlertAction *proceedAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Proceed", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            ///User tapped proceed, show the ride settings VC
            
            UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
            C411RideSettingsVC *rideSettingsVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411RideSettingsVC"];
            [navRoot pushViewController:rideSettingsVC animated:YES];

            ///Dequeue the current Alert Controller and allow other to be visible
            [[MAAlertPresenter sharedPresenter]dequeueAlert];
            
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:proceedAction];
        
        ///Enqueue the alert controller object in the presenter queue to be displayed one by one
        [[MAAlertPresenter sharedPresenter]enqueueAlert:alertController];

    }

    return canOffer;
    
    
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnNotInterestedTapped:(UIButton *)sender {
    
    if ((!self.shouldShowNevermindAsClose) || self.shouldSaveInRejectedByOnClose) {
        ///work as Nevermind button
        ///add current user to the rejectedBy relation of the ride request
        __weak typeof(self) weakSelf = self;
        [self showWorkingButton];
        [self saveCurrentUserToRelation:kRideRequestRejectedByKey withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded) {
                
                if (weakSelf.shouldSaveInRejectedByOnClose) {
                    
                    ///user tapped on close button, but as this is the first time user responded, so we had saved the current user on RejectedBy relation and then we'll close the popup
                    [weakSelf btnCloseTapped:weakSelf.btnClose];

                    
                }
                else{
                    
                    ///hide working and show close button as user tapped on Nevermind button
                    [weakSelf showCloseButton];

                }
                
            }
            
        }];

    }
    else{
        
        ///Work as close button
        [self btnCloseTapped:self.btnClose];
    }

}


- (IBAction)btnInterestedTapped:(UIButton *)sender {
    
        ///add current user to the initiatedBy relation of the ride request
        __weak typeof(self) weakSelf = self;
        [self showWorkingButton];
    ///Fetch the current user details
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    [currentUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (object) {
            
            ///Check if user can offer ride
            if ([weakSelf canOfferRide:currentUser]) {
                
                ///work on offering the ride
                [self saveCurrentUserToRelation:kRideRequestInitiatedByKey withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if (succeeded) {
                        
                        ///hide working and show close button
                        [weakSelf showCloseButton];
                        
                        ///set the estimated cost for the driver
                        
                        ///show additional note and cost popup
                        weakSelf.vuAdditionalNotePopupBase.hidden = NO;
                        
                    }
                    else{
                        
                        if(![AppDelegate handleParseError:error]){
                            ///show error
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        }
                        ///Hide working button
                        [weakSelf hideWorkingButton];
                    }
                    
                    
                    
                }];

            }
            else{
                
                ///Hide the working button
                [weakSelf hideWorkingButton];

            }
            
        }
        else{
            
            if (error) {
                
                if(![AppDelegate handleParseError:error]){
                    // Show the errorString somewhere and let the user try again.
                    NSString *errorString = [error userInfo][@"error"];
                    [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                }
                
            }
            
            ///Hide the working button
            [weakSelf hideWorkingButton];
            
        }
        
        
    }];

    
    

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

- (IBAction)btnSendTapped:(UIButton *)sender {
    
    ///Create a ride response object and make entry on parse
    if (self.txtCost.text.length > 0) {
        
        ///Remove the keyboard
        [self endEditing:YES];
        
        ///Send Ride response
        [self sendRideResponseWithAdditionalNote:self.txtAdditionalNote.text cost:self.txtCost.text toRiderWithId:self.alertPayload.strUserId forRideRequestWithId:self.alertPayload.strRideRequestId fromPickUpLocation:CLLocationCoordinate2DMake(self.alertPayload.pickUpLat, self.alertPayload.pickUpLon) toDropLocation:CLLocationCoordinate2DMake(self.alertPayload.dropLat, self.alertPayload.dropLon)];

    }
    else{
        
        [AppDelegate showToastOnView:self withMessage:NSLocalizedString(@"Cost cannot be empty.", nil)];
    }
    
    
}

- (IBAction)btnShowRatingTapped:(UIButton *)sender {
    
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411RideReviewsVC *rideReviewsVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411RideReviewsVC"];
    rideReviewsVC.rideConfirmed = NO;
    if (self.rider) {
        
        rideReviewsVC.targetUser = self.rider;
    }
    else{
        
        rideReviewsVC.targetUserId = self.alertPayload.strUserId;
    }
    [navRoot pushViewController:rideReviewsVC animated:YES];
    
    
}

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    ///Show photo VC to view photo alert
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
    viewPhotoVC.imgPhoto = self.imgVuRider.image;
    [navRoot pushViewController:viewPhotoVC animated:YES];
}


//****************************************************
#pragma mark - UITextFieldDelegate Methods
//****************************************************

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtAdditionalNote) {
        
        [self.txtCost becomeFirstResponder];
        return NO;
    }
    else{

        [textField resignFirstResponder];
        return YES;
    
    }
    
}




//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)keyboarWillShow:(NSNotification *)notif
{
    
    ///if custom additional note popup is visible, move it up by 100 pixel
    if (!self.vuAdditionalNotePopupBase.isHidden) {
        
        self.cnsAdditonalNotePopupCenterY.constant = -100;
        
    }
    
}

-(void)keyboarWillHide:(NSNotification *)notif
{
    
    ///if custom additional note popup is visible, move it back to original position
    if (!self.vuAdditionalNotePopupBase.isHidden) {
        
        self.cnsAdditonalNotePopupCenterY.constant = 0;
        
    }
    
}

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}


@end
