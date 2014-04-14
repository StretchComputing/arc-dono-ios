//
//  DefaultChurchView.m
//  HolyDutch
//
//  Created by Nick Wroblewski on 11/5/13.
//
//

#import "DefaultChurchView.h"
#import "MFSideMenu.h"
#import "ArcAppDelegate.h"
#import "ArcClient.h"
#import "rSkybox.h"
#import "ArcUtility.h"
#import "LeftViewController.h"
#import "ILTranslucentView.h"
#import "DefaultWebViewController.h"
#import "ArcClient.h"
#import "DonateWebViewController.h"
#import "RecurringDonationOne.h"
#import "MFSideMenu.h"

@interface DefaultChurchView ()

@end

@implementation DefaultChurchView


-(void)viewWillDisappear:(BOOL)animated{
    
    

}

-(void)setDonationSubLabel{
    
    self.donatingAsLabel.text = @"";
    return;
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
        self.donatingAsLabel.text = [NSString stringWithFormat:@"Donating as: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"]];
    }else{
        self.donatingAsLabel.text = @"You are currently donating anonymously";
    }
}
-(void)setRecurringLabels{
    
    if (self.recurringAmount == 0.0) {
        self.recurringLabelTop.text = @"Recurring Donations";
        self.recurringLabelBottom.text = @"Click to schedule weekly or monthly donations";
    }else{
        self.recurringLabelTop.text = @"My Recurring Donation";
        self.recurringLabelBottom.text = [self getRecurringString];
    }
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    @try {
        self.navigationController.sideMenu.allowSwipeOpenLeft = YES;

        
        self.didGetRecurring = NO;
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"customerEmail"] length] > 0) {
            ArcClient *tmp = [[ArcClient alloc] init];
            [tmp getListOfRecurringPayments];
            
            self.recurringLabelTop.text = @"Loading...";
            self.recurringLabelBottom.text = @"";
        }else{
            self.didGetRecurring = YES;
            [self setRecurringLabels];

        }
        
        
        [self setDonationSubLabel];
        
        
        self.navigationController.sideMenu.allowSwipeOpenLeft = YES;
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  



}

- (IBAction)openMenuNow:(id)sender {
    [self.navigationController.sideMenu toggleLeftSideMenu];
}
- (IBAction)helpAction:(id)sender {
    [self help];
}
- (IBAction)helpAction2:(id)sender {
    [self help];
}

-(void)help{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Default Location" message:@"You have selected this as your default location.  This page will show when the app loads, or when you click 'Home' from the left menu.  \n \n  If you would like to view other locations, please select 'View All Locations'." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View All Locations", nil];
    [alert show];
}

-(void)messagesAction{
    
    if ([self.messagesArray count] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Messages" message:@"There are currently no messages from this location to its members." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void)creditCardsComplete:(NSNotification *)notification{
    
    @try {
        self.didFinishCards = YES;
        NSDictionary *userInfo = [notification valueForKey:@"userInfo"];
        
        @try {
            NSArray *results = [[userInfo valueForKey:@"apiResponse"] valueForKey:@"Results"];
            
            
            if ([results count] > 0) {
                self.creditCardArray = [NSMutableArray arrayWithArray:results];
            }
        }
        @catch (NSException *exception) {
            self.creditCardArray = [NSMutableArray array];
        }
        
        
        if (self.loadingViewController.view.hidden == NO) {
            //waiting for donation
            self.loadingViewController.view.hidden = YES;

            if (self.isRecurring) {
                [self performSegueWithIdentifier:@"recurringDonation" sender:self];

            }else{
                [self goToWebPayment];

            }
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.creditCardsComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
  
    
}

-(void)webComplete:(NSNotification *)notification{
    
    @try {
        
        self.didFinishCards = NO;
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp getListOfCreditCards];
        
        if ([[[notification valueForKey:@"userInfo"] valueForKey:@"result"] isEqualToString:@"success"]) {
            //show "create account" view if they have none
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0 && self.didJustRegister) {
                //show the "complete your registration" form
            }
        }
       

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.webComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
  
}

-(void)becameActive:(NSNotification *)notification{
    
    @try {
        self.didFinishCards = NO;
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp getListOfCreditCards];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.becameActive" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
   
    
}

-(void)viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (void)viewDidLoad
{
    @try {
        
        self.anonymousReminderChecked = NO;
        self.guestCreateAccountFrontView.layer.cornerRadius = 5.0;
        self.recurringDonationFrontView.layer.cornerRadius = 5.0;

        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];
        
        

        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneGetRecurringPayments:) name:@"getRecurringPaymentsNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneDeleteRecurringPayment:) name:@"deleteRecurringPaymentNotification" object:nil];
       
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webComplete:) name:@"webDone" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creditCardsComplete:) name:@"creditCardNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becameActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateComplete:) name:@"updateGuestCustomerNotification" object:nil];
        
        
        self.creditCardArray = [NSMutableArray array];
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp getListOfCreditCards];
        
        self.donationHistoryButton.text = @"View Donation History";
        self.donationHistoryButton.tintColor = dutchRedColor;
        
        self.viewAllLocationsButton.text = @"View Other Locations";
        self.viewAllLocationsButton.tintColor = dutchRedColor;
        
        
        self.makeDonationButton.text = @"Make Donation";
        self.makeDonationButton.tintColor = dutchGreenColor;
        
        self.contactButton.text = @"Contact Location";
        self.contactButton.tintColor = dutchGreenColor;
        
        self.websiteButton.text = @"View Website";
        self.websiteButton.tintColor = dutchGreenColor;
        
        self.messagesButton.text = @"Messages";
        self.messagesButton.tintColor = dutchGreenColor;
        
        
        
        self.donationType = [self.myMerchant.donationTypes objectAtIndex:0];
        self.quickButtonOne.text = @"$10";
        self.quickButtonTwo.text = @"$25";
        self.quickButtonThree.text = @"$50";
        self.quickButtonFour.text = @"$75";
        
        self.quickButtonOne.tintColor = dutchDarkBlueColor;
        self.quickButtonTwo.tintColor = dutchDarkBlueColor;
        self.quickButtonThree.tintColor = dutchDarkBlueColor;
        self.quickButtonFour.tintColor = dutchDarkBlueColor;
        
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        
        self.merchantName.text = self.myMerchant.name;
        self.topLabel.text = [NSString stringWithFormat:@"%@, %@", self.myMerchant.city, self.myMerchant.state];
        
        
        
        
        ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:self.nameView.frame];
        translucentView.translucentStyle = UIBarStyleBlack;
        translucentView.translucentTintColor = [UIColor clearColor];
        
        if (isIos7) {
            translucentView.translucentAlpha = 0.98;
            translucentView.backgroundColor = [UIColor clearColor];
            
        }else{
            translucentView.translucentAlpha = 9.0;
            translucentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
           
            
        }
        
        
        [self.view insertSubview:translucentView aboveSubview:self.nameView];
        
        
        
        if (self.myMerchant.merchantId == 16) {
            self.mainImage.image = [UIImage imageNamed:@"Evangelical"];
            
        }else if (self.myMerchant.merchantId == 17) {
            
            self.mainImage.image = [UIImage imageNamed:@"LivingWaters"];
            
        }else if (self.myMerchant.merchantId == 15) {
            self.mainImage.image = [UIImage imageNamed:@"StPaul"];
            
        }else if (self.myMerchant.merchantId == 18) {
            self.mainImage.image = [UIImage imageNamed:@"Browning"];
            
        }else if (self.myMerchant.merchantId == 20) {
            
            self.mainImage.image = [UIImage imageNamed:@"testChurch"];
            
        }else if (self.myMerchant.merchantId == 21) {
            
            self.mainImage.image = [UIImage imageNamed:@"21"];
            
        }else{
            
            //Get the image from server, if not, default
            
            
            //default
           // self.mainImage.image = [UIImage imageNamed:@"testChurch"];
            
            
            ArcClient *tmp = [[ArcClient alloc] init];
            NSString *serverUrl = [tmp getCurrentUrl];
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if ([mainDelegate.imageDictionary valueForKey:[NSString stringWithFormat:@"%d", self.myMerchant.merchantId]]) {
                
                NSData *imageData = [mainDelegate.imageDictionary valueForKey:[NSString stringWithFormat:@"%d", self.myMerchant.merchantId]];
                
                self.mainImage.image = [UIImage imageWithData:imageData];
                
            }else{
                
                
                NSString *logoImageUrl = [NSString stringWithFormat:@"%@Images/App/Promo/%d.png", serverUrl, self.myMerchant.merchantId];
                logoImageUrl = [logoImageUrl stringByReplacingOccurrencesOfString:@"/rest/v1" withString:@""];
                
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    
                    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:logoImageUrl]];
                    
                    if ( data == nil ){
                        self.mainImage.image = [UIImage imageNamed:@"testChurch"];
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIImage *logoImage = [UIImage imageWithData:data];
                        
                        if (logoImage) {
                            self.mainImage.image = logoImage;
                            
                            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                            [mainDelegate.imageDictionary setValue:data forKey:[NSString stringWithFormat:@"%d", self.myMerchant.merchantId]];
                        }
                    });
                });
                
            }
            

            
            
            
            
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
    
}

- (IBAction)openMenu:(id)sender {
    [self.navigationController.sideMenu toggleLeftSideMenu];
}


-(void)tryDonation{
    
    if (!self.didFinishCards) {
        self.isRecurring = NO;
        self.loadingViewController.displayText.text = @"Loading Donation...";
        [self.loadingViewController startSpin];
        
    }else{
        [self goToWebPayment];
        
    }
    
    
}
- (IBAction)makeDonation:(id)sender {
    
    
    @try {
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
           
            
            [self tryDonation];
        }else{
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"skipAnonymous"] length] == 0) {
                
                self.anonymousAlert = [[UIAlertView alloc] initWithTitle:@"Donate Anonymously?" message:@"If you make a donation before creating an account, it will be sent anonymously.  You will also not receive automatic email receipts of your transactions." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create An Account", @"Donate Anonymously", nil];
                [self.anonymousAlert show];
                
            }else{
                
                [self tryDonation];

            }
        }
        
        
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.makeDonation" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }


}

-(void)goToWebPayment{
    
    
    @try {
        NSMutableArray *itemArray = [NSMutableArray array];
        
        NSString *value = @"";
        
        self.donationType = [self.myMerchant.donationTypes objectAtIndex:0];
        
        NSDictionary *item = @{@"Amount":@"1", @"Percent":@"1.0", @"ItemId":[self.donationType valueForKey:@"Id"], @"Value":value, @"Description":[self.donationType valueForKey:@"Description"]};
        
        [itemArray addObject:item];
        
        
        
        //Add card must be done via the web now:
        
        
        NSString *url = @"";
        
        ArcClient *client = [[ArcClient alloc] init];
        NSString *token = [client authHeader];
        
        NSString *guestId = @"";
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] == 0) {
            guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"guestId"];
        }else{
            guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
            
        }
        
        
        
        NSString *anonymous = @"false";
        
        
        if (self.myMerchant.chargeFee) {
            
            
        }else{
            self.myMerchant.convenienceFeeCap = 0.0;
            self.myMerchant.convenienceFee = 0.0;
        }
      

        
        NSString *quickOne = [NSString stringWithFormat:@"%.0f", self.myMerchant.quickPayOne];
        NSString *quickTwo = [NSString stringWithFormat:@"%.0f", self.myMerchant.quickPayTwo];
        NSString *quickThree = [NSString stringWithFormat:@"%.0f", self.myMerchant.quickPayThree];
        NSString *quickFour = [NSString stringWithFormat:@"%.0f", self.myMerchant.quickPayFour];

        NSString *passUrl = [client getCurrentUrl];
        
        NSString *startUrl = [passUrl stringByReplacingOccurrencesOfString:@"/rest/v1/" withString:@""];
        
        //NSLog(@"Token: %@", token);
        
        url = [NSString stringWithFormat:@"%@/content/confirmpayment/confirmpayment.html?invoiceAmount=%.2f&customerId=%@&authenticationToken=%@&invoiceId=%d&merchantId=%d&gratuity=%.2f&anonymous=%@&token=%@&serverUrl=%@&type=CREDIT&convenienceFee=%f&convenienceFeeCap=%f&name=%@&quickOne=%@&quickTwo=%@&quickThree=%@&quickFour=%@", startUrl, 0.0, guestId, @"", self.myMerchant.invoiceId, self.myMerchant.merchantId, 0.0, anonymous, token, passUrl, self.myMerchant.convenienceFee, self.myMerchant.convenienceFeeCap,self.myMerchant.name, quickOne, quickTwo,quickThree, quickFour];
        
        for (int i = 0; i < [itemArray count]; i++) {
            
            NSDictionary *item = [itemArray objectAtIndex:i];
            url = [url stringByAppendingFormat:@"&Amount=%@&Description=%@&ItemId=%@&Percent=%@&Value=%@", [item valueForKey:@"Amount"], [item valueForKey:@"Description"], [item valueForKey:@"ItemId"], [item valueForKey:@"Percent"], [item valueForKey:@"Value"]];
        }
        
        for (int i = 0; i < [self.myMerchant.donationTypes count]; i++) {
            
            NSDictionary *donationType = [self.myMerchant.donationTypes objectAtIndex:i];
            url = [url stringByAppendingFormat:@"&TypeDescription=%@&TypeId=%@", [donationType valueForKey:@"Description"], [donationType valueForKey:@"Id"]];
            
            
        }
         //NSLog(@"URL: %@", url);
        
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // url = [url stringByReplacingOccurrencesOfString:@"==" withString:@"%3D%3D"];
        
        int location = [url rangeOfString:@"&serverUrl"].location;
        location = location - 4;
        url = [url stringByReplacingOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(location, 5)];
        // NSLog(@"Encoded: %@", url);
        
        
        if ([self.creditCardArray count] > 0) {
            
            for (int i = 0; i < [self.creditCardArray count]; i++) {
                
                NSDictionary *card = [self.creditCardArray objectAtIndex:i];
                
                NSString *cardType = [self getCardTypeForNumber:[card valueForKey:@"Number"]];
                
                url = [url stringByAppendingFormat:@"&CardNumber=%@&CardExpiration=%@&CardToken=%@&CardType=%@", [card valueForKey:@"Number"], [card valueForKey:@"ExpirationDate"],
                       [card valueForKey:@"CCToken"], cardType];
            }
        }
        
        //NSLog(@"URL: %@", url);
        
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
        DonateWebViewController *webController = [self.storyboard instantiateViewControllerWithIdentifier:@"webdonate"];
        webController.webUrl = url;
        [self.navigationController pushViewController:webController animated:YES];
        
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.goToWebPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
    
    
    
}



-(IBAction)contactAction{
    
    @try {
        if ([self.myMerchant.email length] > 0) {
            
            
            if ([MFMailComposeViewController canSendMail]) {
                
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                [mailViewController setToRecipients:@[self.myMerchant.email]];
                
                [self presentModalViewController:mailViewController animated:YES];
                
            }else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:@"Your device cannot currently send email." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            
            
            
        }else{
            
            
            if ([MFMailComposeViewController canSendMail]) {
                
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                [mailViewController setToRecipients:@[[[NSUserDefaults standardUserDefaults] valueForKey:@"arcMail"]]];
                [mailViewController setSubject:[NSString stringWithFormat:@"To: %@", self.myMerchant.name]];
                
                [self presentModalViewController:mailViewController animated:YES];
                
            }else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:@"Your device cannot currently send email." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            
            
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.contactAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
 
}


-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    @try {
        
        switch (result)
        {
            case MFMailComposeResultCancelled:
                break;
            case MFMailComposeResultSent:
                
                break;
            case MFMailComposeResultFailed:
                
                break;
                
            case MFMailComposeResultSaved:
                
                break;
            default:
                
                break;
        }
        
        
        [self dismissModalViewControllerAnimated:YES];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"DefaultChurchView.mailComposeController" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



-(IBAction)websiteAction{
    
    
    [self performSegueWithIdentifier:@"goWeb" sender:self];
    
    
    

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    @try {
        
        
        
        
        
        if ([[segue identifier] isEqualToString:@"recurringDonation"]) {
            
            RecurringDonationOne *recurring = [segue destinationViewController];
            recurring.myMerchant = self.myMerchant;
            recurring.creditCards = [NSArray arrayWithArray:self.creditCardArray];
            
            
        }else if ([[segue identifier] isEqualToString:@"payCard"]) {
      
            
        }else if ([[segue identifier] isEqualToString:@"single"]) {
            
           
            
        }else if ([[segue identifier] isEqualToString:@"multiple"]) {
         
            
        }else if ([[segue identifier] isEqualToString:@"goWeb"]) {
            
            DefaultWebViewController *webview = [segue destinationViewController];
            
            NSString *web = @"";
            
            if ([self.myMerchant.website length] > 0) {
                web = self.myMerchant.website;
            }else if ([self.myMerchant.name isEqualToString:@"Arc Mobile Inc"]){
                web = @"www.arcmobileapp.com";
            }else{
                web = @"www.dono.io";
            }
            
            
            
            if ([web length] > 0) {
                if ([web rangeOfString:@"http://"].location == NSNotFound) {
                    web = [@"http://" stringByAppendingString:web];
                }
                
                webview.webUrl = web;
                
            }
            
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"DefaultChurchView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}




- (IBAction)quickActionOne {
    self.amount = @"10.00";
    [self payAction];
}

- (IBAction)quickActionTwo{
    self.amount = @"25.00";
    [self payAction];
}
- (IBAction)quickActionThree{
    self.amount = @"50.00";
    [self payAction];
}
- (IBAction)quickActionFour{
    self.amount = @"75.00";
    [self payAction];
}

- (IBAction)goDonationHistory {
    
    
    @try {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
            [self performSegueWithIdentifier:@"goHistory" sender:self];
            
        }else{
            self.loginAlert = [[UIAlertView alloc] initWithTitle:@"Not Signed In." message:@"Only signed in users view their payment history. Select 'Go Profile' to log in or create an account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Go Profile", nil];
            [self.loginAlert show];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.goDonationHistory" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
  


}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    @try {
        
        if (alertView == self.anonymousAlert) {
            
            if (buttonIndex == 2) {
                [ArcClient trackEvent:@"GUEST_CHOOSE_DONATE_ANONYMOUSLY"];
                
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"skipAnonymous"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self tryDonation];
                
                
            }else if (buttonIndex == 1){
                self.guestCreateAccountView.hidden = NO;
                [self.guestCreateAccountEmailText becomeFirstResponder];
              
            }
            
        }else if (alertView == self.subscriptionAlert) {
            
            if (buttonIndex == 1) {
                [self cancelRecurringDonation];
            }
            
        }
        else if (alertView == self.loginAlert){
            
            if (buttonIndex == 1) {
                
                self.guestCreateAccountView.hidden = NO;
                [self.guestCreateAccountEmailText becomeFirstResponder];
                
            }
             
             
        }else if (alertView == self.registerSuccessAlert) {
            
            [self tryDonation];
        }else if (alertView == self.areYouSureAlert){
            
            if (buttonIndex == 0) {
                
                [ArcClient trackEvent:@"GUEST_CREATE_ACCOUNT_CANCEL_SECONDARY"];

           
                
                [self tryDonation];
            }else{
                
                
                self.guestCreateAccountView.hidden = NO;
                
                [self.guestCreateAccountEmailText becomeFirstResponder];
            }
            
        }else{
            //Help Alert
            
            if (buttonIndex == 1) {
                
                LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
                [tmp newChurchAction];
                
            }else if (buttonIndex == 2){
                
               // LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
                //[tmp supportSelected];
                
                
            }
        }
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.clickedButtonAtIndex" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}



- (IBAction)payAction {
    
    
    @try {
        //double amountDouble = [self.amount doubleValue];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
        
        if ([self.creditCards count] > 0) {
            //Have at least 1 card, present UIActionSheet
            
            if ([self.creditCards count] == -1) {
                
                self.selectedCard = [self.creditCards objectAtIndex:0];
                
                
                [self performSegueWithIdentifier:@"payCard" sender:self];
                return;
                
            }else{
                
                self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                
                int x = 0;
                if (self.haveDwolla) {
                    x++;
                    [self.actionSheet addButtonWithTitle:@"Dwolla"];
                }
                
                for (int i = 0; i < [self.creditCards count]; i++) {
                    CreditCard *tmpCard = (CreditCard *)[self.creditCards objectAtIndex:i];
                    
                    if ([tmpCard.sample rangeOfString:@"Credit Card"].location == NSNotFound && [tmpCard.sample rangeOfString:@"Debit Card"].location == NSNotFound) {
                        
                        [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", tmpCard.sample]];
                        
                    }else{
                        [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@  %@", [ArcUtility getCardNameForType:tmpCard.cardType], [tmpCard.sample substringFromIndex:[tmpCard.sample length] - 8] ]];
                        
                    }
                    
                    
                    
                    
                }
                
                [self.actionSheet addButtonWithTitle:@"+ New Card"];
                [self.actionSheet addButtonWithTitle:@"Cancel"];
                self.actionSheet.cancelButtonIndex = [self.creditCards count] + x;
            }
            
            
            [self.actionSheet showInView:self.view];
            
            
            
        }else{
            //No cards, go to Add Card Screen
            [self performSegueWithIdentifier:@"addCard" sender:self];
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.payAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
    
}






-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    @try {
        
        int x = 0;
        if (self.haveDwolla) {
            x++;
        }
        
        
        if (buttonIndex == 0) {
            //Dwolla
            
            if (self.haveDwolla) {
                // if ((token == nil) || [token isEqualToString:@""]) {
                
                //    [self performSegueWithIdentifier:@"confirmDwolla" sender:self];
                
                
                //  }else{
                //       [rSkybox addEventToSession:@"selectedDwollaForPayment"];
                //
                //     [self performSegueWithIdentifier:@"goPayDwolla" sender:self];
                
                // }
            }else{
                //Grab top CC
                
                self.selectedCard = [self.creditCards objectAtIndex:0];
                [self performSegueWithIdentifier:@"payCard" sender:self];
            }
            
            
            
            
        }else {
            
            
            if ([self.creditCards count] > 0) {
                
                if (buttonIndex == ([self.creditCards count] + 1 + x)) {
                    //Cancel
                }else if (buttonIndex == [self.creditCards count] + x){
                    //New Card
                    [self performSegueWithIdentifier:@"addCard" sender:self];
                }else{
                    self.selectedCard = [self.creditCards objectAtIndex:buttonIndex - x];
                    
                    [self performSegueWithIdentifier:@"payCard" sender:self];
                    
                }
            }
            
        }
        
        
    }@catch (NSException *e) {
        
       // NSLog(@"E: %@", e);
        [rSkybox sendClientLog:@"DefaultChurchView.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}





- (IBAction)goAllChurches {
    
       //Changed to recurring donations button
    
    if ([self.recurringLabelTop.text isEqualToString:@"Loading..."]) {
        
    }else{
        if (self.recurringAmount == 0.0) {
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
                
                
                if (!self.didFinishCards) {
                    self.isRecurring = YES;
                    self.loadingViewController.displayText.text = @"Loading...";
                    [self.loadingViewController startSpin];
                    
                }else{
                    [self performSegueWithIdentifier:@"recurringDonation" sender:self];
                    
                }
                
                
                
            }else{
                self.loginAlert = [[UIAlertView alloc] initWithTitle:@"Not Logged In" message:@"Only registered users can sign up for recurring donations.  Would you like to create an account now?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Sign Up", nil];
                [self.loginAlert show];
                
            }
            
            
        }else{
            self.subscriptionAlert = [[UIAlertView alloc] initWithTitle:@"Cancel Recurring Donation" message:@"Would you like to remove your recurring donation?  Your card will no longer be charged, effective immediately." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Remove", nil];
            [self.subscriptionAlert show];
        }
    }
    
    
    
}



-(NSString *)getCardTypeForNumber:(NSString *)cardNumber{
    
    
     @try {
     
     if ([cardNumber length] > 0) {
     
     NSString *firstOne = [cardNumber substringToIndex:1];
     NSString *firstTwo = [cardNumber substringToIndex:2];
     NSString *firstThree = [cardNumber substringToIndex:3];
     NSString *firstFour = [cardNumber substringToIndex:4];
     
     int numberLength = [cardNumber length];
     
     if ([firstOne isEqualToString:@"4"] && ((numberLength == 15) || (numberLength == 16))) {
     return @"Visa";
     }
     
     double cardDigits = [firstTwo doubleValue];
     if ((cardDigits >= 51) && (cardDigits <= 55) && (numberLength == 16)) {
     return @"MasterCard";
     }
     
     if (([firstTwo isEqualToString:@"34"] || [firstTwo isEqualToString:@"37"]) && (numberLength == 15)) {
     return @"American Express";
     }
     
     if (([firstTwo isEqualToString:@"65"] || [firstFour isEqualToString:@"6011"]) && (numberLength == 16)) {
     return @"Discover";
     }
     
     double threeDigits = [firstThree doubleValue];
     if ((numberLength == 14) && ([firstTwo isEqualToString:@"36"] || [firstTwo isEqualToString:@"38"] || ((threeDigits >= 300) && (threeDigits <= 305) ))) {
     return @"Diners";
     }
     
     return @"Credit";
     }else{
     return @"Credit";
     }
     }
     @catch (NSException *e) {
         return @"Credit";
     [rSkybox sendClientLog:@"DefaultChurchView.getCardTypeForNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
     }
     
     
    
}


- (IBAction)guestCreateAccountSubmitAction {
    
    @try {
        
        [ArcClient trackEvent:@"GUEST_CREATE_ACCOUNT_ATTEMPT"];
        
        
        if ([self.guestCreateAccountEmailText.text length] == 0 || [self.guestCreateAccountPasswordText.text length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Please fill out both email and password before submitting." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }else if ([self.guestCreateAccountPasswordText.text length] < 5){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Too Short" message:@"Password must be at least 5 characters." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            
        }else if (![self validateEmail:self.guestCreateAccountEmailText.text]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            
        }else{
            [self runRegister];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.guestCreateAccountSubmitAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
   
}
- (IBAction)guestCreateAccountCancelAction {
    

   
        self.guestCreateAccountView.hidden = YES;
        
        [self.guestCreateAccountEmailText resignFirstResponder];
        [self.guestCreateAccountPasswordText resignFirstResponder];
 
}
- (IBAction)endText {
}

- (BOOL) validateEmail: (NSString *) candidate {
    
    @try {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        return [emailTest evaluateWithObject:candidate];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.validateEmail" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        return NO;
        
    }
    
    
}


-(void)runRegister{
    
    @try {
        
        [self.loadingViewController startSpin];
        self.loadingViewController.displayText.text = @"Registering...";
        
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];

        
        [tempDictionary setValue:self.guestCreateAccountEmailText.text forKey:@"eMail"];
        [tempDictionary setValue:self.guestCreateAccountPasswordText.text forKey:@"Password"];
        [tempDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"IsGuest"];
        
        
        NSDictionary *loginDict = [[NSDictionary alloc] init];
        loginDict = tempDictionary;
        
        
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp updateGuestCustomer:loginDict];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.runRegister" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}



-(void)updateComplete:(NSNotification *)notification{
    @try {
        
        
        [self.loadingViewController stopSpin];
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        //NSLog(@"ResponseInfo: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        BOOL isAlreadyRegistered = NO;
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //NSDictionary *theInvoice = [[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] objectAtIndex:0];
            
            self.guestCreateAccountView.hidden = YES;
            [self.guestCreateAccountEmailText resignFirstResponder];
            [self.guestCreateAccountPasswordText resignFirstResponder];
            
            NSString *newToken = [responseInfo valueForKey:@"Results"];
            
            
            //NSLog(@"NewToken: %@", newToken);
            
            //Successful conversion from guest->customer
            
            self.registerSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Thank your for registering, email receipts will now be sent to your address." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [self.registerSuccessAlert show];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *guestId = [prefs valueForKey:@"guestId"];
            //NSString *guestToken = [prefs valueForKey:@"guestToken"];
            
            
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            [mainDelegate insertCustomerWithId:guestId andToken:newToken];
            
            
            //Convert Guest Id/Token to customer Id/Token
            
            [prefs setValue:self.guestCreateAccountEmailText.text forKey:@"customerEmail"];
            [prefs setValue:guestId forKey:@"customerId"];
            [prefs setValue:newToken forKey:@"customerToken"];
            
            [prefs setValue:@"" forKey:@"guestId"];
            [prefs setValue:@"" forKey:@"guestToken"];
            
            [prefs synchronize];
            
           // self.didFinishCards = NO;
           // ArcClient *tmp = [[ArcClient alloc] init];
           //  [tmp getListOfCreditCards];
            
            
            
        } else if([status isEqualToString:@"error"]){
            
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            
            if(errorCode == 103 || errorCode == 106) {
                isAlreadyRegistered = YES;
            } else {
                errorMsg = @"Unable to register account, please try again.";
            }
            
            
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = @"Unable to register account, please try again.";
        }
        
        if (isAlreadyRegistered) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email In Use" message:@"The email address you entered is already being used.  If you already have an account, please sign in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }else{
            if([errorMsg length] > 0) {
                // self.errorLabel.text = errorMsg;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"DefaultChurchView.updateComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}




- (IBAction)anonymousCancelAction {
    
    self.anonymousAlertBackView.hidden = YES;
}

- (IBAction)anonymousDonateAction {
    

    self.anonymousAlertBackView.hidden = YES;

    
    if (self.anonymousReminderChecked) {
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"skipAnonymous"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [ArcClient trackEvent:@"GUEST_CREATE_ACCOUNT_CANCEL_INITIAL"];

    [self tryDonation];


    
   
}

- (IBAction)anonymousCreateAction {
    
    
    if (self.anonymousReminderChecked) {
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"skipAnonymous"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    self.anonymousAlertBackView.hidden = YES;

    
    self.guestCreateAccountView.hidden = NO;
    [self.guestCreateAccountEmailText becomeFirstResponder];
}


- (IBAction)anonymousReminderCheckAction {
    
    if (self.anonymousReminderChecked) {
        self.anonymousReminderChecked = NO;
        self.anonymousCheckBox.image = [UIImage imageNamed:@"homeunchecked"];

    }else{
        self.anonymousReminderChecked = YES;
        self.anonymousCheckBox.image = [UIImage imageNamed:@"homechecked"];
    }
}



-(void)doneGetRecurringPayments:(NSNotification *)notification{
    
    
    @try {
        NSDictionary *userInfo = [notification valueForKeyPath:@"userInfo"];
        //NSLog(@"UserInfo: %@", userInfo);
        
        self.recurringDonationDictionary = [NSDictionary dictionary];
        if ([[userInfo valueForKey:@"status"] isEqualToString:@"success"]) {
            
            id results = [[userInfo valueForKey:@"apiResponse"] valueForKey:@"Results"];
            
            
            if ([[results class] isSubclassOfClass:[NSDictionary class]]) {
                
                NSDictionary *myDictionary = [NSDictionary dictionaryWithDictionary:results];
                
                if ([[myDictionary valueForKey:@"MerchantId"] intValue] == self.myMerchant.merchantId) {
                    self.recurringDonationDictionary = [NSDictionary dictionaryWithDictionary:myDictionary];
                    self.recurringAmount = [[self.recurringDonationDictionary valueForKey:@"Amount"] doubleValue] + [[self.recurringDonationDictionary valueForKey:@"Gratuity"] doubleValue];
                }
                
            }else if ([[results class] isSubclassOfClass:[NSArray class]]) {
                
                NSArray *myArray = [NSArray arrayWithArray:results];
                
                for (int i = 0; i < [myArray count]; i++) {
                    NSDictionary *myDictionary = [myArray objectAtIndex:i];
                    
                    if ([[myDictionary valueForKey:@"MerchantId"] intValue] == self.myMerchant.merchantId) {
                        
                        self.recurringDonationDictionary = [NSDictionary dictionaryWithDictionary:myDictionary];
                        self.recurringAmount = [[self.recurringDonationDictionary valueForKey:@"Amount"] doubleValue] + [[self.recurringDonationDictionary valueForKey:@"Gratuity"] doubleValue];
                        break;
                    }
                    
                }
                
                
            }else{
                self.recurringAmount = 0.0;
                
            }
            
        }else{
            self.recurringAmount = 0.0;
            
        }
        
        [self setRecurringLabels];
    }
    @catch (NSException *exception) {
        [self setRecurringLabels];
        [rSkybox sendClientLog:@"DefaultChurchView.doneRecurringPayments" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];


    }
   

}


-(NSString *)getRecurringString{
    
    @try {
        NSString *type = [self.recurringDonationDictionary valueForKey:@"Type"];
        
        NSLog(@"Type; %@", type);
        
        if ([type isEqualToString:@"MONTHLY"]) {
            
            NSString *dayOfMonth = [[self.recurringDonationDictionary valueForKey:@"Value"] stringValue];
            
            int dayOfMonthInt = [dayOfMonth intValue];
            
            NSString *suffix = @"";
            
            if (dayOfMonthInt == 1){
                suffix = @"st";
            }else if (dayOfMonthInt == 2){
                suffix = @"nd";
                
            }else if (dayOfMonthInt == 3){
                suffix = @"rd";
            }else if (dayOfMonthInt == 21){
                suffix = @"st";
                
            }else if (dayOfMonthInt == 22){
                suffix = @"nd";
                
            }else if (dayOfMonthInt == 23){
                suffix = @"rd";
                
            }else{
                suffix = @"th";
            }
            return [NSString stringWithFormat:@"$%.2f, the %@%@ of every month", self.recurringAmount, dayOfMonth, suffix];
            
            
        }else if ([type isEqualToString:@"WEEKLY"]){
            
            int dayOfWeekInt = [[self.recurringDonationDictionary valueForKey:@"Value"] intValue];
            
            NSString *day = @"";
            if (dayOfWeekInt == 1) {
                day = @"Monday";
            }else if (dayOfWeekInt == 2){
                day = @"Tuesday";
                
            }else if (dayOfWeekInt == 3){
                day = @"Wednesday";
                
            }else if (dayOfWeekInt == 4){
                day = @"Thursday";
                
            }else if (dayOfWeekInt == 5){
                day = @"Friday";
                
            }else if (dayOfWeekInt == 6){
                day = @"Saturday";
                
            }else if (dayOfWeekInt == 7){
                day = @"Sunday";
                
            }
            
            return [NSString stringWithFormat:@"$%.2f, every %@", self.recurringAmount, day];
            
        }else if ([type isEqualToString:@"XOFMONTH"]){
            
            int dayOfWeekInt = [[self.recurringDonationDictionary valueForKey:@"Value"] intValue];
            
            NSString *day = @"";
            if (dayOfWeekInt == 1) {
                day = @"Monday";
            }else if (dayOfWeekInt == 2){
                day = @"Tuesday";
                
            }else if (dayOfWeekInt == 3){
                day = @"Wednesday";
                
            }else if (dayOfWeekInt == 4){
                day = @"Thursday";
                
            }else if (dayOfWeekInt == 5){
                day = @"Friday";
                
            }else if (dayOfWeekInt == 6){
                day = @"Saturday";
                
            }else if (dayOfWeekInt == 7){
                day = @"Sunday";
                
            }
            
            
            int prefixInt = [[self.recurringDonationDictionary valueForKey:@"xOfMonth"] intValue];
            NSString *prefix = @"";
            if (prefixInt == 1) {
                prefix = @"1st";
            }else if (prefixInt == 2){
                prefix = @"2nd";
                
            }else if (prefixInt == 3){
                prefix = @"3rd";
                
            }else if (prefixInt == 4){
                prefix = @"4th";
                
            }
            
            return [NSString stringWithFormat:@"$%.2f, the %@ %@ of every month", self.recurringAmount, prefix, day];
            

        }else{
            return @"";
        }
    }
    @catch (NSException *exception) {
        return @"";
        [rSkybox sendClientLog:@"DefaultChurchView.doneRecurringPayments" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
}


-(void)doneDeleteRecurringPayment:(NSNotification *)notification{
    
    
    @try {
        self.loadingViewController.view.hidden = YES;
        
        
        NSDictionary *userInfo = [notification valueForKey:@"userInfo"];
        
        if ([[userInfo valueForKey:@"status"] isEqualToString:@"success"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your recurring donation has been canceled." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            self.recurringAmount = 0.0;
            [self setRecurringLabels];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We encountered an error canceling your donation, please try again.  If the problem persists, please contact customer support." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We encountered an error canceling your donation, please try again.  If the problem persists, please contact customer support." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        [rSkybox sendClientLog:@"DefaultChurchView.doneRecurringPayments" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
}







- (IBAction)cancelRecurringDonation {
    
    self.loadingViewController.displayText.text = @"Removing...";
    self.loadingViewController.view.hidden = NO;
    
    ArcClient *tmp = [[ArcClient alloc] init];
    
    [tmp deleteRecurringPayment:[self.recurringDonationDictionary valueForKey:@"Id"]];
    
    
}

- (IBAction)submitRecurringDonation {
}
@end
