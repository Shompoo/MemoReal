//
//  CameraSession.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 30/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//@protocol CameraSessionDelegate;
@interface CameraSession : NSObject 
{
   // AVCaptureSession *captureSession;
    //AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureDeviceInput *captureAudioDeviceInput;
    AVCaptureAudioDataOutput    *captureAudioDataOutput;
   // CGSize deviceScreenResolution;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;

//@property (nonatomic,assign) id <CameraSessionDelegate> delegate;

//- (void)addVideoPreviewLayer;
//- (void)addVideoInput;
- (BOOL)setupCaptureSession;
- (void)startCaptureSession;
- (void)stopCaptureSession;

//- (void) startCamera;

@end
