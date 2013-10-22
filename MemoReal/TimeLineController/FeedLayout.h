//
//  FeedLayout.h
//  MemorealT2
//
//  Created by Treechot Shompoonut on 12/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FeedLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) CGFloat spacingY;


@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) NSInteger cellCount;

@end
