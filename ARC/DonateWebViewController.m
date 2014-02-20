//
//  DonateWebViewController.m
//  Dono
//
//  Created by Nick Wroblewski on 2/9/14.
//
//

#import "DonateWebViewController.h"
#import "MFSideMenu.h"
#import "rSkybox.h"

@interface DonateWebViewController ()

@end

@implementation DonateWebViewController


-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.sideMenu.allowSwipeOpenLeft = YES;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.sideMenu.allowSwipeOpenLeft = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webComplete:) name:@"webDone" object:nil];

}

-(void)webComplete:(NSNotification *)notification{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    @try {
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
        self.webView.delegate = self;
        self.webView.hidden = YES;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DonateWebViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
 

}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    @try {
        self.webView.hidden = NO;
        
        CGRect frame = self.webView.frame;
        frame.origin.y += 15;
        frame.size.height -= 15;
        self.webView.frame = frame;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DonateWebViewController.webViewDidFinishLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
  
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    @try {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We experienced an error loading the donation view, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DonateWebViewController.webViewDidFailWithError" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
}
@end
