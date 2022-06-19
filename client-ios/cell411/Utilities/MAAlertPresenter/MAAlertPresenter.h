//
//  MAAlertPresenter.h
//  MAAlertPresenter
//
//  Created by Milan Agarwal on 10/08/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface MAAlertPresenter : NSObject

+(instancetype)sharedPresenter;
-(void)enqueueAlert:(UIAlertController *)alertController;
-(void)dequeueAlert;
-(void)removeAllAlertsFromQueue;
@end
