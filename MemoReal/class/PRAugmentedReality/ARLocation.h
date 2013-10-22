////
//  LocationWork.h
//  PrometAR
//
// Created by Geoffroy Lesage on 4/24/13.
// Copyright (c) 2013 Promet Solutions Inc.
//
//  ARLocation.h
//  MemoReal
//
//  Created by Treechot Shompoonut on 30/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

#import "ARObject.h"

@interface ARLocation : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *location;
    CLLocationCoordinate2D currentLoc;
    
    NSDateFormatter * formatter;
    
    
    CMMotionManager * motionManager;
    NSTimer *accelTimer;
   
    
    // Major variables
    float currentHeading;
    float currentInclination;
    
    // Others
    float rollingZ;
    float rollingX;
    
    float rollingZ2;
    float rollingX2;
    
    float deviceViewHeight;

}
@property (nonatomic, assign) double lat, lon;
@property (nonatomic, assign) BOOL  gotPreciseEnoughLocation;
@property (nonatomic, assign) double currentLat;
@property (nonatomic, assign) double currentLon;

- (void) startLocationUpdate;
- (void) stopLocationUpdate;


-(void)startAR:(CGSize)deviceScreenSize;

-(CGRect)getCurrentFramePosition;
-(int)getARObjectXPosition:(ARObject*)arObject;


-(void)arStopUpdateLocation;


@end
