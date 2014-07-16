//
//  GZCalendarGridView.m
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/6.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZCalendarGridView.h"
#import "GZCalendarCellLayout.h"
#import "GZCalendarCellLayoutDayOnly.h"


@interface GZCalendarGridView (){
    
    NSDateComponents *_todayDateComponents;
    id<GZCalendarCellLayout> _cellLayout;
    BOOL _needDrawEvent;
    
}

- (void)initialize;
- (void)initializeWithBaseDate:(NSDate *)baseDate;
- (void)initializeWithBaseDate:(NSDate *)baseDate calendarType:(GZCalendarGridViewType)calendarType;
- (NSDate *)dateAtIndexPath:(NSIndexPath *)indexPath;
- (NSDateComponents *)dateComponentsAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathFomDate:(NSDate *)date;

- (NSDateComponents *)defaultComponentOptionsFromDate:(NSDate *)date;
- (void) getCellStyle;

@end


@implementation GZCalendarGridView


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame baseDate:(NSDate *)baseDate{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeWithBaseDate:baseDate];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame baseDate:(NSDate *)baseDate calendarType:(GZCalendarGridViewType)calendarType{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeWithBaseDate:baseDate calendarType:calendarType];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    
    BOOL canRelayout = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    [super setFrame:frame];
    
    if (canRelayout) {
        
        if ([self.subviews containsObject:_titleLabel]) {
            CGFloat labelHeight = CGRectGetHeight(self.bounds)/(_weekRange.length+1);
            _titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), labelHeight);
            _gridView.frame = CGRectOffset(_titleLabel.frame, 0, CGRectGetHeight(self.bounds)-labelHeight);
        }else{
            _gridView.frame = self.bounds;
        }
        
        _eventGridView.frame = self.bounds;
    }
}

-(void)setCanShowTitleLabel:(BOOL)canShowTitleLabel{
    
    _canShowTitleLabel = canShowTitleLabel;
    
    [self showTitleLabelIfNeed];

}

- (void) showTitleLabelIfNeed{
    
    if (_canShowTitleLabel) {
        
        _titleLabel.text = [self monthStringForDate:_baseDate];
        
        if ([self.delegate respondsToSelector:@selector(calendarView:willShowHeaderLabel:)]) {
            [self.delegate calendarView:self willShowHeaderLabel:_titleLabel];
        }
        
        [self addSubview:_titleLabel];
        
        if ([self.delegate respondsToSelector:@selector(calendarView:didShowHeaderLabel:)]) {
            [self.delegate calendarView:self didShowHeaderLabel:_titleLabel];
        }
        
    }else{
        if ([self.delegate respondsToSelector:@selector(calendarView:willHideHeaderLabel:)]) {
            [self.delegate calendarView:self willHideHeaderLabel:_titleLabel];
        }
        [self.titleLabel removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(calendarView:didHideHeaderLabel:)]) {
            [self.delegate calendarView:self didHideHeaderLabel:_titleLabel];
        }
    }
    
    
//    NSUInteger weekOfMonth = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:_baseDate];
//    
//    
//    
//    if (weekOfMonth == 1) {
//        
//        NSInteger toYear = [_calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:[NSDate date]];
//        NSInteger year = [_calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:_baseDate];
//        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        if (toYear != year) {
//            [dateFormatter setDateFormat:@"LLL Y"];
//        }else{
//            [dateFormatter setDateFormat:@"LLL"];
//        }
//        
//        if (_canShowTitleLabel) {
//            _titleLabel.text = [dateFormatter stringFromDate:_baseDate];
//            
//            if ([self.delegate respondsToSelector:@selector(calendarView:willShowHeaderLabel:)]) {
//                [self.delegate calendarView:self willShowHeaderLabel:_titleLabel];
//            }
//            
//            [self addSubview:_titleLabel];
//            
//            if ([self.delegate respondsToSelector:@selector(calendarView:didShowHeaderLabel:)]) {
//                [self.delegate calendarView:self didShowHeaderLabel:_titleLabel];
//            }
//            
//        }
//        
//    }else{
//        if (_canShowTitleLabel) {
//            if ([self.delegate respondsToSelector:@selector(calendarView:willHideHeaderLabel:)]) {
//                [self.delegate calendarView:self willHideHeaderLabel:_titleLabel];
//            }
//            [self.titleLabel removeFromSuperview];
//            if ([self.delegate respondsToSelector:@selector(calendarView:didHideHeaderLabel:)]) {
//                [self.delegate calendarView:self didHideHeaderLabel:_titleLabel];
//            }
//        }
//        
//    }
}

- (NSString *)monthStringForDate:(NSDate *)date{
    NSInteger toYear = [_calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:[NSDate date]];
    NSInteger year = [_calendar ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (toYear != year) {
        [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"LLL Y" options:0 locale:[NSLocale currentLocale]]];
    }else{
        [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"LLL" options:0 locale:[NSLocale currentLocale]]];
    }
    
    NSString *monthString = [dateFormatter stringFromDate:date];
//    NSLog(@"monthString:%@",monthString);
    return monthString;
}

-(void)setBaseDate:(NSDate *)baseDate{
    
    _baseDate = baseDate;
    
    NSUInteger weekOfMonth = [_calendar ordinalityOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:_baseDate];
    

    BOOL shouldShowTitleLabelFromDelegate = [self.delegate respondsToSelector:@selector(calendarView:shouldShowHeaderLabel:)]?[self.delegate calendarView:self shouldShowHeaderLabel:_titleLabel]:YES;
    
    
    if (self.calendarType == GZCalendarGridViewTypeMonth) {
        _weekRange = [GZCalendar weekRangeFoMonthOnBaseDate:_baseDate inCalendar:_calendar];
        _startDate = [GZCalendar firstDateFromDate:_baseDate withFirstWeekDay:_firstWeekday inCalendar:_calendar];
        
        self.canShowTitleLabel = shouldShowTitleLabelFromDelegate;
        
    }else if (self.calendarType == GZCalendarGridViewTypeWeek){
        _weekRange = [GZCalendar weekRangeFoWeekOnBaseDate:_baseDate inCalendar:_calendar];
        _startDate = [GZCalendar firstDateOfWeekFromDate:_baseDate withFirstWeekDay:_firstWeekday inCalendar:_calendar];
        self.canShowTitleLabel = shouldShowTitleLabelFromDelegate && (1 == weekOfMonth);
    }
    
    
    _endDate = [_startDate dateByAddingTimeInterval:TIME_INTERVALS_FROM_INDEXPATH([NSIndexPath indexPathForRow:(WEEK_DAYS-1) inSection:_weekRange.length-1])];

}

-(BOOL) showEventViewIfNeed{
    BOOL shouldShowEvent = [_dataSource respondsToSelector:@selector(calendarView:shouldShowEventFromDate:toDate:)]?[_dataSource calendarView:self shouldShowEventFromDate:_startDate toDate:_endDate]:NO;
    
    if (shouldShowEvent) {
        [self addSubview:_eventGridView];
        [_eventGridView reloadData];
    }else{
        [_eventGridView removeFromSuperview];
    }
    return shouldShowEvent;
}

-(void)reloadData{
    
    [_gridView deSelectCellAtIndexPathes:_gridView.selectedIndexPathes];
    [self getCellStyle];
    [_gridView reloadData];
    [self showEventViewIfNeed];
    
}

-(void)reloadDataWithDate:(NSDate *)baseDate{
    
    self.baseDate = baseDate;
    [self reloadData];
}

-(void)setDelegate:(id<GZCalendarGridViewDelegate>)delegate{
    if (_delegate != delegate) {
        _delegate = delegate;
        [self reloadData];
    }
}

-(void)setDataSource:(id<GZCalendarGridViewDataSource>)dataSource{
    
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
    
}

-(NSIndexPath *)indexPathFomDate:(NSDate *)date{
    NSTimeInterval timeInterval = [date timeIntervalSinceDate:_startDate];
    NSInteger days = (NSInteger)floor(timeInterval/ONE_DAY_TIME_INTERVAL);
    
    NSInteger section = days / WEEK_DAYS;
    NSInteger row = days % WEEK_DAYS;
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (BOOL)isExistDate:(NSDate *)date{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self > %@ and self < %@", self.startDate, self.endDate];
    return [predicate evaluateWithObject:date];
    
    
}


-(BOOL)selectDate:(NSDate *)date{
    //補完
    NSIndexPath *indexPath = [self indexPathFomDate:date];
    return [_gridView selectCellAtIndexPath:indexPath];
}

-(void)deselectDate:(NSDate *)date{
    //補完，而且做date->indexPath的轉換
    [_gridView deSelectCellAtIndexPathes:@[[self indexPathFomDate:date]]];
}

#pragma mark - Private Methods

- (void)initialize{
    [self initializeWithBaseDate:[NSDate date] calendarType:GZCalendarGridViewTypeMonth];
}

- (void)initializeWithBaseDate:(NSDate *)baseDate{
    [self initializeWithBaseDate:baseDate calendarType:GZCalendarGridViewTypeMonth];
}

- (void)initializeWithBaseDate:(NSDate *)baseDate calendarType:(GZCalendarGridViewType)calendarType{
    
//    self.backgroundColor = [UIColor whiteColor];
    
    self.canShowTitleLabel = NO;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:20];//[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.textColor = [UIColor colorWithRed:1.000 green:0.343 blue:0.343 alpha:1.000];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    _firstWeekday = GZCalendarWeekdaySunday;
    _holidayWeekdays = GZCalendarWeekdaySaturday|GZCalendarWeekdaySunday;
    
    
    GZGridView *gridView = [[GZGridView alloc] initWithFrame:self.bounds];
    [self addSubview:gridView];
    _gridView = gridView;
    _gridView.dataSource = self;
    _gridView.delegate = self;
    
    _eventGridView = [[GZGridView alloc] initWithFrame:self.bounds];
    _eventGridView.dataSource = self;
    _eventGridView.delegate = self;
    
    _eventGridView.userInteractionEnabled = NO;

//    [self addSubview:_titleLabel];
    
//    [self showEventViewIfNeed];
//    [self addSubview:_eventGridView];
    

    _calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    self.calendarType = calendarType;
    self.baseDate = baseDate;
    
    _todayDateComponents = [self defaultComponentOptionsFromDate:[NSDate date]];
    
    _needDrawEvent = NO;
    
    
    
    [self getCellStyle];
    
}

-(NSDate *)dateAtIndexPath:(NSIndexPath *)indexPath{
    return [_startDate dateByAddingTimeInterval:TIME_INTERVALS_FROM_INDEXPATH(indexPath)];
}


-(NSDateComponents *)dateComponentsAtIndexPath:(NSIndexPath *)indexPath{
    return [self defaultComponentOptionsFromDate:[self dateAtIndexPath:indexPath]];
}


-(NSDateComponents *)defaultComponentOptionsFromDate:(NSDate *)date{
    return [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
}

-(void)getCellStyle{

    
    GZCalendarGridViewCellStyle cellStyle = [self.dataSource respondsToSelector:@selector(cellStyleForCalendarView:)]?[self.dataSource cellStyleForCalendarView:self]:GZCalendarGridViewCellStyleDateOnly;

    
    _cellLayout = nil;
    
    switch (cellStyle) {
        case GZCalendarGridViewCellStyleCustom:
        {
            NSAssert([_dataSource respondsToSelector:@selector(customCellLayoutForCalendarView:)], @"沒有實作提供CellLayoutClass的方法");
            _cellLayout = [_dataSource customCellLayoutForCalendarView:self];
        }
            break;
            //DateOnly是Default值
        case GZCalendarGridViewCellStyleDateOnly:
        default:
            _cellLayout = [[GZCalendarCellLayoutDayOnly alloc] init];
            break;
    }

}


-(GZCalendarGridViewCellState)cellStateAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDateComponents *dateComponents = [self dateComponentsAtIndexPath:indexPath];
    
    GZCalendarWeekday currentWeekDay = 1<<dateComponents.weekday;
    
    BOOL isHoliday = (currentWeekDay&_holidayWeekdays) ==  currentWeekDay;
    BOOL isToday = [dateComponents isEqual:_todayDateComponents];
    BOOL enabled = [self isCellEndableAtIndex:indexPath];
    
    GZCalendarGridViewCellState state = GZCalendarGridViewCellStateNormal;
    
    if (!enabled) {
        state = GZCalendarGridViewCellStateDisable;
    }
    else if (isToday) {
        state = GZCalendarGridViewCellStateToday;
    }else if (isHoliday){
        state = GZCalendarGridViewCellStateHoliday;
    }
    
    return state;
}

- (BOOL) isCellEnableOnDate:(NSDate *)date{
    NSDateComponents *baseDateComponents = [self defaultComponentOptionsFromDate:_baseDate];
    NSDateComponents *dateComponents = [self defaultComponentOptionsFromDate:date];
    
    NSComparisonResult minComparisonResult = [_minDate compare:date];
    NSComparisonResult maxComparisonResult = [_maxDate compare:date];
    
    BOOL isEnableDefault = baseDateComponents.month == dateComponents.month && (minComparisonResult == NSOrderedAscending ||minComparisonResult == NSOrderedSame) && (maxComparisonResult == NSOrderedDescending || maxComparisonResult == NSOrderedSame);
    
    return [_dataSource respondsToSelector:@selector(calendarView:shouldEnableCellWithDate:)]?[_dataSource calendarView:self shouldEnableCellWithDate:date]:isEnableDefault;
}

- (BOOL)isCellEndableAtIndex:(NSIndexPath *)indexPath{
    
    NSDateComponents *baseDateComponents = [self defaultComponentOptionsFromDate:_baseDate];
    NSDateComponents *dateComponents = [self dateComponentsAtIndexPath:indexPath];
    
    NSDate *date = [self dateAtIndexPath:indexPath];
    
    NSComparisonResult minComparisonResult = [_minDate compare:date];
    NSComparisonResult maxComparisonResult = [_maxDate compare:date];
    
    
    BOOL isEnableDefault = baseDateComponents.month == dateComponents.month && (minComparisonResult == NSOrderedAscending ||minComparisonResult == NSOrderedSame) && (maxComparisonResult == NSOrderedDescending || maxComparisonResult == NSOrderedSame);
    
    return [_dataSource respondsToSelector:@selector(calendarView:shouldEnableCellWithDate:)]?[_dataSource calendarView:self shouldEnableCellWithDate:date]:isEnableDefault;
}


#pragma mark - GZGridView Datasource

-(NSInteger)numberOfSectionInGridView:(GZGridView *)gridView{
    return self.calendarType == GZCalendarGridViewTypeMonth?_weekRange.length:1;
}

-(NSInteger)gridView:(GZGridView *)gridView numberOfRowsInSection:(NSInteger)section{
    return WEEK_DAYS;
}


-(void)gridView:(GZGridView *)gridView cellContentInRect:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath{
    
    GZCalendarGridViewCellState state = [self cellStateAtIndexPath:indexPath];
    
    if (gridView == _gridView) {
        NSDate *date = [self dateAtIndexPath:indexPath];
        
        if ([_cellLayout respondsToSelector:@selector(drawBackgroundInRect:withCellState:)]) {
            [_cellLayout drawBackgroundInRect:rect withCellState:state];
        }
        
        if (state == GZCalendarGridViewCellStateDisable) {
            if ([_cellLayout respondsToSelector:@selector(drawDisableCellInRect:onDate:)]) {
                [_cellLayout drawDisableCellInRect:rect onDate:date];
            }
        }else{
            if (state == GZCalendarGridViewCellStateToday && [_cellLayout respondsToSelector:@selector(drawTodayCellInRect:onDate:)]) {
                [_cellLayout drawTodayCellInRect:rect onDate:date];
            }
            else if (state == GZCalendarGridViewCellStateHoliday && [_cellLayout respondsToSelector:@selector(drawHolidayCellInRect:onDate:)]) {
                [_cellLayout drawHolidayCellInRect:rect onDate:date];
            }
            else{
                if ([_cellLayout respondsToSelector:@selector(drawNormalCellInRect:onDate:)]) {
                    [_cellLayout drawNormalCellInRect:rect onDate:date];
                }
            }
        }
    }
    
    else if(gridView == _eventGridView){
        
        
        NSDate *startDate = [self dateAtIndexPath:indexPath];
        NSDate *endDate = [startDate dateByAddingTimeInterval:ONE_DAY_TIME_INTERVAL];
        
        NSArray *events = [_dataSource respondsToSelector:@selector(calendarView:eventsFromStartDate:toEndDate:)]?[_dataSource calendarView:self eventsFromStartDate:startDate toEndDate:endDate]:@[];
        
        
        if (events.count > 0  ) {
            if ([_cellLayout respondsToSelector:@selector(drawEvents:inRect:withCellState:)]) {
                [_cellLayout drawEvents:events inRect:rect withCellState:state];
            }if ([_cellLayout respondsToSelector:@selector(drawEvents:inRect:withCellState:)]) {
                [_cellLayout drawEvents:events inRect:rect withCellState:state];
            }
        }
        
    }
    
    
    
    
    
}

-(CGFloat)gridView:(GZGridView *)gridView heightInSection:(NSInteger)section{
    return [_dataSource respondsToSelector:@selector(calendarView:heightInSection:)]?[_dataSource calendarView:self heightInSection:section]:-1;
}

-(void)gridView:(GZGridView *)gridView selectedCellContentInRect:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath{
    
    NSDate *date = [self dateAtIndexPath:indexPath];
    GZCalendarGridViewCellState state = [self cellStateAtIndexPath:indexPath];
    
    
    //Selected一定要有
    [_cellLayout drawSelectedCellInRect:rect onDate:date withCellState:state];
    
}

- (BOOL)gridView:(GZGridView *)gridView shouldShowCellInIndexPath:(NSIndexPath *)indexPath{
    GZCalendarGridViewCellState state = [self cellStateAtIndexPath:indexPath];
    
    BOOL drawable = [_dataSource respondsToSelector:@selector(calendarView:shouldDrawCellWithCalendarState:)]?[_dataSource calendarView:self shouldDrawCellWithCalendarState:state]:YES;
    
    return drawable;
    
}

-(void)gridView:(GZGridView *)gridView highlightedCellContentInRect:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath{

    NSDate *date = [self dateAtIndexPath:indexPath];

    GZCalendarGridViewCellState state = [self cellStateAtIndexPath:indexPath];
    
    if ([_cellLayout respondsToSelector:@selector(drawHighlightedCellInRect:onDate:withCellState:)]) {
        [_cellLayout drawHighlightedCellInRect:rect onDate:date withCellState:state];
    }
    else if ([_cellLayout respondsToSelector:@selector(drawSelectedCellInRect:onDate:withCellState:)]){
        [_cellLayout drawSelectedCellInRect:rect onDate:date withCellState:state];
    }


}

#pragma mark - GZGridView Delegate

-(BOOL)gridView:(GZGridView *)gridView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.delegate respondsToSelector:@selector(calendarView:shouldHighlightCellForDate:)]?[self.delegate calendarView:self shouldHighlightCellForDate:[self dateAtIndexPath:indexPath]]:YES;
}

-(BOOL)gridView:(GZGridView *)gridView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.delegate respondsToSelector:@selector(calendarView:shouldSelectCellForDate:)]?[self.delegate calendarView:self shouldSelectCellForDate:[self dateAtIndexPath:indexPath]]:YES;
}

-(void)gridView:(GZGridView *)gridView willHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(calendarView:willHighlightDate:)]) {
        [self.delegate calendarView:self willHighlightDate:[self dateAtIndexPath:indexPath]];
    }
}

-(void)gridView:(GZGridView *)gridView willSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(calendarView:willSelectDate:)]) {
        [self.delegate calendarView:self willSelectDate:[self dateAtIndexPath:indexPath]];
    }
}


-(void)gridView:(GZGridView *)gridView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(calendarView:didHighlightDate:)]) {
        [self.delegate calendarView:self didHighlightDate:[self dateAtIndexPath:indexPath]];
    }
}


-(void)gridView:(GZGridView *)gridView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _selectedDate = [self dateAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:self didSelectDate:[self dateAtIndexPath:indexPath]];
    }
}


-(void)gridView:(GZGridView *)gridView willDehighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(calendarView:willDehighlightDate:)]) {
        [self.delegate calendarView:self willDehighlightDate:[self dateAtIndexPath:indexPath]];
    }
}

-(void)gridView:(GZGridView *)gridView willDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(calendarView:willDeselectDate:)]) {
        [self.delegate calendarView:self willDeselectDate:[self dateAtIndexPath:indexPath]];
    }
}


-(void)gridView:(GZGridView *)gridView didDehighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(calendarView:didDehighlightDate:)]) {
        [self.delegate calendarView:self didDehighlightDate:[self dateAtIndexPath:indexPath]];
    }
}

-(void)gridView:(GZGridView *)gridView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(calendarView:didDeselectDate:)]) {
        [self.delegate calendarView:self didDeselectDate:[self dateAtIndexPath:indexPath]];
    }
}

#pragma mark - KVO
//
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    
//    if (object == _titleLabel && [keyPath isEqualToString:@"text"]) {
//        
//        [_titleLabel removeObserver:self forKeyPath:keyPath];
//        [_titleLabel addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
//    }
//    
//    
//}



- (UIImage*)screenshotWithView:(UIView *)view inRect:(CGRect)rect{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = rect.size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the window's anchor point
    CGContextTranslateCTM(context, view.center.x, view.center.y);
    // Apply the window's transform about the anchor point
    CGContextConcatCTM(context, view.transform);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context,
                          -CGRectGetWidth(view.bounds) * view.layer.anchorPoint.x,
                          -CGRectGetHeight(view.bounds) * view.layer.anchorPoint.y);
    
    // Render the layer hierarchy to the current context
    [view.layer renderInContext:context];
    
    // Restore the context
    CGContextRestoreGState(context);
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    
    
    return image;
}


@end
