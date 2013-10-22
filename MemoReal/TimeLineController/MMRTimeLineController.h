//
//  MMRTimeLineController.h
//  MemorealT2
//
//  Created by Treechot Shompoonut on 12/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "menuView.h"
#import "FeedCollectionView.h"
#import "MMRInputViewController.h"
#import "MMRDetailViewController.h"
#import "CamViewController.h"
#import "MMRLocation.h"


@interface MMRTimeLineController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, MMRLocationDelegate>
{
    UIButton *arButt;
    UIButton *mapButt;
    UIButton *daysButt;
    UIButton *addButt;
    UIView *status;
    
    UILabel *placelabel;
    UILabel *latLabel;
    UILabel *lonLabel;
    UILabel *pCount;
    UILabel *pWord;
    double lat, lon;
    NSString * imgName;
    
    CLLocationCoordinate2D coordinate;
    CLLocation *location;
    
    BOOL recently;
    int geoTry;
    
    NSDictionary *placeMarkDict;
    NSMutableArray * arData;
    NSMutableArray *memoData;
}

@property (nonatomic, copy) CLLocation *storedLocation;

@property (strong, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) MMRInputViewController *inputViewController;
@property (nonatomic, strong) CamViewController *arViewController;

@property (strong, nonatomic) MMRLocation *locationMGR;
@property (strong, nonatomic) MMRDetailViewController *detailViewController;

@property (strong, nonatomic) menuView *menuV;

@end
