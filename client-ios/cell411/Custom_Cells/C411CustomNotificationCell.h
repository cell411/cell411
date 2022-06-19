//
//  C411CustomNotificationCell.h
//  cell411
//
//  Created by Milan Agarwal on 28/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultilineLabel.h"

@class PFObject;

@interface C411CustomNotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVuClock;
@property (weak, nonatomic) IBOutlet MultilineLabel *lblNotificationTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTimestamp;
-(void)setDataUsingObject:(PFObject *)customAlert;

@end
