//
//  Images.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 08/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Memos;

@interface Images : NSManagedObject

@property (nonatomic, retain) NSString * imgid;
@property (nonatomic, retain) NSString * imgTag;
@property (nonatomic, retain) NSString * locid;
@property (nonatomic, retain) Memos *memo;

@end
