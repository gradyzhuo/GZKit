//
//  GZInfiniteMonthCalendrView.h
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/7.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GZKit/GZInfiniteScrollView.h>
#import <GZKit/GZCalendarGridView.h>

typedef NS_ENUM(NSUInteger, GZMonthCalendrViewUpdateBaseOnType){
    GZMonthCalendrViewUpdateBaseOnTypeWeek,
    GZMonthCalendrViewUpdateBaseOnTypeMonth
};

@class GZMonthCalendrView;
@protocol GZMonthCalendrViewDelegate <NSObject,GZInfiniteScrollViewDelegate>

@optional
- (GZCalendarGridViewCellStyle) cellStyleForCalendarView:(GZMonthCalendrView *) calendarView;
- (id<GZCalendarCellLayout>) customCellLayoutForCalendarView:(GZMonthCalendrView *) calendarView;



- (void) calendarView:(GZMonthCalendrView *)calendarView didSelectDate:(NSDate *)date;
- (BOOL) calendarView:(GZMonthCalendrView *)calendarView shouldShowEventFromDate:(NSDate *)fromDate toDate:(NSDate *)date;
- (NSArray *) calendarView:(GZMonthCalendrView *)calendarView eventsFromDate:(NSDate *)fromDate toDate:(NSDate *)date;

//- (void) calendarView:(GZMonthCalendrView *)calendarView didShowHeaderLabels:(NSArray *)headerLabels;

//- (BOOL) calendarView:(GZMonthCalendrView *)calendarView shouldShowMonthHeaderLabel:(UILabel *)monthHeaderLabel onBaseDate:(NSDate *)baseDate;
//- (void) calendarView:(GZMonthCalendrView *)calendarView willShowMonthHeaderLabel:(UILabel *)monthHeaderLabel onBaseDate:(NSDate *)baseDate;
//- (void) calendarView:(GZMonthCalendrView *)calendarView didShowMonthHeaderLabel:(UILabel *)monthHeaderLabel onBaseDate:(NSDate *)baseDate;
//
//
//- (void) calendarView:(GZMonthCalendrView *)calendarView willHideMonthHeaderLabel:(UILabel *)monthHeaderLabel onBaseDate:(NSDate *)baseDate;
//- (void) calendarView:(GZMonthCalendrView *)calendarView didHideMonthHeaderLabel:(UILabel *)monthHeaderLabel onBaseDate:(NSDate *)baseDate;


@end

@interface GZMonthCalendrView : GZInfiniteScrollView<GZCalendarGridViewDelegate,GZCalendarGridViewDataSource>{
    
}

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, weak) IBOutlet id<GZMonthCalendrViewDelegate> delegate;
@property (nonatomic, readonly) NSDate *selectedDate;
@property (nonatomic, readonly) GZCalendarGridView *selectedCalendarView;
//@property (nonatomic, readonly) NSArray *headerLabels;
//@property (nonatomic) NSUInteger heightForWeek;

- (GZCalendarGridView *) visibleCalendarGridViewOnDate:(NSDate *)date;
- (GZCalendarGridView *) existCalendarGridViewOnDate:(NSDate *)date;

- (void) jumpToToday:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (void) jumpToDate:(NSDate *)date animate:(BOOL)animated completion:(void(^)(BOOL finished))completion;

- (void) selectDate:(NSDate *)date;

- (void) reloadDataBaseOn:(GZMonthCalendrViewUpdateBaseOnType)baseOnType WithDate:(NSDate *)date;
- (void) reloadDataWithDate:(NSDate *)date;

@end
