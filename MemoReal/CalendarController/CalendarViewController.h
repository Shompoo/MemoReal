//
//  CalendarViewController.h
//  MemoReal
//
//  Created by Treechot Shompoonut on 22/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>
#import "VRGCalendarView.h"
#import "RNGridMenu.h"


@interface CalendarViewController : UIViewController <VRGCalendarViewDelegate, RNGridMenuDelegate>
{
    NSMutableArray *eventArray;
}
@property (strong, nonatomic) IBOutlet UIView *eventCountView;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UIButton *countButton;


@end
