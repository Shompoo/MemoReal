//
//  CamViewController.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 29/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import "ARController.h"
#import "ARObject.h"
#import "MMRDetailViewController.h"
#import "CameraSession.h"





@interface CamViewController : UIViewController <ARControllerDelegate>
{
    ARController * arController;
    ARObject * arObject;
    
    NSMutableArray * arData;
    NSInteger nid;
    NSString * name;
    
}
@property (strong, nonatomic) IBOutlet UIView *popView;

@property (strong, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (retain) CameraSession *captureManager;
@property (strong, nonatomic) MMRDetailViewController *detailViewController;

@end
