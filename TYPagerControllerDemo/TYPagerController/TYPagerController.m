//
//  TYPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYPagerController.h"

@interface TYPagerController ()<TYPagerViewLayoutDataSource, TYPagerViewLayoutDelegate> {
    // private
    struct {
        unsigned int viewWillAppearForIndex :1;
        unsigned int viewDidAppearForIndex :1;
        unsigned int viewWillDisappearForIndex :1;
        unsigned int viewDidDisappearForIndex :1;
        
        unsigned int transitionFromIndexToIndex :1;
        unsigned int transitionFromIndexToIndexProgress :1;
        unsigned int viewDidScroll: 1;
        unsigned int viewWillBeginScrolling: 1;
        unsigned int viewDidEndScrolling: 1;
    }_delegateFlags;
}

// Data
@property (nonatomic, strong) TYPagerViewLayout<UIViewController *> *layout;

@end


@implementation TYPagerController

- (TYPagerViewLayout<UIViewController *> *)layout {
    if (!_layout) {
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        TYPagerViewLayout<UIViewController *> *layout = [[TYPagerViewLayout alloc]initWithScrollView:scrollView];
        layout.dataSource = self;
        layout.delegate = self;
        layout.adjustScrollViewInset = YES;
        _layout = layout;
    }
    return _layout;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _automaticallySystemManagerViewAppearanceMethods = YES;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _automaticallySystemManagerViewAppearanceMethods = YES;
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.layout.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _layout.scrollView.frame = UIEdgeInsetsInsetRect(self.view.bounds,_contentInset);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _layout.scrollView.frame = UIEdgeInsetsInsetRect(self.view.bounds,_contentInset);
}

#pragma mark - getter && setter

- (void)setDelegate:(id<TYPagerControllerDelegate>)delegate
{
    _delegate = delegate;
    
    _delegateFlags.viewWillAppearForIndex = [delegate respondsToSelector:@selector(pagerController:viewWillAppear:forIndex:)];
    _delegateFlags.viewDidAppearForIndex = [delegate respondsToSelector:@selector(pagerController:viewDidAppear:forIndex:)];
    _delegateFlags.viewWillDisappearForIndex = [delegate respondsToSelector:@selector(pagerController:viewWillDisappear:forIndex:)];
    _delegateFlags.viewDidDisappearForIndex = [delegate respondsToSelector:@selector(pagerController:viewDidDisappear:forIndex:)];
    
    _delegateFlags.transitionFromIndexToIndex = [delegate respondsToSelector:@selector(pagerController:transitionFromIndex:toIndex:animated:)];
    _delegateFlags.transitionFromIndexToIndexProgress = [delegate respondsToSelector:@selector(pagerController:transitionFromIndex:toIndex:progress:)];
    
    _delegateFlags.viewDidScroll = [delegate respondsToSelector:@selector(pagerControllerDidScroll:)];
    _delegateFlags.viewWillBeginScrolling = [delegate respondsToSelector:@selector(pagerControllerWillBeginScrolling:animate:)];
    _delegateFlags.viewDidEndScrolling = [delegate respondsToSelector:@selector(pagerControllerDidEndScrolling:animate:)];
}

- (NSInteger)curIndex {
    return _layout.curIndex;
}

- (NSInteger)countOfControllers {
    return _layout.countOfPagerItems;
}

- (NSArray<UIViewController *> *)visibleControllers {
    return _layout.visibleItems;
}

- (UIScrollView *)scrollView {
    return _layout.scrollView;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self.view setNeedsLayout];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return _automaticallySystemManagerViewAppearanceMethods;
}

- (void)childViewController:(UIViewController *)childViewController BeginAppearanceTransition:(BOOL)isAppearing animated:(BOOL)animated {
    if (!_automaticallySystemManagerViewAppearanceMethods) {
        [childViewController beginAppearanceTransition:isAppearing animated:animated];
    }
}

- (void)childViewControllerEndAppearanceTransition:(UIViewController *)childViewController {
    if (!_automaticallySystemManagerViewAppearanceMethods) {
        [childViewController endAppearanceTransition];
    }
}

#pragma mark - public method

- (UIViewController *)controllerForIndex:(NSInteger)index {
    return [_layout itemForIndex:index];
}

- (void)scrollToControllerAtIndex:(NSInteger)index animate:(BOOL)animate {
    [_layout scrollToItemAtIndex:index animate:animate];
}

- (void)updateData {
    [_layout updateData];
}

- (void)reloadData {
    [_layout reloadData];
}

- (void)registerClass:(Class)Class forControllerWithReuseIdentifier:(NSString *)identifier {
    [_layout registerClass:Class forItemWithReuseIdentifier:identifier];
}
- (void)registerNib:(UINib *)nib forControllerWithReuseIdentifier:(NSString *)identifier {
    [_layout registerNib:nib forItemWithReuseIdentifier:identifier];
}
- (UIViewController *)dequeueReusableControllerWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    return [_layout dequeueReusableItemWithReuseIdentifier:identifier forIndex:index];
}

#pragma mark - private

- (void)willBeginScrollingAnimate:(BOOL)animate {
    if (_delegateFlags.viewWillBeginScrolling) {
        [_delegate pagerControllerWillBeginScrolling:self animate:animate];
    }
}

- (void)didEndScrollingAnimate:(BOOL)animate {
    if (_delegateFlags.viewDidEndScrolling) {
        [_delegate pagerControllerDidEndScrolling:self animate:animate];
    }
}

#pragma mark - TYPagerViewLayoutDataSource

- (NSInteger)numberOfItemsInPagerViewLayout {
    return [_dataSource numberOfControllersInPagerController];
}

- (id)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout itemForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    return [_dataSource pagerController:self controllerForIndex:index prefetching:prefetching];
}
- (UIView *)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout viewForItem:(id)item atIndex:(NSInteger)index {
    UIViewController *viewController = item;
    return viewController.view;
}

- (UIViewController *)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout viewControllerForItem:(id)item atIndex:(NSInteger)index {
    return item;
}

- (void)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout addVisibleItem:(id)item atIndex:(NSInteger)index {
    UIViewController *viewController = item;
    if (_delegateFlags.viewWillAppearForIndex) {
        [_delegate pagerController:self viewWillAppear:viewController forIndex:index];
    }
    // addChildViewController
    [self addChildViewController:viewController];
    [self childViewController:viewController BeginAppearanceTransition:YES animated:YES];
    [pagerViewLayout.scrollView addSubview:viewController.view];
    [self childViewControllerEndAppearanceTransition:viewController];
    [viewController didMoveToParentViewController:self];
    if (_delegateFlags.viewDidAppearForIndex) {
        [_delegate pagerController:self viewDidAppear:viewController forIndex:index];
    }
}

- (void)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout removeInVisibleItem:(id)item atIndex:(NSInteger)index {
    UIViewController *viewController = item;
    if (_delegateFlags.viewWillDisappearForIndex) {
        [_delegate pagerController:self viewWillDisappear:viewController forIndex:index];
    }
    // removeChildViewController
    [viewController willMoveToParentViewController:nil];
    [self childViewController:viewController BeginAppearanceTransition:NO animated:YES];
    [viewController.view removeFromSuperview];
    [self childViewControllerEndAppearanceTransition:viewController];
    [viewController removeFromParentViewController];
    if (_delegateFlags.viewDidDisappearForIndex) {
        [_delegate pagerController:self viewDidDisappear:viewController forIndex:index];
    }
}

#pragma mark - TYPagerViewLayoutDelegate

- (void)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    if (_delegateFlags.transitionFromIndexToIndex) {
        [_delegate pagerController:self transitionFromIndex:fromIndex toIndex:toIndex animated:animated];
    }
}

- (void)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    if (_delegateFlags.transitionFromIndexToIndexProgress) {
        [_delegate pagerController:self transitionFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
}

- (void)pagerViewLayoutDidScroll:(TYPagerViewLayout *)pagerViewLayout {
    if (_delegateFlags.viewDidScroll) {
        [_delegate pagerControllerDidScroll:self];
    }
}

- (void)pagerViewLayoutWillBeginDragging:(TYPagerViewLayout *)pagerViewLayout {
    [self willBeginScrollingAnimate:YES];
}

- (void)pagerViewLayoutWillBeginScrollToView:(TYPagerViewLayout *)pagerViewLayout animate:(BOOL)animate {
    [self willBeginScrollingAnimate:animate];
}

- (void)pagerViewLayoutDidEndDecelerating:(TYPagerViewLayout *)pagerViewLayout {
    [self didEndScrollingAnimate:YES];
}

- (void)pagerViewLayoutDidEndScrollToView:(TYPagerViewLayout *)pagerViewLayout animate:(BOOL)animate {
    [self didEndScrollingAnimate:animate];
}

- (void)pagerViewLayoutDidEndScrollingAnimation:(TYPagerViewLayout *)pagerViewLayout {
    [self didEndScrollingAnimate:YES];
}

- (void)dealloc
{
    _layout = nil;
}

@end
