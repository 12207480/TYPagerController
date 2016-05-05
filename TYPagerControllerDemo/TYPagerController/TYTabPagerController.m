//
//  TYTabPagerController.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/5/3.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYTabPagerController.h"
#import "TYPagerTabBar.h"
#import "TYTabTitleViewCell.h"

@interface TYTabPagerController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    struct {
        unsigned int titleForIndex :1;
    }_dataSuorceFlags;
}
@property (nonatomic, weak) TYPagerTabBar *pagerTabBar;
@end

#define kPagerTabBarHieght 36
static NSString *const cellId = @"TYTabTitleViewCell";

@implementation TYTabPagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addTabBar];
    
    self.contentTopEdging = CGRectGetHeight(_pagerTabBar.frame);
    _dataSuorceFlags.titleForIndex = [self.dataSource respondsToSelector:@selector(pagerController:titleForIndex:)];
}

- (void)reloadData
{
    [super reloadData];
    [_pagerTabBar reloadData];
}

- (void)addTabBar
{
    TYPagerTabBar *pagerTabBar = [[TYPagerTabBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kPagerTabBarHieght)];
    pagerTabBar.collectionView.delegate = self;
    pagerTabBar.collectionView.dataSource = self;
    [pagerTabBar.collectionView registerClass:[TYTabTitleViewCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:pagerTabBar];
    _pagerTabBar = pagerTabBar;
}

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated
{
    TYTabTitleViewCell *fromCell = (TYTabTitleViewCell *)[_pagerTabBar.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]];
    TYTabTitleViewCell *toCell = (TYTabTitleViewCell *)[_pagerTabBar.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            fromCell.titleLabel.textColor = [UIColor darkTextColor];
            fromCell.titleLabel.font = [UIFont systemFontOfSize:15];
            toCell.titleLabel.textColor = [UIColor redColor];
            toCell.titleLabel.font = [UIFont systemFontOfSize:18];
        }];
    }else {
        fromCell.titleLabel.textColor = [UIColor darkTextColor];
        fromCell.titleLabel.font = [UIFont systemFontOfSize:15];
        toCell.titleLabel.textColor = [UIColor redColor];
        toCell.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    [_pagerTabBar.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    CGRect fromCellFrame = [_pagerTabBar cellFrameWithIndex:fromIndex];
    CGRect toCellFrame = [_pagerTabBar cellFrameWithIndex:toIndex];
    
    CGFloat progressX = (toCellFrame.origin.x-fromCellFrame.origin.x)*progress+fromCellFrame.origin.x;
    CGFloat width = toCellFrame.size.width*progress + fromCellFrame.size.width*(1-progress);//toCellFrame.size.width;
    _pagerTabBar.underLineView.frame = CGRectMake(progressX, toCellFrame.size.height - 3, width, 3);
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
        cell.titleLabel.text = title;
        if (indexPath.item == self.curIndex) {
            cell.titleLabel.textColor = [UIColor redColor];
            cell.titleLabel.font = [UIFont systemFontOfSize:18];
        }else {
            cell.titleLabel.textColor = [UIColor darkTextColor];
            cell.titleLabel.font = [UIFont systemFontOfSize:15];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self moveToControllerAtIndex:indexPath.item animated:NO];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_cellWidth > 0) {
        return CGSizeMake(_cellWidth, CGRectGetHeight(_pagerTabBar.frame));
    }
    return CGSizeZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
