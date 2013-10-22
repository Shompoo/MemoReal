//
//  MMRAnnotation.m
//  MemoReal
//
//  Created by Treechot Shompoonut on 19/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "MMRAnnotation.h"
#import "PlaceHelper.h"

@implementation MMRAnnotation


@synthesize coordinate, title;

-(id)initWithCoorDinate:(CLLocationCoordinate2D)loc2D title:(NSString *)t{
    self = [super init];
    if (self) {
        
        ////Woolf College lat="51.29998818" lon="1.07001592"
        coordinate = loc2D;
        [self setTitle:t];
        
    }
    return self;
}

- (NSString *)title {
    if ([title isKindOfClass:[NSNull class]])
        return @"Untitled";
    else
        return title;
}
    


@end
