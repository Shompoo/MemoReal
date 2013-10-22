//
//  ImageStore.m
//  TestText
//
//  Created by Treechot Shompoonut on 01/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "ImageStore.h"

@implementation ImageStore


-(id)init
{
    self = [super init];
    if (self) {
        dic = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

+(id)sharedStore{
    static ImageStore *__instance = nil;
    if(__instance == nil){
        __instance = [[ImageStore alloc] init];
    }
    
    return __instance;
}


- (void) setImage: (UIImage *)img forKey:(NSString *) imgKey
{
    [dic setObject:img forKey:imgKey];
}

- (UIImage *)imageForKey:(NSString *)imgKey
{
    return [dic objectForKey:imgKey];
}

-(void)deleteImageForKey:(NSString *)imgKey
{
    if (imgKey) return;
    [dic removeObjectForKey:imgKey];
}



@end
