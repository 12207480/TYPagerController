//
//  TabPagerViewDmeoController.m
//  TYPagerControllerDemo
//
//  Created by tany on 2017/7/19.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TabPagerViewDmeoController.h"
#import "TYTabPagerView.h"

@interface TabPagerViewDmeoController ()<TYTabPagerViewDataSource, TYTabPagerViewDelegate>

@property (nonatomic, weak) TYTabPagerView *pagerView;

@property (nonatomic, strong) NSArray *datas;

@end

@implementation TabPagerViewDmeoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"TabPagerViewDmeoController";
    self.view.backgroundColor = [UIColor whiteColor];
    [self addTabPagerView];
    
    [self loadData];
}

- (void)addTabPagerView {
    TYTabPagerView *pagerView = [[TYTabPagerView alloc]init];
    pagerView.tabBar.layout.barStyle = TYPagerBarStyleCoverView;
    pagerView.tabBar.progressView.backgroundColor = [UIColor lightGrayColor];
    pagerView.dataSource = self;
    pagerView.delegate = self;
    [self.view addSubview:pagerView];
    _pagerView = pagerView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _pagerView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.navigationController.navigationBar.frame));
}

- (void)loadData {
    NSMutableArray *datas = [NSMutableArray array];
    for (NSInteger i = 0; i < 20; ++i) {
        [datas addObject:i%2 == 0 ? [NSString stringWithFormat:@"Tab %ld",i]:[NSString stringWithFormat:@"Tab Tab %ld",i]];
    }
    _datas = [datas copy];
    
    [_pagerView reloadData];
    //[_pagerView scrollToViewAtIndex:1 animate:YES];
}


#pragma mark - TYTabPagerViewDataSource

- (NSInteger)numberOfViewsInTabPagerView {
    return _datas.count;
}

- (UIView *)tabPagerView:(TYTabPagerView *)tabPagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    UIView *view = [[UIView alloc]initWithFrame:[tabPagerView.layout frameForItemAtIndex:index]];
    view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:arc4random()%255/255.0];
    //NSLog(@"viewForIndex:%ld prefetching:%d",index,prefetching);
    return view;
}

- (NSString *)tabPagerView:(TYTabPagerView *)tabPagerView titleForIndex:(NSInteger)index {
    NSString *title = _datas[index];
    return title;
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
