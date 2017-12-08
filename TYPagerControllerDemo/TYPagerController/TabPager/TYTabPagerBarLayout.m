//
//  TYTabPagerBarLayout.m
//  TYPagerControllerDemo
//
//  Created by tanyang on 2017/7/17.
//  Copyright © 2017年 tany. All rights reserved.
//

#import "TYTabPagerBarLayout.h"
#import "TYTabPagerBar.h"

@interface TYTabPagerBarLayout ()

@property (nonatomic, weak) TYTabPagerBar *pagerTabBar;

@property (nonatomic, assign) CGFloat selectFontScale;

@end

#define kUnderLineViewHeight 2

@implementation TYTabPagerBarLayout

- (instancetype)initWithPagerTabBar:(TYTabPagerBar *)pagerTabBar {
    if (self = [super init]) {
        _pagerTabBar = pagerTabBar;
        [self configurePropertys];
        self.barStyle = TYPagerBarStyleProgressElasticView;
    }
    return self;
}

- (void)configurePropertys {
    _cellSpacing = 2;
    _cellEdging = 3;
    _cellWidth = 0;
    _progressHorEdging = 6;
    _progressWidth = 0;
    _animateDuration = 0.25;
    
    _normalTextFont = [UIFont systemFontOfSize:15];
    _selectedTextFont = [UIFont systemFontOfSize:18];
    _normalTextColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    _selectedTextColor = [UIColor redColor];
    _textColorProgressEnable = YES;
    //_adjustContentCellsCenter = YES;
}

#pragma mark - geter setter

- (void)setProgressRadius:(CGFloat)progressRadius {
    _progressRadius = progressRadius;
    _pagerTabBar.progressView.layer.cornerRadius = progressRadius;
}

- (void)setProgressBorderWidth:(CGFloat)progressBorderWidth {
    _progressBorderWidth = progressBorderWidth;
    _pagerTabBar.progressView.layer.borderWidth = progressBorderWidth;
}

- (void)setProgressBorderColor:(UIColor *)progressBorderColor {
    _progressBorderColor = progressBorderColor;
    if (!_progressColor) {
        _pagerTabBar.progressView.backgroundColor = [UIColor clearColor];
    }
    _pagerTabBar.progressView.layer.borderColor = progressBorderColor.CGColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    _pagerTabBar.progressView.backgroundColor = progressColor;
}

- (void)setProgressHeight:(CGFloat)progressHeight {
    _progressHeight = progressHeight;
    CGRect frame = _pagerTabBar.progressView.frame;
    CGFloat height = CGRectGetHeight(_pagerTabBar.collectionView.frame);
    frame.origin.y = _barStyle == TYPagerBarStyleCoverView ? (height - _progressHeight)/2:(height - _progressHeight - _progressVerEdging);
    frame.size.height = progressHeight;
    _pagerTabBar.progressView.frame = frame;
}

- (UIEdgeInsets)sectionInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, UIEdgeInsetsZero) || _barStyle != TYPagerBarStyleCoverView) {
        return _sectionInset;
    }
    if (_barStyle == TYPagerBarStyleCoverView && _adjustContentCellsCenter) {
        return _sectionInset;
    }
    CGFloat horEdging = -_progressHorEdging+_cellSpacing;
    return UIEdgeInsetsMake(0, horEdging, 0, horEdging);
}

- (void)setAdjustContentCellsCenter:(BOOL)adjustContentCellsCenter {
    BOOL change = _adjustContentCellsCenter != adjustContentCellsCenter;
    _adjustContentCellsCenter = adjustContentCellsCenter;
    if (change && _pagerTabBar.superview) {
        [_pagerTabBar setNeedsLayout];
    }
}

- (void)setBarStyle:(TYPagerBarStyle)barStyle
{
    if (barStyle == _barStyle) {
        return;
    }
    if (_barStyle == TYPagerBarStyleCoverView) {
        self.progressBorderWidth = 0;
        self.progressBorderColor = nil;
    }
    _barStyle = barStyle;
    switch (barStyle) {
        case TYPagerBarStyleProgressView:
            self.progressWidth = 0;
            self.progressHorEdging = 6;
            self.progressVerEdging = 0;
            self.progressHeight = kUnderLineViewHeight;
            break;
        case TYPagerBarStyleProgressBounceView:
        case TYPagerBarStyleProgressElasticView:
            self.progressWidth = 30;
            self.progressVerEdging = 0;
            self.progressHorEdging = 0;
            self.progressHeight = kUnderLineViewHeight;
            break;
        case TYPagerBarStyleCoverView:
            self.progressWidth = 0;
            self.progressHorEdging = -self.progressHeight/4;
            self.progressVerEdging = 3;
            break;
        default:
            break;
    }
    _pagerTabBar.progressView.hidden = barStyle == TYPagerBarStyleNoneView;
    if (barStyle == TYPagerBarStyleCoverView) {
        _progressRadius = 0;
        _pagerTabBar.progressView.layer.zPosition = -1;
        [_pagerTabBar.progressView removeFromSuperview];
        [_pagerTabBar.collectionView insertSubview: _pagerTabBar.progressView atIndex:0];
    }else {
        self.progressRadius = _progressHeight/2;
        if (_pagerTabBar.progressView.layer.zPosition == -1) {
            _pagerTabBar.progressView.layer.zPosition = 0;
            [_pagerTabBar.progressView removeFromSuperview];
            [_pagerTabBar.collectionView addSubview:_pagerTabBar.progressView];
        }
        
    }
}

#pragma mark - public

- (void)layoutIfNeed {
    UICollectionViewFlowLayout *collectionLayout = (UICollectionViewFlowLayout *)_pagerTabBar.collectionView.collectionViewLayout;
    collectionLayout.minimumLineSpacing = _cellSpacing;
    collectionLayout.minimumInteritemSpacing = _cellSpacing;
    _selectFontScale = self.normalTextFont.pointSize/(self.selectedTextFont ? self.selectedTextFont.pointSize:self.normalTextFont.pointSize);
    collectionLayout.sectionInset = _sectionInset;
}

- (void)invalidateLayout {
    [_pagerTabBar.collectionView.collectionViewLayout invalidateLayout];
}

- (void)adjustContentCellsCenterInBar {
    if (!_adjustContentCellsCenter || !_pagerTabBar.superview) {
        return;
    }
    CGRect frame = self.pagerTabBar.collectionView.frame;
    if (CGRectIsEmpty(frame)) {
        return;
    }
    
    UICollectionViewFlowLayout *collectionLayout = (UICollectionViewFlowLayout *)_pagerTabBar.collectionView.collectionViewLayout;
    CGSize contentSize = collectionLayout.collectionViewContentSize;
    NSArray *layoutAttribulte = [collectionLayout layoutAttributesForElementsInRect:CGRectMake(0, 0, MAX(contentSize.width, CGRectGetWidth(frame)), MAX(contentSize.height,CGRectGetHeight(frame)))];
    if (layoutAttribulte.count == 0) {
        return;
    }
    
    UICollectionViewLayoutAttributes *firstAttribute = layoutAttribulte.firstObject;
    UICollectionViewLayoutAttributes *lastAttribute = layoutAttribulte.lastObject;
    CGFloat left = CGRectGetMinX(firstAttribute.frame);
    CGFloat right = CGRectGetMaxX(lastAttribute.frame);
    if (right - left > CGRectGetWidth(self.pagerTabBar.frame)) {
        return;
    }
    CGFloat sapce = (CGRectGetWidth(self.pagerTabBar.frame) - (right - left))/2;
    _sectionInset = UIEdgeInsetsMake(_sectionInset.top, sapce, _sectionInset.bottom, sapce);
    collectionLayout.sectionInset = _sectionInset;
}

- (CGRect)cellFrameWithIndex:(NSInteger)index {
    return [_pagerTabBar cellFrameWithIndex:index];
}

#pragma mark - cell

- (void)transitionFromCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> *)fromCell toCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> *)toCell animate:(BOOL)animate {
    if (_pagerTabBar.countOfItems == 0) {
        return;
    }
    void (^animateBlock)() = ^{
        if (fromCell) {
            fromCell.titleLabel.font = _normalTextFont;
            fromCell.titleLabel.textColor = _normalTextColor;
            fromCell.transform = CGAffineTransformMakeScale(_selectFontScale, _selectFontScale);
        }
        if (toCell) {
            toCell.titleLabel.font = _normalTextFont;
            toCell.titleLabel.textColor = _selectedTextColor ? _selectedTextColor : _normalTextColor;
            toCell.transform = CGAffineTransformIdentity;
        }
    };
    if (animate) {
        [UIView animateWithDuration:_animateDuration animations:^{
            animateBlock();
        }];
    }else{
        animateBlock();
    }
    
}

- (void)transitionFromCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> *)fromCell toCell:(UICollectionViewCell<TYTabPagerBarCellProtocol> *)toCell progress:(CGFloat)progress {
    if (_pagerTabBar.countOfItems == 0 || !_textColorProgressEnable) {
        return;
    }
    CGFloat currentTransform = (1.0 - _selectFontScale)*progress;
    fromCell.transform = CGAffineTransformMakeScale(1.0-currentTransform, 1.0-currentTransform);
    toCell.transform = CGAffineTransformMakeScale(_selectFontScale+currentTransform, _selectFontScale+currentTransform);
    
    if (_normalTextColor == _selectedTextColor || !_selectedTextColor) {
        return;
    }
    
    CGFloat narR=0,narG=0,narB=0,narA=1;
    [_normalTextColor getRed:&narR green:&narG blue:&narB alpha:&narA];
    CGFloat selR=0,selG=0,selB=0,selA=1;
    [_selectedTextColor getRed:&selR green:&selG blue:&selB alpha:&selA];
    CGFloat detalR = narR - selR ,detalG = narG - selG,detalB = narB - selB,detalA = narA - selA;
    
    fromCell.titleLabel.textColor = [UIColor colorWithRed:selR+detalR*progress green:selG+detalG*progress blue:selB+detalB*progress alpha:selA+detalA*progress];
    toCell.titleLabel.textColor = [UIColor colorWithRed:narR-detalR*progress green:narG-detalG*progress blue:narB-detalB*progress alpha:narA-detalA*progress];
}

#pragma mark - progress View

// set up progress view frame
- (void)setUnderLineFrameWithIndex:(NSInteger)index animated:(BOOL)animated
{
    UIView *progressView = _pagerTabBar.progressView;
    if (progressView.isHidden || _pagerTabBar.countOfItems == 0) {
        return;
    }
    
    CGRect cellFrame = [self cellFrameWithIndex:index];
    CGFloat progressHorEdging = _progressWidth > 0 ? (cellFrame.size.width - _progressWidth)/2 : _progressHorEdging;
    CGFloat progressX = cellFrame.origin.x+progressHorEdging;
    CGFloat progressY = _barStyle == TYPagerBarStyleCoverView ? (cellFrame.size.height - _progressHeight)/2:(cellFrame.size.height - _progressHeight - _progressVerEdging);
    CGFloat width = cellFrame.size.width-2*progressHorEdging;
    
    if (animated) {
        [UIView animateWithDuration:_animateDuration animations:^{
            progressView.frame = CGRectMake(progressX, progressY, width, _progressHeight);
        }];
    }else {
        progressView.frame = CGRectMake(progressX, progressY, width, _progressHeight);
    }
}

- (void)setUnderLineFrameWithfromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress
{
    UIView *progressView = _pagerTabBar.progressView;
    if (progressView.isHidden || _pagerTabBar.countOfItems == 0) {
        return;
    }
    
    CGRect fromCellFrame = [self cellFrameWithIndex:fromIndex];
    CGRect toCellFrame = [self cellFrameWithIndex:toIndex];
    
    CGFloat progressFromEdging = _progressWidth > 0 ? (fromCellFrame.size.width - _progressWidth)/2 : _progressHorEdging;
    CGFloat progressToEdging = _progressWidth > 0 ? (toCellFrame.size.width - _progressWidth)/2 : _progressHorEdging;
    CGFloat progressY = _barStyle == TYPagerBarStyleCoverView ? (toCellFrame.size.height - _progressHeight)/2:(toCellFrame.size.height - _progressHeight - _progressVerEdging);
    CGFloat progressX = 0, width = 0;
    
    if (_barStyle == TYPagerBarStyleProgressBounceView) {
        if (fromCellFrame.origin.x < toCellFrame.origin.x) {
            if (progress <= 0.5) {
                progressX = fromCellFrame.origin.x + progressFromEdging;
                width = (toCellFrame.size.width-progressToEdging+progressFromEdging+_cellSpacing)*2*progress + fromCellFrame.size.width-2*progressFromEdging;
            }else {
                progressX = fromCellFrame.origin.x + progressFromEdging + (fromCellFrame.size.width-progressFromEdging+progressToEdging+_cellSpacing)*(progress-0.5)*2;
                width = CGRectGetMaxX(toCellFrame)-progressToEdging - progressX;
            }
        }else {
            if (progress <= 0.5) {
                progressX = fromCellFrame.origin.x + progressFromEdging - (toCellFrame.size.width-progressToEdging+progressFromEdging+_cellSpacing)*2*progress;
                width = CGRectGetMaxX(fromCellFrame) - progressFromEdging - progressX;
            }else {
                progressX = toCellFrame.origin.x + progressToEdging;
                width = (fromCellFrame.size.width-progressFromEdging+progressToEdging + _cellSpacing)*(1-progress)*2 + toCellFrame.size.width - 2*progressToEdging;
            }
        }
    }else if (_barStyle == TYPagerBarStyleProgressElasticView) {
        if (fromCellFrame.origin.x < toCellFrame.origin.x) {
            if (progress <= 0.5) {
                progressX = fromCellFrame.origin.x + progressFromEdging + (fromCellFrame.size.width-2*progressFromEdging)*progress;
                width = (toCellFrame.size.width-progressToEdging+progressFromEdging+_cellSpacing)*2*progress - (toCellFrame.size.width-2*progressToEdging)*progress + fromCellFrame.size.width-2*progressFromEdging-(fromCellFrame.size.width-2*progressFromEdging)*progress;
            }else {
                progressX = fromCellFrame.origin.x + progressFromEdging + (fromCellFrame.size.width-2*progressFromEdging)*0.5 + (fromCellFrame.size.width-progressFromEdging - (fromCellFrame.size.width-2*progressFromEdging)*0.5 +progressToEdging+_cellSpacing)*(progress-0.5)*2;
                width = CGRectGetMaxX(toCellFrame)-progressToEdging - progressX - (toCellFrame.size.width-2*progressToEdging)*(1-progress);
            }
        }else {
            if (progress <= 0.5) {
                progressX = fromCellFrame.origin.x + progressFromEdging - (toCellFrame.size.width-(toCellFrame.size.width-2*progressToEdging)/2-progressToEdging+progressFromEdging+_cellSpacing)*2*progress;
                width = CGRectGetMaxX(fromCellFrame) - (fromCellFrame.size.width-2*progressFromEdging)*progress - progressFromEdging - progressX;
            }else {
                progressX = toCellFrame.origin.x + progressToEdging+(toCellFrame.size.width-2*progressToEdging)*(1-progress);
                width = (fromCellFrame.size.width-progressFromEdging+progressToEdging-(fromCellFrame.size.width-2*progressFromEdging)/2 + _cellSpacing)*(1-progress)*2 + toCellFrame.size.width - 2*progressToEdging - (toCellFrame.size.width-2*progressToEdging)*(1-progress);
            }
        }
    }else {
        progressX = (toCellFrame.origin.x+progressToEdging-(fromCellFrame.origin.x+progressFromEdging))*progress+fromCellFrame.origin.x+progressFromEdging;
        width = (toCellFrame.size.width-2*progressToEdging)*progress + (fromCellFrame.size.width-2*progressFromEdging)*(1-progress);
    }
    
    progressView.frame = CGRectMake(progressX,progressY, width, _progressHeight);
}

- (void)layoutSubViews {
    if (CGRectIsEmpty(_pagerTabBar.frame)) {
        return;
    }
    if (_barStyle == TYPagerBarStyleCoverView) {
        self.progressHeight = CGRectGetHeight(_pagerTabBar.collectionView.frame) -self.progressVerEdging*2;
        self.progressRadius = _progressRadius > 0 ? _progressRadius : self.progressHeight/2;
    }
    [self setUnderLineFrameWithIndex:_pagerTabBar.curIndex animated:NO];
}

@end
