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
#import "ArcClient.h"
#import "LeftViewController.h"
#import "GuestCreateAccount.h"

@interface ChurchAmountSingleType ()

@end

@implementation ChurchAmountSingleType

-(void)viewWillDisappear:(BOOL)animated{
    
    
    self.navigationController.sideMenu.allowSwipeOpenLeft = YES;
    self.navigationController.sideMenu.allowSwipeOpenRight = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webSuccess:) name:@"webSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webFailure:) name:@"webFailure" object:nil];
    
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
    
    @try {
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
        
        self.quickButtonOne.text = [NSString stringWithFormat:@"$%.0f", self.myMerchant.quickPayOne];
        self.quickButtonTwo.text = [NSString stringWithFormat:@"$%.0f", self.myMerchant.quickPayTwo];
        self.quickButtonThree.text = [NSString stringWithFormat:@"$%.0f", self.myMerchant.quickPayThree];
        self.quickButtonFour.text = [NSString stringWithFormat:@"$%.0f", self.myMerchant.quickPayFour];
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
        
        
        
        NSArray *itemsArray = [NSArray arrayWithObjects:flexButton, doneButton, nil];
        
        
        [toolbar setItems:itemsArray];
        
        [self.amountText setInputAccessoryView:toolbar];
        
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"didShowSingleOverlay"] length] == 0) {
            //[[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didShowSingleOverlay"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
            //NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(doneHelp) userInfo:Nil repeats:NO];
            //self.helpOverlayView.hidden = NO;
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ChurchAmountSingleType.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
   
}

-(void)doneHelp{
    self.helpOverlayView.hidden = YES;
}

-(void)closeHelpOverlay{
    self.helpOverlayView.hidden = YES;
}

-(void)resignKeyboard{
    @try {
        double amountDouble = [self.amountText.text doubleValue];
        
        self.amountText.text = [NSString stringWithFormat:@"%.2f", amountDouble];
        
        self.amountSlider.value = amountDouble / 100.0;
        [self.amountText resignFirstResponder];
    }
    
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ChurchAmountSingleType.resignKeyboard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
   
}


- (IBAction)goBack {
    
    if (self.isHome) {
        [self.navigationController.sideMenu toggleLeftSideMenu];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)textEditDidBegin {
    
    double amountDouble = [self.amountText.text doubleValue];
    
    if (amountDouble == 0.0) {
        self.amountText.text = @"";
    }
}
- (IBAction)payAction {
    
    @try {
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
            
            if ([self.creditCards count] == -1) {
                
                self.selectedCard = [self.creditCards objectAtIndex:0];
                
               // NSLog(@"SelectedCard: %@", self.selectedCard);
                
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
       // NSLog(@"E: %@", exception);
        [rSkybox sendClientLog:@"ChurchAmountSingleType.payAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

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
        
      //  NSLog(@"E: %@", e);
        [rSkybox sendClientLog:@"ChurchAmountSingleType.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}






- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        
        
        
        if ([[segue identifier] isEqualToString:@"saveInfo"]) {
            
            
            GuestCreateAccount *next = [segue destinationViewController];
            
            next.ccNumber = self.webCardNumber;
            next.ccSecurityCode = self.webSecurityCode;
            next.ccExpiration = self.webExpiration;
            
            next.askSaveCard = YES;
            
            
            
        }else{
            
            NSMutableArray *itemArray = [NSMutableArray array];
            
            NSString *value = [NSString stringWithFormat:@"%.2f", [self.amountText.text doubleValue]];
            NSDictionary *item = @{@"Amount":@"1", @"Percent":@"1.0", @"ItemId":[self.donationType valueForKey:@"Id"], @"Value":value, @"Description":[self.donationType valueForKey:@"Description"]};
            
            [itemArray addObject:item];
            
            
            if ([[segue identifier] isEqualToString:@"addCard"]) {
                
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
                
                self.chargeFee = 0.0;
                
                if (self.myMerchant.chargeFee) {
                    
                    if ([self.amountText.text doubleValue] < self.myMerchant.convenienceFeeCap) {
                        self.chargeFee = self.myMerchant.convenienceFee;
                    }
                }
                
                NSString *passUrl = [client getCurrentUrl];
                
                NSString *startUrl = [passUrl stringByReplacingOccurrencesOfString:@"/rest/v1/" withString:@""];
                
                url = [NSString stringWithFormat:@"%@/content/confirmpayment/confirmpayment.html?invoiceAmount=%.2f&customerId=%@&authenticationToken=%@&invoiceId=%d&merchantId=%d&gratuity=%.2f&anonymous=%@&token=%@&serverUrl=%@", startUrl, [self.amountText.text doubleValue], guestId, @"", self.myMerchant.invoiceId, self.myMerchant.merchantId, self.chargeFee, anonymous, token, passUrl];
                
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
                
                
                
                
                
                /*
                 AddCreditCardGuest *addCard = [segue destinationViewController];
                 addCard.myMerchant = self.myMerchant;
                 
                 //  NSLog(@"Amount: %f", [self.amountText.text doubleValue]);
                 
                 addCard.donationAmount = [self.amountText.text doubleValue];
                 addCard.myItemsArray = [NSMutableArray arrayWithArray:itemArray];
                 */
                
            }else if ([[segue identifier] isEqualToString:@"payCard"]) {
                
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];

                ConfirmPaymentViewController *confirm = [segue destinationViewController];
                confirm.donationAmount = [self.amountText.text doubleValue];
                confirm.selectedCard = self.selectedCard;
                confirm.myMerchant = self.myMerchant;
                confirm.myItemsArray = [NSMutableArray arrayWithArray:itemArray];
                
            }

            
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ChurchAmountSingleType.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)quickActionOne {
    self.amountText.text = [NSString stringWithFormat:@"%.2f", self.myMerchant.quickPayOne];
    [self payAction];
}

- (IBAction)quickActionTwo{
    self.amountText.text = [NSString stringWithFormat:@"%.2f", self.myMerchant.quickPayTwo];
    [self payAction];
}
- (IBAction)quickActionThree{
    self.amountText.text = [NSString stringWithFormat:@"%.2f", self.myMerchant.quickPayThree];
    [self payAction];
}
- (IBAction)quickActionFour{
    self.amountText.text = [NSString stringWithFormat:@"%.2f", self.myMerchant.quickPayFour];
    [self payAction];
}


- (IBAction)sliderChanged {
    
    
    @try {
        
        double value = self.amountSlider.value;
        
        double amount = value * 100.0 * 100.0;
        
        amount = 500 * floor((amount/500));
        
        amount = amount/100.0;
        
        self.amountText.text = [NSString stringWithFormat:@"%.2f", amount];
    }
    
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ChurchAmountSingleType.sliderChanged" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
}





-(void)webSuccess:(NSNotification *)notification{
    
    


    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
        //not a guest
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Congratulations, your donation was successfully processed!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
        [tmp homeSelected];
    }else{
        //guest
        
        NSDictionary *userInfo = [notification valueForKey:@"userInfo"];
        
        self.webCardNumber = [userInfo valueForKey:@"cardNumber"];
        self.webExpiration = [userInfo valueForKey:@"cardExpiration"];
        self.webSecurityCode = [userInfo valueForKey:@"cardSecurityCode"];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Congratulations, your donation was successfully processed!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        [self performSegueWithIdentifier:@"saveInfo" sender:nil];
    }
    
}

-(void)webFailure:(NSNotification *)notification{
    
    BOOL editCardOption = NO;
    BOOL duplicateTransaction = NO;
    BOOL displayAlert = NO;
    BOOL possibleError = NO;
    BOOL networkError = NO;
    
    
    
    NSString *errorMsg = @"";
    
    int errorCode = [[[notification valueForKey:@"userInfo"] valueForKey:@"errorCode"] intValue];
    if(errorCode == CANNOT_GET_PAYMENT_AUTHORIZATION) {
        //errorMsg = @"Credit card not approved.";
        editCardOption = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credit Card" message:@"Your credit card could not be authorized.  Please double check your card information and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
        
        
    } else if(errorCode == FAILED_TO_VALIDATE_CARD) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credit Card" message:@"Your credit card could not be authorized.  Please double check your card information and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
        // TODO need explanation from Jim to put proper error msg
        //errorMsg = @"Failed to validate credit card";
        editCardOption = YES;
    } else if (errorCode == FIELD_FORMAT_ERROR){
        // errorMsg = @"Invalid Credit Card Field Format";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credit Card" message:@"Your credit card could not be authorized.  Please double check your card information and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
        editCardOption = YES;
    }else if(errorCode == INVALID_ACCOUNT_NUMBER) {
        // TODO need explanation from Jim to put proper error msg
        // errorMsg = @"Invalid credit/debit card number";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Card Number" message:@"The number you entered for this credit card is inavlid.  Please double check your card information and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
        
        
        editCardOption = YES;
    } else if(errorCode == MERCHANT_CANNOT_ACCEPT_PAYMENT_TYPE) {
        // TODO put exact type of credit card not accepted in msg -- Visa, MasterCard, etc.
        errorMsg = @"Merchant does not accept credit/debit card";
    } else if(errorCode == OVER_PAID) {
        errorMsg = @"Over payment. Please check invoice and try again.";
    } else if(errorCode == INVALID_AMOUNT) {
        errorMsg = @"Invalid amount. Please re-enter payment and try again.";
    } else if(errorCode == INVALID_EXPIRATION_DATE) {
        //errorMsg = @"Invalid expiration date.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Expiration Date" message:@"The expiration date you entered for this credit card is inavlid.  Please double check your card information and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
        
        
        editCardOption = YES;
    }  else if (errorCode == UNKOWN_ISIS_ERROR){
        //editCardOption = YES;
        errorMsg = @"Payment failed, please try again.";
    }else if (errorCode == PAYMENT_MAYBE_PROCESSED){
        errorMsg = @"This payment may have already processed.  To be sure, please wait 30 seconds and then try again.";
        displayAlert = YES;
    }else if(errorCode == DUPLICATE_TRANSACTION){
        duplicateTransaction = YES;
    }else if (errorCode == CHECK_IS_LOCKED){
        errorMsg = @"This check is currently locked.  Please try again in a few minutes.";
        displayAlert = YES;
    }else if (errorCode == CARD_ALREADY_PROCESSED){
        errorMsg = @"This card has already been used for payment on this invoice.  A card may only be used once per invoice.  Please try again with a different card.";
        displayAlert = YES;
    }else if (errorCode == NO_AUTHORIZATION_PROVIDED){
        errorMsg = @"Invalid Authorization, please try again.";
        displayAlert = YES;
    }else if (errorCode == NETWORK_ERROR){
        
        networkError = YES;
        errorMsg = @"dono is having problems connecting to the internet.  Please check your connection and try again.  Thank you!";
        
    }else if (errorCode == NETWORK_ERROR_CONFIRM_PAYMENT){
        
        networkError = YES;
        errorMsg = @"dono experienced a problem with your internet connection while trying to confirm your payment.  Please check with your server to see if your payment was accepted.";
        
    }else if (errorCode == PAYMENT_POSSIBLE_SUCCESS){
        errorMsg = @"error";
        possibleError = YES;
    }else if (errorCode == INVALID_SECURITY_PIN){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Security PIN" message:@"The CVV you entered for this credit card is inavlid.  Please double check your card information and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else {
        //errorMsg = ARC_ERROR_MSG;
        errorMsg = @"We were unable to process your donation at this time, please try again.";
    }
    
    
    if (displayAlert) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Warning" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        if ([errorMsg length] > 0) {
            if (networkError) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet  Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }else{
                
                if (possibleError) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Validation Failed" message:@"We were unable to validate that your payment went through.  Please verify by reloading the invoice, or checking with your server." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Failed" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
                
            }
        }
        
        
        // self.errorLabel.text = errorMsg;
        
    }
    
    if (editCardOption) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credit Card" message:@"Your payment may have failed due to invalid credit card information.  Would you like to view/edit the card you tried to make this payment with?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"View/Edit", nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credit Card" message:@"Your payment may have failed due to invalid credit card information.  Please verify your payment details and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
    }else if (duplicateTransaction){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Transaction" message:@"dono has recorded a similar transaction that happened recently.  To avoid a duplicate transaction, please wait 30 seconds and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    
    
    
    
}




@end
