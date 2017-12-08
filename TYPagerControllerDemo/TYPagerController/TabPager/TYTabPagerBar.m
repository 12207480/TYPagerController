//
//  TYTabPagerBar.m
//  TYPagerControllerDemo
//
//  Created by tany on 2017/7/13.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTabPagerBar.h"

@interface TYTabPagerBar ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    struct {
        unsigned int transitionFromeCellAnimated :1;
        unsigned int transitionFromeCellProgress :1;
        unsigned int widthForItemAtIndex :1;
    }_delegateFlags;
    TYTabPagerBarLayout *_layout;
}

// UI
@property (nonatomic, weak) UICollectionView *collectionView;

// Data

@property (nonatomic, assign) NSInteger countOfItems;

@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, assign) BOOL isFirstLayout;
@property (nonatomic, assign) BOOL didLayoutSubViews;

@end

@implementation TYTabPagerBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _isFirstLayout = YES;
        _didLayoutSubViews = NO;
        _autoScrollItemToCenter = YES;
        self.backgroundColor = [UIColor clearColor];
        [self addFixAutoAdjustInsetScrollView];
        [self addCollectionView];
        [self addUnderLineView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _isFirstLayout = YES;
        _didLayoutSubViews = NO;
        _autoScrollItemToCenter = YES;
        self.backgroundColor = [UIColor clearColor];
        [self addFixAutoAdjustInsetScrollView];
        [self addCollectionView];
        [self addUnderLineView];
    }
    return self;
}

- (void)addFixAutoAdjustInsetScrollView {
    UIView *view = [[UIView alloc]init];
    [self addSubview:view];
}

- (void)addCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:UIEdgeInsetsInsetRect(self.bounds, _contentInset) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    if ([collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        collectionView.prefetchingEnabled = NO;
    }
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)addUnderLineView {
     UIView *progressView = [[UIView alloc]init];
    progressView.backgroundColor = [UIColor redColor];
    [_collectionView addSubview:progressView];
    _progressView = progressView;
}

#pragma mark - getter setter

- (void)setProgressView:(UIView *)progressView {
    if (_progressView == progressView) {
        return;
    }
    if (_progressView) {
        [_progressView removeFromSuperview];
    }
    if (_layout && _layout.barStyle == TYPagerBarStyleCoverView) {
        progressView.layer.zPosition = -1;
        [_collectionView insertSubview: progressView atIndex:0];
    }else {
        [_collectionView addSubview:progressView];
    }
    if (_layout && self.superview) {
        [_layout layoutSubViews];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (_backgroundView) {
        [_backgroundView removeFromSuperview];
    }
    _backgroundView = backgroundView;
    backgroundView.frame = self.bounds;
    [self insertSubview:backgroundView atIndex:0];
}

- (void)setDelegate:(id<TYTabPagerBarDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.transitionFromeCellAnimated = [delegate respondsToSelector:@selector(pagerTabBar:transitionFromeCell:toCell:animated:)];
    _delegateFlags.transitionFromeCellProgress = [delegate respondsToSelector:@selector(pagerTabBar:transitionFromeCell:toCell:progress:)];
    _delegateFlags.widthForItemAtIndex = [delegate respondsToSelector:@selector(pagerTabBar:widthForItemAtIndex:)];
}

- (void)setLayout:(TYTabPagerBarLayout *)layout {
    BOOL updateLayout = _layout && _layout != layout;
    _layout = layout;
    if (updateLayout) {
        [self reloadData];
    }
}

- (TYTabPagerBarLayout *)layout {
    if (!_layout) {
        _layout = [[TYTabPagerBarLayout alloc]initWithPagerTabBar:self];
    }
    return _layout;
}

#pragma mark - public

- (void)reloadData {
    _countOfItems = [_dataSource numberOfItemsInPagerTabBar];
    if (_curIndex >= _countOfItems) {
        _curIndex = _countOfItems - 1;
    }
    if ([_delegate respondsToSelector:@selector(pagerTabBar:configureLayout:)]) {
        [_delegate pagerTabBar:self configureLayout:self.layout];
    }
    [self.layout layoutIfNeed];
    [_collectionView reloadData];
    [self.layout adjustContentCellsCenterInBar];
    [self.layout layoutSubViews];
}

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerClass:Class forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell<TYTabPagerBarCellProtocol> *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell;
}

- (CGRect)cellFrameWithIndex:(NSInteger)index
{
    if (index >= _countOfItems) {
        return CGRectZero;
    }
    UICollectionViewLayoutAttributes * cellAttrs = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (!cellAttrs) {
        return CGRectZero;
    }
    return cellAttrs.frame;
}

- (UICollectionViewCell<TYTabPagerBarCellProtocol> *)cellForIndex:(NSInteger)index
{
    if (index >= _countOfItems) {
        return nil;
    }
    return (UICollectionViewCell<TYTabPagerBarCellProtocol> *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (void)scrollToItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animate:(BOOL)animate {
    if (toIndex < _countOfItems && toIndex >= 0 && fromIndex < _countOfItems && fromIndex >= 0) {
        _curIndex = toIndex;
        [self transitionFromIndex:fromIndex toIndex:toIndex animated:animate];
        if (_autoScrollItemToCenter) {
            if (!_didLayoutSubViews) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scrollToItemAtIndex:toIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animate];
                });
            }else {
                [self scrollToItemAtIndex:toIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animate];
            }
        }
    }
}

- (void)scrollToItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    if (toIndex < _countOfItems && toIndex >= 0 && fromIndex < _countOfItems && fromIndex >= 0) {
        [self transitionFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
}

- (void)scrollToItemAtIndex:(NSInteger)index atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated {
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:scrollPosition animated:animated];
}

- (CGFloat)cellWidthForTitle:(NSString *)title {
    if (!title) {
        return CGSizeZero.width;
    }
    //iOS 7
    CGRect frame = [title boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName:self.layout.selectedTextFont} context:nil];
    return CGSizeMake(ceil(frame.size.width), ceil(frame.size.height) + 1).width;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    _countOfItems = [_dataSource numberOfItemsInPagerTabBar];
    return _countOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell<TYTabPagerBarCellProtocol> *cell = [_dataSource pagerTabBar:self cellForItemAtIndex:indexPath.item];
    [self.layout transitionFromCell:(indexPath.item == _curIndex ? nil : cell) toCell:(indexPath.item == _curIndex ? cell : nil) animate:NO];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(pagerTabBar:didSelectItemAtIndex:)]) {
        [_delegate pagerTabBar:self didSelectItemAtIndex:indexPath.item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.layout.cellWidth > 0) {
        return CGSizeMake(self.layout.cellWidth+self.layout.cellEdging*2, CGRectGetHeight(_collectionView.frame));
    }else if(_delegateFlags.widthForItemAtIndex){
        CGFloat width = [_delegate pagerTabBar:self widthForItemAtIndex:indexPath.item]+self.layout.cellEdging*2;
        return CGSizeMake(width, CGRectGetHeight(_collectionView.frame));
    }else {
        NSAssert(NO, @"you must return cell width!");
    }
    return CGSizeZero;
}

#pragma mark - transition cell

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated
{
    UICollectionViewCell<TYTabPagerBarCellProtocol> *fromCell = [self cellForIndex:fromIndex];
    UICollectionViewCell<TYTabPagerBarCellProtocol> *toCell = [self cellForIndex:toIndex];
    if (_delegateFlags.transitionFromeCellAnimated) {
        [_delegate pagerTabBar:self transitionFromeCell:fromCell toCell:toCell animated:animated];
    }else {
        [self.layout transitionFromCell:fromCell toCell:toCell animate:animated];
    }
    [self.layout setUnderLineFrameWithIndex:toIndex animated:fromCell && animated ? animated: NO];
}

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    UICollectionViewCell<TYTabPagerBarCellProtocol> *fromCell = [self cellForIndex:fromIndex];
    UICollectionViewCell<TYTabPagerBarCellProtocol> *toCell = [self cellForIndex:toIndex];
    if (_delegateFlags.transitionFromeCellProgress) {
        [_delegate pagerTabBar:self transitionFromeCell:fromCell toCell:toCell progress:progress];
    }else {
        [self.layout transitionFromCell:fromCell toCell:toCell progress:progress];
    }
    [self.layout setUnderLineFrameWithfromIndex:fromIndex toIndex:toIndex progress:progress];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _backgroundView.frame = self.bounds;
    CGRect frame = UIEdgeInsetsInsetRect(self.bounds, _contentInset);
    BOOL needUpdateLayout = (frame.size.height > 0 && _collectionView.frame.size.height != frame.size.height) || (frame.size.width > 0 && _collectionView.frame.size.width != frame.size.width);
    _collectionView.frame = frame;
    if (!_didLayoutSubViews && !CGRectIsEmpty(_collectionView.frame)) {
        _didLayoutSubViews = YES;
    }
    if (needUpdateLayout) {
        [_layout invalidateLayout];
    }
    if (frame.size.height > 0 && frame.size.width > 0) {
        [_layout adjustContentCellsCenterInBar];
    }
    _isFirstLayout = NO;
    [_layout layoutSubViews];
}

- (void)dealloc {
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

@end
