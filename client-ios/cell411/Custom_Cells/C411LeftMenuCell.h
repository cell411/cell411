//
//  C411LeftMenuCell.h
//  cell411
//
//  Created by Milan Agarwal on 23/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C411LeftMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVuMenuIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblMenuTitle;
@property (weak, nonatomic) IBOutlet UIView *vuSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuRedirectIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRedirectIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsRedirectIconTS;
@property (nonatomic, assign) BOOL willRedirectOutsideApp;
@end
