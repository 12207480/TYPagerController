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

// views
@property (nonatomic, weak) UIView *pagerBarView;
@property (nonatomic, weak) UICollectionView *collectionViewBar;
@property (nonatomic, weak) UIView *underLineView;

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
        
        [self registerCellClass:[TYTabTitleViewCell class] isContainXib:NO];
        
        [self configureTransitionBlocks];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addPagerBarView];
    
    [self addCollectionViewBar];
    
    [self addUnderLineView];
    
    [self configurePagerData];
}

- (void)addPagerBarView
{
    UIView *pagerBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.contentTopEdging)];
    pagerBarView.backgroundColor = _pagerBarColor;
    [self.view addSubview:pagerBarView];
    _pagerBarView = pagerBarView;
}

- (void)addCollectionViewBar
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = _cellSpacing;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.contentTopEdging) collectionViewLayout:layout];
    collectionView.backgroundColor = _pagerBarColor;
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
    underLineView.hidden = _progressViewHiden;
    underLineView.backgroundColor = _progressColor;
    if (_progressRadius > 0) {
        underLineView.layer.cornerRadius = _progressRadius;
        underLineView.layer.masksToBounds = YES;
    }
    [_collectionViewBar addSubview:underLineView];
    _underLineView = underLineView;
}

#pragma mark - public

- (void)reloadData
{
    [self configurePagerData];
    
    [_collectionViewBar reloadData];
    
    [super reloadData];
}

- (void)updateContentView
{
    [super updateContentView];
    
    [self updateTabPagerView];
    
    [self setUnderLineFrameWithIndex:self.curIndex animated:NO];
    
    [self scrollToIndex:self.curIndex animated:NO];
}

- (void)registerCellClass:(Class)cellClass isContainXib:(BOOL)isContainXib
{
    _cellClass = cellClass;
    _cellId = NSStringFromClass(cellClass);
    _cellContainXib = isContainXib;
}

#pragma mark - private

- (void)updateTabPagerView
{
    CGFloat statusHeight = self.navigationController.isNavigationBarHidden ? 20:0;
    _pagerBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.contentTopEdging+statusHeight);
    _collectionViewBar.frame = CGRectMake(0, statusHeight, CGRectGetWidth(self.view.frame), self.contentTopEdging);
}

- (void)configireInitPropertys
{
    self.changeIndexWhenScrollProgress = 1.0;
    _pagerBarColor = [UIColor whiteColor];
    _normalTextFont = [UIFont systemFontOfSize:15];
    _selectedTextFont = [UIFont systemFontOfSize:18];
    _normalTextColor = [UIColor darkTextColor];
    _selectedTextColor = [UIColor redColor];
    _progressColor = [UIColor redColor];
    _progressRadius = 1;
    _progressViewHiden = NO;
    _animateDuration = 0.25;
    _cellSpacing = 0;
    _cellEdging = 3;
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

- (UICollectionViewCell *)cellForIndex:(NSInteger)index
{
    return [_collectionViewBar cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
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
    UICollectionViewCell *fromCell = [self cellForIndex:fromIndex];
    UICollectionViewCell *toCell = [self cellForIndex:toIndex];
    
    if (![self isProgressScrollEnabel]) {
        
        if (_transitionCellAnimatedBlock) {
            _transitionCellAnimatedBlock(fromCell,toCell,animated);
        }
        
        [self setUnderLineFrameWithIndex:toIndex animated:fromCell && animated ? animated: NO];
    }

    [self scrollToIndex:toIndex animated:fromCell && animated ? animated: NO];
}

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    UICollectionViewCell *fromCell = [self cellForIndex:fromIndex];
    UICollectionViewCell *toCell = [self cellForIndex:toIndex];
    
    if (_transitionCellProgressBlock) {
        _transitionCellProgressBlock(fromCell,toCell,progress);
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
    }else if(_dataSuorceFlags.titleForIndex){
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
