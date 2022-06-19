//
//  C411CellSelectionCell.m
//  cell411
//
//  Created by Milan Agarwal on 02/09/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "C411CellSelectionCell.h"
#import "Constants.h"
#import "C411ColorHelper.h"

@implementation C411CellSelectionCell

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
    self.imgVuCell.layer.cornerRadius = self.imgVuCell.bounds.size.width / 2;
    self.imgVuCell.layer.masksToBounds = YES;
    
    ///Disable user interaction of checkbox so touch event could be
    ///passed to tableview:didSelectRowAtIndexpath
    self.btnCheckbox.userInteractionEnabled = NO;
    [self applyColors];
}

-(void)applyColors
{
    self.lblCellName.textColor = [C411ColorHelper sharedInstance].primaryTextColor;
    self.btnCheckbox.fillColor = [C411ColorHelper sharedInstance].themeColor;
    self.btnCheckbox.borderColor = [C411ColorHelper sharedInstance].secondaryTextColor;
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
