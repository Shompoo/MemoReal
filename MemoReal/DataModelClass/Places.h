//
//  Places.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 08/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Addresses, Locations, Memos;

@interface Places : NSManagedObject

@property (nonatomic, retain) NSString * locid;
@property (nonatomic, retain) NSString * placeId;
@property (nonatomic, retain) NSString * pname;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) Addresses *address;
@property (nonatomic, retain) Locations *loc;
@property (nonatomic, retain) NSSet *memos;
@end

@interface Places (CoreDataGeneratedAccessors)

- (void)addMemosObject:(Memos *)value;
- (void)removeMemosObject:(Memos *)value;
- (void)addMemos:(NSSet *)values;
- (void)removeMemos:(NSSet *)values;

@end
