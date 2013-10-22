//
//  MemoRealAppDelegate.h
//  MemoReal
//
//  Created by Treechot Shompoonut on 17/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>

@class CamViewController;


@interface MemoRealAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) CamViewController *arViewController;

//@property (strong, nonatomic) FBSession *session;

@end
