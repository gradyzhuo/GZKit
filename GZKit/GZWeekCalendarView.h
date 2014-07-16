//
//  GZWeekCalendarView.h
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/15.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GZKit/GZPagingView.h>
#import <GZKit/GZCalendarGridView.h>

@class GZWeekCalendarView,GZCalendarGridViewDelegate;
@protocol GZWeekCalendrViewDelegate <NSObject,GZPagingViewDelegate, GZCalendarGridViewDelegate>

@optional
- (GZCalendarGridViewCellStyle) cellStyleForCalendarView:(GZWeekCalendarView *) calendarView;
- (id<GZCalendarCellLayout>) customCellLayoutForCalendarView:(GZWeekCalendarView *) calendarView;

- (BOOL) calendarView:(GZWeekCalendarView *)calendarView shouldShowEventFromDate:(NSDate *)fromDate toDate:(NSDate *)date;
- (NSArray *) calendarView:(GZWeekCalendarView *)calendarView eventsFromDate:(NSDate *)fromDate toDate:(NSDate *)date;

@end

@interface GZWeekCalendarView : GZPagingView<GZCalendarGridViewDataSource, GZCalendarGridViewDelegate>

@property (nonatomic, weak) IBOutlet id<GZWeekCalendrViewDelegate> delegate;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, readonly) NSDate *selectedDate;
@property (nonatomic, readonly) NSDate *baseDate;
@property (nonatomic, readonly) GZCalendarGridView *selectedCalendarView;


- (void) selectDate:(NSDate *)date;

- (void) reloadData;
- (void) reloadDataWithDate:(NSDate *)date;

@end
