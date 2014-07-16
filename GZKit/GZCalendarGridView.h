//
//  GZCalendarGridView.h
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/6.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <GZKit/GZGridView.h>
#import <GZKit/GZCalendar.h>

#define IS_DEVICE_PAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define IS_DEVICE_PHONE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone

typedef enum GZCalendarGridViewCellStyle {
    GZCalendarGridViewCellStyleDateOnly = 0,
    GZCalendarGridViewCellStyleCustom = 9
} GZCalendarGridViewCellStyle;

typedef enum GZCalendarGridViewCellState {
    GZCalendarGridViewCellStateNormal = 0,
    GZCalendarGridViewCellStateDisable = 1,
    GZCalendarGridViewCellStateToday = 2,
    GZCalendarGridViewCellStateHoliday = 3
} GZCalendarGridViewCellState;

typedef enum GZCalendarGridViewType {
    GZCalendarGridViewTypeMonth,
    GZCalendarGridViewTypeWeek
} GZCalendarGridViewType;

@protocol GZCalendarGridViewDataSource,GZCalendarGridViewDelegate;

@interface GZCalendarGridView : UIView<GZGridViewDelegate,GZGridViewDataSource>{
    GZGridView *_eventGridView;
}

@property (nonatomic, weak,readonly) GZGridView *gridView;

@property (nonatomic) GZCalendarGridViewType calendarType;

@property (nonatomic, weak) IBOutlet id<GZCalendarGridViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<GZCalendarGridViewDelegate> delegate;

@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSDate *baseDate;

@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;

@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;

@property (nonatomic, readonly) NSDate *selectedDate;
@property (nonatomic, readonly) NSRange weekRange;

@property (nonatomic) GZCalendarWeekday firstWeekday;
@property (nonatomic) GZCalendarWeekday holidayWeekdays;

@property (nonatomic) BOOL canShowTitleLabel;
@property (nonatomic, readonly) UILabel *titleLabel;

- (BOOL) isExistDate:(NSDate *)date;

- (id) initWithFrame:(CGRect)frame baseDate:(NSDate *)baseDate calendarType:(GZCalendarGridViewType)calendarType;
- (id) initWithFrame:(CGRect)frame baseDate:(NSDate *)baseDate;

- (NSString *) monthStringForDate:(NSDate *)date;

- (CGPoint) locationOnDate:(NSDate *)date;

- (BOOL) selectDate:(NSDate *)date;
- (void) deselectDate:(NSDate *)date;

- (void) reloadData;
- (void) reloadDataWithDate:(NSDate *)baseDate;

@end

@protocol GZCalendarCellLayout;

@protocol GZCalendarGridViewDataSource <NSObject>
@optional

- (CGFloat) calendarView:(GZCalendarGridView *)calendarView heightInSection:(NSInteger)section;

- (id<GZCalendarCellLayout>) customCellLayoutForCalendarView:(GZCalendarGridView *) calendarView;
- (GZCalendarGridViewCellStyle) cellStyleForCalendarView:(GZCalendarGridView *) calendarView;



//Events Support
- (BOOL) calendarView:(GZCalendarGridView *)calendarView shouldShowEventFromDate:(NSDate *)fromDate toDate:(NSDate *)date;
- (NSArray *) calendarView:(GZCalendarGridView *) calendarView eventsFromStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate;

- (BOOL) calendarView:(GZCalendarGridView *) calendarView shouldEnableCellWithDate:(NSDate *)date;
- (BOOL) calendarView:(GZCalendarGridView *) calendarView shouldDrawCellWithCalendarState:(GZCalendarGridViewCellState)state;

@end

@protocol GZCalendarGridViewDelegate <NSObject>

@optional


- (BOOL) calendarView:(GZCalendarGridView *)calendarView shouldShowHeaderLabel:(UILabel *)headerLabel;

- (void) calendarView:(GZCalendarGridView *)calendarView willShowHeaderLabel:(UILabel *)headerLabel;
- (void) calendarView:(GZCalendarGridView *)calendarView didShowHeaderLabel:(UILabel *)headerLabel;

- (void) calendarView:(GZCalendarGridView *)calendarView willHideHeaderLabel:(UILabel *)headerLabel;
- (void) calendarView:(GZCalendarGridView *)calendarView didHideHeaderLabel:(UILabel *)headerLabel;

- (BOOL) calendarView:(GZCalendarGridView *)calendarView shouldHighlightCellForDate:(NSDate *)date;
- (BOOL) calendarView:(GZCalendarGridView *)calendarView shouldSelectCellForDate:(NSDate *)date;

- (void) calendarView:(GZCalendarGridView *)calendarView willHighlightDate:(NSDate *)date;
- (void) calendarView:(GZCalendarGridView *)calendarView willDehighlightDate:(NSDate *)date;
- (void) calendarView:(GZCalendarGridView *)calendarView willSelectDate:(NSDate *)date;
- (void) calendarView:(GZCalendarGridView *)calendarView willDeselectDate:(NSDate *)date;

- (void) calendarView:(GZCalendarGridView *)calendarView didHighlightDate:(NSDate *)date;
- (void) calendarView:(GZCalendarGridView *)calendarView didSelectDate:(NSDate *)date;
- (void) calendarView:(GZCalendarGridView *)calendarView didDehighlightDate:(NSDate *)date;
- (void) calendarView:(GZCalendarGridView *)calendarView didDeselectDate:(NSDate *)date;


@end
