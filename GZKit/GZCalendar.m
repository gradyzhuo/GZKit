//
//  GZCalendar.m
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/7.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZCalendar.h"

@implementation GZCalendar

+ (NSRange) weekRangeFoMonthOnBaseDate:(NSDate *)baseDate inCalendar:(NSCalendar *)calendar{
    
    NSRange weekRange = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:baseDate];
//    NSInteger week = [calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:baseDate];
//    weekRange.location = week;
    return weekRange;
}

+(NSRange)weekRangeFoWeekOnBaseDate:(NSDate *)baseDate inCalendar:(NSCalendar *)calendar{
    NSInteger week = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYear forDate:baseDate];
    return NSMakeRange(week, 1);
}

+ (NSDate *)firstDateFromDate:(NSDate *)date withFirstWeekDay:(GZCalendarWeekday)firstWeekday inCalendar:(NSCalendar *)calendar{
    
//    NSUInteger week = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYear forDate:date];

    NSRange weekRange = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSInteger year = [calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
    NSDateComponents *datecomponents = [[NSDateComponents alloc] init];
    datecomponents.year = year;
    datecomponents.week = weekRange.location;
    datecomponents.weekdayOrdinal = log2(firstWeekday);
    NSDate *firstDate = [calendar dateFromComponents:datecomponents];
    
//    
//    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
//    NSDate *firstDate = [GZCalendar firstDateFromWeekOfMonth:1 inMonth:dateComponents.month inYear:dateComponents.year inFirstWeekDay:firstWeekday inCalendar:calendar];
//    
    return firstDate;
}


+ (NSDate *)firstDateOfWeekFromDate:(NSDate *)date withFirstWeekDay:(GZCalendarWeekday)firstWeekday inCalendar:(NSCalendar *)calendar{

    NSInteger week = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYear forDate:date];
    NSInteger year = [calendar ordinalityOfUnit:NSYearCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
    NSDateComponents *datecomponents = [[NSDateComponents alloc] init];
    datecomponents.year = year;
    datecomponents.week = week;
    datecomponents.weekdayOrdinal = log2(firstWeekday);

    return [calendar dateFromComponents:datecomponents];
}


+ (NSDate *)firstDateOfWeek:(NSUInteger)week inYear:(NSUInteger)year inCalendar:(NSCalendar *)calendar{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekdayOrdinal:calendar.firstWeekday];
    [components setWeek:week];
    [components setYear:year];
    NSDate *firstDate = [calendar dateFromComponents:components];
    return firstDate;
}

+(NSDate *)endDateOfWeek:(NSUInteger)weekOfYear inYear:(NSUInteger)year inCalendar:(NSCalendar *)calendar{
    NSDate *firstDate = [GZCalendar firstDateOfWeek:weekOfYear inYear:year inCalendar:calendar];
    return [firstDate dateByAddingTimeInterval:WEEK_TIME_INTERVAL-ONE_DAY_TIME_INTERVAL];
}

+ (NSDate *)firstDateFromWeekOfMonth:(NSUInteger)weekOfMonth inMonth:(NSUInteger)month inYear:(NSUInteger)year inFirstWeekDay:(GZCalendarWeekday)firstWeekDay inCalendar:(NSCalendar *)calendar{
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekdayOrdinal:log2(firstWeekDay)];
    [components setWeekOfMonth:weekOfMonth];
    [components setMonth:month];
    [components setYear:year];
    NSDate *firstDate = [calendar dateFromComponents:components];
    
    return firstDate;
    
}


+(NSUInteger)firstWeekOfMonthWithDate:(NSDate *)date inCalendar:(NSCalendar *)calendar{
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    dateComponents.day = 1;
    NSDate *firstDayDate = [calendar dateFromComponents:dateComponents];
    
    NSUInteger weekOfMonth = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:firstDayDate];
    return weekOfMonth;
}

@end
