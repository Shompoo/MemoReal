//
//  ButtonCell.m
//  MemorealT2
//
//  Created by Treechot Shompoonut on 10/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "ButtonCell.h"

@implementation ButtonCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
    }
    return self;
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
