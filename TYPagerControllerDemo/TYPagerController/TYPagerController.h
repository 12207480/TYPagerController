//
//  TYPagerController.h
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYPagerController;
@protocol TYPagerControllerDataSource <NSObject>

// pagerController count
- (NSInteger)numberOfControllersInPagerController;

// pagerController at index
- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index;

@optional

// pagerController title
- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index;

@end

@protocol TYPagerControllerDelegate <NSObject>

@optional

// transition from index to index with animated
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)formIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated;

// transition from index to index with progress
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)formIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end

@interface TYPagerController : UIViewController

@property (nonatomic, weak, readonly) UIScrollView *contentView; // don‘t change the frame

@property (nonatomic, weak) id<TYPagerControllerDataSource> dataSource;
@property (nonatomic, weak) id<TYPagerControllerDelegate>   delegate;

@property (nonatomic, strong, readonly) NSCache *memoryCache;// cache pagerController

@property (nonatomic, assign, readonly) NSInteger curIndex;

@property (nonatomic, assign, readonly) NSRange visibleRange; // visible index range

@property (nonatomic, assign) CGFloat contentTopEdging; // contentView top edge

@property (nonatomic, assign) CGFloat changeIndexWhenScrollProgress; // default 1.0

// reload
- (void)reloadData;

// override must call super
- (void)updateContentView;

// move pager controller to index
- (void)moveToControllerAtIndex:(NSInteger)index animated:(BOOL)animated;

// visible pager controllers
- (NSArray *)visibleViewControllers;

// scroll use progress
- (BOOL)isProgressScrollEnabel;

@end

@interface TYPagerController (TransitionOverride)

// subclass override
- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated;

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end
