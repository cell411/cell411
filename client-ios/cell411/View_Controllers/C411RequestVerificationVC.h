//
//  C411RequestVerificationVC.h
//  cell411
//
//  Created by Milan Agarwal on 09/02/16.
//  Copyright (c) 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface C411RequestVerificationVC : UIViewController

@property (nonatomic, weak) PFObject *myPublicCellObj;
/*OLD implementation of verification request handling*/
//@property (nonatomic, weak) PFObject *verificationReqObj;

@end
