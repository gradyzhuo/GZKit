//
//  GZWeekCalendarView.m
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/15.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZWeekCalendarView.h"


@interface GZWeekCalendarView (){
    GZCalendarGridView *_previousCalendarView;
}

@end

@implementation GZWeekCalendarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

//- (void) reloadDate{
//    GZCalendarGridView *currentGridView = (GZCalendarGridView *)self.currentPageView;
//    GZCalendarGridView *previousGridView = (GZCalendarGridView *)self.previousPageView;
//    GZCalendarGridView *nextGridView = (GZCalendarGridView *)self.nextPageView;
//    
//    [previousGridView reloadDataWithDate:[currentGridView.startDate dateByAddingTimeInterval:-1*ONE_DAY_TIME_INTERVAL]];
//    [nextGridView reloadDataWithDate:[currentGridView.endDate dateByAddingTimeInterval:ONE_DAY_TIME_INTERVAL]];
//    
//    
//    [currentGridView selectDate:[NSDate date]];
//    
//}

- (void)setDelegate:(id<GZWeekCalendrViewDelegate>)delegate{
    [super setDelegate:delegate];
    
    [self reloadData];
    [self selectDate:_selectedDate];
}

- (void) setup{
    _baseDate = [NSDate date];
    
    _calendar = [NSCalendar autoupdatingCurrentCalendar];
    self.infiniteEnable = YES;
    NSDate *date = [NSDate date];
    for (NSInteger i=0; i<3; i++) {
        GZCalendarGridView *calendarGridView = [[GZCalendarGridView alloc] initWithFrame:self.bounds baseDate:date calendarType:GZCalendarGridViewTypeWeek];
        calendarGridView.dataSource = self;
        calendarGridView.delegate = self;
        [self addPageView:calendarGridView];
    }
    
    [self reloadData];
    [self selectDate:_baseDate];
    
    
    
    
    
    __weak GZWeekCalendarView *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf reloadData];
        [weakSelf selectDate:weakSelf.selectedDate];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GZPagingViewDidStopNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        GZCalendarGridView *currentGridView = (GZCalendarGridView *)weakSelf.currentPageView;

        if (self.pagingPosition == GZPagingPositionLeft) {
            GZCalendarGridView *gridView = (GZCalendarGridView *)weakSelf.previousPageView;
            [gridView reloadDataWithDate:[currentGridView.startDate dateByAddingTimeInterval:-1*ONE_DAY_TIME_INTERVAL]];
            
            
        }else{
            GZCalendarGridView *gridView = (GZCalendarGridView *)weakSelf.nextPageView;
            [gridView reloadDataWithDate:[currentGridView.endDate dateByAddingTimeInterval:ONE_DAY_TIME_INTERVAL]];
        }
        
//        NSUInteger currentWeek = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYearForWeekOfYear forDate:currentGridView.baseDate];
//        
//        NSUInteger selectedWeek = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYearForWeekOfYear forDate:self.selectedDate];
//        
//        _selectedDate = currentWeek == selectedWeek ? self.selectedDate : currentGridView.startDate;
//        
//        [self selectDate:self.selectedDate isUserTouched:NO];
    }];
}


-(void)selectDate:(NSDate *)date isUserTouched:(BOOL)isUserTouched{
    
    NSDateComponents *willSelectDateComponents = [_calendar components:NSCalendarUnitYear|NSCalendarUnitWeekOfYear fromDate:date];
    
    NSArray *filtedCalendarGridView = [self.pageViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GZCalendarGridView * gridView, NSDictionary *bindings) {
        NSDateComponents *gridViewBaseDateComponents = [_calendar components:NSCalendarUnitYear|NSCalendarUnitWeekOfYear fromDate:gridView.baseDate];
        return [gridViewBaseDateComponents isEqual:willSelectDateComponents];
    }]];
    
    GZCalendarGridView *selectedCalendarGridView = filtedCalendarGridView.count>0?filtedCalendarGridView[0]:nil;
    
    
    if (_previousCalendarView != selectedCalendarGridView) {
        [_previousCalendarView deselectDate:_selectedDate];
    }
    
    
    [selectedCalendarGridView selectDate:date];

    
    if (isUserTouched && ![_selectedDate isEqualToDate:date] && [self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:(GZCalendarGridView *)self didSelectDate:date];
    }
    
    [self willChangeValueForKey:@"selectedDate"];
    _selectedDate = date;
    [self didChangeValueForKey:@"selectedDate"];
    
    _selectedCalendarView = selectedCalendarGridView;
    _previousCalendarView = selectedCalendarGridView;
    
}

-(void)selectDate:(NSDate *)date{
    
    GZCalendarGridView *currentCalendarGridView = (GZCalendarGridView *)self.currentPageView;
    GZCalendarGridView *previousCalendarGridView = (GZCalendarGridView *)self.previousPageView;
    GZCalendarGridView *nextCalendarGridView = (GZCalendarGridView *)self.nextPageView;
    
    NSUInteger currentWeek = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYearForWeekOfYear forDate:currentCalendarGridView.baseDate];
    
    NSUInteger willSelectWeek = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYearForWeekOfYear forDate:date];
    
    if (currentWeek > willSelectWeek) {
        [previousCalendarGridView reloadDataWithDate:date];
        [previousCalendarGridView selectDate:date];
        [self pagingToPreviousPage:YES];
    }else if (currentWeek < willSelectWeek){
        [nextCalendarGridView reloadDataWithDate:date];
        [nextCalendarGridView selectDate:date];
        [self pagingToNextPage:YES];
    }

    
    [self selectDate:date isUserTouched:NO];
    
}


-(void)reloadData{
    [self reloadDataWithDate:_baseDate];
}

-(void)reloadDataWithDate:(NSDate *)date{
    _baseDate = date;
    
    GZCalendarGridView *currentGridView = (GZCalendarGridView *)self.currentPageView;
    GZCalendarGridView *previousGridView = (GZCalendarGridView *)self.previousPageView;
    GZCalendarGridView *nextGridView = (GZCalendarGridView *)self.nextPageView;
    
    
    [currentGridView reloadDataWithDate:date];
    [previousGridView reloadDataWithDate:[currentGridView.startDate dateByAddingTimeInterval:DAYS_TIME_INTERVAL(-1)]];
    [nextGridView reloadDataWithDate:[currentGridView.endDate dateByAddingTimeInterval:ONE_DAY_TIME_INTERVAL]];
    
    
}

#pragma mark - GZCalendarGridView Delegate

-(GZCalendarGridViewCellStyle)cellStyleForCalendarView:(GZCalendarGridView *)calendarView{
    
    GZCalendarGridViewCellStyle style = [self.delegate respondsToSelector:@selector(cellStyleForCalendarView:)]?[self.delegate cellStyleForCalendarView:self]:GZCalendarGridViewCellStyleDateOnly;
    return style;
}

-(id<GZCalendarCellLayout>)customCellLayoutForCalendarView:(GZCalendarGridView *)calendarView{
    
    NSAssert([self.delegate respondsToSelector:@selector(customCellLayoutForCalendarView:)], @"Delegate 需實作");
    id<GZCalendarCellLayout> cellLayout = [self.delegate customCellLayoutForCalendarView:self];
    NSAssert(cellLayout != nil, @"Cell Layout 不可為nil");
    
    return cellLayout;
}

-(BOOL)calendarView:(GZCalendarGridView *)calendarView shouldEnableCellWithDate:(NSDate *)date{
    return YES;
}


-(void)calendarView:(GZCalendarGridView *)calendarView didSelectDate:(NSDate *)date{
    
    [self selectDate:date isUserTouched:YES];
}

-(BOOL)calendarView:(GZCalendarGridView *)calendarView shouldShowEventFromDate:(NSDate *)fromDate toDate:(NSDate *)date{
    return [self.delegate respondsToSelector:@selector(calendarView:shouldShowEventFromDate:toDate:)]?[self.delegate calendarView:self shouldShowEventFromDate:fromDate toDate:date]:NO;
}

-(NSArray *)calendarView:(GZCalendarGridView *)calendarView eventsFromStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate{
    return [self.delegate respondsToSelector:@selector(calendarView:eventsFromDate:toDate:)]?[self.delegate calendarView:self eventsFromDate:startDate toDate:endDate]:nil;
}

@end
