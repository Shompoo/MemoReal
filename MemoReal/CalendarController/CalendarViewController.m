//
//  CalendarViewController.m
//  MemoReal
//
//  Created by Treechot Shompoonut on 22/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CalendarViewController.h"
#import "DataManager.h"
#import "NVSlideMenuController.h"
#import "RNGridMenu.h"
#import "MMRDetailViewController.h"
#import "MMRInputViewController.h"


@interface CalendarViewController ()
{
    NSDateFormatter *dateFormater;
    DataManager *dataMGR;
    NSMutableArray *dateFound;
    NSMutableArray *memoArray;
    NSMutableDictionary *detailDict;
    int eCount;
}

@property (nonatomic, strong) MMRDetailViewController *detailViewController;
@end

@implementation CalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"MeMoReal", @"MeMoReal");
        dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"EEEE, dd MMM yyyy hh:mm:ss a"];
        
        dataMGR = [[DataManager alloc] init];
        detailDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)SetAppearanceForNavBar
{
    
    //[UIFont fontWithName:@"HelveticaNeue-Light" size:15]
    // lightBlue [UIColor colorWithRed:0.35f green:0.51f blue:0.91f alpha:1.00f]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f]];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor],UITextAttributeTextColor,
                                               [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset,
                                               [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0],UITextAttributeFont,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
   
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self SetAppearanceForNavBar];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.leftBarButtonItem = [self slideOutBarButton];
    self.navigationItem.rightBarButtonItem = [self rightNavBarItem];
    
    
    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.delegate=self;
    [self.view addSubview:calendar];
    
    //[self custimiseImageView:self.imageView];
    [self custimiseView:self.countButton];
    [self.countButton setImage:[UIImage imageNamed:@"papericon"] forState:UIControlStateNormal];
   
    
    [self.countButton addTarget:self action:@selector(eventPopup:) forControlEvents:UIControlEventTouchUpInside];
    
    [self checkEventByDate:[NSDate date]];
    
    RNLongPressGestureRecognizer *longPress = [[RNLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
   
}

#pragma -mark SlideOutMenu

- (UIBarButtonItem *)slideOutBarButton {
    
    UIButton *menu = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 27, 18)];
    [menu addTarget:self action:@selector(slideOut:) forControlEvents:UIControlEventTouchUpInside];
    [menu setBackgroundImage:[UIImage imageNamed:@"mList.png"] forState:UIControlStateNormal];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menu];
    
    
    return menuItem;
}

- (UIBarButtonItem *)rightNavBarItem
{
    UIButton *rightmenu = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 27, 18)];
    [rightmenu addTarget:self action:@selector(getInputView:) forControlEvents:UIControlEventTouchUpInside];
    [rightmenu setBackgroundImage:[UIImage imageNamed:@"plusCorner"] forState:UIControlStateNormal];
    UIBarButtonItem *ritem = [[UIBarButtonItem alloc] initWithCustomView:rightmenu];
    
    
    return ritem;
}



#pragma mark - Event handlers

- (void)slideOut:(id)sender {
    
    [self.slideMenuController toggleMenuAnimated:self];
}
- (IBAction)getInputView:(id)sender
{
    
    MMRInputViewController *inputViewController = [[MMRInputViewController alloc] init];
    [self.navigationController pushViewController:inputViewController animated:YES];
    
}


#pragma mark - Vurig calendar delegate

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    if (month==[[NSDate date] month]) {
        
              
        eventArray = [[NSMutableArray alloc] init];
        NSMutableArray *muColors = [[NSMutableArray alloc] init];
       
        for (NSString *dt in [dataMGR getEventForCalendar]) {
           
             NSDate *aday = [dateFormater dateFromString:dt];
            if (aday != nil) {
                [eventArray addObject:aday];
                [muColors addObject:[UIColor orangeColor]];
            }
        
        }
        
        NSArray *dates = [NSArray arrayWithArray:eventArray];
        
        NSArray *color = [NSArray arrayWithArray:muColors];
         [calendarView markDates:dates withColors:color];
        
    }
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date {
    
     [self.eventCountView setHidden:YES];
     [self checkEventByDate:date];
   
    
}


-(void)checkEventByDate:(NSDate *)date
{
    
    NSDateFormatter *shortFormatter = [[NSDateFormatter alloc] init];
    [shortFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
    
    dateFound = [[NSMutableArray alloc] init];
    [dateFound removeAllObjects];
    
    
    NSString *selectedDate = [shortFormatter stringFromDate:date];
    
    eCount = 0;
    for (NSString *dt in [dataMGR getEventForCalendar]) {
        
        
        if ([dt rangeOfString:selectedDate].location != NSNotFound) {
            
           // NSLog(@"It does not contain selectedDate");
            eCount = eCount + 1;
            if (eCount < 2) {
                [self.countLabel setText:[NSString stringWithFormat:@"%d place", eCount]];
            }
            else{
                
                [self.countLabel setText:[NSString stringWithFormat:@"%d places", eCount]];
            }
            
            
            [dateFound addObject:dt];
            
            //type dict of memo
            //[memoArray addObject:[dataMGR getMemoByDate:dt]];
            
            [self.eventCountView setHidden:NO];
            
        } 
        
    }
    
}


-(void)custimiseView:(UIView *)view
{
    view.layer.cornerRadius = view.bounds.size.width/2 ;
    [view setBackgroundColor:[UIColor colorWithRed:0.35f green:0.51f blue:0.91f alpha:1.00f]];
  
}

- (IBAction)eventPopup:(id)sender
{
    if (eCount == 0) {
        return;
    }
    [self showImagesOnly];
}
        
    
#pragma mark - RNGridMenuDelegate
    
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
{
        //NSLog(@"Dismissed with item %d: %@ \n %@", itemIndex, [dateFound objectAtIndex:itemIndex], [detailDict objectForKey:[dateFound objectAtIndex:itemIndex]]);
    NSDictionary *mDict = [[NSDictionary alloc] initWithDictionary:[detailDict objectForKey:[dateFound objectAtIndex:itemIndex] ] copyItems:YES];
    //NSLog(@"init detail %@", mDict);
    if (!self.detailViewController) {
        self.detailViewController = [[MMRDetailViewController alloc]
                                     initWithPlaceName:[mDict objectForKey:@"title"]
                                     memoDetail:[mDict objectForKey:@"detail"]
                                     tagsName:[mDict objectForKey:@"tags"]
                                     dateAdded:[mDict objectForKey:@"timeAdded"]
                                     ImageName:[mDict objectForKey:@"imageTag"]
                                     Latitude:[mDict objectForKey:@"lat"]
                                     andLongitude:[mDict objectForKey:@"lon"]];
    }
    
    [self.navigationController pushViewController:self.detailViewController animated:NO];
    
        
}

- (void)showImagesOnly {
    NSInteger numberOfOptions = eCount;
    [detailDict removeAllObjects];
     memoArray = [[NSMutableArray alloc] init];
    [memoArray removeAllObjects];

    NSMutableArray *muitems = [[NSMutableArray alloc] init];
    
    for (NSString *aday in dateFound) {
        memoArray = [dataMGR getMemoByDate:aday];
        if (memoArray.count > 0) {
            [detailDict setObject:[memoArray objectAtIndex:0] forKey:aday];
            
            NSDictionary *memDict = [memoArray objectAtIndex:0];
            NSString *imgName = [memDict objectForKey:@"imageTag"];
            if (imgName.length != 0) {
            
                [muitems addObject:[self getImageByName:imgName]];
            }else{
                [muitems addObject:[UIImage imageNamed:@"defaultImage"]];
            }
        }
        else{
            NSLog(@"No event detail: %d", memoArray.count);
        }
        
    }
    
    
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:[muitems subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}


-(UIImage *)getImageByName:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFolder = [NSString stringWithFormat:@"%@/Images",documentsDirectory];
    
    
    NSString * imageFilePath = [imageFolder stringByAppendingPathComponent:imageName];
    
    return [UIImage imageWithContentsOfFile: imageFilePath];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
