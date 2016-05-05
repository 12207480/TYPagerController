//
//  TYPagerTabBar.h
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/5/3.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYPagerTabBar : UIView
@property (nonatomic, weak, readonly) UICollectionView *collectionView;
@property (nonatomic, weak, readonly) UIView *underLineView;

- (void)reloadData;

- (CGRect)cellFrameWithIndex:(NSInteger)index;
@end
