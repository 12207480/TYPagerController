# TYPagerController
page View controller,simple,high custom,and have tabBar styles.

## ScreenShot
####TYPagerBarStyle

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

// pagerController count
- (NSInteger)numberOfControllersInPagerController;

// pagerController at index
- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index;

@optional

// pagerController title
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

// transition frome cell to cell animated
- (void)pagerController:(TYTabPagerController *)pagerController transitionFromeCell:(UICollectionViewCell *)fromCell toCell:(UICollectionViewCell *)toCell animated:(BOOL)animated;

// transition frome cell to cell progress
- (void)pagerController:(TYTabPagerController *)pagerController transitionFromeCell:(UICollectionViewCell *)fromCell toCell:(UICollectionViewCell *)toCell progress:(CGFloat)progress;

@end
```
##Usage Demo

* **第一种方法**

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
    
    if (_showNavBar) {
        pagerController.progressWidth = _variable ? 0 : 36;
    }
    
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

* **第二种方法**

```objc
@interface CustomPagerController : TYTabButtonPagerController

@end

@implementation CustomPagerController

- (void)viewDidLoad {
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
