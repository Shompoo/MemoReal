//
//  menuView.m
//  MemorealT2
//
//  Created by Treechot Shompoonut on 13/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "menuView.h"

@implementation menuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self = [super initWithFrame:frame];
        if (self) {
            // Initialization code
            NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"menuView" owner:self options:nil];
            UIView* mainView = (UIView*)[nibViews objectAtIndex:0];
            [self addSubview:mainView];
        }
        return self;
    }
    return self;
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
