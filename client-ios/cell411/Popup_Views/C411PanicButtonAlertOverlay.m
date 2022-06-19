//
//  C411PanicButtonAlertOverlay.m
//  cell411
//
//  Created by Milan Agarwal on 16/09/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PanicButtonAlertOverlay.h"
#import "C411PanicAlertSettings.h"
#import "C411StaticHelper.h"
#import "Constants.h"
//#import "ServerUtility.h"
#import "C411LocationManager.h"
#import "C411ColorHelper.h"

@interface C411PanicButtonAlertOverlay ()

@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRecipientsTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertRecipients;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNote;
@property (weak, nonatomic) IBOutlet UILabel *lblCountdown;
@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholderBase;
@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *vuUserLocationBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuUserLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblUserCity;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

-(IBAction)btnCloseTapped:(id)sender;

@property (nonatomic, strong) GMSMapView *mapView;
//@property (nonatomic, strong) NSURLSessionDataTask *getLocationTask;
@property (nonatomic, assign) NSInteger waitTime;
@property (nonatomic, strong) NSTimer *alertWaitTimer;
@property (nonatomic, assign, getter=isInitialized) BOOL initialized;

@end

@implementation C411PanicButtonAlertOverlay


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
    [C411StaticHelper removeOnScreenKeyboard];
    [self registerForNotifications];
}

-(void)dealloc
{
    [self unregisterFromNotifications];
}


//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setAlertType:(NSInteger)alertType
{
    _alertType = alertType;
    if (!self.isInitialized) {
        
        self.initialized = YES;
        [self setAlertDetails];

    }
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///Set rounded corner for Map placeholder base
    self.vuMapPlaceholderBase.layer.cornerRadius = 5.0;
    self.vuMapPlaceholderBase.layer.masksToBounds = YES;
    
    ///Set rounded corner for close button
    self.btnClose.layer.cornerRadius = 3.0;
    self.btnClose.layer.masksToBounds = YES;
    
    ///hide required things
    self.lblCountdown.hidden = YES;
    self.vuMapPlaceholderBase.hidden = YES;
    self.vuUserLocationBase.hidden = YES;
    self.btnClose.hidden = YES;
    
    ///set initial strings for localization
    self.lblUserCity.text = NSLocalizedString(@"Retreiving City...", nil);
    self.lblRecipientsTitle.text = NSLocalizedString(@"RECIPIENTS:", nil);

    
    [self applyColors];
}

-(void)updateMapStyle {
    self.mapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
}

-(void)applyColors {
    [self updateMapStyle];
    ///Set background color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuMapPlaceholderBase.backgroundColor = lightCardColor;
    self.btnClose.backgroundColor = lightCardColor;
    
    ///Set Primary text colors
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblUserCity.textColor = primaryTextColor;
    [self.btnClose setTitleColor:primaryTextColor forState:UIControlStateNormal];
    
    ///set hint icon color
    UIColor *hintIconColor = [C411ColorHelper sharedInstance].hintIconColor;
    self.imgVuUserLocation.tintColor = hintIconColor;
    
}

-(void)registerForNotifications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)setAlertDetails
{
    ///Get Panic Settings
    C411PanicAlertSettings *panicAlertSettings = [C411PanicAlertSettings getPanicAlertSettings];
    ///set title
    if (self.alertType == BTN_ALERT_TAG_PANIC) {
        
        self.lblAlertTitle.text = NSLocalizedString(@"PANIC ALERT", nil);
    }
    else if (self.alertType == BTN_ALERT_TAG_FALLEN){
        
        self.lblAlertTitle.text = NSLocalizedString(@"FALLEN ALERT", nil);

    }
    else{
        
        self.lblAlertTitle.text = nil;
    }
    
    ///Set Alert recipients
    NSMutableString *strAlertRecipients = [NSMutableString string];
    BOOL allFriendsSelected = NO;
    
    NSDictionary *dictAllFriends = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientAllFriendsKey];
    if (dictAllFriends && [[dictAllFriends objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
        
        ///All friends option is selected
        allFriendsSelected = YES;
        
        ///Append All friends text
        [strAlertRecipients appendString:NSLocalizedString(@"- All Friend(s)\n", nil)];
    }
        ///3. Check for near by option
        NSDictionary *dictNearBy = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientNearMeKey];
        if (dictNearBy && [[dictNearBy objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
            
            ///Append All near by users text
            [strAlertRecipients appendString:NSLocalizedString(@"- Near By users\n", nil)];
            
        }

        
    if (!allFriendsSelected) {
        
        ///2.Check for Private Cell option is selected or not. Both All Friends and Private Cell are Mutually Exclusive
        NSDictionary *dictPrivateCells = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPrivateCellsMembersKey];
        if (dictPrivateCells && [[dictPrivateCells objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
            
            ///Private Cells option is selected, append private cell text
            [strAlertRecipients appendString:NSLocalizedString(@"- Private Cell(s):", nil)];

            ///Get the array of the selected Private Cells
            NSArray *arrSelectedPrivateCells = [dictPrivateCells objectForKey:kPanicAlertRecipientSelectedCellsKey];
            ///Iterate the array and append all cell names
            BOOL isFirstCell = YES;
            for (NSDictionary *dictSelectedPrivateCell in arrSelectedPrivateCells) {
                
                NSString *strCellName = [dictSelectedPrivateCell objectForKey:kPanicAlertRecipientSelectedCellNameKey];
                if (isFirstCell) {
                    
                    isFirstCell = NO;
                    [strAlertRecipients appendFormat:@" %@",strCellName];
                }
                else{
                    
                    [strAlertRecipients appendFormat:@", %@",strCellName];
                    
                }
                
            }
            
            ///Append \n
            [strAlertRecipients appendString:@"\n"];

            
        }
        
        
    }
    
#if NON_APP_USERS_ENABLED
    ///3.Check for Nau Cell option is selected or not.
    NSDictionary *dictNauCells = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientNauCellsMembersKey];
    if (dictNauCells && [[dictNauCells objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
        
        ///Nau Cells option is selected, append Nau cell text
        [strAlertRecipients appendString:NSLocalizedString(@"- Non App User Cell(s):", nil)];
        
        ///Get the array of the selected Nau Cells
        NSArray *arrSelectedNauCells = [dictNauCells objectForKey:kPanicAlertRecipientSelectedCellsKey];
        ///Iterate the array and append all cell names
        BOOL isFirstCell = YES;
        for (NSDictionary *dictSelectedNauCell in arrSelectedNauCells) {
            
            NSString *strCellName = [dictSelectedNauCell objectForKey:kPanicAlertRecipientSelectedCellNameKey];
            if (isFirstCell) {
                
                isFirstCell = NO;
                [strAlertRecipients appendFormat:@" %@",strCellName];
            }
            else{
                
                [strAlertRecipients appendFormat:@", %@",strCellName];
                
            }
            
        }
        
        ///Append \n
        [strAlertRecipients appendString:@"\n"];
        
        
    }
#endif

    //Check for Public Cell option is selected or not
    NSDictionary *dictPublicCells = [panicAlertSettings.dictAlertRecipients objectForKey:kPanicAlertRecipientPublicCellsMembersKey];
    if (dictPublicCells && [[dictPublicCells objectForKey:kPanicAlertRecipientIsSelectedKey]boolValue]) {
        ///Public Cells option is selected, append public cell text
        [strAlertRecipients appendString:NSLocalizedString(@"- Public Cell(s):", nil)];

        ///1. Get the selected Public Cells Array
        NSArray *arrSelectedPublicCells = [dictPublicCells objectForKey:kPanicAlertRecipientSelectedCellsKey];
        
        ///Iterate the array and and append all cell names
        BOOL isFirstCell = YES;
        for (NSDictionary *dictSelectedPublicCell in arrSelectedPublicCells) {
            
            NSString *strCellName = [dictSelectedPublicCell objectForKey:kPanicAlertRecipientSelectedCellNameKey];
            if (isFirstCell) {
                
                isFirstCell = NO;
                [strAlertRecipients appendFormat:@" %@",strCellName];
            }
            else{
                
                [strAlertRecipients appendFormat:@", %@",strCellName];
                
            }
            
        }
        
        ///Append \n
        [strAlertRecipients appendString:@"\n"];
        
        
    }

    self.lblAlertRecipients.text = strAlertRecipients;
    ///Set additional text
    if (panicAlertSettings.strAdditionalNote.length > 0) {
        
        self.lblAdditionalNote.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Additional text: %@",nil),panicAlertSettings.strAdditionalNote];
 
    }
    else{
        
        self.lblAdditionalNote.text = nil;
    }
    
    if (panicAlertSettings.waitTime == PanicWaitTimeInstant) {
        
        ///Alert issued from soft button(i.e from app) and it's instant one or it's issued from panic button when app is in background, send it instantly without showing countdown
        [self handleCountdownExpiration];
        
    }
    else{
        ///get the saved
        self.waitTime = panicAlertSettings.waitTime;
        self.alertWaitTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(alertCountDownTimer:) userInfo:nil repeats:YES];
        
        ///Set countdown title and show it
        self.lblCountdown.text = [NSString stringWithFormat:@"%d",(int)self.waitTime];
        self.lblCountdown.hidden = NO;
        
        ///Set close button title as cancel and show it
        [self.btnClose setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        self.btnClose.hidden = NO;
        
        
    }
    
    
}

-(void)alertCountDownTimer:(NSTimer *)timer
{
    ///decrement wait time
    self.waitTime--;
    self.lblCountdown.text = [NSString localizedStringWithFormat:@"%d",(int)self.waitTime];

    if (self.waitTime == 0) {
        
        ///stop timer
        [self.alertWaitTimer invalidate];
        self.alertWaitTimer = nil;
        
        
        ///handle timer completion
        [self handleCountdownExpiration];
        
    }
    
}

-(void)handleCountdownExpiration
{
    ///hide timer text
    self.lblCountdown.hidden = YES;
    
    ///Post notification to send alert
    NSDictionary *dictUserInfo = @{kPanicOrFallenAlertTypeKey:@(self.alertType)};
    [[NSNotificationCenter defaultCenter]postNotificationName:kSendPanicOrFallenAlertNotifocation object:nil userInfo:dictUserInfo];
    
    
    ///Add google map
    CLLocationCoordinate2D locCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
    [self addGoogleMapWithAlertCoordinate:locCoordinate andMarkerTitle:NSLocalizedString(@"You are here", nil)];
    
    ///show it
    self.vuMapPlaceholderBase.hidden = NO;
    
    ///Get user location
    [self updateLocationUsingCoordinate:locCoordinate];
    
    ///show close button and set title as close
    [self.btnClose setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    self.btnClose.hidden = NO;
    
}

-(void)addGoogleMapWithAlertCoordinate:(CLLocationCoordinate2D)alertCoordinate andMarkerTitle:(NSString *)strMarkerTitle
{
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:alertCoordinate.latitude longitude:alertCoordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //self.mapView.mapType = kGMSTypeHybrid;
    
    float hPadding = 16;
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.bounds.size.width - 2 * hPadding;
    self.mapView.frame = mapFrame;
    [self.vuMapPlaceholder addSubview:self.mapView];
    [self.vuMapPlaceholder sendSubviewToBack:self.mapView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ///update map frame to get the correct frame values
        //[self updateMapFrame];
    });
    
    ///Add the marker to it and display title by default
    GMSMarker *alertMarker = [[GMSMarker alloc]init];
    alertMarker.position = alertCoordinate;
    alertMarker.title = strMarkerTitle;
    alertMarker.map = self.mapView;
    alertMarker.icon = [UIImage imageNamed:MAP_MARKER_ICON_NAME];
    self.mapView.selectedMarker = alertMarker;
    
    [self.mapView animateToLocation:alertCoordinate];
    [self updateMapStyle];
    
}

-(void)updateMapFrame
{
    float hPadding = 16;
    CGRect mapFrame = self.vuMapPlaceholder.bounds;
    mapFrame.origin = CGPointMake(0, 0);
    mapFrame.size.width = self.bounds.size.width - 2 * hPadding;
    self.mapView.frame = mapFrame;
    
}

-(void)updateLocationUsingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    GMSGeocoder *geoCoder = [GMSGeocoder geocoder];
    __weak typeof(self) weakSelf = self;
    [geoCoder reverseGeocodeCoordinate:locCoordinate completionHandler:^(GMSReverseGeocodeResponse * _Nullable geoCodeResponse, NSError * _Nullable error) {
        
        if (!error && geoCodeResponse) {
            //NSLog(@"#Succeed: resp= %@\nerr=%@",geoCodeResponse,error);
            
            ///Get first available address
            GMSAddress *firstAddress = [geoCodeResponse firstResult];
            
            if (!firstAddress && ([geoCodeResponse results].count > 0)) {
                ///Additional handling to fallback to get address from array if in any case first result gives nil
                firstAddress = [[geoCodeResponse results]firstObject];
                
            }
            
            if(firstAddress){
                
                weakSelf.vuUserLocationBase.hidden = NO;
                weakSelf.lblUserCity.text = firstAddress.locality;
            }
            else{
                
                //weakSelf.lblUserCity.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        else{
            
            NSLog(@"#Failed: resp= %@\nerr=%@",geoCodeResponse,error);
        }
        
        
    }];
    
    /*
    ///cancel previous request
    [self.getLocationTask cancel];
    self.getLocationTask = nil;
    
    ///make a new request
    NSString *strLatLong = [NSString stringWithFormat:@"%f,%f",locCoordinate.latitude,locCoordinate.longitude];
    __weak typeof(self) weakSelf = self;
    
    self.getLocationTask = [ServerUtility getAddressForCoordinate:strLatLong andCompletion:^(NSError *error, id data) {
        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
        
        if (!error && data) {
            
            NSArray *results=[data objectForKey:kGeocodeResultsKey];
            
            if([results count]>0){
                
                NSDictionary *address=[results firstObject];
                NSArray *addcomponents=[address objectForKey:kGeocodeAddressComponentsKey];
                
                weakSelf.vuUserLocationBase.hidden = NO;
                weakSelf.lblUserCity.text = [C411StaticHelper getAddressCompFromResult:addcomponents forType:kGeocodeTypeLocality useLongName:YES];
            }
            else{
                
                //weakSelf.lblAlertLocation.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        
    }];
     */
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

-(IBAction)btnCloseTapped:(id)sender{
    
    if (self.alertWaitTimer) {
        ///stop the timer
        [self.alertWaitTimer invalidate];
        self.alertWaitTimer = nil;
    }
    [self removeFromSuperview];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
