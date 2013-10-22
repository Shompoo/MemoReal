//
//  ExportView.m
//  MemoReal
//
//  Created by Treechot Shompoonut on 28/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "ExportView.h"

@implementation ExportView

@synthesize attString;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable(); //1
    CGPathAddRect(path, NULL, self.bounds );
    
    
    attString = [[NSAttributedString alloc]
                                     initWithString:@"Hello core text world!"];// autorelease]; //2
    
    
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attString); //3
    CTFrameRef frame =
    CTFramesetterCreateFrame(framesetter,
                             CFRangeMake(0, [attString length]), path, NULL);
    
    CTFrameDraw(frame, context); //4
    
    
    
    
    
    CFRelease(frame); //5
    CFRelease(path);
    CFRelease(framesetter);
}

@end
