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

@interface TableViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"TYPagerController Demo";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    _dataArray = @[@"可变 渐变1 pagerController",@"可变 渐变2 pagerController",@"可变 渐变1 带导航 pagerController",@"可变 渐变2 带导航 pagerController",@"可变 渐变1 customPagerController",@"可变 渐变2 customPagerController",@"可变 渐变1 带导航 customPagerController",@"可变 渐变2 带导航 customPagerController"];
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
    if (indexPath.row <= 1) {
        ViewController *VC = [[ViewController alloc]init];
        VC.variable = indexPath.row;
        VC.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.row <= 3) {
        ViewController *VC = [[ViewController alloc]init];
        VC.variable = indexPath.row;
        VC.showNavBar = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.row <= 5) {
        CustomPagerController *VC = [[CustomPagerController alloc]init];
        VC.barStyle = indexPath.row%2 ? TYPagerBarStyleCoverView:TYPagerBarStyleProgressView;
        VC.variable = indexPath.row%2;
        VC.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.row <= 7) {
        CustomPagerController *VC = [[CustomPagerController alloc]init];
        VC.barStyle = indexPath.row%2 ? TYPagerBarStyleCoverView:TYPagerBarStyleNoneView;
        VC.variable = indexPath.row%2;
        VC.showNavBar = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
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
