//
//  C411QRCodeScannerVC.h
//  cell411
//
//  Created by Milan Agarwal on 14/08/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAGBackActionCallbackVC.h"
@class C411BarcodeScannerVC;

@protocol C411BarcodeScannerVCDelegate <NSObject>

-(void)scanner:(C411BarcodeScannerVC *)scanner didScanBarcodesWithResult:(NSArray *)arrBarcodes;

@end

@interface C411BarcodeScannerVC : MAGBackActionCallbackVC

@property (nonatomic, assign)id<C411BarcodeScannerVCDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIView *vuScannerPreview;


@end
