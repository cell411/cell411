//
//  C411RideResponsePopup.m
//  cell411
//
//  Created by Milan Agarwal on 04/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideResponsePopup.h"
#import "C411StaticHelper.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ServerUtility.h"
#import "UIImageView+ImageDownloadHelper.h"
#import "C411ViewPhotoVC.h"
#import "C411RideReviewsVC.h"
#import "C411ColorHelper.h"
#import "Constants.h"

@interface C411RideResponsePopup ()

@property (weak, nonatomic) IBOutlet UIView *vuAlertBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuDriver;
@property (weak, nonatomic) IBOutlet UIView *vuResponseStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblResponseStatus;
@property (weak, nonatomic) IBOutlet UIView *vuSeparator;
@property (weak, nonatomic) IBOutlet UILabel *lblAlertTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNote;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteValue;
@property (weak, nonatomic) IBOutlet UILabel *lblPickUpAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDropAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblCost;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuVehiclePhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnDecideLater;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnSmallClose;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNotePopupBase;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNotePopup;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalPopupHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblAdditionalNoteTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtAdditionalNote;
@property (weak, nonatomic) IBOutlet UIView *vuAdditionalNoteSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentMode;
@property (weak, nonatomic) IBOutlet UIView *vuCashContainer;
@property (weak, nonatomic) IBOutlet UIView *vuCashImgContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblCash;
@property (weak, nonatomic) IBOutlet UIView *vuSilverContainer;
@property (weak, nonatomic) IBOutlet UIView *vuSilverImgContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblSilver;
@property (weak, nonatomic) IBOutlet UIView *vuCryptoContainer;
@property (weak, nonatomic) IBOutlet UIView *vuCryptoImgContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblCrypto;
@property (weak, nonatomic) IBOutlet UIView *vuBarteringContainer;
@property (weak, nonatomic) IBOutlet UIView *vuBarteringImgContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblBartering;
@property (weak, nonatomic) IBOutlet UIView *vuCreditCardContainer;
@property (weak, nonatomic) IBOutlet UIView *vuCreditCardImgContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCard;
@property (weak, nonatomic) IBOutlet UILabel *lblETA;
@property (weak, nonatomic) IBOutlet UIView *vuPaymentModes;
@property (weak, nonatomic) IBOutlet UIView *vuAvgRatingBase;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuStar;
@property (weak, nonatomic) IBOutlet UILabel *lblAvgRating;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAdditionalNoteTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsResponseStatusViewTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsResponseStatusLabelTS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsResponseStatusLabelBS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsAdditonalNotePopupCenterY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCashImgLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCashImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCashLabelLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCashLabelTrailingS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSilverVuLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSilverImgLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSilverImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSilverLabelLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsSilverLabelTrailingS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCryptoVuLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCryptoImgLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCryptoImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCryptoLabelLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCryptoLabelTrailingS;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsBarteringVuLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsBarteringImgLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsBarteringImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsBarteringLabelLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsBarteringLabelTrailingS;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCreditCardVuLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCreditCardImgLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCreditCardImgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCreditCardLabelLS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCreditCardLabelTrailingS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCreditCardLabelWidth;




- (IBAction)btnDecideLaterTapped:(UIButton *)sender;
- (IBAction)btnRejectTapped:(UIButton *)sender;
- (IBAction)btnConfirmTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(UIButton *)sender;
- (IBAction)btnCallTapped:(UIButton *)sender;
- (IBAction)btnSendTapped:(UIButton *)sender;
- (IBAction)btnShowRatingTapped:(UIButton *)sender;

@property (nonatomic, assign, getter=isInitialized) BOOL initialized;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *dropLocationTask;
@property (nonatomic, strong) PFObject *rideResponse;
@property (nonatomic, strong) NSURLSessionDataTask *pickUpDistanceMatrixTask;
@property (nonatomic, assign, getter=isRideConfirmed) BOOL rideConfirmed;

@end

@implementation C411RideResponsePopup

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
    [self.pickUpLocationTask cancel];
    self.pickUpLocationTask = nil;
    [self.dropLocationTask cancel];
    self.dropLocationTask = nil;
    [self.pickUpDistanceMatrixTask cancel];
    self.pickUpDistanceMatrixTask = nil;

    [self unregisterFromNotifications];
    
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

-(void)setAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    _alertPayload = alertPayload;
    
    if (!self.isInitialized) {
        
        [self initializeViewWithAlertPayload:alertPayload];
        self.initialized = YES;
        
    }
    
}


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

-(void)configureViews
{
    ///Set corner radius
    self.vuAlertBase.layer.cornerRadius = 5.0;
    self.vuAlertBase.layer.masksToBounds = YES;
    self.vuAdditionalNotePopup.layer.cornerRadius = 5.0;
    self.vuAdditionalNotePopup.layer.masksToBounds = YES;
    self.btnDecideLater.layer.cornerRadius = 2.0;
    self.btnDecideLater.layer.masksToBounds = YES;
    self.btnReject.layer.cornerRadius = 2.0;
    self.btnReject.layer.masksToBounds = YES;
    self.btnConfirm.layer.cornerRadius = 2.0;
    self.btnConfirm.layer.masksToBounds = YES;
    self.btnClose.layer.cornerRadius = 2.0;
    self.btnClose.layer.masksToBounds = YES;
    self.btnSmallClose.layer.cornerRadius = 2.0;
    self.btnSmallClose.layer.masksToBounds = YES;
    self.btnCall.layer.cornerRadius = 2.0;
    self.btnCall.layer.masksToBounds = YES;
    self.vuCashContainer.layer.cornerRadius = 3.0;
    self.vuCashContainer.layer.masksToBounds = YES;
    self.vuSilverContainer.layer.cornerRadius = 3.0;
    self.vuSilverContainer.layer.masksToBounds = YES;
    self.vuCryptoContainer.layer.cornerRadius = 3.0;
    self.vuCryptoContainer.layer.masksToBounds = YES;
    self.vuBarteringContainer.layer.cornerRadius = 3.0;
    self.vuBarteringContainer.layer.masksToBounds = YES;
    self.vuCreditCardContainer.layer.cornerRadius = 3.0;
    self.vuCreditCardContainer.layer.masksToBounds = YES;

    
    ///make circular views
    [C411StaticHelper makeCircularView:self.imgVuDriver];
    [C411StaticHelper makeCircularView:self.vuCashImgContainer];
    [C411StaticHelper makeCircularView:self.vuSilverImgContainer];
    [C411StaticHelper makeCircularView:self.vuCryptoImgContainer];
    [C411StaticHelper makeCircularView:self.vuBarteringImgContainer];
    [C411StaticHelper makeCircularView:self.vuCreditCardImgContainer];
    [C411StaticHelper makeCircularView:self.vuAvgRatingBase];
    
    ///set initial strings for localization
    self.lblAdditionalNote.text = [NSString localizedStringWithFormat:@"%@:",NSLocalizedString(@"ADDITIONAL NOTE", nil)];
    self.lblAdditionalNoteValue.text = NSLocalizedString(@"LOADING...", nil);
    self.lblPickUpAddress.text = NSLocalizedString(@"Retreiving", nil);
    self.lblDropAddress.text = NSLocalizedString(@"Retreiving", nil);
    self.lblETA.text = NSLocalizedString(@"LOADING...", nil);
    self.lblPaymentMode.text = [NSString localizedStringWithFormat:@"%@:",NSLocalizedString(@"PAYMENT MODE", nil)];
    [self.btnClose setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    [self.btnSmallClose setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    [self.btnCall setTitle:NSLocalizedString(@"Call", nil) forState:UIControlStateNormal];
    [self.btnReject setTitle:NSLocalizedString(@"Reject", nil) forState:UIControlStateNormal];
    [self.btnConfirm setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    [self.btnDecideLater setTitle:NSLocalizedString(@"Decide Later", nil) forState:UIControlStateNormal];
    [self.btnSend setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    self.lblAdditionalPopupHeading.text = NSLocalizedString(@"Additional Note", nil);
    self.txtAdditionalNote.placeholder = NSLocalizedString(@"Additional text message if any", nil);

    [self applyColors];
}

-(void)applyColors {
    
    ///Set background color
    UIColor *lightCardColor = [C411ColorHelper sharedInstance].lightCardColor;
    self.vuAlertBase.backgroundColor = lightCardColor;
    self.vuAdditionalNotePopup.backgroundColor = lightCardColor;
    
    ///Set Primary Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTitle.textColor = primaryTextColor;
    self.lblAdditionalNote.textColor = primaryTextColor;
    self.lblPaymentMode.textColor = primaryTextColor;
    self.lblCost.textColor = primaryTextColor;
    self.lblAdditionalPopupHeading.textColor = primaryTextColor;
    self.txtAdditionalNote.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblETA.textColor = secondaryTextColor;
    self.lblPickUpAddress.textColor = secondaryTextColor;
    self.lblDropAddress.textColor = secondaryTextColor;
    self.lblAdditionalNoteTitle.textColor = secondaryTextColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuSeparator.backgroundColor = themeColor;
    self.vuAvgRatingBase.backgroundColor = themeColor;
    self.btnClose.backgroundColor = themeColor;
    self.btnCall.backgroundColor = themeColor;
    self.btnReject.backgroundColor = themeColor;
    self.btnConfirm.backgroundColor = themeColor;
    self.btnSmallClose.backgroundColor = themeColor;
    self.btnDecideLater.backgroundColor = themeColor;

    ///Set primaryBGTextColor
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.lblAvgRating.textColor = primaryBGTextColor;
    self.imgVuStar.tintColor = primaryBGTextColor;
    [self.btnClose setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnCall setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnReject setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnConfirm setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnSmallClose setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    [self.btnDecideLater setTitleColor:primaryBGTextColor forState:UIControlStateNormal];
    
    ///Set separator color
    UIColor *separatorColor = [C411ColorHelper sharedInstance].separatorColor;
    self.vuAdditionalNoteSeparator.backgroundColor = separatorColor;
    
    ///set secondary color
    UIColor *secondaryColor = [C411ColorHelper sharedInstance].secondaryColor;
    [self.btnSend setTitleColor:secondaryColor forState:UIControlStateNormal];
    
    ///Set payment mode colors
    self.vuCashContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CASH_COLOR andAlpha:PAY_SELECTED_ALPHA];
    self.vuCashImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CASH_COLOR];
    
    self.vuSilverContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_SILVER_COLOR andAlpha:PAY_SELECTED_ALPHA];
    self.vuSilverImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_SILVER_COLOR];
    
    self.vuCryptoContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CRYPTO_COLOR andAlpha:PAY_SELECTED_ALPHA];
    self.vuCryptoImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CRYPTO_COLOR];
    
    self.vuBarteringContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_BARTERING_COLOR andAlpha:PAY_SELECTED_ALPHA];
    self.vuBarteringImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_BARTERING_COLOR];
    
    self.vuCreditCardContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CREDIT_CARD_COLOR andAlpha:PAY_SELECTED_ALPHA];
    self.vuCreditCardImgContainer.backgroundColor = [C411StaticHelper colorFromHexString:PAY_CREDIT_CARD_COLOR];

}


-(void)addTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgVuAvatarTapped:)];
    [self.imgVuDriver addGestureRecognizer:tapRecognizer];
}

-(void)initializeViewWithAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    ///hide the buttons initially
    self.btnDecideLater.hidden = YES;
    self.btnReject.hidden = YES;
    self.btnConfirm.hidden = YES;
    
    ///Hide the ride response status view initially
    self.lblResponseStatus.text = nil;
    self.cnsResponseStatusLabelTS.constant = 0;
    self.cnsResponseStatusLabelBS.constant = 0;
    self.cnsResponseStatusViewTS.constant = 0;

    ///Hide the payment modes initially
    self.vuPaymentModes.hidden = YES;
    
    ///Show the user image
    //__weak typeof(self) weakSelf = self;
//    [C411StaticHelper getAvatarForUserWithId:alertPayload.strUserId shouldFallbackToGravatar:YES ofSize:self.imgVuDriver.bounds.size.width roundedCorners:NO withCompletion:^(BOOL success, UIImage *image) {
//        
//        if (success && image) {
//            
//            ///Got the image, set it to the imageview
//            weakSelf.imgVuDriver.image = image;
//        }
//        
//        
//    }];

    
    ///Show the car image
//    [C411StaticHelper getCarImageForUserWithId:alertPayload.strUserId withCompletion:^(BOOL success, UIImage *image) {
//        
//        if (success && image) {
//            
//            ///Got the image, set it to the imageview
//            weakSelf.imgVuVehiclePhoto.image = image;
//        }
//        
//        
//    }];

    
    ///show the title
    CGFloat fontSize = self.lblAlertTitle.font.pointSize;
    NSString *strTitleMidText = NSLocalizedString(@"offered to give you a", nil);
    NSString *strTitle = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ %@ ride",nil),alertPayload.strFullName,strTitleMidText];
    NSRange unboldTextRange = NSMakeRange(alertPayload.strFullName.length + 1, strTitleMidText.length);
    self.lblAlertTitle.attributedText = [C411StaticHelper getSemiboldAttributedStringWithString:strTitle ofSize:fontSize withUnboldTextInRange:unboldTextRange];
    
    __weak typeof(self) weakSelf = self;
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
                NSRange driverNameRange = NSMakeRange(0, alertPayload.strFullName.length);
                ///2. set deleted user attribute
                NSMutableAttributedString *attrTitle = weakSelf.lblAlertTitle.attributedText.mutableCopy;
                [attrTitle setAttributes:dictDeletedUserAttr range:driverNameRange];
                weakSelf.lblAlertTitle.attributedText = attrTitle;
            }
            else {
                ///Set profile pic
                [weakSelf.imgVuDriver setAvatarForUser:parseUser shouldFallbackToGravatar:YES ofSize:weakSelf.imgVuDriver.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
                ///Add Tap Gesture on image
                [weakSelf addTapGesture];
                ///Show the car image
                [weakSelf.imgVuVehiclePhoto setCarImageForUser:parseUser withCompletion:NULL];
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
        self.cnsAdditionalNoteTS.constant = 0;
        
    }
    
    ///Fetch and set the current status for ride response and show the action buttons accordingly
    [self fetchRideResponseStatusAndUpdateUI];
    
    ///Get the address for pickup and drop locations
    CLLocationCoordinate2D pickUpCoordinate = CLLocationCoordinate2DMake(alertPayload.pickUpLat, alertPayload.pickUpLon);
    CLLocationCoordinate2D dropCoordinate = CLLocationCoordinate2DMake(alertPayload.dropLat, alertPayload.dropLon);
    self.pickUpLocationTask = [C411StaticHelper updateLocationonLabel:self.lblPickUpAddress usingCoordinate:pickUpCoordinate];
    self.dropLocationTask = [C411StaticHelper updateLocationonLabel:self.lblDropAddress usingCoordinate:dropCoordinate];
    
    ///show cost
    self.lblCost.text = alertPayload.strCost;
    
    ///Show avg rating of driver
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionary];
    dictParams[kAverageStarsFuncParamUserIdKey] = alertPayload.strUserId;
    [C411StaticHelper setAverageRatingForUserWithDetails:dictParams onLabel:self.lblAvgRating];

    ///set additional note title for popup
    NSString *strDriverFirstName = [[alertPayload.strFullName componentsSeparatedByString:@" "]firstObject];
    self.lblAdditionalNoteTitle.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Do you want to send additional note to %@?",nil),strDriverFirstName];
    
    
}

/*
-(void)fetchRideResponseStatusAndUpdateUI
{
    ///Fetch and set the response status for ride and show the action buttons accordingly
    __weak typeof(self) weakSelf = self;
    PFQuery *rideResponseQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
    [rideResponseQuery includeKey:kRideResponseRespondedByKey];
    
    [rideResponseQuery getObjectInBackgroundWithId:self.alertPayload.strRideResponseId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///ride response found
            weakSelf.rideResponse = object;
            
            ///get the status
            NSString *strRideResponseStatus = weakSelf.rideResponse[kRideResponseStatusKey];
            if ([strRideResponseStatus isEqualToString:kRideResponseStatusWaiting]) {
                
                ///show decide later, reject or confirm button
                weakSelf.btnDecideLater.hidden = NO;
                weakSelf.btnReject.hidden = NO;
                weakSelf.btnConfirm.hidden = NO;
                
            }
            else{
                
                ///Show the ride response status view
                self.cnsResponseStatusLabelTS.constant = 5;
                self.cnsResponseStatusLabelBS.constant = 5;
                self.cnsResponseStatusViewTS.constant = 10;

                
                if ([strRideResponseStatus isEqualToString:kRideResponseStatusRejected]){
                    
                    ///set the background color of response status view to red
                    weakSelf.vuResponseStatus.backgroundColor = [UIColor redColor];
                    
                    ///set the rejected text for response status
                    weakSelf.lblResponseStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"You have rejected %@ for this ride",nil),weakSelf.alertPayload.strFullName];
                    
                    ///show the close button
                    [weakSelf showCloseButton];
                    
                }
                else if ([strRideResponseStatus isEqualToString:kRideResponseStatusConfirmed]){
                    
                    ///set the background color of response status view to green
                    weakSelf.vuResponseStatus.backgroundColor = [UIColor greenColor];
                    
                    ///set the confirmed text for response status
                    weakSelf.lblResponseStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"You have selected %@ for this ride",nil),weakSelf.alertPayload.strFullName];
                    
                    ///show small close and call button
                    weakSelf.btnSmallClose.hidden = NO;
                    weakSelf.btnCall.hidden = NO;
                    
                }
            }
            
            ///Set seen status to True if it's not yet updated
            NSNumber *numRideResponseSeenValue = weakSelf.rideResponse[kRideResponseSeenKey];
            
            if ((!numRideResponseSeenValue)
                ||(![numRideResponseSeenValue boolValue])) {
                
                weakSelf.rideResponse[kRideResponseSeenKey] = @(YES);
                [weakSelf.rideResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (error) {
                        ///save the seen status eventually
                        [weakSelf.rideResponse saveEventually];
                    }
                    
                }];
                
            }
            
        }
        else {
            
            ///show the error
            if (error) {
                
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            }
            
            ///unable to fetch ride response details, show the close button
            [weakSelf showCloseButton];
            
            
        }
    }];
    
    
}
*/

-(void)fetchRideResponseStatusAndUpdateUI
{
    ///Fetch and set the response status for ride and show the action buttons accordingly
    __weak typeof(self) weakSelf = self;
    PFQuery *rideResponseQuery = [PFQuery queryWithClassName:kRideResponseClassNameKey];
    [rideResponseQuery includeKey:kRideResponseRespondedByKey];
    
    [rideResponseQuery getObjectInBackgroundWithId:self.alertPayload.strRideResponseId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///ride response found
            weakSelf.rideResponse = object;
            
            ///get the status
            NSString *strRideResponseStatus = weakSelf.rideResponse[kRideResponseStatusKey];
            
            if ([strRideResponseStatus isEqualToString:kRideResponseStatusConfirmed]){
                
                ///set the background color of response status view to green
                weakSelf.vuResponseStatus.backgroundColor = [UIColor greenColor];
                
                ///set the confirmed text for response status
                weakSelf.lblResponseStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"You have selected %@ for this ride",nil),weakSelf.alertPayload.strFullName];
                
                ///show small close and call button
                weakSelf.btnSmallClose.hidden = NO;
                weakSelf.btnCall.hidden = NO;
                
                ///Show the ride response status view
                weakSelf.cnsResponseStatusLabelTS.constant = 5;
                weakSelf.cnsResponseStatusLabelBS.constant = 5;
                weakSelf.cnsResponseStatusViewTS.constant = 10;

            }
            else{
                
                ///Rider may have cancelled the ride or would have selected someone else or it is yet to be selected. So get the ride request object first
                PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
                [rideRequestQuery includeKey:kRideRequestSelectedUserKey];
                [rideRequestQuery getObjectInBackgroundWithId:weakSelf.alertPayload.strRideRequestId block:^(PFObject *object,  NSError *error){
                    
                    if (!error && object) {
                        
                        ///ride request found
                        PFObject *rideRequest = object;
                        ///get the status
                        NSString *strRideStatus = rideRequest[kRideRequestStatusKey];
                        if ([strRideStatus isEqualToString:kRideRequestStatusPending]) {
                            ///Ride request status is still pending, check if it's not yet expired
                            
                            NSTimeInterval createdAtInMillis = [rideRequest.createdAt timeIntervalSince1970]*1000;
                            BOOL isRequestExpired = ![C411StaticHelper isRideRequestValid:@(createdAtInMillis)];
                            
                            if (isRequestExpired == NO) {
                                
                                ///Ride request is not yet expired and no action has been taken yet. See if rider has rejected the driver reponse or not
                                if ([strRideResponseStatus isEqualToString:kRideResponseStatusRejected]){
                                    
                                    ///set the background color of response status view to red
                                    weakSelf.vuResponseStatus.backgroundColor = [UIColor redColor];
                                    
                                    ///set the rejected text for response status
                                    weakSelf.lblResponseStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"You have rejected %@ for this ride",nil),weakSelf.alertPayload.strFullName];
                                    
                                    ///Show the ride response status view
                                    weakSelf.cnsResponseStatusLabelTS.constant = 5;
                                    weakSelf.cnsResponseStatusLabelBS.constant = 5;
                                    weakSelf.cnsResponseStatusViewTS.constant = 10;
                                    

                                    ///show the close button
                                    [weakSelf showCloseButton];
                                    
                                }
                                else{
                                    
                                    ///show decide later, reject or confirm button
                                    weakSelf.btnDecideLater.hidden = NO;
                                    weakSelf.btnReject.hidden = NO;
                                    weakSelf.btnConfirm.hidden = NO;
                                    
                                }
                                
                                
                            }
                            else{
                                ///Ride request is expired
                                ///set the background color of response status view to red
                                weakSelf.vuResponseStatus.backgroundColor = [UIColor redColor];
                                
                                ///set the expired text for response status
                                weakSelf.lblResponseStatus.text = NSLocalizedString(@"This ride request is expired", nil);
                                
                                ///Show the ride response status view
                                weakSelf.cnsResponseStatusLabelTS.constant = 5;
                                weakSelf.cnsResponseStatusLabelBS.constant = 5;
                                weakSelf.cnsResponseStatusViewTS.constant = 10;
                                
                                ///show close button
                                [weakSelf showCloseButton];
                                
                            }
                            
                        }
                        else{
                            
                            if ([strRideStatus isEqualToString:kRideRequestStatusCancelled]) {
                                
                                ///set the background color of response status view to red
                                weakSelf.vuResponseStatus.backgroundColor = [UIColor redColor];
                                
                                ///set the cancelled text for response status
                                weakSelf.lblResponseStatus.text = NSLocalizedString(@"This ride request is cancelled", nil);
                                
                            }
                            else if ([strRideStatus isEqualToString:kRideRequestStatusSelected]) {
                                
                                ///set the background color of response status view to green
                                weakSelf.vuResponseStatus.backgroundColor = [UIColor greenColor];
                                
                                ///Set the selected text with the selected person name
                                PFUser *selectedUser = rideRequest[kRideRequestSelectedUserKey];
                                NSString *strFirstName = selectedUser[kUserFirstnameKey];
                                NSString *strLastName = selectedUser[kUserLastnameKey];
                                NSString *strSelectedUserFullName = [C411StaticHelper getFullNameUsingFirstName:strFirstName andLastName:strLastName];
                                
                                weakSelf.lblResponseStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"You have selected %@ for this ride",nil),strSelectedUserFullName];
                               
                            }
                            
                            ///Show the ride response status view
                            weakSelf.cnsResponseStatusLabelTS.constant = 5;
                            weakSelf.cnsResponseStatusLabelBS.constant = 5;
                            weakSelf.cnsResponseStatusViewTS.constant = 10;
                            
                            ///show close button
                            [weakSelf showCloseButton];
                        }
                        
                    }
                    else {
                        
                        ///show the error
                        if (error) {
                            
                            NSString *errorString = [error userInfo][@"error"];
                            [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                        }
                        
                        ///unable to fetch ride details, show the close button
                        [weakSelf showCloseButton];
                        
                        
                    }
                }];

                
            }

            
            ///Set seen status to True if it's not yet updated
            NSNumber *numRideResponseSeenValue = weakSelf.rideResponse[kRideResponseSeenKey];
            
            if ((!numRideResponseSeenValue)
                ||(![numRideResponseSeenValue boolValue])) {
                
                weakSelf.rideResponse[kRideResponseSeenKey] = @(YES);
                [weakSelf.rideResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (error) {
                        ///save the seen status eventually
                        [weakSelf.rideResponse saveEventually];
                    }
                    
                }];
                
            }
            
            
            ///show Driver ETA
            PFUser *driver = weakSelf.rideResponse[kRideResponseRespondedByKey];
            [weakSelf showETAForDriver:driver];
            
            ///show accepted payment modes for Driver
            [self showAcceptedPaymentModesForDriver:driver];
            
            
        }
        else {
            
            ///show the error
            if (error) {
                
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            }
            
            ///unable to fetch ride response details, show the close button
            [weakSelf showCloseButton];
            
            
        }
    }];
    
    
}

-(void)showAcceptedPaymentModesForDriver:(PFUser *)driver
{
    ///Get the driver profile first
    __weak typeof(self) weakSelf = self;
    [C411StaticHelper getDriverProfileForUser:driver withCompletion:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (!error) {
            
            PFObject *driverProfile = (PFObject *)object;
            
            ///Set the payment modes
            BOOL isCashAccepted = [driverProfile[kDriverProfileIsCashAcceptedKey]boolValue];
            if (!isCashAccepted) {
                weakSelf.lblCash.text = nil;
                weakSelf.cnsCashImgLS.constant = 0;
                weakSelf.cnsCashImgWidth.constant = 0;
                weakSelf.cnsCashLabelLS.constant = 0;
                weakSelf.cnsCashLabelTrailingS.constant = 0;
                weakSelf.cnsSilverVuLS.constant = 0;
                
            }
            
            BOOL isSilverAccepted = [driverProfile[kDriverProfileIsSilverAcceptedKey]boolValue];
            if (!isSilverAccepted) {
                
                weakSelf.lblSilver.text = nil;
                weakSelf.cnsSilverVuLS.constant = 0;
                weakSelf.cnsSilverImgLS.constant = 0;
                weakSelf.cnsSilverImgWidth.constant = 0;
                weakSelf.cnsSilverLabelLS.constant = 0;
                weakSelf.cnsSilverLabelTrailingS.constant = 0;
                
                
            }
            
            BOOL isCryptoAccepted = [driverProfile[kDriverProfileIsCryptoAcceptedKey]boolValue];
            if (!isCryptoAccepted) {
                
                weakSelf.lblCrypto.text = nil;
                weakSelf.cnsCryptoVuLS.constant = 0;
                weakSelf.cnsCryptoImgLS.constant = 0;
                weakSelf.cnsCryptoImgWidth.constant = 0;
                weakSelf.cnsCryptoLabelLS.constant = 0;
                weakSelf.cnsCryptoLabelTrailingS.constant = 0;
                
            }
            
            BOOL isBarteringAccepted = [driverProfile[kDriverProfileIsBarteringAcceptedKey]boolValue];
            if (!isBarteringAccepted) {
                
                weakSelf.lblBartering.text = nil;
                weakSelf.cnsBarteringVuLS.constant = 0;
                weakSelf.cnsBarteringImgLS.constant = 0;
                weakSelf.cnsBarteringImgWidth.constant = 0;
                weakSelf.cnsBarteringLabelLS.constant = 0;
                weakSelf.cnsBarteringLabelTrailingS.constant = 0;
     
            }
            
            BOOL isCreditCardAccepted = [driverProfile[kDriverProfileIsCreditCardAcceptedKey]boolValue];
            if (!isCreditCardAccepted) {
                
                weakSelf.lblCreditCard.text = nil;
                weakSelf.cnsCreditCardVuLS.constant = 0;
                weakSelf.cnsCreditCardImgLS.constant = 0;
                weakSelf.cnsCreditCardImgWidth.constant = 0;
                weakSelf.cnsCreditCardLabelLS.constant = 0;
                weakSelf.cnsCreditCardLabelTrailingS.constant = 0;
                weakSelf.cnsCreditCardLabelWidth.constant = 0;
                
            }
            
            weakSelf.vuPaymentModes.hidden = NO;
            
        }
        else if (error.code == kPFErrorObjectNotFound){
            
            ///Show only cash payment mode
            weakSelf.lblSilver.text = nil;
            weakSelf.cnsSilverVuLS.constant = 0;
            weakSelf.cnsSilverImgLS.constant = 0;
            weakSelf.cnsSilverImgWidth.constant = 0;
            weakSelf.cnsSilverLabelLS.constant = 0;
            weakSelf.cnsSilverLabelTrailingS.constant = 0;
            
            weakSelf.lblCrypto.text = nil;
            weakSelf.cnsCryptoVuLS.constant = 0;
            weakSelf.cnsCryptoImgLS.constant = 0;
            weakSelf.cnsCryptoImgWidth.constant = 0;
            weakSelf.cnsCryptoLabelLS.constant = 0;
            weakSelf.cnsCryptoLabelTrailingS.constant = 0;

            weakSelf.lblBartering.text = nil;
            weakSelf.cnsBarteringVuLS.constant = 0;
            weakSelf.cnsBarteringImgLS.constant = 0;
            weakSelf.cnsBarteringImgWidth.constant = 0;
            weakSelf.cnsBarteringLabelLS.constant = 0;
            weakSelf.cnsBarteringLabelTrailingS.constant = 0;

            weakSelf.lblCreditCard.text = nil;
            weakSelf.cnsCreditCardVuLS.constant = 0;
            weakSelf.cnsCreditCardImgLS.constant = 0;
            weakSelf.cnsCreditCardImgWidth.constant = 0;
            weakSelf.cnsCreditCardLabelLS.constant = 0;
            weakSelf.cnsCreditCardLabelTrailingS.constant = 0;
            weakSelf.cnsCreditCardLabelWidth.constant = 0;

            weakSelf.vuPaymentModes.hidden = NO;

            
        }
        else {
            
            // Show the errorString somewhere and let the user try again.
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"error fetching accepted payment modes for driver:%@",errorString);
            
        }
        
    }];
}



-(void)showETAForDriver:(PFUser *)driver
{
    ///Get the location coordinate for Driver
    PFGeoPoint *driverLocation = driver[kUserLocationKey];
    
    ///Get the pickup coordinate
    CLLocationCoordinate2D pickUpCoordinate = CLLocationCoordinate2DMake(self.alertPayload.pickUpLat, self.alertPayload.pickUpLon);

    ///Get the distance matrix for driver location to pickup locations
    NSString *strOriginLatLong = [NSString stringWithFormat:@"%f,%f",driverLocation.latitude,driverLocation.longitude];
    NSString *strDestLatLong = [NSString stringWithFormat:@"%f,%f",pickUpCoordinate.latitude,pickUpCoordinate.longitude];
    __weak typeof(self) weakSelf = self;
    self.pickUpDistanceMatrixTask = [ServerUtility getDistanceAndDurationMatrixFromLocation:strOriginLatLong toLocation:strDestLatLong andCompletion:^(NSError *error, id data) {
        NSLog(@"%s,data = %@",__PRETTY_FUNCTION__,data);
        
        if (!error && data) {
            
            NSDictionary *dictDistanceMatrix = [C411StaticHelper getDistanceAndDurationFromDistanceMatrixResponse:data];
            NSNumber *numDuration = [dictDistanceMatrix objectForKey:kDistanceMatrixDurationKey];
            if(numDuration){
                
                int seconds = [numDuration intValue];
                int hours = (int)seconds / (60 * 60);
                int remainingSec = seconds % (60 * 60);
                int mins = remainingSec / 60;
                
                NSString *strHourSuffix = hours > 1 ? NSLocalizedString(@"hrs", nil):NSLocalizedString(@"hr", nil);
                NSString *strMinSuffix = mins > 1 ? NSLocalizedString(@"mins", nil):NSLocalizedString(@"min", nil);
                
                NSString *strDuration = nil;
                if (hours > 0 && mins > 0) {
                    
                    ///show hours and mins
                    strDuration = [NSString localizedStringWithFormat:@"%d %@ %d %@",hours,strHourSuffix,mins,strMinSuffix];
                    
                }
                else if (hours > 0){
                    
                    ///show hours
                    strDuration = [NSString localizedStringWithFormat:@"%d %@",hours,strHourSuffix];
                    
                }
                else{
                    
                    ///show mins
                    strDuration = [NSString localizedStringWithFormat:@"%d %@",mins,strMinSuffix];
                    
                }

                
                
                if (strDuration.length > 0) {
                    
                    weakSelf.lblETA.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ is about %@ away",nil),weakSelf.alertPayload.strFullName,strDuration];
                }
                else{
                    
                    weakSelf.lblETA.text = NSLocalizedString(@"N/A", nil);
                    
                }
                
            }
            else{
                
                weakSelf.lblETA.text = NSLocalizedString(@"N/A", nil);
            }
            
        }
        else{
            weakSelf.lblETA.text = NSLocalizedString(@"N/A", nil);
            
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

-(void)updateRideResponse:(PFObject *)rideResponse withStatus:(NSString *)strResponseStatus
{
    ///update the ride response status to rejected/confirmed on parse and show the popup asking for additional note on success
    
    if (rideResponse) {
        
        rideResponse[kRideResponseStatusKey] = strResponseStatus;
        rideResponse[kRideResponseSeenByDriverKey] = @(NO);
        [self showWorkingButton];
        __weak typeof(self) weakSelf = self;
        [rideResponse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            ///Show the ride response status view
            weakSelf.cnsResponseStatusLabelTS.constant = 5;
            weakSelf.cnsResponseStatusLabelBS.constant = 5;
            weakSelf.cnsResponseStatusViewTS.constant = 10;

            if (!error) {
                
                ///ride response updated successfully, show the popup asking for additional note
                weakSelf.vuAdditionalNotePopupBase.hidden = NO;
                
                if ([strResponseStatus isEqualToString:kRideResponseStatusConfirmed]) {
                    
                    ///hide working button
                    [weakSelf hideWorkingButton];
                    ///hide reject button
                    weakSelf.btnReject.hidden = YES;
                    
                    ///show small close and call button
                    weakSelf.btnSmallClose.hidden = NO;
                    weakSelf.btnCall.hidden = NO;
                    
                    ///show green status as the responded driver is selected
                    ///set the background color of response status view to green
                    weakSelf.vuResponseStatus.backgroundColor = [UIColor greenColor];
                    
                    ///set the confirmed text for response status
                    weakSelf.lblResponseStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"You have selected %@ for this ride",nil),weakSelf.alertPayload.strFullName];
                    
                    ///set the ride confirmed flag to Yes
                    weakSelf.rideConfirmed = YES;
                    
                }
                else{
                  
                    ///show close button
                    [weakSelf showCloseButton];

                    ///show red status as the responded driver is rejected
                    ///set the background color of response status view to red
                    weakSelf.vuResponseStatus.backgroundColor = [UIColor redColor];
                    
                    ///set the rejected text for response status
                    weakSelf.lblResponseStatus.text = [NSString localizedStringWithFormat:NSLocalizedString(@"You have rejected %@ for this ride",nil),weakSelf.alertPayload.strFullName];
                    
                }

            }
            else{
                
                ///show the error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
                
                ///hide the working button and give user another chance
                [weakSelf hideWorkingButton];
            }
            
        }];
    }

}

-(void)addAdditionalNote:(NSString *)strAdditionalNote fromRiderForRideResponseWithId:(NSString *)strRideResponseId andCompletion:(PFBooleanResultBlock)completion
{
    PFObject *additionalNote4Ride = [PFObject objectWithClassName:kAdditionalNote4RideClassNameKey];
    
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *strWriterName = [C411StaticHelper getFullNameUsingFirstName:currentUser[kUserFirstnameKey] andLastName:currentUser[kUserLastnameKey]];
    
    additionalNote4Ride[kAddNote4RideWriterIdKey] = currentUser.objectId;
    additionalNote4Ride[kAddNote4RideWriterNameKey] = strWriterName;
    additionalNote4Ride[kAddNote4RideNoteKey] = strAdditionalNote;
    additionalNote4Ride[kAddNote4RideRideResponseIdKey] = strRideResponseId;
//    additionalNote4Ride[kAddNote4RideAlertTypeKey] = strAlertType;
//    additionalNote4Ride[kAddNote4RideSeenKey] = @(0);///Initially it will be unseen
    
    [additionalNote4Ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (completion != NULL) {
            
            completion(succeeded,error);
        }
        
    }];
    
}

-(void)sendRideRejectedPushNotificationToDriver:(PFUser *)driver withAdditionalNote:(NSString *)strAdditionalNote andAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    ///make payload and send push
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *userFirstName = currentUser[kUserFirstnameKey];
    NSString *userLastName = currentUser[kUserLastnameKey];
    NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:userFirstName andLastName:userLastName];
    
    NSString *strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"has rejected your ride :(", nil)];
    NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
    dictData[kPayloadAlertKey] = strAlertMsg;
    dictData[kPayloadUserIdKey] = currentUser.objectId;
    if (strAdditionalNote.length > 0) {
        dictData[kPayloadAdditionalNoteKey] = strAdditionalNote;
       
    }
    
    ///Get ride response time in milliseconds
    double rideResponseTimeInMillis = alertPayload.createdAtInMillis;
    dictData[kPayloadCreatedAtKey] = @(rideResponseTimeInMillis);
    dictData[kPayloadNameKey] = strFullName;
    dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeRideRejected;
    dictData[kPayloadRideResponseIdKey] = alertPayload.strRideResponseId;
    dictData[kPayloadSoundKey] = @"default";///To play default sound
    dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:kInstallationUserKey equalTo:driver];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:dictData];
    
    ///Send Push notification
    [push sendPushInBackground];


}

-(void)sendRideConfirmedPushNotificationToDriver:(PFUser *)driver withAdditionalNote:(NSString *)strAdditionalNote andAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    
    ///make payload and send push
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *userFirstName = currentUser[kUserFirstnameKey];
    NSString *userLastName = currentUser[kUserLastnameKey];
    NSString *strFullName = [C411StaticHelper getFullNameUsingFirstName:userFirstName andLastName:userLastName];
    
    NSString *strAlertMsg = [NSString stringWithFormat:@"%@ %@",strFullName,NSLocalizedString(@"approved your ride!", nil)];
    NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
    dictData[kPayloadAlertKey] = strAlertMsg;
    dictData[kPayloadUserIdKey] = currentUser.objectId;
    if (strAdditionalNote.length > 0) {
        dictData[kPayloadAdditionalNoteKey] = strAdditionalNote;
        
    }
    
    ///Get ride response time in milliseconds
    double rideResponseTimeInMillis = alertPayload.createdAtInMillis;
    dictData[kPayloadCreatedAtKey] = @(rideResponseTimeInMillis);
    dictData[kPayloadNameKey] = strFullName;
    dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeRideConfirmed;
    dictData[kPayloadRideResponseIdKey] = alertPayload.strRideResponseId;
    dictData[kPayloadPickUpLatKey] = @(alertPayload.pickUpLat);
    dictData[kPayloadPickUpLongKey] = @(alertPayload.pickUpLon);
    dictData[kPayloadDropLatKey] = @(alertPayload.dropLat);
    dictData[kPayloadDropLongKey] = @(alertPayload.dropLon);
    dictData[kPayloadSoundKey] = @"default";///To play default sound
    dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:kInstallationUserKey equalTo:driver];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:dictData];
    
    ///Send Push notification
    [push sendPushInBackground];
    
    
}

-(void)sendRideSelectedPushNotificationToDrivers:(NSArray *)arrDrivers forSelectedDriver:(PFUser *)selectedDriver usingAlertPayload:(C411AlertNotificationPayload *)alertPayload
{
    ///make payload and send push
    PFUser *currentUser = [AppDelegate getLoggedInUser];
    NSString *userFirstName = currentUser[kUserFirstnameKey];
    NSString *userLastName = currentUser[kUserLastnameKey];
    NSString *strRiderName = [C411StaticHelper getFullNameUsingFirstName:userFirstName andLastName:userLastName];
    
    NSString *selectedDriverFirstName = selectedDriver[kUserFirstnameKey];
    NSString *selectedDriverLastName = selectedDriver[kUserLastnameKey];
    NSString *strSelectedDriverName = [C411StaticHelper getFullNameUsingFirstName:selectedDriverFirstName andLastName:selectedDriverLastName];

    
    NSString *strAlertMsg = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ selected %@'s ride",nil),strRiderName,strSelectedDriverName];
    NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
    dictData[kPayloadAlertKey] = strAlertMsg;
    dictData[kPayloadUserIdKey] = currentUser.objectId;
    
    ///Get ride response time in milliseconds
    double rideResponseTimeInMillis = alertPayload.createdAtInMillis;
    dictData[kPayloadCreatedAtKey] = @(rideResponseTimeInMillis);
    dictData[kPayloadNameKey] = strRiderName;
    dictData[kPayloadAlertTypeKey] = kPayloadAlertTypeRideSelected;
    dictData[kPayloadSoundKey] = @"default";///To play default sound
    dictData[kPayloadBadgeKey] = kPayloadBadgeValueIncrement;
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:kInstallationUserKey containedIn:arrDrivers];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:dictData];
    
    ///Send Push notification
    [push sendPushInBackground];

}

-(void)sendRideConfirmedPushNotificationsUsingAlertPayload:(C411AlertNotificationPayload *)alertPayload withAdditionalNote:(NSString *)strAdditionalNote withCompletion:(PFBooleanResultBlock)completion
{
    PFUser *selectedDriver = self.rideResponse[kRideResponseRespondedByKey];
    
    ///send ride confirmed notification to selected driver
    [self sendRideConfirmedPushNotificationToDriver:selectedDriver withAdditionalNote:strAdditionalNote andAlertPayload:alertPayload];
    
    ///Get the drivers other than the selected driver to whom ride request has been sent and are not spammed by current user
    __weak typeof(self) weakSelf = self;
    [self getFilteredDriversForRideWithRequestId:alertPayload.strRideRequestId otherThanSelectedDriver:selectedDriver andCompletion:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        NSArray *arrFilteredDrivers = objects;
        if (arrFilteredDrivers.count > 0) {
            ///Notify the other drivers about the selected driver for this ride
            [weakSelf sendRideSelectedPushNotificationToDrivers:arrFilteredDrivers forSelectedDriver:selectedDriver usingAlertPayload:alertPayload];
            
        }
        
        ///call the completion block
        if (completion != NULL) {
            ///There is no meaning of success here, so better check for error if you want to know whether it succeeded or not
            completion(YES,error);
        }
        
        
    }];
    
    
}

-(void)getFilteredDriversForRideWithRequestId:(NSString *)strRideRequestId otherThanSelectedDriver:(PFUser *)selectedDriver andCompletion:(PFArrayResultBlock)completion
{
    PFQuery *getRideDriversQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [getRideDriversQuery whereKey:@"objectId" equalTo:strRideRequestId];
    [getRideDriversQuery selectKeys:@[kRideRequestTargetMembersKey]];
    
    [getRideDriversQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (object) {
            
            PFObject *rideRequest = object;
            ///get the target members(drivers)
            NSArray *arrRideDrivers = rideRequest[kRideRequestTargetMembersKey];
            
            ///make a mutable array of filtered drivers
            NSMutableArray *arrNonSelectedDrivers = [NSMutableArray array];
            for (PFUser *driver in arrRideDrivers) {
                
                if (![driver.objectId isEqualToString:selectedDriver.objectId]) {
                    
                    ///add the driver to non selected driver list
                    [arrNonSelectedDrivers addObject:driver];
                    
                }
                
            }
            
            ///Filter the array by removing members who have spammed current user
            [[AppDelegate sharedInstance]filteredArrayByRemovingMembersInSpammedByRelationFromArray:arrNonSelectedDrivers withCompletion:^(id result, NSError *error) {
                
                NSArray *arrSpammedByFilteredDrivers = (NSArray *)result;
                if (arrSpammedByFilteredDrivers.count > 0) {
                    
                    ///Filter the array by removing members who have been spammed by current user
                    [[AppDelegate sharedInstance]filteredArrayByRemovingMembersInSpammedUsersRelationFromArray:arrSpammedByFilteredDrivers withCompletion:^(id result, NSError *error) {
                        
                        NSArray *arrFilteredDrivers = (NSArray *)result;
                        if (completion != NULL) {
                            
                            completion(arrFilteredDrivers, error);
                        }
                        
                    }];
                }
                else{
                    
                    ///call the completion block
                    if (completion != NULL) {
                        
                        completion(arrSpammedByFilteredDrivers,error);
                        
                    }
                }
            }];
            
             
        }
        else{
            
            ///call the completion block
            if (completion != NULL) {
                
                completion(nil,error);
            }
        }
        
    }];
}

-(void)setSelectedUser:(PFUser *)selectedDriver forRideWithRequestId:(NSString *)strRideRequestId withCompletion:(PFBooleanResultBlock)completion
{
    ///Fetch and set the ride status and selectedUser for ride
    PFQuery *rideRequestQuery = [PFQuery queryWithClassName:kRideRequestClassNameKey];
    [rideRequestQuery getObjectInBackgroundWithId:strRideRequestId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            PFObject *rideRequest = object;
            rideRequest[kRideRequestSelectedUserKey] = selectedDriver;
            rideRequest[kRideRequestStatusKey] = kRideRequestStatusSelected;
            
            ///Save it in background
            [rideRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    
                    ///save it eventually if error occured
                    [rideRequest saveEventually];
                    
                }
                
                
            }];
            
            ///Call the completion block
            if (completion != NULL) {
                
                completion(YES,error);
            }

        }
        else{
            ///show the error
            if (error) {
                
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];
            }
            
            ///Call the completion block
            if (completion != NULL) {
                
                completion(NO,error);
            }

            
        }
    }];

}

//****************************************************
#pragma mark - Action Methods
//****************************************************

- (IBAction)btnDecideLaterTapped:(UIButton *)sender {
    
    if (self.actionHandler != NULL) {
        ///call the Decide later action handler
        self.actionHandler(sender,0,nil);
        
    }
    
    ///remove the view from superview
    [self removeFromSuperview];
    self.actionHandler = NULL;

}

- (IBAction)btnRejectTapped:(UIButton *)sender {
    
    ///update the ride response status to rejected on parse and show the popup asking for additional note on success
    [self updateRideResponse:self.rideResponse withStatus:kRideResponseStatusRejected];
    
}

- (IBAction)btnConfirmTapped:(UIButton *)sender {
    
    ///Set the selected driver for ride request
    [self showWorkingButton];
    __weak typeof(self) weakSelf = self;
    [self setSelectedUser:self.rideResponse[kRideResponseRespondedByKey] forRideWithRequestId:self.alertPayload.strRideRequestId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (succeeded) {
            
            ///update the ride response status to confirmed on parse and show the popup asking for additional note on success
            [weakSelf updateRideResponse:weakSelf.rideResponse withStatus:kRideResponseStatusConfirmed];
            
            ///Post notification to hide overlay if shown for this ride request
            [[NSNotificationCenter defaultCenter]postNotificationName:kHideRideOverlayNotification object:weakSelf.alertPayload.strRideRequestId];

            
        }
        else{
            
            ///Hide the working button
            [weakSelf hideWorkingButton];
        }
        
    }];
    


}

- (IBAction)btnCloseTapped:(UIButton *)sender {
    
    if (self.actionHandler != NULL) {
        ///call the Decide later action handler
        self.actionHandler(sender,0,nil);
        
    }
    
    ///remove the view from superview
    [self removeFromSuperview];
    self.actionHandler = NULL;

}

- (IBAction)btnCallTapped:(UIButton *)sender {
    
    ///Call the driver
    PFUser *driver = self.rideResponse[kRideResponseRespondedByKey];
    [C411StaticHelper callUser:driver];
}

- (IBAction)btnSendTapped:(UIButton *)sender {
    
    ///Remove the keyboard
    [self endEditing:YES];

    ///Check ride response status and if it's rejected then notify the driver that he has been rejected, otherwise if it's confirmed then notify the driver that he has been selected and notify other drivers who showed interest for this ride that this driver is selected
    NSString *strAdditonalNoteFromRider = [self.txtAdditionalNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    ///hide the additional note popup
    self.vuAdditionalNotePopupBase.hidden = YES;

    BOOL isRideConfirmed = NO;
    if ([self.rideResponse[kRideResponseStatusKey] isEqualToString:kRideResponseStatusConfirmed]) {
        
        isRideConfirmed = YES;
        
    }
    
    ///Show the progress hud
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    __weak typeof(self) weakSelf = self;

    if (strAdditonalNoteFromRider.length > 0) {
        
        [self addAdditionalNote:strAdditonalNoteFromRider fromRiderForRideResponseWithId:self.alertPayload.strRideResponseId andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (!error) {
                
                ///send the push notifications
                if (isRideConfirmed) {
                    
                    ///Current user(rider) confirmed the ride of this driver,send ride confirmed notifications
                    [weakSelf sendRideConfirmedPushNotificationsUsingAlertPayload:weakSelf.alertPayload withAdditionalNote:strAdditonalNoteFromRider withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                        
                        if (error) {
                            
                            ///log the error
                            NSLog(@"Some error occurred sending push to other drivers --> %@",error);
                            
                        }
                        
                        ///Hide the progress hud
                        [MBProgressHUD hideHUDForView:weakSelf animated:YES];
                    }];
                    
                }
                else{
                    
                    ///Current user(rider) rejected the ride of this driver, send ride rejected notifications
                    [weakSelf sendRideRejectedPushNotificationToDriver:weakSelf.rideResponse[kRideResponseRespondedByKey] withAdditionalNote:strAdditonalNoteFromRider andAlertPayload:weakSelf.alertPayload];
                   

                    ///Hide the progress hud
                    [MBProgressHUD hideHUDForView:weakSelf animated:YES];

                }
                
                
            }
            else{
                
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                [C411StaticHelper showAlertWithTitle:nil message:errorString onViewController:[AppDelegate sharedInstance].window.rootViewController];

                ///Hide the progress hud
                [MBProgressHUD hideHUDForView:weakSelf animated:YES];

            }
            
            
        }];
        
    }
    else{
        
        ///Just send the push notifications
        if (isRideConfirmed) {
            
            ///Current user(rider) confirmed the ride of this driver
            [self sendRideConfirmedPushNotificationsUsingAlertPayload:self.alertPayload withAdditionalNote:nil withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    
                    ///log the error
                    NSLog(@"Some error occurred sending push to other drivers --> %@",error);
                    
                }
                
                ///Hide the progress hud
                [MBProgressHUD hideHUDForView:weakSelf animated:YES];

                
            }];
        }
        else{
            
            ///Current user(rider) rejected the ride of this driver
            [self sendRideRejectedPushNotificationToDriver:self.rideResponse[kRideResponseRespondedByKey] withAdditionalNote:nil andAlertPayload:self.alertPayload];
            
            ///Hide the progress hud
            [MBProgressHUD hideHUDForView:weakSelf animated:YES];

        }
    }

}

- (void)imgVuAvatarTapped:(UITapGestureRecognizer *)sender {
    ///Show photo VC to view photo alert
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411ViewPhotoVC *viewPhotoVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411ViewPhotoVC"];
    viewPhotoVC.imgPhoto = self.imgVuDriver.image;
    [navRoot pushViewController:viewPhotoVC animated:YES];
}

- (IBAction)btnShowRatingTapped:(UIButton *)sender {
    
    UINavigationController *navRoot = (UINavigationController *)[AppDelegate sharedInstance].window.rootViewController;
    C411RideReviewsVC *rideReviewsVC = [navRoot.storyboard instantiateViewControllerWithIdentifier:@"C411RideReviewsVC"];
    if ([self.rideResponse[kRideResponseStatusKey] isEqualToString:kRideResponseStatusConfirmed]) {
        
        rideReviewsVC.rideConfirmed = YES;
        
    }
    PFUser *driver = self.rideResponse[kRideResponseRespondedByKey];

    if (driver) {
        
        rideReviewsVC.targetUser = driver;
    }
    else{
        
        rideReviewsVC.targetUserId = self.alertPayload.strUserId;
    }
    
    [navRoot pushViewController:rideReviewsVC animated:YES];
    
    
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
