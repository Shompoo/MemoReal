//
//  DetailCell.h
//  SVAAboutPage
//
//  Created by Treechot Shompoonut on 24/04/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UICollectionViewCell


@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *detailTextView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@end
