//
//  ExportHelper.h
//  MemorealT2
//
//  Created by Treechot Shompoonut on 24/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface ExportHelper : NSObject
{
    NSString * imageName;
}
- (UIImage *) imageWithView:(UIView *)view;
- (NSAttributedString *)stringAttributeForPDFfromString:(NSString *)str;
- (NSString *)generatePDFFromAttributedString:(NSAttributedString *)str andImage:(UIImage *)image ;


-(UIImage *)leftImageBYimage:(UIImage *)image;
- (void) saveImage: (UIImage *)outputImage;
-(UIView *)drawViewForTextWithTitle:(NSString *)titleStr body:(NSString *)bodyStr andDatetime:(NSString *)dt;
-(UIImage*) drawTextImage:(UIImage *)txtImage inImage:(UIImage*)image;



@end
