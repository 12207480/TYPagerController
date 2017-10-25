//
//  PagerControllerDemoController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 2017/7/18.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TabPagerControllerDemoController.h"
#import "CustomViewController.h"
#import "ListViewController.h"
#import "CollectionViewController.h"

@interface TabPagerControllerDemoController ()<TYTabPagerControllerDataSource,TYTabPagerControllerDelegate>

@property (nonatomic, strong) NSArray *datas;

@end

@implementation TabPagerControllerDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"TabPagerControllerDemoController";
    self.tabBarHeight = 50;
    self.tabBar.layout.barStyle = TYPagerBarStyleProgressView;
    self.tabBar.layout.adjustContentCellsCenter = YES;
    self.dataSource = self;
    self.delegate = self;
    
    [self loadData];
}

- (void)loadData {
    NSMutableArray *datas = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; ++i) {
        [datas addObject:i%2 == 0 ? [NSString stringWithFormat:@"Tab %ld",i]:[NSString stringWithFormat:@"Tab Tab %ld",i]];
    }
    _datas = [datas copy];
    
    [self reloadData];
    [self scrollToControllerAtIndex:1 animate:YES];
}

#pragma mark - TYTabPagerControllerDataSource

- (NSInteger)numberOfControllersInTabPagerController {
    return _datas.count;
}

- (UIViewController *)tabPagerController:(TYTabPagerController *)tabPagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    if (index%3 == 0) {
        CustomViewController *VC = [[CustomViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }else if (index%3 == 1) {
        ListViewController *VC = [[ListViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }else {
        CollectionViewController *VC = [[CollectionViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }
}

- (NSString *)tabPagerController:(TYTabPagerController *)tabPagerController titleForIndex:(NSInteger)index {
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
