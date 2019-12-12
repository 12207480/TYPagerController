//
//  TYTabPagerBar.h
//  TYPagerControllerDemo
//
//  Created by tany on 2017/7/13.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTabPagerBarLayout.h"

NS_ASSUME_NONNULL_BEGIN

@class TYTabPagerBar;
@protocol TYTabPagerBarDataSource <NSObject>

- (NSInteger)numberOfItemsInPagerTabBar;

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index;

@end

@protocol TYTabPagerBarDelegate <NSObject>

@optional

// configure layout
- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar configureLayout:(TYTabPagerBarLayout *)layout;

// if cell wdith is not variable,you can set layout.cellWidth. otherwise ,you can implement this return cell width. cell width not contain cell edge
- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index;

// did select cell item
- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index;

// transition frome cell to cell with animated
- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar transitionFromeCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> * _Nullable)fromCell toCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> * _Nullable)toCell animated:(BOOL)animated;

// transition frome cell to cell with progress
- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar transitionFromeCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> * _Nullable)fromCell toCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> * _Nullable)toCell progress:(CGFloat)progress;

@end

@interface TYTabPagerBar : UIView

@property (nonatomic, weak, readonly) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *progressView;
// automatically resized to self.bounds
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, weak, nullable) id<TYTabPagerBarDataSource> dataSource;

@property (nonatomic, weak, nullable) id<TYTabPagerBarDelegate> delegate;

@property (nonatomic, strong) TYTabPagerBarLayout *layout;

@property (nonatomic, assign) BOOL autoScrollItemToCenter;

@property (nonatomic, assign, readonly) NSInteger countOfItems;

@property (nonatomic, assign, readonly) NSInteger curIndex;

@property (nonatomic, assign) UIEdgeInsets contentInset;

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

- (__kindof UICollectionViewCell<TYTabPagerBarCellProtocol> *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

- (void)reloadData;

- (void)scrollToItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animate:(BOOL)animate;
- (void)scrollToItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;
- (void)scrollToItemAtIndex:(NSInteger)index atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (CGFloat)cellWidthForTitle:(NSString * _Nullable)title;
- (CGRect)cellFrameWithIndex:(NSInteger)index;
- (nullable UICollectionViewCell<TYTabPagerBarCellProtocol> *)cellForIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
