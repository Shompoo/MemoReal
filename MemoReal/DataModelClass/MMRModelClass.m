//
//  MMRModelClass.m
//  Memoreal
//
//  Created by Treechot Shompoonut on 29/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "MMRModelClass.h"

@interface MMRModelClass ()
{
    
}

@end

@implementation MMRModelClass

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainContext = _mainContext;



+(id)sharedDataModel{
    static MMRModelClass *__instance = nil;
    if(__instance == nil){
        __instance = [[MMRModelClass alloc] init];
    }
    
    return __instance;
}

+ (id)insertEntity: (NSString*)entityName InManagedObjectContext:(NSManagedObjectContext *)moc_
{
    
    //NSString * tableName = entityName;
    NSParameterAssert(moc_);
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc_];
}


- (NSString *)modelName {
    return @"Memoreal";
}

- (NSString *)pathToModel {
    return [[NSBundle mainBundle] pathForResource:[self modelName]
                                           ofType:@"momd"];
}

- (NSString *)storeFilename {
    return [[self modelName] stringByAppendingPathExtension:@"sqlite"];
}

- (NSString *)pathToLocalStore {
    return [[self documentsDirectory] stringByAppendingPathComponent:[self storeFilename]];
}

- (NSString *)documentsDirectory {
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSManagedObjectContext *)mainContext {
    if (_mainContext == nil) {
        _mainContext = [[NSManagedObjectContext alloc] init];
        _mainContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    }
    
    return _mainContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        NSURL *storeURL = [NSURL fileURLWithPath:[self pathToModel]];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:storeURL];
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        //NSLog(@"SQLITE STORE PATH: %@", [self pathToLocalStore]);
        NSURL *storeURL = [NSURL fileURLWithPath:[self pathToLocalStore]];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]
                                             initWithManagedObjectModel:[self managedObjectModel]];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSError *error = nil;
        
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:options
                                       error:&error]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:NSUnderlyingErrorKey];
            NSString *reason = @"Could not create persistent store.";
            NSException *exc = [NSException exceptionWithName:NSInternalInconsistencyException
                                                       reason:reason
                                                     userInfo:userInfo];
            @throw exc;
        }
        
        _persistentStoreCoordinator = psc;
    }
    
    return _persistentStoreCoordinator;
}

- (NSArray *)FetchAllobjectInEntity:(NSString *)entityName
{
    // Define our table/entity to use
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self mainContext]];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *results = [[_mainContext executeFetchRequest:request error:&error] mutableCopy];
    if (!results) {
        // Handle the error.
        // This is a serious error and should advise the user to restart the application
        [NSException raise:@"Fetch data failed" format:@"Error : %@", [error localizedDescription]];
        NSLog(@"Error : %@", error);
    }
    NSMutableArray *allObject = [[NSMutableArray alloc] initWithArray:results];
    
    NSLog(@"This entityL %@ has  %d obj", entityName, allObject.count);
    
    return allObject;
    
}




//// Test Fetching

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
{
   
    return [self respondsToSelector:@selector(entityInManagedObjectContext:)] ?
    [self performSelector:@selector(entityInManagedObjectContext:) withObject:context] :
    [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

+ (NSArray *)findAllObjects;
{
    NSManagedObjectContext *context = [[self sharedDataModel] mainContext];  //[[[UIApplication sharedApplication] delegate] managedObjectContext];
    return [self findAllObjectsInContext:context];
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context;
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        //handle errors
        NSLog(@"%@", [error localizedDescription]);
    }
    return results;
}


/*- (void)deleteObjectByEntityname:(NSString *)entityname
 {
 
 // Define our table/entity to use
 NSEntityDescription *entity = [NSEntityDescription entityForName:entityname inManagedObjectContext:_mainContext];
 // Setup the fetch request
 NSFetchRequest *request = [[NSFetchRequest alloc] init];
 [request setEntity:entity];
 
 NSError *error;
 NSArray *results = [[_mainContext executeFetchRequest:request error:&error] mutableCopy];
 
 //[allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
 
 //error handling goes here
 for (NSManagedObject * obj in results) {
 [_mainContext deleteObject:obj];
 }
 
 [_mainContext save:nil];
 
 //_allEvents = [[NSMutableArray alloc] initWithArray:results];
 NSLog(@"Deleted all events, EventDataModel.allEvents : %d", results.count);
 
 }*/
 


 

@end