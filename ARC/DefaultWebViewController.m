//
//  DefaultWebViewController.m
//  Dono
//
//  Created by Nick Wroblewski on 1/25/14.
//
//

#import "DefaultWebViewController.h"
#import "rSkybox.h"

@interface DefaultWebViewController ()

@end

@implementation DefaultWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    @try {
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DeafultWebViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
  

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
