//
//  TYTabPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/5/3.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYTabPagerController.h"
#import "TYTabTitleViewCell.h"

@interface TYTabPagerController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    struct {
        unsigned int titleForIndex :1;
    }_dataSuorceFlags;
    
    CGFloat _selectFontScale;
}
@property (nonatomic, weak) UICollectionView *collectionViewBar;
@property (nonatomic, weak) UIView *underLineView;
@end

#define kCollectionViewBarHieght 36
#define kUnderLineViewHeight 2

static NSString *const cellId = @"TYTabTitleViewCell";

@implementation TYTabPagerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        [self configireInitPropertys];
        
        [self configureTransitionBlocks];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addCollectionViewBar];
    
    [self addUnderLineView];
    
    [self configurePagerData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _collectionViewBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.contentTopEdging);
    [self setUnderLineFrameWithIndex:self.curIndex animated:NO];
}

- (void)addCollectionViewBar
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.contentTopEdging) collectionViewLayout:layout];
    collectionView.backgroundColor = _pagerBarColor;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [self.view addSubview:collectionView];
    _collectionViewBar = collectionView;
    
    [collectionView registerClass:[TYTabTitleViewCell class] forCellWithReuseIdentifier:cellId];
}

- (void)addUnderLineView
{
    UIView *underLineView = [[UIView alloc]init];
    underLineView.hidden = _progressViewHiden;
    underLineView.backgroundColor = _progressColor;
    if (_progressRadius > 0) {
        underLineView.layer.cornerRadius = _progressRadius;
        underLineView.layer.masksToBounds = YES;
    }
    [_collectionViewBar addSubview:underLineView];
    _underLineView = underLineView;
}

- (void)reloadData
{
    [super reloadData];
    
    [self configurePagerData];
    
    [_collectionViewBar reloadData];
    [_collectionViewBar setContentOffset:CGPointZero];
    
    [self setUnderLineFrameWithIndex:self.curIndex animated:NO];
}

#pragma mark - private

- (void)configireInitPropertys
{
    _pagerBarColor = [UIColor whiteColor];
    _normalTextFont = [UIFont systemFontOfSize:15];
    _selectedTextFont = [UIFont systemFontOfSize:18];
    _normalTextColor = [UIColor darkTextColor];
    _selectedTextColor = [UIColor redColor];
    _progressColor = [UIColor redColor];
    _progressRadius = 1;
    _progressViewHiden = NO;
    _animateDuration = 0.25;
    _progressHeight = kUnderLineViewHeight;
    self.contentTopEdging = kCollectionViewBarHieght;
}

- (void)configureTransitionBlocks
{
    __weak typeof(self) weakSelf = self;
    
    [self setTransitionCellAnimatedBlock:^(UICollectionViewCell *fromCell, UICollectionViewCell *toCell, BOOL animated) {
        if (animated) {
            [UIView animateWithDuration:weakSelf.animateDuration animations:^{
                [weakSelf transitionFromCell:(TYTabTitleViewCell *)fromCell toCell:(TYTabTitleViewCell *)toCell];
            }];
        }else{
            [weakSelf transitionFromCell:(TYTabTitleViewCell *)fromCell toCell:(TYTabTitleViewCell *)toCell];
        }
    }];
    
    [self setTransitionCellProgressBlock:^(UICollectionViewCell *fromCell, UICollectionViewCell *toCell, CGFloat progress) {
        [weakSelf transitionFromCell:(TYTabTitleViewCell *)fromCell toCell:(TYTabTitleViewCell *)toCell progress:progress];
    }];
    
    [self setConfigreCellForItemBlock:^(UICollectionViewCell *cell, NSString *title,NSIndexPath *indexPath) {
        TYTabTitleViewCell *titleCell = (TYTabTitleViewCell *)cell;
        titleCell.titleLabel.text = title;
        titleCell.titleLabel.font = weakSelf.normalTextFont;
    }];
}

- (void)configurePagerData
{
    _selectFontScale = _selectedTextFont.pointSize/_normalTextFont.pointSize;
    
    _dataSuorceFlags.titleForIndex = [self.dataSource respondsToSelector:@selector(pagerController:titleForIndex:)];
    NSAssert(_dataSuorceFlags.titleForIndex, @"TYPagerControllerDataSource pagerController:titleForIndex: not impletement!");
}

- (CGRect)cellFrameWithIndex:(NSInteger)index
{
    UICollectionViewLayoutAttributes * cellAttrs = [_collectionViewBar layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cellAttrs.frame;
}

- (TYTabTitleViewCell *)cellForIndex:(NSInteger)index
{
    return (TYTabTitleViewCell *)[_collectionViewBar cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    [_collectionViewBar scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

- (void)setUnderLineFrameWithIndex:(NSInteger)index animated:(BOOL)animated
{
    if (_progressViewHiden) {
        return;
    }
    CGRect cellFrame = [self cellFrameWithIndex:index];
    if (animated) {
        [UIView animateWithDuration:_animateDuration animations:^{
            _underLineView.frame = CGRectMake(cellFrame.origin.x, cellFrame.size.height - _progressHeight, cellFrame.size.width, _progressHeight);
        }];
    }else {
        _underLineView.frame = CGRectMake(cellFrame.origin.x, cellFrame.size.height - _progressHeight, cellFrame.size.width, _progressHeight);
    }
}

- (void)setUnderLineFrameWithfromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    if (_progressViewHiden) {
        return;
    }
    CGRect fromCellFrame = [self cellFrameWithIndex:fromIndex];
    CGRect toCellFrame = [self cellFrameWithIndex:toIndex];
    
    CGFloat progressX = (toCellFrame.origin.x-fromCellFrame.origin.x)*progress+fromCellFrame.origin.x;
    CGFloat width = toCellFrame.size.width*progress + fromCellFrame.size.width*(1-progress);//toCellFrame.size.width;
    _underLineView.frame = CGRectMake(progressX, toCellFrame.size.height - _progressHeight, width, _progressHeight);
}

- (void)transitionFromCell:(TYTabTitleViewCell *)fromCell toCell:(TYTabTitleViewCell *)toCell
{
    if (fromCell) {
        fromCell.titleLabel.textColor = _normalTextColor;
        fromCell.transform = CGAffineTransformIdentity;
    }
    
    if (toCell) {
        toCell.titleLabel.textColor = _selectedTextColor;
        toCell.transform = CGAffineTransformMakeScale(_selectFontScale, _selectFontScale);
    }
}

- (void)transitionFromCell:(TYTabTitleViewCell *)fromCell toCell:(TYTabTitleViewCell *)toCell progress:(CGFloat)progress
{
    CGFloat currentTransform = (_selectFontScale - 1.0)*progress;
    fromCell.transform = CGAffineTransformMakeScale(_selectFontScale-currentTransform, _selectFontScale-currentTransform);
    toCell.transform = CGAffineTransformMakeScale(1.0+currentTransform, 1.0+currentTransform);
    
    CGFloat narR,narG,narB,narA;
    [_normalTextColor getRed:&narR green:&narG blue:&narB alpha:&narA];
    CGFloat selR,selG,selB,selA;
    [_selectedTextColor getRed:&selR green:&selG blue:&selB alpha:&selA];
    CGFloat detalR = narR - selR ,detalG = narG - selG,detalB = narB - selB,detalA = narA - selA;
    
    fromCell.titleLabel.textColor = [UIColor colorWithRed:selR+detalR*progress green:selG+detalG*progress blue:selB+detalB*progress alpha:selA+detalA*progress];
    toCell.titleLabel.textColor = [UIColor colorWithRed:narR-detalR*progress green:narG-detalG*progress blue:narB-detalB*progress alpha:narA-detalA*progress];
}

#pragma mark - override transition

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated
{
    TYTabTitleViewCell *fromCell = [self cellForIndex:fromIndex];
    TYTabTitleViewCell *toCell = [self cellForIndex:toIndex];
    
    if (![self isProgressScrollEnabel]) {
        
        if (_transitionCellAnimatedBlock) {
            _transitionCellAnimatedBlock(fromCell,toCell,animated);
        }
        
        [self setUnderLineFrameWithIndex:toIndex animated:fromCell && animated ? animated: NO];
    }

    [self scrollToIndex:toIndex animated:YES];
}

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    TYTabTitleViewCell *fromCell = [self cellForIndex:fromIndex];
    TYTabTitleViewCell *toCell = [self cellForIndex:toIndex];
    
    if (_transitionCellProgressBlock) {
        _transitionCellProgressBlock(fromCell,toCell,progress);
    }
    
    [self setUnderLineFrameWithfromIndex:fromIndex toIndex:toIndex progress:progress];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [self.dataSource numberOfControllersInPagerController];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TYTabTitleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    if (_dataSuorceFlags.titleForIndex) {
        NSString *title = [self.dataSource pagerController:self titleForIndex:indexPath.item];
        
        _configreCellForItemBlock(cell,title,indexPath);
        _transitionCellAnimatedBlock(indexPath.item == self.curIndex ? nil : cell,indexPath.item == self.curIndex ? cell : nil,NO);
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
    }
    return CGSizeZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"TYTabPagerController dealloc");
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
