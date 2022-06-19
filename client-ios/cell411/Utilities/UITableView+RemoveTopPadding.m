//
//  UITableView+RemoveTopPadding.m
//  cell411
//
//  Created by Milan Agarwal on 24/04/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "UITableView+RemoveTopPadding.h"

@implementation UITableView (RemoveTopPadding)

-(void)removeTopPadding
{
    ///Remove top padding of 15 pixel
    self.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);

}

@end
