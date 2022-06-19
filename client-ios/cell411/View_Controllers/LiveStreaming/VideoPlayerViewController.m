//
//  VideoPlayerViewController.m
//  SDKSampleApp
//
//  This code and all components (c) Copyright 2015-2016, Wowza Media Systems, LLC. All rights reserved.
//  This code is licensed pursuant to the BSD 3-Clause License.
//


#import <WowzaGoCoderSDK/WowzaGoCoderSDK.h>

#import "VideoPlayerViewController.h"
#import "SettingsViewModel.h"
#import "SettingsViewController.h"
#import "MP4Writer.h"
#import "AppDelegate.h"
#import "ConfigConstants.h"
#import "Constants.h"
#import "C411StaticHelper.h"
#import "ServerUtility.h"
#import "C411LocationManager.h"
#import "C411AppDefaults.h"
#import <MBProgressHUD/MBProgressHUD.h>

#if VIDEO_STREAMING_ENABLED
///Include the keys in binary only if video streaming is enabled

#define WZA_USER_NAME   @"cell411"
#define WZA_PWD    @"p6Gbei9zQhohdK"

#pragma mark VideoPlayerViewController (GoCoder SDK Sample App) -

static NSString *const SDKSampleSavedConfigKey = @"SDKSampleSavedConfigKey";
//static NSString *const SDKSampleAppLicenseKey = @"GSDK-CA41-0001-E32F-0CF1-93EC";
//static NSString *const SDKSampleAppLicenseKey = @"GSDK-5442-0003-5E92-A59A-8C20";
//static NSString *const SDKSampleAppLicenseKey = @"GSDK-2B42-0000-D810-EAED-34DB";
#endif

@interface VideoPlayerViewController () <WZStatusCallback, WZVideoSink, WZAudioSink, WZVideoEncoderSink, WZAudioEncoderSink>

#pragma mark - UI Elements
@property (nonatomic, weak) IBOutlet UIButton   *broadcastButton;
@property (nonatomic, weak) IBOutlet UIButton   *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton   *switchCameraButton;
@property (nonatomic, weak) IBOutlet UIButton   *torchButton;
@property (nonatomic, weak) IBOutlet UIButton   *micButton;
- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender;

#pragma mark - GoCoder SDK Components
@property (nonatomic, strong) WowzaGoCoder      *goCoder;
@property (nonatomic, strong) WowzaConfig       *goCoderConfig;
@property (nonatomic, strong) WZCameraPreview   *goCoderCameraPreview;

#pragma mark - Data
//@property (nonatomic, strong) NSMutableArray    *receivedGoCoderEventCodes;
@property (nonatomic, assign) BOOL              blackAndWhiteVideoEffect;
@property (nonatomic, assign) BOOL              recordVideoLocally;

#pragma mark - MP4Writing
@property (nonatomic, strong) MP4Writer         *mp4Writer;
@property (nonatomic, assign) BOOL              writeMP4;
@property (nonatomic, strong) dispatch_queue_t  video_capture_queue;


@property (nonatomic, assign,getter=isFirstTime) BOOL firstTime;


@end

#pragma mark -
@implementation VideoPlayerViewController

#if VIDEO_STREAMING_ENABLED
///Include this class implementation in binary only if video streaming is enabled

#pragma mark - UIViewController Protocol Instance Methods

- (void) viewDidLoad {
    [super viewDidLoad];
    
    ///show toast that video streaming is about to be started
    [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Video streaming starting...", nil)];

    ///hide the settings button
    self.settingsButton.hidden = YES;
    self.firstTime = YES;
    self.blackAndWhiteVideoEffect = [[NSUserDefaults standardUserDefaults] boolForKey:BlackAndWhiteKey];
    self.recordVideoLocally = [[NSUserDefaults standardUserDefaults] boolForKey:kRecordVideoLocally];
    
//    self.receivedGoCoderEventCodes = [NSMutableArray new];
    
    [WowzaGoCoder setLogLevel:WowzaGoCoderLogLevelDefault];
    
    // Load or initialization the streaming configuration settings
    NSData *savedConfig = [[NSUserDefaults standardUserDefaults] objectForKey:SDKSampleSavedConfigKey];
    if (savedConfig) {
        self.goCoderConfig = [NSKeyedUnarchiver unarchiveObjectWithData:savedConfig];
    }
    else {
        self.goCoderConfig = [WowzaConfig new];
        self.goCoderConfig.applicationName = WZA_APP_NAME;
        self.goCoderConfig.hostAddress = CNAME;
        self.goCoderConfig.username = WZA_USER_NAME;
        self.goCoderConfig.password = WZA_PWD;
        self.goCoderConfig.backgroundBroadcastEnabled = YES;
        
        ///set video resolution
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *strVideoResolution = [defaults objectForKey:kVideoStreamingResolution];
        CGSize videoSize = [C411AppDefaults getVideoSizeForResolution:strVideoResolution];
        self.goCoderConfig.videoWidth = videoSize.width;
        self.goCoderConfig.videoHeight = videoSize.height;

    }
        
    NSLog (@"WowzaGoCoderSDK version =\n major:%lu\n minor:%lu\n revision:%lu\n build:%lu\n short string: %@\n verbose string: %@",
           (unsigned long)[WZVersionInfo majorVersion],
           (unsigned long)[WZVersionInfo minorVersion],
           (unsigned long)[WZVersionInfo revision],
           (unsigned long)[WZVersionInfo buildNumber],
           [WZVersionInfo string],
           [WZVersionInfo verboseString]);
    
    NSLog (@"%@", [WZPlatformInfo string]);
    
    self.goCoder = nil;
    [self registerForNotifications];

}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.goCoder.cameraPreview.previewLayer.frame = self.view.bounds;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;

    [AppDelegate sharedInstance].shouldRotate = YES;
    [[UIDevice currentDevice]setOrientation:UIInterfaceOrientationLandscapeRight];
    if (self.isFirstTime) {
        
        self.firstTime = NO;
        
        // Register the GoCoder SDK license key
        NSError *goCoderLicensingError = [WowzaGoCoder registerLicenseKey:WZA_LICENSE_KEY];
        if (goCoderLicensingError != nil) {
            // Handle license key registration failure
            [self showAlertWithTitle:@"Streaming SDK Licensing Error" error:goCoderLicensingError];
        }
        else {
            ///set the stream name
            self.goCoderConfig.streamName = self.strStreamName;
            
            // Initialize the GoCoder SDK
            self.goCoder = [WowzaGoCoder sharedInstance];
            
            // Specify the view in which to display the camera preview
            if (self.goCoder != nil) {
                
                // Request camera and microphone permissions
                [WowzaGoCoder requestPermissionForType:WowzaGoCoderPermissionTypeCamera response:^(WowzaGoCoderCapturePermission permission) {
                    NSLog(@"Camera permission is: %@", permission == WowzaGoCoderCapturePermissionAuthorized ? @"authorized" : @"denied");
                }];
                
                [WowzaGoCoder requestPermissionForType:WowzaGoCoderPermissionTypeMicrophone response:^(WowzaGoCoderCapturePermission permission) {
                    NSLog(@"Microphone permission is: %@", permission == WowzaGoCoderCapturePermissionAuthorized ? @"authorized" : @"denied");
                }];
                
                [self.goCoder registerVideoSink:self];
                [self.goCoder registerAudioSink:self];
                [self.goCoder registerVideoEncoderSink:self];
                [self.goCoder registerAudioEncoderSink:self];
                
                self.goCoder.config = self.goCoderConfig;
                self.goCoder.cameraView = self.view;
                
                // Start the camera preview
                self.goCoderCameraPreview = self.goCoder.cameraPreview;
                [self.goCoderCameraPreview startPreview];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults boolForKey:kStreamVideoOnFBPage]||[defaults boolForKey:kStreamVideoOnCell411YTChannel]||[defaults boolForKey:kStreamVideoOnUserYTChannel]
                    //||([defaults boolForKey:kStreamVideoOnFBWall] && [FBSDKAccessToken currentAccessToken])
                    ){
                    
                    __weak typeof(self) weakSelf = self;
                    ///make an API call to fblive script first and then start streaming
                    ///1. Make a dictionary of params
                    PFUser *currentUser = [AppDelegate getLoggedInUser];
                    NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
                   NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
                    dictParams[kStreamVideoToSocialMediaParamName] = strFullName;
                    dictParams[kStreamVideoToSocialMediaParamStreamName] = self.strStreamName;
                    dictParams[kStreamVideoToSocialMediaParamUser] = currentUser.objectId;
                    
                    ///Stream video to FB page if enabled
                    if ([defaults boolForKey:kStreamVideoOnFBPage]) {
                        
                        dictParams[kStreamVideoToSocialMediaParamFBPage] = @"yes";
                        
                    }
                    
                    ///Stream video to Cell 411 Youtube channel if enabled
                    if ([defaults boolForKey:kStreamVideoOnCell411YTChannel]) {
                        
                        dictParams[kStreamVideoToSocialMediaParamYTCell411] = @"yes";
                        
                    }
                    
                    ///Stream video to User's live Youtube channel if enabled
                    if ([defaults boolForKey:kStreamVideoOnUserYTChannel]) {
                        NSString *strStreamName = [defaults objectForKey:kUserLiveYTChannelStreamName];
                        NSString *strServerUrl = [defaults objectForKey:kUserLiveYTChannelServerUrl];
                        ///extract rtmp:// if exist as a suffix
                        NSString *strInvalidSuffix = @"rtmp://";
                        if ([strServerUrl hasSuffix:strInvalidSuffix]) {
                            strServerUrl = [strServerUrl substringFromIndex:strInvalidSuffix.length];
                        }
                        NSString *strHostName = [strServerUrl stringByDeletingLastPathComponent];
                        NSString *strAppName = [strServerUrl lastPathComponent];
                        if (strStreamName.length > 0 && strHostName.length > 0 && strAppName.length > 0) {
                            dictParams[kStreamVideoToSocialMediaParamUserYT] = @"yes";
                            dictParams[kStreamVideoToSocialMediaParamUserYTKey] = strStreamName;
                            dictParams[kStreamVideoToSocialMediaParamUserYTHost] = strHostName;
                            dictParams[kStreamVideoToSocialMediaParamUserYTApp] = strAppName;
                            
                        }
                        
                    }
 /*
                    ///Stream video to user's fb wall if enabled
                    if ([defaults boolForKey:kStreamVideoOnFBWall] && [FBSDKAccessToken currentAccessToken]) {
                        
                        dictParams[kStreamVideoToSocialMediaParamFBWall] = @"yes";
                        dictParams[kStreamVideoToSocialMediaParamFBToken] = [FBSDKAccessToken currentAccessToken].tokenString;
                        dictParams[kStreamVideoToSocialMediaParamFBDestination] = [FBSDKAccessToken currentAccessToken].userID;
                        

                    }
 */
                    
                    CLLocationCoordinate2D locCoordinate = [[C411LocationManager sharedInstance] getCurrentLocationWithFallbackToOtherAvailableLocation:YES].coordinate;
                    ///2. Disable the onscreen controls
                    [self disableOnscreenControls];

                    ///3.Make an API call to get city and country
//                    NSString *strLatLong = [NSString stringWithFormat:@"%f,%f",locCoordinate.latitude,locCoordinate.longitude];
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

                    GMSGeocoder *geoCoder = [GMSGeocoder geocoder];
                    [geoCoder reverseGeocodeCoordinate:locCoordinate completionHandler:^(GMSReverseGeocodeResponse * _Nullable geoCodeResponse, NSError * _Nullable error) {
                        
                        NSString *strCity = @"";
                        NSString *strCountry = @"";
                        if (!error && geoCodeResponse) {
                            //NSLog(@"#Succeed: resp= %@\nerr=%@",geoCodeResponse,error);
                            
                            ///Get first available address
                            GMSAddress *firstAddress = [geoCodeResponse firstResult];
                            
                            if (!firstAddress && ([geoCodeResponse results].count > 0)) {
                                ///Additional handling to fallback to get address from array if in any case first result gives nil
                                firstAddress = [[geoCodeResponse results]firstObject];
                                
                            }
                            
                            if(firstAddress){
                                
                                strCity = firstAddress.locality;
                                strCountry = firstAddress.country;
                            }
                            
                        }
                        else{
                            
                            NSLog(@"#Failed: resp= %@\nerr=%@",geoCodeResponse,error);
                        }
                    
                    /*
                    [ServerUtility getAddressForCoordinate:strLatLong andCompletion:^(NSError *error, id data) {
                        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
                        NSString *strCity = @"";
                        NSString *strCountry = @"";
                        
                        if (!error && data) {
                            
                            NSArray *results=[data objectForKey:kGeocodeResultsKey];
                            
                            if([results count]>0){
                                
                                NSDictionary *address=[results firstObject];
                                NSArray *addcomponents=[address objectForKey:kGeocodeAddressComponentsKey];
                                
                                strCity = [C411StaticHelper getAddressCompFromResult:addcomponents forType:kGeocodeTypeLocality useLongName:YES];
                                strCountry = [C411StaticHelper getAddressCompFromResult:addcomponents forType:kGeocodeTypeCountry useLongName:YES];
                            }
                            else{
                                
                                NSLog(@"Error doing reverse geocoding: %@", error.localizedDescription);
                                
                            }
                            
                        }
                        */
                        dictParams[kStreamVideoToSocialMediaParamCity] = strCity;
                        dictParams[kStreamVideoToSocialMediaParamCountry] = strCountry;
                        
                        ///4.Make an API call to publish live video on FB
                        
                        [ServerUtility streamVideoToFBPageWithDetails:dictParams andCompletion:^(NSError *error, id data) {
                            
                            if (error) {
                                
                                ///Log the error
                                NSLog(@"#Error making fblive call:%@",error.localizedDescription);
                            }
                            
                            ///5. Enable the controls
                            [weakSelf enableOnscreenControls];
                            
                            ///6. start streaming
                            [weakSelf didTapBroadcastButton:weakSelf.broadcastButton];
                            
                            ///7. Remove progress hud
                            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                            
                        }];

                    }];
                    
                    
                }
                else{
                    
                    ///Start streaming
                    [self didTapBroadcastButton:self.broadcastButton];

                }

            }
            
            // Update the UI controls
            [self updateUIControls];
        }

        
    }

    NSData *savedConfigData = [NSKeyedArchiver archivedDataWithRootObject:self.goCoderConfig];
    [[NSUserDefaults standardUserDefaults] setObject:savedConfigData forKey:SDKSampleSavedConfigKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Update the configuration settings in the GoCoder SDK
    if (self.goCoder != nil)
        self.goCoder.config = self.goCoderConfig;
    
    self.blackAndWhiteVideoEffect = [[NSUserDefaults standardUserDefaults] boolForKey:BlackAndWhiteKey];
    self.recordVideoLocally = [[NSUserDefaults standardUserDefaults] boolForKey:kRecordVideoLocally];

}


-(void)viewWillDisappear:(BOOL)animated
{
    
    [AppDelegate sharedInstance].shouldRotate = NO;
    
    [[UIDevice currentDevice]setOrientation:UIInterfaceOrientationLandscapeRight]; ///This is a hack as without this should autorotate method is not getting called by iOS
    
    [[UIDevice currentDevice]setOrientation:UIInterfaceOrientationPortrait];
    
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

-(void)dealloc
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self unregisterFromNotifications];
}

-(void)cleanUp
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

    if (self.goCoder.status.state == WZStateRunning) {
        [self.goCoder endStreaming:self];
        NSLog(@"ending stream");
    }
    [self.goCoder unregisterVideoSink:self];
    [self.goCoder unregisterAudioSink:self];
    [self.goCoder unregisterVideoEncoderSink:self];
    [self.goCoder unregisterAudioEncoderSink:self];
    
//    self.goCoder.config = nil;
    self.goCoder.cameraView = nil;
    self.goCoder = nil;
    self.goCoderConfig = nil;
    self.goCoderCameraPreview = nil;
    self.delegate = nil;
    self.strStreamName = nil;

}

-(void)disableOnscreenControls
{
    self.broadcastButton.enabled    = NO;
    self.torchButton.enabled        = NO;
    self.switchCameraButton.enabled = NO;
    self.settingsButton.enabled     = NO;
    
}

-(void)enableOnscreenControls
{
    self.broadcastButton.enabled    = YES;
    self.torchButton.enabled        = YES;
    self.switchCameraButton.enabled = YES;
    self.settingsButton.enabled     = YES;

}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];

}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - UI Action Methods

- (IBAction) didTapBroadcastButton:(id)sender {

    // Ensure the minimum set of configuration settings have been specified necessary to
    // initiate a broadcast streaming session
    NSError *configError = [self.goCoder.config validateForBroadcast];
    if (configError != nil) {
        [self showAlertWithTitle:@"Incomplete Streaming Settings" error:configError];
        return;
    }
    
    // Disable the U/I controls
    dispatch_async(dispatch_get_main_queue(), ^{
        self.broadcastButton.enabled    = NO;
        self.torchButton.enabled        = NO;
        self.switchCameraButton.enabled = NO;
        self.settingsButton.enabled     = NO;
    });
    
    if (self.goCoder.status.state == WZStateRunning) {
        
        ///show toast that video streaming is about to be stopped
        [AppDelegate showToastOnView:self.view withMessage:NSLocalizedString(@"Video streaming stopping...", nil)];

        [self.goCoder endStreaming:self];
        ///go back
        [self.delegate videoBroadcastingVCDidClosed:self];
        [self cleanUp];
        [self.navigationController popViewControllerAnimated:YES];

    }
    else {
//        [self.receivedGoCoderEventCodes removeAllObjects];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self.goCoder startStreaming:self];
            [self.micButton setImage:[UIImage imageNamed:(self.goCoder.isAudioMuted ? @"mic_off_button" : @"mic_on_button")] forState:UIControlStateNormal];
        });
    }
}

- (IBAction) didTapSwitchCameraButton:(id)sender {
    WZCamera *otherCamera = [self.goCoderCameraPreview otherCamera];
    if (![otherCamera supportsWidth:self.goCoderConfig.videoWidth]) {
        [self.goCoderConfig loadPreset:otherCamera.supportedPresetConfigs.lastObject.toPreset];
        self.goCoder.config = self.goCoderConfig;
    }
    [self.goCoderCameraPreview switchCamera];
    [self.torchButton  setImage:[UIImage imageNamed:@"torch_on_button"] forState:UIControlStateNormal];
    [self updateUIControls];
}

- (IBAction) didTapTorchButton:(id)sender {
    BOOL newTorchOnState = !self.goCoderCameraPreview.camera.torchOn;
    
    self.goCoderCameraPreview.camera.torchOn = newTorchOnState;
    [self.torchButton setImage:[UIImage imageNamed:(newTorchOnState ? @"torch_off_button" : @"torch_on_button")] forState:UIControlStateNormal];
}

- (IBAction) didTapMicButton:(id)sender {
    BOOL newMutedState = !self.goCoder.isAudioMuted;
    
    self.goCoder.audioMuted = newMutedState;
    [self.micButton setImage:[UIImage imageNamed:(newMutedState ? @"mic_off_button" : @"mic_on_button")] forState:UIControlStateNormal];
}

- (IBAction) didTapSettingsButton:(id)sender {
    UIViewController *settingsNavigationController = [[UIStoryboard storyboardWithName:@"GoCoderSettings" bundle:nil] instantiateViewControllerWithIdentifier:@"settingsNavigationController"];
    
    SettingsViewController *settingsVC = (SettingsViewController *)(((UINavigationController *)settingsNavigationController).topViewController);
    [settingsVC addAllSections];
    
    SettingsViewModel *settingsModel = [[SettingsViewModel alloc] initWithSessionConfig:self.goCoderConfig];
    settingsModel.supportedPresetConfigs = self.goCoder.cameraPreview.camera.supportedPresetConfigs;
    settingsVC.viewModel = settingsModel;
    
    [self presentViewController:settingsNavigationController animated:YES completion:NULL];
}


- (IBAction)barBtnBackTapped:(UIBarButtonItem *)sender {
    
    [self.delegate videoBroadcastingVCDidClosed:self];
    [self cleanUp];
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - Instance Methods

// Update the state of the UI controls
- (void) updateUIControls {
    if (self.goCoder.status.state != WZStateIdle && self.goCoder.status.state != WZStateRunning) {
        // If a streaming broadcast session is in the process of starting up or shutting down,
        // disable the UI controls
        self.broadcastButton.enabled    = NO;
        self.torchButton.enabled        = NO;
        self.switchCameraButton.enabled = NO;
        self.settingsButton.enabled     = NO;
        self.micButton.hidden           = YES;
        self.micButton.enabled          = NO;
    } else {
        // Set the UI control state based on the streaming broadcast status, configuration,
        // and device capability
        self.broadcastButton.enabled    = YES;
        self.switchCameraButton.enabled = self.goCoderCameraPreview.cameras.count > 1;
        self.torchButton.enabled        = [self.goCoderCameraPreview.camera hasTorch];
        self.settingsButton.enabled     = !self.goCoder.isStreaming;
        // The mic icon should only be displayed while streaming and audio streaming has been enabled
        // in the GoCoder SDK configuration setiings
        self.micButton.enabled          = self.goCoder.isStreaming && self.goCoderConfig.audioEnabled;
        self.micButton.hidden           = !self.micButton.enabled;
    }
}

#pragma mark - WZStatusCallback Protocol Instance Methods

- (void) onWZStatus:(WZStatus *) goCoderStatus {
    // A successful status transition has been reported by the GoCoder SDK
    
    switch (goCoderStatus.state) {

        case WZStateIdle:
            // There is no active streaming broadcast session
            if (self.writeMP4 && self.mp4Writer.writing) {
                if (self.video_capture_queue) {
                    dispatch_async(self.video_capture_queue, ^{
                        [self.mp4Writer stopWriting];
                        self.mp4Writer = nil;
                    });
                }
                else {
                    [self.mp4Writer stopWriting];
                    self.mp4Writer = nil;
                }
                
                
            }
            self.writeMP4 = NO;
            break;

            
        case WZStateStarting:
            // A streaming broadcast session is starting up
            break;
            
        case WZStateRunning:
            // A streaming broadcast session is running
            self.writeMP4 = NO;
            if (self.recordVideoLocally) {
                self.mp4Writer = [MP4Writer new];
                self.writeMP4 = [self.mp4Writer prepareWithConfig:self.goCoderConfig];
                if (self.writeMP4) {
                    [self.mp4Writer startWriting];
                }
            }
            break;

        case WZStateStopping:
            // A streaming broadcast session is shutting down
/*
            if (self.writeMP4) {
                [self.mp4Writer stopWriting];
            }
            self.writeMP4 = NO;
 */
            break;
            
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.goCoder.status.state == WZStateIdle) {
            ///streaming stopped
            [self.broadcastButton setImage:[UIImage imageNamed: @"play_button"] forState:UIControlStateNormal];
            NSLog(@"m-> streaming stopped");
            
        }
        else if (self.goCoder.status.state == WZStateRunning) {
            ///streaming started
            [self.broadcastButton setImage:[UIImage imageNamed: @"pause_button"] forState:UIControlStateNormal];
            
            __weak typeof(self) weakSelf = self;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ///Send broadcasting alert after 10 seconds of streaming
                NSLog(@"m->dispatching now");
                [weakSelf.delegate videoBroadcastingVCDidStartBroadcasting:weakSelf];
                
            });
        }
//        if (self.goCoder.status.state == WZStateIdle || self.goCoder.status.state == WZStateRunning) {
//            [self.broadcastButton setImage:[UIImage imageNamed:(_goCoder.status.state == WZStateIdle) ? @"play_button" : @"pause_button"] forState:UIControlStateNormal];
//        }
        
        [self updateUIControls];
    });
}

- (void) onWZEvent:(WZStatus *) goCoderStatus {
    // If an event is reported by the GoCoder SDK, display an alert dialog describing the event,
    // but only if we haven't already shown an alert for this event
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        __block BOOL haveSeenAlertForEvent = NO;
//        [self.receivedGoCoderEventCodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([((NSNumber *)obj) isEqualToNumber:[NSNumber numberWithInteger:goCoderStatus.event]]) {
//                haveSeenAlertForEvent = YES;
//                *stop = YES;
//            }
//        }];
//        if (!haveSeenAlertForEvent) {
//            [self showAlertWithTitle:@"Live Streaming Event" status:goCoderStatus];
//            [self.receivedGoCoderEventCodes addObject:[NSNumber numberWithInteger:goCoderStatus.error.code]];
//        }
        
        [self updateUIControls];
    });
}

- (void) onWZError:(WZStatus *) goCoderStatus {
    // If an error is reported by the GoCoder SDK, display an alert dialog containing the error details
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"Live Streaming Error" status:goCoderStatus];
        
        [self updateUIControls];
    });
}

#pragma mark - WZVideoSink
#warning Don't implement this protocol unless your application makes use of it
- (void) videoFrameWasCaptured:(nonnull CVImageBufferRef)imageBuffer framePresentationTime:(CMTime)framePresentationTime frameDuration:(CMTime)frameDuration {
    if (self.goCoder.isStreaming) {
        
        if (self.blackAndWhiteVideoEffect) {
            // convert frame to b/w using CoreImage tonal filter
            CIImage *frameImage = [[CIImage alloc] initWithCVImageBuffer:imageBuffer];
            CIFilter *grayFilter = [CIFilter filterWithName:@"CIPhotoEffectTonal"];
            [grayFilter setValue:frameImage forKeyPath:@"inputImage"];
            frameImage = [grayFilter outputImage];

            CIContext * context = [CIContext contextWithOptions:nil];
            [context render:frameImage toCVPixelBuffer:imageBuffer];
        }
        
    }
}

- (void) videoCaptureInterruptionStarted {
    if (!self.goCoderConfig.backgroundBroadcastEnabled) {
        [self.goCoder endStreaming:self];
    }
}

- (void) videoCaptureUsingQueue:(nullable dispatch_queue_t)queue {
    self.video_capture_queue = queue;
}

#pragma mark - WZAudioSink

- (void) audioLevelDidChange:(float)level {
//    NSLog(@"%@ %0.2f", @"Audio level did change", level);
}

#pragma mark - WZAudioEncoderSink

- (void) audioSampleWasEncoded:(nullable CMSampleBufferRef)data {
    if (self.writeMP4) {
        [self.mp4Writer appendAudioSample:data];
    }
}


#pragma mark - WZVideoEncoderSink

- (void) videoFrameWasEncoded:(nonnull CMSampleBufferRef)data {
    if (self.writeMP4) {
        [self.mp4Writer appendVideoSample:data];
    }
}

#pragma mark -

- (void) showAlertWithTitle:(NSString *)title status:(WZStatus *)status {
    UIAlertView *alertDialog = [[UIAlertView alloc] initWithTitle:title
                                                          message:status.description
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [alertDialog show];
}

- (void) showAlertWithTitle:(NSString *)title error:(NSError *)error {
    UIAlertView *alertDialog = [[UIAlertView alloc] initWithTitle:title
                                                          message:error.localizedDescription
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [alertDialog show];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

- (void) orientationChanged:(NSNotification *)notification {
    
    /*
     We are looking at orientation changed events in order to demonstrate sending stream data to the server.
     */
    
    WZDataMap *params = [WZDataMap new];
    UIDevice * device = notification.object;
    switch(device.orientation) {
        case UIDeviceOrientationPortrait:
            [params setString:@"portrait" forKey:@"deviceOrientation"];
            [params setInteger:0 forKey:@"deviceRotation"];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            [params setString:@"portrait" forKey:@"deviceOrientation"];
            [params setInteger:180 forKey:@"deviceRotation"];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            [params setString:@"landscape" forKey:@"deviceOrientation"];
            [params setInteger:90 forKey:@"deviceRotation"];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [params setString:@"landscape" forKey:@"deviceOrientation"];
            [params setInteger:270 forKey:@"deviceRotation"];
            break;
            
        default:
            break;
    };
    
    if (params.data.count > 0) {
        [self.goCoder sendDataEvent:WZDataScopeStream eventName:@"onDeviceOrientation" params:params callback:nil];
    }
}


#endif

@end





