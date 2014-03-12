//
//  PaymentOptionsWebViewController.m
//  Dono
//
//  Created by Nick Wroblewski on 3/7/14.
//
//

#import "PaymentOptionsWebViewController.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "MFSideMenu.h"

@interface PaymentOptionsWebViewController ()

@end

@implementation PaymentOptionsWebViewController



-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.sideMenu.allowSwipeOpenLeft = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.sideMenu.allowSwipeOpenLeft = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardsComplete:) name:@"cardsDone" object:nil];
    
}
-(void)cardsComplete:(NSNotification *)notification{
    
    [self.navigationController popViewControllerAnimated:YES];
}


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
        
        
        [self setUpWebUrl];
        
        //NSLog(@"URL: %@", self.webUrl);
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];
        
        self.webView.delegate = self;
        self.webView.hidden = YES;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"PaymentOptionsWebViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
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
        [rSkybox sendClientLog:@"PaymentOptions.webViewDidFinishLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    @try {
       // NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We experienced an error loading the payment options view, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        [self performSelector:@selector(goBack) withObject:Nil afterDelay:0.6];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"PaymentOptions.webViewDidFailWithError" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
}



-(void)setUpWebUrl{
    
    ArcClient *client = [[ArcClient alloc] init];
    NSString *token = [client authHeader];
    
    NSString *guestId = @"";
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] == 0) {
        guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"guestId"];
    }else{
        guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
        
    }
    
    
    
    NSString *passUrl = [client getCurrentUrl];
    NSString *startUrl = [passUrl stringByReplacingOccurrencesOfString:@"/rest/v1/" withString:@""];
    
    //NSLog(@"Token: %@", token);
    
    self.webUrl = [NSString stringWithFormat:@"%@/content/confirmpayment/managepayment.html?customerId=%@&token=%@&serverUrl=%@", startUrl, guestId, token, passUrl];
    
    
    self.webUrl = [self.webUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    int location = [self.webUrl rangeOfString:@"&serverUrl"].location;
    location = location - 4;
    self.webUrl = [self.webUrl stringByReplacingOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(location, 5)];
    
    
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
