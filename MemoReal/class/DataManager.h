//
//  DataManager.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 03/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Places, Locations, Addresses, Memos, Images, Tags;


@interface DataManager : NSObject
{
    NSManagedObjectContext * context;
    Places *aPlace ;
    Locations *geoTag;
    NSNumber *locId;
    NSNumber *placeId;
    Addresses *address;
    Memos *newMemo;
    Images *img;
    Tags *aTag;
    
}

@property (nonatomic, strong) NSMutableArray * arData;
@property (nonatomic, strong) NSMutableArray * memoData;


-(void)addPlaceWithName:(NSString *)placeName
            geoLocation:(CLLocation *)currentLocation
             memoDetail:(NSString *)detail image:(NSString *)imageTag andTags:(NSString *)tagsName;

-(void)updateMemoWithName:(NSString *)placeName memoDetail:(NSString *)memDatail tags:(NSString *)memTags
             andTimestamp:(NSString *)dateCreated;

- (NSMutableArray *)getARDataObject;
- (NSMutableArray *)getDataForFeeding;
- (NSMutableArray *)getMemoByARId:(NSString *)nid;
- (NSMutableArray *)getEventForCalendar;
- (NSMutableArray *)getMemoByDate:(NSString *)dateString;


- (NSDictionary *)setDefaultAddress;
- (NSEntityDescription *)setEntityDescriptionByName:(NSString *)entityName;

-(void)deletePlacebyName:(NSString *)placeName andCoordinate:(CLLocationCoordinate2D)degrees;


@end
