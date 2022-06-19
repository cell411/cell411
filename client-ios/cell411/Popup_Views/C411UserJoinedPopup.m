//
//  C411UserJoinedPopup.m
//  cell411
//
//  Created by Milan Agarwal on 18/01/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411UserJoinedPopup.h"
#import "C411StaticHelper.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "AppDelegate.h"
#import "C411ViewPhotoVC.h"
#import "C411UserProfilePopup.h"
#import "C411ColorHelper.h"
#import "Constants.h"


@interface C411UserJoinedPopup ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *vuUserJoinedPopup;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UITextView *txtVuAlertMessage;
@property (weak, nonatomic) IBOutlet UIView *vuUserLocationContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuUserLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblUserLocation;
@property (weak, nonatomic) IBOutlet UIView *vuSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btnDecideLater;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFriend;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

- (IBAction)btnDecideLaterTapped:(UIButton *)sender;
- (IBAction)btnAddFriendTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;

@property (nonatomic, assign, getter = isInitialized) BOOL initialized;
@property (nonatomic, assign, getter = isAvatarAvailable) BOOL avatarAvailable;

@end

@implementation C411UserJoinedPopup

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self configureViews];
    [self registerForNotifications];
    [C411StaticHelper removeOnScreenKeyboard];
    
}

-(void)dealloc
{
    [self unregisterFromNotifications];
    //    [self.getLocationTask cancel];
    //    self.getLocationTask = nil;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setUser:(PFUser *)user
{
    _user = user;
    if (!self.isInitialized) {
        
        [self setupUserJoinedDetails];
        self.initialized = YES;
        
    }
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///1. set border color
    //    UIColor *whiteColor = [UIColor whiteColor];
    //    self.imgVuAvatar.layer.borderColor = whiteColor.CGColor;
    //    self.imgVuAvatar.layer.borderWidth = 2.0;
    
    
    ///2. Make circular views
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    [C411StaticHelper makeCircularView:self.btnClose];
    
    ///3. Set corner radius
    self.vuUserJoinedPopup.layer.cornerRadius = 5.0;
    self.vuUserJoinedPopup.layer.masksToBounds = YES;
    
    self.btnClose.layer.borderWidth = 1.0;
    
    ///6. set initial strings for localization
    self.lblUserLocation.text = NSLocalizedString(@"Retreiving City...", nil);
    
    [self.btnAddFriend setTitle:NSLocalizedString(@"Add Friend", nil) forState:UIControlStateNormal];
    [self.btnDecideLater setTitle:NSLocalizedString(@"Decide Later", nil) forState:UIControlStateSelected];
    
    [self applyColors];
}

-(void)applyColors {
    ///set background color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuUserJoinedPopup.backgroundColor = lightCardColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.txtVuAlertMessage.textColor = primaryTextColor;
    self.lblUserLocation.textColor = primaryTextColor;
    
    ///Set dark hint icon color
    self.imgVuUserLocation.tintColor = [C411ColorHelper sharedInstance].darkHintIconColor;
    
    ///set card color
    self.vuUserLocationContainer.backgroundColor = [C411ColorHelper sharedInstance].cardColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnDecideLater.backgroundColor = themeColor;
    self.btnAddFriend.backgroundColor = themeColor;
    
    ///Set primary BG TEXT color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    [self.btnDecideLater setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnAddFriend setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    self.vuSeparator.backgroundColor = primaryBGTextColor;
    
    UIColor *crossButtonColor = [C411ColorHelper sharedInstance].popupCrossButtonColor;
    self.btnClose.backgroundColor = crossButtonColor;
    
    ///1.4 border color of cross button
    UIColor *blackColor = [UIColor blackColor];
    self.btnClose.layer.borderColor = blackColor.CGColor;
    
    NSDictionary *dictLinkTextAttr = @{NSForegroundColorAttributeName:self.txtVuAlertMessage.textColor};
    self.txtVuAlertMessage.linkTextAttributes = dictLinkTextAttr;

}



-(void)addTapGestureOnImageView:(UIView *)imgVu
{
    ///Enable user interaction to listen tap event
    imgVu.userInteractionEnabled = YES;
    
    ///Add tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgVuAvatarTapped:)];
    [imgVu addGestureRecognizer:tapRecognizer];
}


-(void)setupUserJoinedDetails{
    
    ///Set tap gesture on avatar imageview
    [self addTapGestureOnImageView:self.imgVuAvatar];
    
    ///set user avatar
    __weak typeof(self) weakSelf = self;
    if (self.user) {
        [self.imgVuAvatar setAvatarForUser:self.user shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
            
            if (success && image) {
                ///This user has profile picture available
                weakSelf.avatarAvailable = YES;
                
            }
            
        }];
    }
    
    ///Set user joined message
    ///Get user full name
    NSString *strUserFullName = [C411StaticHelper getFullNameUsingFirstName:self.user[kUserFirstnameKey] andLastName:self.user[kUserLastnameKey]];
    
    float fontSize = self.txtVuAlertMessage.font.pointSize;
    NSDictionary *dictMainAttr = @{NSFontAttributeName:[UIFont systemFontOfSize: fontSize],
                                   NSForegroundColorAttributeName:[UIColor blackColor]};
    NSMutableAttributedString *attribStrAlertTitle = [[NSMutableAttributedString alloc]initWithString:[NSString localizedStringWithFormat:NSLocalizedString(@"%@ has just joined %@ would you like add them as friend",nil),strUserFullName,LOCALIZED_APP_NAME] attributes:dictMainAttr];
    
    
    NSDictionary *dictSubAttr = @{NSFontAttributeName:[UIFont boldSystemFontOfSize: fontSize]};
    
    ///set attributes on user full name
    ///1. make name range
    NSRange fullNameRange = NSMakeRange(0, strUserFullName.length);
    ///2. set bold attribute
    [attribStrAlertTitle setAttributes:dictSubAttr range:fullNameRange];
    
    ///3. add link attribute for full name
    NSDictionary *dictParams = @{kInternalLinkParamType:kInternalLinkParamTypeShowUserProfile};
    NSURL *url = [NSURL URLWithString:[ServerUtility stringByAppendingParams:dictParams toUrlString:kInternalLinkBaseURL]];
    [attribStrAlertTitle addAttribute:NSLinkAttributeName value:url range:fullNameRange];
    
    self.txtVuAlertMessage.attributedText = attribStrAlertTitle;
    self.txtVuAlertMessage.delegate = self;
    
    ///Set city
    PFGeoPoint *userLocation = self.user[kUserLocationKey];
    [self updateLocationUsingCoordinate:CLLocationCoordinate2DMake(userLocation.latitude, userLocation.longitude)];
    
}

-(void)updateLocationUsingCoordinate:(CLLocationCoordinate2D)locCoordinate
{
    
    GMSGeocoder *geoCoder = [GMSGeocoder geocoder];
    NSLog(@"%s",__PRETTY_FUNCTION__);
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
                
                weakSelf.lblUserLocation.text = firstAddress.locality;
            }
            else{
                
                weakSelf.lblUserLocation.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        else{
            
            NSLog(@"#Failed: resp= %@\nerr=%@",geoCodeResponse,error);
        }
        
        
    }];
    
    
}

-(void)closePopupViaSender:(UIButton *)sender{
    
    if (self.actionHandler != NULL) {
        ///call the Close action handler
        self.actionHandler(sender,0,nil);
        
    }
    
    [self removeFromSuperview];
}

-(void)handleInternalUrl:(NSURL *)url
{
    
    ///Parse the url and get the type value to take corresponding action
    NSDictionary *dictParams = [ServerUtility getParamsFromUrl:url];
    
    if (dictParams) {
        
        ///get the type value
        NSString *strType = dictParams[kInternalLinkParamType];
        if ([strType isEqualToString:kInternalLinkParamTypeShowUserProfile]) {
            
            if (self.user) {
                
                ///show user profile if alertPerson holds valid user object
                if ([self.user.objectId isEqualToString:[AppDelegate getLoggedInUser].objectId]) {
                    
                    /* Open it to Show profile of current user
                     C411MyProfileVC *myProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"C411MyProfileVC"];
                     [self.navigationController pushViewController:myProfileVC animated:YES];
                     */
                    
                }
                else{
                    
                    ///show profile of other user
                    [self showUserProfile:self.user];
                }
                
            }
            
        }
    }
    
    
}

-(void)showUserProfile:(PFUser *)user
{
    
    ///Show user profile popup
    C411UserProfilePopup *vuUserProfilePopup = [[[NSBundle mainBundle] loadNibNamed:@"C411UserProfilePopup" owner:self options:nil] lastObject];
    
    vuUserProfilePopup.user = user;
   vuUserProfilePopup.actionHandler = ^(id action, NSInteger actionIndex, id customObject) {
        
        ///Do anything on close
        
        
    };
    
    UIViewController *rootVC = [AppDelegate sharedInstance].window.rootViewController;
    ///Set view frame
    vuUserProfilePopup.frame = rootVC.view.bounds;
    ///add view
    [rootVC.view addSubview:vuUserProfilePopup];
    [rootVC.view bringSubviewToFront:vuUserProfilePopup];
    
}

-(void)registerForNotifications
{
    [super registerForNotifications];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    
    [super unregisterFromNotifications];
    
    ///Remove observing from notification attached on this class
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kDarkModeValueChangedNotification object:nil];
    
}


//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnDecideLaterTapped:(UIButton *)sender {
    
    [self closePopupViaSender:sender];
    
}

- (IBAction)btnAddFriendTapped:(UIButton *)sender {
    
    self.actionHandler(sender,1,nil);
    [self removeFromSuperview];
    
}

- (IBAction)btnCloseTapped:(UIButton *)sender {
    
    [self closePopupViaSender:sender];
    
}

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    
    ///Show photo VC to view photo alert
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
    if (self.isAvatarAvailable) {
        
        ///set image
        UIImageView *imgVuAvatar = (UIImageView *) sender.view;
        viewPhotoVC.imgPhoto = imgVuAvatar.image;
    }
    else{
        
        ///set user object to be used to fetch avatar
        viewPhotoVC.user = self.user;
        
    }
    [navRoot pushViewController:viewPhotoVC animated:YES];
}

//****************************************************
#pragma mark - UITextViewDelegate Methods
//****************************************************

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    // Call your method here.
    [self handleInternalUrl:URL];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    // Call your method here.
    [self handleInternalUrl:URL];
    return NO;
    
}

//****************************************************
#pragma mark - Notification Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
