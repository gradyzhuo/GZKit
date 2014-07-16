//
//  GZInfiniteMonthCalendrView.m
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/7.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZMonthCalendrView.h"
#import "GZCalendarGridView.h"
#import "GZCalendarCellLayoutDayOnly.h"

#define HEIGHT_FOR_WEEK 60

@interface GZMonthCalendrView (){
    NSDate *_baseDate;
    GZMonthCalendrViewUpdateBaseOnType _baseOnType;
    GZCalendarGridView *_previousSelectedCalendarView;
}



- (BOOL) isTodayCalendarView:(GZCalendarGridView *)calendarView;

@end

@implementation GZMonthCalendrView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _baseOnType = GZMonthCalendrViewUpdateBaseOnTypeMonth;
        
        self.alwaysBounceVertical = YES;
        _baseDate = [NSDate date];
        
        _selectedDate = _baseDate;
        
        _calendar = [NSCalendar autoupdatingCurrentCalendar];
//        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        
        __weak id weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf reloadDataBaseOn:GZMonthCalendrViewUpdateBaseOnTypeMonth WithDate:self.selectedDate];
        }];
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _baseOnType = GZMonthCalendrViewUpdateBaseOnTypeMonth;
        self.alwaysBounceVertical = YES;
        _baseDate = [NSDate date];
        _selectedDate = _baseDate;
        _calendar = [NSCalendar autoupdatingCurrentCalendar];
//        self.showsVerticalScrollIndicator = YES;
//        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSCurrentLocaleDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self reloadDataBaseOn:GZMonthCalendrViewUpdateBaseOnTypeMonth WithDate:self.selectedDate];
        }];
        
    }
    return self;
}


-(void)selectDate:(NSDate *)date isUserTouched:(BOOL)isUserTouched{
    
    if (self.visibleContentViews.count == 0) {
        [self layoutSubviews];
    }
    
    
    
    NSDateComponents *selectedDateWeekComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear fromDate:date];
    
    NSArray *filtedGridViews = [self.visibleContentViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GZCalendarGridView *gridView, NSDictionary *bindings) {
        NSDateComponents *gridBaseDateComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear fromDate:gridView.baseDate];
        
        return [gridBaseDateComponents isEqual:selectedDateWeekComponents];
    }]];
    
    GZCalendarGridView *selectedCalendarGridView = filtedGridViews.count>0?filtedGridViews[0]:nil;
    _selectedCalendarView = selectedCalendarGridView;
    
    if (_previousSelectedCalendarView != selectedCalendarGridView) {
        [_previousSelectedCalendarView deselectDate:_selectedDate];
    }
    [selectedCalendarGridView selectDate:date];
    [self willChangeValueForKey:@"selectedDate"];
    _selectedDate = date;
    [self didChangeValueForKey:@"selectedDate"];
    
    if (isUserTouched && [self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:self didSelectDate:date];
    }
    _previousSelectedCalendarView = selectedCalendarGridView;
    
}


-(void)selectDate:(NSDate *)date{
    [self selectDate:date isUserTouched:NO];
}

-(void)reloadDataWithDate:(NSDate *)date{
    _baseDate = date;
    
    [self reloadData];
    [self setNeedsLayout];
}


-(void)reloadDataBaseOn:(GZMonthCalendrViewUpdateBaseOnType)baseOnType WithDate:(NSDate *)date{
    _baseOnType = baseOnType;
    _baseDate = date;
//    _calendar = [NSCalendar currentCalendar];
    [self reloadDataWithDate:date];
    
}

//TODO: 目的產生現在有那些Label顯示出來用的
//- (void)layoutSubviews{
//    [super layoutSubviews];
//    
//    CGRect visibleBounds = [self bounds];
//    
//    
//    
//    NSArray *visibleHeaderViews = [_mutableVisibleContentViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GZCalendarGridView *evaluatedContentView, NSDictionary *bindings) {
//        //CGRectContainsPoint(visibleBounds, evaluatedContentView.frame.origin)
//        
//        return CGRectIntersectsRect(visibleBounds, evaluatedContentView.frame) && evaluatedContentView.canShowTitleLabel;
//    }]];
//    
//    NSArray *labels = [visibleHeaderViews valueForKeyPath:@"self.titleLabel"];
//    
//    if ([self.delegate respondsToSelector:@selector(calendarView:didShowHeaderLabels:)]) {
//        [self.delegate calendarView:self didShowHeaderLabels:labels];
//    }
//
//    _headerLabels = labels;
//    
//}

- (GZCalendarGridView *) existCalendarGridViewOnDate:(NSDate *)date{
    NSDateComponents *selectedDateWeekComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear fromDate:date];
    
    NSArray *filtedGridViews = [self.visibleContentViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GZCalendarGridView *gridView, NSDictionary *bindings) {
        NSDateComponents *gridBaseDateComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear fromDate:gridView.baseDate];
        
        return [gridBaseDateComponents isEqual:selectedDateWeekComponents];
    }]];
    
    return filtedGridViews.count>0?filtedGridViews[0]:nil;
    
}

-(GZCalendarGridView *)visibleCalendarGridViewOnDate:(NSDate *)date{
    NSDateComponents *selectedDateWeekComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear fromDate:date];
    
    CGRect visibleBounds = [self bounds];
    
    NSArray *filtedGridViews = [self.visibleContentViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GZCalendarGridView *gridView, NSDictionary *bindings) {
        NSDateComponents *gridBaseDateComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear fromDate:gridView.baseDate];
        
        return [gridBaseDateComponents isEqual:selectedDateWeekComponents] && CGRectIntersectsRect(visibleBounds, gridView.frame);
    }]];
    
    return filtedGridViews.count>0?filtedGridViews[0]:nil;
    
}

-(BOOL)isTodayCalendarView:(GZCalendarGridView *)calendarView{
    NSDateComponents *todayDateComponents = [_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
    
    return [todayDateComponents isEqual:[_calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:calendarView.baseDate]];
}

-(void)jumpToDate:(NSDate *)date animate:(BOOL)animated completion:(void (^)(BOOL))completion{
    GZCalendarGridView *gridView = [self existCalendarGridViewOnDate:date];
    
    if (gridView) {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                [self setContentOffset:gridView.frame.origin];
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
        else{
            [self setContentOffset:gridView.frame.origin];
            if (completion) {
                completion(YES);
            }
        }
        
    }else{
        
        NSLog(@"date:%@",date);
        
        [self reloadDataBaseOn:GZMonthCalendrViewUpdateBaseOnTypeMonth WithDate:date];
        [self selectDate:date];
        if (completion) {
            completion(YES);
        }
    }
    
}

-(void)jumpToToday:(BOOL)animated completion:(void (^)(BOOL))completion{
    NSDate *todayDate = [NSDate date];
    [self jumpToDate:todayDate animate:animated completion:completion];
}




#pragma mark - Override

- (UIView *) getContentViewFromDataSourceWithReuseContentView:(GZCalendarGridView *)contentView nearBy:(GZCalendarGridView *)nearByContentView withPosition:(GZInfiniteScrollViewContentViewPosition)position{

    if (contentView == nil) {
        
        switch (_baseOnType) {
            case GZMonthCalendrViewUpdateBaseOnTypeWeek:
            {
                
                NSDate *startDate = [GZCalendar firstDateOfWeekFromDate:_baseDate withFirstWeekDay:1<<_calendar.firstWeekday inCalendar:_calendar];
                
                NSDate *endDate = [startDate dateByAddingTimeInterval:WEEK_TIME_INTERVAL-ONE_DAY_TIME_INTERVAL];
                
                contentView = [[GZCalendarGridView alloc] initWithFrame:CGRectZero baseDate:endDate calendarType:GZCalendarGridViewTypeWeek];
                
                contentView.delegate = self;
                contentView.dataSource = self;
                contentView.gridView.highlightCellWhenMoving = YES;
                
                contentView.baseDate = endDate;
            }
                break;
                
            case GZMonthCalendrViewUpdateBaseOnTypeMonth:
            default:
            {
                NSDate *startDate = [GZCalendar firstDateFromDate:_baseDate withFirstWeekDay:1<<_calendar.firstWeekday inCalendar:_calendar];
                
                NSDate *endDate = [startDate dateByAddingTimeInterval:WEEK_TIME_INTERVAL-ONE_DAY_TIME_INTERVAL];
                
                contentView = [[GZCalendarGridView alloc] initWithFrame:CGRectZero baseDate:endDate calendarType:GZCalendarGridViewTypeWeek];
                
                contentView.delegate = self;
                contentView.dataSource = self;
                contentView.gridView.highlightCellWhenMoving = YES;
                
                contentView.baseDate = endDate;
            }
                break;
        }
        
    }
    
    if (nearByContentView){
        
        NSDate *nearStartDate = nearByContentView.startDate;
        NSDate *nearEndDate = nearByContentView.endDate;
        
        NSInteger nearStartWeekOfMonth = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:nearStartDate];
        NSInteger nearEndWeekOfMonth = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:nearEndDate];
        
        NSInteger nearWeek = nearByContentView.weekRange.location;
        NSInteger nearYear = [_calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:nearByContentView.baseDate];
        
        NSRange nearBaseWeekRange = [GZCalendar weekRangeFoMonthOnBaseDate:nearByContentView.baseDate inCalendar:_calendar];
        
        NSInteger nearBaseWeekOfMonth = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:nearByContentView.baseDate];
        
        NSUInteger nearFirstWeekOfMonth = [GZCalendar firstWeekOfMonthWithDate:nearByContentView.baseDate inCalendar:_calendar];
        
        if (position == GZInfiniteScrollViewContentViewPositionTop) {
            
            //因為是Top，所以看現在下面的Week的EndDate是不是下個月份的第一週
            if (nearStartWeekOfMonth!=nearEndWeekOfMonth && nearBaseWeekOfMonth == nearFirstWeekOfMonth) {
                [contentView reloadDataWithDate:nearStartDate];
                
            }else{
                //因為是Top，所以比較Care的是下個月的EndDate所代表的週次是不是下個月正要開始的週次(都會是在右側)
                //所以更新是用WeekEndDate 而不是StartDate
                NSDate *weekEndDate = [GZCalendar endDateOfWeek:--nearWeek inYear:nearYear inCalendar:_calendar];
                [contentView reloadDataWithDate:weekEndDate];
                
            }
            
            
            
            
        }else{
            //因為是Bottom，所以看現在上面的Week的StartDate是不是下個月份的第一週
            if (nearStartWeekOfMonth!=nearEndWeekOfMonth && nearBaseWeekOfMonth == nearBaseWeekRange.length) {
                //現在這裡是本月份的開始第一週
                [contentView reloadDataWithDate:nearEndDate];
                
            }else{
                //因為是Bottom，所以比較Care的是上個月的StartDate所代表的週次是不是上個月已經結束的週次(都會是在左側)
                //所以更新是用WeekStartDate 而不是EndDate
                NSDate *weekStartDate = [GZCalendar firstDateOfWeek:++nearWeek inYear:nearYear inCalendar:_calendar];
                [contentView reloadDataWithDate:weekStartDate];
            }
            
            
            
            
            
        }
        
    }
    
    if ([contentView selectDate:_selectedDate]) {
        _previousSelectedCalendarView = contentView;
    }
    
    return contentView;
}

- (CGSize) getContentViewSizeFromDataSourceWithReuseContentView:(GZCalendarGridView *)contentView nearBy:(GZCalendarGridView *)nearByContentView withPosition:(GZInfiniteScrollViewContentViewPosition)position{
    
    NSUInteger weekOfMonth = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:contentView.baseDate];
    NSUInteger firstWeekOfMonth = [GZCalendar firstWeekOfMonthWithDate:contentView.baseDate inCalendar:_calendar];

    
    CGFloat height = (contentView.weekRange.length*HEIGHT_FOR_WEEK);
    if (weekOfMonth == firstWeekOfMonth) {
        height *= 2;
    }

    return CGSizeMake(CGRectGetWidth(self.bounds), height);
}


//- (CGFloat) getHighForHeaderViewFromDataSourceWithContentView:(UIView *)contentView{
//    return 0.f;
//}


#pragma mark - GZCalendarGridView Datasource

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



-(BOOL)calendarView:(GZCalendarGridView *)calendarView shouldShowEventFromDate:(NSDate *)fromDate toDate:(NSDate *)date{
    return [self.delegate respondsToSelector:@selector(calendarView:shouldShowEventFromDate:toDate:)]?[self.delegate calendarView:self shouldShowEventFromDate:fromDate toDate:date]:NO;
}

-(NSArray *)calendarView:(GZCalendarGridView *)calendarView eventsFromStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate{
    return [self.delegate respondsToSelector:@selector(calendarView:eventsFromDate:toDate:)]?[self.delegate calendarView:self eventsFromDate:startDate toDate:endDate]:nil;
}
//
//-(BOOL)calendarView:(GZCalendarGridView *)calendarView shouldShowHeaderLabel:(UILabel *)headerLabel{
//    return [self.delegate respondsToSelector:@selector(calendarView:shouldShowMonthHeaderLabel:onBaseDate:)]?[self.delegate calendarView:self shouldShowMonthHeaderLabel:headerLabel onBaseDate:calendarView.baseDate]:YES;
//}
//
//-(void)calendarView:(GZCalendarGridView *)calendarView willShowHeaderLabel:(UILabel *)headerLabel{
//    if ([self.delegate respondsToSelector:@selector(calendarView:willShowMonthHeaderLabel:onBaseDate:)]) {
//        [self.delegate calendarView:self willShowMonthHeaderLabel:headerLabel onBaseDate:calendarView.baseDate];
//    }
//}
//
//-(void)calendarView:(GZCalendarGridView *)calendarView didShowHeaderLabel:(UILabel *)headerLabel{
//    if ([self.delegate respondsToSelector:@selector(calendarView:didShowMonthHeaderLabel:onBaseDate:)]) {
//        [self.delegate calendarView:self didShowMonthHeaderLabel:headerLabel onBaseDate:calendarView.baseDate];
//    }
//}
//
//- (void)calendarView:(GZCalendarGridView *)calendarView willHideHeaderLabel:(UILabel *)headerLabel{
//    if ([self.delegate respondsToSelector:@selector(calendarView:willHideMonthHeaderLabel:onBaseDate:)]) {
//        [self.delegate calendarView:self willHideMonthHeaderLabel:headerLabel onBaseDate:calendarView.baseDate];
//    }
//}
//
//-(void)calendarView:(GZCalendarGridView *)calendarView didHideHeaderLabel:(UILabel *)headerLabel{
//    if ([self.delegate respondsToSelector:@selector(calendarView:didHideMonthHeaderLabel:onBaseDate:)]) {
//        [self.delegate calendarView:self didHideMonthHeaderLabel:headerLabel onBaseDate:calendarView.baseDate];
//    }
//}

-(BOOL)calendarView:(GZCalendarGridView *)calendarView shouldDrawCellWithCalendarState:(GZCalendarGridViewCellState)state{
    return state != GZCalendarGridViewCellStateDisable;
}

-(void)calendarView:(GZCalendarGridView *)calendarView didSelectDate:(NSDate *)date{
    [self selectDate:date isUserTouched:YES];
}


@end
