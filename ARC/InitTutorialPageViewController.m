//
//  InitTutorialPageViewController.m
//  Dono
//
//  Created by Nick Wroblewski on 1/26/14.
//
//

#import "InitTutorialPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PrivacyTermsViewController.h"
#import "rSkybox.h"
#import "ArcAppDelegate.h"
#import "ArcClient.h"
#import "ArcIdentifier.h"
@interface InitTutorialPageViewController ()

@end

@implementation InitTutorialPageViewController


-(void)viewDidAppear:(BOOL)animated{
    
    

    
}

-(void)viewWillDisappear:(BOOL)animated{
    
   
}


-(void)viewWillAppear:(BOOL)animated{
    
    

    
    
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneHelp{

}
- (void)viewDidLoad
{
    
    self.skipButton.layer.cornerRadius = 12.0;
    self.skipButton.layer.borderColor = [dutchRedColor CGColor];
    self.skipButton.layer.borderWidth = 2.0;
    
    
    
    
    
    
    self.helpView.layer.cornerRadius = 7.0;
    self.helpView.layer.masksToBounds = YES;
    
    [super viewDidLoad];
	
    self.myScrollView.delegate = self;
    
    
    @try {
        self.pageControl.pageIndicatorTintColor = dutchTopLineColor;
        self.pageControl.currentPageIndicatorTintColor = dutchRedColor;
    }
    @catch (NSException *exception) {
        
    }
    
    [self.myScrollView setContentSize:CGSizeMake(1280, 0)];
    

    
    
  
    self.bottomLine.backgroundColor = dutchTopLineColor;
    
    

    
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    self.loadingViewController.view.hidden = YES;
    [self.view addSubview:self.loadingViewController.view];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int offset = scrollView.contentOffset.x;
    
    if (offset == 0) {
        self.pageControl.currentPage = 0;
    }else if (offset == 320){
        self.pageControl.currentPage = 1;
    }else if (offset == 640){
        self.pageControl.currentPage = 3;
    }else if (offset == 960){
        self.pageControl.currentPage = 4;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        @try {
            
            
            
            if ([[segue identifier] isEqualToString:@"goPrivacy"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = YES;
                self.isGoingPrivacyTerms = YES;
                
            }
            
            if ([[segue identifier] isEqualToString:@"goTerms"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = NO;
                self.isGoingPrivacyTerms = YES;
                
            }
        }
        @catch (NSException *e) {
            [rSkybox sendClientLog:@"InitTutorial.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InitTutorial.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (IBAction)termsAction {
    [self performSegueWithIdentifier:@"goTerms" sender:self];
}

- (IBAction)privacyAction {
    [self performSegueWithIdentifier:@"goPrivacy" sender:self];
    
}

@end
