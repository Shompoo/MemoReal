//
//  ARObject.m
//  PrometAR
//
// Created by Geoffroy Lesage on 4/24/13.
// Copyright (c) 2013 Promet Solutions Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ARObject.h"
#import "DataManager.h"
#import "MMRDetailViewController.h"


@interface ARObject ()
{
    NSMutableArray *memoData;
}
@end


@implementation ARObject

@synthesize arTitle, distance;

- (id)initWithId:(int)newNid
           title:(NSString*)newTitle
     coordinates:(CLLocationCoordinate2D)newCoordinates
andCurrentLocation:(CLLocationCoordinate2D)currLoc {
    
    self = [super init];
    if (self) {
        nid = newNid;
        
        arTitle = [[NSString alloc] initWithString:newTitle];
        
        lat = newCoordinates.latitude;
        lon = newCoordinates.longitude;
        
        distance = @([self calculateDistanceFrom:currLoc]);
        
        [self.view setTag:newNid];
    }
    return self;
}

-(double)calculateDistanceFrom:(CLLocationCoordinate2D)user_loc_coord {
    
    CLLocationCoordinate2D object_loc_coord = CLLocationCoordinate2DMake(lat, lon);
    
    CLLocation *object_location = [[CLLocation alloc] initWithLatitude:object_loc_coord.latitude
                                                              longitude:object_loc_coord.longitude];
    CLLocation *user_location = [[CLLocation alloc] initWithLatitude:user_loc_coord.latitude
                                                            longitude:user_loc_coord.longitude];
    
    return [object_location distanceFromLocation:user_location];
}
-(NSString*)getDistanceLabelText {
    if (distance.doubleValue > POINT_ONE_MILE_METERS)
         return [NSString stringWithFormat:@"%.2f mi", distance.doubleValue*METERS_TO_MILES];
    else return [NSString stringWithFormat:@"%.0f ft", distance.doubleValue*METERS_TO_FEET];
}

- (NSDictionary*)getARObjectData {
    NSArray *keys = @[@"id",@"title", @"latitude", @"longitude", @"distance"];
    
    NSArray *values = @[@(nid),
                       arTitle,
                       @(lat),
                       @(lon),
                       distance];
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

-(void)viewDidLoad
{
    UITapGestureRecognizer *tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                         action:@selector(gestureTapped:)];// autorelease];
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [titleL setText:arTitle];
    
    [distanceL setText:[self getDistanceLabelText]];
}


#pragma touch-events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Add something to make some highlighted effect
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Add something to make some highlighted effect
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Add something to make some highlighted effect
   
}


#pragma mark - using gestureRecognizer

- (void)gestureTapped:(UIGestureRecognizer *)recon{
    
    if (recon.state == UIGestureRecognizerStateEnded) {
        
        NSString *pId = [NSString stringWithFormat:@"%d", nid];
        
        DataManager *dataMGR = [[DataManager alloc] init];
        memoData = [[NSMutableArray alloc] init];
        [memoData removeAllObjects];
        
       
        memoData = [dataMGR getMemoByARId:pId];
        
      
        if (memoData.count > 0)
        {
                            
                if ([self.delegate respondsToSelector:@selector(arObjectControl:didTappedForValue:)]) {
                    [self.delegate arObjectControl:self didTappedForValue:memoData];
                }
        }                 
        
        
    }
       
}





@end
