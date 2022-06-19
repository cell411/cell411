//
//  QRCodeGeneratorVC.m
//  cell411
//
//  Created by Milan Agarwal on 14/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "C411QRCodeGeneratorVC.h"
#import "C411StaticHelper.h"
#import <Parse/Parse.h>
#import "ConfigConstants.h"
#import "AppDelegate.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411QRCodeGeneratorVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imgVuQRCode;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UIView *vuBaseQRAndEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblInfoWithAppName;
- (IBAction)barBtnShareTapped:(UIBarButtonItem *)sender;
@property (nonatomic, strong) UIImage *qrCodeImg;
@end

@implementation C411QRCodeGeneratorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *strEmail = [C411StaticHelper getEmailFromUser:[AppDelegate getLoggedInUser]];
    strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.lblUsername.text = strEmail;
    
    CGImageRef qrCodeImageRef = [self createQRImageForString:strEmail size:CGSizeMake(200, 200)];
    self.qrCodeImg = [UIImage imageWithCGImage:qrCodeImageRef];
    
    NSLog(@"Image Size %@",NSStringFromCGSize(self.qrCodeImg.size));
    self.imgVuQRCode.image = self.qrCodeImg;
    
    [self configureViews];
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
    self.title = NSLocalizedString(@"QR Code", nil);
    if (@available(iOS 11, *)) {
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        ///Above line is commented to disable large title temporarily to fix an issue(Navigation bar background color gets cleared for large titles) until we switch to Xcode 11 having base SDK as iOS 13 for compilation that provides the new UINavigationBarAppearance Class using which we can set same appearance for all scrollEdgeAppearance, standardAppearance and compactAppearance to resolve the issue as provided here: https://stackoverflow.com/a/56696967/3412051
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    ///Set dynamic app name
    self.lblInfoWithAppName.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Your friends can use %@ to scan this code and add you as a friend.",nil),LOCALIZED_APP_NAME];
    
    [self applyColors];
}

-(void)applyColors {
    self.view.backgroundColor = [C411ColorHelper sharedInstance].backgroundColor;
    
    ///Set primary Text Color
    self.lblInfoWithAppName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (CGImageRef)createQRImageForString:(NSString *)string size:(CGSize)size {
    // Setup the QR filter with our string
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *image = [filter valueForKey:@"outputImage"];
    
    // Calculate the size of the generated image and the scale for the desired image size
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width / CGRectGetWidth(extent), size.height / CGRectGetHeight(extent));
    
    // Since CoreImage nicely interpolates, we need to create a bitmap image that we'll draw into
    // a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
#if TARGET_OS_IPHONE
    CIContext *context = [CIContext contextWithOptions:nil];
#else
    CIContext *context = [CIContext contextWithCGContext:bitmapRef options:nil];
#endif
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return scaledImage;
}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)barBtnShareTapped:(UIBarButtonItem *)sender {
    
    NSString *strShareText = [NSString localizedStringWithFormat:NSLocalizedString(@"Hi, feel free to scan my QR code and join me on %@ network to get help in emergency.",nil), LOCALIZED_APP_NAME];
    UIImage *QRCodeWithEmailImg = [C411StaticHelper snapshot:self.vuBaseQRAndEmail];
    if (!QRCodeWithEmailImg) {
        ///If there is an error taking snapshot, use QR code image to share
        QRCodeWithEmailImg = self.qrCodeImg;
    }
    NSArray * arrActivityItems = @[strShareText,QRCodeWithEmailImg];
    
    UIActivityViewController *shareActivityVC = [[UIActivityViewController alloc]initWithActivityItems:arrActivityItems applicationActivities:nil];
    shareActivityVC.excludedActivityTypes = @[UIActivityTypeAirDrop];
    //    [shareActivityVC setValue:self.story.strTitle forKey:@"subject"];
    [self presentViewController:shareActivityVC animated:YES completion:NULL];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************

-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
