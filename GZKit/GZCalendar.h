//
//  GZCalendar.h
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/7.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WEEK_DAYS 7
//計算天數轉總秒數的巨集函式
#define DAYS_TIME_INTERVAL(DAYS) (DAYS * 24 * 60 *60)
//一天份的便捷定義
#define ONE_DAY_TIME_INTERVAL DAYS_TIME_INTERVAL(1)
#define WEEK_TIME_INTERVAL DAYS_TIME_INTERVAL(WEEK_DAYS)
#define TIME_INTERVALS_FROM_INDEXPATH(INDEXPATH) (WEEK_TIME_INTERVAL*(INDEXPATH.section)+DAYS_TIME_INTERVAL(INDEXPATH.row))

typedef NS_ENUM(NSInteger, GZCalendarWeekday){
    GZCalendarWeekdaySunday = 1<<1,
    GZCalendarWeekdayMonday = 1<<2,
    GZCalendarWeekdayTuesday = 1<<3,
    GZCalendarWeekdayWednesday = 1<<4,
    GZCalendarWeekdayThursday = 1<<5,
    GZCalendarWeekdayFriday = 1<<6,
    GZCalendarWeekdaySaturday = 1<<7,
};

@interface GZCalendar : NSObject

+ (NSRange) weekRangeFoMonthOnBaseDate:(NSDate *)baseDate inCalendar:(NSCalendar *)calendar;
+ (NSRange) weekRangeFoWeekOnBaseDate:(NSDate *)baseDate inCalendar:(NSCalendar *)calendar;
+ (NSDate *)firstDateFromDate:(NSDate *)date withFirstWeekDay:(GZCalendarWeekday)firstWeekday inCalendar:(NSCalendar *)calendar;
+ (NSDate *)firstDateOfWeekFromDate:(NSDate *)date withFirstWeekDay:(GZCalendarWeekday)firstWeekday inCalendar:(NSCalendar *)calendar;
+ (NSDate *)firstDateOfWeek:(NSUInteger)weekOfYear inYear:(NSUInteger)year inCalendar:(NSCalendar *)calendar;

+ (NSDate *)endDateOfWeek:(NSUInteger)weekOfYear inYear:(NSUInteger)year inCalendar:(NSCalendar *)calendar;

+ (NSDate *)firstDateFromWeekOfMonth:(NSUInteger)weekOfMonth inMonth:(NSUInteger)month inYear:(NSUInteger)year inFirstWeekDay:(GZCalendarWeekday)firstWeekDay inCalendar:(NSCalendar *)calendar;

+ (NSUInteger) firstWeekOfMonthWithDate:(NSDate *)date inCalendar:(NSCalendar *)calendar;

@end
