# TYPagerController v2.0
TYPagerController 简单，强大，高度定制，页面控制器,水平滚动内容和标题栏,包含多种barStyle。<br>
TYPagerController v2.0 重构优化代码，分离出TYPagerViewLayout布局类,添加更多功能，更加强大。<br>
如果还想使用以前的版本可以查看分支v1.0.6 和 pod 'TYPagerController', '~> 1.0.6' <br>

* TYPagerViewLayout 水平滚动页面的layout类，只需要initWithScrollView:即可实现水平滚动页面.
* TYPagerView 包含TYPagerViewLayout的水平滚动页面View
* TYPagerController 包含TYPagerViewLayout的水平滚动页面Controller。
* TYTabPagerBar Pager的标题 tabBar
* TYTabPagerView 包含TabBar的TYPagerView
* TYTabPagerController 包含TabBar的TYPagerController

注意：获取数据后必须调用reloadData.<br>
更详细的使用请看[LovePlayNews](https://github.com/12207480/LovePlayNews)项目

## CocoaPods
```
pod 'TYPagerController'
```

## Requirements
* Xcode 7 or higher
* iOS 7.0 or higher
* ARC

## ScreenShot
### TYPagerBarStyle

New TYPagerBarStyleProgressElasticView<br>
![image](https://github.com/12207480/TYPagerController/blob/master/ScreenShot/TYPagerController6.gif)

1 TYPagerBarStyleProgressBounceView<br>
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController1.gif)

2 TYPagerBarStyleProgressView<br>
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController2.gif)

3 TYPagerBarStyleCoverView<br>
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController3.gif)
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController7.gif)

4 TYPagerBarStyleNoneView<br>
![image](https://raw.githubusercontent.com/12207480/TYPagerController/master/ScreenShot/TYPagerController4.gif)

## API

### Class
* TYPagerViewLayout
```objc
@interface TYPagerViewLayout<__covariant ItemType> : NSObject

@property (nonatomic, weak, nullable) id<TYPagerViewLayoutDataSource> dataSource;
@property (nonatomic, weak, nullable) id<TYPagerViewLayoutDelegate> delegate;

// strong,will control the delegate,don't set delegate on other place.
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
// if viewcontroller's automaticallyAdjustsScrollViewInsets YES ,will cause frame problems, you can set YES, default YES
@property (nonatomic, assign) BOOL adjustScrollViewInset;

@property (nonatomic, assign, readonly) NSInteger countOfPagerItems;
@property (nonatomic, assign, readonly) NSInteger curIndex;// default -1

@property (nonatomic, strong, readonly) NSCache<NSNumber *,ItemType> *memoryCache;; // will cache pagerView,you can set countLimit
@property (nonatomic, assign) BOOL autoMemoryCache; // default YES

@property (nonatomic, assign) NSInteger prefetchItemCount;// preload left and right item's count , default 0

@property (nonatomic, assign, readonly) NSRange prefetchRange;
@property (nonatomic, assign, readonly) NSRange visibleRange;

@property (nonatomic, strong, nullable, readonly) NSArray<NSNumber *> * visibleIndexs;
@property (nonatomic, strong, nullable, readonly) NSArray<ItemType> * visibleItems;

// default YES, if NO,will not call delegate transitionFromIndex:toIndex:progress:,but will call transitionFromIndex:toIndex:
@property (nonatomic, assign) BOOL progressAnimateEnabel;

// default NO, when scroll visible range change will add item.If YES add item only when scroll animate end, suggest set prefetchItemCount 1 or more
@property (nonatomic, assign) BOOL addVisibleItemOnlyWhenScrollAnimatedEnd;

// default 0.5,when scroll progress percent will change index, only progressAnimateEnabel is NO or don't implement delegate transitionFromIndex: toIndex: progress:
@property (nonatomic, assign) CGFloat changeIndexWhenScrollProgress;
```
* TYPagerView
```objc
@interface TYPagerView : UIView

@property (nonatomic, weak, nullable) id<TYPagerViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<TYPagerViewDelegate> delegate;
// pagerView's layout,don't set layout's dataSource to other
@property (nonatomic, strong, readonly) TYPagerViewLayout<UIView *> *layout;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, assign, readonly) NSInteger countOfPagerViews;
@property (nonatomic, assign, readonly) NSInteger curIndex;// default -1

@property (nonatomic, assign, nullable, readonly) NSArray<UIView *> *visibleViews;

@property (nonatomic, assign) UIEdgeInsets contentInset;

//if not visible, prefecth, cache view at index, return nil
- (UIView *_Nullable)viewForIndex:(NSInteger)index;

// register && dequeue's usage like tableView
- (void)registerClass:(Class)Class forViewWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forViewWithReuseIdentifier:(NSString *)identifier;
- (UIView *)dequeueReusableViewWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

// scroll to index
- (void)scrollToViewAtIndex:(NSInteger)index animate:(BOOL)animate;

// update data and layout,but don't reset propertys(curIndex,visibleDatas,prefechDatas)
- (void)updateData;

// reload data and reset propertys
- (void)reloadData;
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
* TYPagerController
```objc
@interface TYPagerController : UIViewController

@property (nonatomic, weak, nullable) id<TYPagerControllerDataSource> dataSource;
@property (nonatomic, weak, nullable) id<TYPagerControllerDelegate>   delegate;
// pagerController's layout,don't set layout's dataSource to other
@property (nonatomic, strong, readonly) TYPagerViewLayout<UIViewController *> *layout;
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

@property (nonatomic, assign, readonly) NSInteger countOfControllers;
@property (nonatomic, assign, readonly) NSInteger curIndex;// default -1

@property (nonatomic, strong, nullable, readonly) NSArray<UIViewController *> *visibleControllers;

@property (nonatomic, assign) UIEdgeInsets contentInset;

//if not visible, prefecth, cache view at index, return nil
- (UIViewController *_Nullable)controllerForIndex:(NSInteger)index;

// register && dequeue's usage like tableView
- (void)registerClass:(Class)Class forControllerWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forControllerWithReuseIdentifier:(NSString *)identifier;
- (UIViewController *)dequeueReusableControllerWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

// scroll to index
- (void)scrollToControllerAtIndex:(NSInteger)index animate:(BOOL)animate;

//  update data and layout,but don't reset propertys(curIndex,visibleDatas,prefechDatas)
- (void)updateData;

// reload data and reset propertys
- (void)reloadData;
```

##Usage Demo
* TYTabPagerView
```objc
- (void)addTabPagerView {
    TYTabPagerView *pagerView = [[TYTabPagerView alloc]init];
    pagerView.tabBar.layout.barStyle = TYPagerBarStyleCoverView;
    pagerView.tabBar.progressView.backgroundColor = [UIColor lightGrayColor];
    pagerView.dataSource = self;
    pagerView.delegate = self;
    [self.view addSubview:pagerView];
    _pagerView = pagerView;
}

#pragma mark - TYTabPagerViewDataSource

- (NSInteger)numberOfViewsInTabPagerView {
    return _datas.count;
}

- (UIView *)tabPagerView:(TYTabPagerView *)tabPagerView viewForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
    UIView *view = [[UIView alloc]initWithFrame:[tabPagerView.layout frameForItemAtIndex:index]];
    view.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:arc4random()%255/255.0];
    //NSLog(@"viewForIndex:%ld prefetching:%d",index,prefetching);
    return view;
}

- (NSString *)tabPagerView:(TYTabPagerView *)tabPagerView titleForIndex:(NSInteger)index {
    NSString *title = _datas[index];
    return title;
}
```

* TYTabPagerController
```objc
@interface TabPagerControllerDemoController : TYTabPagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"TabPagerControllerDemoController";
    self.tabBar.layout.barStyle = TYPagerBarStyleProgressView;
    self.dataSource = self;
    self.delegate = self;
    
    [self loadData];
}

- (void)loadData {
    _datas = [datas copy];
    // must call reloadData
    [self reloadData];
}

#pragma mark - TYTabPagerControllerDataSource

- (NSInteger)numberOfControllersInTabPagerController {
    return _datas.count;
}

- (UIViewController *)tabPagerController:(TYTabPagerController *)tabPagerController controllerForIndex:(NSInteger)index prefetching:(BOOL)prefetching {
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

- (NSString *)tabPagerController:(TYTabPagerController *)tabPagerController titleForIndex:(NSInteger)index {
    NSString *title = _datas[index];
    return title;
}
```


更多的使用方法 请查看 demo。

### Contact
如果你发现bug，please pull reqeust me <br>
如果你有更好的改进，please pull reqeust me <br>
