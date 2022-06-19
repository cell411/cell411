//
//  C411PhoneVerificationVC.h
//  cell411
//
//  Created by Milan Agarwal on 27/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface C411PhoneVerificationVC : UIViewController

@property (nonatomic, strong) NSString *strContactNumber;
@property (nonatomic, copy) SuccessCompletionHandler verificationCompletionHandler;

@end
