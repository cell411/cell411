//
//  UIImageView+ImageDownloadHelper.m
//  cell411
//
//  Created by Milan Agarwal on 30/10/16.
//  Copyright © 2016 Milan Agarwal. All rights reserved.
//

#import "UIImageView+ImageDownloadHelper.h"
#import "C411StaticHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (ImageDownloadHelper)

//****************************************************
#pragma mark - Public Methods
//****************************************************


-(void)setCarImageForUserWithId:(NSString *)strUserId withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    ///get the user object from parse
    __weak typeof(self) weakSelf = self;
    PFQuery *getUserQuery = [PFUser query];
    [getUserQuery getObjectInBackgroundWithId:strUserId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///User found, get the avatar for this user
            PFUser *parseuser = (PFUser *)object;
            [weakSelf setCarImageForUser:parseuser withCompletion:completion];
            
        }
        else {
            
            ///log error
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"#error: %@",errorString);
            
            ///call the completion block if provided
            if (completion!=NULL) {
                
                completion(NO,nil);
            }
            
        }
    }];
    
    
}


-(void)setCarImageForUser:(PFUser *)parseUser withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    NSURL *carImageUrl = [C411StaticHelper getCarUrlForUser:parseUser];
    if (carImageUrl) {
        
        ///Set the image using the carImageUrl
        [self sd_setImageWithURL:carImageUrl placeholderImage:self.image options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (completion != NULL) {
                
                BOOL success = NO;
                if (!error && image) {
                    success = YES;
                }
                ///call the completion block
                completion(success, image);
            }
            
            
        }];
    }
    else{
        
        if (completion != NULL) {
           
            ///call the completion block
            completion(NO, nil);
            
        }
    }
}


-(void)setAvatarForUser:(PFUser *)parseUser shouldFallbackToGravatar:(BOOL)fallbackToGravatar ofSize:(int)imageSize roundedCorners:(BOOL)roundedCorner withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    NSURL *avatarUrl = [C411StaticHelper getAvatarUrlForUser:parseUser];
    __weak typeof(self) weakSelf = self;
    
    if (avatarUrl) {
        
            ///Set the image using the carImageUrl
            [self sd_setImageWithURL:avatarUrl placeholderImage:self.image options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (!error && image) {
                    
                    if (roundedCorner) {
                        
                        image = [C411StaticHelper getRoundedRectImageFromImage:image withSize:CGSizeMake(imageSize, imageSize) withCornerRadius:imageSize/2];
                        ///set the rounded image
                        weakSelf.image = image;
                    }
                    
                    ///call the completion block and pass the image
                    if (completion!=NULL) {
                        
                        completion(YES,image);
                    }
                    
                }
                else if (fallbackToGravatar){
                    
                    ///get the email of the user
                    NSString *strEmail = [C411StaticHelper getEmailFromUser:parseUser];
                    if (strEmail.length > 0) {
                        
                        [C411StaticHelper getGravatarForEmail:strEmail ofSize:imageSize roundedCorners:roundedCorner withCompletion:^(BOOL success, UIImage *image) {
                            
                            if (success && image) {
                                
                                weakSelf.image = image;
                            }
                            
                            ///call the completion block and pass the image
                            if (completion!=NULL) {
                                
                                completion(success,image);
                            }
                            
                            
                        }];
                    }
                    else{
                        
                        ///call the completion block and pass the image
                        if (completion!=NULL) {
                            
                            completion(NO,nil);
                        }
                    }
                    
                }
                else{
                    
                    ///call the completion block if provided
                    if (completion!=NULL) {
                        
                        completion(NO,image);
                    }
                }
                
                
            }];
            
        
    }
    else if (fallbackToGravatar){
        
        ///get the email of the user
        NSString *strEmail = [C411StaticHelper getEmailFromUser:parseUser];
        if (strEmail.length > 0) {
            
            [C411StaticHelper getGravatarForEmail:strEmail ofSize:imageSize roundedCorners:roundedCorner withCompletion:^(BOOL success, UIImage *image) {
                
                if (success && image) {
                    
                    weakSelf.image = image;
                }
                
                ///call the completion block and pass the image
                if (completion!=NULL) {
                    
                    completion(success,image);
                }
                
                
            }];
            
        }
        else{
            
            ///call the completion block and pass the image
            if (completion!=NULL) {
                
                completion(NO,nil);
            }
        }
    }
    else{
        
        ///call the completion block if provided
        if (completion != NULL) {
            
            completion(NO, nil);
            
        }
    }
    
    
    
}

-(void)setAvatarForUserWithId:(NSString *)strUserId shouldFallbackToGravatar:(BOOL)fallbackToGravatar ofSize:(int)imageSize roundedCorners:(BOOL)roundedCorner withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    ///get the user object from parse
    __weak typeof(self) weakSelf = self;
    PFQuery *getUserQuery = [PFUser query];
    [getUserQuery getObjectInBackgroundWithId:strUserId block:^(PFObject *object,  NSError *error){
        
        if (!error && object) {
            
            ///User found, get the avatar for this user
            PFUser *parseuser = (PFUser *)object;
            [weakSelf setAvatarForUser:parseuser shouldFallbackToGravatar:fallbackToGravatar ofSize:imageSize roundedCorners:roundedCorner withCompletion:completion];
            
        }
        else {
            
            ///log error
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"#error: %@",errorString);
            
            ///call the completion block if provided
            if (completion!=NULL) {
                
                completion(NO,nil);
            }
            
        }
    }];
    
}

-(void)setImageUsingFileObject:(PFFileObject *)photoFile withCompletion:(void(^)(BOOL success, UIImage *image))completion
{
    if (photoFile) {
        __weak typeof(self) weakSelf = self;
        ///Get photo file
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError * error){
            if (!error) {
                ///make image from data
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        ///Show image on main thread
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            weakSelf.image = image;
                            ///call the completion block if provided
                            if (completion!=NULL) {
                                
                                completion(YES,image);
                            }
                        }];
                    }
                    else{
                        NSLog(@"Unable to load the photo");
                        ///call the completion block if provided
                        if (completion!=NULL) {
                            
                            completion(NO,nil);
                        }
                    }
                }
                else{
                    NSLog(@"Photo data not avaialble");
                    ///call the completion block if provided
                    if (completion!=NULL) {
                        
                        completion(NO,nil);
                    }
                }
            }
            else {
                ///show error
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"Error fetching image data associated with Photo file:%@",errorString);
                ///call the completion block if provided
                if (completion!=NULL) {
                    completion(NO,nil);
                }
            }
        }];
    }
    else{
        NSLog(@"Photo File not provided");
        if(completion != NULL) {
            completion(NO, nil);
        }
    }
}


@end
