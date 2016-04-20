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

@property (nonatomic, assign) BOOL needLayoutContentView;

@end

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

#pragma mark - public method

- (void)reloadData
{
    [_memoryCache removeAllObjects];
    [_visibleControllers removeAllObjects];
    _curIndex = 0;
    
    [self updateContentView];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (index < 0 || index >= _countOfControllers) {
        return;
    }
    [_contentView setContentOffset:CGPointMake(index * CGRectGetWidth(_contentView.frame),0) animated:animated];
}

#pragma mark - layout content

- (void)layoutContentViewIfNeed
{
    if (!CGSizeEqualToSize(_contentView.frame.size, CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _topEdging))) {
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
    _contentView.frame = CGRectMake(0, _topEdging, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _topEdging);
    _contentView.contentSize = CGSizeMake(_countOfControllers * CGRectGetWidth(_contentView.frame), 0);
    _contentView.contentOffset = CGPointMake(MAX(_curIndex, 0)*CGRectGetWidth(_contentView.frame), 0);
}

- (void)layoutContentView
{
    NSInteger curIndex = _contentView.contentOffset.x/CGRectGetWidth(_contentView.frame);
    
    if (curIndex < 0) {
        curIndex = 0;
    }else if(curIndex >= _countOfControllers){
        curIndex = _countOfControllers - 1;
    }
    if (curIndex == _curIndex && !_needLayoutContentView) {
        return;
    }
    _needLayoutContentView = NO;
    _curIndex = curIndex;
    //NSLog(@"cur index %ld count %ld",curIndex,self.childViewControllers.count);
    
    [self removeUnVisibleControllersAtIndex:curIndex];
    
    [self addVisibleControllersAtIndex:curIndex];
}

#pragma mark - remove controller
- (void)removeUnVisibleControllersAtIndex:(NSInteger)index
{
    NSMutableArray *deleteArray = [NSMutableArray array];
    [_visibleControllers enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UIViewController *viewController, BOOL * stop) {
        NSInteger indexOfController = [key integerValue];
        
        if (indexOfController < index || indexOfController > index+1) {
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
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        
        if (![_memoryCache objectForKey:@(index)]) {
            [_memoryCache setObject:viewController forKey:@(index)];
        }
    }
}

#pragma mark - add controller
- (void)addVisibleControllersAtIndex:(NSInteger)index
{
    // preload page +1 view
    NSInteger endIndex = MIN(index+1,_countOfControllers-1);
    for (NSInteger idx = index ; idx <= endIndex; ++idx) {
        
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
        viewController.view.frame = [self frameForControllerAtIndex:index];
        [_contentView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
        if (![_visibleControllers objectForKey:@(index)]) {
            [_visibleControllers setObject:viewController forKey:@(index)];
        }
    }else {
        viewController.view.frame = [self frameForControllerAtIndex:index];
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
