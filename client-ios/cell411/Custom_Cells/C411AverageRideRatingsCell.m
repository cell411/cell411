//
//  C411AverageRideRatingsCell.m
//  cell411
//
//  Created by Milan Agarwal on 04/11/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411AverageRideRatingsCell.h"
#import "C411StaticHelper.h"
#import "ConfigConstants.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411AverageRideRatingsCell

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
    [C411StaticHelper makeCircularView:self.vuAverageRatings];
    [self applyColors];
}

-(void)applyColors
{
    self.lblRatingsCount.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.imgVuRatingsCount.tintColor = [C411ColorHelper sharedInstance].darkHintIconColor;
    self.vuAverageRatings.backgroundColor = [C411ColorHelper sharedInstance].themeColor;
    self.lblAverageRatings.textColor = [C411ColorHelper sharedInstance].primaryBGTextColor;
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(darkModeValueDidChanged:) name:kDarkModeValueChangedNotification object:nil];
}

-(void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



-(void)setAverageRating:(float)avgRating withRatingCount:(int)totalRatingCount
{
    ///set one decimal place rating on label
    NSString *strAvgRating = [C411StaticHelper getDecimalStringFromNumber:@(avgRating) uptoDecimalPlaces:1];
    self.lblAverageRatings.text = strAvgRating;
    
    ///set rating count
    self.lblRatingsCount.text = [NSString localizedStringWithFormat:@"%d",totalRatingCount];
    
    ///set stars
    NSInteger baseTag = [[self.imgVuRatingStars firstObject]tag];
    static UIImage *filledStar = nil;
    static UIImage *greyStar = nil;
    static UIImage *halfFilledStar = nil;
    if (!filledStar) {
        
        filledStar = [UIImage imageNamed:@"ic_filled_star_large"];
        
    }
    
    if (!greyStar) {
        
        greyStar = [UIImage imageNamed:@"ic_grey_star_large"];
        
    }
    
    if (!halfFilledStar) {
        
        halfFilledStar = [UIImage imageNamed:@"ic_half_filled_star_large"];
        
    }
    
    for (NSInteger index = 0; index < self.imgVuRatingStars.count; index++) {
        
        UIImageView *imgVuStar = [self.imgVuRatingStars objectAtIndex:index];
        if (imgVuStar.tag < (baseTag + (int)avgRating)) {
            ///set filled star
            imgVuStar.image = filledStar;
        }
        else if ((baseTag + avgRating - imgVuStar.tag) > 0 && (baseTag + avgRating - imgVuStar.tag) < 0.9){
            
            ///Set half filled star
            imgVuStar.image = halfFilledStar;
            
        }
        else{
            
            ///set grey star
            imgVuStar.image = greyStar;
            
        }
        
    }

}


/*
-(void)setAverageRatingForUser:(PFUser *)user
{
    NSDictionary *dictParams = @{kAverageStarsFuncParamUserIdKey:user.objectId};
    __weak typeof(self) weakSelf = self;
    [C411StaticHelper getAverageStarsForUserWithDetails:dictParams andCompletion:^(id  _Nullable object, NSError * _Nullable error) {
        
        NSString *strRatingComponents = (NSString *)object;
        NSArray *arrRatingComponents = [strRatingComponents componentsSeparatedByString:@","];
        int totalRatingCount = [[arrRatingComponents firstObject]intValue];
        weakSelf.lblRatingsCount.text = [NSString localizedStringWithFormat:@"%d",totalRatingCount];
        
        float avgRating = [[arrRatingComponents lastObject]floatValue];
        [weakSelf setAverageRating:avgRating];
        
    }];
}
*/

//****************************************************
#pragma mark - Notifications Methods
//****************************************************
-(void)darkModeValueDidChanged:(NSNotification *)notif {
    ///Re apply the colors
    [self applyColors];
}

@end
