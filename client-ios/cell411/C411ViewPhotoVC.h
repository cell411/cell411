//
//  C411ViewPhotoVC.h
//  cell411
//
//  Created by Milan Agarwal on 02/11/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAGBackActionCallbackVC.h"
@class PFFileObject;
@class PFUser;

@interface C411ViewPhotoVC : MAGBackActionCallbackVC
///Use this value to fetch photoFile from parse if not available
@property (nonatomic, strong) NSString * strCell411AlertId;
@property (nonatomic, strong) PFFileObject * photoFile;
///not required now, for future reference to display caption
@property (nonatomic, strong) NSString * strAdditionalNote;

//use this if provided
@property (nonatomic, weak) UIImage *imgPhoto;
///Use this to get image if imgPhoto is not provided and user is provided
@property (nonatomic, weak) PFUser *user;

@end
