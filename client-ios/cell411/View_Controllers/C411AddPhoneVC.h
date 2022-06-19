//
//  C411AddPhoneVC.h
//  cell411
//
//  Created by Milan Agarwal on 17/06/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

#if PHONE_VERIFICATION_ENABLED
#import "Constants.h"

@class C411AddPhoneVC;

@protocol C411AddPhoneVCDelegate <NSObject>

-(void)addPhoneVC:(C411AddPhoneVC *)addPhoneVC didAddedOrUpdatedUniqueContactNumber:(NSString *)strContactNumber;

@end

#endif


@interface C411AddPhoneVC : UIViewController

@property (nonatomic, assign, getter=isInEditMode) BOOL inEditMode;
///Will hold a valid object if this VC is opened in edit mode and inEditMode property is set to YES
@property (nonatomic, strong) NSString *strContactNumber;

#if PHONE_VERIFICATION_ENABLED

@property (nonatomic, copy) SuccessCompletionHandler verificationCompletionHandler;
@property (nonatomic, assign) id<C411AddPhoneVCDelegate> addOrUpdatePhoneDelegate;
@property (nonatomic, assign,getter=isComingFromPhoneVerificationVC) BOOL comingFromPhoneVerificationVC;

#endif

@end
