//
//  C411WelcomeGalleryVC.m
//  cell411
//
//  Created by Milan Agarwal on 15/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411WelcomeGalleryVC.h"
#import "C411WelcomeGalleryCell.h"
#import "C411LoginVC.h"
#import "C411SignUpVC.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "Constants.h"
#import "C411ColorHelper.h"
//#import "C411ResetPasswordVC.h"
#import "UIImage+GIF.h"

#define kGalleryImage       @"galleryImage"
#define kGalleryGIFImage    @"galleryGIFImage"
#define kGalleryTitle       @"title"
#define kGallerySubtitle    @"subtitle"

@interface C411WelcomeGalleryVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imgVuBG;
@property (weak, nonatomic) IBOutlet UICollectionView *colVuGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIPageControl *pgcGallery;
- (IBAction)btnSignInTapped:(UIButton *)sender;
- (IBAction)btnSignUpTapped:(UIButton *)sender;

@property (nonatomic, strong) NSArray *arrGalleryData;

@end

@implementation C411WelcomeGalleryVC


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForNotifications];
    [self configureViews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

}

-(void)dealloc{
    
    [self unregisterFromNotifications];
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    self.navigationController.navigationBarHidden = NO;
//}

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

-(NSArray *)arrGalleryData
{
    if (!_arrGalleryData) {
        
        _arrGalleryData = @[@{kGalleryImage:[[C411ColorHelper sharedInstance]getSplashImageNameAtIndex:0],
                              kGalleryTitle:[NSString localizedStringWithFormat:NSLocalizedString(@"Welcome to %@",nil),LOCALIZED_APP_NAME],
#if APP_IER
                              kGallerySubtitle:NSLocalizedString(@"\"iER is South Africa’s only dedicated emergency response and disaster management network backed by our own emergency trained call centre designed to respond to any emergency situation 24 hours a day, every day!\"", nil)

#else
                              kGallerySubtitle:NSLocalizedString(@"\"This is the app that allows you to issue and respond to emergencies from your family, friends and neighbors in real time\"", nil)
                             
#endif
#if APP_CELL411
                              ,
                              kGalleryGIFImage:@"gif_avatar"
#endif
                                },
                            @{kGalleryImage:[[C411ColorHelper sharedInstance]getSplashImageNameAtIndex:1],
#if APP_IER

                              kGalleryTitle:NSLocalizedString(@"In an emergency",nil),
                              kGallerySubtitle:NSLocalizedString(@"\"iER dispatches emergency response units to your location and is available nationwide.\niER is linked directly to each and every member and directly to the emergency response personnel, we’ll know where you are within seconds of you sending an alert using the iER App.\"",nil)
#else
                              
                              kGalleryTitle:NSLocalizedString(@"When you are in Danger",nil),
                              kGallerySubtitle:NSLocalizedString(@"\"Let your friends and neighbours know of lurking dangers in your community and improve safety in your neighborhood\"",nil)

                              
#endif
                              },
                            @{kGalleryImage:[[C411ColorHelper sharedInstance]getSplashImageNameAtIndex:2],
#if APP_IER
                              kGalleryTitle:NSLocalizedString(@"Connect and notify",nil),
                              kGallerySubtitle:NSLocalizedString(@"\"Create your own family and community emergency response groups to get an immediate notification once an alert has been issued. Ensuring you get the emergency assistance you need when you need it.\"",nil)
#else
                              kGalleryTitle:NSLocalizedString(@"Are you lost with a broken car?",nil),
                              kGallerySubtitle:[NSString localizedStringWithFormat:NSLocalizedString(@"\"%@ will send your exact coordinates to trusted people so they can find you and help you when you need help most\"",nil),LOCALIZED_APP_NAME]
#endif
                              }
#if VIDEO_STREAMING_ENABLED
                            ,@{kGalleryImage:@"splash_4",
                               kGalleryTitle:NSLocalizedString(@"Stream live HD video",nil),
                               kGallerySubtitle:NSLocalizedString(@"\"You can stream live video and audio to all your friends and groups, to one person or one thousand. The video cannot be deleted or erased.\"",nil)
                               }

#endif
                            ];
    }
    
    return _arrGalleryData;
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)updatePageControl:(UIPageControl *)pageControl forCollectionView:(UICollectionView *)collectionView
{
    CGPoint currentOffset = [collectionView contentOffset];
    int currIndex = currentOffset.x / collectionView.frame.size.width;
    if (self.arrGalleryData.count > 0 && currIndex >= 0 && currIndex < self.arrGalleryData.count) {
        pageControl.currentPage = currIndex;
        
    }
    
}

-(void)configureViews
{
    [self applyColors];
}

-(void)applyColors {
    ///Set background Image
    self.imgVuBG.image = [C411ColorHelper sharedInstance].imgGalleryBG;
    ///Set secondary color on page control
    self.pgcGallery.currentPageIndicatorTintColor = [C411ColorHelper sharedInstance].secondaryColor;
    
    ///Set theme colors on action button text
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    [self.btnSignIn setTitleColor:themeColor forState:UIControlStateNormal];
    [self.btnSignUp setTitleColor:themeColor forState:UIControlStateNormal];
    
    
    ///Set navigation bar color as primary color
    UIColor *primaryColor = [C411ColorHelper sharedInstance].primaryColor;
    self.navigationController.navigationBar.barTintColor = primaryColor;
    ///Set tint color on navigation bar
    self.navigationController.navigationBar.tintColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    
    ///Set keyboard appearance
    [UITextField appearance].keyboardAppearance = [C411ColorHelper sharedInstance].keyboardAppearance;
    //[UITextView appearance].keyboardAppearance = [C411ColorHelper sharedInstance].keyboardAppearance;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

/*
-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetPasswordLinkTapped:) name:kResetPasswordNotification object:nil];
    
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}
*/

//****************************************************
#pragma mark - UICollectionViewDataSource and Delegate Methods
//****************************************************

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.pgcGallery.numberOfPages = self.arrGalleryData.count;
    
    return self.arrGalleryData.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellId = @"C411WelcomeGalleryCell";
    
    C411WelcomeGalleryCell *galleryCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSDictionary *dictGalleryData = [self.arrGalleryData objectAtIndex:indexPath.item];
    NSString *strImageName = [dictGalleryData objectForKey:kGalleryImage];
    galleryCell.imgVuGalleryPic.image = [UIImage imageNamed:strImageName];
    galleryCell.lblTitle.text = [dictGalleryData objectForKey:kGalleryTitle];
    galleryCell.lblSubtitle.text = [dictGalleryData objectForKey:kGallerySubtitle];
    NSString *strGifImgName = [dictGalleryData objectForKey:kGalleryGIFImage];
    if(strGifImgName.length > 0) {
        galleryCell.imgVuGIF.image = [UIImage sd_animatedGIFNamed:strGifImgName];
        galleryCell.imgVuGIF.hidden = NO;
    }
    else{
        galleryCell.imgVuGIF.hidden = YES;
        galleryCell.imgVuGIF.image = nil;
    }
    return galleryCell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return collectionView.bounds.size;
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.arrGalleryData.count >  1)
        [self updatePageControl:self.pgcGallery forCollectionView:self.colVuGallery];
}





//****************************************************
#pragma mark - Action Methods
//****************************************************


- (IBAction)btnSignInTapped:(UIButton *)sender {
    
    C411LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411LoginVC"];
    [self.navigationController pushViewController:loginVC animated:YES];
    
    
}

- (IBAction)btnSignUpTapped:(UIButton *)sender {
    
    C411SignUpVC *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411SignUpVC"];
    [self.navigationController pushViewController:signUpVC animated:YES];

}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
/*
-(void)resetPasswordLinkTapped:(NSNotification *)notif
{
    NSString *strEmail = notif.object;
    
    ///Push Reset Password VC in non animated way
    C411ResetPasswordVC *resetPasswordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411ResetPasswordVC"];
    resetPasswordVC.strEmail = strEmail;
    [self.navigationController pushViewController:resetPasswordVC animated:NO];
    
    
}
*/
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
    ///reload collection view
    self.arrGalleryData = nil;
    [self.colVuGallery reloadData];
}

@end
