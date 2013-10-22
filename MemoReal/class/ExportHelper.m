//
//  ExportHelper.m
//  MemorealT2
//
//  Created by Treechot Shompoonut on 24/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//  Extented from  OCPDFGen  Created by Oliver Rickard on 3/18/12.
//            Copyright (c) 2012 UC Berkeley. All rights reserved.
//
//

#import "ExportHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "TextMarkupParser.h"

#import "ExportView.h"


@implementation ExportHelper

#define DOC_WIDTH  612
#define DOC_HEIGHT 792
#define LEFT_MARGIN 50
#define RIGHT_MARGIN 50
#define TOP_MARGIN 50
#define BOTTOM_MARGIN 50

#define IMG_WIDTH 690
#define IMG_HEIGHT 320
#define LEFT_M 20
#define RIGHT_M 20
#define TOP_M 20
#define BOTTOM_M 20



- (NSAttributedString *)stringAttributeForPDFfromString:(NSString *)str
{
    TextMarkupParser * parser = [[TextMarkupParser alloc] init];
    
    return [parser attrStringFromMarkup:str];
}


-(NSString *)generatePDFFromAttributedString:(NSAttributedString *)str andImage:(UIImage *)image
{
   
    CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
    
    
    NSString * newUniqueIDString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, newUniqueID));
    
    NSString *fileName = [NSString stringWithFormat:@"%@.pdf", newUniqueIDString];
    
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pdfPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    

    int fontSize = 14;
    NSString *font = @"HelveticaNeue";
    UIColor *color = [UIColor blackColor];
    
   
    int CURRENT_TOP_MARGIN = TOP_MARGIN;
    
    int FIRST_PAGE_TOP_MARGIN = TOP_MARGIN;
    
    CGRect a4Page = CGRectMake(0, 0, DOC_WIDTH, DOC_HEIGHT);
    
    
    if (!UIGraphicsBeginPDFContextToFile(pdfPath, a4Page, nil )) {
        NSLog(@"error creating PDF context");
        return nil;
    }
    
    
    BOOL done = NO;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CFRange currentRange = CFRangeMake(0, 0);
    
    
    
    CGContextSetTextDrawingMode (context, kCGTextFill);
    CGContextSelectFont (context, [font cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    //Initialize image
    UIImage * img = [self resizeImageWithImage:image andSize:CGSizeMake(320, 240)];
    
    
    
    // Initialize an attributed string.
    CFAttributedStringRef attrString = (__bridge CFAttributedStringRef)str;
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    
    int pageCount = 1;
    
    do {
        UIGraphicsBeginPDFPage();
        
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        if(pageCount == 1) {
            CURRENT_TOP_MARGIN = FIRST_PAGE_TOP_MARGIN +  img.size.height + 10 ;
           
            CGPoint imgPoint = CGPointMake((DOC_WIDTH/2)-(img.size.width/2), 50);
            CGRect imageFrame = CGRectMake(imgPoint.x, imgPoint.y, img.size.width, img.size.height);
            [img drawInRect:imageFrame];
            

            [self drawBorder];
            
        } else {
            CURRENT_TOP_MARGIN = TOP_MARGIN;
        }
        
         
        CGRect bounds = CGRectMake(LEFT_MARGIN,
                                   CURRENT_TOP_MARGIN,
                                   DOC_WIDTH - RIGHT_MARGIN - LEFT_MARGIN,
                                   DOC_HEIGHT - CURRENT_TOP_MARGIN - BOTTOM_MARGIN);
        
        CGPathAddRect(path, NULL, bounds);
        
        // Create the frame and draw it into the graphics context
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, currentRange, path, NULL);
        
        if(frame) {

            
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 0, bounds.origin.y);
            CGContextScaleCTM(context, 1, -1);
            CGContextTranslateCTM(context, 0, -(bounds.origin.y + bounds.size.height));
            CTFrameDraw(frame, context);
            CGContextRestoreGState(context);
            
            // Update the current range based on what was drawn.
            currentRange = CTFrameGetVisibleStringRange(frame);
            currentRange.location += currentRange.length;
            currentRange.length = 0;
            
            
        }
		
		
        if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)attrString))
            done = YES;
        
        pageCount++;
    } while(!done);
    
    UIGraphicsEndPDFContext();
    
   
    return pdfPath;
}


- (void) drawBorder
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    UIColor *borderColor = [UIColor orangeColor];
    CGRect rectFrame = CGRectMake(RIGHT_MARGIN, 330, DOC_WIDTH - RIGHT_MARGIN - LEFT_MARGIN, 1);
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, 1);
    CGContextStrokeRect(currentContext, rectFrame);
}


#pragma mark Draw and Save image




- (UIImage *)resizeImageWithImage: (UIImage *)originalImage andSize:(CGSize)newSize
{
    
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    CGContextRef imagecontext = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(imagecontext, kCGInterpolationMedium);
    
    CGContextFillRect(imagecontext, CGRectMake(0,0,newSize.width,newSize.height));
    
    
    [originalImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    return resizedImage;
}


-(UIView *)drawViewForTextWithTitle:(NSString *)titleStr body:(NSString *)bodyStr andDatetime:(NSString *)dt
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [titleLabel setNumberOfLines:1];
    [titleLabel setText:titleStr];
    
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, 348, 275)];
    [textView setFont:[UIFont systemFontOfSize:12.0f]];
    [textView setText:bodyStr];
    
  
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 295, 330, 25)];
    [dateLabel setTextAlignment:NSTextAlignmentRight];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 355, 320)];
    
    [dateLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [dateLabel setNumberOfLines:1];
    [dateLabel setText:dt];
    
    [view addSubview:titleLabel];
    [view addSubview:textView];
    [view addSubview:dateLabel];
    [view setBackgroundColor:[UIColor whiteColor]];
    return view;
    
}

- (UIImage *) imageWithView:(UIView *)view
{
        
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

-(UIImage*) drawTextImage:(UIImage *)txtImage inImage:(UIImage*)image
{
    
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 0.0);
    
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    //CGPoint point = CGPointMake(image.size.width+5, 10);
    
    CGRect rect = CGRectMake(335, 5, txtImage.size.width, txtImage.size.height);
    
    
    [txtImage drawInRect:CGRectIntegral(rect)];
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    
    
    return newImage;
}


-(UIImage *)leftImageBYimage:(UIImage *)image
{
    NSLog(@"Start drawing");
  
    CGRect imageRact = CGRectMake(0, 0, 320, IMG_HEIGHT);
    CGSize imageSize = CGSizeMake(IMG_WIDTH, IMG_HEIGHT);
   
            UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
   
    [[UIColor whiteColor] set];
    CGContextFillRect( UIGraphicsGetCurrentContext(), CGRectMake( 0, 0, IMG_WIDTH, IMG_HEIGHT ));
    
           //Set image to draw
            [image drawInRect:imageRact];
        
	UIImage * newimg = UIGraphicsGetImageFromCurrentImageContext();
    
   UIGraphicsEndImageContext();
    
    return newimg;

       
}



- (void) saveImage: (UIImage *)outputImage
{
   
    
    CFUUIDRef newUniqueID = CFUUIDCreate (kCFAllocatorDefault);
    
    NSString * newUniqueIDString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, newUniqueID));
    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *dataPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Exportfiles"];
    if (![fileManager fileExistsAtPath:dataPath])
        [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
   
    imageName = [NSString stringWithFormat:@"%@.jpg", newUniqueIDString];
    
   
    
    NSString *savingFile = [NSString stringWithFormat:@"Documents/Exportfiles/%@", imageName];
    
    NSString  *imageFile = [NSHomeDirectory() stringByAppendingPathComponent:savingFile];
    
  
    [UIImageJPEGRepresentation(outputImage, 1.0) writeToFile:imageFile atomically:YES];
    
   
    
}



@end
