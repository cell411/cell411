//
//  MATimestampFormatter.m
//  cell411
//
//  Created by Milan Agarwal on 08/02/18.
//  Copyright © 2018 Milan Agarwal. All rights reserved.
//

#import "MATimestampFormatter.h"

@interface MATimestampFormatter ()

@property (strong, nonatomic, readwrite) NSDateFormatter *dateFormatter;

@end


@implementation MATimestampFormatter

#pragma mark - Initialization

+ (instancetype)sharedFormatterWithLocale:(NSLocale *)locale
{
    static MATimestampFormatter *_sharedFormatter = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedFormatter = [[MATimestampFormatter alloc] initWithLocale:locale];
    });
    
    return _sharedFormatter;
}

- (instancetype)init
{
    return [self initWithLocale:nil];
}

-(instancetype)initWithLocale:(NSLocale *)locale
{
    if (!locale) {
        ///Set default locale
        locale = [NSLocale currentLocale];
    }
    
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:locale];
        [_dateFormatter setDoesRelativeDateFormatting:YES];
        
        UIColor *color = [UIColor lightGrayColor];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        _dateTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0f],
                                 NSForegroundColorAttributeName : color,
                                 NSParagraphStyleAttributeName : paragraphStyle };
        
        _timeTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f],
                                 NSForegroundColorAttributeName : color,
                                 NSParagraphStyleAttributeName : paragraphStyle };
    }
    return self;
    
}

#pragma mark - Formatter

- (NSString *)timestampForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSAttributedString *)attributedTimestampForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSString *relativeDate = [self relativeDateForDate:date];
    NSString *time = [self timeForDate:date];
    
    NSMutableAttributedString *timestamp = [[NSMutableAttributedString alloc] initWithString:relativeDate
                                                                                  attributes:self.dateTextAttributes];
    
    [timestamp appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    [timestamp appendAttributedString:[[NSAttributedString alloc] initWithString:time
                                                                      attributes:self.timeTextAttributes]];
    
    return [[NSAttributedString alloc] initWithAttributedString:timestamp];
}

- (NSString *)timeForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

- (NSString *)relativeDateForDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [self.dateFormatter stringFromDate:date];
}


@end
