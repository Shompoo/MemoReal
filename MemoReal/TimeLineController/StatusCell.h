//
//  StatusCell.h
//  MemorealT2
//
//  Created by Treechot Shompoonut on 12/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
