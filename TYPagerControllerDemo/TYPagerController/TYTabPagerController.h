//
//  TYTabPagerController.h
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/5/3.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYPagerController.h"

@class TYTabPagerController;

@protocol TYTabPagerControllerDelegate <TYPagerControllerDelegate>

- (void)pagerController:(TYTabPagerController *)pagerController configreCell:(UICollectionViewCell *)cell forItemTitle:(NSString *)title atIndexPath:(NSIndexPath *)indexPath;

- (void)pagerController:(TYTabPagerController *)pagerController transitionFromeCell:(UICollectionViewCell *)fromCell toCell:(UICollectionViewCell *)toCell animated:(BOOL)animated;

- (void)pagerController:(TYTabPagerController *)pagerController transitionFromeCell:(UICollectionViewCell *)fromCell toCell:(UICollectionViewCell *)toCell progress:(CGFloat)progress;

@end

@interface TYTabPagerController : TYPagerController

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-property-synthesis"
@property (nonatomic, weak) id<TYTabPagerControllerDelegate> delegate;
#pragma clang diagnostic pop

// view ,don't change frame
@property (nonatomic, weak, readonly) UIView *pagerBarView; // pagerBarView height is contentTopEdging
@property (nonatomic, weak, readonly) UICollectionView *collectionViewBar;
@property (nonatomic, weak, readonly) UIView *progressView;

// cell
@property (nonatomic, assign) CGFloat cellWidth; // if>0 cells width is equal
@property (nonatomic, assign) CGFloat cellSpacing; // cell space
@property (nonatomic, assign) CGFloat cellEdging;  // cell left right edge

// progress view
@property (nonatomic, assign) CGFloat progressHeight;
@property (nonatomic, assign) CGFloat progressEdging; //if>0 progress width is equal
@property (nonatomic, assign) CGFloat progressWidth;

@property (nonatomic, assign) BOOL progressBounces; // default YES

//   animate duration
@property (nonatomic, assign) CGFloat animateDuration;

// text font
@property (nonatomic, strong) UIFont *normalTextFont;
@property (nonatomic, strong) UIFont *selectedTextFont;

// if you custom cell ,you must register cell
- (void)registerCellClass:(Class)cellClass isContainXib:(BOOL)isContainXib;

// get cell at index
- (UICollectionViewCell *)cellForIndex:(NSInteger)index;

// get cell frame at index
- (CGRect)cellFrameWithIndex:(NSInteger)index;

@end

