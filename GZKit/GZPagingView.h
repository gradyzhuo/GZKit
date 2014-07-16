//
//  GZInitePagingView.h
//  FlyingMan
//
//  Created by Zhuo Ting-Rui on 13/6/1.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum GZPagingDirection {
    GZPagingDirectionHorizon,
    GZPagingDirectionVertical,
} GZPagingDirection;


typedef enum GZPagingPosition {
    GZPagingPositionLeft,
    GZPagingPositionRight,
    GZPagingPositionTop,
    GZPagingPositionBottom,
} GZPagingPosition;

typedef enum GZPagingTransition {
    GZPagingTransitionCustom = 0,
    GZPagingTransitionCurl = 1,
    GZPagingTransitionSlide = 2,
    GZPagingTransitionFlip = 3
} GZPagingTransition;


@class GZPagingView;

extern NSString *GZPagingViewDidStopNotification;
extern NSString *GZPagingViewDidStopPageIndexKey;

@protocol GZPagingViewDatasource <NSObject>

- (NSUInteger) numberOfPageViewsInPagingView:(GZPagingView *)pagingView;
- (UIView *) pagingView:(GZPagingView *)pagingView contentViewWithIndex:(NSUInteger)index;

@end

@protocol GZPagingViewDelegate <NSObject, UIGestureRecognizerDelegate>

@optional
- (void)pagingViewWillBeginDragging:(GZPagingView *)pagingView;
- (void)pagingView:(GZPagingView *)pagingView didScrollToDirection:(GZPagingPosition)direction;
- (void)pagingViewDidEndDragging:(GZPagingView *)pagingView;
- (void)pagingView:(GZPagingView *)pagingView didStopAtPageIndex:(NSInteger)pageIndex;

- (BOOL) pagingView:(GZPagingView *)pagingView shouldPagingToPageIndex:(NSInteger)pageIndex;
- (void)pagingView:(GZPagingView *)pagingView willPagingToIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex;

#pragma mark - Animation Only
- (void)pagingViewWillStartAnimation:(GZPagingView *)pagingView;

@end


@interface GZPagingView : UIView<UIGestureRecognizerDelegate>


@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) NSArray *pageViews;

//Gesture Support, when transition is curl , gesture will disable.
@property (nonatomic) BOOL gestureEnable;
@property (nonatomic) BOOL infiniteEnable;


//Slide Animatation Property
@property (nonatomic) CGFloat minScale;
@property (nonatomic) CGFloat maxScale;

//Delegate
@property (nonatomic, weak) IBOutlet id<GZPagingViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<GZPagingViewDatasource> datasource;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

//Basic Info
@property (nonatomic, readonly) NSInteger pagesCount;
@property (nonatomic, readonly) NSInteger currentPageIndex;
@property (nonatomic, readonly) GZPagingPosition pagingPosition;

@property (nonatomic) CGPoint pagingOffset;

//Animation Support
@property (nonatomic) GZPagingTransition pagingTransition;

//Direction Support
@property (nonatomic) GZPagingDirection pagingDirection;

//PageView Getter
- (UIView *) currentPageView;
- (UIView *) nextPageView;
- (UIView *) previousPageView;

- (NSInteger) pageIndexOfView:(UIView *)pageView;
- (UIView *) pageViewOfIndex:(NSInteger)pageIndex;

- (void) addPageView:(UIView *)pageView;
- (void) removeAllPageView;

//Paging support
- (void) pagingToNextPage:(BOOL)animated;
- (void) pagingToPreviousPage:(BOOL)animated;
- (void) pagingToPageIndex:(NSInteger)index animated:(BOOL)animated;


- (void) reloadData;

@end
