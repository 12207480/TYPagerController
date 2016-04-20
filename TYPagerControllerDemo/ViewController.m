//
//  ViewController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "CustomPagerController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addPagerController];
}

- (void)addPagerController
{
    CustomPagerController *VC = [[CustomPagerController alloc]init];
    [self addChildViewController:VC];
    VC.view.frame = self.view.bounds;
    [self.view addSubview:VC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
