//
//  GZInfiniteScrollView.m
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/7.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZInfiniteScrollView.h"

@interface GZInfiniteScrollView (){
    CGFloat _visibleExtension;
    CGFloat _contentInfiniteSize;
}

- (UIView *)insertContentViewNearBy:(UIView *)nearByContentView withPosition:(GZInfiniteScrollViewContentViewPosition)position;

@end


@implementation GZInfiniteScrollView
@synthesize visibleContentViews = _mutableVisibleContentViews;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initialize];
    }
    return self;
}


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize{
    
    _contentInfiniteSize = 1704;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recenterIfNecessary) name:@"DidEndSmoothScrolling" object:nil];
    
    [self reloadData];
    
    [self recenterIfNecessary];
    
}


-(void) scrollViewDidFinishScrolling:(NSNotification *)note{
    
}


- (UIView *)visibleContentViewInLocation:(CGPoint)location{
    NSArray *views =  [self.visibleContentViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView  *visibleContentView, NSDictionary *bindings) {
        
        return CGRectContainsPoint(visibleContentView.frame, location);
    }]];
    
    return views[0];
}


- (void) resetData{
    
    [_mutableVisibleContentViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _mutableVisibleContentViews = [[NSMutableArray alloc] init];
    _contentViewPool = [@[] mutableCopy];
    if (self.alwaysBounceHorizontal) {
        _visibleExtension = CGRectGetWidth([self bounds]);
    }else{
        _visibleExtension = CGRectGetHeight([self bounds]);
    }

}

-(void)reloadData{

    if (self.alwaysBounceHorizontal) {
        self.contentSize = CGSizeMake(_contentInfiniteSize, CGRectGetHeight(self.bounds));
    }else{
        self.contentSize = CGSizeMake(self.bounds.size.width, _contentInfiniteSize);
    }
    
    [self resetData];
    // hide horizontal scroll indicator so our recentering trick is not revealed
//    [self setShowsHorizontalScrollIndicator:NO];
//    [self setShowsVerticalScrollIndicator:NO];
    
}

-(void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal{
    [super setAlwaysBounceHorizontal:alwaysBounceHorizontal];
    if (alwaysBounceHorizontal) {
//        self.alwaysBounceVertical = NO;
        self.contentSize = CGSizeMake(_contentInfiniteSize, CGRectGetHeight(self.frame));
    }
}

-(void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical{
    [super setAlwaysBounceVertical:alwaysBounceVertical];
    if (alwaysBounceVertical) {
//        self.alwaysBounceHorizontal = NO;
        self.contentSize = CGSizeMake(self.frame.size.width, _contentInfiniteSize);
    }
}

-(NSArray *)visibleContentViews{
    return [_mutableVisibleContentViews copy];
}

-(void)setRecenterIfNeed{
    if (self.alwaysBounceHorizontal) {
        CGPoint currentOffset = [self contentOffset];
        CGFloat contentWidth = [self contentSize].width;
        CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;

        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        // move content by the same amount so it appears to stay still
        for (UIView *contentView in _mutableVisibleContentViews) {
            CGPoint center = contentView.center;//[self.contentContainerView convertPoint:label.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            contentView.center = center;//[self convertPoint:center toView:self.contentContainerView];
        }
    }else{
        CGPoint currentOffset = [self contentOffset];
        CGFloat contentHeight = [self contentSize].height;
        CGFloat centerOffsetY = (contentHeight - CGRectGetHeight(self.frame)) / 2.0;
        
        self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY);
        
        // move content by the same amount so it appears to stay still
        for (UIView *contentView in _mutableVisibleContentViews) {
            CGPoint center = contentView.center;//[self.contentContainerView convertPoint:label.center toView:self];
            center.y += (centerOffsetY - currentOffset.y);
            contentView.center = center;
        }
    }
    
}

#pragma mark - Layout

// recenter content periodically to achieve impression of infinite scrolling
- (void)recenterIfNecessary
{
    
    if (self.alwaysBounceHorizontal) {
        CGPoint currentOffset = [self contentOffset];
        CGFloat contentWidth = [self contentSize].width;
        CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
        CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
        
        if (distanceFromCenter > contentWidth / 3)
        {
            [self setRecenterIfNeed];
        }
        

    }else{
        CGPoint currentOffset = [self contentOffset];
        CGFloat contentHeight = [self contentSize].height;
        CGFloat centerOffsetY = (contentHeight - [self bounds].size.height) / 2.0;
        CGFloat distanceFromCenter = fabs(currentOffset.y - centerOffsetY);
        
        if (distanceFromCenter > contentHeight / 3)
        {
            [self setRecenterIfNeed];
        }
        
//        if (distanceFromCenter > CGRectGetHeight(self.bounds))
//        {
//            [self setRecenterIfNeed];
//        }
    }
    
    
}

- (void)setPagingEnabled:(BOOL)pagingEnabled{
    [super setPagingEnabled:pagingEnabled];
    
}

-(void)setBounds:(CGRect)bounds{
    CGRect currentBounds = self.bounds;
    [super setBounds:bounds];
    
    if (!CGSizeEqualToSize(currentBounds.size, bounds.size)) {
        [self reloadData];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    if (self.scrollEnabled) {
//        
//        if (!self.pagingEnabled) {
//            [self recenterIfNecessary];
//        }
//        
//        CGRect visibleBounds = [self bounds];
//        
//        if (self.alwaysBounceHorizontal) {
//            CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
//            CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
//            [self placeContentViewsFromMinX:minimumVisibleX-_visibleExtension toMaxX:maximumVisibleX+_visibleExtension];
//        }else{
//            CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
//            CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
//            [self placeContentViewsFromMinY:minimumVisibleY-_visibleExtension toMaxY:maximumVisibleY+_visibleExtension];
//            
//        }
//    }
    
    [self recenterIfNecessary];
    
    CGRect visibleBounds = [self bounds];
    
    if (self.alwaysBounceHorizontal) {
        CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
        CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
        [self placeContentViewsFromMinX:minimumVisibleX-_visibleExtension toMaxX:maximumVisibleX+_visibleExtension];
    }else{
        CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
        CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
        [self placeContentViewsFromMinY:minimumVisibleY-_visibleExtension toMaxY:maximumVisibleY+_visibleExtension];
        
    }
    

}


#pragma mark - Label Tiling

- (CGFloat) getHighForHeaderViewFromDataSourceWithContentView:(UIView *)contentView{
    return [self.delegate respondsToSelector:@selector(scrollView:heightForheaderWithContentView:)]?[self.delegate scrollView:self heightForheaderWithContentView:contentView]:0.f;
}

-(UIView *)contentViewNearBy:(UIView *)nearByContent position:(GZInfiniteScrollViewContentViewPosition)position{
    
    NSInteger index = [_mutableVisibleContentViews indexOfObject:nearByContent];
    UIView *result;
    switch (position) {
        case GZInfiniteScrollViewContentViewPositionRight:
        case GZInfiniteScrollViewContentViewPositionBottom:
            result = _mutableVisibleContentViews.count>(index+1)?_mutableVisibleContentViews[index+1]:nil;
            break;
            
        case GZInfiniteScrollViewContentViewPositionLeft:
        case GZInfiniteScrollViewContentViewPositionTop:
            result = _mutableVisibleContentViews.count>(index-1)?_mutableVisibleContentViews[index-1]:nil;
            break;
            
        default:
            break;
    }
    return result;
}

- (UIView *) getContentViewFromDataSourceWithReuseContentView:(UIView *)contentView nearBy:(UIView *)nearByContentView withPosition:(GZInfiniteScrollViewContentViewPosition)position{
    if ([_dataSource respondsToSelector:@selector(scrollView:reuseContentView:nearBy:fromPosition:)]) {
        contentView = [_dataSource scrollView:self reuseContentView:contentView nearBy:nearByContentView fromPosition:position];
    }
    return contentView;
}

- (CGSize) getContentViewSizeFromDataSourceWithReuseContentView:(UIView *)contentView nearBy:(UIView *)nearByContentView withPosition:(GZInfiniteScrollViewContentViewPosition)position{
    
    CGSize contentViewSize = self.bounds.size;
    
    if ([_dataSource respondsToSelector:@selector(scrollView:sizeForContentView:nearBy:fromPosition:)]) {
        contentViewSize = [_dataSource scrollView:self sizeForContentView:contentView nearBy:nearByContentView fromPosition:position];
    }
    
    return contentViewSize;
}


- (UIView *)insertContentViewNearBy:(UIView *)nearByContentView withPosition:(GZInfiniteScrollViewContentViewPosition)position{
    
    UIView *contentView;
    if ([_contentViewPool count]>0) {
        contentView = _contentViewPool[0];
        [_contentViewPool removeObjectAtIndex:0];
    }
    
    contentView = [self getContentViewFromDataSourceWithReuseContentView:contentView nearBy:nearByContentView withPosition:position];
    
    CGSize contentViewSize = [self getContentViewSizeFromDataSourceWithReuseContentView:contentView nearBy:nearByContentView withPosition:position];
    
    CGRect frame = [contentView frame];

    if (!CGSizeEqualToSize(frame.size, contentViewSize)) {
        frame.size = contentViewSize;
        contentView.frame = frame;
    }
    
    [self addSubview:contentView];
    return contentView;
}


- (CGFloat)placeNewViewOnTop:(CGFloat)topEdge{
    
    
    UIView *view = [self insertContentViewNearBy:_mutableVisibleContentViews[0] withPosition:GZInfiniteScrollViewContentViewPositionTop];
    
    CGFloat headerHeight = [self getHighForHeaderViewFromDataSourceWithContentView:view];
    topEdge -= headerHeight;
    
    // add rightmost label at the end of the array
    [_mutableVisibleContentViews insertObject:view atIndex:0];
    
    CGRect frame = [view frame];
    frame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frame))/2;
    frame.origin.y = topEdge - CGRectGetHeight(frame);
    [view setFrame:frame];
    
    return CGRectGetMinY(frame);
}

- (CGFloat) placeNewViewOnBottom:(CGFloat)bottomEdge
{
    
    UIView *view = [self insertContentViewNearBy:[_mutableVisibleContentViews lastObject] withPosition:GZInfiniteScrollViewContentViewPositionBottom];
    CGFloat headerHeight =  [self getHighForHeaderViewFromDataSourceWithContentView:view];
    bottomEdge += headerHeight;
    
    [_mutableVisibleContentViews addObject:view];
     // add leftmost label at the beginning of the array
    
    CGRect frame = [view frame];
    frame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frame))/2;
    frame.origin.y = bottomEdge;//[self bounds].size.height - frame.size.height;
    
    [view setFrame:frame];
    
    return CGRectGetMaxY(frame);
}

- (CGFloat) placeNewViewOnLeft:(CGFloat)leftEdge
{
    
    UIView *view = [self insertContentViewNearBy:_mutableVisibleContentViews[0] withPosition:GZInfiniteScrollViewContentViewPositionLeft];
    
    CGFloat headerHeight =  [self getHighForHeaderViewFromDataSourceWithContentView:view];
    leftEdge -= headerHeight;
    
    [_mutableVisibleContentViews insertObject:view atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [view frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))/2;
    
    [view setFrame:frame];
    
    return CGRectGetMinX(frame);
}


- (CGFloat)placeNewViewOnRight:(CGFloat)rightEdge
{
    
    
    
    UIView *view = [self insertContentViewNearBy:[_mutableVisibleContentViews lastObject] withPosition:GZInfiniteScrollViewContentViewPositionRight];
    [_mutableVisibleContentViews addObject:view]; // add rightmost label at the end of the array
    
    CGFloat headerHeight =  [self getHighForHeaderViewFromDataSourceWithContentView:view];
    rightEdge += headerHeight;
    
//    UIView *headerView = [self getHeaderViewfromDataSourceWithHeight:headerHeight forContentView:view];
//    CGRect headerFrame = [headerView frame];
//    headerFrame.origin.x = rightEdge;
//    headerFrame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(headerFrame))/2;
    
//    rightEdge = CGRectGetMaxX([headerView frame]);
    
    CGRect frame = [view frame];
    frame.origin.x = rightEdge;
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame))/2;
    [view setFrame:frame];
    
    
    
    return CGRectGetMaxX(frame);
}


- (void)placeContentViewsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{
    
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([_mutableVisibleContentViews count] == 0)
    {
        [self placeNewViewOnRight:minimumVisibleX+_visibleExtension];
    }
    
    // add labels that are missing on right side
    UILabel *lastLabel = [_mutableVisibleContentViews lastObject];
    CGFloat rightEdge = CGRectGetMaxX([lastLabel frame]);
    while (rightEdge < maximumVisibleX)
    {
        rightEdge = [self placeNewViewOnRight:rightEdge];
    }
    
    // add labels that are missing on left side
    UILabel *firstLabel = _mutableVisibleContentViews[0];
    CGFloat leftEdge = CGRectGetMinX([firstLabel frame]);
    while (leftEdge > minimumVisibleX)
    {
        leftEdge = [self placeNewViewOnLeft:leftEdge];
    }
    
    CGFloat removeOffset = CGRectGetWidth(self.bounds)*8;
    
    // remove labels that have fallen off right edge
    lastLabel = [_mutableVisibleContentViews lastObject];
    while ([lastLabel frame].origin.x > maximumVisibleX-removeOffset)
    {
        [lastLabel removeFromSuperview];
        [_mutableVisibleContentViews removeLastObject];
        lastLabel = [_mutableVisibleContentViews lastObject];
    }
    
    // remove labels that have fallen off left edge
    firstLabel = _mutableVisibleContentViews[0];
    while (CGRectGetMaxX([firstLabel frame]) < minimumVisibleX+removeOffset)
    {
        [firstLabel removeFromSuperview];
        [_mutableVisibleContentViews removeObjectAtIndex:0];
        firstLabel = _mutableVisibleContentViews[0];
    }
}


- (void)placeContentViewsFromMinY:(CGFloat)minimumVisibleY toMaxY:(CGFloat)maximumVisibleY{
    
    
    
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([_mutableVisibleContentViews count] == 0)
    {
        [self placeNewViewOnBottom:minimumVisibleY+_visibleExtension];
    }
//    
//    // add labels that are missing on right side
    UIView *lastContentView = [_mutableVisibleContentViews lastObject];
    CGFloat bottomEdge = CGRectGetMaxY([lastContentView frame]);
    while (bottomEdge <= maximumVisibleY)
    {
        bottomEdge = [self placeNewViewOnBottom:bottomEdge];
    }

    // add labels that are missing on left side
    UILabel *firstLabel = _mutableVisibleContentViews[0];
    CGFloat topEdge = CGRectGetMinY([firstLabel frame]);
    while (topEdge >= minimumVisibleY)
    {
        topEdge = [self placeNewViewOnTop:topEdge];
    }
    
    CGFloat removeOffset = 0;//CGRectGetHeight(self.bounds)*3;
    
    // remove labels that have fallen off right edge
    UIView *willRemoveLastContentView = [_mutableVisibleContentViews lastObject];
    while ([willRemoveLastContentView frame].origin.y > maximumVisibleY+removeOffset)
    {
        
        [willRemoveLastContentView removeFromSuperview];
        [_mutableVisibleContentViews removeLastObject];
        [_contentViewPool addObject:willRemoveLastContentView];
        
        willRemoveLastContentView = [_mutableVisibleContentViews lastObject];
        
    }
    
    // remove labels that have fallen off left edge
    UIView *willRemoveFirstContentView = _mutableVisibleContentViews[0];
    while (CGRectGetMaxY([willRemoveFirstContentView frame]) < minimumVisibleY-removeOffset)
    {
        [willRemoveFirstContentView removeFromSuperview];
        [_mutableVisibleContentViews removeObjectAtIndex:0];
        [_contentViewPool addObject:willRemoveFirstContentView];
        willRemoveFirstContentView = _mutableVisibleContentViews[0];
        
    }
    
}


@end
