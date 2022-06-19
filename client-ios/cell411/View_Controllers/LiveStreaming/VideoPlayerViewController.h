//
//  VideoPlayerViewController.h
//  SDKSampleApp
//
//  This code and all components (c) Copyright 2015-2016, Wowza Media Systems, LLC. All rights reserved.
//  This code is licensed pursuant to the BSD 3-Clause License.
//

#import <UIKit/UIKit.h>

@class VideoPlayerViewController;


@protocol VideoPlayerViewControllerDelegate <NSObject>

-(void)videoBroadcastingVCDidClosed:(VideoPlayerViewController *)videoBroadcastingVC;
-(void)videoBroadcastingVCDidStartBroadcasting:(VideoPlayerViewController *)videoBroadcastingVC;

@end

@interface VideoPlayerViewController : UIViewController

@property (nonatomic, strong) NSString *strStreamName;
@property (nonatomic, strong) NSDictionary *dictAlertParams;
@property (nonatomic, assign) id<VideoPlayerViewControllerDelegate> delegate;

@end

