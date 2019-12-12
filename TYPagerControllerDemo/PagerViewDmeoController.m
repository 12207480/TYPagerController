//
//  PagerViewDmeoController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 2017/7/6.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "PagerViewDmeoController.h"
#import "TYPagerView.h"
#import "TYTabPagerBar.h"

@interface PagerViewDmeoController ()<TYPagerViewDataSource, TYPagerViewDelegate,TYTabPagerBarDataSource,TYTabPagerBarDelegate>
@property (nonatomic, weak) TYTabPagerBar *tabBar;
@property (nonatomic, weak) TYPagerView *pageView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation PagerViewDmeoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc]initWithTitle:@"reload" style:UIBarButtonItemStylePlain target:self action:@selector(reloadData)];
    UIBarButtonItem *scrollItem = [[UIBarButtonItem alloc]initWithTitle:@"update" style:UIBarButtonItemStylePlain target:self action:@selector(updateData)];
    self.navigationItem.rightBarButtonItems = @[reloadItem,scrollItem];
    [self addPagerTabBar];
    [self addPagerView];
    
    [self loadData];
}

- (void)addPagerTabBar {
    TYTabPagerBar *tabBar = [[TYTabPagerBar alloc]init];
    tabBar.layout.barStyle = TYPagerBarStyleProgressElasticView;
    tabBar.dataSource = self;
    tabBar.delegate = self;
    [tabBar registerClass:[TYTabPagerBarCell class] forCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
    [self.view addSubview:tabBar];
    _tabBar = tabBar;
}

- (void)addPagerView {
    TYPagerView *pageView = [[TYPagerView alloc]init];
    //pageView.layout.progressAnimateEnabel = NO;
    //pageView.layout.prefetchItemCount = 1;
    pageView.layout.autoMemoryCache = NO;
    pageView.dataSource = self;
    pageView.delegate = self;
    // you can rigsiter cell like tableView
    [pageView.layout registerClass:[UIView class] forItemWithReuseIdentifier:@"cellId"];
    [self.view addSubview:pageView];
    _pageView = pageView;
}

- (void)loadData {
    NSMutableArray *datas = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; ++i) {
        [datas addObject:i%2 == 0 ? [NSString stringWithFormat:@"Tab %ld",i]:[NSString stringWithFormat:@"Tab Tab %ld",i]];
    }
    _datas = [datas copy];
    
    [self reloadData];
}

- (void)updateData {
    NSMutableArray *datas = [NSMutableArray array];
    for (NSInteger i = 0; i <arc4random()%26+1; ++i) {
        [datas addObject:i%2 == 0 ? [NSString stringWithFormat:@"Tab %ld",i]:[NSString stringWithFormat:@"Tab Tab %ld",i]];
    }
    _datas = [datas copy];
    
    [_tabBar reloadData];
    [_pageView updateData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _tabBar.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame), 36);
    _pageView.frame = CGRectMake(0, CGRectGetMaxY(_tabBar.frame), CGRectGetWidth(self.view.frame), 300);
}

- (void)reloadData {
    [_tabBar reloadData];
    [_pageView reloadData];
}


#pragma mark - TYTabPagerBarDataSource

- (NSInteger)numberOfItemsInPagerTabBar {
    return _datas.count;
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier] forIndex:index];
    cell.titleLabel.text = _datas[index];
    return cell;
}

#pragma mark - TYTabPagerBarDelegate

- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = _datas[index];
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [_pageView scrollToViewAtIndex:index animate:YES];
}

#pragma mark - TYPagerViewDataSource

- (NSInteger)numberOfViewsInPagerView {
    return _datas.count;
}

- (UIView *)pagerView:(TYPagerView *)pagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    //you can set UIView *view = [[UIView alloc]initWithFrame:[pagerView.layout frameForItemAtIndex:index]]; or UIView *view = [[UIView alloc]init];
    //or reigster and dequeue item like tableView
    UIView *view = [pagerView.layout dequeueReusableItemWithReuseIdentifier:@"cellId" forIndex:index];
    view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:arc4random()%255/255.0];
    //NSLog(@"viewForIndex:%ld prefetching:%d",index,prefetching);
    return view;
}

#pragma mark - TYPagerViewDelegate

- (void)pagerView:(TYPagerView *)pagerView willAppearView:(UIView *)view forIndex:(NSInteger)index {
    //NSLog(@"+++++++++willAppearViewIndex:%ld",index);
}

- (void)pagerView:(TYPagerView *)pagerView willDisappearView:(UIView *)view forIndex:(NSInteger)index {
    //NSLog(@"---------willDisappearView:%ld",index);
}

- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    NSLog(@"fromIndex:%ld, toIndex:%ld",fromIndex,toIndex);
    [_tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex animate:animated];
}

- (void)pagerView:(TYPagerView *)pagerView transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    //NSLog(@"fromIndex:%ld, toIndex:%ld progress%.3f",fromIndex,toIndex,progress);
    [_tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex progress:progress];
}

- (void)pagerViewWillBeginScrolling:(TYPagerView *)pageView animate:(BOOL)animate {
    //NSLog(@"pagerViewWillBeginScrolling");
}

- (void)pagerViewDidEndScrolling:(TYPagerView *)pageView animate:(BOOL)animate {
    //NSLog(@"pagerViewDidEndScrolling");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
