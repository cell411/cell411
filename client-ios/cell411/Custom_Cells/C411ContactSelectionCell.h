//
//  C411ContactSelectionCell.h
//  cell411
//
//  Created by Milan Agarwal on 31/08/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAGCheckbox.h"

@interface C411ContactSelectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblContactName;
@property (weak, nonatomic) IBOutlet UILabel *lblContactEmailOrPhone;
@property (weak, nonatomic) IBOutlet MAGCheckbox *btnCheckbox;

@end
