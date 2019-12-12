//
//  ViewController.m
//  TYPagerControllerDemo
//
//  Created by tany on 2017/7/6.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "ViewController.h"
#import "PagerViewDmeoController.h"
#import "PagerControllerDmeoController.h"
#import "TabPagerControllerDemoController.h"
#import "TabPagerViewDmeoController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

#pragma mark - action

- (IBAction)turnToPageViewDemo:(id)sender {
    PagerViewDmeoController *vc = [[PagerViewDmeoController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)turnToTabPagerViewDemo:(id)sender {
    TabPagerViewDmeoController *vc = [[TabPagerViewDmeoController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)turnToPageControllerDemo:(id)sender {
    PagerControllerDmeoController *pagerController = [[PagerControllerDmeoController alloc]init];
    [self.navigationController pushViewController:pagerController animated:YES];
}

- (IBAction)turnToTabPagerControllerDemo:(id)sender {
    TabPagerControllerDemoController *pagerController = [[TabPagerControllerDemoController alloc]init];
    //pagerController.pagerController.layout.prefetchItemCount = 1;
    [self.navigationController pushViewController:pagerController animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
