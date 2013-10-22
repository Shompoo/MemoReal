//
//  MMRInputViewController.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 02/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "MMRLocation.h"
#import "CamViewController.h"
#import "MMRDetailViewController.h"
#import "RNGridMenu.h"


@interface MMRInputViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, RNGridMenuDelegate>
{
    UIImagePickerController *imagePicker;
    UIImageView *addedView;
    UIImage *storedImage;
    NSString *name;
    NSString *desc ;
    NSString *tags ;
}

@property (strong, nonatomic) MMRLocation *mmrLocation;
@property (nonatomic, retain) NSDictionary * placeDict;
@property (nonatomic, strong) CamViewController *arViewController;
@property (nonatomic, strong) MMRDetailViewController *detailViewController;


@property (strong, nonatomic) IBOutlet UIView *shadowView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *tagsField;
@property (strong, nonatomic) IBOutlet UITextView *commentView;
@property (strong, nonatomic) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UIButton *button2;
@property (strong, nonatomic) IBOutlet UIButton *button3;
@property (strong, nonatomic) IBOutlet UIButton *cam;
@property (strong, nonatomic) IBOutlet UIButton *fav;


-(id)initWithPlaceName: (NSString *)placeName memoDetail:(NSString *)detail tagsName:(NSString *)tag andTimeStamp:(NSString *)time;
- (void)setCustomInputView;
- (void)setBorderForView:(UIView *)view;
- (void)setShadowForView:(UIView *)view;
- (void)subviewForTextField;
- (void) saveImage: (UIImage *)outputImage;
- (UIImage *)resizeImageWithImage: (UIImage *)originalImage andSize:(CGSize)newSize;


- (IBAction)TakePhoto:(id)sender;

@end
