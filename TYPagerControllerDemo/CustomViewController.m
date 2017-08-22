//
//  CustomViewController.m
//  TYPagerControllerDemo
//
//  Created by tany on 16/4/20.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "CustomViewController.h"
#import "TestPushViewController.h"

@interface CustomViewController ()
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, weak) UIButton *pushBtn;
@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"text %@",_text);
    [self addPageLabel];
    
    [self addButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _label.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
     _cancelBtn.center = CGPointMake(_label.center.x,_label.center.y + 100);
     _pushBtn.center = CGPointMake(_label.center.x,_label.center.y + 200);
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

- (void)addButton
{
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:21];
    [cancelBtn setTitle:@"pop back" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(0, 0, 100, 40);
    cancelBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 60);
    [self.view addSubview:cancelBtn];
    _cancelBtn = cancelBtn;
    
    //Push another view controller
    UIButton *pushBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pushBtn.titleLabel.font = [UIFont systemFontOfSize:21];
    [pushBtn setTitle:@"push another controller" forState:UIControlStateNormal];
    [pushBtn addTarget:self action:@selector(pushAnotherController) forControlEvents:UIControlEventTouchUpInside];
    pushBtn.frame = CGRectMake(0, 0, 100, 40);
    pushBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 160);
    [self.view addSubview:pushBtn];
    _pushBtn = pushBtn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear index %@",_text);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear index %@",_text);
}

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushAnotherController {
    TestPushViewController *pushCon = [[TestPushViewController alloc] init];
    [self.navigationController pushViewController:pushCon animated:YES];
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
