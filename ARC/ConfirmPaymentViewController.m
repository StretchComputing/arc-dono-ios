//
//  ConfirmPaymentViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/28/13.
//
//

#import "ConfirmPaymentViewController.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "FBEncryptorAES.h"
#import "ArcUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "InvoiceView.h"
#import "MFSideMenu.h"
#import "LeftViewController.h"
#import "GuestCreateAccount.h"

@interface ConfirmPaymentViewController ()

@end

@implementation ConfirmPaymentViewController

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    self.locationNameLabel.text = [NSString stringWithFormat:@"for %@", self.myMerchant.name];
    
    if (self.justAddedCard) {
        self.hiddenText.hidden = YES;
        self.pinPrompt.hidden = YES;
        self.pinExplainText.hidden = YES;
        self.ccPinView.hidden = YES;
    }else{
        self.pinPrompt.hidden = NO;
        self.hiddenText.hidden = NO;
        self.pinExplainText.hidden = NO;
        self.ccPinView.hidden = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentComplete:) name:@"createPaymentNotification" object:nil];


}

-(void)resignKeyboard{
    [self.hiddenText resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^(void){
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }];
    
}
- (void)viewDidLoad
{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webSuccess:) name:@"webSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webFailure:) name:@"webFailure" object:nil];

    
    self.numSelected = [self.myMerchant.donationTypes count];
    
    self.chargeFee = 0.0;

    if (self.myMerchant.chargeFee) {
        
        if (self.donationAmount < self.myMerchant.convenienceFeeCap) {
            self.chargeFee = self.myMerchant.convenienceFee;
        }
    }
    
    [self.myTableView reloadData];
    self.isDefault = YES;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultChurchId"] length] > 0) {
        //if there already is a default church, uncheck this one
        [self defaultClicked];
    }
    
    self.isAnonymous = NO;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"] length] > 0) {
        self.anonymousView.hidden = NO;
    }else{
        self.anonymousView.hidden = YES;
    }
    
    
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
    [self.hiddenText setInputAccessoryView:toolbar];
    
    
    self.hiddenText.delegate = self;
    [rSkybox addEventToSession:@"viewConfirmPaymentViewController"];

    self.incorrectPinCount = 0;
   
   // self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
   // self.topLineView.layer.shadowRadius = 1;
   // self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
   // self.backView.backgroundColor = dutchTopNavColor;
    
    
    
    
    
    
    self.confirmButton.text = @"Go To Payment";
    self.confirmButton.textColor = [UIColor whiteColor];
    self.confirmButton.tintColor = dutchGreenColor;
    
    self.myTotalLabel.text = [NSString stringWithFormat:@"$%.2f", self.donationAmount + self.chargeFee];
    if (self.selectedCard) {
       // self.paymentLabel.text = [NSString stringWithFormat:@"****%@", [self.selectedCard.sample substringFromIndex:[self.selectedCard.sample length]-4]];
        //self.paymentLabel.text = self.selectedCard.sample;
        
        if ([self.selectedCard.sample rangeOfString:@"Credit Card"].location == NSNotFound && [self.selectedCard.sample rangeOfString:@"Debit Card"].location == NSNotFound) {
            
            self.paymentLabel.text = [NSString stringWithFormat:@"%@", self.selectedCard.sample];
            
        }else{
            self.paymentLabel.text = [NSString stringWithFormat:@"%@  %@", [ArcUtility getCardNameForType:self.selectedCard.cardType], [self.selectedCard.sample substringFromIndex:[self.selectedCard.sample length] - 8] ];
            
        }
        
        
        
    }else{
        self.paymentLabel.text = [NSString stringWithFormat:@"%@", self.mySelectedCard.sample];
        
        self.paymentLabel.text = [NSString stringWithFormat:@"%@  %@", [ArcUtility getCardNameForType:self.mySelectedCard.cardType], [self.mySelectedCard.sample substringFromIndex:[self.mySelectedCard.sample length] - 8] ];
        

    }
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.hiddenText.keyboardType = UIKeyboardTypeNumberPad;
   // self.hiddenText.delegate = self;
    self.hiddenText.text = @"";
   // [self.view addSubview:self.hiddenText];

}




-(void)setValues:(NSString *)newString{
    
    
    if ([newString length] < 5) {
        
        @try {
            self.checkNumOne.text = [newString substringWithRange:NSMakeRange(0, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumOne.text = @"";
        }
        
        @try {
            self.checkNumTwo.text = [newString substringWithRange:NSMakeRange(1, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumTwo.text = @"";
        }
        
        @try {
            self.checkNumThree.text = [newString substringWithRange:NSMakeRange(2, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumThree.text = @"";
        }
        
        @try {
            self.checkNumFour.text = [newString substringWithRange:NSMakeRange(3, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumFour.text = @"";
        }
        
        
        
    }
}






- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSUInteger newLength = [self.hiddenText.text length] + [string length] - range.length;
    
    @try {
        
      
        
        if (newLength > 4) {
            return FALSE;
        }else{

            return TRUE;
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ConfirmPayment.testField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



- (IBAction)confirmAction {
    
    [self submit:nil];
}

- (IBAction)submit:(id)sender {
    @try {
        
        

        
        if (self.justAddedCard) {
            [self performSelector:@selector(createPayment)];

        }else{
            if ([self.hiddenText.text length] == 0) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Pin" message:@"Please enter your full credit card PIN.  Your PIN is the 4 digit number you created when you saved this card." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }else{
                
                [self performSelector:@selector(createPayment)];
                
            }
        }
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"CreditCardPayment.submit" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



-(void)createPayment{
    @try{
        
        
        if (self.isDefault) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", self.myMerchant.merchantId] forKey:@"defaultChurchId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSString *pinNumber = self.hiddenText.text;
        

        NSString *ccNumber;
        NSString *ccSecurityCode;
        
        if (self.selectedCard) {
            ccNumber = [FBEncryptorAES decryptBase64String:self.selectedCard.number keyString:pinNumber];
           ccSecurityCode = [FBEncryptorAES decryptBase64String:self.selectedCard.securityCode keyString:pinNumber];
        }else{
            ccNumber = self.mySelectedCard.number;
            ccSecurityCode = self.mySelectedCard.securityCode;
        }

        
        
        if (ccNumber && ([ccNumber length] > 0)) {

            //Go to the HTML5 page
            
            NSString *url = @"";
        
            ArcClient *client = [[ArcClient alloc] init];
            NSString *token = [client authHeader];
            
            NSString *guestId = @"";
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] == 0) {
                guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"guestId"];
            }else{
                guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
                
            }
            
            NSString *expiration = @"";
        
            if (self.selectedCard) {
                expiration = self.selectedCard.expiration;
                
            }else{
                expiration = self.mySelectedCard.expiration;
                
            }
            
            NSString *anonymous = @"false";
            
            if (self.isAnonymous) {
                anonymous = @"true";
            }
            NSString *cardType = [ArcUtility getCardTypeForNumber:ccNumber];
            
            NSString *passUrl = [client getCurrentUrl];

            NSString *startUrl = [passUrl stringByReplacingOccurrencesOfString:@"/rest/v1/" withString:@""];
        
            
            url = [NSString stringWithFormat:@"%@/content/confirmpayment/confirmpayment.html?invoiceAmount=%.2f&customerId=%@&authenticationToken=%@&invoiceId=%d&merchantId=%d&gratuity=%.2f&type=%@&cardType=%@&fundSourceAccount=%@&expiration=%@&pin=%@&anonymous=%@&token=%@&serverUrl=%@", startUrl, self.donationAmount, guestId, @"", self.myMerchant.invoiceId, self.myMerchant.merchantId, self.chargeFee, @"CREDIT", cardType, ccNumber, expiration, ccSecurityCode, anonymous, token, passUrl];
            
            for (int i = 0; i < [self.myItemsArray count]; i++) {
                
                NSDictionary *item = [self.myItemsArray objectAtIndex:i];
                url = [url stringByAppendingFormat:@"&Amount=%@&Description=%@&ItemId=%@&Percent=%@&Value=%@", [item valueForKey:@"Amount"], [item valueForKey:@"Description"], [item valueForKey:@"ItemId"], [item valueForKey:@"Percent"], [item valueForKey:@"Value"]];
            }
            NSLog(@"URL: %@", url);
            
            url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            url = [url stringByReplacingOccurrencesOfString:@"==" withString:@"%3D%3D"];
            NSLog(@"Encoded: %@", url);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
            /*
            //[self.activity startAnimating];
            self.loadingViewController.displayText.text = @"Sending Donation...";
            [self.loadingViewController startSpin];
         
            
            
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            NSDictionary *loginDict = [[NSDictionary alloc] init];
            
            NSNumber *invoiceAmount = [NSNumber numberWithDouble:self.donationAmount];
            [ tempDictionary setObject:invoiceAmount forKey:@"InvoiceAmount"];
            [ tempDictionary setObject:invoiceAmount forKey:@"Amount"];
            
            [ tempDictionary setObject:@"" forKey:@"AuthenticationToken"];
            
            [ tempDictionary setObject:ccNumber forKey:@"FundSourceAccount"];
            
            NSString *guestId = @"";
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] == 0) {
                guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"guestId"];
            }else{
                guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
                
            }
            
            
            
            [ tempDictionary setObject:guestId forKey:@"CustomerId"];
            
            if (self.selectedCard) {
                [ tempDictionary setObject:self.selectedCard.expiration forKey:@"Expiration"];

            }else{
                [ tempDictionary setObject:self.mySelectedCard.expiration forKey:@"Expiration"];

            }
            
            if (self.chargeFee > 0.0) {
                [tempDictionary setObject:[NSNumber numberWithDouble:self.chargeFee] forKey:@"Gratuity"];
            }
            
            NSString *invoiceIdString = [NSString stringWithFormat:@"%d", self.myMerchant.invoiceId];
            [ tempDictionary setObject:invoiceIdString forKey:@"InvoiceId"];
            NSString *merchantIdString = [NSString stringWithFormat:@"%d", self.myMerchant.merchantId];
            [ tempDictionary setObject:merchantIdString forKey:@"MerchantId"];
            
            [ tempDictionary setObject:ccSecurityCode forKey:@"Pin"];
            
            [ tempDictionary setObject:@"CREDIT" forKey:@"Type"];
            
            if (self.isAnonymous) {
                [tempDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"Anonymous"];
            }
            
            
            NSString *cardType = [ArcUtility getCardTypeForNumber:ccNumber];
            [ tempDictionary setObject:cardType forKey:@"CardType"];
            
            
            
            
            
            if ([self.myItemsArray count] > 0) {
                [tempDictionary setValue:self.myItemsArray forKey:@"Items"];
            }
            
            
            loginDict = tempDictionary;

            ArcClient *client = [[ArcClient alloc] init];
            
      
            
            self.myTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(createPaymentTimer) userInfo:nil repeats:NO];
            
            
            self.navigationController.sideMenu.allowSwipeOpenLeft = NO;
            
            [client createPayment:loginDict];
            */
            
        }else{
            
            if (self.incorrectPinCount < 3) {
                self.incorrectPinCount ++;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Pin" message:@"Please enter your correct credit card PIN.  Your PIN is the 4 digit number you created when you saved this card." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                
                self.checkNumOne.text = @"";
                self.checkNumTwo.text = @"";
                self.checkNumThree.text = @"";
                self.checkNumFour.text = @"";
                
                self.hiddenText.text = @"";
            }else{
                
                
                ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                [mainDelegate deleteCreditCardWithNumber:self.creditCardNumber andSecurityCode:self.creditCardSecurityCode andExpiration:self.creditCardExpiration];
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Deleted" message:@"You have entered your PIN wrong too many times.  For security reasons, this card has been deleted.  Please re-add the card with a new PIN, and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                
                LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
                [tmp homeSelected];
                
            }
            
          
        }
        
    }
    @catch (NSException *e) {
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Error" message:@"We were unable to process your payment at this time, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        
        [rSkybox sendClientLog:@"CreditCardPayment.createPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)createPaymentTimer{
 
    
    [self showHighVolumeOverlay];
}


-(void)showHighVolumeOverlay{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.loadingViewController.displayText.text = @"dono is experiencing high volume, or a weak internet connection, please be patient...";
        self.loadingViewController.displayText.font = [UIFont fontWithName:[self.loadingViewController.displayText.font fontName] size:14];
        
        self.loadingViewController.displayText.numberOfLines = 3;
        CGRect frame = self.loadingViewController.mainBackView.frame;
        frame.origin.y -= 20;
        frame.size.height += 40;
        frame.origin.x = 10;
        frame.size.width = 300;
        self.loadingViewController.mainBackView.frame = frame;
        
        CGRect frame2 = self.loadingViewController.displayText.frame;
        frame2.origin.y -= 20;
        frame2.size.height += 40;
        frame2.origin.x = 10;
        frame2.size.width = 300;
        self.loadingViewController.displayText.frame = frame2;
        
    }];
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
    
    self.confirmButton.enabled = YES;
  
    
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
        errorMsg = ARC_ERROR_MSG;
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

-(void)paymentComplete:(NSNotification *)notification{
    
    @try {
        self.navigationController.sideMenu.allowSwipeOpenLeft = YES;

        [self.myTimer invalidate];
        
        //[self hideHighVolumeOverlay];
        
        BOOL editCardOption = NO;
        BOOL duplicateTransaction = NO;
        BOOL displayAlert = NO;
        BOOL possibleError = NO;
        BOOL networkError = NO;
        
        self.confirmButton.enabled = YES;
        self.navigationItem.hidesBackButton = NO;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        //[self.activity stopAnimating];
        [self.loadingViewController stopSpin];
        
        NSString *errorMsg= @"";
        if ([status isEqualToString:@"success"]) {
            
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
                //not a guest
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Congratulations, your donation was successfully processed!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
                [tmp homeSelected];
            }else{
                //guest
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Congratulations, your donation was successfully processed!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                [self performSegueWithIdentifier:@"saveInfo" sender:nil];
            }
        } else if([status isEqualToString:@"error"]){
                
                
                int errorCode = [[responseInfo valueForKey:@"error"] intValue];
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
                    errorMsg = ARC_ERROR_MSG;
                }
            } else {
                // must be failure -- user notification handled by ArcClient
                errorMsg = ARC_ERROR_MSG;
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
    @catch (NSException *e) {
        
        [self.loadingViewController stopSpin];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:@"We encountered an error processing your request, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [rSkybox sendClientLog:@"CreditCardPayment.paymentComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}




- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"saveInfo"]) {
            
            if (self.selectedCard) {
                GuestCreateAccount *next = [segue destinationViewController];
                next.myInvoice = self.myInvoice;
                next.ccNumber = self.selectedCard.number;
                next.ccSecurityCode = self.selectedCard.securityCode;
                next.ccExpiration = self.selectedCard.expiration;
                
                
                next.askSaveCard = NO;
            }else{
                GuestCreateAccount *next = [segue destinationViewController];
                next.myInvoice = self.myInvoice;
                next.ccNumber = self.mySelectedCard.number;
                next.ccSecurityCode = self.mySelectedCard.securityCode;
                next.ccExpiration = self.mySelectedCard.expiration;
                next.askSaveCard = NO;
                
                next.askSaveCard = YES;
                
            }
           
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ConfirmPayment.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}





- (IBAction)anonymousClicked {
    
    if (self.isAnonymous) {
        self.isAnonymous = NO;
        [self.anonymousImageView setImage:[UIImage imageNamed:@"homeunchecked"]];

    }else{
        self.isAnonymous = YES;
        [self.anonymousImageView setImage:[UIImage imageNamed:@"homechecked"]];
    }
}

- (IBAction)defaultClicked {
    
    
    if (self.isDefault) {
        self.isDefault = NO;
        [self.defaultImageView setImage:[UIImage imageNamed:@"homeunchecked"]];
        
    }else{
        self.isDefault = YES;
        [self.defaultImageView setImage:[UIImage imageNamed:@"homechecked"]];
    }
    
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subCell"];
        
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
        UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:2];
        UIImageView *helpImage = (UIImageView *)[cell.contentView viewWithTag:3];
        
        helpImage.hidden = YES;
  
        if (self.chargeFee > 0) {
            
            if (indexPath.row == [self.myItemsArray count]) {
                helpImage.hidden = NO;
                nameLabel.text = @"Processing Fee";
                priceLabel.text = [NSString stringWithFormat:@"%.2f", self.chargeFee];
            }else{
                NSDictionary *donationType = [self.myItemsArray objectAtIndex:indexPath.row];
                nameLabel.text = [donationType valueForKey:@"Description"];
                priceLabel.text = [donationType valueForKey:@"Value"];
            }
        }else{
            
            NSDictionary *donationType = [self.myItemsArray objectAtIndex:indexPath.row];
            nameLabel.text = [donationType valueForKey:@"Description"];
            priceLabel.text = [donationType valueForKey:@"Value"];
            
        }
 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ConfirmPayment.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 33;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    int x = 0;
    
    if (self.chargeFee > 0) {
        x = 1;
    }
    return [self.myItemsArray count] + x;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.chargeFee > 0 && indexPath.row == [self.myItemsArray count]) {
        
        NSString *message = [NSString stringWithFormat:@"Due to the cost of processing credit card transactions, a $%.2f processing fee will be added to all donations of $%.2f or less.", self.chargeFee, self.myMerchant.convenienceFeeCap];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Processing Fee" message:message delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        
    }
}


- (IBAction)pinBegan:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^(void){
        CGRect frame = self.view.frame;
        frame.origin.y = -116;
        self.view.frame = frame;
    }];
}
- (IBAction)showPinHelp {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card PIN" message:@"Your card pin is the 4 digit number you entered when saving this card.  If you do not remember your PIN, please add a new form of payment." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
@end
