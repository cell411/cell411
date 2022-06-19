//
//  UIImageView+ImageDownloadHelper.h
//  cell411
//
//  Created by Milan Agarwal on 30/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFUser;
@class PFFileObject;
@interface UIImageView (ImageDownloadHelper)

-(void)setCarImageForUser:(PFUser *)parseUser withCompletion:(void(^)(BOOL success, UIImage *image))completion;
-(void)setCarImageForUserWithId:(NSString *)strUserId withCompletion:(void(^)(BOOL success, UIImage *image))completion;
-(void)setAvatarForUser:(PFUser *)parseUser shouldFallbackToGravatar:(BOOL)fallbackToGravatar ofSize:(int)imageSize roundedCorners:(BOOL)roundedCorner withCompletion:(void(^)(BOOL success, UIImage *image))completion;
-(void)setAvatarForUserWithId:(NSString *)strUserId shouldFallbackToGravatar:(BOOL)fallbackToGravatar ofSize:(int)imageSize roundedCorners:(BOOL)roundedCorner withCompletion:(void(^)(BOOL success, UIImage *image))completion;
-(void)setImageUsingFileObject:(PFFileObject *)photoFile withCompletion:(void(^)(BOOL success, UIImage *image))completion;

@end
