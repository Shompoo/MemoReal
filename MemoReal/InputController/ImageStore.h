//
//  ImageStore.h
//  TestText
//
//  Created by Treechot Shompoonut on 01/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageStore : NSObject

{
    NSMutableDictionary *dic;
}

//+ (ImageStore *)sharedStore;

+(id)sharedStore;
- (void) setImage: (UIImage *)img forKey:(NSString *) imgKey;
- (UIImage *)imageForKey:(NSString *)imgKey;
- (void)deleteImageForKey:(NSString *)imgKey;


@end
