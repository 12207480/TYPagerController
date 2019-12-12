//
//  TYPagerView.m
//  TYPagerControllerDemo
//
//  Created by tany on 2017/7/5.
//  Copyright © 2017年 tanyang. All rights reserved.
//

#import "TYPagerView.h"

@interface TYPagerView ()<TYPagerViewLayoutDataSource, TYPagerViewLayoutDelegate> {
    // private
    struct {
        unsigned int willAppearViewForIndex :1;
        unsigned int didAppearViewForIndex :1;
        unsigned int willDisappearViewForIndex :1;
        unsigned int didDisappearViewForIndex :1;
        unsigned int transitionFromIndexToIndex :1;
        unsigned int transitionFromIndexToIndexProgress :1;
        unsigned int viewDidScroll: 1;
        unsigned int viewWillBeginScrolling: 1;
        unsigned int viewDidEndScrolling: 1;
    }_delegateFlags;
}

// Data
@property (nonatomic, strong) TYPagerViewLayout<UIView *> *layout;

@end

@implementation TYPagerView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        // prevent sysytem automaticallyAdjustsScrollViewInsets
        [self addFixAutoAdjustInsetScrollView];
        [self addLayoutScrollView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
        // prevent sysytem automaticallyAdjustsScrollViewInsets
        [self addFixAutoAdjustInsetScrollView];
        [self addLayoutScrollView];
    }
    return self;
}

- (void)addFixAutoAdjustInsetScrollView {
    UIView *view = [[UIView alloc]init];
    [self addSubview:view];
}

- (void)addLayoutScrollView {
    UIScrollView *contentView = [[UIScrollView alloc]init];
    TYPagerViewLayout<UIView *> *layout = [[TYPagerViewLayout alloc]initWithScrollView:contentView];
    layout.dataSource = self;
    layout.delegate = self;
    [self addSubview:contentView];
    _layout = layout;
    _layout.scrollView.frame = self.bounds;
}

#pragma mark - getter && setter

- (NSInteger)curIndex {
    return _layout.curIndex;
}

- (NSInteger)countOfPagerViews {
    return _layout.countOfPagerItems;
}

- (NSArray<UIView *> *)visibleViews {
    return _layout.visibleItems;
}

- (UIScrollView *)scrollView {
    return _layout.scrollView;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self setNeedsLayout];
}

- (void)setDelegate:(id<TYPagerViewDelegate>)delegate {
    _delegate = delegate;
    
    _delegateFlags.willAppearViewForIndex = [delegate respondsToSelector:@selector(pagerView:willAppearView:forIndex:)];
    _delegateFlags.didAppearViewForIndex = [delegate respondsToSelector:@selector(pagerView:didAppearView:forIndex:)];
    _delegateFlags.willDisappearViewForIndex = [delegate respondsToSelector:@selector(pagerView:willDisappearView:forIndex:)];
    _delegateFlags.didDisappearViewForIndex = [delegate respondsToSelector:@selector(pagerView:didDisappearView:forIndex:)];
    
    _delegateFlags.transitionFromIndexToIndex = [delegate respondsToSelector:@selector(pagerView:transitionFromIndex:toIndex:animated:)];
    _delegateFlags.transitionFromIndexToIndexProgress = [delegate respondsToSelector:@selector(pagerView:transitionFromIndex:toIndex:progress:)];
    
    _delegateFlags.viewDidScroll = [delegate respondsToSelector:@selector(pagerViewDidScroll:)];
    _delegateFlags.viewWillBeginScrolling = [delegate respondsToSelector:@selector(pagerViewWillBeginScrolling:animate:)];
    _delegateFlags.viewDidEndScrolling = [delegate respondsToSelector:@selector(pagerViewDidEndScrolling:animate:)];
}

#pragma mark - public

- (void)updateData {
    [_layout updateData];
}

- (void)reloadData {
    [_layout reloadData];
}

- (void)scrollToViewAtIndex:(NSInteger)index animate:(BOOL)animate {
    [_layout scrollToItemAtIndex:index animate:animate];
}

- (UIView *)viewForIndex:(NSInteger)idx {
    return [_layout itemForIndex:idx];
}

- (void)registerClass:(Class)Class forViewWithReuseIdentifier:(NSString *)identifier {
    [_layout registerClass:Class forItemWithReuseIdentifier:identifier];
}
- (void)registerNib:(UINib *)nib forViewWithReuseIdentifier:(NSString *)identifier {
    [_layout registerNib:nib forItemWithReuseIdentifier:identifier];
}
- (UIView *)dequeueReusableViewWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    return [_layout dequeueReusableItemWithReuseIdentifier:identifier forIndex:index];
}

#pragma mark - private

- (void)willBeginScrollingAnimate:(BOOL)animate {
    if (_delegateFlags.viewWillBeginScrolling) {
        [_delegate pagerViewWillBeginScrolling:self animate:animate];
    }
}

- (void)didEndScrollingAnimate:(BOOL)animate {
    if (_delegateFlags.viewDidEndScrolling) {
        [_delegate pagerViewDidEndScrolling:self animate:animate];
    }
}

#pragma mark - TYPagerViewLayoutDataSource

- (NSInteger)numberOfItemsInPagerViewLayout {
    return [_dataSource numberOfViewsInPagerView];
}

- (id)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout itemForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    return [_dataSource pagerView:self viewForIndex:index prefetching:prefetching];
}

- (UIView *)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout viewForItem:(id)item atIndex:(NSInteger)index {
    return item;
}

- (void)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout addVisibleItem:(id)item atIndex:(NSInteger)index {
    UIView *visibleView = item;
    if (_delegateFlags.willAppearViewForIndex) {
        [_delegate pagerView:self willAppearView:visibleView forIndex:index];
    }
    [pagerViewLayout.scrollView addSubview:visibleView];
    if (_delegateFlags.didAppearViewForIndex) {
        [_delegate pagerView:self didAppearView:visibleView forIndex:index];
    }
}

- (void)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout removeInVisibleItem:(id)item atIndex:(NSInteger)index {
    UIView *invisibleView = item;
    if (_delegateFlags.willDisappearViewForIndex) {
        [_delegate pagerView:self willDisappearView:invisibleView forIndex:index];
    }
    [invisibleView removeFromSuperview];
    if (_delegateFlags.didDisappearViewForIndex) {
        [_delegate pagerView:self didDisappearView:invisibleView forIndex:index];
    }
}

#pragma mark - TYPagerViewLayoutDelegate

- (void)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    if (_delegateFlags.transitionFromIndexToIndex) {
        [_delegate pagerView:self transitionFromIndex:fromIndex toIndex:toIndex animated:animated];
    }
}

- (void)pagerViewLayout:(TYPagerViewLayout *)pagerViewLayout transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    if (_delegateFlags.transitionFromIndexToIndexProgress) {
        [_delegate pagerView:self transitionFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
}

- (void)pagerViewLayoutDidScroll:(TYPagerViewLayout *)pagerViewLayout {
    if (_delegateFlags.viewDidScroll) {
        [_delegate pagerViewDidScroll:self];
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

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    _layout.scrollView.frame = UIEdgeInsetsInsetRect(self.bounds,_contentInset);
}

- (void)dealloc {
    _layout = nil;
}

@end
