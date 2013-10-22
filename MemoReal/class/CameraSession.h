//
//  CameraSession.h
//  Memoreal
//
//  Created by Treechot Shompoonut on 30/07/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface CameraSession : NSObject 
{
   
    AVCaptureDeviceInput *captureAudioDeviceInput;
    AVCaptureAudioDataOutput    *captureAudioDataOutput;
  
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;


- (BOOL)setupCaptureSession;
- (void)startCaptureSession;
- (void)stopCaptureSession;



@end
