//
//  C411LocationPickerVC.m
//  cell411
//
//  Created by Milan Agarwal on 14/10/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411LocationPickerVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411LocationPickerVC ()

@property (weak, nonatomic) IBOutlet UILabel *lblInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuLocationPicker;
@property (weak, nonatomic) IBOutlet UIButton *btnPickLocation;

- (IBAction)btnPickLocationTapped:(UIButton *)sender;

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, assign, getter=isFirstTime) BOOL firstTime;

@end

@implementation C411LocationPickerVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.firstTime = YES;
    [self configureViews];
    [self registerForNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isFirstTime) {
        
        self.firstTime = NO;
        [self addGoogleMap];
    }
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.mapView = nil;
    self.currentLocation = nil;
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
    self.title = NSLocalizedString(@"Pick Location", nil);
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)updateMapStyle {
    self.mapView.mapStyle = [GMSMapStyle styleWithContentsOfFileURL:[C411ColorHelper sharedInstance].mapStyleURL error:NULL];
}

-(void)applyColors {
    ///Update map style
    [self updateMapStyle];
    
    ///Set theme colors on buttons
    self.btnPickLocation.backgroundColor = [C411ColorHelper sharedInstance].themeColor;
    
    ///Set primaryBgText color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnPickLocation setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
}

-(void)addGoogleMap
{
    // Create a GMSCameraPosition that tells the map to display the coordinate  at zoom level 15.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.mapType = kGMSTypeHybrid;
    [self.mapView animateToLocation:self.currentLocation.coordinate];
    //self.view = self.mapView;
    self.mapView.frame = self.view.frame;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    [self updateMapStyle];
    ///bring subviews to front
    //[self.view addSubview:self.btnPickLocation];
//    [self.view bringSubviewToFront:self.lblInfo];
//    [self.view bringSubviewToFront:self.imgVuLocationPicker];
//    [self.view bringSubviewToFront:self.btnPickLocation];
    
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


//****************************************************
#pragma mark - Action Methods
//****************************************************
- (IBAction)btnPickLocationTapped:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    CLLocationCoordinate2D locCoord = weakSelf.mapView.camera.target;
    CLLocation *weakDispatchLocation = [[CLLocation alloc]initWithLatitude:locCoord.latitude longitude:locCoord.longitude];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (weakSelf.completionHandler != NULL) {
            ///call the completion handler and pass the location picked
            weakSelf.completionHandler(weakDispatchLocation);
            weakSelf.completionHandler = NULL;
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
