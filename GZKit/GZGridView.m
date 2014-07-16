//
//  FMGridView.m
//  FMKit
//
//  Created by Zhuo Ting-Rui on 13/6/17.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZGridView.h"
#import "GZGridSelectedView.h"

@interface GZGridView ()<UIGestureRecognizerDelegate>{
    UIPanGestureRecognizer *_panGestureRecognizer;
    BOOL _isPartUpdate;
    GZGridSelectedView *_selectedView;
    NSUInteger _tapCount;
    CGPoint _beginLocation;
    CGFloat _cellWidth;
    CGFloat _cellHeight;
    BOOL _isLayouted;
    NSIndexPath *_hightlightedIndexPath;
    
    BOOL _needReload;
    
}

@end

@implementation GZGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setup];
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
        
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

- (void) setup{

    
    _highlightCellWhenMoving = NO;

    _tapCount = 1;
    
    _isLayouted = NO;
    _needReload = YES;
    
    _selectedView = [[GZGridSelectedView alloc] initWithFrame:self.bounds];
    _selectedView.gridView = self;
    _selectedView.userInteractionEnabled = NO;
    _selectedView.backgroundColor = [UIColor clearColor];

}

-(void)setDataSource:(id<GZGridViewDataSource>)dataSource{
    _dataSource = dataSource;
    [self reloadData];
}

-(CGSize)sizeOfItemAtIdexPath:(NSIndexPath *)indexPath{

    NSInteger rowsOfSection= [[_sections objectAtIndex:indexPath.section] integerValue];
    
    //row負責x, section負責y
    CGFloat defaultHeight = (_height / [_sections count]);
    
    _cellHeight = [_dataSource respondsToSelector:@selector(gridView:heightInSection:)]?([_dataSource gridView:self heightInSection:indexPath.section] != -1.f?[_dataSource gridView:self heightInSection:indexPath.section]:defaultHeight):(defaultHeight);
    _cellWidth = _width/rowsOfSection;
    
    return CGSizeMake(_cellWidth, _cellHeight);
}

- (CGFloat) heightOfSection:(NSUInteger)section{
    CGSize size = [self sizeOfItemAtIdexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return size.height;
}

- (void)setHighlightCellWhenMoving:(BOOL)selectCellWhenMove{
    _highlightCellWhenMoving = selectCellWhenMove;
    _panGestureRecognizer.enabled = selectCellWhenMove;
}

-(void)highlightCellsAtIndexPathes:(NSArray *)indexPathes{
    [_selectedView highlightCellsAtIndexPathes:indexPathes];
}

- (void)highlightCellAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *tempIndexPath = _hightlightedIndexPath;

    
    if (_indexPathes.count == 0) {
        _needReload = YES;
        [self prepareGridView];
    }
    if (![_indexPathes containsObject:indexPath]||!indexPath) {
        [_selectedView highlightCellsAtIndexPathes:nil];
        return;
    }
    
    BOOL shouldHighlight = [self.delegate respondsToSelector:@selector(gridView:shouldHighlightItemAtIndexPath:)]?[self.delegate gridView:self shouldHighlightItemAtIndexPath:indexPath]:YES;
    
    if (shouldHighlight){
        
        if (_hightlightedIndexPath && [self.delegate respondsToSelector:@selector(gridView:willDehighlightItemAtIndexPath:)]) {
            
            [self.delegate gridView:self willDehighlightItemAtIndexPath:_hightlightedIndexPath];
            
        }
        
        if ([self.delegate respondsToSelector:@selector(gridView:willHighlightItemAtIndexPath:)]) {
            
            [self.delegate gridView:self willHighlightItemAtIndexPath:indexPath];
            
        }

        
        [_selectedView highlightCellsAtIndexPathes:@[indexPath]];
        
        if (tempIndexPath && [self.delegate respondsToSelector:@selector(gridView:didDehighlightItemAtIndexPath:)]) {
            
            [self.delegate gridView:self didDehighlightItemAtIndexPath:tempIndexPath];
            
        }
        
        if ([self.delegate respondsToSelector:@selector(gridView:didHighlightItemAtIndexPath:)]) {
            
            [self.delegate gridView:self didHighlightItemAtIndexPath:indexPath];
            
        }
    }
    
}


-(void)deSelectCellAtIndexPath:(NSIndexPath *)indexPath{

    [_selectedView removeSelectedIndexPath:indexPath];
    [_selectedView reloadData];

}

-(void)deSelectCellAtIndexPathes:(NSArray *)indexPathes{
    
    [indexPathes enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [_selectedView removeSelectedIndexPath:indexPath];
    }];
    
    [_selectedView reloadData];
    
}

-(void)deHighlightCellAtIndexPath:(NSIndexPath *)indexPath{
    [self willChangeValueForKey:@"hightlightedIndexPath"];
    _hightlightedIndexPath = nil;
    [self didChangeValueForKey:@"hightlightedIndexPath"];
}


- (void)deselectCellWhenSelectedIndexPathExist{

    [_selectedView removeAllSelectedIndexPathes];
    [_selectedView reloadData];
}

//-(void)selectCellAtIndexPath:(NSIndexPath *)indexPath{
//    [self selectCellAtIndexPath:indexPath withTapCount:_tapCount];
//}

-(NSArray *)selectedIndexPathes{
    return _selectedView.selectedIndexPathes;
}

-(BOOL)selectCellAtIndexPath:(NSIndexPath *)indexPath usingDelegate:(BOOL)usingDelegate{
    if (_indexPathes.count == 0) {
        _needReload = YES;
        [self prepareGridView];
    }
    
    if (![_indexPathes containsObject:indexPath]) {
        return NO;
    }
    
    [self willChangeValueForKey:@"hightlightedIndexPath"];
    //    _hightlightedIndexPath = nil;
    [self highlightCellAtIndexPath:nil];
    [self didChangeValueForKey:@"hightlightedIndexPath"];
    
    BOOL shouldSelect = [self.delegate respondsToSelector:@selector(gridView:shouldSelectItemAtIndexPath:)]?[self.delegate gridView:self shouldSelectItemAtIndexPath:indexPath]:YES;
    
    if (shouldSelect) {
        
        if (usingDelegate && [self.delegate respondsToSelector:@selector(gridView:willSelectItemAtIndexPath:)]) {
            
            [self.delegate gridView:self willSelectItemAtIndexPath:indexPath];
            
        }
        
        if (!_allowsMultipleSelection) {
            __weak GZGridView *weakSelf = self;
            
            [[_selectedView.selectedIndexPathes copy] enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                if (usingDelegate && [weakSelf.delegate respondsToSelector:@selector(gridView:willDeselectItemAtIndexPath:)]) {
                    [weakSelf.delegate gridView:self willDeselectItemAtIndexPath:indexPath];
                }
            }];
            [_selectedView removeAllSelectedIndexPathes];
            
            if (usingDelegate && [self.delegate respondsToSelector:@selector(gridView:didDeselectItemAtIndexPath:)]) {
                [self.delegate gridView:self didDeselectItemAtIndexPath:indexPath];
            }
        }
        
        //確認IndexPath正確才加入
        if (indexPath) {
            [_selectedView addSelectedIndexPath:indexPath];
        }
        [_selectedView reloadData];
        
        
        if (usingDelegate && [self.delegate respondsToSelector:@selector(gridView:didSelectItemAtIndexPath:)]) {
            [self.delegate gridView:self didSelectItemAtIndexPath:indexPath];
            
        }
        
    }
    return YES;
}

-(BOOL)selectCellAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self selectCellAtIndexPath:indexPath usingDelegate:NO];
    
}

-(void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    if (!allowsMultipleSelection) {
        [_selectedView removeAllSelectedIndexPathes];
    }
    
    [_selectedView reloadData];
    
}

- (void) viewDidTapped:(UITouch *)touch event:(UIEvent *)event{
    
    CGPoint location = [touch locationInView:self];
    NSIndexPath *willSelectIndexPath = [self indexPathFromLocation:location];

//    _tapCount = [touch tapCount];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self selectCellAtIndexPath:willSelectIndexPath usingDelegate:YES];
    
//    [self performSelector:@selector(selectCellAtIndexPath:) withObject:willSelectIndexPath afterDelay:0.1];
    
}



-(void)setFrame:(CGRect)frame{
    
    _width = CGRectGetWidth(frame);
    _height = CGRectGetHeight(frame);
    
    BOOL needRelayout = !CGSizeEqualToSize(self.frame.size, frame.size);
    
    
    [super setFrame:frame];
    if (needRelayout) {
        _selectedView.frame = self.bounds;
    }
    
}



- (void) reloadData{
    _needReload = YES;
    [self prepareGridView];
    [self setNeedsDisplay];

}


- (void)prepareGridView{
    
    if (!_needReload || self.dataSource == nil) {
        return;
    }
    
    NSAssert([self.dataSource respondsToSelector:@selector(gridView:numberOfRowsInSection:)], @"gridView:numberOfRowsInSection:");
    
    [_sections removeAllObjects];
    [_indexPathes removeAllObjects];
    
    _sections = nil;
    _indexPathes = nil;
    
    _sections = [@[] mutableCopy];
    _indexPathes = [@[] mutableCopy];

    NSInteger sections = [_dataSource respondsToSelector:@selector(numberOfSectionInGridView:)]?[_dataSource numberOfSectionInGridView:self]:1;
    
    for (NSInteger section=0; section<sections; section++) {
        
        NSInteger rows = [_dataSource gridView:self numberOfRowsInSection:section];
        [_sections addObject:@(rows)];
        
        for (NSInteger row = 0; row<rows; row++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            BOOL shouldShow = [_dataSource respondsToSelector:@selector(gridView:shouldShowCellInIndexPath:)]?[_dataSource gridView:self shouldShowCellInIndexPath:indexPath]:YES;
            
            if (shouldShow) {
                [_indexPathes addObject:indexPath];
            }
            
        }
        
    }
    
    _needReload = NO;
    
}

- (void)drawGridView{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (NSIndexPath *indexPath in _indexPathes) {
        CGContextSaveGState(context);
        CGRect frame = [self frameForIndexPath:indexPath];
        if ([self.dataSource respondsToSelector:@selector(gridView:cellContentInRect:atIndexPath:)]) {
            [self.dataSource gridView:self cellContentInRect:frame atIndexPath:indexPath];
        }
        CGContextRestoreGState(context);
    }
    
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self drawGridView];
}


- (void)dealloc{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRelease(context);
    
}



@end



@implementation GZGridView (FrameOperate)

- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath{
    
    [self sizeOfItemAtIdexPath:indexPath];
    
    CGFloat y = indexPath.section * _cellHeight;
    CGFloat x = indexPath.row * _cellWidth;
    
    return CGRectMake(x, y, _cellWidth, _cellHeight);
}

- (NSIndexPath *) indexPathFromLocation:(CGPoint)location{
    
    NSInteger row = location.x / _cellWidth;
    NSInteger section = location.y / _cellHeight;
    
    NSIndexPath *indexPath = nil;
    if (section < _sections.count && row < [_sections[section] integerValue]) {
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    }
    
    return indexPath;

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch.view convertPoint:[touch locationInView:touch.view] toView:self];
    
    [self highlightCellAtIndexPath:[self indexPathFromLocation:point]];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (_highlightCellWhenMoving) {
        [self highlightCellAtIndexPath:[self indexPathFromLocation:[touch locationInView:self]]];
    }
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    
    NSIndexPath *currentIndexPath = [self indexPathFromLocation:[touch locationInView:self]];
    NSIndexPath *previousIndexPath = [self indexPathFromLocation:[touch previousLocationInView:self]];

    BOOL isSameLocation = [currentIndexPath isEqual:previousIndexPath];
    if (isSameLocation) {
        [self viewDidTapped:touch event:event];
    }else{
        [self highlightCellAtIndexPath:nil];
    }
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self highlightCellAtIndexPath:nil];
    [super touchesCancelled:touches withEvent:event];
}




@end
