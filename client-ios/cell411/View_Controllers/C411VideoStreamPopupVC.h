//
//  C411VideoStreamPopupVC.h
//  cell411
//
//  Created by Milan Agarwal on 07/09/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class C411VideoStreamPopupVC, C411Alert;

@protocol C411VideoStreamPopupVCDelegate<NSObject>

-(void)videoStreamPopupVCDidTappedStreamVideo:(C411VideoStreamPopupVC *)videoStreamPopupVC;
-(void)videoStreamPopupVCDidTappedCancel:(C411VideoStreamPopupVC *)videoStreamPopupVC;


@end


@interface C411VideoStreamPopupVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnStreamVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnPublishToFB;
@property (nonatomic, assign) id<C411VideoStreamPopupVCDelegate> delegate;
@property (nonatomic, strong) NSString *strPopupTitle;
@property (nonatomic, strong) C411Alert *alert;
@property (nonatomic, strong) NSDictionary *dictAlertParams;
@property (nonatomic, strong) NSDictionary *dictResult;
@property (nonatomic, assign) BOOL canShowVideoStreamOption;
@end
