//
//  MMRModelClass.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 29/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MMRModelClass : NSObject

+ (id)sharedDataModel;

//+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (id)insertEntity: (NSString*)entityName InManagedObjectContext:(NSManagedObjectContext *)moc_;


@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSManagedObjectContext *)mainContext;
- (NSString *)modelName;
- (NSString *)pathToModel;
- (NSString *)storeFilename;
- (NSString *)pathToLocalStore;
- (NSString *)documentsDirectory;

////Test Fetching
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context;

@end
