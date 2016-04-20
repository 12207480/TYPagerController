//
//  CustomPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/19.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "CustomPagerController.h"

@interface CustomPagerController ()<TYPagerControllerDataSource>

@end

@implementation CustomPagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;
}

- (NSInteger)numberOfControllersInPagerController{
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
