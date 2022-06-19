//
//  C411CreateMyPublicCellVC.m
//  cell411
//
//  Created by Milan Agarwal on 01/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411CreateMyPublicCellVC.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "C411LocationManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "C411ColorHelper.h"
//#import "ServerUtility.h"

@interface C411CreateMyPublicCellVC ()<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UITextViewDelegate,GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgVuCell;
@property (weak, nonatomic) IBOutlet UIView *vuCellNameIconBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCellIcon;
@property (weak, nonatomic) IBOutlet UITextField *txtCellName;
@property (weak, nonatomic) IBOutlet UIView *vuCellNameUnderline;
@property (weak, nonatomic) IBOutlet UIView *vuSelectCategoryIconBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuSelectCategoryIcon;
@property (weak, nonatomic) IBOutlet UITextField *txtSelectCategory;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCategory;
@property (weak, nonatomic) IBOutlet UIView *vuSelectCategoryUnderline;
@property (weak, nonatomic) IBOutlet UILabel *lblDescHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblCellDescPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *txtVuCellDesc;
@property (weak, nonatomic) IBOutlet UIView *vuDescUnderline;
@property (weak, nonatomic) IBOutlet UIView *vuCurrentLocationContainer;
@property (weak, nonatomic) IBOutlet UIView *vuLocationIconBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuLocationIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblCellLocation;
@property (strong, nonatomic) IBOutlet UIView *vuCategoryPickerBase;
@property (weak, nonatomic) IBOutlet UIView *vuMapPlaceholder;
@property (weak, nonatomic) IBOutlet UIPickerView *pckrCategory;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuLocationPointer;
- (IBAction)btnSelectCategoryTapped:(UIButton *)sender;
- (IBAction)barBtnCreateCellTapped:(UIBarButtonItem *)sender;
- (IBAction)barBtnSelectCategoryTapped:(UIBarButtonItem *)sender;

@property (nonatomic, assign, getter=isFirstTime) BOOL firstTime;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSArray *arrCategories;
@property (nonatomic, assign) PublicCellCategory selectedCategory;
//@property (nonatomic, strong) NSURLSessionDataTask *getLocationTask;
@property (nonatomic, strong) GMSAddress *cellAddress;

@end

@implementation C411CreateMyPublicCellVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.firstTime = YES;
    ///Try to get the array of owned public cells before hand.
    NSArray *arrTmpOwnedPublicCells = self.publicCellsDelegate.arrOwnedPublicCells;
    arrTmpOwnedPublicCells = nil;
    [self registerForNotifications];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isFirstTime) {
        
        [self configureViews];
        [self setupViews];
        
        ///Unhide the navigation bar
        self.navigationController.navigationBarHidden = NO;

    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isFirstTime) {
        
        self.firstTime = NO;
        ///add google map
        if (self.isInEditMode) {
            
            PFGeoPoint *cellLocationGeoPoint = self.publicCellObj[kPublicCellGeoTagKey];
            CLLocationCoordinate2D cellLocationCoordinate = CLLocationCoordinate2DMake(cellLocationGeoPoint.latitude, cellLocationGeoPoint.longitude);
            ///Add google map centered to cell location
            [self addGoogleMapWithAlertCoordinate:cellLocationCoordinate];

        }
        else{
            ///Add google map centered to current location by default
            [self addGoogleMapWithAlertCoordinate:[[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate];

        }
        

    }
}

-(void)dealloc
{
//    [self.getLocationTask cancel];
//    self.getLocationTask = nil;
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
#pragma mark - Property Initializers
//****************************************************

-(NSArray *)arrCategories
{
    if (!_arrCategories) {
        
//        _arrCategories = @[@"Activism",
//                           @"Journalism",
//                           @"Personal Safety",
//                           @"Community Safety",
//                           @"Government",
//                           @"Education",
//                           @"Commercial"
//                           ];
        
//        _arrCategories = @[
//                           @(PublicCellCategoryActivism),
//                           @(PublicCellCategoryCommercial),
//                           @(PublicCellCategoryCommunitySafety),
//                           @(PublicCellCategoryEducation),
//                           @(PublicCellCategoryGovernment),
//                           @(PublicCellCategoryJournalism),
//                           @(PublicCellCategoryPersonalSafety)
//                           ];
        _arrCategories = [C411StaticHelper getPublicCellCategoriesSortedByName];
    }
    
    return _arrCategories;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    if(self.isInEditMode){
        self.title = NSLocalizedString(@"Update Public Cell", nil);
    }
    else{
        self.title = NSLocalizedString(@"Create Public Cell", nil);
    }
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    ///configure cell image
    [C411StaticHelper makeCircularView:self.imgVuCell];
    [C411StaticHelper makeCircularView:self.vuCellNameIconBG];
    [C411StaticHelper makeCircularView:self.vuSelectCategoryIconBG];
    [C411StaticHelper makeCircularView:self.vuLocationIconBG];
    
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
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuCellNameIconBG.backgroundColor = themeColor;
    self.vuSelectCategoryIconBG.backgroundColor = themeColor;
    self.vuLocationIconBG.backgroundColor = themeColor;
    self.imgVuLocationPointer.tintColor = themeColor;
    
    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuCellNameUnderline.backgroundColor = separatorColor;
    self.vuSelectCategoryUnderline.backgroundColor = separatorColor;
    self.vuDescUnderline.backgroundColor = separatorColor;

    ///Set container title colors
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblDescHeading.textColor = primaryTextColor;
    self.txtCellName.textColor = primaryTextColor;
    self.txtSelectCategory.textColor = primaryTextColor;
    self.txtVuCellDesc.textColor = primaryTextColor;
    
    ///Set secondary color
    self.lblCellLocation.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    
    ///Set hint icon color on dropdown
    self.btnSelectCategory.tintColor = [C411ColorHelper sharedInstance].hintIconColor;

    ///Set disabled text color for placeholer text
    UIColor *disabledTextColor = [C411ColorHelper sharedInstance].disabledTextColor;
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtCellName];
    [C411StaticHelper setPlaceholderColor:disabledTextColor ofTextField:self.txtSelectCategory];
    self.lblCellDescPlaceholder.textColor = disabledTextColor;
    
    ///Set card color
    self.vuCurrentLocationContainer.backgroundColor = [C411ColorHelper sharedInstance].cardColor;

    ///Set primaryBgText color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.imgVuCellIcon.tintColor = primaryBGTextColor;
    self.imgVuSelectCategoryIcon.tintColor = primaryBGTextColor;
    self.imgVuLocationIcon.tintColor = primaryBGTextColor;

}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setupViews
{
    ///Make picker view as input view for category selection
    self.txtSelectCategory.inputView = self.vuCategoryPickerBase;
    self.pckrCategory.dataSource = self;
    self.pckrCategory.delegate = self;
    
    if (self.isInEditMode && self.publicCellObj) {
        
        ///set cell name
        self.txtCellName.text = self.publicCellObj[kPublicCellNameKey];
        
        ///set cell category
        self.selectedCategory = [C411StaticHelper getPublicCellCategoryFromPublicCell:self.publicCellObj];
        self.txtSelectCategory.text = [C411StaticHelper getLocalizedPublicCellCategory:self.selectedCategory];

        NSInteger categroyIndex = [self.arrCategories indexOfObject:@(self.selectedCategory)];
        if (categroyIndex != NSNotFound) {
            
            [self.pckrCategory selectRow:categroyIndex inComponent:0 animated:NO];

        }

        ///set cell description
        NSString *strCellDesc = self.publicCellObj[kPublicCellDescriptionKey];
        
        if (strCellDesc.length > 0) {
            
            self.txtVuCellDesc.text = strCellDesc;
            self.lblCellDescPlaceholder.hidden = YES;

        }
        
    }
    
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


-(void)updateLocationUsingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    ///Reset address
    self.lblCellLocation.text = NSLocalizedString(@"Retrieving...", nil);
    self.cellAddress = nil;

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
                
                weakSelf.lblCellLocation.text = firstAddress.locality;
                weakSelf.cellAddress = firstAddress;
            }
            else{
                
                weakSelf.lblCellLocation.text = NSLocalizedString(@"N/A", nil);
                weakSelf.cellAddress = nil;
            }
            
        }
        else{
            
            NSLog(@"#Failed: resp= %@\nerr=%@",geoCodeResponse,error);
        }
        
        
    }];

/*
    NSLog(@"%s",__PRETTY_FUNCTION__);
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
                
                weakSelf.lblCellLocation.text = [C411StaticHelper getAddressCompFromResult:addcomponents forType:kGeocodeTypeLocality useLongName:YES];
            }
            else{
                
                weakSelf.lblCellLocation.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        
    }];
 */
    
    
}

//****************************************************
#pragma mark - UIPickerViewDataSource Methods
//****************************************************

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrCategories.count;
}


//****************************************************
#pragma mark - UIPickerViewDelegate Methods
//****************************************************

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        
        PublicCellCategory category = (PublicCellCategory)[self.arrCategories[row] integerValue];
        return [C411StaticHelper getLocalizedPublicCellCategory:category];
    }
    
    return nil;
}

//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnSelectCategoryTapped:(UIButton *)sender {
    
    if (!self.txtSelectCategory.isFirstResponder) {
        [self.txtSelectCategory becomeFirstResponder];
    }
}

- (IBAction)barBtnCreateCellTapped:(UIBarButtonItem *)sender {
    
    NSString *strCellName = self.txtCellName.text;
    ///trim the cell name
    strCellName = [strCellName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *strCellDesc = self.txtVuCellDesc.text;
    ///trim the cell description
    strCellDesc = [strCellDesc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    ///1.Check if cell name is empty
    if (strCellName.length == 0) {
        
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Please enter Cell name", nil) onViewController:self];
        return;
        
    }
    
    if (self.selectedCategory == PublicCellCategoryUnrecognized) {
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Please choose a category", nil) onViewController:self];
        return;
    }
    
    if (strCellDesc.length == 0) {
        
        [C411StaticHelper showAlertWithTitle:nil message:NSLocalizedString(@"Please give a brief description for your Cell", nil) onViewController:self];
        return;
        
        
    }
    
    [self.view endEditing:YES];
    
    ///Get the locCoord currently set
    CLLocationCoordinate2D locCoord = self.mapView.camera.target;
    BOOL isNameChanged = NO;
    BOOL isCategoryChanged = NO;
    BOOL isDescriptionChanged = NO;
    BOOL isLocationChanged = NO;
    NSString *strOldCellName = self.publicCellObj[kPublicCellNameKey];
    
    if (self.isInEditMode) {
        
        ///Check if cell name is updated or not
        if (![strCellName isEqualToString:strOldCellName]) {
            ///Cell name is changed
            isNameChanged = YES;
        }
        
        ///Check if cell category is updated or not
        PublicCellCategory oldCategory = [C411StaticHelper getPublicCellCategoryFromPublicCell:self.publicCellObj];
        if (self.selectedCategory != oldCategory) {
            ///Cell category is changed
            isCategoryChanged = YES;
        }
        
        ///Check if cell description is updated or not
        if (![strCellDesc isEqualToString:self.publicCellObj[kPublicCellDescriptionKey]]) {
            ///Cell description is changed
            isDescriptionChanged = YES;
        }
        
        ///Check if cell location is updated or not
        PFGeoPoint *cellOldLocationGeoPoint = self.publicCellObj[kPublicCellGeoTagKey];
        PFGeoPoint *cellCurrentLocGeoPoint = [PFGeoPoint geoPointWithLatitude:locCoord.latitude longitude:locCoord.longitude];
        double distanceDiffInMeters = [cellOldLocationGeoPoint distanceInKilometersTo:cellCurrentLocGeoPoint] * 1000; //1KM = 1000 Meters
        int ingorableDiffInMeters = 100;///slight change in location to about 100 meters will be ignored to overcome precision errors.
        NSString *strCity = self.publicCellObj[kPublicCellCityKey];
        if ((distanceDiffInMeters > ingorableDiffInMeters)
            || (strCity.length > 0
                && self.cellAddress
                && (![self.cellAddress.locality isEqualToString:strCity]))) {
            
            ///Cell location is changed
            isLocationChanged = YES;
        }
        
    
        ///show toast if nothing is updated and return
        if (!(isNameChanged || isCategoryChanged
              || isDescriptionChanged || isLocationChanged)) {
            
            ///Nothing is updated
            [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Nothing to update", nil)];
            
            return;
        }
        
        
    }
    
    
    ///2.Check if this cell is already added or not
    for (PFObject *myPublicCell in self.publicCellsDelegate.arrOwnedPublicCells) {
        if(self.isInEditMode && [myPublicCell.objectId isEqualToString:self.publicCellObj.objectId]){
            ///Skip checking for name of the same cell if current user is editing that cell
            continue;
        }
        else if ([myPublicCell[kPublicCellNameKey] isEqualToString:strCellName]) {
            
            ///cell exist with this name
            NSString *strMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ already exists",nil),strCellName];
            [C411StaticHelper showAlertWithTitle:nil message:strMessage onViewController:self];
            
            return;
            
        }
        
    }
    
    ///Create weak reference of self
    __weak typeof(self) weakSelf = self;
    if (self.isInEditMode) {
        
        ///Update Cell object
        if (isNameChanged) {
            
            ///update the name of cell
            self.publicCellObj[kPublicCellNameKey] = strCellName;
            
        }
        
        if (isCategoryChanged) {
            
            ///update the category of cell
            //self.publicCellObj[kPublicCellCategoryKey] = self.txtSelectCategory.text;
            self.publicCellObj[kPublicCellTypeKey] = @(self.selectedCategory);
            
        }

        if (isDescriptionChanged) {
            
            ///update the description of cell
            self.publicCellObj[kPublicCellDescriptionKey] = strCellDesc;
            
        }
        
        if (isLocationChanged) {
            
            ///update the location of cell
            PFGeoPoint *cellGeoPoint = [PFGeoPoint geoPointWithLatitude:locCoord.latitude longitude:locCoord.longitude];
            self.publicCellObj[kPublicCellGeoTagKey] = cellGeoPoint;
            self.publicCellObj[kPublicCellCityKey] = self.cellAddress.locality;
            self.publicCellObj[kPublicCellCountryKey] = self.cellAddress.country;
            self.publicCellObj[kPublicCellFullAddressKey] = [self.cellAddress.lines componentsJoinedByString:@", "];
        }
        
        ///Save it in background
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        ///Make a intimation details dictionary
        NSMutableDictionary *dictChngIntimationDetails = [NSMutableDictionary dictionary];
        dictChngIntimationDetails[kChgIntmnToPubCellMembersFuncParamPubCellObjectIdKey] = self.publicCellObj.objectId;
        dictChngIntimationDetails[kChgIntmnToPubCellMembersFuncParamPubCellNameKey] = strOldCellName;
        dictChngIntimationDetails[kChgIntmnToPubCellMembersFuncParamIsNameChangedKey] = @(isNameChanged);
        dictChngIntimationDetails[kChgIntmnToPubCellMembersFuncParamIsCategoryChangedKey] = @(isCategoryChanged);
        dictChngIntimationDetails[kChgIntmnToPubCellMembersFuncParamIsDescChangedKey] = @(isDescriptionChanged);
        dictChngIntimationDetails[kChgIntmnToPubCellMembersFuncParamIsLocChnagedKey] = @(isLocationChanged);
        
        
        [self.publicCellObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            if (error) {
                
                ///Save it eventually
                [weakSelf.publicCellObj saveEventually];
                
            }
            
            ///Post notification that cell is updated
            [[NSNotificationCenter defaultCenter]postNotificationName:kPublicCellUpdatedNotification object:nil];
            
            
            ///show toast
            [AppDelegate showToastOnView:[AppDelegate sharedInstance].window.rootViewController.view withMessage:NSLocalizedString(@"Cell updated successfully", nil)];
            
            ///Call public cell intimation cloud function to intimate all members of this cell for this change
            [C411StaticHelper sendChangeIntimationToPublicCellMembersWithDetails:dictChngIntimationDetails andCompletion:NULL];
            
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                ///remove the view controller after 3 sec
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            //});

            
            

            
        }];


    }
    else{
    
        ///Create a Cell object
        PFObject *myPublicCell = [PFObject objectWithClassName:kPublicCellClassNameKey];
        PFUser *currentUser = [AppDelegate getLoggedInUser];
        myPublicCell[kPublicCellCreatedByKey] = currentUser;
        myPublicCell[kPublicCellNameKey] = strCellName;
        myPublicCell[kPublicCellTotalMembersKey] = @1;
        PFRelation *membersRelation = [myPublicCell relationForKey:kPublicCellMembersKey];
        [membersRelation addObject:[AppDelegate getLoggedInUser]];
/*OLD implementation of verification request handling
        myPublicCell[kPublicCellIsVerifiedKey] = @0;
*/
        myPublicCell[kPublicCellVerificationStatusKey] = @(CellVerificationStatusUnsolicited);
        PFGeoPoint *cellGeoPoint = [PFGeoPoint geoPointWithLatitude:locCoord.latitude longitude:locCoord.longitude];
        myPublicCell[kPublicCellGeoTagKey] = cellGeoPoint;
        if(self.cellAddress){
            myPublicCell[kPublicCellCityKey] = self.cellAddress.locality;
            myPublicCell[kPublicCellCountryKey] = self.cellAddress.country;
            myPublicCell[kPublicCellFullAddressKey] = [self.cellAddress.lines componentsJoinedByString:@", "];
        }
        //myPublicCell[kPublicCellCategoryKey] = self.txtSelectCategory.text;
        myPublicCell[kPublicCellDescriptionKey] = strCellDesc;
        myPublicCell[kPublicCellTypeKey] = @(self.selectedCategory);
        
        ///Save it in background
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [myPublicCell saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            if (succeeded) {
                
                ///1.Add this cell to array which will post notification when added to the cells list
                [weakSelf.publicCellsDelegate addOwnedPublicCell:myPublicCell];
                ///Reset selected category
                weakSelf.selectedCategory = PublicCellCategoryUnrecognized;
                
                ///Clear text field
                weakSelf.txtCellName.text = nil;
                weakSelf.txtVuCellDesc.text = nil;
                weakSelf.lblCellDescPlaceholder.hidden = NO;
                weakSelf.txtSelectCategory.text = nil;
                
                ///show toast
                [AppDelegate showToastOnView:weakSelf.view withMessage:NSLocalizedString(@"Cell added successfully", nil)];
                
                ///Send alert to all patrolling users within 50 miles
                ///Create Payload data
                NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
                NSString *strAlertMsg = [NSString stringWithFormat:@"%@ %@ %@",NSLocalizedString(@"A new Public Cell called", nil),strCellName,NSLocalizedString(@"has just been created in your area.", nil)];
                
                dictData[kPayloadAlertKey] = strAlertMsg;
                dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeNewPublicCell;
                dictData[kPayloadUserIdKey] = currentUser.objectId;
                dictData[kPayloadCellIdKey] = myPublicCell.objectId;
                dictData[kPayloadCellNameKey] = strCellName;
                
                dictData[kPayloadSoundKey] = @"default";///To play default sound
                dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
                
                
                
                // Create our Installation query
                PFQuery *pushQuery = [PFInstallation query];
                PFQuery *fetchGloablUsersInnerQuery = [PFUser query];
                [fetchGloablUsersInnerQuery whereKey:kUserNewPublicCellAlertKey equalTo:NEW_PUBLIC_CELL_ALERT_VALUE_ON];
                [fetchGloablUsersInnerQuery whereKey:kUserLocationKey nearGeoPoint:cellGeoPoint withinMiles:50];
                [fetchGloablUsersInnerQuery whereKey:@"objectId" notEqualTo:currentUser.objectId];
                [pushQuery whereKey:kInstallationUserKey matchesQuery:fetchGloablUsersInnerQuery];
                
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                [push setData:dictData];
                ///Send Push notification
                [push sendPushInBackground];
                
                
                
            }
            else{
                
                if (error) {
                    if(![AppDelegate handleParseError:error]){
                        ///show error
                        NSString *errorString = [error userInfo][@"error"];
                        [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:weakSelf];
                    }
                }
                
            }
            
            
        }];

    }

}

- (IBAction)barBtnSelectCategoryTapped:(UIBarButtonItem *)sender {
    
    NSInteger selectedRow = [self.pckrCategory selectedRowInComponent:0];
    self.selectedCategory = (PublicCellCategory)[self.arrCategories[selectedRow] integerValue];
    self.txtSelectCategory.text = [C411StaticHelper getLocalizedPublicCellCategory:self.selectedCategory];
    [self.txtSelectCategory resignFirstResponder];

    
    
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
#pragma mark - UITextViewDelegate Methods
//****************************************************

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *finalString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    ///Toggle Place holder visibility
    if (finalString && finalString.length > 0) {
        ///Hide Placeholder string
        if (textView == self.txtVuCellDesc) {
            
            self.lblCellDescPlaceholder.hidden = YES;
            
        }
        
    }
    else{
        ///Show Placeholder string
        if (textView == self.txtVuCellDesc) {
            
            self.lblCellDescPlaceholder.hidden = NO;
            
        }
    }
    
    return YES;
    
}


//****************************************************
#pragma mark - GMSMapViewDelegate Methods
//****************************************************

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)position
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    CLLocationCoordinate2D locCoord = mapView.camera.target;
    [self updateLocationUsingCoordinate:locCoord];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
