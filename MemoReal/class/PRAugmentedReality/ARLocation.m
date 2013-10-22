///
//  LocationWork.h
//  PrometAR
//
// Created by Geoffroy Lesage on 4/24/13.
// Copyright (c) 2013 Promet Solutions Inc.
//
//  ARLocation.m
//  MemoReal
//
//  Created by Treechot Shompoonut on 30/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "ARLocation.h"

@implementation ARLocation

@synthesize gotPreciseEnoughLocation;
@synthesize currentLat, currentLon;

-(id) init
{
    self = [super init];
    if(self)
    {
        gotPreciseEnoughLocation = NO;    
        [self setLocationManager];
        [self setDateFormat];
        motionManager = [[CMMotionManager alloc] init];
        
        
    }
    [self startLocationUpdate];
    
    return self;
}

+(id)shareInstance{
    static ARLocation *__instance = nil;
    if(__instance == nil){
        __instance = [[ARLocation alloc] init];
    }
    
    return __instance;
}


- (void) setLocationManager
{
    if (locationManager == nil){
        
        locationManager = [[CLLocationManager alloc]init];
        
	}
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    locationManager.delegate = self;
    
}

- (void) setDateFormat
{
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss a z"];
}

- (void) startLocationUpdate
{
    [locationManager startUpdatingLocation];
    
}

- (void) stopLocationUpdate
{
    [locationManager stopUpdatingLocation];
}


- (CLLocationCoordinate2D) getCurrent2Dlocation
{
    [self startLocationUpdate];
    
       
    //Assign location value
    self.lat = location.coordinate.latitude;
    self.lon = location.coordinate.longitude;
    
    currentLoc =  CLLocationCoordinate2DMake(self.lat , self.lon);
    
    return currentLoc;
}


#pragma mark -
#pragma mark CLLocationManagerDelegate


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    location = [locations lastObject];
    
    //Get timeStemp of lastest location update
    NSDate * eventDate = [(CLLocation *)[locations lastObject] timestamp];
    
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 1.0 || location.horizontalAccuracy < 100 ) {
        //Assign location value
        self.lat = location.coordinate.latitude;
        self.lon = location.coordinate.longitude;
        
        gotPreciseEnoughLocation = YES;
        currentLat = location.coordinate.latitude;
        currentLon = location.coordinate.longitude;
        
        
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
        currentHeading =  fmod(newHeading.trueHeading, 360.0);

}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if(error.code == kCLErrorDenied) {
        [locationManager stopUpdatingLocation];
    } else if(error.code == kCLErrorLocationUnknown) {
        // retry
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Retrieving location error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}



#pragma mark - AR delegate

-(void)arStopUpdateLocation
{
    [locationManager stopUpdatingLocation];
}


-(void)pollAccellerometerForVerticalPosition {
    
    CMAcceleration acceleration = motionManager.accelerometerData.acceleration;
    
    rollingZ  = (acceleration.z * kFilteringFactor) + (rollingZ  * (1.0 - kFilteringFactor));
    rollingX = (acceleration.y * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    
	if (rollingZ > 0.0)      currentInclination = inc_avg(atan(rollingX / rollingZ) + M_PI / 2.0);
	else if (rollingZ < 0.0) currentInclination = inc_avg(atan(rollingX / rollingZ) - M_PI / 2.0);
	else if (rollingX < 0)   currentInclination = inc_avg(M_PI/2.0);
	else if (rollingX >= 0)  currentInclination = inc_avg(3 * M_PI/2.0);
}

# pragma mark - Accellerometer

-(void)startAR:(CGSize)deviceScreenSize {
    
    deviceViewHeight = deviceScreenSize.height;
    
    [locationManager startUpdatingHeading];
    [motionManager startAccelerometerUpdates];
    
    if (accelTimer) {
        accelTimer = nil;
    }
    accelTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_RATE
                                                  target:self
                                                selector:@selector(pollAccellerometerForVerticalPosition)
                                                userInfo:nil
                                                 repeats:YES];
}


# pragma mark - Callback functions

-(CGRect)getCurrentFramePosition {
    float y_pos = currentInclination*VERTICAL_SENS;
    float x_pos = X_CENTER+(0-currentHeading)*HORIZ_SENS;
    
    return CGRectMake(x_pos, y_pos+60, OVERLAY_VIEW_WIDTH, deviceViewHeight);
}
-(int)getARObjectXPosition:(ARObject*)arObject {
    CLLocationCoordinate2D coordinates;
    coordinates.latitude        = [[arObject getARObjectData][@"latitude"] doubleValue];
    coordinates.longitude       = [[arObject getARObjectData][@"longitude"] doubleValue];
    
    double latitudeDistance     = max(coordinates.latitude, currentLat) - min(coordinates.latitude, currentLat);
    double longitudeDistance    = max(coordinates.longitude, currentLon) - min(coordinates.longitude, currentLon);
    
    int x_position = DEGREES(atanf(longitudeDistance/(latitudeDistance*lat_over_lon)));
    
    if ((coordinates.latitude < currentLat) && (coordinates.longitude > currentLon))
        x_position = 180-x_position;
    
    else if ((coordinates.latitude < currentLat) && (coordinates.longitude < currentLon))
        x_position += 180;
    
    else if ((coordinates.latitude > currentLat) && (coordinates.longitude < currentLon))
        x_position += 270;
    
    return x_position*HORIZ_SENS;
}


@end
