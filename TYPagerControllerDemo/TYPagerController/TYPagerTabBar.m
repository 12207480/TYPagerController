//
//  TYPagerTabBar.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/5/3.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYPagerTabBar.h"
#import "TYTabTitleViewCell.h"

@interface TYPagerTabBar ()
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *underLineView;

@property (nonatomic, assign) NSInteger curIndex;
@end

#define kUnderLineViewHeight 3

@implementation TYPagerTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addCollectionView];
        
        [self addUnderLineView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self addCollectionView];
        
        [self addUnderLineView];
    }
    return self;
}

- (void)addCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;

    [self addSubview:collectionView];
    _collectionView = collectionView;
}

- (void)addUnderLineView
{
    UIView *underLineView = [[UIView alloc]init];
    underLineView.backgroundColor = [UIColor redColor];
    [_collectionView addSubview:underLineView];
    _underLineView = underLineView;
}

- (void)reloadData
{
    [_collectionView reloadData];
    [_collectionView setContentOffset:CGPointZero];
    [self setNeedsLayout];
}

- (CGRect)cellFrameWithIndex:(NSInteger)index
{
    UICollectionViewLayoutAttributes * cellAttrs = [_collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cellAttrs.frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
    
    CGRect cellFrame = [self cellFrameWithIndex:_curIndex];
    _underLineView.frame = CGRectMake(cellFrame.origin.x, cellFrame.size.height - kUnderLineViewHeight, cellFrame.size.width, kUnderLineViewHeight);
    
}

@end
