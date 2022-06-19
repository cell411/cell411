//
//  MAJSQAsyncPhotoMediaItem.m
//  cell411
//
//  Created by Milan Agarwal on 17/04/17.
//  Copyright © 2017 Milan Agarwal. All rights reserved.
//

#import "MAJSQAsyncPhotoMediaItem.h"
#import <JSQMessagesViewController/JSQMessagesMediaPlaceholderView.h>
#import <JSQMessagesViewController/JSQMessagesMediaViewBubbleImageMasker.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+JSQMessages.h"


@interface MAJSQAsyncPhotoMediaItem ()

@property (strong, nonatomic) UIImageView *cachedAsyncImageView;

@end

@implementation MAJSQAsyncPhotoMediaItem

#pragma mark - Initialization

-(instancetype)initWithUrl:(NSURL *)imageUrl
{
    self = [super init];
    if (self) {
        _imageUrl = [imageUrl copy];
        _cachedAsyncImageView = nil;
    }
    return self;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedAsyncImageView = nil;
}

#pragma mark - Setters

- (void)setImageUrl:(NSURL *)imageUrl
{
    _imageUrl = [imageUrl copy];
    _cachedAsyncImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedAsyncImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.imageUrl == nil) {
        return [super mediaView];
    }
    
    if (self.cachedAsyncImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor jsq_messageBubbleLightGrayColor];
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedAsyncImageView = imageView;

        UIView *activityIndicator = [JSQMessagesMediaPlaceholderView viewWithActivityIndicator];
        activityIndicator.frame = imageView.frame;
        
        [imageView addSubview:activityIndicator];
        
        __weak typeof(self) weakSelf = self;
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.imageUrl.absoluteString];
        if(image == nil)
        {
            [imageView sd_setImageWithURL:self.imageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error == nil) {
                    [weakSelf.cachedAsyncImageView setImage:image];
                    [activityIndicator removeFromSuperview];
                } else {
                    NSLog(@"Image downloading error: %@", [error localizedDescription]);
                }
            }];
        } else {
            [self.cachedAsyncImageView setImage:image];
            [activityIndicator removeFromSuperview];
        }
    }
    
    return self.cachedAsyncImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.imageUrl.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: imageUrl=%@ image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.imageUrl, self.image, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _imageUrl = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageUrl))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.imageUrl forKey:NSStringFromSelector(@selector(imageUrl))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    MAJSQAsyncPhotoMediaItem *copy = [[MAJSQAsyncPhotoMediaItem allocWithZone:zone] initWithUrl:self.imageUrl];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    copy.image = self.image.copy;
    return copy;
}


@end
