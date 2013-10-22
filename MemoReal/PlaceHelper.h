//
//  PlaceHelper.h
//  MemorealT2
//
//  Created by Treechot Shompoonut on 23/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceHelper : NSObject
{

NSString* name;
NSString* description;
float latitude;
float longitude;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end
