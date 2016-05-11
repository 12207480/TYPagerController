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
    NSInteger   _countOfControllers;
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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        _memoryCache = [[NSCache alloc]init];
        _changeIndexWhenScrollProgress = 0.5;
        _contentTopEdging = 0;
    }
    return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addContentView];

    [self configurePropertys];
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

- (void)layoutContentViewIfNeed
{
    if (!CGSizeEqualToSize(_contentView.frame.size, CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _contentTopEdging))) {
        // size changed
        [self updateContentView];
    }
}

- (void)updateContentView
{
    _needLayoutContentView = YES;
    _countOfControllers = [_dataSource numberOfControllersInPagerController];
    
    [self reSizeContentView];
    
    [self layoutContentView];
}

- (void)reSizeContentView
{
    _contentView.frame = CGRectMake(0, _contentTopEdging, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _contentTopEdging);
    _contentView.contentSize = CGSizeMake(_countOfControllers * CGRectGetWidth(_contentView.frame), 0);
    _contentView.contentOffset = CGPointMake(_curIndex*CGRectGetWidth(_contentView.frame), 0);
}

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
    
    //NSLog(@"visibleRange %@",NSStringFromRange(visibleRange));
    //NSLog(@"cur index %ld count %ld",_curIndex,self.childViewControllers.count);
}

- (void)configurePagerIndex
{
    CGFloat offsetX = _contentView.contentOffset.x;
    CGFloat width = CGRectGetWidth(_contentView.frame);

    TYPagerControllerDirection direction = offsetX >= _preOffsetX ? TYPagerControllerLeft : TYPagerControllerRight;
    
    NSInteger index = 0;
    BOOL animated = _scrollAnimated;
    _scrollAnimated = YES;
    CGFloat percentChangeIndex = 1.0-_changeIndexWhenScrollProgress;
    
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

    if (index != _curIndex) {
        NSInteger fromIndex = _curIndex;
        _curIndex = index;
        if (_methodFlags.transitionFromIndexToIndex) {
            [self transitionFromIndex:fromIndex toIndex:_curIndex animated:animated];
        }
        if (_delegateFlags.transitionFromIndexToIndex) {
            [_delegate pagerController:self transitionFromIndex:fromIndex toIndex:_curIndex animated:animated];
        }
    }
}

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
    NSInteger fromIndex = 0;
    NSInteger toIndex = 0;
    if (direction == TYPagerControllerLeft) {
        if (floorIndex >= _countOfControllers -1) {
            return;
        }
        fromIndex = floorIndex;
        toIndex = MIN(_countOfControllers-1, fromIndex + 1);
    }else {
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

- (BOOL)isProgressScrollEnabel
{
    return (_delegateFlags.transitionFromIndexToIndexProgress || _methodFlags.transitionFromIndexToIndexProgress) && !_isTapScrollMoved ;
}

//- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated
//{
//    NSLog(@"formIndex %ld toIndex:%ld",fromIndex,toIndex);
//}
//
//- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
//{
//    NSLog(@"formIndex %ld toIndex:%ld progress %.2f",fromIndex,toIndex, progress);
//}

#pragma mark - remove controller
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

- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    if (viewController.parentViewController) {
        //NSLog(@"removeViewController index %ld",index);
        [self removeViewController:viewController];
        
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
- (void)addControllersInVisibleRange:(NSRange)range
{
    // preload page +1 view
    NSInteger endIndex = range.location + range.length;
    for (NSInteger idx = range.location ; idx < endIndex; ++idx) {
        
        UIViewController *viewController = [_visibleControllers objectForKey:@(idx)];
        
        if (!viewController) {
            viewController = [_memoryCache objectForKey:@(idx)];
        }
        
        if (!viewController) {
            viewController = [_dataSource pagerController:self controllerForIndex:idx];
        }
        
        [self addViewController:viewController atIndex:idx];
    }
}

- (void)addViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    if (!viewController.parentViewController) {
        //NSLog(@"addViewController index %ld",index);
        [self addChildViewController:viewController];
        viewController.view.frame = frameForControllerAtIndex(index, _contentView.frame);
        [_contentView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
        if (![_visibleControllers objectForKey:@(index)]) {
            [_visibleControllers setObject:viewController forKey:@(index)];
        }
    }else {
        viewController.view.frame = frameForControllerAtIndex(index, _contentView.frame);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _contentView) {
        if ([self isProgressScrollEnabel] && !_needLayoutContentView) {
            // 计算scroll progress
            [self configurePagerIndexByProgress];
        }
        
        if (!_needLayoutContentView) {
            // 计算scroll index
            [self configurePagerIndex];
        }
        
        [self layoutContentView];
        
        _isTapScrollMoved = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _contentView) {
        
        _preOffsetX = scrollView.contentOffset.x;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_memoryCache removeAllObjects];
    [_visibleControllers removeAllObjects];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
