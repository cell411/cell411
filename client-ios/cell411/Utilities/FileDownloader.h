//
//  FileDownloader.h
//  cell411
//
//  Created by Milan Agarwal on 02/11/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

///A singleton object which will use NSURLSession to download files(preferable for large files)
@interface FileDownloader : NSObject

@property (strong, nonatomic, readonly) NSURLSession *session;
@property (strong, nonatomic) NSMutableDictionary *progressBuffer;
@property (nonatomic, assign) id<NSURLSessionDownloadDelegate> downloaderDelegate;

+(instancetype)sharedDownloader;

@end
