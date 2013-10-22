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
//@synthesize delegate;


#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		//[self setCaptureSession:[[AVCaptureSession alloc] init]];
        //captureSession = [[AVCaptureSession alloc] init];
         [self registerForNotifications];
	}
	return self;
}

/*
- (void)addVideoPreviewLayer {
	//[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	//[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)addVideoInput {
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
}
 */

#pragma mark ======== Setup and teardown methods =========


- (BOOL)setupCaptureSession
{
	
	// Create the capture session
	captureSession = [[AVCaptureSession alloc] init];
    if (!captureSession) {
        NSLog(@"AVCaptureSession allocation failed!");;
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
    
    // add an observer for the interupted property, we simply log the result
    [captureSession addObserver:self forKeyPath:@"interrupted" options:NSKeyValueObservingOptionNew context:nil];
    [captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    
	// Start the capture session - This will cause the audio data output delegate method didOutputSampleBuffer
    // to be called for each new audio buffer recieved from the input device
	[self startCaptureSession];
    
    return YES;
}


// if we need to we call this to dispose of the previous capture session
// and create a new one, add our input and output and go
- (BOOL)resetCaptureSession
{
    if (captureSession) {
        [captureSession removeObserver:self forKeyPath:@"interrupted" context:nil];
        [captureSession removeObserver:self forKeyPath:@"running" context:nil];
        
        //[captureSession release];
        captureSession = nil;
    }
    
    // Create the capture session
	captureSession = [[AVCaptureSession alloc] init];
    if (!captureSession) {
        NSLog(@"AVCaptureSession allocation failed!");
        return NO;
    }
    
    if ([captureSession canAddInput: captureAudioDeviceInput]) {
        [captureSession addInput:captureAudioDeviceInput];
    } else {
        NSLog(@"Could not addInput to Capture Session!");
        return NO;
    }
    
    if ([captureSession canAddOutput:captureAudioDataOutput]) {
        [captureSession addOutput:captureAudioDataOutput];
    } else {
        NSLog(@"Could not addOutput to Capture Session!");
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
    
    // this sample always attempts to keep the capture session running without tearing it all down,
    // which means we may be trying to start the capture session while it's still
    // in some interim interrupted state (after a phone call for example) which will usually
    // get cleared up after a very short delay handle by a simple retry mechanism
    // if we still can't start, then resort to releasing the previous capture session and creating a new one
    if (captureSession.isInterrupted) {
        if (retry < 3) {
            retry++;
            NSLog(@"Capture Session interrupted try starting again...");
            [self performSelector:@selector(startCaptureSession) withObject:self afterDelay:2];
            return;
        } else {
            NSLog(@"Resetting Capture Session");
            BOOL result = [self resetCaptureSession];
            if (NO == result) {
                // this is bad, and means we can never start...should never see this
                NSLog(@"FAILED in resetCaptureSession! Cannot restart capture session!");
                return;
            }
        }
    }
    
    if (!captureSession.running) {
        NSLog(@"startCaptureSession");
        
        [captureSession startRunning];
        
        retry = 0;
    }
}

- (void)stopCaptureSession
{
    if (captureSession.running) {
        NSLog(@"stopCaptureSession");
        [captureSession stopRunning];
    }
}

#pragma mark ======== Observers =========

// observe state changes from the capture session, we log interruptions but activate the UI via notification when running
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"interrupted"] ) {
        NSLog(@"CaptureSesson is interrupted %@", (captureSession.isInterrupted) ? @"Yes" : @"No");
    }
    
    if ([keyPath isEqualToString:@"running"] ) {
        NSLog(@"CaptureSesson is running %@", (captureSession.isRunning) ? @"Yes" : @"No");
        if (captureSession.isRunning) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CaptureSessionRunningNotification" object:nil];
        }
    }
}

#pragma mark ======== Notifications =========

// notifications for standard things we want to know about
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
                                             selector:@selector(routeChangeHandler:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureSessionRuntimeError:)
                                                 name:AVCaptureSessionRuntimeErrorNotification
                                               object:nil];
}

// log any runtime erros from the capture session
- (void)captureSessionRuntimeError:(NSNotification *)notification
{
    NSError *error = [notification.userInfo objectForKey: AVCaptureSessionErrorKey];
    
    NSLog(@"AVFoundation error %d", [error code]);
}


// need to stop capture session and close the file if recording on resign
- (void)willResignActive
{
    NSLog(@"CaptureSessionController willResignActive");
    
    [self stopCaptureSession];
    
    
}

// we want to start the capture session again automatically on active
- (void)didBecomeActive
{
    NSLog(@"CaptureSessionController didBecomeActive");
    
    [self startCaptureSession];
}


// teardown
/*
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVCaptureSessionRuntimeErrorNotification
                                                  object:nil];
    
    [captureSession removeObserver:self forKeyPath:@"interrupted" context:nil];
	[captureSession removeObserver:self forKeyPath:@"running" context:nil];
    
    //[captureSession release];
	//[captureAudioDeviceInput release];
    [captureAudioDataOutput setSampleBufferDelegate:nil queue:NULL];
	//[captureAudioDataOutput release];
	
	if (_outputFile) { CFRelease(_outputFile); _outputFile = NULL; }
	
	if (extAudioFile)
        ExtAudioFileDispose(extAudioFile);
    
	if (auGraph) {
		if (didSetUpAudioUnits)
			AUGraphUninitialize(auGraph);
		DisposeAUGraph(auGraph);
	}
    
    if (currentInputAudioBufferList) free(currentInputAudioBufferList);
    if (outputBufferList) delete outputBufferList;
	
	[super dealloc];
}*/

/*
- (void) startCamera
{
   
    self.captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([self.captureSession canAddInput:videoIn]) [self.captureSession addInput:videoIn];
			else    NSLog(@"Couldn't add video input");
		} else      NSLog(@"Couldn't create video input");
	} else          NSLog(@"Couldn't create video capture device");
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CGRect layerRect = CGRectMake(0, 0,
                                  deviceScreenResolution.width,
                                  deviceScreenResolution.height);
	[self.previewLayer setBounds:layerRect];
	[cameraLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
     NSLog(@"Started Cam");
}*/
 

@end
