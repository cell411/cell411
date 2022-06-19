//
//  DateHelper.m
//  InventoryApp
//
//  Created by Milan Agarwal on 29/01/15.
//  Copyright (c) 2015 Milan Agarwal. All rights reserved.
//

#import "DateHelper.h"

static DateHelper *dateHelper;

@interface DateHelper ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation DateHelper


//****************************************************
#pragma mark - Static Initialization
//****************************************************


+(instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateHelper = [[DateHelper alloc]init];
    });
    return dateHelper;
}


//****************************************************
#pragma mark - Life Cycle Methods
//****************************************************


-(instancetype)init
{
    if (self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc]init];
        [self.dateFormatter setLocale:[NSLocale currentLocale]];
    }
    return  self;
}


//****************************************************
#pragma mark - Public Methods
//****************************************************


-(NSDate *)dateFromString:(NSString *)strDate withFormat:(NSString *)strDateFormat
{
    NSDate *date = nil;
    
    //  [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    if (strDate) {
        if (strDateFormat) {
            [self.dateFormatter setDateFormat:strDateFormat];
            
        }
        
        date = [self.dateFormatter dateFromString:strDate];
    }
    return  date;
}


-(NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)strDateFormat
{
    NSString *strDate = nil;
    
    [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (date) {
        if (strDateFormat) {
            [self.dateFormatter setDateFormat:strDateFormat];
        }
        strDate = [self.dateFormatter stringFromDate:date];
    }
    
    return strDate;
}

//[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

-(NSString *)convertDateToUTCTimeZoneFromDate:(NSString *)date withFormat:(NSString *)strdateFormat{
    
    NSString *strDate=nil;
    NSDate *dateTime=nil;
    if(date){
        
        [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [self.dateFormatter setDateFormat:strdateFormat];
        
        dateTime=[self.dateFormatter dateFromString:date];
        
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        if(strdateFormat){
            [self.dateFormatter setDateFormat:strdateFormat];
        }
        strDate=[self.dateFormatter stringFromDate:dateTime];
    }
    return strDate;
}


//-(NSString *)convertUTCTimeDateToLocalTimeZone:(NSDate *)date withFormat:(NSString *)strDateFormmat{
//
//    NSString *strDate=nil;
//    NSDate *dateTime=nil;
//    if(date){
//       // dateTime=[self.dateFormatter dateFromString:date];
//
//       // [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//
//        [self]
//        if(strdateFormat){
//            [self.dateFormatter setDateFormat:strdateFormat];
//        }
//        strDate=[self.dateFormatter stringFromDate:dateTime];
//
//    }
//    return strDate;
//
//
//}


-(NSDate*)removeTimeComponent:(NSDate*)date{
    
    [self.dateFormatter setCalendar: [NSCalendar currentCalendar]];
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd 00:00"];
    
    NSString * dateString = [self.dateFormatter stringFromDate:date];
    //  [self.dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss z"];
    
    //  return [self.dateFormatter dateFromString:[dateString stringByAppendingString:@" +0000"]];
    return [self.dateFormatter dateFromString:dateString];
}




- (NSDate*)get1WeekBackDateForDate:(NSDate*)date{
    
    NSCalendar *currentCalendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    
    
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    
    [componentsToSubtract setDay:-7];
    
    NSDate *beginningOfWeek = [currentCalendar dateByAddingComponents:componentsToSubtract
                                                               toDate:date options:0];
    
    return [self removeTimeComponent:beginningOfWeek];
}

-(NSDate*)removeMonth:(int)n fromDate:(NSDate*)date{
    NSCalendar *currentCalendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    
    
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setMonth: -n];
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    [dFormatter setLocale:[NSLocale currentLocale]];
    [dFormatter setCalendar:[NSCalendar currentCalendar]];
    [dFormatter setDateFormat:@"d"];
    // int d = [[dFormatter stringFromDate:date] intValue];
    [componentsToSubtract setDay:-1];
    
    
    
    NSDate *beginningOfWeek = [currentCalendar dateByAddingComponents:componentsToSubtract
                                                               toDate:date options:0];
    
    
    
    return [self removeTimeComponent:beginningOfWeek];
}

-(NSDate *)get3MBackDateFromDate:(NSDate*)date{
    
    
    NSDate *threeMothBackDate = [self removeMonth:3 fromDate:date];
    
    
    
    return [self removeTimeComponent:threeMothBackDate];
    
}


-(NSDate *)get1MBackDateFromDate:(NSDate*)date{
    
    
    NSDate *oneMonthBackDate = [self removeMonth:1 fromDate:date];
    
    
    
    return [self removeTimeComponent:oneMonthBackDate];
    
}


-(NSString *)getCurrentDatewithFormat:(NSString *)strDateFormat{
    
    [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [self.dateFormatter setDateFormat:strDateFormat];
    
    NSString *date_String=[self.dateFormatter stringFromDate:[NSDate date]];
    
    return date_String;
    
}

-(NSString *)getCurrentTime{
    
    // return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    [self.dateFormatter setDateFormat:@"hh:mm"];
    
    NSString *Time_String=[self.dateFormatter stringFromDate:[NSDate date]];
    return Time_String;
    
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+(NSInteger)getAgeUsingBirthday:(NSDate *)birthday
{
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    return age;
}

+(NSInteger)getYearFromDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
    return components.year;
    
}


+(NSInteger)getMonthFromDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:date];
    return components.month;
    
}

+(NSInteger)getDayFromDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
    return components.day;
    
}


+ (BOOL)isFutureDate:(NSDate *)date
{
    NSDate *now = [NSDate date];
    
    return [self daysBetweenDate:now andDate:date] > 0;
    
}


+(NSDate *)getDateByAddingMonth:(NSInteger)monthCount toDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:monthCount];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}
@end
