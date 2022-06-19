//
//  C411RideRequestsCell.m
//  cell411
//
//  Created by Milan Agarwal on 03/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411RideRequestsCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@interface C411RideRequestsCell ()

@property (nonatomic, strong) NSURLSessionDataTask *pickUpLocationTask;
@property (nonatomic, strong) NSURLSessionDataTask *dropLocationTask;


@end

@implementation C411RideRequestsCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.lblPickupAddress.text = nil;
    self.lblDropAddress.text = nil;
    [self configureViews];
    [self registerForNotifications];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    [self.pickUpLocationTask cancel];
    self.pickUpLocationTask = nil;
    [self.dropLocationTask cancel];
    self.dropLocationTask = nil;
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(void)setPickupLocation:(CLLocationCoordinate2D)pickupLocation
{
    _pickupLocation = pickupLocation;

    if (self.lblPickupAddress.text.length == 0) {
       
        ///Get the address for pickup locations
        [self.pickUpLocationTask cancel];
        self.lblPickupAddress.text = NSLocalizedString(@"Retreiving...", nil);
        self.pickUpLocationTask = [C411StaticHelper updateLocationonLabel:self.lblPickupAddress usingCoordinate:pickupLocation];

    }

}

-(void)setDropLocation:(CLLocationCoordinate2D)dropLocation
{
    _dropLocation = dropLocation;
    
    if (self.lblDropAddress.text.length == 0) {
        ///Get the address for drop locations
        [self.dropLocationTask cancel];
        self.lblDropAddress.text = NSLocalizedString(@"Retreiving...", nil);
        self.dropLocationTask = [C411StaticHelper updateLocationonLabel:self.lblDropAddress usingCoordinate:dropLocation];

    }
    
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///make circular images
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    
    ///configure status button
    self.btnFlag.layer.cornerRadius = 3.0;
    
    self.vuAlertBase.layer.cornerRadius = 3.0;
    self.vuAlertBase.layer.shadowOffset = CGSizeMake(0, 1);
    self.vuAlertBase.layer.shadowOpacity = 0.8;
    self.vuAlertBase.layer.masksToBounds = NO;
    
    [self applyColors];
}

-(void)applyColors
{
    ///Set light card color
    self.vuAlertBase.backgroundColor = [C411ColorHelper sharedInstance].lightCardColor;
    
    ///Set Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblAlertTitle.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblAlertTimestamp.textColor = secondaryTextColor;
    self.lblPickupAddress.textColor = secondaryTextColor;
    self.lblDropAddress.textColor = secondaryTextColor;
    self.imgVuClock.tintColor = [C411ColorHelper sharedInstance].hintIconColor;

    self.vuAlertBase.layer.shadowColor = [C411ColorHelper sharedInstance].fabShadowColor.CGColor;
    
    ///Set dark hint color
    UIColor *darkHintIconColor = [C411ColorHelper sharedInstance].darkHintIconColor;
    self.imgVuRequestIndicator.tintColor = darkHintIconColor;
    
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
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
