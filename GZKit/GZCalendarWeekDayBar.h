//
//  GZCalendarWeekDayBar.h
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/10.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GZKit/GZGridView.h>
#import <GZKit/GZCalendar.h>

typedef enum GZWeekDayBarSymbolsType {
    GZWeekDayBarDefaultSymbolsType,
    GZWeekDayBarVeryShortSymbolsType,
    GZWeekDayBarShortSymbolsType,
    GZWeekDayBarStandaloneSymbolsType,
    GZWeekDayBarShortStandaloneSymbolsType,
    GZWeekDayBarVeryShortStandaloneSymbolsType,
} GZWeekDayBarSymbolsType;


typedef enum GZWeekDayBarWeekDayType {
    GZWeekDayBarWeekDayTypeNormal = 0,
    GZWeekDayBarWeekDayTypeHoliday = 1
} GZWeekDayBarWeekDayType;



@interface GZCalendarWeekDayBar : UIView <GZGridViewDataSource,GZGridViewDelegate>{
    @package
    GZGridView *_gridView;
}

@property (nonatomic) GZWeekDayBarSymbolsType symbolsType;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic) GZCalendarWeekday holidayWeekdays;
@property (nonatomic) GZCalendarWeekday firstWeekday;

- (void) setTextColor:(UIColor *)textColor forWeekDayType:(GZWeekDayBarWeekDayType)weekDayType;

@end
