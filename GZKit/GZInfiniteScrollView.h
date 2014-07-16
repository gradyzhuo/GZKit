//
//  GZInfiniteScrollView.h
//  GZKit
//
//  Created by 卓俊諺 on 2013/10/7.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum GZInfiniteScrollViewContentViewPosition {
    GZInfiniteScrollViewContentViewPositionTop,
    GZInfiniteScrollViewContentViewPositionBottom,
    GZInfiniteScrollViewContentViewPositionLeft,
    GZInfiniteScrollViewContentViewPositionRight
} GZInfiniteScrollViewContentViewPosition;

@class GZInfiniteScrollView;

@protocol GZInfiniteScrollViewDataSource <NSObject>

//- (UIView *) scrollView:(GZInfiniteScrollView *)scrollView headerViewWithContentView:(UIView *)nearByContentView;
- (UIView *) scrollView:(GZInfiniteScrollView *)scrollView reuseContentView:(UIView *)contentView nearBy:(UIView *)nearByContentView fromPosition:(GZInfiniteScrollViewContentViewPosition)contentPosition;
- (CGSize) scrollView:(GZInfiniteScrollView *)scrollView sizeForContentView:(UIView *)contentView nearBy:(UIView *)nearByContentView fromPosition:(GZInfiniteScrollViewContentViewPosition)contentPosition;


@end

@protocol GZInfiniteScrollViewDelegate <NSObject,UIScrollViewDelegate>

@optional
- (CGFloat) scrollView:(GZInfiniteScrollView *)scrollView heightForheaderWithContentView:(UIView *)nearByContentView;

//- (void) scrollView:(GZInfiniteScrollView *)scrollView willDisplayContentView:(UIView *)contentView nearBy:(UIView *)nearByContentView fromPosition:(GZInfiniteScrollViewContentViewPosition)contentPosition;

@end

@interface GZInfiniteScrollView : UIScrollView{
    @package
    NSMutableArray *_mutableVisibleContentViews;
    NSMutableArray *_contentViewPool;
    CGFloat _divideSize;
}

@property (nonatomic, weak) IBOutlet id<GZInfiniteScrollViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<GZInfiniteScrollViewDelegate> delegate;

@property (nonatomic, readonly) NSArray *visibleContentViews;


- (void) setRecenterIfNeed;

- (UIView *)contentViewNearBy:(UIView *)nearByContent position:(GZInfiniteScrollViewContentViewPosition)position;

- (UIView *)visibleContentViewInLocation:(CGPoint)location;

- (void) reloadData;
- (void) resetData;

@end
