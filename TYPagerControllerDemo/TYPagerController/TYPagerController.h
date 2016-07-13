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

// viewController count in pagerController
- (NSInteger)numberOfControllersInPagerController;

// viewController at index in pagerController
- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index;

@optional

// viewController title in pagerController
- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index;

@end

@protocol TYPagerControllerDelegate <NSObject>

@optional

// transition from index to index with animated
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated;

// transition from index to index with progress
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end

@interface TYPagerController : UIViewController

@property (nonatomic, weak, readonly) UIScrollView *contentView; // don‘t change the frame

@property (nonatomic, weak) id<TYPagerControllerDataSource> dataSource;
@property (nonatomic, weak) id<TYPagerControllerDelegate>   delegate;

@property (nonatomic, strong, readonly) NSCache *memoryCache;// cache pagerController, you can set countLimit

@property (nonatomic, assign, readonly) NSInteger countOfControllers;// after viewdidload or reload have value

@property (nonatomic, assign, readonly) NSInteger curIndex;

@property (nonatomic, assign, readonly) NSRange visibleRange; // visible index range

@property (nonatomic, assign) CGFloat contentTopEdging; // contentView top edge

@property (nonatomic, assign) BOOL adjustStatusBarHeight; // defaut NO,if YES and navBar is hide,statusBarHeight have value to adjust status

@property (nonatomic, assign) CGFloat changeIndexWhenScrollProgress; // default 1.0,when scroll progress percent will change index

// reload
- (void)reloadData;

// override must call super , update contentView subviews frame
- (void)updateContentView;

// move pager controller to index
- (void)moveToControllerAtIndex:(NSInteger)index animated:(BOOL)animated;

// visible pager controllers
- (NSArray *)visibleViewControllers;

// scroll is progressing
- (BOOL)isProgressScrollEnabel;

// see adjustStatusBarHeight ,only layout views ,it is valid.
- (NSInteger)statusBarHeight;

@end

@interface TYPagerController (TransitionOverride)

// subclass override
- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated;

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end
