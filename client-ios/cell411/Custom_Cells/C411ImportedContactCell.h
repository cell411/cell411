//
//  C411ImportedContactCell.h
//  cell411
//
//  Created by Milan Agarwal on 08/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+CustomProperty.h"

@interface C411ImportedContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblContactName;
@property (weak, nonatomic) IBOutlet UILabel *lblContactEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnContactStatus;

@end
