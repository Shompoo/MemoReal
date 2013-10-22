//
//  MMRInputViewController.m
//  Memoreal
//
//  Created by Treechot Shompoonut on 02/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "MMRInputViewController.h"
#import "NVSlideMenuController.h"
#import "ImageItem.h"
#import "ImageStore.h"
#import "MMRLocation.h"
#import "ImageItem.h"
#import "ImageStore.h"
#import "DataManager.h"
#import "MMRTimeLineController.h"
#import "RNGridMenu.h"

@interface MMRInputViewController ()
{
    ImageItem *item;
    ImageStore *store;
   
  
    CLLocationCoordinate2D location2D;
    CLLocation * location;
    DataManager *dataMGR;
    NSArray *tagsArray;
    NSArray *address;
    NSData *originalImgData;
    NSString *imageName;
    NSTimer * timer;
    BOOL isEditing;
    NSString *pname;
    NSString *mdesc;
    NSString *mtag;
    NSString *timestamp;

}

@end

@implementation MMRInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"MeMoReal", @"MeMoReal");
    }
    return self;
}


-(id)initWithPlaceName: (NSString *)placeName memoDetail:(NSString *)detail tagsName:(NSString *)tag andTimeStamp:(NSString *)time
{
    self = [self init];
    if (self)
    {
        self.title = @"Editing";
        
        pname = placeName;
        mdesc = detail;
        mtag = tag;
        timestamp = time;
       
        isEditing = YES;
        
    }
    return self;
}


-(void)SetAppearanceForNavBar
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f]];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor],UITextAttributeTextColor,
                                               [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset,
                                               [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0],UITextAttributeFont,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self SetAppearanceForNavBar];

    self.navigationItem.leftBarButtonItem = [self slideOutBarButton];
    self.navigationItem.rightBarButtonItem = [self rightNavBarItem];
    [self.view setBackgroundColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0f]];
    
    
    [self setCustomInputView];
    
    item = [[ImageItem alloc] init];
    store = [[ImageStore alloc] init];
    dataMGR = [[DataManager alloc] init];
    
    if (isEditing) {
        
       
        self.nameField.text = pname;
        self.commentView.text = mdesc;
        self.tagsField.text = mtag;
        [self.cam setHidden:YES];
    }
    else{
        NSDateFormatter *formatter ;
        formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"EEEE, dd MMM yyyy hh:mm:ss a"];
        timestamp = [formatter stringFromDate:[NSDate date]];
        
        self.mmrLocation = [[MMRLocation alloc] init];
        [self prepareDataForAdding];
    }
    
}

-(void) prepareDataForAdding
{
    ///Deley action to get Curent Location for debugging
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //code to be executed on the main queue after delay
        location = [self.mmrLocation getMyCurrentLocation];
        
       
       
       if (location != nil) {
           
           [self.mmrLocation stopLocationUpdate];
        }

    });////End delay

}


-(void)requestStartUpdateLocation:(id)sender
{
    [self.mmrLocation startLocationUpdate];
}


#pragma -mark SlideOutMenu


- (UIBarButtonItem *)rightNavBarItem
{
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(addMemo:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitleColor:[UIColor colorWithRed:0.35f green:0.51f blue:0.91f alpha:1.00f] forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [doneButton setFrame:CGRectMake(0, 0, 60, 30)];
    
    UIBarButtonItem *righrButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    return righrButton;
}



- (UIBarButtonItem *)slideOutBarButton {
    
    UIButton *menu = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 27, 18)];
    [menu addTarget:self action:@selector(slideOut:) forControlEvents:UIControlEventTouchUpInside];
    [menu setBackgroundImage:[UIImage imageNamed:@"mList.png"] forState:UIControlStateNormal];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menu];
    
    
    return menuItem;
}


#pragma mark - Event handlers

- (void)slideOut:(id)sender {
    
    [self dismissKeyboard];
    [self.slideMenuController toggleMenuAnimated:self];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.nameField resignFirstResponder];
    [self.tagsField resignFirstResponder];
    [self.commentView resignFirstResponder];
}


- (IBAction)TakePhoto:(id)sender
{
    imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else{
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES
                     completion:nil];
    
}


- (void)addMemo: (id)sender {
    
    [self dismissKeyboard];
    
    name = self.nameField.text ;
    if ([name isEqualToString:@""]) {
        [self getWarningForEmptyField:self.nameField];
        [self.nameField becomeFirstResponder];
        return;
    }
    desc = (self.commentView.text.length > 0 ? self.commentView.text : @"No detail");
    tags = (self.tagsField.text.length > 0 ? self.tagsField.text : @"");
    
    if ( storedImage!= nil) {
        
        UIImage *resizedImage = [self resizeImageWithImage:storedImage andSize:CGSizeMake(640, 320)];
        
        [self saveImage:resizedImage];
    }
    
    if (isEditing) {
        [dataMGR updateMemoWithName:name memoDetail:desc tags:tags andTimestamp:timestamp];
         location = [self prevLocation];
        
    }
    else{
    
    /****No placeMark****/
    [dataMGR addPlaceWithName:name
                  geoLocation:location
                   memoDetail:desc image:imageName andTags:tags];
    }
   
    
    ///****Success***///
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Entry has been saved" delegate:self cancelButtonTitle:@"AR" otherButtonTitles:@"Detail", @"Timeline", nil];
    //[alert show];
    [self showList];
    
}

- (void)showList
{
    NSInteger numberOfOptions = 3;
    NSArray *options = @[@"Real",
                         @"Timeline",
                         @"Detail"
                         ];
    RNGridMenu *menu = [[RNGridMenu alloc] initWithTitles:[options subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    menu.delegate = self;
    
    menu.itemFont = [UIFont boldSystemFontOfSize:18];
    menu.itemSize = CGSizeMake(150, 55);
    [menu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}



-(void)getWarningForEmptyField:(UITextField *)textField
{
    textField.layer.borderWidth = 2.0f;
    textField.layer.borderColor = [UIColor redColor].CGColor;
    textField.placeholder = @"Title can't be empty";

}

#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
{
    
    switch (itemIndex) {
        case 0:
        {
            self.arViewController = [[CamViewController alloc] init];
            
            [self.navigationController pushViewController:self.arViewController animated:YES];
            
            self.nameField.text =@"";
            self.commentView.text = @"";
            self.tagsField.text = @"";
            [addedView setImage:nil];
            
        }
            break;
        case 1:
        {
            MMRTimeLineController *timelineController = [[MMRTimeLineController alloc] initWithNibName:@"MMRTimeLineController" bundle:nil];
            
            [self.navigationController pushViewController:timelineController animated:YES];
            
            
            
            self.nameField.text =@"";
            self.commentView.text = @"";
            self.tagsField.text = @"";
            [addedView setImage:nil];
            
        }
            break;
        case 2:
        {
           
            self.detailViewController = [[MMRDetailViewController alloc] initWithPlaceName:name memoDetail:desc tagsName:tags dateAdded:timestamp ImageName:imageName Latitude:[NSNumber numberWithDouble:location.coordinate.latitude]
                                                                              andLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
            
            [self.navigationController pushViewController:self.detailViewController animated:YES];
            
            
            
            self.nameField.text =@"";
            self.commentView.text = @"";
            self.tagsField.text = @"";
            [addedView setImage:nil];
        }
            break;
        default:
            break;
    }
    
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
        {
            self.arViewController = [[CamViewController alloc] init];
            
            [self.navigationController pushViewController:self.arViewController animated:YES];
            
            self.nameField.text =@"";
            self.commentView.text = @"";
            self.tagsField.text = @"";
            [addedView setImage:nil];
           
        }
            break;
        case 1:
        {
            self.detailViewController = [[MMRDetailViewController alloc] initWithPlaceName:name memoDetail:desc tagsName:tags dateAdded:timestamp ImageName:imageName Latitude:[NSNumber numberWithDouble:location.coordinate.latitude]
                                                                              andLongitude:[NSNumber numberWithDouble:location.coordinate.longitude]];
            
            [self.navigationController pushViewController:self.detailViewController animated:YES];
            
            
            
            self.nameField.text =@"";
            self.commentView.text = @"";
            self.tagsField.text = @"";
            [addedView setImage:nil];
        }
            break;
        case 2:
        {
            MMRTimeLineController *timelineController = [[MMRTimeLineController alloc] initWithNibName:@"MMRTimeLineController" bundle:nil];
            
            [self.navigationController pushViewController:timelineController animated:YES];
            
            
            
            self.nameField.text =@"";
            self.commentView.text = @"";
            self.tagsField.text = @"";
            [addedView setImage:nil];
        }
            break;
        
    }
    
    
  
}

-(CLLocation *)prevLocation
{
     
     NSMutableArray * memoArray = [[NSMutableArray alloc] init];
     [memoArray removeAllObjects];
     memoArray = [dataMGR getMemoByDate:timestamp];
    
    //Keys @"lat", @"lon",@"timeAdded"
    double latitude, longitude;
    
     
   
         NSDictionary *memDict = [memoArray objectAtIndex:0];
         latitude = [[memDict objectForKey:@"lat"] doubleValue];
         longitude = [[memDict objectForKey:@"lon"] doubleValue];
    
        imageName = [memDict objectForKey:@"imageTag"];
    
    CLLocationCoordinate2D degrees = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocation *oldLoc = [[CLLocation alloc] initWithLatitude:degrees.latitude longitude:degrees.longitude];
    
    
    return oldLoc;
}

#pragma mark - Set Text input
- (void) setCustomInputView
{
    
    //TextView
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 310, 30)];
    self.commentView = [[UITextView alloc] initWithFrame:CGRectMake(5, 35, 310, 130)];
    self.tagsField = [[UITextField alloc] initWithFrame:CGRectMake(5, 165, 310, 30)];
    
    
    
    [self setBorderForView:_commentView];
    [self.nameField setFont:[UIFont systemFontOfSize:15]];
    [self.tagsField setFont:[UIFont systemFontOfSize:15]];
    [self.commentView setFont:[UIFont systemFontOfSize:17]];
    [self.commentView setDelegate:self];
    
    
    self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 190)];
    [self.shadowView setBackgroundColor:[UIColor whiteColor]];
    
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.borderWidth = 1.0f;
  
    [self setBorderForView:_shadowView];
    [self setShadowForView:_shadowView];
    
    [self.view addSubview:_shadowView];
    [self.view addSubview:_nameField];
    [self.view addSubview:_commentView];
    [self.view addSubview:_tagsField];
    [self subviewForTextField];
    
    [self.nameField setDelegate:self];
    [self.nameField becomeFirstResponder];
    /////
    [self.view setNeedsLayout];
    
    
       
}

- (void)setBorderForView:(UIView *)view
{
    //Border
    [view.layer setBorderColor: [[UIColor colorWithRed:181/255.0 green:179/255.0 blue:177/255.0 alpha:0.4f] CGColor]];
    [view.layer setBorderWidth: 1.0];
    [view.layer setBorderColor: [[UIColor colorWithRed:181/255.0 green:179/255.0 blue:177/255.0 alpha:0.4f] CGColor]];
    [view.layer setBorderWidth: 1.0];
    
}

- (void)setShadowForView:(UIView *)view
{
    //Shadow
    [view.layer setShadowColor:[[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0] CGColor]];
    [view.layer setShadowOpacity:0.7f];
    [view.layer setShadowOffset: CGSizeMake(2.0f, 2.0f)];
    [view.layer setShadowRadius:2.0f];
    
    view.layer.shouldRasterize = YES;
}

- (void)subviewForTextField
{
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(5, 3, 22, 22)];
    
    UIView *paddingViewB = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
    
    
    UIView *paddingViewF = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIImageView *imgVF = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 16, 16)];
    
    imgV.image = [UIImage imageNamed:@"locationpin"];
    imgV.alpha = 0.5f;
    imgV.opaque = NO;
    imgV.contentMode = UIViewContentModeScaleAspectFit;
    
        
    //Button
    self.fav = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fav.frame = CGRectMake(2, 4, 22, 22);
    self.fav.layer.cornerRadius = 10.0f;
    self.fav.clipsToBounds = YES;
    [self.fav setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    self.fav.alpha = 0.2f;
    
    
    
    imgVF.image = [UIImage imageNamed:@"tags"];
    imgVF.alpha = 0.5f;
    imgVF.opaque = NO;
    imgVF.contentMode = UIViewContentModeScaleAspectFit;
    
    [paddingView addSubview:imgV];
    
    [paddingViewB addSubview:_fav];
    [paddingViewF addSubview:imgVF];
    
    _nameField.leftView = paddingView;
    _nameField.leftViewMode = UITextFieldViewModeAlways;
    _nameField.rightView = paddingViewB;
    _nameField.rightViewMode = UITextFieldViewModeAlways;
    _nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    _tagsField.leftView = paddingViewF;
    _tagsField.leftViewMode = UITextFieldViewModeAlways;
    _tagsField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    _nameField.placeholder = @"Name your place";
    _tagsField.placeholder = @"Tags:";
    
    
    
    //Button
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 28)];
    addedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 25)];
    addedView.layer.cornerRadius = 10.0f;
    
   
    addedView.opaque = NO;
    addedView.contentMode = UIViewContentModeScaleToFill;
   
    
    self.cam = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(35, 0, 30, 25);
    self.cam.frame = frame;
 
    self.cam.layer.cornerRadius = 10.0f;
    self.cam.clipsToBounds = YES;
   
    [self.cam setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    self.cam.alpha = 0.6f;
    [backView addSubview:addedView];
    [backView addSubview:self.cam];
    _tagsField.rightView = backView;
    _tagsField.rightViewMode = UITextFieldViewModeAlways;
    
    
    [self.cam addTarget:self action:@selector(TakePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.fav addTarget:self action:@selector(addMemo:) forControlEvents:UIControlEventTouchUpInside];
   ////
    [self.fav setHidden:YES];
    
}

#pragma mark - TextField delegate
- (BOOL)textViewShouldBeginEditing:(UITextView*)textView {
    
  
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
   
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
       
        return NO;
    }
    
    return YES;
}




#pragma -mark UIImagePickerControllerDelegate Delegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Clear imageKey in Store
    NSString *oldImgKey = [item imageKey];
    if (oldImgKey) {
        [[ImageStore sharedStore] deleteImageForKey:oldImgKey];
    }
    
    UIImage * addedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
        
    //Create UUID for taken image for
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    
    //Create string for UUID for imgString in imageStore.h
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
       
    
    //Bridge image to store by UUID  key
    NSString *key = (__bridge NSString *)newUniqueIDString;
    [item setImageKey:key];
    
       
    

    //Store the image for key
    [[ImageStore sharedStore] setImage:addedImage forKey:[item imageKey]];
    
     storedImage = [[ImageStore sharedStore] imageForKey:[item imageKey]];
    
    UIImageWriteToSavedPhotosAlbum(storedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);

    [addedView setImage:storedImage];
       
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    //Resolve potential memory leaks
    CFRelease(newUniqueID);
    CFRelease(newUniqueIDString);
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)lastImageInStore
{
    return  [[ImageStore sharedStore] imageForKey:[item imageKey]];

}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void) saveImage: (UIImage *)outputImage
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *dataPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Images"];
    if (![fileManager fileExistsAtPath:dataPath])
        [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    NSString *ftime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    imageName = [NSString stringWithFormat:@"%@.jpg", ftime];
    
   
    
    NSString *savingFile = [NSString stringWithFormat:@"Documents/Images/%@", imageName];
    
    NSString  *imageFile = [NSHomeDirectory() stringByAppendingPathComponent:savingFile];
    
    
    [UIImageJPEGRepresentation(outputImage, 0.5) writeToFile:imageFile atomically:YES];
    
}



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

@end
