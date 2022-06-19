//
//  C411PublicCellBasicDetailCell.m
//  cell411
//
//  Created by Milan Agarwal on 02/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PublicCellBasicDetailCell.h"
#import "ConfigConstants.h"
#import "C411StaticHelper.h"
//#import "ServerUtility.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@interface C411PublicCellBasicDetailCell ()

//@property (nonatomic, strong) NSURLSessionDataTask *getLocationTask;

@end

@implementation C411PublicCellBasicDetailCell


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self configureViews];
    [self registerForNotifications];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc {
    [self unregisterFromNotifications];
}


//****************************************************
#pragma mark - Private Methods
//****************************************************


-(void)configureViews
{
    ///configure cell image
    [C411StaticHelper makeCircularView:self.imgVuCell];
    [C411StaticHelper makeCircularView:self.vuCellNameIconBG];
    [C411StaticHelper makeCircularView:self.vuCategoryIconBG];
    [C411StaticHelper makeCircularView:self.vuLocationIconBG];
    
    [self applyColors];
}

-(void)applyColors
{
    ///set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblCellName.textColor = primaryTextColor;
    self.lblCategory.textColor = primaryTextColor;
    self.lblLocation.textColor = primaryTextColor;
    self.lblDescriptionHeading.textColor = primaryTextColor;

    ///Set secondary text color
    self.lblDescription.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    
    ///Set theme color
    UIColor *themeColor = [C411ColorHelper sharedInstance].themeColor;
    self.vuCellNameIconBG.backgroundColor = themeColor;
    self.vuCategoryIconBG.backgroundColor = themeColor;
    self.vuLocationIconBG.backgroundColor = themeColor;

    ///Set primaryBgText color
    UIColor *primaryBGTextColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
    self.imgVuCellIcon.tintColor = primaryBGTextColor;
    self.imgVuCategoryIcon.tintColor = primaryBGTextColor;
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


//****************************************************
#pragma mark - Public Methods
//****************************************************


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
                
                weakSelf.lblLocation.text = firstAddress.locality;
            }
            else{
                
                weakSelf.lblLocation.text = NSLocalizedString(@"N/A", nil);
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
                
                weakSelf.lblLocation.text = [C411StaticHelper getAddressCompFromResult:addcomponents forType:kGeocodeTypeLocality useLongName:YES];
            }
            else{
                
                weakSelf.lblLocation.text = NSLocalizedString(@"N/A", nil);
            }
            
            
        }
        
    }];
    */
}

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}



@end
