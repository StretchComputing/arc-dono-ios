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

@interface DefaultChurchView ()

@end

@implementation DefaultChurchView


-(void)viewWillDisappear:(BOOL)animated{
    
    

}
-(void)viewWillAppear:(BOOL)animated{
    
    @try {
        
        
        
        
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
            [self goToWebPayment];
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
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] == 0) {
                //guest
                self.guestCreateAccountView.hidden = NO;
                
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
        self.guestCreateAccountFrontView.layer.cornerRadius = 5.0;

        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];
        
        

        [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (IBAction)makeDonation:(id)sender {
    
    
    @try {
        
        if (!self.didFinishCards) {
            
            self.loadingViewController.displayText.text = @"Loading Donation...";
            [self.loadingViewController startSpin];
        
        }else{
            [self goToWebPayment];

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
        
        
        
        
        
        if ([[segue identifier] isEqualToString:@"addCard"]) {
            
          
            
            
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
            self.logInAlert = [[UIAlertView alloc] initWithTitle:@"Not Signed In." message:@"Only signed in users view their payment history. Select 'Go Profile' to log in or create an account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Go Profile", nil];
            [self.logInAlert show];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.goDonationHistory" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
  


}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    @try {
        
        if (alertView == self.logInAlert) {
            
            if (buttonIndex == 1) {
                //Go Profile
                
                LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
                [tmp profileSelected];
            }
        }else if (alertView == self.areYouSureAlert){
            
            if (buttonIndex == 0) {
                
                [ArcClient trackEvent:@"GUEST_CREATE_ACCOUNT_CANCEL_SECONDARY"];

                
                self.guestCreateAccountView.hidden = YES;
                
                [self.guestCreateAccountEmailText resignFirstResponder];
                [self.guestCreateAccountPasswordText resignFirstResponder];
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
    
    LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
    [tmp newChurchAction];
    
    
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
    
    [ArcClient trackEvent:@"GUEST_CREATE_ACCOUNT_CANCEL_INITIAL"];

    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"hasShownAreYouSure"] length] == 0) {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"hasShownAreYouSure"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.areYouSureAlert = [[UIAlertView alloc] initWithTitle:@"Remain Anonymous?" message:@"Are you sure you want to remain anonymous?  For tax purposes, we recommend you sign up so you can receive email receipts." delegate:self cancelButtonTitle:@"Stay Anonymous" otherButtonTitles:@"Sign Up!", nil];
        [self.areYouSureAlert show];
        
    }else{
        self.guestCreateAccountView.hidden = YES;
        
        [self.guestCreateAccountEmailText resignFirstResponder];
        [self.guestCreateAccountPasswordText resignFirstResponder];
    }
 
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
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Thank your for registering, email receipts will now be sent to your address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
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
            
            self.didFinishCards = NO;
            ArcClient *tmp = [[ArcClient alloc] init];
            [tmp getListOfCreditCards];
            
            
            
        } else if([status isEqualToString:@"error"]){
            
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            
            if(errorCode == 103) {
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


@end
