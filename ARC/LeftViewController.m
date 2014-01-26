//
//  LeftViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import "LeftViewController.h"
#import "HomeNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "ChurchSelector.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "Merchant.h"
#import "DefaultChurchView.h"
#import "ILTranslucentView.h"

@interface LeftViewController ()

@end

@implementation LeftViewController



-(void)isOpening:(NSNotification *)notification{
    
   // NSLog(@"Notification: %@", notification);
    
    NSDictionary *userInfo = [notification valueForKey:@"userInfo"];
    
    float oldX = [[userInfo valueForKey:@"width"] floatValue];
    float percent = (oldX / 210);
    float newX = percent * 96 - 50;
    
    int middleDelta = 20;
    int outsideDelta = 70;
    
    
    CGRect frame = self.homeButton.frame;
    frame.origin.x = newX;
    frame.origin.y = 30 - ((1 - percent) * outsideDelta);
    self.homeButton.frame = frame;
    
    CGRect frame2 = self.allLocationsButton.frame;
    frame2.origin.x = newX;
    frame2.origin.y = 78 - ((1 - percent) * middleDelta);
    self.allLocationsButton.frame = frame2;
    
    CGRect frame3 = self.profileButton.frame;
    frame3.origin.x = newX;
    frame3.origin.y = 127 + ((1 - percent) * middleDelta);
    self.profileButton.frame = frame3;
    
    CGRect frame4 = self.settingsButton.frame;
    frame4.origin.x = newX;
    frame4.origin.y = 177 + ((1 - percent) * outsideDelta);
    self.settingsButton.frame = frame4;
    
    
    
}



-(void)didBeginOpen:(NSNotification *)notification{
    
    self.defaultChurchLabel.text = @"No default location found...";
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultChurchId"] length] > 0) {
        
        int merchId = [[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultChurchId"] intValue];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        for (int i = 0; i < [mainDelegate.allMerchants count]; i++) {
            
            Merchant *tmpMerch = [mainDelegate.allMerchants objectAtIndex:i];
            
            if (tmpMerch.merchantId == merchId) {
                self.defaultChurchLabel.text = tmpMerch.name;
                break;
            }
        }
    }
   
}

-(void)downPressed:(UIButton *)button{
    
    
    [self resetButtonFont];
    [button.titleLabel setFont:[UIFont fontWithName:FONT_BOLD size:21]];

    
}
-(void)viewDidLoad{
    
    [self.homeButton addTarget:self action:@selector(downPressed:) forControlEvents:UIControlEventTouchDown];
    [self.profileButton addTarget:self action:@selector(downPressed:) forControlEvents:UIControlEventTouchDown];
    [self.paymentButton addTarget:self action:@selector(downPressed:) forControlEvents:UIControlEventTouchDown];
    [self.settingsButton addTarget:self action:@selector(downPressed:) forControlEvents:UIControlEventTouchDown];
    [self.allLocationsButton addTarget:self action:@selector(downPressed:) forControlEvents:UIControlEventTouchDown];

    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, -30, 320, 650)];
    translucentView.translucentStyle = UIBarStyleBlack;
    translucentView.translucentTintColor = [UIColor clearColor];
    
    if (isIos7) {
        translucentView.translucentAlpha = 1.0;
        translucentView.backgroundColor = [UIColor clearColor];

    }else{
        translucentView.translucentAlpha = 9.0;
        translucentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        for (UIView *view in [self.orangeView subviews]) {
            [view removeFromSuperview];
        }

    }
    
    
    [self.view insertSubview:translucentView aboveSubview:self.orangeView];
    
    
    self.versionLabel.text = [NSString stringWithFormat:@"version %@", ARC_VERSION_NUMBER];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginOpen:) name:@"LeftMenuDidBeginOpen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isOpening:) name:@"LeftMenuOpenWidth" object:nil];

    
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 4;
    self.topLineView.layer.shadowOpacity = 0.7;
    
    self.profileLabel.text = @"My Profile";
    
    self.newChurchButton.text = @"Select New Location";
}


-(IBAction)homeSelected{
    
    [self resetButtonFont];
    [self.homeButton.titleLabel setFont:[UIFont fontWithName:FONT_BOLD size:21]];
    
    if ([self.sideMenu.navigationController.viewControllers count] == 1) {
        //Home is only one on the stack
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshMerchants" object:self userInfo:@{}];
        
      
    }else{

    }
    
    Merchant *foundMerchant;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultChurchId"] length] > 0) {
        
        int merchId = [[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultChurchId"] intValue];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        for (int i = 0; i < [mainDelegate.allMerchants count]; i++) {
            
            Merchant *tmpMerch = [mainDelegate.allMerchants objectAtIndex:i];
            
            if (tmpMerch.merchantId == merchId) {
                foundMerchant = tmpMerch;
                break;
            }
        }
        
        
        if (foundMerchant) {
            
            DefaultChurchView *defaultView = [self.storyboard instantiateViewControllerWithIdentifier:@"default"];
            defaultView.myMerchant = foundMerchant;
            [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
            [self.sideMenu.navigationController pushViewController:defaultView animated:NO];
           

            
            
        }else{
            [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];

        }
    }else{
        [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];

    }
    
    
    
    
    

    
    
    if (self.sideMenu.menuState == MFSideMenuStateLeftMenuOpen) {
        [self.sideMenu toggleLeftSideMenu];
        
    }
}
-(IBAction)profileSelected{
    [self resetButtonFont];

    [self.profileButton.titleLabel setFont:[UIFont fontWithName:FONT_BOLD size:21]];
    
    [self goToScreenWithIdentifier:@"profile"];

 
    
}
-(IBAction)billingSelected{
    [self resetButtonFont];

    [self.paymentButton.titleLabel setFont:[UIFont fontWithName:FONT_BOLD size:21]];
    
    
    [self goToScreenWithIdentifier:@"allCards"];

    

    
}
-(IBAction)supportSelected{
    [self resetButtonFont];

    [self.settingsButton.titleLabel setFont:[UIFont fontWithName:FONT_BOLD size:21]];
    
    [self goToScreenWithIdentifier:@"supportVC"];


    
}
-(IBAction)shareSelected{
    
    
    [self goToScreenWithIdentifier:@"share"];
    
}

-(void)goToScreenWithIdentifier:(NSString *)identifier{
    
    UIViewController *creditCards = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    [self.sideMenu.navigationController popToRootViewControllerAnimated:NO];
    [self.sideMenu.navigationController pushViewController:creditCards animated:NO];
    self.sideMenu.navigationController.navigationBarHidden = YES;
    
    if (self.sideMenu.menuState == MFSideMenuStateLeftMenuOpen) {
        [self.sideMenu toggleLeftSideMenu];

    }
    
}

- (IBAction)newChurchAction {
    [self resetButtonFont];

    [self.allLocationsButton.titleLabel setFont:[UIFont fontWithName:FONT_BOLD size:21]];
    
    [self.sideMenu.navigationController popViewControllerAnimated:YES];
    if (self.sideMenu.menuState == MFSideMenuStateLeftMenuOpen) {
        [self.sideMenu toggleLeftSideMenu];
        
    }
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"turnOffDefault" object:self userInfo:@{}];


}

-(void)resetButtonFont{
    
    [self.homeButton.titleLabel setFont:[UIFont fontWithName:FONT_REGULAR size:21]];
    [self.profileButton.titleLabel setFont:[UIFont fontWithName:FONT_REGULAR size:21]];
    [self.paymentButton.titleLabel setFont:[UIFont fontWithName:FONT_REGULAR size:21]];
    [self.settingsButton.titleLabel setFont:[UIFont fontWithName:FONT_REGULAR size:21]];
    [self.allLocationsButton.titleLabel setFont:[UIFont fontWithName:FONT_REGULAR size:21]];

}
- (IBAction)learnDwolla {
    
    [ArcClient trackEvent:@"DWOLLA_MENU_LEARN_MORE"];

    
}
@end
