//
//  ExportView.h
//  MemoReal
//
//  Created by Treechot Shompoonut on 28/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface ExportView : UIView
{

    NSAttributedString* attString;
}
@property (retain, nonatomic) NSAttributedString* attString;
@end
