//
//  DateHelper.h
//  InventoryApp
//
//  Created by Milan Agarwal on 29/01/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject

+(instancetype)sharedHelper;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
+ (NSInteger)getAgeUsingBirthday:(NSDate *)birthday;
+(NSInteger)getYearFromDate:(NSDate *)date;
+(NSInteger)getMonthFromDate:(NSDate *)date;
+(NSInteger)getDayFromDate:(NSDate *)date;


///Returns Yes If date belongs to coming tomorrow or more
+ (BOOL)isFutureDate:(NSDate *)date;
+(NSDate *)getDateByAddingMonth:(NSInteger)monthCount toDate:(NSDate *)date;

-(NSDate *)dateFromString:(NSString *)strDate withFormat:(NSString *)strDateFormat;
-(NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)strDateFormat;
-(NSString *)convertDateToUTCTimeZoneFromDate:(NSString *)date withFormat:(NSString *)strdateFormat;


-(NSDate *)get3MBackDateFromDate:(NSDate*)date;
-(NSDate *)get1MBackDateFromDate:(NSDate*)date;
-(NSDate*)removeMonth:(int)n fromDate:(NSDate*)date;
- (NSDate*)get1WeekBackDateForDate:(NSDate*)date;
-(NSDate*)removeTimeComponent:(NSDate*)date;

-(NSString *)getCurrentDatewithFormat:(NSString *)strDateFormat;
-(NSString *)getCurrentTime;


@end
