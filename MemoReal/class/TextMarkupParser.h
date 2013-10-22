//
//  TextMarkupParser.h
//  MemorealT2
//
//  Created by Treechot Shompoonut on 24/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface TextMarkupParser : NSObject
{
    
    NSString* font;
    UIColor* color;
    UIColor* strokeColor;
    float strokeWidth;
        
    NSMutableArray* images;
}

@property (retain, nonatomic) NSString* font;
@property (retain, nonatomic) UIColor* color;
@property (retain, nonatomic) UIColor* strokeColor;
@property (assign, readwrite) float strokeWidth;


@property (retain, nonatomic) NSMutableArray* images;

-(NSAttributedString*)attrStringFromMarkup:(NSString*)html;


@end
