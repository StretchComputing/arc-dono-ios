//
//  LeftViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
#import "SteelfishBoldLabel.h"
#import "SteelfishLabel.h"
#import "SteelfishButton.h"
#import "NVUIGradientButton.h"
@interface LeftViewController : UIViewController

@property (nonatomic, strong) MFSideMenu *sideMenu;

-(IBAction)homeSelected;
-(IBAction)profileSelected;
-(IBAction)billingSelected;
-(IBAction)supportSelected;
-(IBAction)shareSelected;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *profileLabel;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet SteelfishLabel *versionLabel;
- (IBAction)newChurchAction;

@property (strong, nonatomic, getter = anewChurch) IBOutlet NVUIGradientButton *newChurchButton;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *profileSubLabel;
- (IBAction)learnDwolla;
@property (strong, nonatomic) IBOutlet UIView *orangeView;
@property (strong, nonatomic) IBOutlet SteelfishButton *homeButton;
@property (strong, nonatomic) IBOutlet SteelfishButton *paymentButton;
@property (strong, nonatomic) IBOutlet SteelfishButton *settingsButton;
@property (strong, nonatomic) IBOutlet SteelfishButton *allLocationsButton;

@property (strong, nonatomic) IBOutlet SteelfishButton *profileButton;
@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *defaultChurchLabel;
@end
