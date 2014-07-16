//
//  GZInitePagingView.m
//  FlyingMan
//
//  Created by Zhuo Ting-Rui on 13/6/1.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZPagingView.h"

NSString *GZPagingViewDidStopNotification = @"GZPagingViewDidStopNotification";
NSString *GZPagingViewDidStopPageIndexKey = @"GZPagingViewDidStopPageIndexKey";

struct IndexCircularDoubleLinkedList {
    NSInteger index;
    __unsafe_unretained UIView *pageView;
    struct IndexCircularDoubleLinkedList * nextIndexLink;
    struct IndexCircularDoubleLinkedList * previousIndexLink;
};

typedef struct IndexCircularDoubleLinkedList CDLLIndex;


CDLLIndex * createIndexItemLink(NSInteger index, __weak UIView *pagingView){
    CDLLIndex *newIndex = malloc(sizeof(CDLLIndex));
    newIndex->index = index;
    newIndex->pageView = pagingView;
    return newIndex;
}


void printIndexLinkedList(CDLLIndex *startIndexItem, CDLLIndex *currentIndexItem, BOOL infiniteEnable){
    CDLLIndex *indexItem = nil;
    if (infiniteEnable) {
        //支援無盡
        while (indexItem != startIndexItem) {
            if (indexItem == nil) {
                indexItem = startIndexItem;
            }
            
            printf("%d->",indexItem->index);
            
            indexItem = indexItem -> nextIndexLink;
        }
        
    }else{
        //不支援無盡
        indexItem = startIndexItem;
        
        while (indexItem != nil) {
            
            printf("%d->",indexItem->index);
            
            indexItem = indexItem -> nextIndexLink;
        }
        
    }
    printf("\n");
}

void clearIndexLinkedList(CDLLIndex *startIndexItem, CDLLIndex *currentIndexItem, BOOL infiniteEnable){
    
    printf("clearIndexLinkedList\n");
    
    CDLLIndex *indexItem = NULL;
    CDLLIndex *willFreeIndexItem = NULL;
    if (infiniteEnable) {
        //支援無盡
        while (indexItem != startIndexItem) {
            if (indexItem == nil) {
                indexItem = startIndexItem;
            }
            
            
            willFreeIndexItem = indexItem;
            indexItem = indexItem -> nextIndexLink;
            
            willFreeIndexItem->nextIndexLink->previousIndexLink = NULL;
            willFreeIndexItem->nextIndexLink = NULL;
            willFreeIndexItem->previousIndexLink = NULL;
            free(willFreeIndexItem);
        }
        
    }else{
        //不支援無盡
        indexItem = startIndexItem;
        
        while (indexItem != nil) {
            
            willFreeIndexItem = indexItem;
            
            indexItem = indexItem -> nextIndexLink;
            
//            willFreeIndexItem->nextIndexLink->previousIndexLink = NULL;
            willFreeIndexItem->nextIndexLink = NULL;
            willFreeIndexItem->previousIndexLink = NULL;
            free(willFreeIndexItem);
            
        }
        
    }
    
}


@interface GZPagingView (){
    CGPoint _gestureTotalOffset;
    NSMutableArray *_locations;
    BOOL _lock;
    
    CGPoint _lastDistanceOffset;
    CGPoint _endVelocity;
    CGPoint _startVelocity;
    
    UITapGestureRecognizer *_tapGesture;
    
    CGFloat _kValue;
    
    CDLLIndex *_startIndexItem;
    CDLLIndex *_endIndexItem;
    CDLLIndex *_currentIndexItem;
    CDLLIndex *_centerIndexItem;
    CDLLIndex *_willPageToIndexItem;
    
    BOOL _isOdd;

    
    CGPoint _contentOffset;
    
    NSMutableArray *_mutablePageViews;

}

- (void) initialization;

- (void) layoutPageViews;

- (CGRect) frameForPageLocation:(NSInteger)location;

- (void) selectPageIndex:(NSInteger)pageIndex;

- (NSInteger) locationIndexFomPageIndex:(NSInteger)pageIndex;
//- (UIView *) pageViewForLocation:(NSInteger)location;
//- (void)viewDidTapGesture:(UITapGestureRecognizer *)gestureRecognizer;

- (NSInteger) pageIndexFromLocation:(NSInteger)location;

- (CDLLIndex *) indexItemFromLocation:(NSInteger)location;

- (void) viewDidPanGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (void) transitionToPageLocation:(NSInteger)toLocation animated:(BOOL)animated;
- (void) animationDidComplete:(NSInteger)locationOffset animated:(BOOL)animated;


@end

@implementation GZPagingView
@synthesize pageViews = _mutablePageViews;

#pragma mark - View's initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initialization];
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}


- (void) initialization{
    
    _pagesCount = 0;
    
    _maxScale = 1.0f;
    _minScale = 0.5f;
    
    _infiniteEnable = NO;
    _isOdd = NO;
    
    _contentOffset = CGPointZero;
    
    //CDLLIndex
    _startIndexItem = nil;
    _endIndexItem = nil;
    _currentIndexItem = nil;
    _centerIndexItem = nil;
    
    
    _gestureEnable = YES;
    _lastDistanceOffset = CGPointZero;
    _endVelocity = CGPointZero;
    _startVelocity = CGPointZero;
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentView];

    
    _willPageToIndexItem = NULL;
    
    self.pagingOffset = CGPointZero;
//    _pagingOffset = CGPointZero;
    
    _locations = [NSMutableArray array];
    
    _pagingTransition = GZPagingTransitionSlide;
    
//    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapGesture:)];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPanGesture:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
//    [self addGestureRecognizer:_tapGesture];
    _mutablePageViews = [NSMutableArray array];
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
//    self.clipsToBounds = YES;
    
    
    [self reloadData];
    
    [self addObserver:self forKeyPath:@"infiniteEnable" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"pagingTransition" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"pagingDirection" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"gestureEnable" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc{
    
    
    [self removeObserver:self forKeyPath:@"infiniteEnable"];
    [self removeObserver:self forKeyPath:@"frame"];
    [self removeObserver:self forKeyPath:@"pagingTransition"];
    [self removeObserver:self forKeyPath:@"pagingDirection"];
    [self removeObserver:self forKeyPath:@"gestureEnable"];

    clearIndexLinkedList(_startIndexItem, _currentIndexItem, _infiniteEnable);
    
    
}

#pragma mark - Layout

- (void)setDelegate:(id<GZPagingViewDelegate>)delegate{
    _delegate = delegate;
//    _panGestureRecognizer.delegate = delegate;
}

- (void)setDatasource:(id<GZPagingViewDatasource>)datasource{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData{
    
    [self removeAllPageView];
    
    
    NSUInteger numberOfPageViews = [self.datasource respondsToSelector:@selector(numberOfPageViewsInPagingView:)]?[self.datasource numberOfPageViewsInPagingView:self]:1;
    if (numberOfPageViews > 0) {
        for (NSUInteger i=0; i<numberOfPageViews; i++) {
            if ([self.datasource respondsToSelector:@selector(pagingView:contentViewWithIndex:)]) {
                UIView *contentView = [self.datasource pagingView:self contentViewWithIndex:i];
                [self addPageView:contentView];
            }
            
        }
    }
    [self layoutPageViews];
    _currentPageIndex = [self pageIndexFromLocation:0];
}

- (void)layoutSubviews{
    
//    self.gestureEnable = NO;
    
    [self sendSubviewToBack:_contentView];
    _contentView.frame = self.bounds;
    [self layoutPageViews];
    
    [super layoutSubviews];
}

- (void)layoutPageViews{
    
    NSInteger centerLocationOffset = (NSInteger)[_mutablePageViews count]/2;
    NSInteger i = 0;
    CDLLIndex *indexItem = nil;

    if (_infiniteEnable) {
        //支援無盡
        while (indexItem != _startIndexItem) {
            if (indexItem == nil) {
                indexItem = _startIndexItem;
            }
            
            NSInteger location = i - centerLocationOffset;
            UIView *pageView = indexItem->pageView;
            
            CGRect frame = [self frameForPageLocation:location];
            pageView.frame = frame;
            
            indexItem = indexItem -> nextIndexLink;
            i++;
        }
        
    }else{
        //不支援無盡
        indexItem = _startIndexItem;
        
        while (indexItem != nil) {
            NSInteger location = i-_currentIndexItem->index;
            UIView *pageView = indexItem->pageView;
            CGRect frame = [self frameForPageLocation:location];
            pageView.frame = frame;
            
            indexItem = indexItem -> nextIndexLink;
            i++;
        }
        
    }
    
    
    
//    
//    [self pageViewForLocation:0].transform = CGAffineTransformMakeScale(1, _maxScale);
//    [self pageViewForLocation:-1].transform = CGAffineTransformMakeScale(1, _minScale);
//    [self pageViewForLocation:1].transform = CGAffineTransformMakeScale(1, _minScale);
    
}


#pragma mark - PagingView Operate Method

- (NSInteger)pageIndexOfView:(UIView *)pageView{
    NSInteger pageIndex = NSNotFound;
    if ([_mutablePageViews containsObject:pageView]) {
        pageIndex = [_mutablePageViews indexOfObject:pageView];
    }
    return pageIndex;
}

-(UIView *)pageViewOfIndex:(NSInteger)pageIndex{
    
//    UIView *view = nil;
//    if (pageIndex < _mutablePageViews.count && pageIndex >= 0) {
//        view = _mutablePageViews[pageIndex];
//    }
//    
//    
//    
//    return view;
    return [self pageViewForLocation:[self locationIndexFomPageIndex:pageIndex]];
}

- (NSInteger)pageIndexFromLocation:(NSInteger)location{
    return [self pageIndexOfView:[self pageViewForLocation:location]];
}

- (void)addPageView:(UIView *)pageView{
    
    _isOdd = !_isOdd;
    
    CDLLIndex *newIndexItem = createIndexItemLink([_mutablePageViews count], pageView);
    newIndexItem->previousIndexLink = nil;
    newIndexItem->nextIndexLink = nil;
    
    if (_startIndexItem == nil) {
        
        if (_infiniteEnable) {
            
            _startIndexItem = newIndexItem;
            _endIndexItem = newIndexItem;
            _startIndexItem->previousIndexLink = _endIndexItem;
            _endIndexItem->nextIndexLink = _startIndexItem;
            _currentIndexItem = newIndexItem;
            _centerIndexItem = newIndexItem;
            
        }else{
            _startIndexItem = newIndexItem;
            _endIndexItem = newIndexItem;
            _currentIndexItem = newIndexItem;
            _centerIndexItem = newIndexItem;
        }
        
        
    }else{
        if (_infiniteEnable) {
            //支援無盡
            newIndexItem->nextIndexLink = _startIndexItem;
            newIndexItem->previousIndexLink = _endIndexItem;
            _startIndexItem->previousIndexLink = newIndexItem;
            _endIndexItem->nextIndexLink = newIndexItem;
            _endIndexItem = newIndexItem;
            //如果目前的數量是偶數，centerIndex會往下一個走。
            if (!_isOdd) {
                _centerIndexItem = _centerIndexItem->nextIndexLink;
                _currentIndexItem = _centerIndexItem;
            }
        }else{
            //不支援無盡
            newIndexItem->previousIndexLink = _endIndexItem;
            _endIndexItem->nextIndexLink = newIndexItem;
            _endIndexItem = newIndexItem;
        }
    }
    _pagesCount ++;
    [_mutablePageViews addObject:pageView];
    [_contentView addSubview:pageView];
    
}

- (UIView *)nextPageView{
    
    UIView *pageView = nil;
    
    if (_currentIndexItem != NULL && _currentIndexItem->nextIndexLink != NULL) {
        pageView = _currentIndexItem->nextIndexLink->pageView;
    }
    return pageView;
}

- (UIView *)previousPageView{
    
    UIView *pageView = nil;
    
    if (_currentIndexItem != NULL && _currentIndexItem->previousIndexLink != NULL) {
        pageView = _currentIndexItem->previousIndexLink->pageView;
    }
    
    return pageView;
}


- (void)removeAllPageView{
    
    _startIndexItem = nil;
    _endIndexItem = nil;
    _currentIndexItem = nil;
    _centerIndexItem = nil;
    
    [_mutablePageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _pagesCount = 0;
    
    [_mutablePageViews removeAllObjects];
    
}

- (void)pagingToPageIndex:(NSInteger)index animated:(BOOL)animated{
    _lastDistanceOffset = CGPointZero;
    
    NSInteger location = [self locationIndexFomPageIndex:index];
    [self transitionToPageLocation:location animated:animated];
}

- (void)pagingToNextPage:(BOOL)animated{
    if ([self nextPageView]) {
        [self transitionToPageLocation:1 animated:animated];
    }
    
    
}

- (void)pagingToPreviousPage:(BOOL)animated{
    if ([self previousPageView]) {
        [self transitionToPageLocation:-1 animated:animated];
    }
}


#pragma mark - Gesture Selector
//
//-(void)viewDidTapGesture:(UITapGestureRecognizer *)gestureRecognizer{
//    
//    if ([_delegate respondsToSelector:@selector(pagingView:shouldSelectAtPageIndex:)]) {
//        
//        if ([_delegate pagingView:self shouldSelectAtPageIndex:_currentPageIndex]) {
//            
//            if ([_delegate respondsToSelector:@selector(pagingView:willSelectAtPageIndex:)]) {
//                
//                [_delegate pagingView:self willSelectAtPageIndex:_currentPageIndex];
//                
//            }
//            
//            [self selectPageIndex:_currentPageIndex];
//            
//            if ([_delegate respondsToSelector:@selector(pagingView:didSelectAtPageIndex:)]) {
//                
//                [_delegate pagingView:self didSelectAtPageIndex:_currentPageIndex];
//                
//            }
//            
//        }
//        
//    }else{
//        [self selectPageIndex:_currentPageIndex];
//    }
//    
//    
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
    
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    
    
    NSLog(@"velocity:%@,touch:%@",NSStringFromCGPoint(velocity),touch);
    
    return YES;//fabs(self.pagingOffset.y) < 10 && fabs(velocity.x) > fabs(velocity.y);
}

- (void)viewDidPanGesture:(UIPanGestureRecognizer *)gestureRecognizer{
    
    if (_pagingTransition == GZPagingTransitionCurl || self.pageViews.count == 0) {
        return ;
    }
    
    static CGPoint startPoint;
    CGPoint translation = [gestureRecognizer translationInView:self];

    
    
    CGPoint offset = CGPointZero;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        if ([_delegate respondsToSelector:@selector(pagingViewWillBeginDragging:)]) {
            [_delegate pagingViewWillBeginDragging:self];
        }
        
        _gestureTotalOffset = CGPointZero;
        
        //開始速度
        _startVelocity = [gestureRecognizer velocityInView:self];
        _endVelocity = _startVelocity;
        
        startPoint = [gestureRecognizer locationOfTouch:0 inView:self];
        //移動的Offset設定
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocity = [gestureRecognizer velocityInView:self];
        

        //分辦滑動方向
        if(velocity.x>0 && _pagingDirection == GZPagingDirectionHorizon) {
            _pagingPosition = GZPagingPositionRight;
        }
        else if (velocity.y > 0 && _pagingDirection == GZPagingDirectionVertical) {
            _pagingPosition = GZPagingPositionBottom;
        }
        else if(velocity.x < 0 && _pagingDirection == GZPagingDirectionHorizon){
            _pagingPosition = GZPagingPositionLeft;
        }
        else if (velocity.y < 0 && _pagingDirection == GZPagingDirectionVertical){
            _pagingPosition = GZPagingPositionTop;
        }
        
        
        
        _startVelocity  = _endVelocity;
        //結束速度
        _endVelocity = velocity;
        
        
        CGPoint tempPoint = [gestureRecognizer locationOfTouch:0 inView:self];
        
        if (_pagingDirection == GZPagingDirectionHorizon) {
            
//            if (fabs(velocity.x) > fabs(velocity.y)) {
//                
//            }
            CGFloat distance = tempPoint.x-startPoint.x;
            
            CGFloat width = CGRectGetWidth(self.frame);
            //TODO: 這裡要確認
            //            width = _pagingOffset.width ==0 ? width : _pagingOffset.width;
            
            CGFloat K = _gestureTotalOffset.x/width;
            
            _kValue = K;
            
            //增加拉動時的阻力
            if (distance > 0 ) distance = distance - (distance * K);
            else               distance = distance + (distance * K);
            
            offset = CGPointMake(distance, 0);
            
            
        }else if (_pagingDirection == GZPagingDirectionVertical){
            
//            if (fabs(velocity.y) > fabs(velocity.x)) {
//                
//            }
            CGFloat distance = tempPoint.y - startPoint.y;
            
            CGFloat height = CGRectGetHeight(self.frame);
            //            height = _pagingOffset.height == 0 ? height : _pagingOffset.height;
            
            CGFloat K = _gestureTotalOffset.y/height;
            _kValue = K;
            
            //增加拉動時的阻力
            if (distance > 0 ) distance = distance - (distance * K);
            else               distance = distance + (distance * K);
            
            offset = CGPointMake(0, distance);
        }
        
        
        
        _lastDistanceOffset = translation;
        
        _gestureTotalOffset.x += offset.x;
        _gestureTotalOffset.y += offset.y;
        
//        _pagingOffset = _gestureTotalOffset;
        
        [_mutablePageViews enumerateObjectsUsingBlock:^(__weak UIView *pageView, NSUInteger idx, BOOL *stop) {
            
            pageView.frame = CGRectOffset(pageView.frame, offset.x, offset.y);
            
        }];
        
        if ([_delegate respondsToSelector:@selector(pagingView:didScrollToDirection:)]) {
            [_delegate pagingView:self didScrollToDirection:_pagingPosition];
        }
        
        startPoint = tempPoint;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        
        CGPoint velocity = [gestureRecognizer velocityInView:self];
        
        if (_pagingDirection == GZPagingDirectionVertical) {
            
            if (_gestureTotalOffset.y <0 && (fabs(_gestureTotalOffset.y) > CGRectGetHeight(self.frame)*.4f || fabs(velocity.y) > 500.f) && _currentIndexItem->nextIndexLink != nil ) {
                [self pagingToNextPage:YES];
            }else if (_gestureTotalOffset.y >0 && (fabs(_gestureTotalOffset.y) > CGRectGetHeight(self.frame)*.4f || fabs(velocity.y) > 500.f) && _currentIndexItem->previousIndexLink != nil){
                [self pagingToPreviousPage:YES];
            }else{
                
                [self transitionToPageLocation:0 animated:YES];
            }
        }else{
            
            if (_gestureTotalOffset.x <0 && (fabs(_gestureTotalOffset.x) > CGRectGetWidth(self.frame)*.4f || fabs(velocity.x) > 500.f ) && _currentIndexItem->nextIndexLink != nil ) {
                [self pagingToNextPage:YES];
            }else if (_gestureTotalOffset.x >0 && (fabs(_gestureTotalOffset.x) > CGRectGetWidth(self.frame)*.4f || fabs(velocity.x) > 500.f ) && _currentIndexItem->previousIndexLink != nil){
                [self pagingToPreviousPage:YES];
            }else{
                [self transitionToPageLocation:0 animated:YES];
            }
        }
        
        if ([_delegate respondsToSelector:@selector(pagingViewDidEndDragging:)]) {
            [_delegate pagingViewDidEndDragging:self];
        }
        
    }
    
}

- (void)setPagingOffset:(CGPoint)pagingOffset{
    _gestureTotalOffset = pagingOffset;
    [self layoutPageViews];
}

-(CGPoint)pagingOffset{
    return _gestureTotalOffset;
}

#pragma mark - PagingView Private Method

- (CDLLIndex *)indexItemFromLocation:(NSInteger)location{
    CDLLIndex *indexItem = _currentIndexItem;
    
    if (indexItem == NULL) {
        return nil;
    }
    for (int i=0; i<abs(location); i++) {
        if (location>0 && indexItem->nextIndexLink != NULL) {
            indexItem = indexItem->nextIndexLink;
            
        }else if(location <0 && indexItem->previousIndexLink != NULL){
            indexItem = indexItem->previousIndexLink;
        }
        
        
        if (indexItem == NULL) {
            break;
        }
    }
    
    return indexItem;
}

- (UIView *) pageViewForLocation:(NSInteger)location{
    
    UIView *pageView = nil;
    
    CDLLIndex *indexItem = [self indexItemFromLocation:location];
    
    if (indexItem != NULL) {
        pageView = indexItem->pageView;
    }
    
    return pageView;
}

- (UIView *) currentPageView{
    UIView *pageView = nil;
    if (_currentIndexItem != NULL) {
        pageView = _currentIndexItem->pageView;
    }
    return pageView;
}

- (NSInteger)locationIndexFomPageIndex:(NSInteger)pageIndex{
    
    NSInteger i=0;
    NSInteger centerLocationOffset = (NSInteger)[_mutablePageViews count]/2;
    if (!_infiniteEnable) {
        CDLLIndex *indexItem = _startIndexItem;
        
        while (indexItem != nil) {
            NSInteger location = i-_currentIndexItem->index;
            if (i == pageIndex) {
                return location;
            }
            indexItem = indexItem -> nextIndexLink;
            i++;
        }
    }else{
        CDLLIndex *indexItem = nil;
        while (indexItem != _startIndexItem) {
            if (indexItem == nil) {
                indexItem = _startIndexItem;
            }
            
            NSInteger location = i - centerLocationOffset;
            if (indexItem->index == pageIndex) {
                return location;
            }
            indexItem = indexItem -> nextIndexLink;
            i++;
        }
    }
    
    return 0;
    
}

- (CGRect)frameForPageLocation:(NSInteger)location{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    if (_pagingDirection == GZPagingDirectionHorizon) {
        return CGRectOffset(self.bounds, width * location, 0);
    }else if(_pagingDirection == GZPagingDirectionVertical){
        return CGRectOffset(self.bounds, 0, height * location);
    }
    
    return CGRectZero;
}



- (void)animationDidComplete:(NSInteger)locationOffset animated:(BOOL)animated{
    
//    NSLog(@"locationOffset:%d",locationOffset);
    
//    NSInteger currentPageIndex;
    
//    NSLog(@"_willToPageIndex:%d",_willToPageIndex);
//    NSLog(@"_currentIndexItem->nextIndexLink->index:%d",_currentIndexItem->nextIndexLink->index);
//    NSLog(@"_currentIndexItem->previousIndexLink->index:%d",_currentIndexItem->previousIndexLink->index);

    
    
    _currentPageIndex = _currentIndexItem->index;
    
    if (_willPageToIndexItem->index != _currentPageIndex) {
        _lock = NO;
        [self pagingToPageIndex:_willPageToIndexItem->index animated:animated];
    }else{
        if (locationOffset != 0) {
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GZPagingViewDidStopNotification object:self userInfo:@{GZPagingViewDidStopPageIndexKey:@(_currentPageIndex)}];
            
            if ([_delegate respondsToSelector:@selector(pagingView:didStopAtPageIndex:)]) {
                [_delegate pagingView:self didStopAtPageIndex:_currentPageIndex];
            }
        }
    }
    
    
    
}


- (void) transitionToPageLocation:(NSInteger)toLocation animated:(BOOL)animated{
    
    _willPageToIndexItem = [self indexItemFromLocation:toLocation];
    
    if (!_lock) {
        
        NSInteger fromIndex = _currentIndexItem->index;
//        UIView *fromPage = _currentIndexItem->pageView;
        
        
        _lock = YES;

        //分辦滑動方向
        if(toLocation>0 && _pagingDirection == GZPagingDirectionHorizon) {
            _pagingPosition = GZPagingPositionRight;
        }
        else if (toLocation > 0 && _pagingDirection == GZPagingDirectionVertical) {
            _pagingPosition = GZPagingPositionBottom;
        }
        else if(toLocation < 0 && _pagingDirection == GZPagingDirectionHorizon){
            _pagingPosition = GZPagingPositionLeft;
        }
        else if (toLocation < 0 && _pagingDirection == GZPagingDirectionVertical){
            _pagingPosition = GZPagingPositionTop;
        }
        
        CFTimeInterval duration = 0.4;
        if (!CGPointEqualToPoint(_lastDistanceOffset, CGPointZero)) {
            if (_pagingDirection == GZPagingDirectionHorizon) {
                duration = 2.f * _lastDistanceOffset.x / (_endVelocity.x  + _startVelocity.x );
            }else{
                duration = 2.f * _lastDistanceOffset.y / (_endVelocity.y + _startVelocity.y);
            }
            duration = duration>0.7?0.7:duration;
            duration = duration<0.1?0.1:duration;
        }
        
        duration = animated?duration:0;
        
        BOOL shouldPaging = [_delegate respondsToSelector:@selector(pagingView:shouldPagingToPageIndex:)]?[_delegate pagingView:self shouldPagingToPageIndex:[self pageIndexFromLocation:toLocation]]:YES;
        
        if (shouldPaging) {
            for (NSInteger i=0; i<abs(toLocation); i++) {
                if (toLocation>0 && _currentIndexItem->nextIndexLink != nil) {
                    _currentIndexItem = _currentIndexItem->nextIndexLink;
                    [_currentIndexItem->pageView.layer removeAllAnimations];
                    if (_infiniteEnable) {
                        _startIndexItem = _startIndexItem->nextIndexLink;
                        _endIndexItem = _endIndexItem->nextIndexLink;
                        _centerIndexItem = _centerIndexItem->nextIndexLink;
                        //因無盡模式，循環的View會出現frame大換位的狀況
                        //為使畫面穩定，所以設定為Hidden
                        _startIndexItem->previousIndexLink->pageView.alpha = 0;
                        
                    }
                    
                }else if(toLocation <0 && _currentIndexItem->previousIndexLink != nil){
                    _currentIndexItem = _currentIndexItem->previousIndexLink;
                    [_currentIndexItem->pageView.layer removeAllAnimations];
                    if (_infiniteEnable) {
                        _startIndexItem = _startIndexItem->previousIndexLink;
                        _endIndexItem = _endIndexItem->previousIndexLink;
                        _centerIndexItem = _centerIndexItem->previousIndexLink;
                        //因無盡模式，循環的View會出現frame大換位的狀況
                        //為使畫面穩定，所以設定為Hidden
                        _endIndexItem->nextIndexLink->pageView.alpha = 0;
                    }
                }
            }

        }
        
        if ([_delegate respondsToSelector:@selector(pagingViewWillStartAnimation:)]) {
            [_delegate pagingViewWillStartAnimation:self];
        }
        
        NSInteger toIndex = _currentIndexItem->index;
//        UIView *toPage = _currentIndexItem->pageView;
//
//        if ([_delegate respondsToSelector:@selector(pagingView:willPagingToPage:fromPage:)]) {
//            [_delegate pagingView:self willPagingToPage:fromPage fromPage:toPage];
//        }
        if ([_delegate respondsToSelector:@selector(pagingView:willPagingToIndex:fromIndex:)]) {
            [_delegate pagingView:self willPagingToIndex:toIndex fromIndex:fromIndex];
        }
        
        
        
        __weak id weakSelf = self;
        
        if (animated) {
            
            if (_pagingTransition == GZPagingTransitionCurl) {
                [self layoutPageViews];
                UIViewAnimationOptions animationOptions = toLocation>0?UIViewAnimationOptionTransitionCurlUp:UIViewAnimationOptionTransitionCurlDown;
                
                [UIView transitionWithView:self duration:duration options:animationOptions animations:^{
                    
                } completion:^(BOOL finished) {
                    if (_infiniteEnable) {
                        CDLLIndex *indexItem = nil;
                        while (indexItem != _startIndexItem) {
                            if (indexItem == nil) indexItem = _startIndexItem;
                            indexItem->pageView.alpha = 1;
                            indexItem = indexItem -> nextIndexLink;
                        }
                    }
                    
                    
                    [weakSelf animationDidComplete:toLocation animated:animated];
                    
                    _lock = NO;
                }];
            }
            else if (_pagingTransition == GZPagingTransitionFlip){
                [self layoutPageViews];
                
                UIViewAnimationOptions animationOptions;
                if (_pagingDirection == GZPagingDirectionHorizon) {
                    animationOptions = toLocation>0?UIViewAnimationOptionTransitionFlipFromLeft:UIViewAnimationOptionTransitionFlipFromRight;
                }else{
                    animationOptions = toLocation>0?UIViewAnimationOptionTransitionFlipFromBottom:UIViewAnimationOptionTransitionFlipFromTop;
                }
                
                
                
                
                [UIView transitionWithView:self duration:duration options:animationOptions animations:^{
                    
                } completion:^(BOOL finished) {
                    if (_infiniteEnable) {
                        CDLLIndex *indexItem = nil;
                        while (indexItem != _startIndexItem) {
                            if (indexItem == nil) indexItem = _startIndexItem;
                            indexItem->pageView.alpha = 1;
                            indexItem = indexItem -> nextIndexLink;
                        }
                    }
                    
                    
                    [weakSelf animationDidComplete:toLocation animated:animated];
                    
                    _lock = NO;
                }];
            }
            
            else if(_pagingTransition == GZPagingTransitionSlide){
                
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews animations:^{
                    
                    [weakSelf layoutPageViews];
                    
                    
                } completion:^(BOOL finished) {
                    
                    if (_infiniteEnable) {
                        CDLLIndex *indexItem = nil;
                        while (indexItem != _startIndexItem) {
                            if (indexItem == nil) indexItem = _startIndexItem;
                            indexItem->pageView.alpha = 1;
                            indexItem = indexItem -> nextIndexLink;
                        }
                    }
                    
                    
                    [weakSelf animationDidComplete:toLocation animated:animated];
                    
                    _lock = NO;
                    
                }];

            }
            
        }else{
            [self layoutPageViews];
            
            if (_infiniteEnable) {
                CDLLIndex *indexItem = nil;
                while (indexItem != _startIndexItem) {
                    if (indexItem == nil) indexItem = _startIndexItem;
                    indexItem->pageView.alpha = 1;
                    indexItem = indexItem -> nextIndexLink;
                }
            }
            
            
            [self animationDidComplete:toLocation animated:animated];
            
            _lock = NO;
        }
        
        _lastDistanceOffset = CGPointZero;
    }
    
}

#pragma mark - KVO Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"infiniteEnable"] && _startIndexItem!=nil && _endIndexItem != nil) {
        if ([change[@"new"] boolValue]) {
            
            _endIndexItem->nextIndexLink = _startIndexItem;
            _startIndexItem->previousIndexLink = _endIndexItem;

        }else{
            _endIndexItem->nextIndexLink = nil;
            _startIndexItem->previousIndexLink = nil;
        }
    }
    
    if ([keyPath isEqualToString:@"gestureEnable"]) {
        _panGestureRecognizer.enabled = [change[@"new"] boolValue] && (_pagingTransition != GZPagingTransitionCurl);
    }
    
    if ([keyPath isEqualToString:@"pagingDirection"]) {
        [self layoutPageViews];
    }
    
    if ([keyPath isEqualToString:@"pagingTransition"]) {
//        self.pagingTransition = [change[@"new"] integerValue];
    }
    
    if ([keyPath isEqualToString:@"frame"]) {
        [self layoutPageViews];
    }
    
//    
}

#pragma mark - UITouch


@end
