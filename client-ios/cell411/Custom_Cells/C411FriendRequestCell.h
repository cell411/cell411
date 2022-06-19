//
//  C411FriendRequestCell.h
//  cell411
//
//  Created by Milan Agarwal on 03/07/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFObject;

@interface C411FriendRequestCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVuAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;
@property (weak, nonatomic) IBOutlet UILabel *lblActionIndicator;

@property (nonatomic, weak) PFObject *friendRequest;
@property (nonatomic, weak) NSMutableDictionary *dictPendingActions;

-(void)setupCell;

@end
