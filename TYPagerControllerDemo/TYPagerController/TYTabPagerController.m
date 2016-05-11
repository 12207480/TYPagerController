//
//  TYTabPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/5/3.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYTabPagerController.h"

@interface TYTabPagerController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    struct {
        unsigned int titleForIndex :1;
    }_tabDataSourceFlags;
    
    struct {
        unsigned int configreReusableCell :1;
        unsigned int transitionFromeCellAnimated :1;
        unsigned int transitionFromeCellProgress :1;
    }_tabDelegateFlags;
}

// views
@property (nonatomic, weak) UIView *pagerBarView;
@property (nonatomic, weak) UICollectionView *collectionViewBar;
@property (nonatomic, weak) UIView *progressView;

@property (nonatomic ,assign) Class cellClass;
@property (nonatomic ,assign) BOOL cellContainXib;
@property (nonatomic ,strong) NSString *cellId;

@end

#define kCollectionViewBarHieght 36
#define kUnderLineViewHeight 2

@implementation TYTabPagerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        [self configireInitPropertys];
    }
    return self;
}

- (void)configireInitPropertys
{
    self.changeIndexWhenScrollProgress = 1.0;
    _animateDuration = 0.25;
    
    _normalTextFont = [UIFont systemFontOfSize:15];
    _selectedTextFont = [UIFont systemFontOfSize:20];
    
    _cellSpacing = 0;
    _cellEdging = 3;
    
    _progressHeight = kUnderLineViewHeight;
    _progressEdging = 3;
    _progressBounces = YES;
    
    self.contentTopEdging = kCollectionViewBarHieght;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addPagerBarView];
    
    [self addCollectionViewBar];
    
    [self addUnderLineView];
}

- (void)addPagerBarView
{
    UIView *pagerBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.contentTopEdging)];
    [self.view addSubview:pagerBarView];
    _pagerBarView = pagerBarView;
}

- (void)addCollectionViewBar
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = _cellSpacing;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.contentTopEdging) collectionViewLayout:layout];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [_pagerBarView addSubview:collectionView];
    _collectionViewBar = collectionView;
    
    if (_cellContainXib) {
        UINib *nib = [UINib nibWithNibName:_cellId bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:_cellId];
    }else {
        [collectionView registerClass:_cellClass forCellWithReuseIdentifier:_cellId];
    }
}

- (void)addUnderLineView
{
    UIView *underLineView = [[UIView alloc]init];
    [_collectionViewBar addSubview:underLineView];
    _progressView = underLineView;
}

- (void)setDelegate:(id<TYTabPagerControllerDelegate>)delegate
{
    [super setDelegate:delegate];
    _tabDelegateFlags.configreReusableCell = [self.delegate respondsToSelector:@selector(pagerController:configreCell:forItemTitle:atIndexPath:)];
    _tabDelegateFlags.transitionFromeCellAnimated = [self.delegate respondsToSelector:@selector(pagerController:transitionFromeCell:toCell:animated:)];
    _tabDelegateFlags.transitionFromeCellProgress = [self.delegate respondsToSelector:@selector(pagerController:transitionFromeCell:toCell:progress:)];
}

- (void)setDataSource:(id<TYPagerControllerDataSource>)dataSource
{
    [super setDataSource:dataSource];
    _tabDataSourceFlags.titleForIndex = [self.dataSource respondsToSelector:@selector(pagerController:titleForIndex:)];
    NSAssert(_tabDataSourceFlags.titleForIndex, @"TYPagerControllerDataSource pagerController:titleForIndex: not impletement!");
}

#pragma mark - public

- (void)reloadData
{    
    [_collectionViewBar reloadData];
    
    [super reloadData];
}

- (void)updateContentView
{
    [super updateContentView];
    
    [self updateTabPagerView];
    
    [self setUnderLineFrameWithIndex:self.curIndex animated:NO];
    
    [self tabScrollToIndex:self.curIndex animated:NO];
}

- (void)registerCellClass:(Class)cellClass isContainXib:(BOOL)isContainXib
{
    _cellClass = cellClass;
    _cellId = NSStringFromClass(cellClass);
    _cellContainXib = isContainXib;
}

- (CGRect)cellFrameWithIndex:(NSInteger)index
{
    UICollectionViewLayoutAttributes * cellAttrs = [_collectionViewBar layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cellAttrs.frame;
}

- (UICollectionViewCell *)cellForIndex:(NSInteger)index
{
    return [_collectionViewBar cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (void)tabScrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    [_collectionViewBar scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

#pragma mark - private

- (void)updateTabPagerView
{
    CGFloat statusHeight = self.navigationController.isNavigationBarHidden ? 20:0;
    _pagerBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.contentTopEdging+statusHeight);
    _collectionViewBar.frame = CGRectMake(0, statusHeight, CGRectGetWidth(self.view.frame), self.contentTopEdging);
}

- (void)setUnderLineFrameWithIndex:(NSInteger)index animated:(BOOL)animated
{
    if (_progressView.isHidden) {
        return;
    }
    CGRect cellFrame = [self cellFrameWithIndex:index];
    CGFloat progressEdging = _progressEdging;
    if (animated) {
        [UIView animateWithDuration:_animateDuration animations:^{
            _progressView.frame = CGRectMake(cellFrame.origin.x+progressEdging, cellFrame.size.height - _progressHeight, cellFrame.size.width-2*progressEdging, _progressHeight);
        }];
    }else {
        _progressView.frame = CGRectMake(cellFrame.origin.x+progressEdging, cellFrame.size.height - _progressHeight, cellFrame.size.width-2*progressEdging, _progressHeight);
    }
}

- (void)setUnderLineFrameWithfromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    if (_progressView.isHidden) {
        return;
    }
    CGRect fromCellFrame = [self cellFrameWithIndex:fromIndex];
    CGRect toCellFrame = [self cellFrameWithIndex:toIndex];
    
    CGFloat progressEdging = _progressEdging;
    CGFloat progressX, width;
    
    if (_progressBounces) {
        if (fromCellFrame.origin.x < toCellFrame.origin.x) {
            if (progress <= 0.5) {
                progressX = fromCellFrame.origin.x + progressEdging;
                width = (toCellFrame.size.width+_cellSpacing)*2*progress + fromCellFrame.size.width-2*progressEdging;
            }else {
                progressX = fromCellFrame.origin.x + progressEdging + (fromCellFrame.size.width+_cellSpacing)*(progress-0.5)*2;
                width = CGRectGetMaxX(toCellFrame)-progressEdging - progressX;
            }
        }else {
            if (progress <= 0.5) {
                progressX = fromCellFrame.origin.x + progressEdging - (toCellFrame.size.width+_cellSpacing)*2*progress;
                width = CGRectGetMaxX(fromCellFrame) - progressEdging - progressX;
            }else {
                progressX = toCellFrame.origin.x + progressEdging;
                width = (fromCellFrame.size.width + _cellSpacing)*(1-progress)*2 + toCellFrame.size.width - 2*progressEdging;
            }
        }
    }else {
        progressX = (toCellFrame.origin.x-fromCellFrame.origin.x)*progress+fromCellFrame.origin.x+progressEdging;
        width = (toCellFrame.size.width-2*progressEdging)*progress + (fromCellFrame.size.width-2*progressEdging)*(1-progress);//toCellFrame.size.width;
    }
    
    _progressView.frame = CGRectMake(progressX, toCellFrame.size.height - _progressHeight, width, _progressHeight);
}

#pragma mark - override transition

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated
{
    UICollectionViewCell *fromCell = [self cellForIndex:fromIndex];
    UICollectionViewCell *toCell = [self cellForIndex:toIndex];
    
    if (![self isProgressScrollEnabel]) {
        
        if (_tabDelegateFlags.transitionFromeCellAnimated) {
            [self.delegate pagerController:self transitionFromeCell:fromCell toCell:toCell animated:animated];
        }
        
        [self setUnderLineFrameWithIndex:toIndex animated:fromCell && animated ? animated: NO];
    }

    [self tabScrollToIndex:toIndex animated:toCell ? YES : fromCell && animated ? animated: NO];
}

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    UICollectionViewCell *fromCell = [self cellForIndex:fromIndex];
    UICollectionViewCell *toCell = [self cellForIndex:toIndex];
    
    if (_tabDelegateFlags.transitionFromeCellProgress) {
        [self.delegate pagerController:self transitionFromeCell:fromCell toCell:toCell progress:progress];
    }
    
    [self setUnderLineFrameWithfromIndex:fromIndex toIndex:toIndex progress:progress];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource numberOfControllersInPagerController];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellId forIndexPath:indexPath];
    
    if (_tabDataSourceFlags.titleForIndex) {
        NSString *title = [self.dataSource pagerController:self titleForIndex:indexPath.item];
        if (_tabDelegateFlags.configreReusableCell) {
            [self.delegate pagerController:self configreCell:cell forItemTitle:title atIndexPath:indexPath];
        }
        if (_tabDelegateFlags.transitionFromeCellAnimated) {
            [self.delegate pagerController:self transitionFromeCell:(indexPath.item == self.curIndex ? nil : cell) toCell:(indexPath.item == self.curIndex ? cell : nil) animated:NO];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self moveToControllerAtIndex:indexPath.item animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_cellWidth > 0) {
        return CGSizeMake(_cellWidth, CGRectGetHeight(_collectionViewBar.frame));
    }else if(_tabDataSourceFlags.titleForIndex){
        NSString *title = [self.dataSource pagerController:self titleForIndex:indexPath.item];
        CGFloat width = [self boundingSizeWithString:title font:_selectedTextFont constrainedToSize:CGSizeMake(200, 200)].width+_cellEdging*2;
        return CGSizeMake(width, CGRectGetHeight(_collectionViewBar.frame));
    }
    return CGSizeZero;
}

// text size
- (CGSize)boundingSizeWithString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize textSize = CGSizeZero;
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED && __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0)
    
    if (![string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        // below ios7
        textSize = [string sizeWithFont:font
                    constrainedToSize:size
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
    else
#endif
    {
        //iOS 7
        CGRect frame = [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName:font } context:nil];
        textSize = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    
    return textSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
