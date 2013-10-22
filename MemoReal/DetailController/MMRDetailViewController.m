//
//  MMRDetailViewController.m
//  MemorealT2
//
//  Created by Treechot Shompoonut on 10/08/2013.
//  Copyright (c) 2013 Treechot Shompoonut. All rights reserved.
//

#import "MemoRealAppDelegate.h"
#import "MMRDetailViewController.h"
#import "NVSlideMenuController.h"
#import "imageCell.h"
#import "DetailCell.h"
#import "TagsCell.h"
#import "ButtonCell.h"
#import "DetailLayout.h"
#import "CamViewController.h"
#import "MapViewController.h"
#import "CalendarViewController.h"
#import "PlaceHelper.h"
#import "ExportHelper.h"
#import "TextMarkupParser.h"
#import "DataManager.h"
#import "RNGridMenu.h"
#import "MMRTimeLineController.h"
#import "MMRInputViewController.h"

static NSString * const imageCellIdent = @"IMGCELL";
static NSString * const detailCellIdent = @"DetailCell";
static NSString * const tagsCellIdent = @"TAGSCELL";
static NSString * const buttonCellIdent = @"BUTTONCELL";

enum {
    ForImage = 0,
    ForDetail,
    ForTags,
    ForButtons
};

@interface MMRDetailViewController ()
{
    NSString * pname;
    NSString * desc;
    NSString * tagslist;
    NSString * dateSaved;
    NSString * imgName;
    CLLocation * placeLoc;
    CLLocationCoordinate2D  coordinate;
    
    NSString *pdffile;

    
}

@end

@implementation MMRDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"MeMoReal", @"MeMoReal");
        self.tabBarItem.image = [UIImage imageNamed:@"signpost"];
    }
    return self;
}

-(id)initWithPlaceName: (NSString *)placeName memoDetail:(NSString *)detail tagsName:(NSString *)tags dateAdded:(NSString *)dateTime ImageName:(NSString *)imageTag andLocation:(CLLocation *)location
{
    self = [self init];
    if (self)
    {
        
        pname = placeName;
        desc = detail;
        tagslist = tags;
        dateSaved = dateTime;
        imgName = imageTag;
        placeLoc = location;
        
    }
    return self;
}


-(id)initWithPlaceName: (NSString *)placeName memoDetail:(NSString *)detail tagsName:(NSString *)tags dateAdded:(NSString *)dateTime ImageName:(NSString *)imageTag Latitude:(NSNumber *)latitude andLongitude:(NSNumber *)longitude
{
    self = [self init];
    if (self)
    {
        
        pname = placeName;
        desc = detail;
        tagslist = tags;
        dateSaved = dateTime;
        imgName = imageTag;
        coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
       
        
    }
    return self;
}


-(void)SetAppearanceForNavBar
{
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor],UITextAttributeTextColor,
                                               [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset,
                                               [UIFont fontWithName:@"HelveticaNeue-Light" size:0.0],UITextAttributeFont,
                                               nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    [self setLayerShadowForUIView:self.navigationController.navigationBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self SetAppearanceForNavBar];
    
    self.navigationItem.leftBarButtonItem = [self slideOutBarButton];
    self.navigationItem.rightBarButtonItem = [self rightItem];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
  
    [self.view setBackgroundColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0f]];
    
    
    [self.collectionView registerClass:[imageCell class] forCellWithReuseIdentifier:imageCellIdent];
   
    [self.collectionView registerNib:[UINib nibWithNibName:@"DetailCell" bundle:nil] forCellWithReuseIdentifier:detailCellIdent];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TagsCell" bundle:nil] forCellWithReuseIdentifier:tagsCellIdent];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellWithReuseIdentifier:buttonCellIdent];
    
    [self setLayerShadowForUIView:self.collectionView];
    [self.collectionView reloadData];
    
  
    
}



#pragma -mark SlideOutMenu

- (UIBarButtonItem *)slideOutBarButton {
    
    UIButton *menu = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 27, 18)];
    [menu addTarget:self action:@selector(slideOut:) forControlEvents:UIControlEventTouchUpInside];
    [menu setBackgroundImage:[UIImage imageNamed:@"mList.png"] forState:UIControlStateNormal];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menu];
    
    
    return menuItem;
}
- (UIBarButtonItem *)rightItem {
    
    UIButton *rightmenu = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 27, 18)];
    [rightmenu addTarget:self action:@selector(showList) forControlEvents:UIControlEventTouchUpInside];
    [rightmenu setBackgroundImage:[UIImage imageNamed:@"pmore.png"] forState:UIControlStateNormal];
    UIBarButtonItem *ritem = [[UIBarButtonItem alloc] initWithCustomView:rightmenu];
    
    
    return ritem;
}




#pragma mark - Event handlers

- (void)slideOut:(id)sender {
    
    [self.slideMenuController toggleMenuAnimated:self];
}


-(NSString *)getImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFolder = [NSString stringWithFormat:@"%@/Images",documentsDirectory];
   
    
    NSString * imageFilePath = [imageFolder stringByAppendingPathComponent:imgName];
    
    return imageFilePath;
   
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 3:
            return 3;
            break;
        default:
            return 1;
            break;
    }
    
}

-(void)setLayerShadowForUIView:(UIView *)view
{
    view.layer.masksToBounds = NO;
    
    view.layer.borderColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0].CGColor;
    view.layer.borderWidth = 1.0f;
    view.layer.contentsScale = [UIScreen mainScreen].scale;
    view.layer.shadowOpacity = 0.2f;
    view.layer.shadowRadius = 2.0f;
    view.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    view.layer.shouldRasterize = YES;
}

- (void) customiseCollectionViewCell: (UICollectionViewCell *)cell
{
    cell.layer.masksToBounds = NO;
    
    cell.layer.borderColor = [UIColor colorWithRed:251/255.0 green:251/255.0 blue:242/255.0 alpha:0.3].CGColor;
    
    
    cell.layer.borderWidth = 1.0f;
    cell.layer.contentsScale = [UIScreen mainScreen].scale;
    cell.layer.shadowOpacity = 0.2f;
    cell.layer.shadowRadius = 2.0f;
    cell.layer.shadowOffset = CGSizeMake(0.5f, 0.6f);
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.layer.shouldRasterize = YES;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    switch (indexPath.section) {
        case ForImage:
        {
            imageCell *imgCell =[collectionView dequeueReusableCellWithReuseIdentifier:@"IMGCELL" forIndexPath:indexPath];
            
            
            UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 191.0f)];
            imv.backgroundColor = [UIColor clearColor];
           
            imv.opaque = NO;
            imv.contentMode = UIViewContentModeScaleToFill;
            
            NSString *imageFile = [self getImage];
          
            imv.image = [UIImage imageWithContentsOfFile: imageFile];
            
            if (imv.image == nil) {
                imv.image = [UIImage imageNamed:@"defaultImage"];
            }
            self.tempImage = imv.image;
            
            
            imgCell.backgroundView = imv;
            
            [self customiseCollectionViewCell:imgCell];
            return imgCell;
            break;
            
        }
        case ForDetail:
        {
            DetailCell *detailCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:detailCellIdent
                                                      forIndexPath:indexPath];
           
            detailCell.nameLabel.text = pname;
            detailCell.detailTextView.text = desc;
            
            detailCell.dateLabel.text = dateSaved;
            
            //detailCell.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
           
            return detailCell;
            break;
        }
        case ForTags:
        {
            TagsCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:tagsCellIdent
                                                      forIndexPath:indexPath];
            [cell.menuIconImage setImage:[UIImage imageNamed:@"tags"]];
            [cell.menuLabel setText:[NSString stringWithFormat:@"Tags: %@", tagslist]];
            //cell.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
            cell.backgroundColor = [UIColor whiteColor];
            
            
            return cell;
            break;
        }
        case ForButtons:
        {
            ButtonCell *buttCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:buttonCellIdent
                                                      forIndexPath:indexPath];
            
            [self customiseCollectionViewCell:buttCell];
           
            
            switch (indexPath.item) {
                case 0:
                {   
                    [buttCell.imageView setImage:[UIImage imageNamed:@"globe"]];
                    [buttCell.menuLabel setText:@"Real"];
                    
                }
                    break;
                case 1:
                {
                    
                    [buttCell.imageView setImage:[UIImage imageNamed:@"location"]];
                    [buttCell.menuLabel setText:@"Map"];
                }
                    break;
                case 2:
                {   [buttCell.imageView setImage:[UIImage imageNamed:@"today"]];
                    [buttCell.menuLabel setText:@"Days"];
                }
                    break;
            }
            
            
            return buttCell;
            break;
        }
    }
    
    return nil;

    
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    
    switch (indexPath.section) {
        
        case ForButtons:
            switch (indexPath.item) {
                case 0:
                {
                    
                    self.arViewController = [[CamViewController alloc] init];
                    [self.navigationController pushViewController:self.arViewController animated:YES];
                    
                    break;
                }
                    
                case 1:
                {
                    
                    PlaceHelper *pHelp = [[PlaceHelper alloc] init];
                    pHelp.name = pname ;
                    pHelp.description = @"Your destination";
                  
                    pHelp.latitude = coordinate.latitude;
                    pHelp.longitude = coordinate.longitude;
                    
                    
                    MapViewController *mapViewController = [[MapViewController alloc] initWithDestinationPlace:pHelp];
                    
                    [self.navigationController pushViewController:mapViewController animated:YES];
                    
                    break;
                    
                }
                case 2:
                {
                    
                    CalendarViewController *calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil];
                    [self.navigationController pushViewController:calendarViewController animated:YES];
                    break;
                }
            }
            break;
    }
    
    
    
}

#pragma mark - Events for object
-(void)editDetail
{
        
    
    MMRInputViewController *inputViewController = [[MMRInputViewController alloc]
                                                   initWithPlaceName:pname memoDetail:desc tagsName:tagslist andTimeStamp:dateSaved];
    [self.navigationController pushViewController:inputViewController animated:YES];
    
    
}


-(void)deletePlace
{
    DataManager *dataMGR = [[DataManager alloc] init];
    
    [dataMGR deletePlacebyName:pname andCoordinate:coordinate];
    
}


-(void)sendEmail
{
   
    NSString *emailTitle = [NSString stringWithFormat:@"Your place from Memoreal: %@", pname];
    NSString *messageBody = [NSString stringWithFormat:@"This is your day at \"%@\"", pname];;
    NSArray *toRecipents = [NSArray arrayWithObject:@""];
   
    MFMailComposeViewController *mc;
    if ([MFMailComposeViewController canSendMail]) {
        
        [self createPDFWithTitle:pname timeStamp:dateSaved memoContent:desc andImage:self.tempImage];
        
        
      
        NSArray *filepart = [pdffile componentsSeparatedByString:@"/"];
        
        NSString *filename = [filepart lastObject];
        //NSString *extension = @"pdf";
        
        
        
        NSArray *arrayPaths =
        NSSearchPathForDirectoriesInDomains(
                                            NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
        NSString *path = [arrayPaths objectAtIndex:0];
        NSString* pdfFileName = [path stringByAppendingPathComponent:filename];
        NSData *myData = [NSData dataWithContentsOfFile:pdfFileName];
        
        
        mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        [mc addAttachmentData:myData mimeType:@"application/pdf" fileName:filename];
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No email account" message:@"Please setup your email.Device > Setting > Mails" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    
    }
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)createPDFWithTitle:(NSString *)place timeStamp:(NSString *)dateTime memoContent:(NSString *)detail andImage:(UIImage *)image
{
    
    
    NSString *titleDeco = @"<font color=\"red\">" ;
    NSString *title = [NSString stringWithFormat:@"\n%@", place]; 
    NSString *addedDeco = @"<font color=\"red\">";
    NSString *added = [NSString stringWithFormat:@"\n%@", dateTime];
    NSString *contDeco = @"<font color=\"black\">";
    NSString *contentText = [NSString stringWithFormat:@"\t\t%@", detail];
    NSString * text = [NSString stringWithFormat:@"%@%@ \n%@%@ \n%@%@", titleDeco,title,addedDeco, added, contDeco, contentText ];
    
    
    ExportHelper *eHelper = [[ExportHelper alloc] init];
    
    pdffile = [eHelper generatePDFFromAttributedString:[eHelper stringAttributeForPDFfromString:text] andImage:image];
    
    
}

-(UIImage *)exportToImage
{
    ExportHelper *exph = [[ExportHelper alloc] init];
    UIImage *bgImage = [exph leftImageBYimage:self.tempImage];
    // CGPoint txtPoint = CGPointMake(340, 10);
    NSString *t = pname;
    NSString *body = [NSString stringWithFormat:@"%@\n#%@",desc, tagslist];
    NSString *dateT = dateSaved;
   
    return [exph drawTextImage:[exph imageWithView:[exph drawViewForTextWithTitle:t body:body andDatetime:dateT]] inImage:bgImage];
}


- (void)showList
{
    NSInteger numberOfOptions = 4;
    NSArray *options = @[@"Facebook",
                         @"Email",
                         @"Edit",
                         @"Delete"
                         ];
    RNGridMenu *menu = [[RNGridMenu alloc] initWithTitles:[options subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    menu.delegate = self;
   
    menu.itemFont = [UIFont boldSystemFontOfSize:18];
    menu.itemSize = CGSizeMake(150, 55);
    [menu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

-(void)facebokShare
{
    UIImage *fbImage = [self exportToImage];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbSheet setInitialText:[NSString stringWithFormat:@"Post from MemoReal: %@", pname]];
        [fbSheet addImage:fbImage];
        
        [self presentViewController:fbSheet animated:YES completion:nil];
    }
    else
    {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't post on you Facebook right now, make sure your device has your Facebook account setup" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    }

}

#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
{
    
    switch (itemIndex) {
        case 0:
            [self performSelector:@selector(facebokShare)];
            break;
        
        case 1:
            [self performSelector:@selector(sendEmail)];
            break;
        
        case 2:
        {
            [self editDetail];
        }
            break;
        case 3:
        {
            NSString *msg = [NSString stringWithFormat:@"Are you sure to delete \"%@\"?", pname];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
            [alert show];
        }
            break;
            
        default:
            break;
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   /* if (buttonIndex == 0){
        //cancelButton
    }*/
    if (buttonIndex == 1) {
       
        [self deletePlace];
        
        MMRTimeLineController *timelineViewController = [[MMRTimeLineController alloc] initWithNibName:@"MMRTimeLineController" bundle:nil];
        [self.navigationController pushViewController:timelineViewController animated:YES];
        
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
