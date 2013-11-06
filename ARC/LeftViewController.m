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
#import "ChurchAmountSingleType.h"
#import "ChurchDontationTypeSelector.h"
#import "DefaultChurchView.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

-(void)didBeginOpen:(NSNotification *)notification{
    
    self.defaultChurchLabel.text = @"No default church found...";
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

-(void)viewDidLoad{
    
    self.versionLabel.text = [NSString stringWithFormat:@"version %@", ARC_VERSION_NUMBER];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginOpen:) name:@"LeftMenuDidBeginOpen" object:nil];
    
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 4;
    self.topLineView.layer.shadowOpacity = 0.7;
    
    self.profileLabel.text = @"My Profile";
    
    self.newChurchButton.text = @"Select New Church";
}


-(IBAction)homeSelected{
    
    
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
    
    [self goToScreenWithIdentifier:@"profile"];

 
    
}
-(IBAction)billingSelected{
    
    [self goToScreenWithIdentifier:@"allCards"];

    

    
}
-(IBAction)supportSelected{
    

    
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
    
    [self.sideMenu.navigationController popViewControllerAnimated:YES];
    if (self.sideMenu.menuState == MFSideMenuStateLeftMenuOpen) {
        [self.sideMenu toggleLeftSideMenu];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"turnOffDefault" object:self userInfo:@{}];


}
- (IBAction)learnDwolla {
    
    [ArcClient trackEvent:@"DWOLLA_MENU_LEARN_MORE"];

    
}
@end
