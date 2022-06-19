//
//  C411OthersRideReviewCell.m
//  cell411
//
//  Created by Milan Agarwal on 04/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411OthersRideReviewCell.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "UIImageView+ImageDownloadHelper.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411OthersRideReviewCell

//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self configureViews];
    [self registerForNotifications];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)dealloc
{
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    ///make circular images
    [C411StaticHelper makeCircularView:self.imgVuAvatar];
    
    [self applyColors];
}

-(void)applyColors
{
    ///Set Text Color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.lblName.textColor = primaryTextColor;
    self.lblReviewTitle.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblTimeStamp.textColor = secondaryTextColor;
    self.lblReviewComment.textColor = secondaryTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)setRating:(int)rating onImageViewCollection:(NSArray *)arrRatingStars{
    
    NSInteger baseTag = [[arrRatingStars firstObject]tag];
    static UIImage *filledStar = nil;
    static UIImage *greyStar = nil;
    if (!filledStar) {
        
        filledStar = [UIImage imageNamed:@"ic_filled_star_large"];
        
    }
    
    if (!greyStar) {
        
        greyStar = [UIImage imageNamed:@"ic_grey_star_large"];
        
    }
    for (NSInteger index = 0; index < arrRatingStars.count; index++) {
        
        UIImageView *imgVuStar = [arrRatingStars objectAtIndex:index];
        if (imgVuStar.tag < (baseTag + rating)) {
            ///set filled star
            imgVuStar.image = filledStar;
        }
        else{
            ///set grey star
            imgVuStar.image = greyStar;
        }
        
    }
}

//****************************************************
#pragma mark - Public Methods
//****************************************************

-(void)setDataUsingObject:(PFObject *)review
{
    ///set avatar
    PFUser *ratedByUser = review[kReviewRatedByKey];
    if([C411StaticHelper isUserDeleted:ratedByUser]){
        ///set name color as disabled
        self.lblName.textColor = [C411ColorHelper sharedInstance].deletedUserTextColor;
    }
    else {
        ///Show avatar
        [self.imgVuAvatar setAvatarForUser:ratedByUser shouldFallbackToGravatar:YES ofSize:self.imgVuAvatar.bounds.size.width * 3 roundedCorners:NO withCompletion:NULL];
        ///Set name color as primary text color
        self.lblName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    }
    
    ///Set Name
    NSString *strRatedByUserName = [C411StaticHelper getFullNameUsingFirstName:ratedByUser[kUserFirstnameKey] andLastName:ratedByUser[kUserLastnameKey]];
    self.lblName.text = strRatedByUserName;
    
    ///set rating
    int rating = [review[kReviewRatingKey]intValue];
    [self setRating:rating onImageViewCollection:self.imgVuRatingStars];
    
    ///set timestamp
    NSDate *reviewDate = review.createdAt;
    self.lblTimeStamp.text = [C411StaticHelper getFormattedTimeFromDate:reviewDate withFormat:TimeStampFormatDateOrTime];
    
    ///set title
    self.lblReviewTitle.text = review[kReviewTitleKey];
    
    ///set comment
    self.lblReviewComment.text = review[kReviewCommentKey];
    
    
}

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
