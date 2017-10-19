//
//  TYTabPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 2017/7/18.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTabPagerController.h"

@interface TYTabPagerController ()<TYTabPagerBarDataSource,TYTabPagerBarDelegate,TYPagerControllerDataSource,TYPagerControllerDelegate>

// UI
@property (nonatomic, strong) TYTabPagerBar *tabBar;
@property (nonatomic, strong) TYPagerController *pagerController;

// Data
@property (nonatomic, strong) NSString *identifier;

@end

#define kTabBarOrignY -999999

@implementation TYTabPagerController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _tabBarHeight = 36;
        _tabBarOrignY = kTabBarOrignY;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tabBarHeight = 36;
        _tabBarOrignY = kTabBarOrignY;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    [self addTabBar];
    
    [self addPagerController];
}

- (void)addTabBar {
    self.tabBar.dataSource = self;
    self.tabBar.delegate = self;
    [self registerClass:[TYTabPagerBarCell class] forTabBarCellWithReuseIdentifier:[TYTabPagerBarCell cellIdentifier]];
    [self.view addSubview:self.tabBar];;
}

- (void)addPagerController {
    self.pagerController.dataSource = self;
    self.pagerController.delegate = self;
    [self addChildViewController:self.pagerController];
    [self.view addSubview:self.pagerController.view];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat orignY = [self fixedTabBarOriginY];
    self.tabBar.frame = CGRectMake(0, orignY, CGRectGetWidth(self.view.frame), _tabBarHeight);
    self.pagerController.view.frame = CGRectMake(0, orignY+_tabBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - _tabBarHeight-orignY);
}

- (CGFloat)fixedTabBarOriginY {
    if (_tabBarOrignY > kTabBarOrignY) {
        return _tabBarOrignY;
    }
    if (!self.navigationController || self.parentViewController != self.navigationController) {
        return 0;
    }
    if (self.navigationController.navigationBarHidden || !(self.edgesForExtendedLayout&UIRectEdgeTop)) {
        return 0;
    }
    return CGRectGetMaxY(self.navigationController.navigationBar.frame);
}

#pragma mark - getter setter

- (TYTabPagerBar *)tabBar {
    if (!_tabBar) {
        _tabBar = [[TYTabPagerBar alloc]init];
    }
    return _tabBar;
}

- (void)setTabBarOrignY:(CGFloat)tabBarOrignY {
    BOOL isChangeValue = _tabBarOrignY != tabBarOrignY;
    _tabBarOrignY = tabBarOrignY;
    if (isChangeValue && _tabBar.superview) {
        [self.view layoutIfNeeded];
    }
}

- (void)setTabBarHeight:(CGFloat)tabBarHeight {
    BOOL isChangeValue = _tabBarHeight != tabBarHeight;
    _tabBarHeight = tabBarHeight;
    if (isChangeValue && _tabBar.superview) {
        [self.view layoutIfNeeded];
    }
}

- (TYPagerController *)pagerController {
    if (!_pagerController) {
        _pagerController = [[TYPagerController alloc]init];
        _pagerController.layout.prefetchItemCount = 1;
    }
    return _pagerController;
}

- (TYPagerViewLayout<UIViewController *> *)layout {
    return self.pagerController.layout;
}

#pragma mark - public

- (void)updateData {
    [self.tabBar reloadData];
    [self.pagerController updateData];
}

- (void)reloadData {
    [self.tabBar reloadData];
    [self.pagerController reloadData];
}

- (void)scrollToControllerAtIndex:(NSInteger)index animate:(BOOL)animate {
    [self.pagerController scrollToControllerAtIndex:index animate:animate];
}

- (void)registerClass:(Class)Class forTabBarCellWithReuseIdentifier:(NSString *)identifier {
    _identifier = identifier;
    [self.tabBar registerClass:Class forCellWithReuseIdentifier:identifier];
}
- (void)registerNib:(UINib *)nib forTabBarCellWithReuseIdentifier:(NSString *)identifier {
    _identifier = identifier;
    [self.tabBar registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (void)registerClass:(Class)Class forPagerCellWithReuseIdentifier:(NSString *)identifier {
    [_pagerController registerClass:Class forControllerWithReuseIdentifier:identifier];
}
- (void)registerNib:(UINib *)nib forPagerCellWithReuseIdentifier:(NSString *)identifier {
    [_pagerController registerNib:nib forControllerWithReuseIdentifier:identifier];
}
- (UIViewController *)dequeueReusablePagerCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    return [_pagerController dequeueReusableControllerWithReuseIdentifier:identifier forIndex:index];
}

#pragma mark - TYTabPagerBarDataSource

- (NSInteger)numberOfItemsInPagerTabBar {
    return [_dataSource numberOfControllersInTabPagerController];
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)pagerTabBar:(TYTabPagerBar *)pagerTabBar cellForItemAtIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [pagerTabBar dequeueReusableCellWithReuseIdentifier:_identifier forIndex:index];
    cell.titleLabel.text = [_dataSource tabPagerController:self titleForIndex:index];
    if ([_delegate respondsToSelector:@selector(tabPagerController:willDisplayCell:atIndex:)]) {
        [_delegate tabPagerController:self willDisplayCell:cell atIndex:index];
    }
    return cell;
}

#pragma mark - TYTabPagerBarDelegate

- (CGFloat)pagerTabBar:(TYTabPagerBar *)pagerTabBar widthForItemAtIndex:(NSInteger)index {
    NSString *title = [_dataSource tabPagerController:self titleForIndex:index];
    return [pagerTabBar cellWidthForTitle:title];
}

- (void)pagerTabBar:(TYTabPagerBar *)pagerTabBar didSelectItemAtIndex:(NSInteger)index {
    [_pagerController scrollToControllerAtIndex:index animate:YES];
    if ([_delegate respondsToSelector:@selector(tabPagerController:didSelectTabBarItemAtIndex:)]) {
        [_delegate tabPagerController:self didSelectTabBarItemAtIndex:index];
    }
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController {
    return [_dataSource numberOfControllersInTabPagerController];
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    UIViewController *viewController = [_dataSource tabPagerController:self controllerForIndex:index prefetching:prefetching];
    return viewController;
}

#pragma mark - TYPagerControllerDelegate

- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated {
    [self.tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex animate:animated];
}

-(void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    [self.tabBar scrollToItemFromIndex:fromIndex toIndex:toIndex progress:progress];
}

- (void)pagerControllerWillBeginScrolling:(TYPagerController *)pagerController animate:(BOOL)animate {
    if ([_delegate respondsToSelector:@selector(tabPagerControllerWillBeginScrolling:animate:)]) {
        [_delegate tabPagerControllerWillBeginScrolling:self animate:animate];
    }
}
- (void)pagerControllerDidEndScrolling:(TYPagerController *)pagerController animate:(BOOL)animate {
    if ([_delegate respondsToSelector:@selector(tabPagerControllerDidEndScrolling:animate:)]) {
        [_delegate tabPagerControllerDidEndScrolling:self animate:animate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
