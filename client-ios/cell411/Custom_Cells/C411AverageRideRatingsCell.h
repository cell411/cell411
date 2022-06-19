//
//  C411AverageRideRatingsCell.h
//  cell411
//
//  Created by Milan Agarwal on 04/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFUser;

@interface C411AverageRideRatingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vuAverageRatings;
@property (weak, nonatomic) IBOutlet UILabel *lblAverageRatings;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imgVuRatingStars;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuRatingsCount;
@property (weak, nonatomic) IBOutlet UILabel *lblRatingsCount;

//-(void)setAverageRatingForUser:(PFUser *)user;

-(void)setAverageRating:(float)avgRating withRatingCount:(int)totalRatingCount;

@end
