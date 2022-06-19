//
//  C411FriendDetailedCell.h
//  cell411
//
//  Created by Milan Agarwal on 02/06/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"
#import <CoreLocation/CoreLocation.h>

@interface C411PublicCellMemberCell : UITableViewCell
@property (weak, nonatomic) IBOutlet RFGravatarImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblMemberName;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
//@property (weak, nonatomic) IBOutlet UIButton *btnRemoveMember;

-(void)updateLocationUsingCoordinate:(CLLocationCoordinate2D)locCoordinate;

@end
