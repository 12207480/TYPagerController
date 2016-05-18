//
//  TYTabButtonPagerControlle.m
//  TYPagerControllerDemo
//
//  Created by tany on 16/5/11.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYTabButtonPagerController.h"
#import "TYTabTitleViewCell.h"

@interface TYTabButtonPagerController ()<TYTabPagerControllerDelegate>
@property (nonatomic, assign) CGFloat selectFontScale;
@end

@implementation TYTabButtonPagerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        _normalTextColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        _selectedTextColor = [UIColor redColor];
        
        _pagerBarColor = [UIColor whiteColor];
        _collectionViewBarColor = [UIColor clearColor];
        
        _progressColor = [UIColor redColor];
        _progressRadius = self.progressHeight/2;
        
        [self registerCellClass:[TYTabTitleViewCell class] isContainXib:NO];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    _selectFontScale = self.selectedTextFont.pointSize/self.normalTextFont.pointSize;
    
    [self configureSubViews];
}

- (void)configureSubViews
{
    // progress
    self.progressView.backgroundColor = _progressColor;
    if (_progressRadius > 0) {
        self.progressView.layer.cornerRadius = _progressRadius;
        self.progressView.layer.masksToBounds = YES;
    }
    
    // tabBar
    self.pagerBarView.backgroundColor = _pagerBarColor;
    self.collectionViewBar.backgroundColor = _collectionViewBarColor;
}

#pragma mark - private

- (void)transitionFromCell:(UICollectionViewCell<TYTabTitleViewCellProtocol> *)fromCell toCell:(UICollectionViewCell<TYTabTitleViewCellProtocol> *)toCell
{
    if (fromCell) {
        fromCell.titleLabel.textColor = self.normalTextColor;
        fromCell.transform = CGAffineTransformIdentity;
    }
    
    if (toCell) {
        toCell.titleLabel.textColor = self.selectedTextColor;
        toCell.transform = CGAffineTransformMakeScale(self.selectFontScale, self.selectFontScale);
    }
}

- (void)transitionFromCell:(UICollectionViewCell<TYTabTitleViewCellProtocol> *)fromCell toCell:(UICollectionViewCell<TYTabTitleViewCellProtocol> *)toCell progress:(CGFloat)progress
{
    CGFloat currentTransform = (self.selectFontScale - 1.0)*progress;
    fromCell.transform = CGAffineTransformMakeScale(self.selectFontScale-currentTransform, self.selectFontScale-currentTransform);
    toCell.transform = CGAffineTransformMakeScale(1.0+currentTransform, 1.0+currentTransform);
    
    CGFloat narR,narG,narB,narA;
    [self.normalTextColor getRed:&narR green:&narG blue:&narB alpha:&narA];
    CGFloat selR,selG,selB,selA;
    [self.selectedTextColor getRed:&selR green:&selG blue:&selB alpha:&selA];
    CGFloat detalR = narR - selR ,detalG = narG - selG,detalB = narB - selB,detalA = narA - selA;
    
    fromCell.titleLabel.textColor = [UIColor colorWithRed:selR+detalR*progress green:selG+detalG*progress blue:selB+detalB*progress alpha:selA+detalA*progress];
    toCell.titleLabel.textColor = [UIColor colorWithRed:narR-detalR*progress green:narG-detalG*progress blue:narB-detalB*progress alpha:narA-detalA*progress];
}

#pragma mark - TYTabPagerControllerDelegate

- (void)pagerController:(TYTabPagerController *)pagerController configreCell:(TYTabTitleViewCell *)cell forItemTitle:(NSString *)title atIndexPath:(NSIndexPath *)indexPath
{
    TYTabTitleViewCell *titleCell = (TYTabTitleViewCell *)cell;
    titleCell.titleLabel.text = title;
    titleCell.titleLabel.font = self.normalTextFont;
}

- (void)pagerController:(TYTabPagerController *)pagerController transitionFromeCell:(UICollectionViewCell<TYTabTitleViewCellProtocol> *)fromCell toCell:(UICollectionViewCell<TYTabTitleViewCellProtocol> *)toCell animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:self.animateDuration animations:^{
            [self transitionFromCell:(TYTabTitleViewCell *)fromCell toCell:(TYTabTitleViewCell *)toCell];
        }];
    }else{
        [self transitionFromCell:fromCell toCell:toCell];
    }
}

- (void)pagerController:(TYTabPagerController *)pagerController transitionFromeCell:(UICollectionViewCell<TYTabTitleViewCellProtocol> *)fromCell toCell:(UICollectionViewCell<TYTabTitleViewCellProtocol> *)toCell progress:(CGFloat)progress
{
    [self transitionFromCell:fromCell toCell:toCell progress:progress];
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
