//
//  MMRAnnotation.h
//  MemoReal
//
//  Created by Treechot Shompoonut on 19/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "PlaceHelper.h"

@interface MMRAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D cooridinate;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, retain) id<MKAnnotation> annotation;

-(id)initWithCoorDinate:(CLLocationCoordinate2D)loc2D title:(NSString *)title;



@end
