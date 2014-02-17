//
//  DonateWebViewController.m
//  Dono
//
//  Created by Nick Wroblewski on 2/9/14.
//
//

#import "DonateWebViewController.h"

@interface DonateWebViewController ()

@end

@implementation DonateWebViewController


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webComplete:) name:@"webDone" object:nil];

}

-(void)webComplete:(NSNotification *)notification{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]]];

}




@end
