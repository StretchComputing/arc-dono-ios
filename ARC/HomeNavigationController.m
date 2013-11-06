//
//  HomeNavigationController.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "HomeNavigationController.h"
#import "MFSideMenu.h"

@interface HomeNavigationController ()

@end

@implementation HomeNavigationController


- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

 
    //[self setNeedsStatusBarAppearanceUpdate];
    self.navigationBarHidden = YES;
    
    
    self.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    //return UIStatusBarStyleLightContent;
    return UIStatusBarStyleBlackOpaque;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
