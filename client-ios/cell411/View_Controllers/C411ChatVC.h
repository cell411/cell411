//
//  C411ChatVC.h
//  cell411
//
//  Created by Milan Agarwal on 02/03/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C411Enums.h"
#import <JSQMessagesViewController/JSQMessagesViewController.h>

@interface C411ChatVC : JSQMessagesViewController

@property (nonatomic, assign) ChatEntityType entityType;
@property (nonatomic, strong) NSString *strEntityName;
@property (nonatomic, strong) NSString *strEntityId;
@property (nonatomic, assign) NSTimeInterval entityCreatedAtInMillis;

@end
