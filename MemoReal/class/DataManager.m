//
//  DataManager.m
//  Memoreal
//
//  Created by Treechot Shompoonut on 03/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "DataManager.h"
#import "MMRModelClass.h"
#import "Places.h"
#import "Locations.h"
#import "Addresses.h"
#import "Memos.h"
#import "Images.h"
#import "Tags.h"


@interface DataManager()
{
    NSDateFormatter *formatter;
   
    NSDictionary * currentAddress;
    NSArray * myPlace;
}

@end
@implementation DataManager

-(id) init
{
    self = [super init];
    if(self)
    {
        [self setDateFormat];
        [self setContext];
      
        myPlace = [[NSArray alloc] init];
        currentAddress = [[NSDictionary alloc] init];
        
    }
    
    
    return self;
}

-(void)setContext
{
    context = [[MMRModelClass sharedDataModel] mainContext];
}

-(void)setDateFormat
{
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, dd MMM yyyy hh:mm:ss a"]; //hh:mm:ss a z 
}


-(NSNumber *)getAttributeIdByTime:(NSDate *)timeNow
{
    NSNumber * ident;
    
    
    [formatter stringFromDate:timeNow];
    NSString *ftime = [NSString stringWithFormat:@"%.0f", [timeNow timeIntervalSince1970]];
    
   
    ident = [NSNumber numberWithInt:ftime.intValue];
    
    
    
    return ident;
}


-(void)addPlaceWithName:(NSString *)placeName
            geoLocation:(CLLocation *)currentLocation
             memoDetail:(NSString *)detail image:(NSString *)imageTag andTags:(NSString *)tagsName

{
    ///Add location
    
    locId = [self getAttributeIdByTime:currentLocation.timestamp];
    NSString *timeStamp = [formatter stringFromDate:currentLocation.timestamp];
    NSDate *now = [NSDate date];
    
    
    geoTag = [NSEntityDescription insertNewObjectForEntityForName:@"Locations" inManagedObjectContext:context];
    
    double lat,lon ;
    lat = currentLocation.coordinate.latitude;
    lon =currentLocation.coordinate.longitude;
    [geoTag setLocid:[NSString stringWithFormat:@"%@", locId]];
    [geoTag setLatitude:[NSNumber numberWithDouble:lat]];
    [geoTag setLongitude:[NSNumber numberWithDouble:lon]];
    [geoTag setTimeStamp:timeStamp];
    
    
    ///Add place
    placeId = [self getAttributeIdByTime:now];
    aPlace = [NSEntityDescription insertNewObjectForEntityForName:@"Places" inManagedObjectContext:context];
    [aPlace setPlaceId:[NSString stringWithFormat:@"%@", placeId]];
    [aPlace setPname:placeName];
    [aPlace setLocid:[NSString stringWithFormat:@"%@", locId]];
    
    
    ///Momos
    newMemo = [NSEntityDescription insertNewObjectForEntityForName:@"Memos" inManagedObjectContext:context];
    [newMemo setLocid:[NSString stringWithFormat:@"%@", locId]];
    [newMemo setDetail:detail];
    [newMemo setImgCount:[NSNumber numberWithInt:1]];
    [newMemo setTimeAdded:[formatter stringFromDate:now]];
    
   
    //Images
    img = [NSEntityDescription insertNewObjectForEntityForName:@"Images" inManagedObjectContext:context];
    [img setLocid:[NSString stringWithFormat:@"%@", locId]];
    [img setImgTag:imageTag];
    [img setImgid:[NSString stringWithFormat:@"%@", placeId]];
    
    //Tags
    aTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tags" inManagedObjectContext:context];
    [aTag setTagKey:@"none"];
    [aTag setTagName:tagsName];
    //[aTag setMemos:newMemo];
    
    
    geoTag.place = aPlace;
    aPlace.loc = geoTag;
    
    newMemo.place = aPlace;
    aTag.memos = newMemo;
    img.memo = newMemo;
    [[aPlace mutableSetValueForKey:@"memos"] addObject:newMemo];
    [[newMemo mutableSetValueForKey:@"tags"] addObject:aTag];
    [[newMemo mutableSetValueForKey:@"images"] addObject:img];

    
    //[context save:nil];
    
    NSError *error = nil;
    if (![context save:&error]) {
        
        abort();
    }
           
}



-(NSEntityDescription *)setEntityDescriptionByName:(NSString *)entityName
{
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
}


-(void)updateMemoWithName:(NSString *)placeName memoDetail:(NSString *)memDatail tags:(NSString *)memTags
             andTimestamp:(NSString *)dateCreated
{
   
    NSError *error = nil;
    NSFetchRequest *fetchMemos = [[NSFetchRequest alloc] init];
    [fetchMemos setEntity:[self setEntityDescriptionByName:@"Memos"]];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeAdded CONTAINS %@", dateCreated]; //Thursday, 22 Aug 2013
    [fetchMemos setPredicate:predicate];
    NSArray *searchObj = [context executeFetchRequest:fetchMemos error:&error];
    
    if (searchObj != nil) {
        
        for (Memos *memo in searchObj) {
            //NSUInteger count = [searchObj count]; // May be 0 if the object has been deleted.
            
            Places  *place = memo.place;
            place.pname = placeName;
            memo.detail = memDatail;
            
        
            NSSet *tags = memo.tags;
        
            
            for (Tags *tag in tags) {
                tag.tagName = memTags;
            }
            
            [context save:&error];
            
            
        }//End for
        if (![context save:&error]) {
           
            abort();
        }
        
    }//End if
    else {
        
        NSLog(@"Fetch failed : %@", error);
    }

}



- (NSMutableArray *)getARDataObject
{
    NSArray *objKey = [NSArray arrayWithObjects:@"nid", @"title", @"lat", @"lon", nil];
    self.arData = [[NSMutableArray alloc] init];
    NSMutableArray *value  = [[NSMutableArray alloc] init];
    [self.arData removeAllObjects];
        
   
    NSFetchRequest *fetchLocation = [[NSFetchRequest alloc] init];
        [fetchLocation setEntity:[self setEntityDescriptionByName:@"Locations"]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchLocation error:&error];
    for (Locations *loc in fetchedObjects) {
        Places *place = loc.place;
        
        NSString *name = [NSString stringWithFormat:@"%@", place.pname];
        NSString *pid = [NSString stringWithFormat:@"%@", place.placeId];
        NSString *latString = [NSString stringWithFormat:@"%.6f", loc.latitude.doubleValue];
        NSString *lonString = [NSString stringWithFormat:@"%.6f", loc.longitude.doubleValue];
        NSArray *obj = [NSArray arrayWithObjects:pid, name, latString, lonString, nil];
       
        [value addObject:obj];
       
    }
    
    for (int i = 0; i < [value count]; i++) {
        NSArray *arr = [NSArray arrayWithArray:[value objectAtIndex:i]];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:arr forKeys:objKey];
        [self.arData addObject:dict];
        
    }
    
   
    return [self arData];

}


- (NSMutableArray *)getDataForFeeding
{
    NSArray *objKey = [NSArray arrayWithObjects:@"nid", @"title", @"lat", @"lon", @"detail", @"timeAdded", @"tags", @"imageTag", nil];
   
    self.memoData = [[NSMutableArray alloc] init];
    NSMutableArray *value  = [[NSMutableArray alloc] init];
    [self.memoData removeAllObjects];
     NSError *error = nil;
  
    NSFetchRequest *fetchMemos = [[NSFetchRequest alloc] init];
    
    [fetchMemos setEntity:[self setEntityDescriptionByName:@"Memos"]];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchMemos error:&error];
    
    
    for (Memos *memo in fetchedObjects) {
        Places *place = memo.place;
        Locations *loc = memo.place.loc;
        
        NSSet *tags = memo.tags;
        NSSet *images = memo.images;
       
        
        NSString *pid = [NSString stringWithFormat:@"%@", place.placeId];
        NSString *name = [NSString stringWithFormat:@"%@", place.pname];
        NSString *latString = [NSString stringWithFormat:@"%.6f", loc.latitude.doubleValue];
        NSString *lonString = [NSString stringWithFormat:@"%.6f", loc.longitude.doubleValue];
        NSString *memDesc = memo.detail;
        NSString *timeAdded = memo.timeAdded;
        
        for (Tags *tag in tags) {
            for (Images *image in images) {
                NSString *imgName = image.imgTag;
                if (imgName.length == 0 || imgName == nil) {
                    imgName = @"";
                }
    
                NSString *tagName = tag.tagName;
                        
            NSArray *obj = [NSArray arrayWithObjects:pid, name, latString, lonString, memDesc, timeAdded, tagName, imgName, nil];
              
            [value addObject:obj];
           
            }
        }
        
        
    }
    
   
    for (int i = 0; i < [value count]; i++) {
        NSArray *arr = [NSArray arrayWithArray:[value objectAtIndex:i]];
       
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:arr forKeys:objKey];
        [self.memoData addObject:dict];
        
    }
    
    return [self memoData];
    
}

-(NSMutableArray *)getMemoByARId:(NSString *)nid
{
    NSArray *objKey = [NSArray arrayWithObjects:@"nid", @"title", @"lat", @"lon", @"detail", @"timeAdded", @"tags", @"imageTag", nil];
    
    self.memoData = [[NSMutableArray alloc] init];
    NSMutableArray *value  = [[NSMutableArray alloc] init];
    [self.memoData removeAllObjects];
    NSError *error = nil;
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self setEntityDescriptionByName:@"Places"]]; 
   
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeId == %@", nid]; 
    [request setPredicate:predicate];
    NSArray *searchObj = [context executeFetchRequest:request error:&error];
    
    if (searchObj != nil) {
       
        
        Places *place = [searchObj objectAtIndex:0];
        Locations *loc = place.loc;
       
        
        
        NSString *pid = [NSString stringWithFormat:@"%@", place.placeId];
        NSString *name = [NSString stringWithFormat:@"%@", place.pname];
        NSString *latString = [NSString stringWithFormat:@"%.6f", loc.latitude.doubleValue];
        NSString *lonString = [NSString stringWithFormat:@"%.6f", loc.longitude.doubleValue];
        
        
        NSSet *memos = place.memos;
        for (Memos *memo in memos) {
            NSString *memDesc = memo.detail;
            NSString *timeAdded = memo.timeAdded;
            
            NSSet *tags = memo.tags;
            NSSet *images = memo.images;
           
            for (Tags *tag in tags) {
                for (Images *image in images) {
                    NSString *imgName = image.imgTag;
                    if (imgName.length == 0 || imgName == nil) {
                        imgName = @"";
                    }
                    
                    NSString *tagName = tag.tagName;
                    
                    NSArray *obj = [NSArray arrayWithObjects:pid, name, latString, lonString, memDesc, timeAdded, tagName, imgName, nil];
                   
                    [value addObject:obj];
                    
                }
            }
            
        }
        
        for (NSArray *a in value) {
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:a forKeys:objKey];
            
            [self.memoData addObject:dict];
            
        }
        
    }
    else {
       
        NSLog(@"Fetch failed : %@", error);
    }
    
    return [self memoData];
}


-(NSMutableArray *)getEventForCalendar
{
    NSMutableArray *value  = [[NSMutableArray alloc] init];
    NSError *error = nil;
    
    NSFetchRequest *fetchMemos = [[NSFetchRequest alloc] init];
    
    [fetchMemos setEntity:[self setEntityDescriptionByName:@"Memos"]];
    [fetchMemos setResultType:NSDictionaryResultType];
    [fetchMemos setReturnsDistinctResults:YES];
    [fetchMemos setPropertiesToFetch:@[@"timeAdded"]];
    
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchMemos error:&error];
    
    if (fetchedObjects == nil) {
        
        NSLog(@"No Event added");
    }
    else {
        if ([fetchedObjects count] > 0) {
           
           
            for (NSDictionary *dict in fetchedObjects) {
                NSString *t = [dict objectForKey:@"timeAdded"];
                [value addObject:t];
                
            }
        }
    }
    
    
    return value;

}

-(NSMutableArray *)getMemoByDate:(NSString *)dateString
{
   
    NSArray *objKey = [NSArray arrayWithObjects:@"nid", @"title", @"lat", @"lon", @"detail", @"timeAdded", @"tags", @"imageTag", nil];
    
    self.memoData = [[NSMutableArray alloc] init];
    NSMutableArray *value  = [[NSMutableArray alloc] init];
    [self.memoData removeAllObjects];
    
    NSError *error = nil;
    
    
    NSFetchRequest *fetchMemos = [[NSFetchRequest alloc] init];
    [fetchMemos setEntity:[self setEntityDescriptionByName:@"Memos"]];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeAdded CONTAINS %@", dateString]; //Thursday, 22 Aug 2013
    [fetchMemos setPredicate:predicate];
    NSArray *searchObj = [context executeFetchRequest:fetchMemos error:&error];
    
    if (searchObj != nil) {
        
        for (Memos *memo in searchObj) {
           
            
            Places  *place = memo.place;
            Locations *loc = memo.place.loc;
            
            
            
            NSString *pid = [NSString stringWithFormat:@"%@", place.placeId];
            NSString *name = [NSString stringWithFormat:@"%@", place.pname];
            NSString *latString = [NSString stringWithFormat:@"%.6f", loc.latitude.doubleValue];
            NSString *lonString = [NSString stringWithFormat:@"%.6f", loc.longitude.doubleValue];
            NSString *memDesc = memo.detail;
            NSString *timeAdded = memo.timeAdded;
            
            NSSet *tags = memo.tags;
            NSSet *images = memo.images;
           
                for (Tags *tag in tags) {
                    for (Images *image in images) {
                        NSString *imgName = image.imgTag;
                        if (imgName.length == 0 || imgName == nil) {
                            imgName = @"";
                        }
                       
                        
                        NSString *tagName = tag.tagName;
                        NSArray *obj = [NSArray arrayWithObjects:pid, name, latString, lonString, memDesc, timeAdded, tagName, imgName, nil];
                        [value addObject:obj];
                       
                    }
                }
           
            
            for (NSArray *a in value) {
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjects:a forKeys:objKey];
                
                [self.memoData addObject:dict];

            }
                        
        }//End for
        
    }//End if
    else {
        
        NSLog(@"Fetch failed : %@", error);
    }
   
    return [self memoData];
}




-(void)deletePlacebyName:(NSString *)placeName andCoordinate:(CLLocationCoordinate2D)degrees
{
    NSString *stringLa = [NSString stringWithFormat:@"%.6f", degrees.latitude];
    NSString *stringLo = [NSString stringWithFormat:@"%.6f", degrees.longitude];

    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self setEntityDescriptionByName:@"Places"]];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pname == %@", placeName]; 
    [request setPredicate:predicate];
    NSArray *searchObj = [context executeFetchRequest:request error:&error];
    
    if (searchObj != nil) {
        
       
    for (Places *place in searchObj) {
        
    
        Locations *loc = place.loc;
    
        
        NSString *name = [NSString stringWithFormat:@"%@", place.pname];
        
        NSString* slat = [NSString stringWithFormat:@"%.6f",loc.latitude.doubleValue];
        NSString* slon = [NSString stringWithFormat:@"%.6f",loc.longitude.doubleValue];
       
        
        if ([name isEqualToString:placeName]) {
            if ([slat isEqualToString:stringLa] && [slon isEqualToString:stringLo]) {
                 
                [context deleteObject:place];
                [context save:&error];
            }
        }
    }
        
    if (![context save:&error]) {
       // NSLog(@"Can't delete data: %@, %@", error, [error userInfo]);
        abort();
    }
    }

}

-(NSDictionary *)setDefaultAddress
{
    
    NSMutableDictionary *defaultAdress = [[NSMutableDictionary alloc] init];
    
    NSArray  *addressKey = [NSArray arrayWithObjects:@"street", @"county", @"postCode", @"country", nil];
    
    NSArray *addressValue = [NSArray arrayWithObjects:@"unknown", @"unknown", @"unknown", @"unknown", nil];
    
    
    for (int i=0; i<4; i++) {
        
        [defaultAdress setObject:[addressValue objectAtIndex:i] forKey:[addressKey objectAtIndex:i]];
    }
    
    
    
    return defaultAdress;
    
}


@end
