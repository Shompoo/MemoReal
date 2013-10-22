//
//  CameraSession.m
//  Memoreal
//
//  Created by Treechot Shompoonut on 30/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "CameraSession.h"

@implementation CameraSession

@synthesize captureSession;
@synthesize previewLayer;



#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		
         [self registerForNotifications];
	}
	return self;
}



/////**************///////////
//  From Apple Dev example project
//

#pragma mark ======== Setup and teardown methods =========


- (BOOL)setupCaptureSession
{
	
	// Create the capture session
	captureSession = [[AVCaptureSession alloc] init];
    if (!captureSession) {
       
        return NO;
    }
	
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([captureSession canAddInput:videoIn])
				[captureSession addInput:videoIn];
			else
				NSLog(@"Couldn't add video input");
		}
		else
			NSLog(@"Couldn't create video input");
	}
	else
		NSLog(@"Couldn't create video capture device");
    
   
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    

    [captureSession addObserver:self forKeyPath:@"interrupted" options:NSKeyValueObservingOptionNew context:nil];
    [captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    [self startCaptureSession];
    
    return YES;
}


- (BOOL)resetCaptureSession
{
    if (captureSession) {
        [captureSession removeObserver:self forKeyPath:@"interrupted" context:nil];
        [captureSession removeObserver:self forKeyPath:@"running" context:nil];
        
        
        captureSession = nil;
    }
    
    // Create the capture session
	captureSession = [[AVCaptureSession alloc] init];
    if (!captureSession) {
       
        return NO;
    }
    
    if ([captureSession canAddInput: captureAudioDeviceInput]) {
        [captureSession addInput:captureAudioDeviceInput];
    } else {
       
        return NO;
    }
    
    if ([captureSession canAddOutput:captureAudioDataOutput]) {
        [captureSession addOutput:captureAudioDataOutput];
    } else {
        
		return NO;
    }
    
    // add an observer for the interupted property, we simply log the result
    [captureSession addObserver:self forKeyPath:@"interrupted" options:NSKeyValueObservingOptionNew context:nil];
    [captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    
    return YES;
}

- (void)startCaptureSession
{
    static UInt8 retry = 0;
  
    if (captureSession.isInterrupted) {
        if (retry < 3) {
            retry++;
           
            [self performSelector:@selector(startCaptureSession) withObject:self afterDelay:2];
            return;
        } else {
            
            BOOL result = [self resetCaptureSession];
            if (NO == result) {
                // this is bad, and means we can never start...should never see this
                NSLog(@"FAILED in resetCaptureSession! Cannot restart capture session!");
                return;
            }
        }
    }
    
    if (!captureSession.running) {
       
        
        [captureSession startRunning];
        
        retry = 0;
    }
}

- (void)stopCaptureSession
{
    if (captureSession.running) {
       
        [captureSession stopRunning];
    }
}

#pragma mark ======== Observers =========

// observe state changes from the capture session, we log interruptions but activate the UI via notification when running
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"interrupted"] ) {
       // NSLog(@"CaptureSesson is interrupted %@", (captureSession.isInterrupted) ? @"Yes" : @"No");
    }
    
    if ([keyPath isEqualToString:@"running"] ) {
        //NSLog(@"CaptureSesson is running %@", (captureSession.isRunning) ? @"Yes" : @"No");
        if (captureSession.isRunning) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CaptureSessionRunningNotification" object:nil];
        }
    }
}

#pragma mark ======== Notifications =========

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureSessionRuntimeError:)
                                                 name:AVCaptureSessionRuntimeErrorNotification
                                               object:nil];
}


- (void)captureSessionRuntimeError:(NSNotification *)notification
{
   // NSError *error = [notification.userInfo objectForKey: AVCaptureSessionErrorKey];
    
   // NSLog(@"AVFoundation error %d", [error code]);
}


- (void)willResignActive
{
   // NSLog(@"CaptureSessionController willResignActive");
    
    //[self stopCaptureSession];
    
    
}

- (void)didBecomeActive
{
    
    [self startCaptureSession];
}



@end
