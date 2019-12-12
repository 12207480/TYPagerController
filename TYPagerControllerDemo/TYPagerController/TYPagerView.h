//
//  TYPagerView.h
//  TYPagerControllerDemo
//
//  Created by tany on 2017/7/5.
//  Copyright © 2017年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYPagerViewLayout.h"

NS_ASSUME_NONNULL_BEGIN

@class TYPagerView;
@protocol TYPagerViewDataSource <NSObject>

- (NSInteger)numberOfViewsInPagerView;

/* 1.if prefetching is YES, the prefetch view not display.
   2.if view will diaplay,will call willAppearView:forIndex:.
   3.layout.frameForItemAtIndex can get view's frame
   4.you can register && dequeue view, usage like tableView
 */
- (UIView *)pagerView:(TYPagerView *)pagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching;

@end

@protocol TYPagerViewDelegate <NSObject>
@optional

// Display customization
// if want do something in view will display,you can implement this
- (void)pagerView:(TYPagerView *)pagerView willAppearView:(UIView *)view forIndex:(NSInteger)index;
- (void)pagerView:(TYPagerView *)pagerView didAppearView:(UIView *)view forIndex:(NSInteger)index;

// Disappear customization

- (void)pagerView:(TYPagerView *)pagerView willDisappearView:(UIView *)view forIndex:(NSInteger)index;
- (void)pagerView:(TYPagerView *)pagerView didDisappearView:(UIView *)view forIndex:(NSInteger)index;

// Transition animation customization

// if you implement ↓↓↓transitionFromIndex:toIndex:progress:,only tap change index will call this, you can set progressAnimateEnabel NO that not call progress method
- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated;

// if you implement the method,also you need implement ↑↑↑transitionFromIndex:toIndex:animated:,deal with tap change index animate
- (void)pagerView:(TYPagerView *)pagerView  transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

// scrollView delegate

- (void)pagerViewDidScroll:(TYPagerView *)pageView;
- (void)pagerViewWillBeginScrolling:(TYPagerView *)pageView animate:(BOOL)animate;
- (void)pagerViewDidEndScrolling:(TYPagerView *)pageView animate:(BOOL)animate;


@end

@interface TYPagerView : UIView

@property (nonatomic, weak, nullable) id<TYPagerViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<TYPagerViewDelegate> delegate;
// pagerView's layout,don't set layout's dataSource to other
@property (nonatomic, strong, readonly) TYPagerViewLayout<UIView *> *layout;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, assign, readonly) NSInteger countOfPagerViews;
@property (nonatomic, assign, readonly) NSInteger curIndex;// default -1

@property (nonatomic, assign, nullable, readonly) NSArray<UIView *> *visibleViews;

@property (nonatomic, assign) UIEdgeInsets contentInset;

//if not visible, prefecth, cache view at index, return nil
- (UIView *_Nullable)viewForIndex:(NSInteger)index;

// register && dequeue's usage like tableView
- (void)registerClass:(Class)Class forViewWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forViewWithReuseIdentifier:(NSString *)identifier;
- (UIView *)dequeueReusableViewWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

// scroll to index
- (void)scrollToViewAtIndex:(NSInteger)index animate:(BOOL)animate;

// update data and layout,but don't reset propertys(curIndex,visibleDatas,prefechDatas)
- (void)updateData;

// reload data and reset propertys
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END

