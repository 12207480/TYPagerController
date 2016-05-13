//
//  ViewController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/4/13.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "ViewController.h"
#import "TYTabButtonPagerController.h"
#import "CustomViewController.h"

@interface ViewController ()<TYPagerControllerDataSource>
@property (nonatomic, strong) TYTabButtonPagerController *pagerController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self addPagerController];
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc]initWithTitle:@"reload" style:UIBarButtonItemStylePlain target:_pagerController action:@selector(reloadData)];
    UIBarButtonItem *scrollItem = [[UIBarButtonItem alloc]initWithTitle:@"scroll" style:UIBarButtonItemStylePlain target:self action:@selector(scrollToRamdomIndex)];
    self.navigationItem.rightBarButtonItems = @[reloadItem,scrollItem];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _pagerController.view.frame = self.view.bounds;
}

- (void)addPagerController
{
    TYTabButtonPagerController *pagerController = [[TYTabButtonPagerController alloc]init];
    pagerController.dataSource = self;
    //pagerController.cellWidth = 56;
    pagerController.cellSpacing = 8;
    pagerController.view.frame = self.view.bounds;
    [self addChildViewController:pagerController];
    [self.view addSubview:pagerController.view];
    _pagerController = pagerController;
}

- (void)scrollToRamdomIndex
{
    [_pagerController moveToControllerAtIndex:arc4random()%30 animated:NO];
}

- (NSInteger)numberOfControllersInPagerController
{
    return 30;
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index
{
    CustomViewController *VC = [[CustomViewController alloc]init];
    VC.text = [@(index) stringValue];
    return VC;
}

- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index
{
    return index %2 == 0 ? [NSString stringWithFormat:@"Tab %ld",index]:[NSString stringWithFormat:@"Tab Tab %ld",index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
