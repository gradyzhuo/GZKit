//
//  FMGridSelectedView.m
//  FMKit
//
//  Created by 卓俊諺 on 2013/8/29.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import "GZGridSelectedView.h"
#import "GZGridView.h"

@interface GZGridSelectedView (){
    NSMutableArray *_selectedMutableIndexPathes;
}

@end

@implementation GZGridSelectedView
@synthesize selectedIndexPathes = _selectedMutableIndexPathes;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _selectedMutableIndexPathes = [@[] mutableCopy];
    }
    return self;
}

-(void)addSelectedIndexPath:(NSIndexPath *)indexPath{
    [_selectedMutableIndexPathes addObject:indexPath];
}

-(void)removeSelectedIndexPath:(NSIndexPath *)indexPath{
    [_selectedMutableIndexPathes removeObject:indexPath];
}


-(void)removeAllSelectedIndexPathes{
    [_selectedMutableIndexPathes removeAllObjects];
}


-(void)highlightCellsAtIndexPathes:(NSArray *)indexPathes{
    _highlightedIndexPathes = indexPathes;
    [self reloadData];
    
}

-(void)setGridView:(GZGridView *)gridView{
    [self willChangeValueForKey:@"gridView"];
    _gridView = gridView;
    [self didChangeValueForKey:@"gridView"];
    
    [_gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_gridView addObserver:self forKeyPath:@"hightlightedIndexPath" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

}

- (void) reloadData{
    
    if (_highlightedIndexPathes.count >0 || _selectedMutableIndexPathes.count > 0) {
        
        
        [self.gridView addSubview:self];
        [self setNeedsDisplay];
        [self.layer addAnimation:[CATransition animation] forKey:kCATransition];
    }else{
        [self removeFromSuperview];
    }
    
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    if (_selectedMutableIndexPathes.count > 0 && [_gridView.dataSource respondsToSelector:@selector(gridView:selectedCellContentInRect:atIndexPath:)]) {
        
        [_selectedMutableIndexPathes enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            if (![_highlightedIndexPathes containsObject:indexPath]) {
                CGRect cellRect = [_gridView frameForIndexPath:indexPath];
                [_gridView.dataSource gridView:_gridView selectedCellContentInRect:cellRect atIndexPath:indexPath];
            }
            
            
        }];
    }
    
    if (_highlightedIndexPathes != nil && [_gridView.dataSource respondsToSelector:@selector(gridView:highlightedCellContentInRect:atIndexPath:)]) {
        [_highlightedIndexPathes enumerateObjectsUsingBlock:^(NSIndexPath *highlightIndexPath, NSUInteger idx, BOOL *stop) {
            CGRect cellRect = [_gridView frameForIndexPath:highlightIndexPath];
            [_gridView.dataSource gridView:_gridView highlightedCellContentInRect:cellRect atIndexPath:highlightIndexPath];
        }];
    }
    
    
    CGContextRestoreGState(context);
    _highlightedIndexPathes = nil;
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"]) {
        CGRect newFrame = [change[@"new"] CGRectValue];

        self.frame = CGRectMake(0, 0, CGRectGetWidth(newFrame), CGRectGetHeight(newFrame));
    }
    
    if ([keyPath isEqualToString:@"hightlightedIndexPath"]) {
        [self reloadData];
    }
    
}

@end
