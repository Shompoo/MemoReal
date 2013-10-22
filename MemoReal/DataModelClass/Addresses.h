//
//  Addresses.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 08/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Places;

@interface Addresses : NSManagedObject

@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * county;
@property (nonatomic, retain) NSString * postCode;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) Places *place;

@end
