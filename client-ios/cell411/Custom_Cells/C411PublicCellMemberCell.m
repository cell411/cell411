//
//  C411FriendDetailedCell.m
//  cell411
//
//  Created by Milan Agarwal on 02/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411PublicCellMemberCell.h"
#import "Constants.h"
//#import "ServerUtility.h"
#import "C411StaticHelper.h"
#import "C411ColorHelper.h"

@interface C411PublicCellMemberCell ()

//@property (nonatomic, strong) NSURLSessionDataTask *getLocationTask;

@end

@implementation C411PublicCellMemberCell


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
    ///configure member image
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    
    ///configure status button
    //self.btnRemoveMember.layer.cornerRadius = 3.0;

    [self applyColors];
}

-(void)applyColors
{
    ///set primary text color
    self.lblMemberName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    
    ///Set secondary text color
    self.lblLocation.textColor = [C411ColorHelper sharedInstance].secondaryTextColor;
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
