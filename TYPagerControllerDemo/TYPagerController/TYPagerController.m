//
//  TYPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYPagerController.h"

typedef NS_ENUM(NSUInteger, TYPagerControllerDirection) {
    TYPagerControllerLeft,
    TYPagerControllerRight,
    TYPagerControllerNone,
};

@interface TYPagerController ()<UIScrollViewDelegate> {
    BOOL        _needLayoutContentView;
    BOOL        _scrollAnimated;
    BOOL        _isTapScrollMoved;
    CGFloat     _preOffsetX;
    
    struct {
        unsigned int transitionFromIndexToIndex :1;
        unsigned int transitionFromIndexToIndexProgress :1;
    }_delegateFlags;
    
    struct {
        unsigned int transitionFromIndexToIndex :1;
        unsigned int transitionFromIndexToIndexProgress :1;
    }_methodFlags;
}

@property (nonatomic, weak) UIScrollView *contentView;

@property (nonatomic, strong) NSMutableDictionary *visibleControllers;

@property (nonatomic, strong) NSCache *memoryCache;

@property (nonatomic, assign) NSInteger countOfControllers;

@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, assign) NSInteger curProgressIndex;

@property (nonatomic, assign) NSRange visibleRange;

@end

NS_INLINE CGRect frameForControllerAtIndex(NSInteger index, CGRect frame)
{
    return CGRectMake(index * CGRectGetWidth(frame), 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}

NS_INLINE NSRange visibleRangWithOffset(CGFloat offset,CGFloat width, NSInteger maxIndex)
{
    NSInteger startIndex = offset/width;
    NSInteger endIndex = ceil((offset + width)/width);
    
    if (startIndex < 0) {
        startIndex = 0;
    }
    
    if (endIndex > maxIndex) {
        endIndex = maxIndex;
    }
    return NSMakeRange(startIndex, endIndex - startIndex);
}

@implementation TYPagerController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self configureInitPropertys];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self configureInitPropertys];
    }
    return self;
}

- (void)configureInitPropertys
{
    _memoryCache = [[NSCache alloc]init];
    _changeIndexWhenScrollProgress = 0.5;
    _contentTopEdging = 0;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    // add horizenl scrollView
    [self addContentView];

    // set up propertys
    [self configurePropertys];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutContentViewIfNeed];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutContentViewIfNeed];
}

- (void)addContentView
{
    UIScrollView *contentView = [[UIScrollView alloc]init];
    contentView.showsHorizontalScrollIndicator = NO;
    contentView.showsVerticalScrollIndicator = NO;
    contentView.pagingEnabled = YES;
    contentView.delegate = self;
    [self.view addSubview:contentView];
    _contentView = contentView;
}

#pragma mark - configre propertys

- (void)configurePropertys
{
    _visibleControllers = [NSMutableDictionary dictionary];
    _curIndex = 0;
    _curProgressIndex = 0;
    _preOffsetX = 0;
    _scrollAnimated = YES;

    [self configureMethods];
}

- (void)resetPropertys
{
    [_memoryCache removeAllObjects];
    [_visibleControllers removeAllObjects];
    
    for (UIViewController *viewController in self.childViewControllers) {
        [self removeViewController:viewController];
    }
    
    _curIndex = 0;
    _curProgressIndex = 0;
    _preOffsetX = 0;
}

- (void)setDelegate:(id<TYPagerControllerDelegate>)delegate
{
    _delegate = delegate;
    
    _delegateFlags.transitionFromIndexToIndex = [_delegate respondsToSelector:@selector(pagerController:transitionFromIndex:toIndex:animated:)];
    _delegateFlags.transitionFromIndexToIndexProgress = [_delegate respondsToSelector:@selector(pagerController:transitionFromIndex:toIndex:progress:)];
}

- (void)configureMethods
{
    _methodFlags.transitionFromIndexToIndex = [self respondsToSelector:@selector(transitionFromIndex:toIndex:animated:)];
    _methodFlags.transitionFromIndexToIndexProgress = [self respondsToSelector:@selector(transitionFromIndex:toIndex:progress:)];
    
}

#pragma mark - public method

- (void)reloadData
{
    [self resetPropertys];
    
    [self updateContentView];
}

- (void)moveToControllerAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index < 0 || index >= _countOfControllers) {
        return;
    }
    _isTapScrollMoved = YES;
    _scrollAnimated = animated;
    [_contentView setContentOffset:CGPointMake(index * CGRectGetWidth(_contentView.frame),0) animated:NO];
}

- (NSArray *)visibleViewControllers
{
    return [_visibleControllers allValues];
}

#pragma mark - layout content

- (NSInteger)statusBarHeight
{
    return (_adjustStatusBarHeight && (!self.navigationController || self.navigationController.isNavigationBarHidden) && [[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 20:0;
}

// if need layout contentView
- (void)layoutContentViewIfNeed
{
    NSInteger topInset = _contentTopEdging - [self statusBarHeight];
    if (CGSizeEqualToSize(_contentView.frame.size, CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - topInset))) {
        if (_contentView.frame.origin.y != topInset) {
            CGRect frame = _contentView.frame;
            frame.origin.y = topInset;
            _contentView.frame = frame;
        }
        return;
    }
    
    // size changed
    [self updateContentView];
}

// update content subViews
- (void)updateContentView
{
    _needLayoutContentView = YES;
    _countOfControllers = [_dataSource numberOfControllersInPagerController];
    
    [self reSizeContentView];
    
    [self layoutContentView];
}

// change content View size
- (void)reSizeContentView
{
    CGFloat contentTopEdging = _contentTopEdging + [self statusBarHeight];
    _contentView.frame = CGRectMake(0, contentTopEdging, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - contentTopEdging);
    _contentView.contentSize = CGSizeMake(_countOfControllers * CGRectGetWidth(_contentView.frame), 0);
    _contentView.contentOffset = CGPointMake(_curIndex*CGRectGetWidth(_contentView.frame), 0);
}

// layout content subViews
- (void)layoutContentView
{
    CGFloat offsetX = _contentView.contentOffset.x;
    // 获取可见range
    NSRange visibleRange = visibleRangWithOffset(offsetX, CGRectGetWidth(_contentView.frame), _countOfControllers);

    if (NSEqualRanges(_visibleRange, visibleRange) && !_needLayoutContentView) {
        return;
    }
    _needLayoutContentView = NO;
    _visibleRange = visibleRange;
    
    [self removeControllersOutOfVisibleRange:_visibleRange];
    
    [self addControllersInVisibleRange:_visibleRange];
}

// caculate pager index
- (void)configurePagerIndex
{
    CGFloat offsetX = _contentView.contentOffset.x;
    CGFloat width = CGRectGetWidth(_contentView.frame);

    // scroll direction
    TYPagerControllerDirection direction = offsetX >= _preOffsetX ? TYPagerControllerLeft : TYPagerControllerRight;
    
    NSInteger index = 0;
    // when scroll progress percent will change index
    CGFloat percentChangeIndex = 1.0-_changeIndexWhenScrollProgress;
    
    // caculate cur index
    if (direction == TYPagerControllerLeft) {
        index = offsetX/width+percentChangeIndex;
    }else {
        index = ceil(offsetX/width-percentChangeIndex);
    }
    
    if (index < 0) {
        index = 0;
    }else if (index >= _countOfControllers) {
        index = _countOfControllers-1;
    }

    // if index not same,change index
    if (index != _curIndex) {
        NSInteger fromIndex = _curIndex;
        _curIndex = index;
        
        if (_methodFlags.transitionFromIndexToIndex) {
            [self transitionFromIndex:fromIndex toIndex:_curIndex animated:_scrollAnimated];
        }
        if (_delegateFlags.transitionFromIndexToIndex) {
            [_delegate pagerController:self transitionFromIndex:fromIndex toIndex:_curIndex animated:_scrollAnimated];
        }
    }
    _scrollAnimated = YES;
}

// caculate pager index and progress
- (void)configurePagerIndexByProgress
{
    CGFloat offsetX = _contentView.contentOffset.x;
    CGFloat width = CGRectGetWidth(_contentView.frame);
    CGFloat floorIndex = floor(offsetX/width);
    CGFloat progress = offsetX/width-floorIndex;
    
    if (floorIndex < 0 || floorIndex >= _countOfControllers) {
        return;
    }
    
    TYPagerControllerDirection direction = offsetX >= _preOffsetX ? TYPagerControllerLeft : TYPagerControllerRight;
    
    NSInteger fromIndex = 0, toIndex = 0;
    
    if (direction == TYPagerControllerLeft) {
        if (floorIndex >= _countOfControllers -1) {
            return;
        }
        fromIndex = floorIndex;
        toIndex = MIN(_countOfControllers-1, fromIndex + 1);
    }else {
        if (floorIndex < 0 ) {
            return;
        }
        toIndex = floorIndex;
        fromIndex = MIN(_countOfControllers-1, toIndex +1);
        progress = 1.0 - progress;
    }
    
    if (_methodFlags.transitionFromIndexToIndexProgress) {
        [self transitionFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
    
    if (_delegateFlags.transitionFromIndexToIndexProgress) {
        [_delegate pagerController:self transitionFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
}

// is scrolling and caculate progess ?
- (BOOL)isProgressScrollEnabel
{
    return (_delegateFlags.transitionFromIndexToIndexProgress || _methodFlags.transitionFromIndexToIndexProgress) && !_isTapScrollMoved ;
}

#pragma mark - remove controller

// remove pager controller if it out of visible range
- (void)removeControllersOutOfVisibleRange:(NSRange)range
{
    NSMutableArray *deleteArray = [NSMutableArray array];
    [_visibleControllers enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UIViewController *viewController, BOOL * stop) {
        NSInteger indexOfController = [key integerValue];
        
        if (!NSLocationInRange(indexOfController, range)) {
            // unvisible
            [self removeViewController:viewController atIndex:indexOfController];
            [deleteArray addObject:key];
        }else {
            [self addViewController:viewController atIndex:indexOfController];
        }
    }];
    
    [_visibleControllers removeObjectsForKeys:deleteArray];
}

// remove pager controller at index
- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    if (viewController.parentViewController) {
        [self removeViewController:viewController];
        // remove and cache
        if (![_memoryCache objectForKey:@(index)]) {
            [_memoryCache setObject:viewController forKey:@(index)];
        }
    }
}

- (void)removeViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];

}

#pragma mark - add controller

// add pager controller if it in visible range
- (void)addControllersInVisibleRange:(NSRange)range
{
    NSInteger endIndex = range.location + range.length;
    for (NSInteger idx = range.location ; idx < endIndex; ++idx) {
        
        UIViewController *viewController = [_visibleControllers objectForKey:@(idx)];
        
        if (!viewController) {
            // if cache have VC
            viewController = [_memoryCache objectForKey:@(idx)];
        }
        
        if (!viewController) {
            // from datasource get VC
            viewController = [_dataSource pagerController:self controllerForIndex:idx];
        }
        
        [self addViewController:viewController atIndex:idx];
    }
}

// add pager controller at index
- (void)addViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    if (!viewController.parentViewController) {
        // addChildViewController
        [self addChildViewController:viewController];
        viewController.view.frame = frameForControllerAtIndex(index, _contentView.frame);
        [_contentView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
        if (![_visibleControllers objectForKey:@(index)]) {
            [_visibleControllers setObject:viewController forKey:@(index)];
        }
    }else {
        // if VC have parentViewController，change the frame
        viewController.view.frame = frameForControllerAtIndex(index, _contentView.frame);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _contentView && _countOfControllers > 0) {

        if ([self isProgressScrollEnabel] && !_needLayoutContentView) {
            //  caculate scroll progress
            [self configurePagerIndexByProgress];
        }
        
        if (!_needLayoutContentView) {
            // caculate scroll index
            [self configurePagerIndex];
        }
        
        // layout
        [self layoutContentView];
        
        _isTapScrollMoved = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _contentView) {
        // save offsetX ,judge scroll direction
        _preOffsetX = scrollView.contentOffset.x;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_memoryCache removeAllObjects];
}

- (void)dealloc
{
    [_memoryCache removeAllObjects];
    [_visibleControllers removeAllObjects];
}

@end
