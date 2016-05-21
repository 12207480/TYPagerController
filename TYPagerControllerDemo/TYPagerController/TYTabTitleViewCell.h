//
//  TYTabTitleViewCell.h
//  TYPagerControllerDemo
//
//  Created by tany on 16/5/4.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTabTitleCellProtocol.h"

@interface TYTabTitleViewCell : UICollectionViewCell<TYTabTitleCellProtocol>
@property (nonatomic, weak,readonly) UILabel *titleLabel;
@end
