//
//  C411QRCodeScannerVC.m
//  cell411
//
//  Created by Milan Agarwal on 14/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411BarcodeScannerVC.h"
#import "MTBBarcodeScanner.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411BarcodeScannerVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) MTBBarcodeScanner *scanner;
@property (strong, nonatomic) NSMutableArray *arrUniqueCodes;

@end

@implementation C411BarcodeScannerVC

//****************************************************
#pragma mark - Life Cycle
//****************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureViews];
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            [self startScanning];
        } else {
            [self displayPermissionMissingAlert];
        }
    }];
    [self registerForNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ///Unhide the navigation bar
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    self.delegate = nil;
    self.scanner = nil;
    self.arrUniqueCodes = nil;
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
    [self stopScanning];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    self.title = NSLocalizedString(@"Scan Code", nil);
    if (@available(iOS 11, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        ///Above line is commented to disable large title temporarily to fix an issue(Navigation bar background color gets cleared for large titles) until we switch to Xcode 11 having base SDK as iOS 13 for compilation that provides the new UINavigationBarAppearance Class using which we can set same appearance for all scrollEdgeAppearance, standardAppearance and compactAppearance to resolve the issue as provided here: https://stackoverflow.com/a/56696967/3412051
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self applyColors];
}

-(void)applyColors {
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    ///Set primary Text Color
    self.lblDescription.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode] previewView:self.vuScannerPreview];
    }
    return _scanner;
}


- (void)startScanning {
    self.arrUniqueCodes = [[NSMutableArray alloc] init];
    
    __weak typeof(self) weakSelf = self;
    NSError *err = nil;
    [self.scanner startScanningWithResultBlock:^(NSArray<AVMetadataMachineReadableCodeObject *> *codes) {
        BOOL isNewCodeAdded = NO;
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if (code.stringValue && [weakSelf.arrUniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                isNewCodeAdded = YES;
                [weakSelf.arrUniqueCodes addObject:code.stringValue];
                
                NSLog(@"Found unique code: %@", code.stringValue);
                
                
            }
        }
        
        //Notify the delegate
        if (isNewCodeAdded) {
            
            if ([weakSelf.delegate respondsToSelector:@selector(scanner:didScanBarcodesWithResult:)]) {
                [weakSelf.delegate scanner:weakSelf didScanBarcodesWithResult:weakSelf.arrUniqueCodes];
            }
            
        }
    } error:&err];
    
    if(err) {
        ///Show error
        [C411StaticHelper showAlertWithTitle:nil message:err.localizedDescription onViewController:nil];
    }
}

- (void)stopScanning {
    
    [self.scanner stopScanning];
    
}

- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ does not have permission to use the camera.",nil),LOCALIZED_APP_NAME];
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = NSLocalizedString(@"This device does not have a camera.",nil);
    } else {
        message = NSLocalizedString(@"An unknown error occurred.",nil);
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Scanning Unavailable",nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"Ok",nil)
                      otherButtonTitles:nil] show];
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
