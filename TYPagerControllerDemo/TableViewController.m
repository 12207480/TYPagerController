//
//  TableViewController.m
//  TYPagerControllerDemo
//
//  Created by tany on 16/5/17.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TableViewController.h"
#import "TYTabButtonPagerController.h"
#import "ViewController.h"
#import "CustomPagerController.h"
#import "CustomViewController.h"
#import "ListViewController.h"
#import "CollectionViewController.h"

@interface TableViewController ()<TYPagerControllerDataSource>
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"TYPagerController Demo";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    _dataArray = @[@"pagerController",@"可变 渐变1 pagerController",@"可变 渐变2 pagerController",@"可变 渐变1 带导航 pagerController",@"可变 渐变2 带导航 pagerController",@"可变 渐变1 customPagerController",@"可变 渐变2 customPagerController",@"可变 渐变1 带导航 customPagerController",@"可变 渐变2 带导航 customPagerController"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    
    cell.textLabel.text = _dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TYPagerController *VC = [[TYPagerController alloc]init];
        VC.dataSource = self;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.row <= 2) {
        ViewController *VC = [[ViewController alloc]init];
        VC.variable = indexPath.row-1;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.row <= 4) {
        ViewController *VC = [[ViewController alloc]init];
        VC.variable = indexPath.row-1;
        VC.showNavBar = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.row <= 6) {
        CustomPagerController *VC = [[CustomPagerController alloc]init];
        VC.barStyle = (indexPath.row-1)%2 ? TYPagerBarStyleCoverView:TYPagerBarStyleProgressView;
        VC.variable = (indexPath.row-1)%2;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.row <= 8) {
        CustomPagerController *VC = [[CustomPagerController alloc]init];
        VC.barStyle = (indexPath.row-1)%2 ? TYPagerBarStyleCoverView:TYPagerBarStyleNoneView;
        VC.variable = (indexPath.row-1)%2;
        VC.showNavBar = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController
{
    return 30;
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index
{
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

@end
