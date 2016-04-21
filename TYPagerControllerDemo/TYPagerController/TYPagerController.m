//
//  TYPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYPagerController.h"

@interface TYPagerController ()<UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *contentView;

@property (nonatomic, strong) NSMutableDictionary *visibleControllers;

@property (nonatomic, strong) NSCache *memoryCache;

@property (nonatomic, assign) NSInteger countOfControllers;

@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, assign) NSRange visibleRange;

@property (nonatomic, assign) BOOL needLayoutContentView;

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

    [self configirePropertys];
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

- (void)configirePropertys
{
    _visibleControllers = [NSMutableDictionary dictionary];
    _memoryCache = [[NSCache alloc]init];
    _curIndex = 0;
}

- (void)resetPropertys
{
    [_memoryCache removeAllObjects];
    [_visibleControllers removeAllObjects];
    
    for (UIViewController *viewController in self.childViewControllers) {
        [self removeViewController:viewController];
    }
    
    _curIndex = 0;
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
        [self updateContentView];
    }
}

- (void)updateContentView
{
    _needLayoutContentView = YES;
    _countOfControllers = [_dataSource numberOfControllersInPagerController];
    // size changed
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
    // 获取可见range
    NSRange visibleRange = visibleRangWithOffset(_contentView.contentOffset.x, CGRectGetWidth(_contentView.frame), _countOfControllers);

    if (NSEqualRanges(_visibleRange, visibleRange) && !_needLayoutContentView) {
        return;
    }
    //NSLog(@"visibleRange %@",NSStringFromRange(visibleRange));
    _needLayoutContentView = NO;
    _visibleRange = visibleRange;
    _curIndex = _visibleRange.location;
    
    [self removeUnVisibleControllersOutOfRange:_visibleRange];
    
    [self addVisibleControllersOutOfRange:_visibleRange];
    
    //NSLog(@"cur index %ld count %ld",_curIndex,self.childViewControllers.count);
    
}

- (NSRange)getVisibleRangWithVisibleOrignX:(CGFloat)visibleOrignX visibleEndX:(CGFloat)visibleEndX
{
    NSInteger startIndex = visibleOrignX/CGRectGetWidth(_contentView.frame);
    
    NSInteger endIndex = ceil(visibleEndX/CGRectGetWidth(_contentView.frame));
    if (startIndex < 0) {
        startIndex = 0;
    }
    if (endIndex > _countOfControllers) {
        endIndex = _countOfControllers;
    }
    return NSMakeRange(startIndex, endIndex - startIndex);
}

#pragma mark - remove controller
- (void)removeUnVisibleControllersOutOfRange:(NSRange)range
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
- (void)addVisibleControllersOutOfRange:(NSRange)range
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
