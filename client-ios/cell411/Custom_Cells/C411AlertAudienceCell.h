//
//  C411AlertAudienceCell.h
//  cell411
//
//  Created by Milan Agarwal on 30/03/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C411AlertAudienceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *tglBtnAudienceSelection;
@property (weak, nonatomic) IBOutlet UILabel *lblAudienceType;
@property (weak, nonatomic) IBOutlet UILabel *lblCounter;
@property (weak, nonatomic) IBOutlet UIView *vuDisabledOverlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCounterWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cnsCounterTrailing;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
@property (nonatomic,assign,getter=isAudienceDisabled) BOOL audienceDisabled;

-(void)hideCounter:(BOOL)hide;



@end
