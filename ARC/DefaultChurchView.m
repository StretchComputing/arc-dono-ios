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
#import "ChurchAmountSingleType.h"
#import "ChurchDontationTypeSelector.h"
#import "rSkybox.h"
#import "ArcUtility.h"
#import "AddCreditCardGuest.h"
#import "ConfirmPaymentViewController.h"
#import "LeftViewController.h"

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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Default Location" message:@"You have selected this as your default location.  This page will show when the app loads, or when you click 'Home' from the left menu.  \n \n  If you would like to view other locations, please select 'View All Locations'.  \n \n  If you would like to remove your default location, you can do so from the 'Settings' page." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View All Locations", @"Go Settings", nil];
    [alert show];
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
        
        ArcClient *tmp = [[ArcClient alloc] init];
        NSString *serverUrl = [tmp getCurrentUrl];
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if ([mainDelegate.imageDictionary valueForKey:[NSString stringWithFormat:@"%d", self.myMerchant.merchantId]]) {
            
            NSData *imageData = [mainDelegate.imageDictionary valueForKey:[NSString stringWithFormat:@"%d", self.myMerchant.merchantId]];
            
            self.merchantImage.image = [UIImage imageWithData:imageData];
            
        }else{
            
            
            NSString *logoImageUrl = [NSString stringWithFormat:@"%@Images/App/Logos/%d.jpg", serverUrl, self.myMerchant.merchantId];
            logoImageUrl = [logoImageUrl stringByReplacingOccurrencesOfString:@"/rest/v1" withString:@""];
            
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:logoImageUrl]];
                
                if ( data == nil ){
                    return;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImage *logoImage = [UIImage imageWithData:data];
                    
                    if (logoImage) {
                        self.merchantImage.image = logoImage;
                        
                        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                        [mainDelegate.imageDictionary setValue:data forKey:[NSString stringWithFormat:@"%d", self.myMerchant.merchantId]];
                    }
                });
            });
            
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
        if ([self.myMerchant.donationTypes count] > 1) {
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"skipDonationOptions"] length] > 0) {
                [self performSegueWithIdentifier:@"single" sender:self];
                
            }else{
                [self performSegueWithIdentifier:@"multiple" sender:self];
                
            }
            
        }else{
            
            [self performSegueWithIdentifier:@"single" sender:self];
            
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"DefaultChurchView.makeDonation" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }


}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    @try {
        
        
        NSMutableArray *itemArray = [NSMutableArray array];
        
        NSString *value = [NSString stringWithFormat:@"%.2f", [self.amount doubleValue]];
        NSDictionary *item = @{@"Amount":@"1", @"Percent":@"1.0", @"ItemId":[self.donationType valueForKey:@"Id"], @"Value":value, @"Description":[self.donationType valueForKey:@"Description"]};
        
        [itemArray addObject:item];
        
        
        if ([[segue identifier] isEqualToString:@"addCard"]) {
            
            AddCreditCardGuest *addCard = [segue destinationViewController];
            addCard.myMerchant = self.myMerchant;
            
            
            addCard.donationAmount = [self.amount doubleValue];
            addCard.myItemsArray = [NSMutableArray arrayWithArray:itemArray];
            
            
        }else if ([[segue identifier] isEqualToString:@"payCard"]) {
            
            ConfirmPaymentViewController *confirm = [segue destinationViewController];
            confirm.donationAmount = [self.amount doubleValue];
            confirm.selectedCard = self.selectedCard;
            confirm.myMerchant = self.myMerchant;
            confirm.myItemsArray = [NSMutableArray arrayWithArray:itemArray];
            
        }else if ([[segue identifier] isEqualToString:@"single"]) {
            
            ChurchAmountSingleType *single = [segue destinationViewController];
            single.myMerchant = self.myMerchant;
            
            if ([self.myMerchant.donationTypes count] == 1) {
                single.donationType = [self.myMerchant.donationTypes objectAtIndex:0];
            }
            
        }else if ([[segue identifier] isEqualToString:@"multiple"]) {
            
            ChurchDontationTypeSelector *multiple = [segue destinationViewController];
            multiple.myMerchant = self.myMerchant;
        }else if ([[segue identifier] isEqualToString:@"goHistory"]) {
            
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
                
                LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
                [tmp supportSelected];
                
                
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
