//
//  FMCalendarViewCellLayout.h
//  FMKit
//
//  Created by Zhuo Ting-Rui on 13/6/18.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GZKit/GZCalendarGridView.h>

/**
 GZCalendarCellLayout
 
 使用FMCalendarCellLayout Protocol 規劃Cell的呈現行為.
 使用者需實作其中的繪圖方法細節，達成需求。
 
 */

@protocol GZCalendarCellLayout <NSObject>
@required

- (void) drawNormalCellInRect:(CGRect)rect onDate:(NSDate *)date;

- (void) drawSelectedCellInRect:(CGRect)rect onDate:(NSDate *)date withCellState:(GZCalendarGridViewCellState)state;

@optional
/** @name Optional Draw Method  */
- (void) drawBackgroundInRect:(CGRect)rect withCellState:(GZCalendarGridViewCellState)state;

- (void) drawTodayCellInRect:(CGRect)rect onDate:(NSDate *)date;

- (void) drawHolidayCellInRect:(CGRect)rect onDate:(NSDate *)date;

- (void) drawDisableCellInRect:(CGRect)rect onDate:(NSDate *)date;

- (void) drawHighlightedCellInRect:(CGRect)rect onDate:(NSDate *)date withCellState:(GZCalendarGridViewCellState)state;

- (void) drawEvents:(NSArray *)events inRect:(CGRect)frame withCellState:(GZCalendarGridViewCellState)state;

@end
