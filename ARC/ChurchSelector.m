//
//  Home.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "ChurchSelector.h"
#import "Merchant.h"
#import "ArcAppDelegate.h"
#import "CreditCard.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "HomeNavigationController.h"
#import "SMContactsSelector.h"
#import "MFSideMenu.h"
#import "SteelfishBoldLabel.h"
#import "LeftViewController.h"
#import "SteelfishLabel.h"
#import "ILTranslucentView.h"

#define REFRESH_HEADER_HEIGHT 52.0f



@interface ChurchSelector ()

-(void)getMerchantList;


@end




@implementation ChurchSelector
@synthesize sloganLabel;

-(void)goMerchantRefresh:(NSNotification *)notification{
    [self getMerchantList];
}

-(void)appActive{
    [self getMerchantList];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}


-(void)newLocation{
    
    [self getMerchantList];
}
-(void)viewWillAppear:(BOOL)animated{
    
    
 
    @try {
        
        
        if (self.isSearchShowing) {
            [self searchAction];
        }
        
        if (!self.sideMenu) {
            LeftViewController *leftSideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftSide"];
            
            
            
            
            self.sideMenu = [MFSideMenu menuWithNavigationController:self.navigationController
                                              leftSideMenuController:leftSideMenuViewController
                                             rightSideMenuController:nil];
            
            self.sideMenu.allowSwipeOpenLeft = YES;
            leftSideMenuViewController.sideMenu = self.sideMenu;
        }
        
        self.retryCount = 0;
        
        if (!self.isGettingMerchantList) {
            self.isGettingMerchantList = YES;
            
            [self getMerchantList];
            
        }
        
        
        if (self.view.frame.size.height < 500) {
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
            
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
            
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"Home.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  

   
    

}

-(void)keyboardWillShow{
    self.searchToolBar.hidden = NO;
    self.placeNameLabel.textColor = [UIColor whiteColor];
    
    int y = 202;
    if (isIos7) {
        y = 222;
    }
    self.placeNameLabel.frame = CGRectMake(8, y, 305, 43);
}

-(void)keyboardWillHide{
    self.searchToolBar.hidden = YES;
    self.placeNameLabel.textColor = [UIColor blackColor];
    
    int y = 271;
    if (isIos7) {
        y = 291;
    }
    self.placeNameLabel.frame = CGRectMake(8, y, 305, 43);

}

-(void)customerDeactivated{
    
    @try {
        if (self.navigationController.topViewController == self) {
            [self logOut];
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.customerDeactivated" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}
-(void)logOut{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Deactivated" message:@"For security purposes, your account has been remotely deactivated.  If this was done in error, please contact dutch support." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    

    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"arcUrl"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerId"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerToken"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"admin"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arcLoginType"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"customerEmail"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController dismissModalViewControllerAnimated:NO];
    
}
-(void)viewDidAppear:(BOOL)animated{
    
  
    
    @try {
        
        
 
  
        
    
        
        //SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Home"];
        // self.navigationItem.titleView = navLabel;
        
        //SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Home"];
		//self.navigationItem.backBarButtonItem = temp;
        
        
        for (int i = 0; i < [self.allMerchants count]; i++) {
            
            NSIndexPath *myPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.myTableView deselectRowAtIndexPath:myPath animated:NO];
        }
        
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([mainDelegate.logout isEqualToString:@"true"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully logged out.  You may continue to use dono as a guest." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            mainDelegate.logout = @"";
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *customerId = [prefs stringForKey:@"customerId"];
            
            
            NSString *keyString = [NSString stringWithFormat:@"%@noPaymentKey", customerId];
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:keyString];
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"arcUrl"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerId"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerToken"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"admin"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arcLoginType"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"customerEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autoPostFacebook"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autoPostTwitter"];

            [[NSUserDefaults standardUserDefaults] synchronize];
            
           // [self.navigationController dismissModalViewControllerAnimated:NO];
            
        }
        
      

        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)checkPayment{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    [mainDelegate doPaymentCheck];
}

-(void)goToMerchant:(id)sender{
    
    UIButton *myButton = (UIButton *)sender;
    
    
    [self payBillAction];
    
    
}

-(void)turnOff:(NSNotification *)notification{
    
    if (self.isChecked) {
        [self checkAction];
    }
}
- (void)viewDidLoad
{
    
    self.circularSpinner = [[TJSpinner alloc] initWithSpinnerType:kTJSpinnerTypeCircular];
    
    self.circularSpinner.hidesWhenStopped = YES;
    self.circularSpinner.radius = 8;
    self.circularSpinner.pathColor = [UIColor whiteColor];
    self.circularSpinner.fillColor = [UIColor orangeColor];
    self.circularSpinner.thickness = 4;
    [self.circularSpinner startAnimating];
    
    
    self.circularSpinner.frame = CGRectMake(150, 200, 25, 25);
    
    [self.view insertSubview:self.circularSpinner aboveSubview:self.loadingLocationsLabel];
    
    
    
    @try {
     //   [self setNeedsStatusBarAppearanceUpdate];

    }
    @catch (NSException *exception) {
        
    }
    
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    

    self.isChecked = YES;

    if (isIos7) {
        self.searchBar.hidden = YES;
        
        CGRect frame = self.searchBar.frame;
        frame.origin.x = 0;
        frame.size.width = 320;
        self.searchBar.frame = frame;
    }
    self.searchBar.delegate = self;
    self.matchingMerchants = [NSMutableArray array];
    self.payBillButton.text = @"Donate!";

    self.payBillButton.textColor = [UIColor whiteColor];
    self.payBillButton.textShadowColor = [UIColor darkGrayColor];
    self.payBillButton.cornerRadius = 3.0;
    self.payBillButton.borderColor = [UIColor darkGrayColor];
    self.payBillButton.borderWidth = 0.5;

    self.payBillButton.tintColor = dutchGreenColor;
    
    
    self.moreInfoButton.text = @"More Info";
    self.moreInfoButton.cornerRadius = 3.0;
    self.moreInfoButton.borderWidth = 0.5;
    self.moreInfoButton.borderColor = [UIColor darkGrayColor];
    //self.moreInfoButton.textColor = [UIColor blackColor];
   // self.moreInfoButton.textShadowColor = [UIColor darkGrayColor];
    //self.moreInfoButton.tintColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:225.0/215.0 alpha:1];

   
    
    
    //Carousel
    //self.roundView.layer.cornerRadius = 9.0;
    self.navigationController.navigationBarHidden = YES;
    

    [self updateSliders];
    
    int y = 90;
    if (self.view.frame.size.height < 500) {
        y = 80;
    }
    
  
    
    
    
    //self.borderLine1.layer.shadowOffset = CGSizeMake(0, 1);
    //self.borderLine1.layer.shadowRadius = 1;
    //self.borderLine1.layer.shadowOpacity = 0.2;
    
    //self.borderLine2.layer.shadowOffset = CGSizeMake(0, -1);
    //self.borderLine2.layer.shadowRadius = 1;
    //self.borderLine2.layer.shadowOpacity = 0.5;
    
    
    @try {
        
 
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goMerchantRefresh:) name:@"RefreshMerchants" object:nil];

        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOff:) name:@"turnOffDefault" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(merchantListComplete:) name:@"merchantListNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newLocation) name:@"newLocation" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:@"appActive" object:nil];
        
        
        
        self.searchCancelButton.hidden = YES;
        
        self.refreshListButton.hidden = YES;
        self.matchingMerchants = [NSMutableArray array];
        self.searchTextField.delegate = self;
        self.restaurantSegment.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
        
        // [self.toolbar setBackgroundImage:[UIImage imageNamed:@"navBarLogo.png"]
        //                  forBarMetrics:UIBarMetricsDefault];
        self.serverData = [NSMutableData data];
        self.allMerchants = [NSMutableArray array];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        self.myTableView.hidden = YES;
        
        self.activityView.hidden = NO;
        self.errorLabel.text = @"";
        [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.
        
        [self.searchTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
        footer.backgroundColor = [UIColor clearColor];
        
        self.myTableView.tableFooterView = footer;
        //self.myTableView.backgroundColor = [UIColor clearColor];
        //self.myTableView.backgroundView.backgroundColor = [UIColor clearColor];
        
        self.myTableView.separatorColor = [UIColor darkGrayColor];
        
        /*
         CAGradientLayer *gradient = [CAGradientLayer layer];
         gradient.frame = self.view.bounds;
         self.view.backgroundColor = [UIColor clearColor];
         double x = 1.8;
         UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
         // UIColor *myColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
         gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
         [self.view.layer insertSublayer:gradient atIndex:0];
         
         */
        
        for (UIView *subview in self.searchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
        
        //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        
        //refresh controller
        //check if refresh control is available
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }
        
        if (self.isIos6) {
            self.refreshControl = [[UIRefreshControl alloc] init];
            [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
            [self.myTableView addSubview:self.refreshControl];
        }else{
            [self setupStrings];
            [self addPullToRefreshHeader];
        }
        
        self.payBillButton.enabled = NO;
        self.moreInfoButton.enabled = NO;
        
        
        NSArray *images = @[[UIImage imageNamed:@"menuHomeIcon.png"], [UIImage imageNamed:@"menuProfileIcon"], [UIImage imageNamed:@"menuBillingIcon"], [UIImage imageNamed:@"menuSettingsIcon"]];
        
        

       
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)handleRefresh:(id)sender{
    
    [self getMerchantList];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    @try {
        
        self.matchingMerchants = [NSMutableArray array];
        if ((searchText == nil) || [searchText isEqualToString:@""]) {
            self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
        }else{
            
            NSString *currentStringToMatch = [searchText lowercaseString];
            
            for (int i = 0; i < [self.allMerchants count]; i++) {
                Merchant *tmpMerchant = [self.allMerchants objectAtIndex:i];
                NSString *merchantName = [tmpMerchant.name lowercaseString];
                
                if ([merchantName rangeOfString:currentStringToMatch].location != NSNotFound) {
                    [self.matchingMerchants addObject:tmpMerchant];
                }
            }
        }
        
        if ([self.matchingMerchants count] > 0) {
            self.errorLabel.text = @"";
            self.payBillButton.enabled = YES;

        }else{
            self.placeAddressLabel.text = @"";
            self.placeNameLabel.text = @"";
            self.payBillButton.enabled = NO;
        }
        
        [self.myTableView reloadData];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.textFieldDidChange" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}
-(void)textFieldDidChange{
    @try {
        
        self.matchingMerchants = [NSMutableArray array];
        if ((self.searchTextField.text == nil) || [self.searchTextField.text isEqualToString:@""]) {
            self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
        }else{
            
            NSString *currentStringToMatch = [self.searchTextField.text lowercaseString];
            
            for (int i = 0; i < [self.allMerchants count]; i++) {
                Merchant *tmpMerchant = [self.allMerchants objectAtIndex:i];
                NSString *merchantName = [tmpMerchant.name lowercaseString];
                
                if ([merchantName rangeOfString:currentStringToMatch].location != NSNotFound) {
                    [self.matchingMerchants addObject:tmpMerchant];
                }
            }
        }
        
        if ([self.matchingMerchants count] > 0) {
            self.errorLabel.text = @"";
        }
        
        //NSLog(@"Count: %d", [self.matchingMerchants count]);
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.textFieldDidChange" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}
-(void)getMerchantList{
    @try{
       
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([mainDelegate.lastLongitude length] > 0) {
            [tempDictionary setValue:[NSNumber numberWithDouble:[mainDelegate.lastLatitude doubleValue]] forKey:@"Latitude"];
            [tempDictionary setValue:[NSNumber numberWithDouble:[mainDelegate.lastLongitude doubleValue]] forKey:@"Longitude"];
        }
        
        
        self.loadingLocationsLabel.text = @"Loading Locations...";
		NSDictionary *loginDict = [[NSDictionary alloc] init];
		loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client getMerchantList:loginDict];
         
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.getMerchantList" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)merchantListComplete:(NSNotification *)notification{
    @try {
        
        
        [self.circularSpinner stopAnimating];
        
        self.payBillButton.enabled = YES;
        self.moreInfoButton.enabled = YES;
        
        self.isGettingMerchantList = NO;
        self.refreshListButton.hidden = YES;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
        
        [self.activity stopAnimating];
        [self.refreshControl endRefreshing];
        if (self.shouldCallStop) {
            [self stopLoading];
        }
        
        self.activityView.hidden = YES;
        NSString *errorMsg = @"";
        
       /// NSLog(@"ResponseInfo: %@", responseInfo);
        
        if ([status isEqualToString:@"success"]) {
            //success
            self.errorLabel.text = @"";
            
            NSArray *merchants = [apiResponse valueForKey:@"Results"];
            
            if ([merchants count] > 0) {
                self.allMerchants = [NSMutableArray array];
                self.matchingMerchants = [NSMutableArray array];
                self.loadingLocationsLabel.text = @"";

                
            }else{
                self.loadingLocationsLabel.text = @"No locations found...";

            }
            
            for (int i = 0; i < [merchants count]; i++) {
                Merchant *tmpMerchant = [[Merchant alloc] init];
                NSDictionary *theMerchant = [merchants objectAtIndex:i];
                
                
                
                tmpMerchant.name = [theMerchant valueForKey:@"Name"];
                
                tmpMerchant.merchantId = [[theMerchant valueForKey:@"Id"] intValue];
                
                tmpMerchant.address = [theMerchant valueForKey:@"Street"];
                tmpMerchant.city = [theMerchant valueForKey:@"City"];
                tmpMerchant.state = [theMerchant valueForKey:@"State"];
                tmpMerchant.zipCode = [theMerchant valueForKey:@"Zipcode"];
                tmpMerchant.twitterHandler = [theMerchant valueForKey:@"TwitterHandler"];
                tmpMerchant.facebookHandler = [theMerchant valueForKey:@"FacebookHandler"];
                tmpMerchant.paymentsAccepted = [theMerchant valueForKey:@"PaymentAccepted"];
                tmpMerchant.invoiceId = [[theMerchant valueForKey:@"InvoiceId"] intValue];
                
                tmpMerchant.chargeFee = [[theMerchant valueForKey:@"ChargeConvenienceFee"] boolValue];
                tmpMerchant.convenienceFee = [[theMerchant valueForKey:@"ConvenienceFee"] doubleValue];
                tmpMerchant.convenienceFeeCap = [[theMerchant valueForKey:@"ConvenienceFeeCap"] doubleValue];
            
                
                if ([theMerchant valueForKey:@"DMeMail"]) {
                    tmpMerchant.email = [theMerchant valueForKey:@"DMeMail"];
                }
                
                if ([theMerchant valueForKey:@"Website"]) {
                    tmpMerchant.website = [theMerchant valueForKey:@"Website"];

                }
                
                
                if ([theMerchant valueForKey:@"InvoiceDetails"]) {
                    tmpMerchant.donationTypes = [NSMutableArray arrayWithArray:[theMerchant valueForKey:@"InvoiceDetails"]];
         

                }else{
                    tmpMerchant.donationTypes = [NSMutableArray array];
                }
                
                tmpMerchant.invoiceLength = [[theMerchant valueForKey:@"InvoiceLength"] intValue];
                
                
                NSArray *quickpayArray = [theMerchant valueForKey:@"QuickPay"];
                
                for (int i = 0; i < [quickpayArray count]; i++){
                    
                    NSDictionary *quickPayDictionary = [quickpayArray objectAtIndex:i];
                    
                    if (i == 0) {
                        tmpMerchant.quickPayOne = [[quickPayDictionary valueForKey:@"Value"] doubleValue];
                    }else if (i == 1){
                        tmpMerchant.quickPayTwo = [[quickPayDictionary valueForKey:@"Value"] doubleValue];

                    }else if (i == 2){
                        tmpMerchant.quickPayThree = [[quickPayDictionary valueForKey:@"Value"] doubleValue];

                    }else if (i == 3){
                        tmpMerchant.quickPayFour = [[quickPayDictionary valueForKey:@"Value"] doubleValue];

                    }
                }


                //For Test Videos:
                
                /*
                if (i == 0) {
                    tmpMerchant.name = @"Untitled";
                    tmpMerchant.address = @"111 W Kinzie Chicago, IL";
                    tmpMerchant.city = @"Chicago";
                    tmpMerchant.state = @"IL";
                    tmpMerchant.zipCode = @"60654";
                }else{
                    tmpMerchant.name = @"Union Sushi";
                }
                 */
            
                NSString *status = [theMerchant valueForKey:@"Status"];
                
                if ([status length] > 0 && [status isEqualToString:@"A"]) {
                    [self.allMerchants addObject:tmpMerchant];
                    [self.matchingMerchants addObject:tmpMerchant];
                    
                    //TODO remove: adding everyone twice
                   // [self.allMerchants addObject:tmpMerchant];
                   // [self.matchingMerchants addObject:tmpMerchant];
                }
                
             
               
                
            }
            
            
            //TESTING ONLY ************************************************************************************************************
            
            /*
            self.allMerchants = [NSMutableArray array];
            self.matchingMerchants = [NSMutableArray array];
            
            Merchant *merch1 = [[Merchant alloc] init];
            merch1.name = @"Evangelical United Methodist";
            merch1.merchantId = 20;
            merch1.address = @"345 Broadwater Ave";
            merch1.city = @"Billings";
            merch1.state = @"MT";
            merch1.zipCode = @"59100";
            [self.allMerchants addObject:merch1];
            [self.matchingMerchants addObject:merch1];

            Merchant *merch2 = [[Merchant alloc] init];
            merch2.name = @"Living Waters United Methodist";
            merch2.merchantId = 21;
            merch2.address = @"51 West Cameron Bridge Rd.";
            merch2.city = @"Bozeman";
            merch2.state = @"MT";
            merch2.zipCode = @"59718";
            [self.allMerchants addObject:merch2];
            [self.matchingMerchants addObject:merch2];

            
            Merchant *merch3 = [[Merchant alloc] init];
            merch3.name = @"St. Paul's United Methodist";
            merch3.merchantId = 22;
            merch3.address = @"519 Logan St.";
            merch3.city = @"Helena";
            merch3.state = @"MT";
            merch3.zipCode = @"59601";
            [self.allMerchants addObject:merch3];
            [self.matchingMerchants addObject:merch3];

            
            Merchant *merch4 = [[Merchant alloc] init];
            merch4.name = @"Browining United Methodist";
            merch4.merchantId = 23;
            merch4.address = @"123 Highway 89";
            merch4.city = @"Browning";
            merch4.state = @"MT";
            merch4.zipCode = @"59417";
            [self.allMerchants addObject:merch4];
            [self.matchingMerchants addObject:merch4];

            */
       
            
            
            //*&******************************************************************************************************************
            
            
            
            
            if ([self.allMerchants count] == 0) {
                self.errorLabel.text = @"*No nearbly restaurants found";
            }else{
                self.myTableView.hidden = NO;
                [self.myTableView reloadData];
            }
            
            
            if (!self.didGoDefault) {
                self.didGoDefault = YES;
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultChurchId"] length] > 0 ) {
                    
                    if ([[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 1] == self) {
                        self.loadingViewController.displayText.text = @"Finding Default...";
                        [self.loadingViewController startSpin];
                        [self performSelector:@selector(goToDefault) withObject:Nil afterDelay:1.0];
                    }
                
                    
                }
            }
            
            
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            mainDelegate.allMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
            
       
            
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            // TODO create static values maybe in ArcClient
            // TODO need real error code from Santiago
            if(errorCode == 999) {
                errorMsg = @"Can not find merchants.";
            } else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            if ([self.allMerchants count] == 0) {
                self.errorLabel.text = errorMsg;
                //if no Merchants found, retry.
                if (self.retryCount < 1) {
                    self.retryCount++;
                    [self getMerchantList];
                }else{
                    self.refreshListButton.hidden = NO;
                }
            }
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.merchantListComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)goToDefault{
    [self.loadingViewController stopSpin];
    LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
    [tmp homeSelected];
}
-(void)refreshList{
    [self getMerchantList];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        if ([self.matchingMerchants count] == 0) {
            //self.myTableView.hidden = YES;
            return 0;
        }else {
            self.myTableView.hidden = NO;
            return [self.matchingMerchants count];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        NSUInteger row = [indexPath row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"churchCell"];
       
        Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:row];
        
        SteelfishBoldLabel *nameLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:2];
        SteelfishLabel *adrLabel = (SteelfishLabel *)[cell.contentView viewWithTag:3];
        SteelfishLabel *adrLabel2 = (SteelfishLabel *)[cell.contentView viewWithTag:4];

        UIImageView *merchImage = (UIImageView *)[cell.contentView viewWithTag:1];
        
        
     
    
        
        nameLabel.text = tmpMerchant.name;
        
        merchImage.layer.masksToBounds = YES;
        merchImage.layer.cornerRadius = 3.0;
        
        merchImage.image = [UIImage imageNamed:@"defaultLogo"];
       // merchImage.layer.borderColor = [[UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0] CGColor];
        //merchImage.layer.borderWidth = 1.0;
        merchImage.layer.cornerRadius = 1.0;
        
        
        //Images
        ArcClient *tmp = [[ArcClient alloc] init];
        NSString *serverUrl = [tmp getCurrentUrl];
     
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        /*
        if ([mainDelegate.imageDictionary valueForKey:[NSString stringWithFormat:@"%d", tmpMerchant.merchantId]]) {
            
            NSData *imageData = [mainDelegate.imageDictionary valueForKey:[NSString stringWithFormat:@"%d", tmpMerchant.merchantId]];
            
            merchImage.image = [UIImage imageWithData:imageData];
            
        }else{
            
            
            NSString *logoImageUrl = [NSString stringWithFormat:@"%@Images/App/Logos/%d.jpg", serverUrl, tmpMerchant.merchantId];
            logoImageUrl = [logoImageUrl stringByReplacingOccurrencesOfString:@"/rest/v1" withString:@""];
            
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:logoImageUrl]];
                
                if ( data == nil ){
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImage *logoImage = [UIImage imageWithData:data];
                    
                    if (logoImage) {
                        merchImage.image = logoImage;
                        
                        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                        [mainDelegate.imageDictionary setValue:data forKey:[NSString stringWithFormat:@"%d", tmpMerchant.merchantId]];
                    }
                });
            });
         
        }
        */
        
        if ([tmpMerchant.name isEqualToString:@"Evangelical United Methodist"]) {
            merchImage.image = [UIImage imageNamed:@"Evangelical"];
        }else if ([tmpMerchant.name isEqualToString:@"Living Waters United Methodist"]) {
            merchImage.image = [UIImage imageNamed:@"LivingWaters"];
            
        }else if ([tmpMerchant.name isEqualToString:@"St. Paul's United Methodist"]) {
            merchImage.image = [UIImage imageNamed:@"StPaul"];
            
        }else if ([tmpMerchant.name isEqualToString:@"Browining United Methodist"]) {
            merchImage.image = [UIImage imageNamed:@"Browning"];
            
        }else if ([tmpMerchant.name isEqualToString:@"Arc Mobile Inc"]) {
            merchImage.image = [UIImage imageNamed:@"testChurch"];
            
        }else{
            
            //Get the image from server, if not, default
            //default
            //merchImage.image = [UIImage imageNamed:@"testChurch"];
            
            ArcClient *tmp = [[ArcClient alloc] init];
            NSString *serverUrl = [tmp getCurrentUrl];
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if ([mainDelegate.imageDictionary valueForKey:[NSString stringWithFormat:@"%d", tmpMerchant.merchantId]]) {
                
                NSData *imageData = [mainDelegate.imageDictionary valueForKey:[NSString stringWithFormat:@"%d", tmpMerchant.merchantId]];
                
                merchImage.image = [UIImage imageWithData:imageData];
                
            }else{
                
                
                NSString *logoImageUrl = [NSString stringWithFormat:@"%@Images/App/Logos/%d.jpg", serverUrl, tmpMerchant.merchantId];
                logoImageUrl = [logoImageUrl stringByReplacingOccurrencesOfString:@"/rest/v1" withString:@""];
                
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    
                    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:logoImageUrl]];
                    
                    if ( data == nil ){
                        merchImage.image = [UIImage imageNamed:@"testChurch"];
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIImage *logoImage = [UIImage imageWithData:data];
                        
                        if (logoImage) {
                            merchImage.image = logoImage;
                            
                            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                            [mainDelegate.imageDictionary setValue:data forKey:[NSString stringWithFormat:@"%d", tmpMerchant.merchantId]];
                        }
                    });
                });
                
            }
            
            
        }
        
        
        merchImage.layer.cornerRadius = 3.0;
        

        
        
        
        
        if (tmpMerchant.address) {
            adrLabel.text = [NSString stringWithFormat:@"%@", tmpMerchant.address];
            adrLabel2.text = [NSString stringWithFormat:@"%@, %@ %@", tmpMerchant.city, tmpMerchant.state, tmpMerchant.zipCode];
        }else{
            adrLabel.text = @"201 North Ave, Chicago, IL";
        }
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 
 {
 return @"Select a restaurant:";
 }
 
 */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([self.matchingMerchants count] > 0) {
        self.selectedRow = indexPath.row;
        
        Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", tmpMerchant.merchantId] forKey:@"defaultChurchId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
        [tmp homeSelected];
        
        
        /*
         
        if ([tmpMerchant.donationTypes count] > 1) {
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"skipDonationOptions"] length] > 0) {
                [self performSegueWithIdentifier:@"single" sender:self];
                
            }else{
                [self performSegueWithIdentifier:@"multiple" sender:self];
                
            }
            
        }else{
            
            [self performSegueWithIdentifier:@"single" sender:self];
            
        }
        
         */
        
    }
    
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    @try {
        
        Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:self.selectedRow];

        
    

        
        if ([[segue identifier] isEqualToString:@"single"]) {
            
           
            
        }else if ([[segue identifier] isEqualToString:@"multiple"]) {

           
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (IBAction)refreshMerchants:(id)sender {
    
    [self.activity startAnimating];
    
    [self getMerchantList];
    
    
}

-(void)endText{
    @try {
        
        self.searchCancelButton.hidden = YES;
        if ([self.matchingMerchants count] == 0) {
            self.myTableView.hidden = YES;
            self.errorLabel.text = @"*No matches found.";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.endText" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


//iOS 5 pull to refresh code




- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    if (!self.isIos6) {
        if (self.isLoading) {
            // Update the content inset, good for section headers
            if (sender.contentOffset.y > 0)
                self.myTableView.contentInset = UIEdgeInsetsZero;
            else if (sender.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
                self.myTableView.contentInset = UIEdgeInsetsMake(-sender.contentOffset.y, 0, 0, 0);
        } else if (self.isDragging && sender.contentOffset.y < 0) {
            // Update the arrow direction and label
            [UIView beginAnimations:nil context:NULL];
            if (sender.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                self.refreshLabel.text = self.textRelease;
                [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else { // User is scrolling somewhere within the header
                self.refreshLabel.text = self.textPull;
                [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
            [UIView commitAnimations];
        }
    }
    
    
}




- (void)setupStrings{
    self.textPull = @"Pull down to refresh...";
    self.textRelease = @"Release to refresh...";
    self.textLoading = @"Loading...";
    
}


//Scroll down to refresh method
- (void)addPullToRefreshHeader {
    
    
    self.refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    self.refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    self.refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    self.refreshLabel.backgroundColor = [UIColor clearColor];
    self.refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.refreshLabel.textAlignment = UITextAlignmentCenter;
    
    self.refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    self.refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                         (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                         27, 44);
    
    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    self.refreshSpinner.hidesWhenStopped = YES;
    
    [self.refreshHeaderView addSubview:self.refreshLabel];
    [self.refreshHeaderView addSubview:self.refreshArrow];
    [self.refreshHeaderView addSubview:self.refreshSpinner];
    
    [self.myTableView addSubview:self.refreshHeaderView];
    
    
    
    
}

//Scroll down to refresh method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isLoading) return;
    self.isDragging = YES;
}



//Scroll down to refresh method
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.isLoading) return;
    self.isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
    
    
}

//Scroll down to refresh method
- (void)startLoading {
    self.isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.myTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        
        self.refreshLabel.text = self.textLoading;
        self.refreshArrow.hidden = YES;
        [self.refreshSpinner startAnimating];
    }];
    
    
    // Refresh action!
    [self refresh];
}

//Scroll down to refresh method
- (void)stopLoading {
    self.shouldCallStop = NO;
    self.isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    
    self.myTableView.contentInset = UIEdgeInsetsZero;
    [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    
    [UIView commitAnimations];
}

//Scroll down to refresh method
- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    self.refreshLabel.text = self.textPull;
    self.refreshArrow.hidden = NO;
    [self.refreshSpinner stopAnimating];
    
    self.refreshLabel.text = self.textPull;
    self.refreshArrow.hidden = NO;
    [self.refreshSpinner stopAnimating];
    
}

//Scroll down to refresh method
- (void)refresh {
    // Don't forget to call stopLoading at the end.
    self.shouldCallStop = YES;
    
    [self getMerchantList];
    
    
}

-(void)noPaymentSources{
    self.didShowPayment = YES;
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}


-(void)inviteFriend{
    
    
    SMContactsSelector *controller = [[SMContactsSelector alloc] initWithNibName:@"SMContactsSelector" bundle:nil];
    controller.delegate = self;
    
    // Select your returned data type
    controller.requestData = DATA_CONTACT_EMAIL; // , DATA_CONTACT_TELEPHONE
    
    // Set your contact list setting record ids (optional)
    //controller.recordIDs = [NSArray arrayWithObjects:@"1", @"2", nil];
    
    //Window show in Modal or not
    controller.showModal = YES; //Mandatory: YES or NO
    //Show tick or not
    controller.showCheckButton = YES; //Mandatory: YES or NO
    [self presentModalViewController:controller animated:YES];
    
}


//********Invite a Friend Methods




-(void)referFriendComplete:(NSNotification *)notification{
    @try {
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        
        [self.activity stopAnimating];
        
        
        if ([status isEqualToString:@"success"]) {
            //success
            self.errorLabel.text = @"";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully invited your friend(s)!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Invite Failed." message:@"Sorry, we were unable to send your invite(s) at this time, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.referFriendComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type{
    
    if (numberRows == 0) {
        //   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email Addresses" message:@"None of the contacts you selected had email addresses entered." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        //[alert show];
    }else{
        
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp referFriend:data];
    }
    
}



-(void)showHintOverlay{
    
    @try {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.hintOverlayView.frame;
            frame.origin.x += 300;
            self.hintOverlayView.frame = frame;
        }];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"Home.showHintOverlay" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
}

-(void)hideHintOverlay{
    
    @try {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.hintOverlayView.frame;
            frame.origin.x += 300;
            self.hintOverlayView.frame = frame;
        }];
        
        [self performSelector:@selector(hideOverlay) withObject:nil afterDelay:1.0];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"Home.hideHintOverlay" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
}

-(void)hideOverlay{
    self.hintOverlayView.hidden = YES;
}



- (IBAction)searchCancelAction {
    
    self.searchTextField.text = @"";
    
    self.searchCancelButton.hidden = YES;
    [self.searchTextField resignFirstResponder];
    

    self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
    
    //self.placeAddressLabel.text = @"";
   // self.placeNameLabel.text = @"";
    self.payBillButton.enabled = YES;
    
    [self.myTableView reloadData];
   // [self.carousel reloadData];
}

-(void)searchEditDidBegin{
    self.searchCancelButton.hidden = NO;
}
- (IBAction)checkNumberDown {
    
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.checkNumberView.frame;
        frame.origin.y = 503;
        self.checkNumberView.frame = frame;
    }];
}








- (void)updateSliders
{
  
}





- (void)setUp
{
	//set up data
	self.wrap = YES;
	self.items = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[self.items addObject:[NSNumber numberWithInt:i]];
	}
}


- (IBAction)reloadCarousel
{

}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex	>= 0)
    {
        
    }
}

- (IBAction)valueChanged {
}
- (IBAction)searchAction {
    
    self.searchBar.hidden = NO;
    
    
    int newy = 71;
    
    if (isIos7) {
        newy = 91;
    }
    if (isIpad) {
        newy = 75;
    }
    if (self.searchBar.frame.origin.y == newy) {
        newy = 7;
        [self performSelector:@selector(becomeResp:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.0];
        self.isSearchShowing = NO;
        CGRect frame = self.myTableView.frame;
        frame.origin.y -= 40;
        frame.size.height += 40;
        self.myTableView.frame = frame;
        
        self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
        [self.myTableView reloadData];

    }else{
        [self performSelector:@selector(becomeResp:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.0];
        self.isSearchShowing = YES;
        CGRect frame = self.myTableView.frame;
        frame.origin.y += 40;
        frame.size.height -= 40;
        self.myTableView.frame = frame;
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.searchBar.frame;
        frame.origin.y = newy;
        self.searchBar.frame = frame;
    }];
    
    
}

-(void)becomeResp:(NSNumber *)yesOrNo{
    
    if ([yesOrNo boolValue]) {
        [self.searchBar becomeFirstResponder];

    }else{
        [self.searchBar resignFirstResponder];
        self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
        self.searchBar.text = @"";

    }
}

-(IBAction)menuAction{
   [self.navigationController.sideMenu toggleLeftSideMenu];
    //[self.callout show];
}

-(void)menuBackAction{

    [UIView animateWithDuration:1.0 animations:^{
        
        self.topImageView.frame = CGRectMake(90, 106, 140, 140);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.menuButton.alpha = 1.0;
        self.backButton.alpha = 0.0;
        [self.view bringSubviewToFront:self.menuButton];
        
    }];
    self.placeAddressLabel.hidden = NO;
    self.placeNameLabel.hidden = NO;
    self.payBillButton.hidden = NO;
    self.moreInfoButton.hidden = NO;
    self.searchButton.hidden = NO;

    [self.enterCheckNumberView removeFromSuperview];
    self.enterCheckNumberView = nil;
    
    [self performSelector:@selector(goAway) withObject:nil afterDelay:1.0];
    
}
-(void)goAway{
    [self.topImageView removeFromSuperview];
    self.topImageView = nil;
}
- (IBAction)payBillAction {
    
    

    

}

-(void)addAlert{
    [self.view addSubview:self.enterCheckNumberView];

}
- (IBAction)moreInfoAction:(id)sender {
}
- (void)viewDidUnload {
    [self setSearchToolBar:nil];
    [super viewDidUnload];
}



-(void)checkAction{
    
    if (self.isChecked) {
        self.isChecked = NO;
        [self.checkboxImage setImage:[UIImage imageNamed:@"homeunchecked"]];
    }else{
        self.isChecked = YES;
        [self.checkboxImage setImage:[UIImage imageNamed:@"homechecked"]];

    }
}




-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
