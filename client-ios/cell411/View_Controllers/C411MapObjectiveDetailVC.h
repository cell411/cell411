//
//  C411MapObjectiveDetailVC.h
//  cell411
//
//  Created by Milan Agarwal on 03/06/19.
//  Copyright © 2019 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFObject;

NS_ASSUME_NONNULL_BEGIN

@interface C411MapObjectiveDetailVC : UIViewController
@property (nonatomic, weak) PFObject *mapObjective;
@end

NS_ASSUME_NONNULL_END
