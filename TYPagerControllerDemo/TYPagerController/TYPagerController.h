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

- (NSInteger)numberOfControllersInPagerController;

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(CGFloat)index;

@end

@interface TYPagerController : UIViewController

@property (nonatomic, assign) CGFloat topEdging;

@property (nonatomic, strong, readonly) NSCache *memoryCache;

@property (nonatomic, assign, readonly) NSInteger curIndex;

@property (nonatomic, weak) id<TYPagerControllerDataSource> dataSource;

- (void)reloadData;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

- (NSArray *)visibleViewControllers;

@end
