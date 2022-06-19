//
//  C411PubPvtCellSelectionCell.h
//  cell411
//
//  Created by Milan Agarwal on 20/04/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C411PubPvtCellSelectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVuCell;
@property (weak, nonatomic) IBOutlet UIImageView *imgVuVerified;
@property (weak, nonatomic) IBOutlet UILabel *lblCellName;
@property (weak, nonatomic) IBOutlet UILabel *lblCellType;
@property (weak, nonatomic) IBOutlet UIButton *tglBtnCellSelection;

@end
