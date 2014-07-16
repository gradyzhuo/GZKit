//
//  GZCalendarWeekDayBar.m
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/10.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZCalendarWeekDayBar.h"
#import <CoreText/CoreText.h>

@interface GZCalendarWeekDayBar (){
    NSArray *_weekDaySymbols;
    NSMutableArray *_textColors;
}

- (void)initialize;
- (void) resetData;

@end

@implementation GZCalendarWeekDayBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}



-(void)initialize{
    
    _textColors = [@[[UIColor blackColor], [UIColor colorWithWhite:0.702 alpha:1.000]] mutableCopy];
    
    _gridView = [[GZGridView alloc] initWithFrame:self.bounds];
    _gridView.dataSource = self;
    _gridView.delegate = self;
    [self addSubview:_gridView];
    
    _holidayWeekdays = GZCalendarWeekdaySaturday|GZCalendarWeekdaySunday;
    _calendar = [NSCalendar currentCalendar];
    
    [self setSymbolsType:GZWeekDayBarVeryShortStandaloneSymbolsType];
    

    [[NSNotificationCenter defaultCenter] addObserverForName:NSCurrentLocaleDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        _holidayWeekdays = GZCalendarWeekdaySaturday|GZCalendarWeekdaySunday;
        _calendar = [NSCalendar currentCalendar];
        
        [self setSymbolsType:GZWeekDayBarVeryShortStandaloneSymbolsType];
        [_gridView reloadData];
    }];

}

-(void)setSymbolsType:(GZWeekDayBarSymbolsType)symbolsType{
    _symbolsType = symbolsType;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    switch (symbolsType) {
        case GZWeekDayBarShortSymbolsType:
            _weekDaySymbols =[formatter shortWeekdaySymbols];
            break;
        case GZWeekDayBarVeryShortSymbolsType:
            _weekDaySymbols =[formatter veryShortWeekdaySymbols];
            break;
        case GZWeekDayBarStandaloneSymbolsType:
            _weekDaySymbols =[formatter standaloneWeekdaySymbols];
            break;
        case GZWeekDayBarShortStandaloneSymbolsType:
            _weekDaySymbols =[formatter shortStandaloneWeekdaySymbols];
            break;
        case GZWeekDayBarVeryShortStandaloneSymbolsType:
            _weekDaySymbols =[formatter veryShortStandaloneWeekdaySymbols];
            break;
        case GZWeekDayBarDefaultSymbolsType:
        default:
            _weekDaySymbols =[formatter weekdaySymbols];
            break;
    }

}

-(void)setTextColor:(UIColor *)textColor forWeekDayType:(GZWeekDayBarWeekDayType)weekDayType{
    if (weekDayType >0 && weekDayType<_textColors.count) {
        _textColors[weekDayType] = textColor;
    }
}

-(NSInteger)numberOfSectionInGridView:(GZGridView *)gridView{
    return 1;
}

-(NSInteger)gridView:(GZGridView *)gridView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

-(void)gridView:(GZGridView *)gridView cellContentInRect:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath{
    
    
    NSInteger weekday = indexPath.row + _calendar.firstWeekday > 7 ? indexPath.row + _calendar.firstWeekday -7 : indexPath.row + _calendar.firstWeekday;
    
    GZCalendarWeekday currentWeekDay = 1<<weekday;
    
    BOOL isHoliday = (currentWeekDay&_holidayWeekdays) ==  currentWeekDay;
    UIColor *textColor = (NO == isHoliday) ? _textColors[0]:_textColors[1];
    
    NSString *weekdayString = [_weekDaySymbols objectAtIndex:weekday-1];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentCenter;
    
    [weekdayString drawInRect:rect withAttributes:@{NSForegroundColorAttributeName:textColor , NSParagraphStyleAttributeName:style}];
}




@end
