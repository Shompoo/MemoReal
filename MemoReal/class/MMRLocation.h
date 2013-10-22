//
//  MMRLocation.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 26/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class MMRLocation;

@protocol MMRLocationDelegate

- (void)locationDidUpdate:(CLLocation *)newLocation;

@end

@interface MMRLocation : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *location;
    CLLocationCoordinate2D currentLoc;
    BOOL recently ;

}

@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;
@property (nonatomic, retain) NSNumber * placeId;
@property (nonatomic, retain) CLLocation *myCurrentlocation;

@property (weak, nonatomic) id <MMRLocationDelegate> delegate;
- (void)isLocationUpdated:(CLLocation *)storeLocation;


- (void) startLocationUpdate;
- (void) stopLocationUpdate;
- (CLLocationCoordinate2D) getCurrent2Dlocation;

- (void) addressFromLocation :(CLLocation *)currentLocation;
- (CLLocation *)getMyCurrentLocation;
- (NSDictionary *)getAddressDict;


+(id)shareInstance;
@end
