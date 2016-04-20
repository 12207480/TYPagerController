//
//  ViewController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "TYPagerController.h"

@interface ViewController ()<TYPagerControllerDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addPagerController];
}

- (void)addPagerController
{
    TYPagerController *VC = [[TYPagerController alloc]init];
    VC.dataSource = self;
    [self addChildViewController:VC];
    VC.view.frame = self.view.bounds;
    [self.view addSubview:VC.view];
}

- (NSInteger)numberOfControllersInPagerController
{
    return 30;
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(CGFloat)index
{
    UIViewController *VC = [[UIViewController alloc]init];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    label.center = VC.view.center;
    label.text = [@(index) stringValue];
    label.font = [UIFont systemFontOfSize:32];
    label.textAlignment = NSTextAlignmentCenter;
    [VC.view addSubview:label];
    VC.view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:arc4random()%255/255.0];
    return VC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
