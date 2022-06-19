//
//  FileDownloader.m
//  cell411
//
//  Created by Milan Agarwal on 02/11/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "FileDownloader.h"
#import "AppDelegate.h"
#import "NSFileManager+DoNotBackUp.h"
#import "C411StaticHelper.h"

#define VIDEO_FOLDER_NAME   @"Videos"

@import AssetsLibrary;

static FileDownloader *fileDownloader;

@interface FileDownloader ()<NSURLSessionDownloadDelegate>

@property (nonatomic, readwrite) NSURLSession *session;

@end

@implementation FileDownloader

//****************************************************
#pragma mark - Public Methods
//****************************************************


+(instancetype)sharedDownloader
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!fileDownloader) {
            ///Create Downloader object
            fileDownloader = [[FileDownloader alloc]init];
            
            ///Create a one time session
            // Session Configuration
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.safearx.cell411.BackgroundSession"];
            
            // Initialize Session
            fileDownloader.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:fileDownloader delegateQueue:nil];

        }
        
    });
    
    return fileDownloader;
    
}

//****************************************************
#pragma mark - Property Initializers
//****************************************************

-(NSMutableDictionary *)progressBuffer
{
    if (!_progressBuffer) {
        
        _progressBuffer = [NSMutableDictionary dictionary];
        /*
         ///set progress to 1 for all files that has been downloaded
         NSFileManager *fm = [NSFileManager defaultManager];
         
         for (PFObject *cell411Alert in self.arrAlerts) {
         
         NSURL *videoURL = [self videoURLForAlert:cell411Alert];
         if (videoURL) {
         
         NSString *strFilePath = [NSString stringWithFormat:@"%@/%@/%@",[C411StaticHelper documentDirectoryPath],VIDEO_FOLDER_NAME,videoURL.lastPathComponent];
         if ([fm fileExistsAtPath:strFilePath]) {
         
         ///set the download progress to 1 for this URL
         [_progressBuffer setObject:@(1.0) forKey:videoURL.absoluteString];
         
         }
         }
         
         }
         */
    }
    
    return _progressBuffer;
}


//****************************************************
#pragma mark - Private Methods
//****************************************************

-(void)saveVideoToGalleryFromUrl:(NSURL *)fileUrl forDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    ///Create a directory of videos
    [C411StaticHelper createFolderAtDocumentDirectoryWithName:VIDEO_FOLDER_NAME];
    
    ///Move this temp file to document directory with mp4 extension
    NSString *strDocDirPath = [C411StaticHelper documentDirectoryPath];
    NSString *strFilePath = [strDocDirPath stringByAppendingPathComponent:VIDEO_FOLDER_NAME];
    NSString *fileName = [[downloadTask originalRequest]URL].lastPathComponent;
    
    strFilePath = [strFilePath stringByAppendingPathComponent:fileName];
    NSURL *localFileUrl = [NSURL fileURLWithPath:strFilePath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:[fileUrl path]]) {
        NSError *error = nil;
        if ([fm fileExistsAtPath:[localFileUrl path]]) {
            
            ///Remove the old file
            BOOL success = [fm removeItemAtURL:localFileUrl error:&error];
            if (error) {
                NSLog(@"Unable to remove old file. %@, %@", error, error.userInfo);
            }
            else if (success){
                
                NSLog(@"successfully removed the old file");
                
            }
            error = nil;
        }
        
        ///Move the new file from temp location to videos dir
        BOOL success = [fm moveItemAtURL:fileUrl toURL:localFileUrl error:&error];
        
        if (error) {
            NSLog(@"Unable to move temporary file to destination. %@, %@", error, error.userInfo);
        }
        else if(success){
            ///add do not backup flag
            
            [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:localFileUrl];
            
            
            ///Save it to user's photo album
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:localFileUrl]) {
                
                [library writeVideoAtPathToSavedPhotosAlbum:localFileUrl
                                            completionBlock:^(NSURL *assetURL, NSError *error){//notify of completion
                                                NSLog(@"%@",assetURL);
                                                if (error) {
                                                    NSLog(@"%@",error.localizedDescription);
                                                }
                                                ///Remove the video saved locally for now, until we implement local video playlist
                                                NSError *err = nil;
                                                [fm removeItemAtURL:localFileUrl error:&err];
                                                if (err) {
                                                    NSLog(@"unable to remove file");
                                                }
                                            }];
            }
            else{
                
                NSLog(@"Incompatible url %@",localFileUrl);
            }
            
        }
    }
    
    
}


- (void)invokeBackgroundSessionCompletionHandler {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
        
        if (!count) {
            AppDelegate *applicationDelegate = (AppDelegate *)[AppDelegate sharedInstance];
            void (^backgroundSessionCompletionHandler)() = [applicationDelegate backgroundSessionCompletionHandler];
            
            if (backgroundSessionCompletionHandler) {
                [applicationDelegate setBackgroundSessionCompletionHandler:nil];
                backgroundSessionCompletionHandler();
            }
        }
    }];
}


//****************************************************
#pragma mark - NSURLSessionDownloadDelegate Methods
//****************************************************

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.downloaderDelegate respondsToSelector:@selector(URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:)]) {
    
        ///Send message to delegate
        [self.downloaderDelegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
        
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    // Calculate Progress
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    // Update Progress Buffer
    NSURL *URL = [[downloadTask originalRequest] URL];
    [[FileDownloader sharedDownloader].progressBuffer setObject:@(progress) forKey:[URL absoluteString]];

    if ([self.downloaderDelegate respondsToSelector:@selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
       
        ///Send message to delegate
        [self.downloaderDelegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
   
    // Write File to photo gallery, Application specific task
    [self saveVideoToGalleryFromUrl:location forDownloadTask:downloadTask];

    // Update Progress Buffer
    [[FileDownloader sharedDownloader].progressBuffer setObject:@(1.0) forKey:[[downloadTask originalRequest].URL absoluteString]];

    if ([self.downloaderDelegate respondsToSelector:@selector(URLSession:downloadTask:didFinishDownloadingToURL:)]) {
       
        ///Send message to delegate
        [self.downloaderDelegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
        
    }
    
    // Invoke Background Completion Handler finally to check if background task is done or not
    [self invokeBackgroundSessionCompletionHandler];

    
}



@end
