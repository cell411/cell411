//
//  C411CellSelectionCell.h
//  cell411
//
//  Created by Milan Agarwal on 02/09/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAGCheckbox.h"

@interface C411CellSelectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgVuCell;
@property (weak, nonatomic) IBOutlet UILabel *lblCellName;
@property (weak, nonatomic) IBOutlet MAGCheckbox *btnCheckbox;

@end
