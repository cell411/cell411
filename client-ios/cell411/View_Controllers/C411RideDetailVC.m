//
//  C411RideDetailVC.m
//  cell411
//
//  Created by Milan Agarwal on 04/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideDetailVC.h"
#import "ServerUtility.h"
#import <GoogleMaps/GoogleMaps.h>
#import "C411StaticHelper.h"
#import "C411LocationManager.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <OpenInGoogleMaps/OpenInGoogleMapsController.h>
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ViewPhotoVC.h"
#import "C411RideReviewsVC.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411RideDetailVC ()

@property (weak, nonatomic) IBOutlet UILabel *lblRequestTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuRider;
@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *vuSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRideStatusHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblSeenStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNote;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteValue;
@property (weak, nonatomic) IBOutlet UILabel *lblMyAdditionalNote;
@property (weak, nonatomic) IBOutlet UILabel *lblMyAdditionalNoteValue;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDropAddress;
@property (weak, nonatomic) IBOutlet UIView *vuPickupDistanceMatrix;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupDistanceMatrix;
@property (weak, nonatomic) IBOutlet UIView *vuPickupToDropDistanceMatrix;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupToDropDistanceMatrix;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigateToPickupAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigateToDropAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblResponseHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblResponse;
@property (weak, nonatomic) IBOutlet UILabel *lblCostHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblCost;
@property (weak, nonatomic) IBOutlet UIView *vuAvgRatingBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuStar;
@property (weak, nonatomic) IBOutlet UILabel *lblAvgRating;
@property (weak, nonatomic) IBOutlet UIView *vuNotifyPickup;
@property (weak, nonatomic) IBOutlet UILabel *lblNotifyPickupTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnNotifyRider;
@property (weak, nonatomic) IBOutlet UIButton *btnRideCompleted;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentLocationCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpLocationCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpLocationCaption2;
@property (weak, nonatomic) IBOutlet UILabel *lblDropLocationCaption;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSeenStatusVuTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSeenStatusLblTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSeenStatusLblBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsResponseLblTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsMyAdditionalNoteTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRideCompletedVuHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsNotifyPickupVuTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsNotifyPickupTitleTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsNotifyRiderBtnTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsNotifyRiderBtnBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsNotifyRiderHeight;

- (IBAction)barBtnCallTapped:(UIBarButtonItem *)sender;
- (IBAction)btnNavigateToPickupAddressTapped:(UIButton *)sender;
- (IBAction)btnNavigateToDropAddressTapped:(UIButton *)sender;
- (IBAction)imgVuAvatarTapped:(UITapGestureRecognizer *)sender;
- (IBAction)btnShowRatingTapped:(UIButton *)sender;
- (IBAction)btnNotifyRiderTapped:(UIButton *)sender;
- (IBAction)btnRideCompletedTapped:(UIButton *)sender;

@property (nonatomic, assign, getter=isFirstTime) BOOL firstTime;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *dropLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpDistanceMatrixTask;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpToDropDistanceMatrixTask;
@property (nonatomic, assign) CLLocationCoordinate2D pickUpCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D dropCoordinate;

@property (nonatomic, strong) NSString *strRideResponseStatus;
@property (nonatomic, assign) float rideCompletedVuInitialHeight;
@property (nonatomic, strong) NSArray *arrNotifyRiderVuConstraintsVal;

@end

@implementation C411RideDetailVC

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.firstTime = YES;
    self.rideCompletedVuInitialHeight = self.cnsRideCompletedVuHeight.constant;

    [self configureViews];
    [self initializeViewWithAlertPayload:self.alertPayload];
    [self registerForNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isFirstTime) {
        
        self.firstTime = NO;
        
        ///Load mapview zoomed to pickup and drop location
        ///Add mapview
        [self addGoogleMapWithAlertCoordinate:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];
        ///add markers
        CLLocationCoordinate2D pickUpCoordinate = CLLocationCoordinate2DMake(self.alertPayload.pickUpLat, self.alertPayload.pickUpLon);
        GMSMarker *pickupMarker = [C411StaticHelper addMarkerOnMap:self.mapView atPosition:pickUpCoordinate withImage:[UIImage imageNamed:@"ic_pin_pick_up_from"] andTitle:nil];
        CLLocationCoordinate2D dropCoordinate = CLLocationCoordinate2DMake(self.alertPayload.dropLat, self.alertPayload.dropLon);
        GMSMarker *dropMarker = [C411StaticHelper addMarkerOnMap:self.mapView atPosition:dropCoordinate withImage:[UIImage imageNamed:@"ic_pin_drop_at"] andTitle:nil];
        NSArray *arrMarkers = @[pickupMarker,
                                dropMarker];
        ///zoom map to show markers
        [C411StaticHelper focusMap:self.mapView toShowAllMarkers:arrMarkers];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
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
#pragma mark - Overridden Methods
//****************************************************
-(void)mag_viewDidBack {
    [super mag_viewDidBack];
    if (self.backActionHandler != NULL) {
        ///call the Close action handler
        self.backActionHandler(nil, nil);
        
    }
    self.backActionHandler = NULL;
}

//****************************************************
#pragma mark - Private methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Ride Detail", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    ///make circular views
    [C411StaticHelper makeCircularView:self.imgVuRider];
    [C411StaticHelper makeCircularView:self.btnNavigateToPickupAddress];
    [C411StaticHelper makeCircularView:self.btnNavigateToDropAddress];
    [C411StaticHelper makeCircularView:self.vuAvgRatingBase];
    
    ///set corner radius
    self.vuPickupDistanceMatrix.layer.cornerRadius = 3.0;
    self.vuPickupDistanceMatrix.layer.masksToBounds = YES;
    self.vuPickupToDropDistanceMatrix.layer.cornerRadius = 3.0;
    self.vuPickupToDropDistanceMatrix.layer.masksToBounds = YES;
    self.vuNotifyPickup.layer.cornerRadius = 3.0;
    self.vuNotifyPickup.layer.shadowOffset = CGSizeMake(0, 1);
    self.vuNotifyPickup.layer.shadowOpacity = 0.8;
    self.vuNotifyPickup.layer.masksToBounds = NO;
    self.btnNotifyRider.layer.cornerRadius = 3.0;
    self.btnNotifyRider.layer.masksToBounds = YES;
    self.btnRideCompleted.layer.cornerRadius = 3.0;
    self.btnRideCompleted.layer.masksToBounds = YES;
    
    [self applyColors];
}

-(void)updateMapStyle {
    self.mapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
}

-(void)applyColors {
    ///Update map style
    [self updateMapStyle];
    ///Set background color
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTitle.textColor = primaryTextColor;
    self.lblRideStatusHeading.textColor = primaryTextColor;
    self.lblAdditionalNote.textColor = primaryTextColor;
    self.lblResponseHeading.textColor = primaryTextColor;
    self.lblCostHeading.textColor = primaryTextColor;
    self.lblMyAdditionalNote.textColor = primaryTextColor;
    self.lblCurrentLocationCaption.textColor = primaryTextColor;
    self.lblPickUpLocationCaption.textColor = primaryTextColor;
    self.lblPickUpLocationCaption2.textColor = primaryTextColor;
    self.lblDropLocationCaption.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblRequestTime.textColor = secondaryTextColor;
    self.lblPickUpAddress.textColor = secondaryTextColor;
    self.lblDropAddress.textColor = secondaryTextColor;
    self.lblNotifyPickupTitle.textColor = secondaryTextColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuSeparator.backgroundColor = themeColor;
    self.vuAvgRatingBase.backgroundColor = themeColor;
    self.btnRideCompleted.backgroundColor = themeColor;
    
    ///Set primaryBGTextColor
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblAvgRating.textColor = primaryBGTextColor;
    self.imgVuStar.tintColor = primaryBGTextColor;
    [self.btnRideCompleted setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    self.vuNotifyPickup.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuNotifyPickup.layer.shadowColor = [C411ColorHelper sharedInstance].fabShadowColor.CGColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)initializeViewWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    ///Hide the seen status view initially
    self.lblSeenStatus.text = nil;
    self.cnsSeenStatusLblTS.constant = 0;
    self.cnsSeenStatusLblBS.constant = 0;
    self.cnsResponseLblTS.constant = 0;
    
    ///Hide the notify rider view initially
    [self hideNotifyRiderView];
    
    ///hide the ride completed view initially
    [self hideRideCompletedView];
    
    ///Show the ride request timestamp
    NSDate *rideRequestDate = [NSDate dateWithTimeIntervalSince1970:(alertPayload.createdAtInMillis / 1000)];
    self.lblRequestTime.text = [C411StaticHelper getFormattedTimeFromDate:rideRequestDate withFormat:TimeStampFormatDateOrTime];
    
    ///Show the user image
//    __weak typeof(self) weakSelf = self;
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
    NSString *strTitleMidText = NSLocalizedString(@"requested a", nil);
    NSString *strTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ %@ ride",nil),alertPayload.strFullName,strTitleMidText];
    NSRange unboldTextRange = NSMakeRange(alertPayload.strFullName.length + 1, strTitleMidText.length);
    CGFloat fontSize = self.lblAlertTitle.font.pointSize;
    NSMutableAttributedString *attrTitle = [C411StaticHelper getSemiboldAttributedStringWithString:strTitle ofSize:fontSize withUnboldTextInRange:unboldTextRange];
    if ([C411StaticHelper isUserDeleted:self.rider]) {
        NSDictionary *dictDeletedUserAttr = @{
                                              NSFontAttributeName:[UIFont systemFontOfSize: fontSize],
                                              NSForegroundColorAttributeName: [C411ColorHelper sharedInstance].deletedUserTextColor
                                              };
        ///1. make name range
        NSRange riderNameRange = NSMakeRange(0, alertPayload.strFullName.length);
        ///2. set deleted user attribute
        [attrTitle setAttributes:dictDeletedUserAttr range:riderNameRange];
    }
    else {
        ///Set profile pic
        [self.imgVuRider setAvatarForUserWithId:alertPayload.strUserId shouldFallbackToGravatar:YES ofSize:self.imgVuRider.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
    }
    self.lblAlertTitle.attributedText = attrTitle;
    
    if (alertPayload.strAdditionalNote.length > 0) {
        
        ///Show the additional Note
        self.lblAdditionalNoteValue.text = alertPayload.strAdditionalNote;
        
    }
    else{
        
        ///hide the additional note label as well
        self.lblAdditionalNote.text = nil;
        self.lblAdditionalNoteValue.text = nil;
        self.cnsSeenStatusVuTS.constant = 0;
        
    }
    
    ///Fetch and set the current status for ride
    [self fetchRideStatusAndUpdateUI];
    
    ///Fetch and show the response details by current user and seen status
    [self fetchRideResponseDetailsAndUpdateUI];
    
    
    ///get pickup and drop coordinate
    self.pickUpCoordinate = CLLocationCoordinate2DMake(alertPayload.pickUpLat, alertPayload.pickUpLon);
    self.dropCoordinate = CLLocationCoordinate2DMake(alertPayload.dropLat, alertPayload.dropLon);

    ///Get the address for pickup and drop locations
    self.pickUpLocationTask = [C411StaticHelper updateLocationonLabel:self.lblPickUpAddress usingCoordinate:self.pickUpCoordinate];
    self.dropLocationTask = [C411StaticHelper updateLocationonLabel:self.lblDropAddress usingCoordinate:self.dropCoordinate];
    
    ///Get the distance matrix for pickup and drop locations
    self.pickUpDistanceMatrixTask = [C411StaticHelper updateDistanceMatrixOnLabel:self.lblPickupDistanceMatrix usingOriginCoordinate:[[C411LocationManager sharedInstance]getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate destinationCoordinate:self.pickUpCoordinate withCompletion:NULL];
    self.pickUpToDropDistanceMatrixTask = [C411StaticHelper updateDistanceMatrixOnLabel:self.lblPickupToDropDistanceMatrix usingOriginCoordinate:self.pickUpCoordinate destinationCoordinate:self.dropCoordinate withCompletion:NULL];
    
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kAverageStarsFuncParamUserIdKey] = self.rider.objectId;
    [C411StaticHelper setAverageRatingForUserWithDetails:dictParams onLabel:self.lblAvgRating];
    
}


-(void)addGoogleMapWithAlertCoordinate:(CLLocationCoordinate2D)alertCoordinate
{
    
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:alertCoordinate.latitude longitude:alertCoordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //self.mapView.delegate = self;
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

-(void)fetchRideStatusAndUpdateUI
{
    ///Fetch and set the ride status for ride and update UI accordingly
    __weak typeof(self) weakSelf = self;
    PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [rideRequestQuery includeKey:kRideRequestSelectedUserKey];
    [rideRequestQuery getObjectInBackgroundWithId:self.alertPayload.strRideRequestId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///ride request found
            PFObject *rideRequest = object;
            ///get the status
            NSString *strRideStatus = rideRequest[kRideRequestStatusKey];
            if ([strRideStatus isEqualToString:kRideRequestStatusPending]) {
                
                ///Set the status as Pending
                weakSelf.lblCurrentStatus.text = NSLocalizedString(@"Pending", nil);
                
            }
            else{
                
                if ([strRideStatus isEqualToString:kRideRequestStatusCancelled]) {
                    
                    ///Set the status as Cancelled
                    weakSelf.lblCurrentStatus.text = NSLocalizedString(@"Cancelled", nil);
                }
                else if ([strRideStatus isEqualToString:kRideRequestStatusSelected]) {
                    
                    ///Set the status as Selected
                    PFUser *selectedUser = rideRequest[kRideRequestSelectedUserKey];
                    if ([selectedUser.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
                        ///Current user is selected
                        weakSelf.lblCurrentStatus.text = NSLocalizedString(@"You are selected", nil);
                    }
                    else{
                        ///someone else is selected for the ride
                        NSString *strFirstName = selectedUser[kUserFirstnameKey];
                        NSString *strLastName = selectedUser[kUserLastnameKey];
                        NSString *strSelectedUserFullName = [C411StaticHelper getFullNameUsingFirstName:strFirstName andLastName:strLastName];
                        
                        weakSelf.lblCurrentStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is selected",nil),strSelectedUserFullName];

                    }

                }
                
              
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
            
            
            
        }
    }];
    
    
}

-(void)fetchRideResponseDetailsAndUpdateUI
{
    ///Fetch and set the ride status for ride and update UI accordingly
    __weak typeof(self) weakSelf = self;
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    PFQuery *rideResponseQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
    [rideResponseQuery whereKey:kRideResponseRideRiquestIdKey equalTo:self.alertPayload.strRideRequestId];
    [rideResponseQuery whereKey:kRideResponseRespondedByKey equalTo:currentUser];
    [rideResponseQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            PFObject *rideResponse = object;
            
            ///Set the response status
            weakSelf.strRideResponseStatus = rideResponse[kRideResponseStatusKey];
            if ([weakSelf.strRideResponseStatus isEqualToString:kRideResponseStatusConfirmed]) {
                ///Current user's offer is confirmed
                weakSelf.lblResponse.text = NSLocalizedString(@"Confirmed", nil);
                
                ///Show the ride completed view if it's not already marked as completed
                if (weakSelf.alertPayload.isRideCompleted == NO) {
                    
                    ///Ride is not yet completed show the ride completed view so that user can mark it as completed
                    weakSelf.cnsRideCompletedVuHeight.constant = weakSelf.rideCompletedVuInitialHeight;
                    weakSelf.btnRideCompleted.hidden = NO;
                    
                    ///Show notify pickup view if it's within time limit
                    BOOL canShowNotifyPickup = [weakSelf canNotifyPickupReached:@(weakSelf.alertPayload.createdAtInMillis)];
                    if (canShowNotifyPickup) {
                        
                        ///Set title for pickup reached
                        [weakSelf updateNotifyPickupReachedMessage:weakSelf.alertPayload.isPickupReached];
                        
                        ///Show the notify pickup option
                        [weakSelf showNotifyRiderView];
                        
                    }
                    
                }
                
                
            }
            else if ([weakSelf.strRideResponseStatus isEqualToString:kRideResponseStatusRejected]) {
                
                weakSelf.lblResponse.text = NSLocalizedString(@"Rejected", nil);
            }
            else{
                
                weakSelf.lblResponse.text = NSLocalizedString(@"Waiting", nil);
                
                ///Show the seen status
                NSNumber *numSeenStatus = rideResponse[kRideResponseSeenKey];
                if ([numSeenStatus boolValue]) {
                    
                    ///Response is seen by the rider
                    weakSelf.lblSeenStatus.text = NSLocalizedString(@"Your response to this request is seen by the rider", nil);
                }
                else{
                    
                    ///Reponse is not yet seen by the rider
                     weakSelf.lblSeenStatus.text = NSLocalizedString(@"Your response to this request is not yet seen by the rider", nil);
                }
                
                ///update constraints to make the seen status visible
                weakSelf.cnsSeenStatusLblTS.constant = 5;
                weakSelf.cnsSeenStatusLblBS.constant = 5;
                weakSelf.cnsResponseLblTS.constant = 10;
                
            }
            
            ///Set the cost
            weakSelf.lblCost.text = rideResponse[kRideResponseCostKey];
            
            ///set my additional note
            NSString *strMyAdditionalNote = rideResponse[kRideResponseAdditionalNoteKey];
            
            if (strMyAdditionalNote.length > 0) {
                
                ///Show my additional Note
                weakSelf.lblMyAdditionalNoteValue.text = strMyAdditionalNote;
                
            }
            else{
                
                ///hide the my additional note label as well
                weakSelf.lblMyAdditionalNote.text = nil;
                weakSelf.lblMyAdditionalNoteValue.text = nil;
                weakSelf.cnsMyAdditionalNoteTS.constant = 0;
                
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
            
            
            
        }

    }];
    

}

-(void)hideNotifyRiderView
{
    ///save the initial value of constraints in array
    NSMutableArray *arrInitialConstraints = [NSMutableArray array];
    [arrInitialConstraints addObject:@(self.cnsNotifyPickupVuTS.constant)];
    [arrInitialConstraints addObject:@(self.cnsNotifyPickupTitleTS.constant)];
    [arrInitialConstraints addObject:@(self.cnsNotifyRiderBtnTS.constant)];
    [arrInitialConstraints addObject:@(self.cnsNotifyRiderHeight.constant)];
    [arrInitialConstraints addObject:@(self.cnsNotifyRiderBtnBS.constant)];
    self.arrNotifyRiderVuConstraintsVal = arrInitialConstraints;
    
    ///Set all constraints to 0 to hide the view
    self.cnsNotifyPickupVuTS.constant = 0;
    self.cnsNotifyPickupTitleTS.constant = 0;
    self.lblNotifyPickupTitle.text = nil;
    self.cnsNotifyRiderBtnTS.constant = 0;
    self.cnsNotifyRiderHeight.constant = 0;
    self.cnsNotifyRiderBtnBS.constant = 0;
    
}

-(void)showNotifyRiderView
{
    self.cnsNotifyPickupVuTS.constant = [[self.arrNotifyRiderVuConstraintsVal objectAtIndex:0]floatValue];
    self.cnsNotifyPickupTitleTS.constant = [[self.arrNotifyRiderVuConstraintsVal objectAtIndex:1]floatValue];
    self.cnsNotifyRiderBtnTS.constant = [[self.arrNotifyRiderVuConstraintsVal objectAtIndex:2]floatValue];
    self.cnsNotifyRiderHeight.constant = [[self.arrNotifyRiderVuConstraintsVal objectAtIndex:3]floatValue];
    self.cnsNotifyRiderBtnBS.constant = [[self.arrNotifyRiderVuConstraintsVal objectAtIndex:4]floatValue];

}

-(void)hideRideCompletedView
{
    self.cnsRideCompletedVuHeight.constant = 0;
    self.btnRideCompleted.hidden = YES;
}

-(BOOL)canNotifyPickupReached:(NSNumber *)confirmedAtInMillis
{
    if (confirmedAtInMillis) {
        
        double currentTimeInMillis = [[NSDate date]timeIntervalSince1970] * 1000;///Multiply by 1000 to convert it from second to millisecond
        
        double timeElaplsedInMillis = currentTimeInMillis - [confirmedAtInMillis doubleValue];
        
        if (timeElaplsedInMillis <= ((TIME_TO_LIVE_FOR_PICKUP_NOTIFY)*1000.0)) {
            
            ///Notification is valid
            return YES;
            
        }
        
    }
    
    return NO;
}

-(void)updateNotifyPickupReachedMessage:(BOOL)isPickupReached
{
    if (isPickupReached) {
        
        self.lblNotifyPickupTitle.text = NSLocalizedString(@"You already reached the pickup location", nil);
        
        [self.btnNotifyRider setTitle:NSLocalizedString(@"Notify Again", nil) forState:UIControlStateNormal];

        
    }
    else{
       
        self.lblNotifyPickupTitle.text = NSLocalizedString(@"Did you reached the pickup location?", nil);
        
        [self.btnNotifyRider setTitle:NSLocalizedString(@"Notify Rider", nil) forState:UIControlStateNormal];

        
    }

}



//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnCallTapped:(UIBarButtonItem *)sender {
    
    if ([self.strRideResponseStatus isEqualToString:kRideResponseStatusConfirmed]) {
        
        ///Make a call to the rider
        [C411StaticHelper callUser:self.rider];
        
    }
    else{
        
        ///Show the alert that you cannot call until request is confirmed
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You can contact the rider once they confirm your ride.", nil) onViewController:self];
    }
}

- (IBAction)btnNavigateToPickupAddressTapped:(UIButton *)sender {
    
    if ([self.strRideResponseStatus isEqualToString:kRideResponseStatusConfirmed]) {
        
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
    else{
        
        ///Show the alert that you cannot navigate until request is confirmed
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You can navigate to the pickup location of the rider once they confirm your ride.", nil) onViewController:self];
    }


}

- (IBAction)btnNavigateToDropAddressTapped:(UIButton *)sender {
    
    if ([self.strRideResponseStatus isEqualToString:kRideResponseStatusConfirmed]) {
        
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
    else{
        
        ///Show the alert that you cannot navigate until request is confirmed
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"You can navigate to the drop location of the rider once they confirm your ride.", nil) onViewController:self];
    }

}

- (IBAction)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    if (![C411StaticHelper isUserDeleted:self.rider]) {
        ///Show photo VC to view photo alert
        C411ViewPhotoVC *viewPhotoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
        viewPhotoVC.imgPhoto = self.imgVuRider.image;
        [self.navigationController pushViewController:viewPhotoVC animated:YES];
    }
}

- (IBAction)btnShowRatingTapped:(UIButton *)sender {
    
    C411RideReviewsVC *rideReviewsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411RideReviewsVC"];
    if ([self.strRideResponseStatus isEqualToString:kRideResponseStatusConfirmed]) {
        
        rideReviewsVC.rideConfirmed = YES;
    }
    else{
        
        rideReviewsVC.rideConfirmed = NO;
    }

    rideReviewsVC.targetUser = self.rider;
    [self.navigationController pushViewController:rideReviewsVC animated:YES];
    
    
}

- (IBAction)btnNotifyRiderTapped:(UIButton *)sender {
    
    ///send push to rider to notify ride reached
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strCurrentUserFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
    NSString *strAlertMsg = [NSString stringWithFormat:@"%@ %@",strCurrentUserFullName,NSLocalizedString(@"reached the pickup location and is ready to pick you up", nil)];
    NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
    dictData[kPayloadAlertKey] = strAlertMsg;
    
    dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeCustom;
    dictData[kPayloadSoundKey] = @"default";///To play default sound
    dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:kInstallationUserKey equalTo:self.rider];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:dictData];
    
    ///Send Push notification
    [push sendPushInBackground];
    
    ///post notification to show overlay
    [[NSNotificationCenter defaultCenter]postNotificationName:kHideRideOverlayNotification object:self.alertPayload.strRideRequestId];
    
    ///update pickup reached on on alert payload
    self.alertPayload.pickupReached = YES;
    
    ///Update the message for the notify
    [self updateNotifyPickupReachedMessage:self.alertPayload.isPickupReached];
    
    ///Get the latest ride request object and update it on Parse
    __weak typeof(self) weakSelf = self;
    ///Show progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [rideRequestQuery getObjectInBackgroundWithId:self.alertPayload.strRideRequestId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///ride request found
            PFObject *rideRequest = object;
            rideRequest[kRideRequestPickupReachedKey] = @(YES);
            
            ///save it on Parse
            [rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    
                    ///Save it eventually
                    [rideRequest saveEventually];
                }
                
                ///Hide the Progress Hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

                
            }];
            
        }
        else {
            
            ///show the error
            if (error) {
                
                if(![AppDelegate handleParseError:error]){
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"Error updating pickup reached on server: %@",errorString);
                }
                //[C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            }
            
            
            ///Hide the Progress Hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

        }
        
        
    }];

    
}

- (IBAction)btnRideCompletedTapped:(UIButton *)sender {
    
    ///Get the latest ride request object and update it on Parse
    __weak typeof(self) weakSelf = self;
    ///Show progress hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [rideRequestQuery getObjectInBackgroundWithId:self.alertPayload.strRideRequestId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///ride request found
            PFObject *rideRequest = object;
            rideRequest[kRideRequestRideCompletedKey] = @(YES);
            
            ///save it on Parse
            [rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    
                    ///Save it eventually
                    [rideRequest saveEventually];
                }
                
                ///Hide the Progress Hud
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                ///Hide the ride completed view
                [weakSelf hideRideCompletedView];
                
                ///Hide the notify view
                [weakSelf hideNotifyRiderView];
                
                ///save ride completed on payload
                weakSelf.alertPayload.rideCompleted = YES;
                
                ///hide pending pickup overlay if it's not yet removed
                if (weakSelf.alertPayload.isPickupReached == NO) {
                    
                    ///post notification to show overlay
                    [[NSNotificationCenter defaultCenter]postNotificationName:kHideRideOverlayNotification object:weakSelf.alertPayload.strRideRequestId];

                }
                
            }];
            
        }
        else {
            
            ///show the error
            if (error) {
                
                if(![AppDelegate handleParseError:error]){
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"Error updating pickup reached on server: %@",errorString);
                }
                //[C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            }
            
            
            ///Hide the Progress Hud
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
        }
        
        
    }];

    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
