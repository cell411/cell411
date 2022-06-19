//
//  C411MyRideReviewCell.h
//  cell411
//
//  Created by Milan Agarwal on 04/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultilineLabel.h"
@class PFObject;

@interface C411MyRideReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vuContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imgVuRatingStars;
@property (weak, nonatomic) IBOutlet UIButton *btnEditMyReview;
@property (weak, nonatomic) IBOutlet MultilineLabel *lblReviewTitle;
@property (weak, nonatomic) IBOutlet MultilineLabel *lblReviewComment;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeStamp;
@property (weak, nonatomic) IBOutlet UIView *vuYou;

-(void)setDataUsingObject:(PFObject *)review;

@end
