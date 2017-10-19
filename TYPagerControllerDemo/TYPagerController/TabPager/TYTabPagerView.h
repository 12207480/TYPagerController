//
//  TYTabPagerView.h
//  TYPagerControllerDemo
//
//  Created by tanyang on 2017/7/18.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYPagerView.h"
#import "TYTabPagerBar.h"

NS_ASSUME_NONNULL_BEGIN

@class TYTabPagerView;
@protocol TYTabPagerViewDataSource <NSObject>

- (NSInteger)numberOfViewsInTabPagerView;

- (UIView *)tabPagerView:(TYTabPagerView *)tabPagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching;

- (NSString *)tabPagerView:(TYTabPagerView *)tabPagerView titleForIndex:(NSInteger)index;

@end

@protocol TYTabPagerViewDelegate <NSObject>
@optional

// display cell
- (void)tabPagerView:(TYTabPagerView *)tabPagerView willDisplayCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> *)cell atIndex:(NSInteger)index;

// did select cell item
- (void)tabPagerView:(TYTabPagerView *)tabPagerView didSelectTabBarItemAtIndex:(NSInteger)index;

// appear && disappear
- (void)tabPagerView:(TYTabPagerView *)tabPagerView willAppearView:(UIView *)view forIndex:(NSInteger)index;
- (void)tabPagerView:(TYTabPagerView *)tabPagerView didDisappearView:(UIView *)view forIndex:(NSInteger)index;

// scrolling
- (void)tabPagerViewWillBeginScrolling:(TYTabPagerView *)tabPagerView animate:(BOOL)animate;
- (void)tabPagerViewDidEndScrolling:(TYTabPagerView *)tabPagerView animate:(BOOL)animate;

@end

@interface TYTabPagerView : UIView

@property (nonatomic, weak, readonly) TYTabPagerBar *tabBar;
@property (nonatomic, weak, readonly) TYPagerView *pageView;

@property (nonatomic, strong, readonly) TYPagerViewLayout<UIView *> *layout;

@property (nonatomic, weak, nullable) id<TYTabPagerViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<TYTabPagerViewDelegate> delegate;

@property (nonatomic, assign) CGFloat tabBarHeight;

// register tabBar cell
- (void)registerClass:(Class)Class forTabBarCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forTabBarCellWithReuseIdentifier:(NSString *)identifier;

// register && dequeue pager Cell, usage like tableView
- (void)registerClass:(Class)Class forPagerCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forPagerCellWithReuseIdentifier:(NSString *)identifier;
- (UIView *)dequeueReusablePagerCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;


- (void)scrollToViewAtIndex:(NSInteger)index animate:(BOOL)animate;

- (void)updateData;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
