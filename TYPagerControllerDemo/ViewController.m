//
//  ViewController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "TYPagerController.h"
#import "CustomViewController.h"

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
    CustomViewController *VC = [[CustomViewController alloc]init];
    VC.text = [@(index) stringValue];
    return VC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
