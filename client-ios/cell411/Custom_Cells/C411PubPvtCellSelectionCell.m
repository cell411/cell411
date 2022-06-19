//
//  C411PubPvtCellSelectionCell.m
//  cell411
//
//  Created by Milan Agarwal on 20/04/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "C411PubPvtCellSelectionCell.h"
#import "C411StaticHelper.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411PubPvtCellSelectionCell

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

-(void)dealloc {
    [self unregisterFromNotifications];
}

//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)configureViews
{
    [C411StaticHelper makeCircularView:self.imgVuCell];
    [C411StaticHelper makeCircularView:self.imgVuVerified];
    [self applyColors];
}

-(void)applyColors
{
    ///set primary text color
    UIColor *primaryTextColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.tglBtnCellSelection.tintColor = primaryTextColor;
    self.lblCellName.textColor = primaryTextColor;
    
    ///Set secondary text color
    UIColor *secondaryTextColor = [C411ColorHelper sharedInstance].secondaryTextColor;
    self.lblCellType.textColor = secondaryTextColor;
    
    self.imgVuVerified.layer.borderColor = [UIColor whiteColor].CGColor;
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
