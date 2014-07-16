//
//  FMGridSelectedView.h
//  FMKit
//
//  Created by 卓俊諺 on 2013/8/29.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GZGridView;
@interface GZGridSelectedView : UIView

@property (nonatomic, strong) GZGridView *gridView;

@property (nonatomic, readonly) NSArray *highlightedIndexPathes;
@property (nonatomic, readonly) NSArray *selectedIndexPathes;

- (void) addSelectedIndexPath:(NSIndexPath *)indexPath;
- (void) removeSelectedIndexPath:(NSIndexPath *)indexPath;
- (void) removeAllSelectedIndexPathes;

- (void) highlightCellsAtIndexPathes:(NSArray *)indexPathes;

- (void) reloadData;

@end
