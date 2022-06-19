//
//  C411NAUMemberCell.h
//  cell411
//
//  Created by Milan Agarwal on 12/09/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C411NAUMemberCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblContactName;
@property (weak, nonatomic) IBOutlet UILabel *lblContactEmailOrPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;

@end
