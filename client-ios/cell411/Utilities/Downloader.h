//
//  Downloader.h
//  TestDemoProject
//
//

#import <Foundation/Foundation.h>

@class Downloader;

typedef enum {
    DownloaderStateIdle = 0, /// Downloaded is intialized, but downloading not started
    DownloaderStateDownloading,
    DownloaderStateDownloaded,
    DownloaderStateErrorRecieved,
    DownloaderStateCanceled
    
}DownloaderState;

@protocol DownloaderDelegate <NSObject>

@required

/// Define this method to receive downloaded data, Data will be de referenced and set to nil once passed to delegate. So consumer of data if have to must reference with strong type

-(void)downloader:(Downloader *)downloader didFinishLoadingWithData:(NSData *)data;

@optional
-(void)downloader:(Downloader *)downloader didRecievedResponse:(NSURLResponse *)response;
-(void)downloader:(Downloader *)downloader didFailWithError:(NSError *)error;
-(void)downloaderDidBeginDownloading:(Downloader *)downloader;
-(void)downloader:(Downloader *)downloader didUpdateWithProgressPercent:(float)progressPercent;

@end

@interface Downloader : NSObject

@property (nonatomic, assign) float progressDone;

//@property (nonatomic, strong) id strongTagObj;

@property (nonatomic, readonly) DownloaderState downloaderState;

@property (nonatomic, readonly) NSURLRequest* request;

//@property (nonatomic, assign) int itemIndex;

/// This property tell time taken in completion of Download, Default value is NSNotFound
@property (nonatomic, readonly) NSTimeInterval timetakenToDownloadInSeconds;



/**
 * @description It initialized downloader instance.
 * @param request It is request instance of item that need to be downloaded, It cannot be nil. It will send nil in case of nil request
 * @param delegate It is weak reference of Download Response Delegate
 * @result Returns the instance of Download after intializing it.
 */
-(instancetype) initWithRequest:(NSURLRequest*)request delegate:(id<DownloaderDelegate>)delegate;

/// This method will start downloading if state is DownloaderState_Idle or DownloaderState_Canceled, which is after creation of instance. It can also be used to restart download
-(void)download;

/// At any point of time downloading can canceled or reset which will set the DownloaderDelegate to nil
-(void)cancel;

@end
