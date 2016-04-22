//
//  TYPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYPagerController.h"

@interface TYPagerController ()<UIScrollViewDelegate> {
    NSInteger   _countOfControllers;
    BOOL        _needLayoutContentView;
    CGFloat     _preOffsetX;
    
    struct {
        unsigned int transitionFromIndexToIndex :1;
    }_delegateFlags;
}

@property (nonatomic, weak) UIScrollView *contentView;

@property (nonatomic, strong) NSMutableDictionary *visibleControllers;

@property (nonatomic, strong) NSCache *memoryCache;

@property (nonatomic, assign) NSInteger curIndex;

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

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
    _memoryCache = [[NSCache alloc]init];
    _curIndex = 0;
    _preOffsetX = 0;
    _changeIndexWhenScrollProgress = 1.0;

    [self configureDelegate];
}

- (void)resetPropertys
{
    [_memoryCache removeAllObjects];
    [_visibleControllers removeAllObjects];
    
    for (UIViewController *viewController in self.childViewControllers) {
        [self removeViewController:viewController];
    }
    
    _curIndex = 0;
    _preOffsetX = 0;
    
    [self configureDelegate];
}

- (void)configureDelegate
{
    _delegateFlags.transitionFromIndexToIndex = [_delegate respondsToSelector:@selector(pagerController:transitionFromIndex:toIndex:)];
}

#pragma mark - public method

- (void)reloadData
{
    [self resetPropertys];
    
    [self updateContentView];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index < 0 || index >= _countOfControllers) {
        return;
    }
    [_contentView setContentOffset:CGPointMake(index * CGRectGetWidth(_contentView.frame),0) animated:animated];
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
    //NSLog(@"visibleRange %@",NSStringFromRange(visibleRange));
    _needLayoutContentView = NO;
    _visibleRange = visibleRange;
    _preOffsetX = _curIndex*CGRectGetWidth(_contentView.frame);
    
    [self removeControllersOutOfVisibleRange:_visibleRange];
    
    [self addControllersInVisibleRange:_visibleRange];
    
    //NSLog(@"cur index %ld count %ld",_curIndex,self.childViewControllers.count);
    
}

- (void)configurePagerIndex
{
    CGFloat offsetX = _contentView.contentOffset.x;
    CGFloat width = CGRectGetWidth(_contentView.frame);
    CGFloat percentChangeIndex = 1.0-_changeIndexWhenScrollProgress;
    NSInteger index = 0;
    
    if (offsetX >= _preOffsetX) {
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
        [self transitionFromIndex:fromIndex toIndex:_curIndex];
        if (_delegateFlags.transitionFromIndexToIndex) {
            [_delegate pagerController:self transitionFromIndex:fromIndex toIndex:_curIndex];
        }
    }
}

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSLog(@"formIndex %ld toIndex:%ld",fromIndex,toIndex);
}

- (void)transitionFromIndex:(NSInteger)formIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    
}

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
    [self configurePagerIndex];
    
    [self layoutContentView];
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
