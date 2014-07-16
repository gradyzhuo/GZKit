//
//  FMCalendarCellDayOnlyLayout.m
//  FMKit
//
//  Created by Zhuo Ting-Rui on 13/6/18.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZCalendarCellLayoutDayOnly.h"

@interface GZCalendarCellLayoutDayOnly (){

}

- (void)drawSideLineBottomInRect:(CGRect)rect;
- (CGRect) labelFrameFromRect:(CGRect)rect;

@end

@implementation GZCalendarCellLayoutDayOnly

#pragma mark - Private Function Method

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)drawSideLineBottomInRect:(CGRect)rect{
    //// Color Declarations
    UIColor* strokeColor = [UIColor colorWithRed: 0.333 green: 0.333 blue: 0.333 alpha: 1];
    
    //// Frames
    CGRect frame = rect;
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 0.5;
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00000 * CGRectGetWidth(frame), CGRectGetMaxY(frame) - bezierPath.lineWidth)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 1.00000 * CGRectGetWidth(frame), CGRectGetMaxY(frame) - bezierPath.lineWidth)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 1.00000 * CGRectGetWidth(frame), CGRectGetMaxY(frame) - bezierPath.lineWidth)];
    [strokeColor setStroke];
    
    [bezierPath stroke];
    
}

- (CGRect) labelFrameFromRect:(CGRect)rect{
    CGFloat labelWidth = (CGRectGetWidth(rect)>CGRectGetHeight(rect)?CGRectGetHeight(rect):CGRectGetWidth(rect))*0.55;
    labelWidth = labelWidth > 30.f ? 30 : labelWidth;
    
    CGRect labelRect = rect;
    labelRect.size = CGSizeMake(labelWidth, labelWidth);
    labelRect.origin = CGPointMake(labelRect.origin.x+CGRectGetWidth(rect)/2-(labelWidth/2), labelRect.origin.y+10);
    return labelRect;
}


#pragma mark - FMCalendarCellLayout Protocol

-(void)drawBackgroundInRect:(CGRect)rect withCellState:(GZCalendarGridViewCellState)state{
    if (state != GZCalendarGridViewCellStateDisable) {
        [self drawSideLineBottomInRect:rect];
    }
}

- (void) drawDate:(NSDate *)date inRect:(CGRect)frame withTextColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    NSString *dateText = [dateFormatter stringFromDate:date];
    
    CGFloat fontSize = CGRectGetWidth(frame)*0.8;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    [textColor setFill];
    [dateText drawInRect: frame withFont: font lineBreakMode:NSLineBreakByCharWrapping  alignment: NSTextAlignmentCenter];
}

-(void)drawNormalCellInRect:(CGRect)rect onDate:(NSDate *)date{
    
    rect = [self labelFrameFromRect:rect];
    
    [self drawDate:date inRect:rect withTextColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    
}

-(void)drawTodayCellInRect:(CGRect)rect onDate:(NSDate *)date{
    rect = [self labelFrameFromRect:rect];
    [self drawDate:date inRect:rect withTextColor:[UIColor colorWithRed:1.000 green:0.343 blue:0.343 alpha:1.000] backgroundColor:[UIColor whiteColor]];
}



-(void)drawHolidayCellInRect:(CGRect)rect onDate:(NSDate *)date{
    rect = [self labelFrameFromRect:rect];
    [self drawDate:date inRect:rect withTextColor:[UIColor colorWithWhite:0.702 alpha:1.000] backgroundColor:[UIColor whiteColor]];
}


-(void)drawDisableCellInRect:(CGRect)rect onDate:(NSDate *)date{
    rect = [self labelFrameFromRect:rect];
    [self drawDate:date inRect:rect withTextColor:[UIColor colorWithWhite:0.800 alpha:1.000] backgroundColor:[UIColor whiteColor]];
}


-(void)drawHighlightedCellInRect:(CGRect)rect onDate:(NSDate *)date withCellState:(GZCalendarGridViewCellState)state{
    
    if (CGRectGetWidth(rect) < CGRectGetHeight(rect)) {
        rect.size = CGSizeMake(rect.size.width, rect.size.width);
    }else{
        rect.size = CGSizeMake(CGRectGetHeight(rect), CGRectGetHeight(rect));
    }
    
    
    UIColor* fillColor = [UIColor colorWithWhite:0.500 alpha:0.650];

    if (state == GZCalendarGridViewCellStateToday) {
        fillColor = [UIColor colorWithRed:1.000 green:0.343 blue:0.343 alpha:1.000];
    }
    
    
    
    
    
    //// Abstracted Attributes
    CGRect ovalRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect));
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: ovalRect];
    [fillColor setFill];
    [ovalPath fill];
    
    [self drawDate:date inRect:ovalRect withTextColor:[UIColor whiteColor] backgroundColor:[UIColor colorWithWhite:1.000 alpha:0.000]];


}

-(void)drawSelectedCellInRect:(CGRect)rect onDate:(NSDate *)date withCellState:(GZCalendarGridViewCellState)state{
    rect = [self labelFrameFromRect:rect];
    
    if (CGRectGetWidth(rect) < CGRectGetHeight(rect)) {
        rect.size = CGSizeMake(rect.size.width, rect.size.width);
    }else{
        rect.size = CGSizeMake(CGRectGetHeight(rect), CGRectGetHeight(rect));
    }
    
    UIColor* fillColor = [UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000];

    if (state == GZCalendarGridViewCellStateToday) {
        fillColor = [UIColor colorWithRed:1.000 green:0.343 blue:0.343 alpha:1.000];
    }

    
    //// Abstracted Attributes
    CGRect ovalRect = CGRectMake(rect.origin.x-2.5, rect.origin.y-1, rect.size.width+5, rect.size.width+5);
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: ovalRect];
    [fillColor setFill];
    [ovalPath fill];
    
    [self drawDate:date inRect:rect withTextColor:[UIColor whiteColor] backgroundColor:[UIColor colorWithWhite:1.000 alpha:0.000]];


}

-(void)drawEvents:(NSArray *)events inRect:(CGRect)frame withCellState:(GZCalendarGridViewCellState)state{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor colorWithRed:1.000 green:0.800 blue:0.400 alpha:1.000];
    UIColor* color2 = [UIColor colorWithWhite:0.702 alpha:1.000];
    
    //// Shadow Declarations
    UIColor* shadow2 = color2;
    CGSize shadow2Offset = CGSizeMake(1.1, 1.1);
    CGFloat shadow2BlurRadius = 1;
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 5) * 0.50000) + 0.5, CGRectGetMinY(frame) + CGRectGetHeight(frame) - 8, 5, 5)];
    [strokeColor setFill];
    [ovalPath fill];
    
    ////// Oval Inner Shadow
    CGRect ovalBorderRect = CGRectInset([ovalPath bounds], -shadow2BlurRadius, -shadow2BlurRadius);
    ovalBorderRect = CGRectOffset(ovalBorderRect, -shadow2Offset.width, -shadow2Offset.height);
    ovalBorderRect = CGRectInset(CGRectUnion(ovalBorderRect, [ovalPath bounds]), -1, -1);
    
    UIBezierPath* ovalNegativePath = [UIBezierPath bezierPathWithRect: ovalBorderRect];
    [ovalNegativePath appendPath: ovalPath];
    ovalNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadow2Offset.width + round(ovalBorderRect.size.width);
        CGFloat yOffset = shadow2Offset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadow2BlurRadius,
                                    shadow2.CGColor);
        
        [ovalPath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(ovalBorderRect.size.width), 0);
        [ovalNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [ovalNegativePath fill];
    }
    CGContextRestoreGState(context);
}



@end
