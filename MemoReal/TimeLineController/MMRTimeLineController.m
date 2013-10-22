//
//  MMRTimeLineController.m
//  MemorealT2
//
//  Created by Treechot Shompoonut on 12/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "MMRTimeLineController.h"
#import "StatusCell.h"
#import "MMRLocation.h"
#import "menuView.h"
#import "FeedLayout.h"
#import "FeedCollectionView.h"
#import "NVSlideMenuController.h"
#import "MMRInputViewController.h"
#import "DataManager.h"
#import "CamViewController.h"
#import "MMRDetailViewController.h"
#import "MapViewController.h"
#import "CalendarViewController.h"




@interface MMRTimeLineController ()
{
   
    NSTimer *timer;
    NSTimer *updateTimer;
    int numOfCell;
    NSDictionary *memoDict;
}
@end

@implementation MMRTimeLineController

@synthesize storedLocation;

#define MAX_GEOREVERSE_TRIES 2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"MeMoReal", @"MeMoReal");
        numOfCell = 1;
        geoTry = 0;
    }
    return self;
}

- (id)initWithLocation:(CLLocation *)currentLocation PlaceMark:(NSDictionary *)placeDict andPlaceCount:(NSString *)count
{
    self = [self init];
    if (self)
    {
            lat = currentLocation.coordinate.latitude;
            lon = currentLocation.coordinate.longitude;
        
    }
    return self;
    
}

-(void)SetAppearanceForNavBar
{
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f]];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor],UITextAttributeTextColor,
                                               [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset,
                                               [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0],UITextAttributeFont,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    [self setLayerShadowForUIView:self.navigationController.navigationBar];
}


- (void)viewDidLoad
{
   
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self SetAppearanceForNavBar];
    [self.view setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0]];
    

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.leftBarButtonItem = [self slideOutBarButton];
    
    
    
    self.locationMGR = [[MMRLocation alloc] init];
    [self.locationMGR setDelegate:self];
    [self.locationMGR startLocationUpdate];
    memoDict = [[NSDictionary alloc] init];
     
    //Setting for topView
    [self setStatusbar];
    ///****Remove Bar button and wider table view,Y-Origin to 120***///
    //[self setButtonBar];
    
    //Clear textLabels
    [placelabel setText:@""];
    [latLabel setText:@""];
    [lonLabel setText:@""];
    [pCount setText:@""];
    
    //Prepare data for collectionView Feed
    [self setFeedingData];
    
    //UICollectionView setting
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0]];
    [self.collectionView registerNib:[UINib nibWithNibName:@"StatusCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    [self.collectionView setDelegate:self];
    [self.collectionView reloadData];
    
    
    //Initail coordinate for showing in statusbar
    [self performSelector:@selector(initialCoordinate) withObject:nil afterDelay:2.0];
    
   
    
    updateTimer =  [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkIsLocationChange) userInfo:nil repeats:YES];
    
}


- (void) viewWillDisappear:(BOOL)animated{
    
    [timer invalidate];
    [updateTimer invalidate];
    [self.locationMGR stopLocationUpdate];
}


-(void)initialCoordinate
{
        
    location = [self.locationMGR getMyCurrentLocation];
    //storedLocation = location;
    [self setStoredLocation:location];
    
    coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
   
    
    if (location != nil) {
        
        [self gotLocationData:location];
                
    }else if (location == nil)
    {
        geoTry = geoTry + 1;
        
        
        
        if (geoTry != MAX_GEOREVERSE_TRIES) {
            [self requestStartUpdateLocation];
             timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(initialCoordinate) userInfo:nil repeats:YES];
            [self performSelector:@selector(gotLocationData:) withObject:location afterDelay:1.0];
          
        }
        if (geoTry == MAX_GEOREVERSE_TRIES) {
            [timer invalidate];
            [self setPlaceDict];
            
            return;
        }
        
          
    }
    
}


-(void)requestStartUpdateLocation
{
    [self.locationMGR startLocationUpdate];
}



-(void)gotLocationData:(CLLocation *)loc
{
   
    [self.locationMGR addressFromLocation:loc];
    
    [self performSelector:@selector(setPlaceDict) withObject:nil afterDelay:2.0];
    
    latLabel.text = [NSString stringWithFormat:@"%.2f", loc.coordinate.latitude];
    lonLabel.text = [NSString stringWithFormat:@"%.2f", loc.coordinate.longitude];
    
    [timer invalidate];
    [self.locationMGR stopLocationUpdate];

}


-(void)checkIsLocationChange
{
    
    if (storedLocation == nil && location != nil) {
        [self setStoredLocation:location];
        
    }
    
    [self.locationMGR isLocationUpdated:storedLocation];
    
    
    
}


-(void)setPlaceDict
{
    placeMarkDict = [[NSDictionary alloc] initWithDictionary:[self.locationMGR getAddressDict] copyItems:YES];
    
    
    if (placeMarkDict.count>0) {
        
       
        NSString *street = [placeMarkDict objectForKey:@"street"];
        NSString *locality = [placeMarkDict objectForKey:@"county"];
        NSString *subArea =  [placeMarkDict objectForKey:@"subArea"];
        NSString *adminArea =  [placeMarkDict objectForKey:@"adminArea"];
        
        BOOL sUnk = [street isEqualToString:@"Unknown"];
        BOOL saUnk = [adminArea isEqualToString:@"Unknown"];
        
        if (street.length > 0) {
            
            if (sUnk == NO) {
                placelabel.text = street;

            }
            if (sUnk == YES) {
                if (subArea.length > 0 && saUnk == NO) {
                    placelabel.text = subArea;
                }
                if (subArea.length > 0 && saUnk == YES) {
                    if (adminArea.length > 0 && ![adminArea isEqualToString:@"Unknown"]) {
                        placelabel.text = adminArea;
                    }
                    if (adminArea.length == 0 && locality != nil) {
                        placelabel.text = locality;
                    }
                }
            }
        }else if (street.length == 0 || locality.length == 0)
        {
            placelabel.text = @"Unknown";
            
        }

    }
    if (!placeMarkDict || placeMarkDict.count == 0) {
        placelabel.text = @"Unknown";
    }

}



-(void)setFeedingData
{
    DataManager *dataMGR = [[DataManager alloc] init];
    
     
    memoData = [[NSMutableArray alloc] init];
    [memoData removeAllObjects];
   
    memoData = [dataMGR getDataForFeeding];
    
    if (memoData.count > 0)
    {
        
        pCount.text = [NSString stringWithFormat:@"%d", memoData.count];
        if (memoData.count < 2) {
            pWord.text = @"place";
        }
        
        numOfCell = memoData.count;
        

    }else{
        
       
        pCount.text = @"0";
        pWord.text = @"place";
        numOfCell = 1;

    }
    
}

#pragma MMRLocationDelegate
- (void)locationDidUpdate:(CLLocation *)newLocation
{
    [self gotLocationData:newLocation];
    
}

#pragma -mark SlideOutMenu

- (UIBarButtonItem *)slideOutBarButton {
    
    UIButton *menu = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 27, 18)];
    [menu addTarget:self action:@selector(slideOut:) forControlEvents:UIControlEventTouchUpInside];
    [menu setBackgroundImage:[UIImage imageNamed:@"mList.png"] forState:UIControlStateNormal];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menu];
    
    
    return menuItem;
}


#pragma mark - Event handlers

- (void)slideOut:(id)sender {
    
    [self.slideMenuController toggleMenuAnimated:self];
}



-(void)setStatusbar
{

    self.topView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 110)];
    
    status = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 207, 110)];
    [status setBackgroundColor:[UIColor whiteColor]];
    [self setLayerShadowForUIView:status];
    
    
    placelabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 7, 125, 49)];
    [placelabel setFont:[UIFont boldSystemFontOfSize:20]];
    [placelabel setNumberOfLines:0];
    
    
    UILabel *lt = [[UILabel alloc] initWithFrame:CGRectMake(8, 64, 47, 21)];
    UILabel *ln = [[UILabel alloc] initWithFrame:CGRectMake(77, 64, 55, 21)];
    [lt setFont:[UIFont systemFontOfSize:12]];
    [ln setFont:[UIFont systemFontOfSize:12]];
    latLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 82, 56, 21)];
    lonLabel = [[UILabel alloc] initWithFrame:CGRectMake(77, 82, 56, 21)];
    [latLabel setFont:[UIFont systemFontOfSize:13]];
    [lonLabel setFont:[UIFont systemFontOfSize:13]];
    [latLabel setTextAlignment:NSTextAlignmentCenter];
    [lonLabel setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *s = [[UILabel alloc] initWithFrame:CGRectMake(152, 7, 46, 21)]; //(155, 7, 46, 21)
    
    pWord = [[UILabel alloc] initWithFrame:CGRectMake(156, 81, 39, 21)]; //(159, 81, 39, 21)
    pCount = [[UILabel alloc] initWithFrame:CGRectMake(132, 28, 74, 54)]; //(162, 28, 32, 54)];
    [s setFont:[UIFont systemFontOfSize:12]];
    [pWord setFont:[UIFont systemFontOfSize:12]];
    [pCount setFont:[UIFont boldSystemFontOfSize:45]];
    [pCount setAdjustsFontSizeToFitWidth:YES];
    [pCount setTextAlignment:NSTextAlignmentCenter];
    
    [self setTextColor:placelabel];
    [self setTextColor:latLabel];
    [self setTextColor:lonLabel];
    [self setTextColor:pCount];
    [self setTextColor:lt];
    [self setTextColor:ln];
    [self setTextColor:s];
    [self setTextColor:pWord];
    
    
    [status addSubview:lt];
    [status addSubview:latLabel];
    [status addSubview:ln];
    [status addSubview:lonLabel];
    [status addSubview:placelabel];
    [status addSubview:s];
    [status addSubview:pWord];
    [status addSubview:pCount];
    
    [lt setText:@"Latitude"];
    [ln setText:@"Longitude"];
    [s setText:@"SAVED"];
    [pWord setText:@"places"];
    
    
    [self.topView setBackgroundColor:[UIColor whiteColor]];
    [self.topView addSubview:status];
    
    
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(214.0f, 11.5f , 90.0f, 90.0f)];
    shadowView.layer.cornerRadius = shadowView.bounds.size.width/2 ;
    [shadowView setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
    [shadowView.layer setBorderWidth: 1.0f];
    shadowView.layer.borderColor = [UIColor colorWithRed:236/255.0 green:233/255.0 blue:233/255.0 alpha:1.0].CGColor;
    
    
    [self.topView addSubview:shadowView];
   
    
    addButt = [UIButton buttonWithType:UIButtonTypeCustom];
    addButt.frame = CGRectMake(5, 5, 80, 80);
    addButt.layer.cornerRadius = 40.0f;
    addButt.clipsToBounds = YES;
   
    [self positioningButton:addButt];
    [addButt setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [addButt setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    
    [addButt setBackgroundColor:[UIColor colorWithRed:227/255.0 green:7/255.0 blue:103/255.0 alpha:1.0]];
    [shadowView addSubview:addButt];
    
    [addButt addTarget:self action:@selector(getInputView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setLayerShadowForUIView:self.topView];
    [self.view addSubview: self.topView];

}


-(void)setButtonBar
{
    //Button1
    UIView * bottomView1 = [[UIView alloc] initWithFrame:CGRectMake(5, 120, 102, 80)];
    
    [bottomView1 setBackgroundColor:[UIColor whiteColor]];
    
    
    arButt = [UIButton buttonWithType:UIButtonTypeCustom];
    arButt.frame = CGRectMake(0, 0, 102, 80);
    
    arButt.clipsToBounds = YES;
    [self positioningButton:arButt];
    [arButt setImage:[UIImage imageNamed:@"globe"] forState:UIControlStateNormal];
    [arButt.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [arButt setTitle:@"Real" forState:UIControlStateNormal];
    [arButt setTitleColor:[self getLightGreyColorForText] forState:UIControlStateNormal];
    
    [bottomView1 addSubview:arButt];
    [self setLayerShadowForUIView:bottomView1];
    
    [self.view addSubview:bottomView1];
    [arButt addTarget:self action:@selector(getRealView:) forControlEvents:UIControlEventTouchUpInside];
    
    //Button2
    UIView * bottomView2 = [[UIView alloc] initWithFrame:CGRectMake(108, 120, 104, 80)];
    [bottomView2 setBackgroundColor:[UIColor whiteColor]];
    
    mapButt = [UIButton buttonWithType:UIButtonTypeCustom];
    mapButt.frame = CGRectMake(0, 0, 102, 80);
    mapButt.clipsToBounds = YES;
    [self positioningButton:mapButt];
    [mapButt setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [mapButt.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [mapButt setTitle:@"Map" forState:UIControlStateNormal];
    
    [mapButt setTitleColor:[self getLightGreyColorForText] forState:UIControlStateNormal];
    
    [bottomView2 addSubview:mapButt];
    [self setLayerShadowForUIView:bottomView2];
    
    [self.view addSubview:bottomView2];
    [mapButt addTarget:self action:@selector(getMapView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //Button3
    UIView * bottomView3 = [[UIView alloc] initWithFrame:CGRectMake(213, 120, 102, 80)];
    [bottomView3 setBackgroundColor:[UIColor whiteColor]];
    
    
    daysButt = [UIButton buttonWithType:UIButtonTypeCustom];
    daysButt.frame = CGRectMake(0, 0, 102, 80);
    
    daysButt.clipsToBounds = YES;
    [self positioningButton:daysButt];
    [daysButt setImage:[UIImage imageNamed:@"today"] forState:UIControlStateNormal];
    [daysButt setTitle:@"Days" forState:UIControlStateNormal];
    
    [daysButt setTitleColor:[self getLightGreyColorForText] forState:UIControlStateNormal];
    
    [bottomView3 addSubview:daysButt];
    [self setLayerShadowForUIView:bottomView3];
    
    [self.view addSubview:bottomView3];
    [daysButt addTarget:self action:@selector(getDaysView:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void)setTextColor:(UILabel *)label
{
    [label setTextColor:[UIColor colorWithRed:103/255.0 green:103/255.0 blue:103/255.0 alpha:1.0]];
}

-(UIColor *)getLightGreyColorForText
{
    return [UIColor colorWithRed:103/255.0 green:103/255.0 blue:103/255.0 alpha:1.0];

}

-(void)positioningButton:(UIButton *)button
{
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -[UIImage imageNamed:@"camera"].size.width, -25.0, 0.0)]; // Left inset is the negative of image width.
    
    [button setImageEdgeInsets:UIEdgeInsetsMake(-15.0, 30.0, 0.0, -button.titleLabel.bounds.size.width)];
    
}

-(void)setLayerShadowForUIView:(UIView *)view
{
    view.layer.masksToBounds = NO;
    
    view.layer.borderColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 1.0f;
    view.layer.contentsScale = [UIScreen mainScreen].scale;
    view.layer.shadowOpacity = 0.2f;
    view.layer.shadowRadius = 2.0f;
    view.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
}

- (IBAction)getRealView:(id)sender
{
   
   self.arViewController = [[CamViewController alloc] init];
   [self.navigationController pushViewController:self.arViewController animated:YES];
    
}

- (IBAction)getMapView:(id)sender
{
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    [self.navigationController pushViewController:mapViewController animated:YES];
    
}

- (IBAction)getDaysView:(id)sender
{
    CalendarViewController *calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil];
    [self.navigationController pushViewController:calendarViewController animated:YES];
    
}

- (IBAction)getInputView:(id)sender
{
    
    self.inputViewController = [[MMRInputViewController alloc] init];
    [self.navigationController pushViewController:self.inputViewController animated:YES];
    
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
    
}




- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    
    return numOfCell;
    
}



-(void)customiseCell:(UICollectionViewCell *)cell
{
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.masksToBounds = NO;
    
    cell.layer.borderColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0].CGColor;
    cell.layer.borderWidth = 1.0f;
    cell.layer.contentsScale = [UIScreen mainScreen].scale;
    cell.layer.shadowOpacity = 0.2f;
    cell.layer.shadowRadius = 2.0f;
    cell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.layer.shouldRasterize = YES;
}


- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StatusCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    
    
    [self customiseCell:cell];
    
    if (memoData.count > 0) {
        
       
        //Keys for object -> @"nid", @"title", @"lat", @"lon", @"detail", @"timeAdded", @"tags", @"imageTag"
        memoDict = [memoData objectAtIndex:indexPath.item];
       
        cell.placeNameLabel.text = [memoDict objectForKey:@"title"];
        cell.dateLabel.text = [memoDict objectForKey:@"timeAdded"];
        
        NSString *imageFile = [self getImageByName:[memoDict objectForKey:@"imageTag"]];
        
        cell.imageView.image = [UIImage imageWithContentsOfFile: imageFile];
        
        if (cell.imageView.image == nil) {
            cell.imageView.image = [UIImage imageNamed:@"defaultImage"];
        }

        
    }
    if(memoData == nil || memoData.count == 0)
    {
       // Set default value
    
    cell.placeNameLabel.text = @"Untitled";
    
    cell.dateLabel.text = @"<no date recored>";
    cell.imageView.image = [UIImage imageNamed:@"defaultImage"];
        
    }
    
    
    return cell;
}


-(NSString *)getImageByName:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFolder = [NSString stringWithFormat:@"%@/Images",documentsDirectory];
    
    
    NSString * imageFilePath = [imageFolder stringByAppendingPathComponent:imageName];
    
    return imageFilePath;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (memoDict.count != 0) {
        memoDict = [memoData objectAtIndex:indexPath.item];
        
        if (!self.detailViewController) {
            self.detailViewController = [[MMRDetailViewController alloc]
                                         initWithPlaceName:[memoDict objectForKey:@"title"]
                                         memoDetail:[memoDict objectForKey:@"detail"]
                                         tagsName:[memoDict objectForKey:@"tags"]
                                         dateAdded:[memoDict objectForKey:@"timeAdded"]
                                         ImageName:[memoDict objectForKey:@"imageTag"]
                                         Latitude:[memoDict objectForKey:@"lat"]
                                         andLongitude:[memoDict objectForKey:@"lon"]];
            [self.navigationController pushViewController:self.detailViewController animated:NO];
        }
    }else{
        return;
    }
    
    
   
    
     
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
