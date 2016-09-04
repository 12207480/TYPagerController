# TYPagerController
page View controller,simple,high custom,and have tabBar styles.<br>
TYPagerController 简单，支持定制，页面控制器,可以滚动内容和标题栏,包含多种style

* TYPagerController 水平滚动页面控制器，不包含任何其他的控件（TabBar），contentTopEdging 为距离top的高度。
* TYTabPagerController 包含TabBar（我帮你创建了Tabbar），contentTopEdging为TabBar的高度，调用registerCellClass 注册cell（遵守TYTabTitleCellProtocol），然后在代理方法里改变cell。
* TYTabButtonPagerController 同上，默认注册了TYTabTitleViewCell

## CocoaPods
```
pod 'TYPagerController'
```

## Requirements
* Xcode 5 or higher
* iOS 6.0 or higher
* ARC

## ScreenShot
####TYPagerBarStyle

New TYPagerBarStyleProgressElasticView<br>
![image](https://github.com/12207480/TYPagerController/blob/master/ScreenShot/TYPagerController6.gif)

1 TYPagerBarStyleProgressBounceView<br>
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController1.gif)

2 TYPagerBarStyleProgressView<br>
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController2.gif)

3 TYPagerBarStyleCoverView<br>
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController3.gif)

4 TYPagerBarStyleNoneView<br>
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController4.gif)

![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController5.gif)

## Datasource and delegate

```objc
@protocol TYPagerControllerDataSource <NSObject>

// viewController count in pagerController
- (NSInteger)numberOfControllersInPagerController;

// viewController at index in pagerController
- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index;

@optional

// viewController title in pagerController
- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index;

@end
```
```objc
@protocol TYPagerControllerDelegate <NSObject>

@optional

// transition from index to index with animated
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)formIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated;

// transition from index to index with progress
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)formIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end
```
```objc
@protocol TYTabPagerControllerDelegate <TYPagerControllerDelegate>

// configre collectionview cell
- (void)pagerController:(TYTabPagerController *)pagerController configreCell:(UICollectionViewCell *)cell forItemTitle:(NSString *)title atIndexPath:(NSIndexPath *)indexPath;

// transition frome cell to cell with animated
- (void)pagerController:(TYTabPagerController *)pagerController transitionFromeCell:(UICollectionViewCell *)fromCell toCell:(UICollectionViewCell *)toCell animated:(BOOL)animated;

// transition frome cell to cell with progress
- (void)pagerController:(TYTabPagerController *)pagerController transitionFromeCell:(UICollectionViewCell *)fromCell toCell:(UICollectionViewCell *)toCell progress:(CGFloat)progress;

@end
```
##Usage Demo

if you want to add coustom TabBar, you can inherit TYPagerController，and set contentTopEdging,else  you can inherit TYTabPagerController or TYTabButtonPagerController,set contentTopEdging(TabBar height) and custom cell(conform TYTabTitleCellProtocol), call registerCellClass, change cell on delegate.<br>

如果你想自己添加TabBar，你可以继承TYPagerController 然后设置 contentTopEdging ，留出高度添加TabBar,你也可以 直接继承 TYTabPagerController或者TYTabButtonPagerController 设置contentTopEdging(TabBar height) ，我帮你创建了Tabbar,你只要调用registerCellClass 注册cell（遵守TYTabTitleCellProtocol），然后在代理方法里改变cell。<br>

关于默认index，可以再viewdidload中调用<br>
```objc
 // 默认第2页 注意：pagerController 默认自动调用reloadData的时机，是在viewWillAppear和viewWillLayoutSubviews 而viewDidLoad至此之前，所以需要手动调用reloadData
[_pagerController reloadData];
 [_pagerController moveToControllerAtIndex:1 animated:NO];
```
更多的使用方法 请查看 demo。

* **first method**

```objc
// add pagerController
- (void)addPagerController
{
    TYTabButtonPagerController *pagerController = [[TYTabButtonPagerController alloc]init];
    pagerController.dataSource = self;
    pagerController.adjustStatusBarHeight = YES;
    //pagerController.cellWidth = 56;
    pagerController.cellSpacing = 8;
    pagerController.barStyle = _variable ? TYPagerBarStyleProgressBounceView: TYPagerBarStyleProgressView;
    
    pagerController.view.frame = self.view.bounds;
    [self addChildViewController:pagerController];
    [self.view addSubview:pagerController.view];
    _pagerController = pagerController;
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController
{
    return 30;
}

- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index
{
    return index %2 == 0 ? [NSString stringWithFormat:@"Tab %ld",index]:[NSString stringWithFormat:@"Tab Tab %ld",index];
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index
{
    if (index%3 == 0) {
        CustomViewController *VC = [[CustomViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }else if (index%3 == 1) {
         ListViewController *VC = [[ListViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }else {
        CollectionViewController *VC = [[CollectionViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }
}

```

* **second method**

```objc
@interface CustomPagerController : TYTabButtonPagerController

@end

@implementation CustomPagerController

- (void)viewDidLoad {
   // set bar style will reset progress propertys, set it behind [super viewdidload]
    self.barStyle = TYPagerBarStyleProgressBounceView;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.adjustStatusBarHeight = YES;
    self.cellSpacing = 8;
}

#pragma mark - TYPagerControllerDataSource

- (NSInteger)numberOfControllersInPagerController
{
    return 30;
}

- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index
{
    return index %2 == 0 ? [NSString stringWithFormat:@"Tab %ld",index]:[NSString stringWithFormat:@"Tab Tab %ld",index];
}

- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index
{
    if (index%3 == 0) {
        CustomViewController *VC = [[CustomViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }else if (index%3 == 1) {
        ListViewController *VC = [[ListViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }else {
        CollectionViewController *VC = [[CollectionViewController alloc]init];
        VC.text = [@(index) stringValue];
        return VC;
    }
}

@end

```
### Contact
如果你发现bug，please pull reqeust me <br>
如果你有更好的改进，please pull reqeust me <br>
如果你有更好的想法或者建议可以联系我，Email:122074809@qq.com
