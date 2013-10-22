//
//  MapViewController.h
//  MemoReal
//
//  Created by Treechot Shompoonut on 19/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#
#import "PlaceHelper.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    UIImageView* routeView;
	NSArray* routes;
}


@property (strong, nonatomic) IBOutlet MKMapView *mapView;

-(void)showRouteFrom:(PlaceHelper *)origin to:(PlaceHelper *)destination;
- (id)initWithDestinationPlace:(PlaceHelper *)endPoint;

@property (strong, nonatomic) PlaceHelper *orig;
@property (strong, nonatomic) PlaceHelper *dest;

@end
