//
//  Memos.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 08/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Images, Places, Tags;

@interface Memos : NSManagedObject

@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * imgCount;
@property (nonatomic, retain) NSString * locid;
@property (nonatomic, retain) NSString * timeAdded;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Places *place;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Memos (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Images *)value;
- (void)removeImagesObject:(Images *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addTagsObject:(Tags *)value;
- (void)removeTagsObject:(Tags *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
