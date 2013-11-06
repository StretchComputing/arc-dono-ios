//
//  ChurchAmountSingleType.m
//  HolyDutch
//
//  Created by Nick Wroblewski on 10/16/13.
//
//

#import "ChurchAmountSingleType.h"
#import "MFSideMenu.h"
#import "ArcAppDelegate.h"
#import "AddCreditCardGuest.h"
#import "rSkybox.h"
#import "ArcUtility.h"
#import "ConfirmPaymentViewController.h"

@interface ChurchAmountSingleType ()

@end

@implementation ChurchAmountSingleType

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.sideMenu.allowSwipeOpenLeft = YES;
    self.navigationController.sideMenu.allowSwipeOpenRight = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.sideMenu.allowSwipeOpenLeft = NO;
    self.navigationController.sideMenu.allowSwipeOpenRight = NO;
    
    if (self.isHome) {
        [self.goBackButton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
        self.titleLabel.text = @"Home";
        
    }else{
        self.titleLabel.text = @"Amount";
        
    }
}

- (void)viewDidLoad
{
    self.view.clipsToBounds = YES;
    self.amountSlider.value = 0.0;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.merchantNameText.text = [NSString stringWithFormat:@"to %@", self.myMerchant.name];

    NSString *toward = [self.donationType valueForKey:@"Description"];
    
    if (!toward) {
        toward = @"General Donation";
    }
    self.typeLabel.text = [NSString stringWithFormat:@"toward %@", toward];
    
    self.amountText.text = @"0.00";
    
    self.quickButtonOne.text = @"$10";
    self.quickButtonTwo.text = @"$25";
    self.quickButtonThree.text = @"$50";
    self.quickButtonFour.text = @"$75";
    self.payButton.text = @"Donate Now!";
    
   // self.quickButtonOne.textColor = [UIColor whiteColor];
    self.quickButtonOne.tintColor = dutchDarkBlueColor;

   // self.quickButtonTwo.textColor = [UIColor whiteColor];
    self.quickButtonTwo.tintColor = dutchDarkBlueColor;
    
   // self.quickButtonThree.textColor = [UIColor whiteColor];
    self.quickButtonThree.tintColor = dutchDarkBlueColor;
    
  //  self.quickButtonFour.textColor = [UIColor whiteColor];
    self.quickButtonFour.tintColor = dutchDarkBlueColor;
    
  //  self.payButton.textColor = [UIColor whiteColor];
    self.payButton.tintColor = dutchGreenColor;
    
    
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
    
    if (isIos7) {
        doneButton.tintColor = [UIColor whiteColor];
    }
    
    
    doneButton.tintColor = [UIColor whiteColor];

    NSArray *itemsArray = [NSArray arrayWithObjects:flexButton, doneButton, nil];
    
    
    [toolbar setItems:itemsArray];
    
    [self.amountText setInputAccessoryView:toolbar];
    

    

}

-(void)resignKeyboard{
    
    
    double amountDouble = [self.amountText.text doubleValue];
    
    self.amountText.text = [NSString stringWithFormat:@"%.2f", amountDouble];
    
    self.amountSlider.value = amountDouble / 100.0;
    [self.amountText resignFirstResponder];
}


- (IBAction)goBack {
    
    if (self.isHome) {
        [self.navigationController.sideMenu toggleLeftSideMenu];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (IBAction)payAction {
    
    double amountDouble = [self.amountText.text doubleValue];
    
    
    if (amountDouble == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Amount" message:@"Please enter a donation amount greater than 0." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    self.amountSlider.value = amountDouble / 100.0;

    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
    
    if ([self.creditCards count] > 0) {
        //Have at least 1 card, present UIActionSheet
        
        if ([self.creditCards count] == 1) {
            
            self.selectedCard = [self.creditCards objectAtIndex:0];
            
            NSLog(@"SelectedCard: %@", self.selectedCard);
            
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
                if (buttonIndex == [self.creditCards count] + 1 + x) {
                    //Cancel
                }else if (buttonIndex == [self.creditCards count] + x){
                    //New Card
                    [self performSegueWithIdentifier:@"addCard" sender:self];
                }
                    self.selectedCard = [self.creditCards objectAtIndex:buttonIndex - x];
                
                    [self performSegueWithIdentifier:@"payCard" sender:self];
                    
                }
            }
            
        }
        
    
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ChurchAmountSingleType.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}






- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        NSMutableArray *itemArray = [NSMutableArray array];
            
        NSString *value = [NSString stringWithFormat:@"%.2f", [self.amountText.text doubleValue]];
        NSDictionary *item = @{@"Amount":@"1", @"Percent":@"1.0", @"ItemId":[self.donationType valueForKey:@"Id"], @"Value":value, @"Description":[self.donationType valueForKey:@"Description"]};
        
        [itemArray addObject:item];
        
        
        if ([[segue identifier] isEqualToString:@"addCard"]) {
            
            AddCreditCardGuest *addCard = [segue destinationViewController];
            addCard.myMerchant = self.myMerchant;
            
            NSLog(@"Amount: %f", [self.amountText.text doubleValue]);
            
            addCard.donationAmount = [self.amountText.text doubleValue];
            addCard.myItemsArray = [NSMutableArray arrayWithArray:itemArray];
            
            
        }else if ([[segue identifier] isEqualToString:@"payCard"]) {
            
            ConfirmPaymentViewController *confirm = [segue destinationViewController];
            confirm.donationAmount = [self.amountText.text doubleValue];
            confirm.selectedCard = self.selectedCard;
            confirm.myMerchant = self.myMerchant;
            confirm.myItemsArray = [NSMutableArray arrayWithArray:itemArray];

        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ChurchAmountSingleType.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)quickActionOne {
    self.amountText.text = @"10.00";
    [self payAction];
}

- (IBAction)quickActionTwo{
    self.amountText.text = @"25.00";
    [self payAction];
}
- (IBAction)quickActionThree{
    self.amountText.text = @"50.00";
    [self payAction];
}
- (IBAction)quickActionFour{
    self.amountText.text = @"75.00";
    [self payAction];
}


- (IBAction)sliderChanged {
    
    double value = self.amountSlider.value;
    
    double amount = value * 100.0 * 100.0;
    
    amount = 500 * floor((amount/500));
    
    amount = amount/100.0;
    
    self.amountText.text = [NSString stringWithFormat:@"%.2f", amount];
    
    
}
@end
