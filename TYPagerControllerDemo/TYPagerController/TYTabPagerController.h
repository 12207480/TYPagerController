//
//  TYTabPagerController.h
//  TYPagerControllerDemo
//
//  Created by tanyang on 16/5/3.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import "TYPagerController.h"

@interface TYTabPagerController : TYPagerController

@property (nonatomic, strong) UIColor *pagerBarColor;
@property (nonatomic, assign) CGFloat cellWidth;

@property (nonatomic, assign) CGFloat animateDuration;

@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *selectedTextColor;

@property (nonatomic, strong) UIFont *normalTextFont;
@property (nonatomic, strong) UIFont *selectedTextFont;

@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, assign) CGFloat progressHeight;
@property (nonatomic, assign) CGFloat progressRadius;
@property (nonatomic, assign) CGFloat progressViewHiden;

// block use __weak typeof(self) weakSelf = self;
// custom transition cell animated
@property (nonatomic, copy) void(^transitionCellAnimatedBlock)(UICollectionViewCell *fromCell,UICollectionViewCell *toCell,BOOL animated);

// custom transition cell progress
@property (nonatomic, copy) void(^transitionCellProgressBlock)(UICollectionViewCell *fromCell,UICollectionViewCell *toCell,CGFloat progress);

// custom configre cellForItemAtIndexPath
@property (nonatomic, copy) void(^configreCellForItemBlock)(UICollectionViewCell *cell,NSString *title,NSIndexPath *indexPath);

@end

