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

@interface DefaultChurchView ()

@end

@implementation DefaultChurchView
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
- (void)viewDidLoad
{
    @try {
        
        
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
        
        
        
        if ([self.myMerchant.name isEqualToString:@"Evangelical United Methodist"]) {
            self.mainImage.image = [UIImage imageNamed:@"Evangelical"];
        }else if ([self.myMerchant.name isEqualToString:@"Living Waters United Methodist"]) {
            self.mainImage.image = [UIImage imageNamed:@"LivingWaters"];

        }else if ([self.myMerchant.name isEqualToString:@"St. Paul's United Methodist"]) {
            self.mainImage.image = [UIImage imageNamed:@"StPaul"];

        }else if ([self.myMerchant.name isEqualToString:@"Browining United Methodist"]) {
            self.mainImage.image = [UIImage imageNamed:@"Browning"];

        }else if ([self.myMerchant.name isEqualToString:@"Arc Mobile Inc"]) {
            self.mainImage.image = [UIImage imageNamed:@"testChurch"];
            
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
                
                
                NSString *logoImageUrl = [NSString stringWithFormat:@"%@Images/App/Logos/%d.jpg", serverUrl, self.myMerchant.merchantId];
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
        
        [self goToWebPayment];
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
        
        
        NSString *passUrl = [client getCurrentUrl];
        
        NSString *startUrl = [passUrl stringByReplacingOccurrencesOfString:@"/rest/v1/" withString:@""];
        
        url = [NSString stringWithFormat:@"%@/content/confirmpayment/confirmpayment.html?invoiceAmount=%.2f&customerId=%@&authenticationToken=%@&invoiceId=%d&merchantId=%d&gratuity=%.2f&anonymous=%@&token=%@&serverUrl=%@&type=CREDIT&convenienceFee=%f&convenienceFeeCap=%f&name=%@", startUrl, 0.0, guestId, @"", self.myMerchant.invoiceId, self.myMerchant.merchantId, 0.0, anonymous, token, passUrl, self.myMerchant.convenienceFee, self.myMerchant.convenienceFeeCap,self.myMerchant.name];
        
        for (int i = 0; i < [itemArray count]; i++) {
            
            NSDictionary *item = [itemArray objectAtIndex:i];
            url = [url stringByAppendingFormat:@"&Amount=%@&Description=%@&ItemId=%@&Percent=%@&Value=%@", [item valueForKey:@"Amount"], [item valueForKey:@"Description"], [item valueForKey:@"ItemId"], [item valueForKey:@"Percent"], [item valueForKey:@"Value"]];
        }
        // NSLog(@"URL: %@", url);
        
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // url = [url stringByReplacingOccurrencesOfString:@"==" withString:@"%3D%3D"];
        
        int location = [url rangeOfString:@"&serverUrl"].location;
        location = location - 4;
        url = [url stringByReplacingOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(location, 5)];
        // NSLog(@"Encoded: %@", url);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.goToWebPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
    
    
    
}



-(IBAction)contactAction{
    
    
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
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
        [self performSegueWithIdentifier:@"goHistory" sender:self];
        
    }else{
        self.logInAlert = [[UIAlertView alloc] initWithTitle:@"Not Signed In." message:@"Only signed in users view their payment history. Select 'Go Profile' to log in or create an account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Go Profile", nil];
        [self.logInAlert show];
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
@end
