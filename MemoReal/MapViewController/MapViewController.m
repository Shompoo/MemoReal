//
//  MapViewController.m
//  MemoReal
//
//  Created by Treechot Shompoonut on 19/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "MapViewController.h"
#import "NVSlideMenuController.h"
#import "MMRAnnotation.h"
#import "DataManager.h"
#import "PlaceHelper.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController ()
{
    NSMutableArray *arData;
    CLLocationCoordinate2D destDegree;
    BOOL mapForDest;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t ;
@end

@implementation MapViewController
@synthesize orig, dest;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
        self.title = NSLocalizedString(@"MeMoReal", @"MeMoReal");
        mapForDest = NO;

    }
    return self;
}

- (id)initWithDestinationPlace:(PlaceHelper *)endPoint
{
    self = [super init];
    if (self) {
        // Custom initialization
        dest = [[PlaceHelper alloc] init] ;
        dest.name = endPoint.name; //@"Terminate";
        dest.description = endPoint.description; //@"Your destination";
        dest.latitude = endPoint.latitude; //51.2769590;
        dest.longitude = endPoint.longitude; //1.0814230;
        destDegree = CLLocationCoordinate2DMake(dest.latitude, dest.longitude);
       
        mapForDest = YES;
        
        
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapView setDelegate:self];
    
    // NavigationBar setting
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f]];
    self.navigationController.navigationBar.alpha = 0.5f;
    self.navigationController.navigationBar.translucent = YES;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationItem.leftBarButtonItem = [self slideOutBarButton];
    
    self.mapView.showsUserLocation = YES;
    
    
    
    
    DataManager *dataMGR = [[DataManager alloc] init];
    arData = [[NSMutableArray alloc] init];
    arData = [dataMGR getARDataObject];
    
    if (mapForDest == NO) {
        [self mapAnnotateWithData];
    }else{
       
        [self performSelector:@selector(getRouteFromAPI) withObject:nil afterDelay:3.0];
    }
    
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

#pragma mark -MapView delegate

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
     
    //if ([dest isKindOfClass:[PlaceHelper class]] && dest != nil)
    if (mapForDest == YES)
    {
        //destDegree = CLLocationCoordinate2DMake(dest.latitude, dest.longitude);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(destDegree, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [self.mapView setRegion:region animated:NO];
        
        orig = [[PlaceHelper alloc] init] ;
        orig.name = @"Originate";
        orig.description = @"Current location";
        orig.latitude = [userLocation coordinate].latitude;  //51.2999000;
        orig.longitude = [userLocation coordinate].longitude; //1.0700000;
        
        //////////[self showRouteFrom:orig to:dest];
        
    }else{
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [self.mapView setRegion:region animated:NO];
        
        //
        
    }
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    static NSString *identifier = @"MMRAnnotation";
    if ([annotation isKindOfClass:[MMRAnnotation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
       // annotationView.image=[UIImage imageNamed:@"orangepin"];
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return annotationView;
    }
    
    return nil;

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    CLLocationCoordinate2D mydes;
    if ([dest isKindOfClass:[NSNull class]] || mapForDest==NO) {
        
        MKUserLocation *userLocation = self.mapView.userLocation;
        
        mydes = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    }else{
        mydes = CLLocationCoordinate2DMake(dest.latitude, dest.longitude);
    }
    
    
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:mydes addressDictionary:nil];
    
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = dest.name ;
    
    [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking}];
   
    
}



-(void)mapAnnotateWithData
{
    
    if (arData.count > 0 ) {
        for (NSDictionary *place in arData) {
            NSString *title = [place objectForKey:@"title"];
            
            CLLocationCoordinate2D coordinates;
            coordinates.latitude = [[place objectForKey:@"lat"] doubleValue];
            coordinates.longitude = [[place objectForKey:@"lon"] doubleValue];
            
            MMRAnnotation *annotation = [[MMRAnnotation alloc] initWithCoorDinate:coordinates title:title];
            
            [self.mapView addAnnotation:annotation];
        }
    }
    else{
        
        NSLog(@"No data saved");
    }

    
    
}


#pragma mark - Routing

-(void)getRouteFromAPI
{
    MKUserLocation *userLocation = self.mapView.userLocation;
    
    orig = [[PlaceHelper alloc] init] ;
    orig.name = @"Originate";
    orig.description = @"Current location";
    
    orig.latitude = [userLocation coordinate].latitude;  //51.2999000;
    orig.longitude = [userLocation coordinate].longitude; //1.0700000;
    
    [self showRouteFrom:orig to:dest];
    
}


//
//  Helper method
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded :(CLLocationCoordinate2D)f to: (CLLocationCoordinate2D) t {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		
        
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
    CLLocation *first = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:f.latitude] floatValue] longitude:[[NSNumber numberWithFloat:f.longitude] floatValue] ];
    CLLocation *end = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:t.latitude] floatValue] longitude:[[NSNumber numberWithFloat:t.longitude] floatValue] ];
	[array insertObject:first atIndex:0];
    [array addObject:end];
	return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	
    NSError *error;
	
    NSString *apiResponse = [NSString  stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"points:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    
	return [self decodePolyLine:[encodedPoints mutableCopy]:f to:t];
}

-(void) centerMap {
    
	MKCoordinateRegion region;
    
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLocation = [routes objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat + 0.018;
	region.span.longitudeDelta = maxLon - minLon + 0.018;
    
	[_mapView setRegion:region animated:YES];
}

-(void)showRouteFrom:(PlaceHelper *)origin to:(PlaceHelper *)destination
{
	
	if(routes) {
		[_mapView removeAnnotations:[_mapView annotations]];
    
	}
	
	
	//MMRAnnotation *ending = [[MMRAnnotation alloc] initWithPlace:destination];
	MMRAnnotation *ending = [[MMRAnnotation alloc] initWithCoorDinate:destDegree title:dest.name];
    
	[_mapView addAnnotation:ending];
	
	routes = [self calculateRoutesFrom:CLLocationCoordinate2DMake(origin.latitude, origin.longitude) to:ending.coordinate];
    
	[self updateRouteView];
	//[self centerMap];
}

-(void) updateRouteView {
    [_mapView removeOverlays:_mapView.overlays];
    
    CLLocationCoordinate2D pointsToUse[[routes count]];
    for (int i = 0; i < [routes count]; i++) {
        CLLocationCoordinate2D coords;
        CLLocation *loc = [routes objectAtIndex:i];
        coords.latitude = loc.coordinate.latitude;
        coords.longitude = loc.coordinate.longitude;
        pointsToUse[i] = coords;
    }
    MKPolyline *lineOne = [MKPolyline polylineWithCoordinates:pointsToUse count:[routes count]];
    [_mapView addOverlay:lineOne];
    
    
}

#pragma mark mapView delegate functions

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *lineview=[[MKPolylineView alloc] initWithOverlay:overlay] ;
        
        lineview.strokeColor=[UIColor colorWithRed:227.0f/255.0f green:7.0f/255.0f blue:103.0f/255.0f alpha:0.6];
        lineview.lineWidth=8.0;
        return lineview;
    }
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
