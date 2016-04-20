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

@end

@implementation TYPagerController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    _curIndex = -1;
}

#pragma mark - layout content
- (void)layoutContentViewIfNeed
{
    if (!CGSizeEqualToSize(_contentView.frame.size, CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _topEdging))) {
         _countOfControllers = [_dataSource numberOfControllersInPagerController];
        // size changed
        [self reSizeContentView];
        
        [self layoutContentView];
    }
}

- (void)reSizeContentView
{
    _contentView.frame = CGRectMake(0, _topEdging, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _topEdging);
    _contentView.contentSize = CGSizeMake(_countOfControllers * CGRectGetWidth(_contentView.frame), 0);
}

- (void)layoutContentView
{
    NSInteger curIndex = _contentView.contentOffset.x/CGRectGetWidth(_contentView.frame);
    
    if (curIndex == _curIndex) {
        return;
    }
    NSLog(@"cur index %ld count %ld",curIndex,self.childViewControllers.count);
    _curIndex = curIndex;
    
    [self removeUnVisibleControllersWithOffset:_contentView.contentOffset.x];
    
    [self addVisibleControllersWithOffset:_contentView.contentOffset.x];
}

#pragma mark - remove controller
- (void)removeUnVisibleControllersWithOffset:(CGFloat)offset
{
    // preload page view
    CGFloat maxOffset = offset + 2 * CGRectGetWidth(_contentView.frame);
    maxOffset = MIN(maxOffset, _countOfControllers*CGRectGetWidth(_contentView.frame));
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        NSInteger index = CGRectGetMinX(viewController.view.frame)/CGRectGetWidth(_contentView.frame);
        index = MIN(index, _countOfControllers-1);
        if (CGRectGetMinX(viewController.view.frame)< offset || CGRectGetMaxX(viewController.view.frame) > maxOffset) {
            // unvisible
            [self removeViewController:viewController atIndex:index];
        }else {
            [self addViewController:viewController atIndex:index];
        }
    }];
}

- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    if (viewController.parentViewController) {
        NSLog(@"removeViewController index %ld",index);
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
    
    if (![_memoryCache objectForKey:@(index)]) {
        [_memoryCache setObject:viewController forKey:@(index)];
    }
}

#pragma mark - add controller
- (void)addVisibleControllersWithOffset:(CGFloat)offset
{
    // preload page +1 view
    NSInteger startIndex = offset/CGRectGetWidth(_contentView.frame);
    NSInteger endIndex = MIN(_countOfControllers-1, startIndex+1) ;
    for (NSInteger idx = startIndex ; idx <= endIndex; ++idx) {
        
        UIViewController *viewController = [_memoryCache objectForKey:@(idx)];
        
        if (!viewController) {
            viewController = [_dataSource pagerController:self controllerForIndex:idx];
        }
        
        [self addViewController:viewController atIndex:idx];
    }
}

- (void)addViewController:(UIViewController *)viewController atIndex:(NSInteger)index
{
    if (!viewController.parentViewController) {
        NSLog(@"addViewController index %ld",index);
        [self addChildViewController:viewController];
        viewController.view.frame = [self frameForControllerAtIndex:index];
        [_contentView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }else {
        viewController.view.frame = [self frameForControllerAtIndex:index];
    }
    
    if (![_memoryCache objectForKey:@(index)]) {
        [_memoryCache setObject:viewController forKey:@(index)];
    }
}

- (CGRect)frameForControllerAtIndex:(NSInteger)index
{
    return CGRectMake(index * CGRectGetWidth(_contentView.frame), 0, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame));
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self layoutContentView];
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidEndDecelerating");
//    [self layoutContentView];
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidEndScrollingAnimation");
//    [self layoutContentView];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_memoryCache removeAllObjects];
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
