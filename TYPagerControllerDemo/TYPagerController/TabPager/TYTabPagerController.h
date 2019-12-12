//
//  TYTabPagerController.h
//  TYPagerControllerDemo
//
//  Created by tanyang on 2017/7/18.
//  Copyright © 2017年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTabPagerBar.h"
#import "TYPagerController.h"

NS_ASSUME_NONNULL_BEGIN

@class TYTabPagerController;
@protocol TYTabPagerControllerDataSource <NSObject>

- (NSInteger)numberOfControllersInTabPagerController;

- (UIViewController *)tabPagerController:(TYTabPagerController *)tabPagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching;

- (NSString *)tabPagerController:(TYTabPagerController *)tabPagerController titleForIndex:(NSInteger)index;

@end

@protocol TYTabPagerControllerDelegate <NSObject>
@optional

// display cell
- (void)tabPagerController:(TYTabPagerController *)tabPagerController willDisplayCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> *)cell atIndex:(NSInteger)index;

// did select cell item
- (void)tabPagerController:(TYTabPagerController *)tabPagerController didSelectTabBarItemAtIndex:(NSInteger)index;

// scrolling
- (void)tabPagerControllerWillBeginScrolling:(TYTabPagerController *)tabPagerController animate:(BOOL)animate;
- (void)tabPagerControllerDidEndScrolling:(TYTabPagerController *)tabPagerController animate:(BOOL)animate;

@end

@interface TYTabPagerController : UIViewController

@property (nonatomic, strong, readonly) TYTabPagerBar *tabBar;
@property (nonatomic, strong, readonly) TYPagerController *pagerController;
@property (nonatomic, strong, readonly) TYPagerViewLayout<UIViewController *> *layout;

@property (nonatomic, weak, nullable) id<TYTabPagerControllerDataSource> dataSource;
@property (nonatomic, weak, nullable) id<TYTabPagerControllerDelegate> delegate;

// you can custom tabBar orignY and height.
@property (nonatomic, assign) CGFloat tabBarOrignY;
@property (nonatomic, assign) CGFloat tabBarHeight;

// register tabBar cell
- (void)registerClass:(Class)Class forTabBarCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forTabBarCellWithReuseIdentifier:(NSString *)identifier;

// register && dequeue pager Cell, usage like tableView
- (void)registerClass:(Class)Class forPagerCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forPagerCellWithReuseIdentifier:(NSString *)identifier;
- (UIViewController *)dequeueReusablePagerCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;


- (void)scrollToControllerAtIndex:(NSInteger)index animate:(BOOL)animate;

- (void)updateData;

- (void)reloadData;


@end

NS_ASSUME_NONNULL_END
