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

