//
//  C411PublicCellSelectionVC.h
//  cell411
//
//  Created by Milan Agarwal on 11/02/16.
//  Copyright (c) 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class C411PublicCellSelectionVC;

@protocol C411PublicCellSelectionVCDelegate <NSObject>

-(void)publicCellSelectionVC:(C411PublicCellSelectionVC *)publicCellSelectionVC didSelectPublicCell:(PFObject *)publicCell;
-(void)publicCellSelectionVCDidCancel:(C411PublicCellSelectionVC *)publicCellSelectionVC;

@end

@interface C411PublicCellSelectionVC : UIViewController

@property (nonatomic, assign) NSInteger alertType;
@property (nonatomic, strong) NSString *strAlertTitle;
@property (nonatomic, assign) id<C411PublicCellSelectionVCDelegate> delegate;

@end
