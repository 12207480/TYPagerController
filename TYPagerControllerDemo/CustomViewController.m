//
//  CustomViewController.m
//  TYPagerControllerDemo
//
//  Created by tany on 16/4/20.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "CustomViewController.h"
#import "PagerControllerDmeoController.h"

@interface CustomViewController ()
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIButton *pushBtn;
@property (nonatomic, weak) UIButton *cancelBtn;
@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"text %@",_text);
    [self addPageLabel];
    [self addPushButton];
    [self addPopButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _label.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
     _cancelBtn.center = CGPointMake(_label.center.x,_label.center.y + 100);
    _pushBtn.center = CGPointMake(_label.center.x,_label.center.y + 50);
}

- (void)addPageLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    label.text = _text;
    label.font = [UIFont systemFontOfSize:32];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    _label = label;
    self.view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:arc4random()%255/255.0];
}

- (void)addPushButton
{
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:21];
    [cancelBtn setTitle:@"posh VC" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(pushVC) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(0, 0, 100, 40);
    cancelBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 60);
    [self.view addSubview:cancelBtn];
    _pushBtn = cancelBtn;
}

- (void)addPopButton
{
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:21];
    [cancelBtn setTitle:@"pop back" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(0, 0, 100, 40);
    cancelBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 60);
    [self.view addSubview:cancelBtn];
    _cancelBtn = cancelBtn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear index %@",_text);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewDidAppear index %@",_text);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear index %@",_text);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewDidDisappear index %@",_text);
}


- (void)pushVC {
    PagerControllerDmeoController *vc = [[PagerControllerDmeoController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
