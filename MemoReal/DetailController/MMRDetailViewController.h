//
//  MMRDetailViewController.h
//  MemorealT2
//
//  Created by Treechot Shompoonut on 10/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "RNGridMenu.h"

@class DetailLayout;
@class CamViewController;
@class MMR_CamViewController;

@interface MMRDetailViewController : UIViewController <UICollectionViewDelegate,
        UICollectionViewDataSource, UITextViewDelegate, MFMailComposeViewControllerDelegate,
    RNGridMenuDelegate, FBLoginViewDelegate>

{
    

}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet  DetailLayout *customLayout;
@property (nonatomic, strong) CamViewController *arViewController;

@property (nonatomic, strong) UIImage *tempImage;

-(id)initWithPlaceName: (NSString *)placeName memoDetail:(NSString *)detail tagsName:(NSString *)tags dateAdded:(NSString *)dateTime ImageName:(NSString *)imageTag andLocation:(CLLocation *)location;

-(id)initWithPlaceName: (NSString *)placeName memoDetail:(NSString *)detail tagsName:(NSString *)tags dateAdded:(NSString *)dateTime ImageName:(NSString *)imageTag Latitude:(NSNumber *)latitude andLongitude:(NSNumber *)longitude;


@end
