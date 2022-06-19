//
//  Downloader.m
//  TestDemoProject
//
//

#import "Downloader.h"

@interface Downloader()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSURLRequest * request_;
    DownloaderState downloaderState_;
    NSURLConnection *connection;
    NSMutableData *mData;
    
    NSTimeInterval startTimeInterval;
    NSTimeInterval endTimeInterval;
}
@property (nonatomic, assign) long long expectedLength;
@property (nonatomic, weak) id<DownloaderDelegate>delegate;


@end
@implementation Downloader

#pragma mark - Override Methods

-(NSURLRequest*)request
{
    return request_;
}

-(DownloaderState)downloaderState
{
    return downloaderState_;
}

-(NSTimeInterval)timetakenToDownloadInSeconds
{
    if (endTimeInterval == 0 || startTimeInterval == 0) {
        return  NSNotFound;
    }
    return (endTimeInterval - startTimeInterval);
}

-(void )callProgressDelegateIfDefined:(float) progressValueInPercentage
{
    if ([_delegate respondsToSelector:@selector(downloader:didUpdateWithProgressPercent:)]) {
        [_delegate downloader:self didUpdateWithProgressPercent:progressValueInPercentage];
    }
}

-(void)dealloc
{
    self.delegate = nil;
    [self cancel];
}

//****************************************************
#pragma mark - Public Methods
//****************************************************


-(instancetype)initWithRequest:(NSURLRequest *)request delegate:(id<DownloaderDelegate>)delegate
{
    if (self = [super init]) {
        if (!request) {
            return nil;
        }
        request_ = request;
        self.delegate = delegate;
        downloaderState_ = DownloaderStateIdle;
        startTimeInterval = 0;
        endTimeInterval = 0;
    }
    return self;
}

-(void)download
{
    
    if (downloaderState_ == DownloaderStateIdle || downloaderState_ == DownloaderStateCanceled) {
        
        downloaderState_ = DownloaderStateDownloading;
        if ([_delegate respondsToSelector:@selector(downloaderDidBeginDownloading:)]) {
            [_delegate downloaderDidBeginDownloading:self];
        }
        
        connection = [[NSURLConnection alloc]initWithRequest:request_ delegate:self startImmediately:YES];
    }
    
}

-(void)cancel
{
    self.delegate = nil;
    [connection cancel];
    connection = nil;
    downloaderState_ = DownloaderStateCanceled;
    mData = nil;
    startTimeInterval = 0;
    endTimeInterval = 0;
}


//****************************************************
#pragma mark - NSURLConnectionDelegate Methods
//****************************************************

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.expectedLength = [response expectedContentLength];
    if ([_delegate respondsToSelector:@selector(downloader:didRecievedResponse:)]) {
        [_delegate downloader:self didRecievedResponse:response];
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!mData) {
        mData = [NSMutableData dataWithData:data];
    }else{
        [mData appendData:data];
    }
    
    if (_expectedLength>0) {
        float percentage = (mData.length/(double)_expectedLength)*100;
        self.progressDone = percentage;
        [self callProgressDelegateIfDefined:percentage];
    }
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    downloaderState_ = DownloaderStateDownloaded;
    endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    
    [_delegate downloader:self didFinishLoadingWithData:mData];
    mData = nil;

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    downloaderState_ = DownloaderStateErrorRecieved;
    endTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    
    if ([_delegate respondsToSelector:@selector(downloader:didFailWithError:)])
    {
        [_delegate downloader:self didFailWithError:error];
    }
}

@end
