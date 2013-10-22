//
//  Tags.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 08/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Memos;

@interface Tags : NSManagedObject

@property (nonatomic, retain) NSString * tagKey;
@property (nonatomic, retain) NSString * tagName;
@property (nonatomic, retain) Memos *memos;

@end
