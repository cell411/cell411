//
//  C411PublicCellBasicDetailCell.h
//  cell411
//
//  Created by Milan Agarwal on 02/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface C411PublicCellBasicDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCell;
@property (weak, nonatomic) IBOutlet UIView *vuCellNameIconBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCellIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblCellName;
@property (weak, nonatomic) IBOutlet UIView *vuCategoryIconBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCategoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;
@property (weak, nonatomic) IBOutlet UIView *vuLocationIconBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuLocationIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDescriptionHeading;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

-(void)updateLocationUsingCoordinate:(CLLocationCoordinate2D)locCoordinate;

@end
