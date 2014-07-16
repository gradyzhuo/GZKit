//
//  FMGridView.h
//  FMKit
//
//  Created by Zhuo Ting-Rui on 13/6/17.
//  Copyright (c) 2013年 Grady Zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@protocol GZGridViewDelegate,GZGridViewDataSource;

@interface GZGridView : UIView{
@protected
    CGFloat _width;
    CGFloat _height;
    NSMutableArray *_sections;
    NSMutableArray *_indexPathes;
    NSMutableArray *_cells;
    NSMutableDictionary *_cellClasses;
}

@property (nonatomic, weak) IBOutlet id<GZGridViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<GZGridViewDelegate> delegate;

//@property (nonatomic, readonly) NSIndexPath *hightlightedIndexPath;
@property (nonatomic, readonly) NSArray *selectedIndexPathes;

@property (nonatomic) BOOL highlightCellWhenMoving;
@property (nonatomic) BOOL allowsMultipleSelection;

- (CGFloat) heightOfSection:(NSUInteger)section;

- (void) highlightCellAtIndexPath:(NSIndexPath *)indexPath;
- (void) highlightCellsAtIndexPathes:(NSArray *)indexPathes;
- (BOOL) selectCellAtIndexPath:(NSIndexPath *)indexPath;

//- (void) deHighlightCellWithIndexPathes:(NSArray *)indexPathes;
- (void) deHighlightCellAtIndexPath:(NSIndexPath *)indexPath;
- (void) deSelectCellAtIndexPath:(NSIndexPath *)indexPath;
- (void) deSelectCellAtIndexPathes:(NSArray *)indexPathes;

- (void) deselectCellWhenSelectedIndexPathExist;
- (void) reloadData;

@end


@interface GZGridView (FrameOperate)

- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *) indexPathFromLocation:(CGPoint)location;

@end

@protocol GZGridViewDelegate <NSObject>

@optional
//Select Event
- (BOOL)gridView:(GZGridView *)gridView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)gridView:(GZGridView *)gridView willDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)gridView:(GZGridView *)gridView willSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)gridView:(GZGridView *)gridView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)gridView:(GZGridView *)gridView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

//Highlight Event
- (BOOL)gridView:(GZGridView *)gridView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)gridView:(GZGridView *)gridView willDehighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)gridView:(GZGridView *)gridView willHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)gridView:(GZGridView *)gridView didDehighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)gridView:(GZGridView *)gridView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol GZGridViewDataSource <NSObject>

@required
- (NSInteger) numberOfSectionInGridView:(GZGridView *)gridView;
- (NSInteger) gridView:(GZGridView *)gridView numberOfRowsInSection:(NSInteger)section;
- (void) gridView:(GZGridView *)gridView cellContentInRect:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGFloat) gridView:(GZGridView *)gridView heightInSection:(NSInteger)section;
- (BOOL) gridView:(GZGridView *)gridView shouldShowCellInIndexPath:(NSIndexPath *)indexPath;
- (void) gridView:(GZGridView *)gridView selectedCellContentInRect:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath;
- (void) gridView:(GZGridView *)gridView highlightedCellContentInRect:(CGRect)rect atIndexPath:(NSIndexPath *)indexPath;

@end