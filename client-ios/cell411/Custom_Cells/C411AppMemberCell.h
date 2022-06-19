//
//  C411AppMemberCell.h
//  cell411
//
//  Created by Milan Agarwal on 06/08/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface C411AppMemberCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblMemberName;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
@end
