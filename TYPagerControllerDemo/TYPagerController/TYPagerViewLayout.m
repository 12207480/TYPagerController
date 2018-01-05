//
//  TYPagerViewLayout.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 2017/7/9.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYPagerViewLayout.h"
#import <objc/runtime.h>

@interface TYAutoPurgeCache : NSCache
@end

@implementation TYAutoPurgeCache

- (nonnull instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
@end

static char ty_pagerReuseIdentifyKey;

@implementation NSObject (TY_PagerReuseIdentify)

- (NSString *)ty_pagerReuseIdentify {
    return objc_getAssociatedObject(self, &ty_pagerReuseIdentifyKey);
}

- (void)setTy_pagerReuseIdentify:(NSString *)ty_pagerReuseIdentify {
    objc_setAssociatedObject(self, &ty_pagerReuseIdentifyKey, ty_pagerReuseIdentify, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

typedef NS_ENUM(NSUInteger, TYPagerScrollingDirection) {
    TYPagerScrollingLeft,
    TYPagerScrollingRight,
};

NS_INLINE CGRect frameForItemAtIndex(NSInteger index, CGRect frame)
{
    return CGRectMake(index * CGRectGetWidth(frame), 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}

// caculate visilble range in offset
NS_INLINE NSRange visibleRangWithOffset(CGFloat offset,CGFloat width, NSInteger maxIndex)
{
    if (width <= 0) {
        return NSMakeRange(0, 0);
    }
    NSInteger startIndex = offset/width;
    NSInteger endIndex = ceil((offset + width)/width);
    
    if (startIndex < 0) {
        startIndex = 0;
    } else if (startIndex > maxIndex) {
        startIndex = maxIndex;
    }
    
    if (endIndex > maxIndex) {
        endIndex = maxIndex;
    }
    
    NSUInteger length = endIndex - startIndex;
    if (length > 5) {
        length = 5;
    }
    return NSMakeRange(startIndex, length);
}

NS_INLINE NSRange prefetchRangeWithVisibleRange(NSRange visibleRange,NSInteger prefetchItemCount, NSInteger  countOfPagerItems) {
    if (prefetchItemCount <= 0) {
        return NSMakeRange(0, 0);
    }
    NSInteger leftIndex = MAX((NSInteger)visibleRange.location - prefetchItemCount, 0);
    NSInteger rightIndex = MIN(visibleRange.location+visibleRange.length+prefetchItemCount, countOfPagerItems);
    return NSMakeRange(leftIndex, rightIndex - leftIndex);
}

static const NSInteger kMemoryCountLimit = 16;

@interface TYPagerViewLayout<ItemType> ()<UIScrollViewDelegate> {
    // Private
    BOOL        _needLayoutContent;
    BOOL        _scrollAnimated;
    BOOL        _isTapScrollMoved;
    CGFloat     _preOffsetX;
    NSInteger   _firstScrollToIndex;
    BOOL        _didReloadData;
    BOOL        _didLayoutSubViews;
    
    struct {
        unsigned int addVisibleItem :1;
        unsigned int removeInVisibleItem :1;
    }_dataSourceFlags;
    
    struct {
        unsigned int transitionFromIndexToIndex :1;
        unsigned int transitionFromIndexToIndexProgress :1;
        unsigned int pagerViewLayoutDidScroll: 1;
    }_delegateFlags;

}

// UI

@property (nonatomic, strong) UIScrollView *scrollView;

// Data

@property (nonatomic, assign) NSInteger countOfPagerItems;
@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) NSCache<NSNumber *,ItemType> *memoryCache;

@property (nonatomic, assign) NSRange visibleRange;
@property (nonatomic, assign) NSRange prefetchRange;

@property (nonatomic, strong) NSDictionary<NSNumber *,ItemType> *visibleIndexItems;
@property (nonatomic, strong) NSDictionary<NSNumber *,ItemType> *prefetchIndexItems;

//reuse Class and nib
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifyClassOrNib;
// reuse items
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifyItems;

@end

static NSString * kScrollViewFrameObserverKey = @"scrollView.frame";

@implementation TYPagerViewLayout

#pragma mark - init

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    if (self = [super init]) {
        NSParameterAssert(scrollView!=nil);
        _scrollView = scrollView;
        
        [self configurePropertys];
        
        [self configureScrollView];
        
        [self addScrollViewObservers];
    }
    return self;
}

#pragma mark - configure

- (void)configurePropertys {
    _curIndex = -1;
    _preOffsetX = 0;
    _changeIndexWhenScrollProgress = 0.5;
    _didReloadData = NO;
    _didLayoutSubViews = NO;
    _firstScrollToIndex = 0;
    _prefetchItemWillAddToSuperView = NO;
    _addVisibleItemOnlyWhenScrollAnimatedEnd = NO;
    _progressAnimateEnabel = YES;
    _adjustScrollViewInset = YES;
    _scrollAnimated = YES;
    _autoMemoryCache = YES;
}

- (void)configureScrollView {
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
}

- (void)resetPropertys {
    [self clearMemoryCache];
    [self removeVisibleItems];
    _scrollAnimated = NO;
    _curIndex = -1;
    _preOffsetX = 0;
}

#pragma mark - getter setter

- (NSArray *)visibleItems {
    return _visibleIndexItems.allValues;
}

- (NSArray *)visibleIndexs {
    return _visibleIndexItems.allKeys;
}

- (NSMutableDictionary *)reuseIdentifyItems {
    if (!_reuseIdentifyItems) {
        _reuseIdentifyItems = [NSMutableDictionary dictionary];
    }
    return _reuseIdentifyItems;
}

- (NSMutableDictionary *)reuseIdentifyClassOrNib {
    if (!_reuseIdentifyClassOrNib) {
        _reuseIdentifyClassOrNib = [NSMutableDictionary dictionary];
    }
    return _reuseIdentifyClassOrNib;
}

- (NSCache *)memoryCache {
    if (!_memoryCache) {
        _memoryCache = [[TYAutoPurgeCache alloc]init];
        _memoryCache.countLimit = kMemoryCountLimit;
    }
    return _memoryCache;
}

- (void)setAutoMemoryCache:(BOOL)autoMemoryCache {
    _autoMemoryCache = autoMemoryCache;
    if(!_autoMemoryCache && _memoryCache){
        [_memoryCache removeAllObjects];
        _memoryCache = nil;
    }
}

- (void)setPrefetchItemCount:(NSInteger)prefetchItemCount {
    _prefetchItemCount = prefetchItemCount;
    if (prefetchItemCount <= 0 && _prefetchIndexItems) {
        _prefetchIndexItems = nil;
    }
}

- (void)setDataSource:(id<TYPagerViewLayoutDataSource>)dataSource {
    _dataSource = dataSource;
    _dataSourceFlags.addVisibleItem = [dataSource respondsToSelector:@selector(pagerViewLayout:addVisibleItem:atIndex:)];
    _dataSourceFlags.removeInVisibleItem = [dataSource respondsToSelector:@selector(pagerViewLayout:removeInVisibleItem:atIndex:)];
}

- (void)setDelegate:(id<TYPagerViewLayoutDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.transitionFromIndexToIndex = [delegate respondsToSelector:@selector(pagerViewLayout:transitionFromIndex:toIndex:animated:)];
    _delegateFlags.transitionFromIndexToIndexProgress = [delegate respondsToSelector:@selector(pagerViewLayout:transitionFromIndex:toIndex:progress:)];
    _delegateFlags.pagerViewLayoutDidScroll = [delegate respondsToSelector:@selector(pagerViewLayoutDidScroll:)];
}

#pragma mark - public

- (void)reloadData {
    [self resetPropertys];
    
    [self updateData];
}

// update don't reset propertys(curIndex)
- (void)updateData {
    [self clearMemoryCache];
    _didReloadData = YES;
    _countOfPagerItems = [_dataSource numberOfItemsInPagerViewLayout];
    [self setNeedLayout];
}

/**
 scroll to item at index
 */
- (void)scrollToItemAtIndex:(NSInteger)index animate:(BOOL)animate {
    if (index < 0 || index >= _countOfPagerItems) {
        if (!_didReloadData && index >= 0) {
            _firstScrollToIndex = index;
        }
        return;
    }
    
    if (!_didLayoutSubViews && CGRectIsEmpty(_scrollView.frame)) {
        _firstScrollToIndex = index;
    }
    
    [self scrollViewWillScrollToView:_scrollView animate:animate];
    [_scrollView setContentOffset:CGPointMake(index * CGRectGetWidth(_scrollView.frame),0) animated:NO];
    [self scrollViewDidScrollToView:_scrollView animate:animate];
}

- (id)itemForIndex:(NSInteger)idx {
    NSNumber *index = @(idx);
    // 1.from visibleViews
    id visibleItem = [_visibleIndexItems objectForKey:index];
    if (!visibleItem && _prefetchItemCount > 0) {
        // 2.from prefetch
        visibleItem = [_prefetchIndexItems objectForKey:index];
    }
    if (!visibleItem) {
        // 3.from cache
        visibleItem = [self cacheItemForKey:index];
    }
    return visibleItem;
}

- (UIView *)viewForItem:(id)item atIndex:(NSInteger)index {
    UIView *view = [_dataSource pagerViewLayout:self viewForItem:item atIndex:index];
    return view;
}

- (UIViewController *)viewControllerForItem:(id)item atIndex:(NSInteger)index {
    if ([_dataSource respondsToSelector:@selector(pagerViewLayout:viewControllerForItem:atIndex:)]) {
        return [_dataSource pagerViewLayout:self viewControllerForItem:item atIndex:index];
    }
    return nil;
}

- (CGRect)frameForItemAtIndex:(NSInteger)index {
    CGRect frame = frameForItemAtIndex(index, _scrollView.frame);
    if (_adjustScrollViewInset) {
        frame.size.height -= _scrollView.contentInset.top;
    }
    return frame;
}

#pragma mark - register && dequeue

- (void)registerClass:(Class)Class forItemWithReuseIdentifier:(NSString *)identifier {
    [self.reuseIdentifyClassOrNib setObject:Class forKey:identifier];
}

- (void)registerNib:(UINib *)nib forItemWithReuseIdentifier:(NSString *)identifier {
    [self.reuseIdentifyClassOrNib setObject:nib forKey:identifier];
}

- (id)dequeueReusableItemWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    NSAssert(_reuseIdentifyClassOrNib.count != 0, @"you don't register any identifiers!");
    NSObject *item = [self.reuseIdentifyItems objectForKey:identifier];
    if (item) {
        [self.reuseIdentifyItems removeObjectForKey:identifier];
        return item;
    }
    id itemClassOrNib = [self.reuseIdentifyClassOrNib objectForKey:identifier];
    if (!itemClassOrNib) {
        NSString *error = [NSString stringWithFormat:@"you don't register this identifier->%@",identifier];
        NSAssert(NO, error);
        NSLog(@"%@", error);
        return nil;
    }
    
    if (class_isMetaClass(object_getClass(itemClassOrNib))) {
        // is class
        item = [[((Class)itemClassOrNib) alloc]init];
    }else if ([itemClassOrNib isKindOfClass:[UINib class]]) {
        // is nib
        item =[((UINib *)itemClassOrNib)instantiateWithOwner:nil options:nil].firstObject;
    }
    if (!item){
        NSString *error = [NSString stringWithFormat:@"you register identifier->%@ is not class or nib!",identifier];
        NSAssert(NO, error);
        NSLog(@"%@", error);
        return nil;
    }
    [item setTy_pagerReuseIdentify:identifier];
    UIView *view = [_dataSource pagerViewLayout:self viewForItem:item atIndex:index];
    view.frame = [self frameForItemAtIndex:index];
    return item;
}

- (void)enqueueReusableItem:(NSObject *)reuseItem prefetchRange:(NSRange)prefetchRange atIndex:(NSInteger)index{
    if (reuseItem.ty_pagerReuseIdentify.length == 0 || NSLocationInRange(index, prefetchRange)) {
        return;
    }
    [self.reuseIdentifyItems setObject:reuseItem forKey:reuseItem.ty_pagerReuseIdentify];
}

#pragma mark - layout content

- (void)setNeedLayout {
    // 1. get count Of pager Items
    if (_countOfPagerItems <= 0) {
        _countOfPagerItems = [_dataSource numberOfItemsInPagerViewLayout];
    }
    _needLayoutContent = YES;
    if (_curIndex >= _countOfPagerItems) {
        _curIndex = _countOfPagerItems - 1;
    }
    
    BOOL needLayoutSubViews = NO;
    if (!_didLayoutSubViews && !CGRectIsEmpty(_scrollView.frame) && _firstScrollToIndex < _countOfPagerItems) {
        _didLayoutSubViews = YES;
        needLayoutSubViews = YES;
    }
    
    // 2.set contentSize and offset
    CGFloat contentWidth = CGRectGetWidth(_scrollView.frame);
    _scrollView.contentSize = CGSizeMake(_countOfPagerItems * contentWidth, 0);
    _scrollView.contentOffset = CGPointMake(MAX(needLayoutSubViews ? _firstScrollToIndex : _curIndex, 0)*contentWidth, _scrollView.contentOffset.y);
    
    // 3.layout content
    if (_curIndex < 0 || needLayoutSubViews) {
        [self scrollViewDidScroll:_scrollView];
    }else {
        [self layoutIfNeed];
    }
}

- (void)layoutIfNeed {
    if (CGRectIsEmpty(_scrollView.frame)) {
        return;
    }
    // 1.caculate visible range
    CGFloat offsetX = _scrollView.contentOffset.x;
    NSRange visibleRange = visibleRangWithOffset(offsetX, CGRectGetWidth(_scrollView.frame), _countOfPagerItems);
    if (NSEqualRanges(_visibleRange, visibleRange) && !_needLayoutContent) {
        // visible range not change
        return;
    }
    _visibleRange = visibleRange;
    _needLayoutContent = NO;
    
    BOOL afterPrefetchIfNoVisibleItems = !_visibleIndexItems;
    if (!afterPrefetchIfNoVisibleItems) {
        // 2.prefetch left and right Items
        [self addPrefetchItemsOutOfVisibleRange:_visibleRange];
    }
    // 3.remove invisible Items
    [self removeVisibleItemsOutOfVisibleRange:_visibleRange];
    // 4.add visiible Items
    [self addVisibleItemsInVisibleRange:_visibleRange];
    if (afterPrefetchIfNoVisibleItems) {
        [self addPrefetchItemsOutOfVisibleRange:_visibleRange];
    }
}

#pragma mark - remove && add visibleViews

- (void)removeVisibleItems {
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _visibleIndexItems = nil;
    _prefetchIndexItems = nil;
    if (_reuseIdentifyItems) {
        [_reuseIdentifyItems removeAllObjects];
    }
}

- (void)removeVisibleItemsOutOfVisibleRange:(NSRange)visibleRange {
    [_visibleIndexItems enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id item, BOOL * stop) {
        NSInteger index = [key integerValue];
        if (!NSLocationInRange(index, visibleRange)) {
            // out of visible
            [self removeInvisibleItem:item atIndex:index];
        }
    }];
}

- (void)removeInvisibleItem:(id)invisibleItem atIndex:(NSInteger)index{
    UIView *invisibleView = [self viewForItem:invisibleItem atIndex:index];
    if (!invisibleView.superview) {
        return;
    }
    if (_dataSourceFlags.removeInVisibleItem) {
        [_dataSource pagerViewLayout:self removeInVisibleItem:invisibleItem atIndex:index];
    }else {
        NSAssert(NO, @"must implememt datasource pagerViewLayout:removeInVisibleItem:atIndex:!");
    }
    
    NSObject *reuseItem = invisibleItem;
    if (_reuseIdentifyClassOrNib.count > 0 && reuseItem.ty_pagerReuseIdentify.length > 0) {
        // reuse
        [self enqueueReusableItem:reuseItem prefetchRange:_prefetchRange atIndex:index];
    }else {
        [self cacheItem:invisibleItem forKey:@(index)];
    }
}

- (void)addVisibleItemsInVisibleRange:(NSRange)visibleRange {
    NSMutableDictionary *visibleIndexItems = [NSMutableDictionary dictionary];
    // add visible views
    for (NSInteger idx = visibleRange.location ; idx < visibleRange.location + visibleRange.length; ++idx) {
        // from visibleViews,prefetch,cache
        id visibleItem  = [self itemForIndex:idx];
        if (!visibleItem && (!_addVisibleItemOnlyWhenScrollAnimatedEnd || visibleRange.length == 1)) {
            // ↑↑↑ if _addVisibleItemOnlyWhenScrollAnimatedEnd is NO ,scroll visible range change will add item from dataSource, else is YES only scroll animate end(visibleRange.length == 1) will add item from dataSource
            visibleItem = [_dataSource pagerViewLayout:self itemForIndex:idx prefetching:NO];
        }
        if (visibleItem) {
            [self addVisibleItem:visibleItem atIndex:idx];
            visibleIndexItems[@(idx)] = visibleItem;
        }
    }
    
    if (visibleIndexItems.count > 0) {
        _visibleIndexItems = [visibleIndexItems copy];
    }else {
        _visibleIndexItems = nil;
    }
}

- (void)addVisibleItem:(id)visibleItem atIndex:(NSInteger)index{
    if (!visibleItem) {
        NSAssert(visibleItem != nil, @"visibleView must not nil!");
        return;
    }
    UIView *view = [self viewForItem:visibleItem atIndex:index];
    if (view.superview && view.superview != _scrollView) {
        [view removeFromSuperview];
    }
    CGRect frame = [self frameForItemAtIndex:index];
    if (!CGRectEqualToRect(view.frame, frame)) {
        view.frame = frame;
    }
    if (!_prefetchItemWillAddToSuperView && view.superview) {
        return;
    }
    
    if (_prefetchItemWillAddToSuperView && view.superview) {
        UIViewController *viewController = [self viewControllerForItem:visibleItem atIndex:index];
        if (!viewController || viewController.parentViewController) {
            return;
        }
    }
    
    if (_dataSourceFlags.addVisibleItem) {
        [_dataSource pagerViewLayout:self addVisibleItem:visibleItem atIndex:index];
    }else {
        NSAssert(NO, @"must implement datasource pagerViewLayout:addVisibleItem:frame:atIndex:!");
    }
}

- (void)addPrefetchItemsOutOfVisibleRange:(NSRange)visibleRange{
    if (_prefetchItemCount <= 0) {
        return;
    }
    NSRange prefetchRange = prefetchRangeWithVisibleRange(visibleRange, _prefetchItemCount, _countOfPagerItems);
    if (visibleRange.length == 1) {
        // ↑↑↑mean: scroll animate end
        NSMutableDictionary *prefetchIndexItems = [NSMutableDictionary dictionary];
        // add prefetch items
        for (NSInteger index = prefetchRange.location; index < NSMaxRange(prefetchRange); ++index) {
            id prefetchItem = nil;
            if (NSLocationInRange(index, visibleRange)) {
                prefetchItem = [_visibleIndexItems objectForKey:@(index)];
            }else {
                prefetchItem = [self prefetchInvisibleItemAtIndex:index];
            }
            if (prefetchItem) {
                [prefetchIndexItems setObject:prefetchItem forKey:@(index)];
            }
        }
        
        BOOL haveReuseIdentifyClassOrNib = _reuseIdentifyClassOrNib.count > 0;
        if (haveReuseIdentifyClassOrNib || _prefetchItemWillAddToSuperView) {
            [_prefetchIndexItems enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, id obj, BOOL * stop) {
                NSInteger index = [key integerValue];
                if (haveReuseIdentifyClassOrNib) {
                    // resuse item
                    [self enqueueReusableItem:obj prefetchRange:prefetchRange atIndex:index];
                }
                if (_prefetchItemWillAddToSuperView && !NSLocationInRange(index, prefetchRange)) {
                    // remove prefetch item to superView
                    UIView *view = [self viewForItem:obj atIndex:index];
                    if (view.superview == _scrollView && ![_visibleIndexItems objectForKey:key]) {
                        [view removeFromSuperview];
                    }
                }
            }];
        }
        if (prefetchIndexItems.count > 0) {
            _prefetchRange = prefetchRange;
            _prefetchIndexItems = [prefetchIndexItems copy];
        }else {
            _prefetchRange = NSMakeRange(0, 0);
            _prefetchIndexItems = nil;
        }
    }else if (NSIntersectionRange(visibleRange, _prefetchRange).length == 0) {
        // visible and prefetch intersection, remove all prefetchItems
        if (_prefetchItemWillAddToSuperView) {
            [_prefetchIndexItems enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                UIView *view = [self viewForItem:obj atIndex:[key integerValue]];
                if (view.superview == _scrollView && ![_visibleIndexItems objectForKey:key]) {
                    [view removeFromSuperview];
                }
            }];
        }
        _prefetchRange = NSMakeRange(0, 0);
        _prefetchIndexItems = nil;
    }
}

- (UIView *)prefetchInvisibleItemAtIndex:(NSInteger)index {
    id prefetchItem = [_prefetchIndexItems objectForKey:@(index)];
    if (!prefetchItem) {
        prefetchItem = [_visibleIndexItems objectForKey:@(index)];
    }
    if (!prefetchItem) {
        prefetchItem = [self cacheItemForKey:@(index)];
    }
    if (!prefetchItem) {
        prefetchItem = [_dataSource pagerViewLayout:self itemForIndex:index prefetching:YES];
        UIView *view = [self viewForItem:prefetchItem atIndex:index];
        CGRect frame = [self frameForItemAtIndex:index];
        if (!CGRectEqualToRect(view.frame, frame)) {
            view.frame = frame;
        }
        if (_prefetchItemWillAddToSuperView && view.superview != _scrollView) {
            [_scrollView addSubview:view];
        }
    }
    return prefetchItem;
}

#pragma mark - caculate index

- (void)caculateIndexWithOffsetX:(CGFloat)offsetX direction:(TYPagerScrollingDirection)direction{
    if (CGRectIsEmpty(_scrollView.frame)) {
        return;
    }
    if (_countOfPagerItems <= 0) {
        _curIndex = -1;
        return;
    }
    // scrollView width
    CGFloat width = CGRectGetWidth(_scrollView.frame);
    NSInteger index = 0;
    // when scroll to progress(changeIndexWhenScrollProgress) will change index
    double percentChangeIndex = _changeIndexWhenScrollProgress;
    if (_changeIndexWhenScrollProgress >= 1.0 || [self progressCaculateEnable]) {
        percentChangeIndex = 0.999999999;
    }
    
    // caculate cur index
    if (direction == TYPagerScrollingLeft) {
        index = ceil(offsetX/width-percentChangeIndex);
    }else {
        index = floor(offsetX/width+percentChangeIndex);
    }
    
    if (index < 0) {
        index = 0;
    }else if (index >= _countOfPagerItems) {
        index = _countOfPagerItems-1;
    }
    if (index == _curIndex) {
        // if index not same,change index
        return;
    }
    
    NSInteger fromIndex = MAX(_curIndex, 0);
    _curIndex = index;
    if (_delegateFlags.transitionFromIndexToIndex /*&& ![self progressCaculateEnable]*/) {
        [_delegate pagerViewLayout:self transitionFromIndex:fromIndex toIndex:_curIndex animated:_scrollAnimated];
    }
    _scrollAnimated = YES;
}

- (void)caculateIndexByProgressWithOffsetX:(CGFloat)offsetX direction:(TYPagerScrollingDirection)direction{
    if (CGRectIsEmpty(_scrollView.frame)) {
        return;
    }
    if (_countOfPagerItems <= 0) {
        _curIndex = -1;
        return;
    }
    CGFloat width = CGRectGetWidth(_scrollView.frame);
    CGFloat floadIndex = offsetX/width;
    NSInteger floorIndex = floor(floadIndex);
    if (floorIndex < 0 || floorIndex >= _countOfPagerItems || floadIndex > _countOfPagerItems-1) {
        return;
    }
    
    CGFloat progress = offsetX/width-floorIndex;
    NSInteger fromIndex = 0, toIndex = 0;
    if (direction == TYPagerScrollingLeft) {
        fromIndex = floorIndex;
        toIndex = MIN(_countOfPagerItems -1, fromIndex + 1);
        if (fromIndex == toIndex && toIndex == _countOfPagerItems-1) {
            fromIndex = _countOfPagerItems-2;
            progress = 1.0;
        }
    }else {
        toIndex = floorIndex;
        fromIndex = MIN(_countOfPagerItems-1, toIndex +1);
        progress = 1.0 - progress;
    }
    
    if (_delegateFlags.transitionFromIndexToIndexProgress) {
        [_delegate pagerViewLayout:self transitionFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
}

- (BOOL)progressCaculateEnable {
    return _delegateFlags.transitionFromIndexToIndexProgress && _progressAnimateEnabel && !_isTapScrollMoved;
}

#pragma mark - memoryCache

- (void)clearMemoryCache {
    if (_autoMemoryCache && _memoryCache) {
        [_memoryCache removeAllObjects];
    }
}

- (void)cacheItem:(id)item forKey:(NSNumber *)key {
    if (_autoMemoryCache && key) {
        UIView *cacheItem = [self.memoryCache objectForKey:key];
        if (cacheItem && cacheItem == item) {
            return;
        }
        [self.memoryCache setObject:item forKey:key];
    }
}

- (id)cacheItemForKey:(NSNumber *)key {
    if (_autoMemoryCache && _memoryCache && key) {
        return [_memoryCache objectForKey:key];
    }
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.superview) {
        return;
    }
    // get scrolling direction
    CGFloat offsetX = scrollView.contentOffset.x;
    TYPagerScrollingDirection direction = offsetX >= _preOffsetX ? TYPagerScrollingLeft : TYPagerScrollingRight;
    
    // caculate index and progress
    if ([self progressCaculateEnable]) {
        [self caculateIndexByProgressWithOffsetX:offsetX direction:direction];
    }
    [self caculateIndexWithOffsetX:offsetX direction:direction];
    
    // layout items
    [self layoutIfNeed];
    _isTapScrollMoved = NO;
    
    if (_delegateFlags.pagerViewLayoutDidScroll) {
        [_delegate pagerViewLayoutDidScroll:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _preOffsetX = scrollView.contentOffset.x;
    if ([_delegate respondsToSelector:@selector(pagerViewLayoutWillBeginDragging:)]) {
        [_delegate pagerViewLayoutWillBeginDragging:self];
    }
}

- (void)scrollViewWillScrollToView:(UIScrollView *)scrollView animate:(BOOL)animate {
    _preOffsetX = scrollView.contentOffset.x;
    _isTapScrollMoved = YES;
    _scrollAnimated = animate;
    if ([_delegate respondsToSelector:@selector(pagerViewLayoutWillBeginScrollToView:animate:)]) {
        [_delegate pagerViewLayoutWillBeginScrollToView:self animate:animate];
    }
}

- (void)scrollViewDidScrollToView:(UIScrollView *)scrollView animate:(BOOL)animate {
    if ([_delegate respondsToSelector:@selector(pagerViewLayoutDidEndScrollToView:animate:)]) {
        [_delegate pagerViewLayoutDidEndScrollToView:self animate:animate];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_delegate respondsToSelector:@selector(pagerViewLayoutDidEndDragging:willDecelerate:)]) {
        [_delegate pagerViewLayoutDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(pagerViewLayoutWillBeginDecelerating:)]) {
        [_delegate pagerViewLayoutWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(pagerViewLayoutDidEndDecelerating:)]) {
        [_delegate pagerViewLayoutDidEndDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(pagerViewLayoutDidEndScrollingAnimation:)]) {
        [_delegate pagerViewLayoutDidEndScrollingAnimation:self];
    }
}

#pragma mark - Observer

- (void)addScrollViewObservers {
    [self addObserver:self forKeyPath:kScrollViewFrameObserverKey options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kScrollViewFrameObserverKey]) {
        CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue];
        CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey]CGRectValue];
        BOOL needLayoutContent = !CGRectEqualToRect(newFrame, oldFrame);
        if (needLayoutContent) {
            [self setNeedLayout];
        }
    }
}

- (void)removeScrollViewObservers {
    [self removeObserver:self forKeyPath:kScrollViewFrameObserverKey context:nil];
}

- (void)dealloc {
    [self removeScrollViewObservers];
    _scrollView.delegate = nil;
    _scrollView = nil;
    if (_reuseIdentifyItems) {
        [_reuseIdentifyItems removeAllObjects];
    }
    if (_reuseIdentifyClassOrNib) {
        [_reuseIdentifyClassOrNib removeAllObjects];
    }
    [self clearMemoryCache];
}

@end
