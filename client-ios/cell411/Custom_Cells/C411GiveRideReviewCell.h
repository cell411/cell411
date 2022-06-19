//
//  C411GiveRideReviewCell.h
//  cell411
//
//  Created by Milan Agarwal on 04/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C411GiveRideReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vuContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btnRatingStars;
@end
