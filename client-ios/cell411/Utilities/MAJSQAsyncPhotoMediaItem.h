//
//  MAJSQAsyncPhotoMediaItem.h
//  cell411
//
//  Created by Milan Agarwal on 17/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSQMessagesViewController/JSQPhotoMediaItem.h>

@interface MAJSQAsyncPhotoMediaItem : JSQPhotoMediaItem<JSQMessageMediaData, NSCoding, NSCopying>

/**
 *  The image url for the photo media item to download asyncronously. The default value is `nil`.
 */
@property (copy, nonatomic) NSURL *imageUrl;

- (instancetype)initWithUrl:(NSURL *)imageUrl;

@end
