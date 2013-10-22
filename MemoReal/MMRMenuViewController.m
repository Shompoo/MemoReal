//
//  MMRMenuViewController.m
//  Memoreal
//
//  Created by Treechot Shompoonut on 29/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "MMRMenuViewController.h"
#import "NVSlideMenuController.h"
#import "MemorealViewController.h"

#import "CamViewController.h"


#import "MenuCell.h"
#import "MMRInputViewController.h"
#import "MMRDetailViewController.h"
#import "MMRTimeLineController.h"
#import "MapViewController.h"
#import "CalendarViewController.h"

enum {
    TimeLine = 0,
    CamView,
    Map,
    Days,
    NewEntry,
    Setting
};

@interface MMRMenuViewController ()

@end

@implementation MMRMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    UIImage *patternImg = [UIImage imageNamed:@"menubg.png"];
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:patternImg]];
   
    self.tableView.separatorColor = [UIColor clearColor];
      

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Menu";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 54;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20,10,300,24)];
    label.backgroundColor = [UIColor clearColor];
    
    //light Mahocgani color colorWithRed:187/255.0 green:83/255.0 blue:88/255.0 alpha:1.0
    //label.textColor = [UIColor colorWithRed:187/255.0 green:83/255.0 blue:88/255.0 alpha:1.0];
    label.textColor = [UIColor whiteColor];
    label.text = @"Memoreal";
    [headerView addSubview:label];
    
    return headerView;

}



 
- (void)configureCell:(MenuCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.menuName.textColor = [UIColor whiteColor];
    switch (indexPath.row) {
        case TimeLine:
            //cell.menuImage.image = [UIImage  imageNamed:@"a1"];
            cell.menuName.text = @"TimeLine";
            break;
            
        case CamView:
            //cell.menuImage.image = [UIImage  imageNamed:@"radar"];
            cell.menuName.text = @"Real";
            break;
            
        case Map:
            //cell.menuImage.image = [UIImage  imageNamed:@"location"];
            cell.menuName.text = @"Map";
            break;
            
        case Days:
            //cell.menuImage.image = [UIImage  imageNamed:@"calendar"];
            cell.menuName.text = @"Days";
            break;
        
        case NewEntry:
            //cell.menuImage.image = [UIImage  imageNamed:@"Notepad"];
            cell.menuName.text = @"Add Place";
            break;
    
       /* case Setting:
            cell.menuImage.image = [UIImage  imageNamed:@"setting"];
            cell.menuName.text = @"Setting";
            break;*/
            
        default:
            break;
    }
}
 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    NSString * CellIdent = @"MenuCell";
    MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdent];
    
    if(cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
        cell = _menuCell;
        _menuCell = nil;
        
    }
    
    [self configureCell:cell forIndexPath:indexPath];
 
    return cell;
}


#pragma mark - table view delegate

- (BOOL)isShowingClass:(Class)class {
    UIViewController *controller = self.slideMenuController.contentViewController;
    if ([controller isKindOfClass:class]) {
        return YES;
    }
    
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)controller;
        if ([navController.visibleViewController isKindOfClass:class]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)showControllerClass:(Class)class {
    if ([self isShowingClass:class]) {
        [self.slideMenuController toggleMenuAnimated:self];
    }
    else {
        
        id rootView = [[class alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootView];
       
        [self.slideMenuController closeMenuBehindContentViewController:nav animated:YES completion:nil];
    }
}

- (void)getFeedView {
    [self showControllerClass:[MMRTimeLineController class]];
}

- (void) getARView
{
    [self showControllerClass:[CamViewController class]];
}

- (void) getMepView{
    [self showControllerClass:[MapViewController class]];
}

- (void) getDaysView{
    [self showControllerClass:[CalendarViewController class]];
}

- (void) getInputView{
    [self showControllerClass:[MMRInputViewController class]];
}

- (void) getSetting{
  //  [self showControllerClass:[MMRDetailViewController class]];
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    switch (indexPath.row) {
        case TimeLine:
            [self getFeedView];
            break;
            
        case CamView:
            [self getARView];
           
            break;
            
        case Map:
            [self getMepView];
            
            break;
            
        case Days:
            [self getDaysView];
            
            break;
            
        case NewEntry:
            [self getInputView];
            
            break;
        case Setting:
            //Test init DetailView
            [self getSetting];
           
            break;
    }
}


@end
