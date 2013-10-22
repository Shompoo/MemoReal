//
//  MMRLocation.m
//  Memoreal
//
//  Created by Treechot Shompoonut on 26/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "MMRLocation.h"


@interface MMRLocation ()
{
    NSDateFormatter * formatter;
    NSMutableDictionary * currentAddress;
    NSArray * myPlace;
   
}



@end

@implementation MMRLocation

@synthesize myCurrentlocation;

-(id) init
{
    self = [super init];
    if(self)
    {
        currentAddress = [[NSMutableDictionary alloc] initWithDictionary:[self setDefaultAddress]];
        [self setLocationManager];
        [self setDateFormat];
        
        
    }
    [self startLocationUpdate];
    
    return self;
}

+(id)shareInstance{
    static MMRLocation *__instance = nil;
    if(__instance == nil){
        __instance = [[MMRLocation alloc] init];
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
        
        recently = YES;
        myCurrentlocation = nil;
        myCurrentlocation = [locations lastObject];
       
    }
    
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

- (CLLocation *)getMyCurrentLocation
{
    
    NSDate * eventDate = [myCurrentlocation timestamp];
    
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
        if (abs(howRecent) < 5.0 || location.horizontalAccuracy < 100) {
            
            
            return myCurrentlocation;
            
        }
        else{
            [self startLocationUpdate];
            [self performSelector:@selector(getMyCurrentLocation) withObject:nil afterDelay:1.0];
        
        }
    
    
    return myCurrentlocation;
    
}


- (void)isLocationUpdated:(CLLocation *)storeLocation
{
    NSTimeInterval t = [[storeLocation timestamp] timeIntervalSinceNow];
   
    if (t< - 60) {
        
        [self startLocationUpdate];
        
         ///Deley action to get Curent Location for debugging
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            
            if (myCurrentlocation != nil) {
                [self.delegate locationDidUpdate:myCurrentlocation];
               
                [self stopLocationUpdate];
                
            }
            if (myCurrentlocation == nil) {
                
                [self performSelector:@selector(isLocationUpdated:) withObject:storeLocation afterDelay:1.0];
            }
            

            
        });////End delay
               
    }
    
    
}


- (void) addressFromLocation :(CLLocation *)currentLocation
{
       
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
   

    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       
                       if (error){
                           NSString *msg = @"Sorry,the system can't reverse locations to address. Please check the Internet connection";
                           [self alert:@"Error" withDetails:msg];
                           
                           return;
                           
                       }
                       
                       if(placemarks && placemarks.count > 0)
                           
                       {
                           // [nearby thoroughfare] - street
                           //[nearby locality] - town
                           CLPlacemark *nearby = [placemarks objectAtIndex:0];
                          
                           
                          
                           //////// add default address /////
                           NSString *adminArea = ([nearby administrativeArea].length > 0 ? [nearby thoroughfare] : @"Unknown");
                           NSString *subAdminArea = ([nearby subAdministrativeArea].length > 0 ? [nearby thoroughfare] : @"Unknown");
                          
                           NSString *street = ([nearby thoroughfare].length > 0 ? [nearby thoroughfare] : @"Unknown");
                           NSString *locality = ([nearby locality].length > 0 ? [nearby locality] : @"Unknown");
                           NSString *postalCode = ([nearby postalCode].length > 0 ? [nearby postalCode] : @"Unknown");
                           NSString *country = ([nearby country].length > 0 ? [nearby country] : @"Unknown");
                           
                          // NSArray *result = [NSArray arrayWithObjects:[nearby thoroughfare],
                            //                  [nearby locality], [nearby postalCode],
                              //                [nearby country], nil];
                           NSArray *result = [NSArray arrayWithObjects:street, subAdminArea, adminArea, locality, postalCode, country, nil];
                           
                          
                           
                           [self setPlaceMark:result];
                                                
                           
                          
                       }else{
                          
                           [self alert:@"" withDetails:@"No maching location"];
                           return;
                       }
                       
                       
                   }];
    
    //return currentAddress;
}


-(void)setPlaceMark:(NSArray *)placeDetail
{
   
   
    NSArray  *addressKey = [NSArray arrayWithObjects:@"street",@"subArea", @"adminArea", @"county", @"postCode", @"country", nil];
    
    myPlace = [NSArray arrayWithArray:placeDetail];
    
       
   
    if (myPlace.count == 0) {
       
        return;
    }
    if (myPlace.count>0) {
        //remove default setting
        [currentAddress removeAllObjects];
        
        for (int i=0; i<6; i++) {
            
            @try {
                [currentAddress setObject:[myPlace objectAtIndex:i] forKey:[addressKey objectAtIndex:i]];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
            @finally {
                
            }
        
        }
        
    }
    
        
        
    
}

-(NSDictionary *)getAddressDict
{
    return currentAddress;
}





-(NSDictionary *)setDefaultAddress
{
    
    NSMutableDictionary *defaultAdress = [[NSMutableDictionary alloc] init];
    
    NSArray  *addressKey = [NSArray arrayWithObjects:@"street",@"subArea", @"adminArea", @"county", @"postCode", @"country", nil];
    
    NSArray *addressValue = [NSArray arrayWithObjects:@"unknow",@"unknow", @"unknow", @"unknow", @"unknow", @"unknow", nil];
    
    
    for (int i=0; i<6; i++) {
      
        [defaultAdress setObject:[addressValue objectAtIndex:i] forKey:[addressKey objectAtIndex:i]];
    }
    
    
    return defaultAdress;
    
}


- (void)alert:(NSString*)title withDetails:(NSString*)details {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:details
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}



@end
