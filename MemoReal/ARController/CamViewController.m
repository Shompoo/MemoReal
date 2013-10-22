//
//  CamViewController.m
//  Memoreal
//
//  Created by Treechot Shompoonut on 29/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "CamViewController.h"

#import "ARController.h"
#import "ARObject.h"
#import "UzysSlideMenu.h"
#import "NVSlideMenuController.h"
#import "DataManager.h"

#import "MMRInputViewController.h"
#import "MMRTimeLineController.h"
#import "MMRDetailViewController.h"


@interface CamViewController ()


@property (nonatomic,strong) UzysSlideMenu *uzysSMenu;
@property (nonatomic,strong) MMRTimeLineController *feedViewController;
@property (nonatomic,strong) MMRInputViewController *inputViewController;

@end

@implementation CamViewController


-(id) init
{
    self = [super init];
    if(self)
    {
       //self.title = NSLocalizedString(@"MeMoReal", @"MeMoReal");
        
    }   
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self setLayerShadowForUIView:self.popView];
    
    if ([self captureManager] == nil) {
        self.captureManager = [[CameraSession alloc] init];
        
        if ([[self captureManager] setupCaptureSession]) {
            
            
            UIView *view = self.view;
            CGRect layerRect = view.layer.bounds;
            [[self.captureManager previewLayer] setBounds:layerRect];
            [[self.captureManager previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
            [view.layer addSublayer:[self.captureManager previewLayer]];
            [view.layer setMasksToBounds:YES];
            
        }
    }
   
    [self setSlideDownMenu];
   
    DataManager *dataMGR = [[DataManager alloc] init];
    arData = [[NSMutableArray alloc] init];
    arData = [dataMGR getARDataObject];
    if (arData.count> 0) {
        NSString *msg;
        
        if (arData.count < 2) {
            msg = [NSString stringWithFormat:@"You have %d place nearby", arData.count];
        }
        else{
            msg = [NSString stringWithFormat:@"You have %d places nearby", arData.count];
        }
        
        
        [self.countLabel setText:msg];
        [self.popView setHidden:NO];
        [self.view bringSubviewToFront:self.popView];
        [self performSelector:@selector(dissMissPopView) withObject:nil afterDelay:3.0];
    }
    
    arController = [[ARController alloc] initWithScreenSize:self.view.frame.size andDelegate:self];
    [arController setDelegate:self];
    
    
   
    
}


- (void) viewDidAppear:(BOOL)animated
{
    
    
    if (arData.count > 0) {
       
        [arController startARWithData:arData];
        
    }
    if (arData.count == 0 ) {
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your MeMoReal is Empty" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Add Place", nil];
        [alert show];
        
    }
    
   
}
-(void)dissMissPopView
{
    [self.popView setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
   
    
    [arController stopAR];
    [[self captureManager] stopCaptureSession];    
    
}





- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   /* if (buttonIndex == 0){
        //cancelButton
        
    }*/
    if (buttonIndex == 1) {
        
        
        self.inputViewController = [[MMRInputViewController alloc] initWithNibName:@"MMRInputViewController" bundle:nil];
        
        [self.navigationController pushViewController:self.inputViewController animated:NO];
       
    }
}



-(void)setSlideDownMenu
{
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"Hot Menu" image:[UIImage imageNamed:@"flower.png"] action:^(UzysSMMenuItem *item) {
        
        
    }];
    
    
    UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Timeline" image:[UIImage imageNamed:@"a2.png"] action:^(UzysSMMenuItem *item) {
        
        self.feedViewController = [[MMRTimeLineController alloc] initWithNibName:@"MMRTimeLineController" bundle:nil];
        [self.navigationController pushViewController:self.feedViewController animated:NO];
       
        
    }];
    
    UzysSMMenuItem *item2 = [[UzysSMMenuItem alloc] initWithTitle:@"Add Place" image:[UIImage imageNamed:@"Map.png"] action:^(UzysSMMenuItem *item) {
        self.inputViewController = [[MMRInputViewController alloc] initWithNibName:@"MMRInputViewController" bundle:nil];
        [self.navigationController pushViewController:self.inputViewController animated:NO];
       
    }];
    
    item0.tag = 0;
    item1.tag = 1;
    item2.tag = 2;
    
    
    self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item1,item2]];
    [self.view addSubview:self.uzysSMenu];

}



#pragma mark - AR Controller Delegate

- (void)arControllerDidSetupAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer*)cameraLayer {
    
       
    [self.view.layer addSublayer:cameraLayer];
    [self.view addSubview:arView];
    
    [self.view bringSubviewToFront:[self.view viewWithTag:1992]];
    
    [self setSlideDownMenu];
  
}

- (void)arControllerUpdateFrame:(CGRect)arViewFrame
{
    
    [[self.view viewWithTag:AR_VIEW_TAG] setFrame:arViewFrame];
}


- (void)gotProblemIn:(NSString*)problemOrigin withDetails:(NSString*)details
{
   
    
    NSString *msg = [NSString stringWithFormat:@"Error %@: %@ \n Please check location services and try again", problemOrigin, details];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    
    
    [alert show];
    
    
}


-(void)arControllerDidReciveActionForData:(NSMutableArray *)arObjectData
{
   
    NSDictionary * memoDict = [arObjectData objectAtIndex:0];
    if (!self.detailViewController) {
        
        self.detailViewController = [[MMRDetailViewController alloc]
                                     initWithPlaceName:[memoDict objectForKey:@"title"]
                                     memoDetail:[memoDict objectForKey:@"detail"]
                                     tagsName:[memoDict objectForKey:@"tags"]
                                     dateAdded:[memoDict objectForKey:@"timeAdded"]
                                     ImageName:[memoDict objectForKey:@"imageTag"]
                                     Latitude:[memoDict objectForKey:@"lat"]
                                     andLongitude:[memoDict objectForKey:@"lon"]];
        
        [self.navigationController pushViewController:self.detailViewController animated:NO];
         
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    
}

-(void)setLayerShadowForUIView:(UIView *)view
{
    view.layer.cornerRadius = 10.0f;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 2.0f;
   
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
