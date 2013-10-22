//
//  Locations.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 08/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Places;

@interface Locations : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locid;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * timeStamp;
@property (nonatomic, retain) Places *place;

@end
