//
//  RecurringDonationFinal.m
//  Dono
//
//  Created by Nick Wroblewski on 3/26/14.
//
//

#import "RecurringDonationFinal.h"
#import "ArcAppDelegate.h"
#import "ArcUtility.h"
#import "ArcClient.h"
#import "DefaultChurchView.h"
#import "rSkybox.h"

@interface RecurringDonationFinal ()

@end

@implementation RecurringDonationFinal

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneCreateRecurringPayment:) name:@"createRecurringPaymentNotification" object:nil];
        
        
        self.titleLabel.text = self.myMerchant.name;
        
        NSString *number = [self.selectedCard valueForKey:@"Number"];
        NSString *type = [ArcUtility getCardTypeForNumber:number];
        
        if ([[self.selectedCard valueForKey:@"CCToken"] length] == 0) {
            number = [number stringByReplacingCharactersInRange:NSMakeRange(6, 6) withString:@"******"];
        }
        self.paymentLabel.text = [NSString stringWithFormat:@"%@   %@", type, number];
        
        
        if ([self.scheduleString isEqualToString:@"weekly"]) {
            
            NSString *day = @"";
            if (self.mainDetail == 1) {
                day = @"Monday";
            }else if (self.mainDetail == 2){
                day = @"Tuesday";
                
            }else if (self.mainDetail == 3){
                day = @"Wednesday";
                
            }else if (self.mainDetail == 4){
                day = @"Thursday";
                
            }else if (self.mainDetail == 5){
                day = @"Friday";
                
            }else if (self.mainDetail == 6){
                day = @"Saturday";
                
            }else if (self.mainDetail == 7){
                day = @"Sunday";
                
            }
            
            self.scheduleLabel.text = [NSString stringWithFormat:@"Every %@", day];
            
            
        }else if ([self.scheduleString isEqualToString:@"monthly"]){
            
            int dayOfMonthInt = self.mainDetail;
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
            
            
            
            self.scheduleLabel.text = [NSString stringWithFormat:@"%d%@ of every month", self.mainDetail, suffix];
        }else{
            //x of month
            
            NSString *day = @"";
            if (self.mainDetail == 1) {
                day = @"Monday";
            }else if (self.mainDetail == 2){
                day = @"Tuesday";
                
            }else if (self.mainDetail == 3){
                day = @"Wednesday";
                
            }else if (self.mainDetail == 4){
                day = @"Thursday";
                
            }else if (self.mainDetail == 5){
                day = @"Friday";
                
            }else if (self.mainDetail == 6){
                day = @"Saturday";
                
            }else if (self.mainDetail == 7){
                day = @"Sunday";
                
            }
            
            NSString *preDay = @"";
            if (self.secondaryDetail == 1) {
                preDay = @"1st";
            }else if (self.secondaryDetail == 2) {
                preDay = @"2nd";
                
            }else if (self.secondaryDetail == 3) {
                preDay = @"3rd";
                
            }else if (self.secondaryDetail == 4) {
                preDay = @"4th";
                
            }
            
            self.scheduleLabel.text = [NSString stringWithFormat:@"%@ %@ of every month", preDay, day];
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationFinal.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
    
}
- (void)viewDidLoad
{
    
    @try {
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        [self.submitButton setTitleColor:dutchGreenColor forState:UIControlStateNormal];
        self.submitButton.layer.cornerRadius = 10.0;
        self.submitButton.layer.borderWidth = 2.0;
        self.submitButton.layer.borderColor = [dutchGreenColor CGColor];
        
        
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        [toolbar setBarStyle:UIBarStyleBlackTranslucent];
        [toolbar sizeToFit];
        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard)];
        doneButton.tintColor = [UIColor whiteColor];
        
        NSArray *itemsArray = [NSArray arrayWithObjects:flexButton, doneButton, nil];
        [toolbar setItems:itemsArray];
        [self.paymentAmountTextField setInputAccessoryView:toolbar];
        
        
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationFinal.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  

    
}

-(void)resignKeyboard{
    
    
    @try {
        [self.paymentAmountTextField resignFirstResponder];
        
        double donationAmount = [self.paymentAmountTextField.text doubleValue];
        
        self.paymentAmountTextField.text = [NSString stringWithFormat:@"%.2f", donationAmount];
        
        self.processingLabel.hidden = YES;
        self.chargeFee = 0.0;
        if (donationAmount > 0.0) {
            if (self.myMerchant.chargeFee) {
                if (donationAmount < self.myMerchant.convenienceFeeCap) {
                    //we pay the convenience fee
                    self.chargeFee = self.myMerchant.convenienceFee;
                    
                    self.processingLabel.hidden = NO;
                    self.processingLabel.text = [NSString stringWithFormat:@"*a %.2f processing fee will be charged on all donations under $%.0f", self.myMerchant.convenienceFee, self.myMerchant.convenienceFeeCap];
                }
            }
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationFinal.resignKeyboard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
    
    
}


- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)submitAction {
    
    
    @try {
        double donationAmount = [self.paymentAmountTextField.text doubleValue];
        if (donationAmount > 0.0) {
            
            
            
            
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            
            //Type
            NSString *type = @"";
            if ([self.scheduleString isEqualToString:@"weekly"]) {
                type = @"WEEKLY";
            }else if ([self.scheduleString isEqualToString:@"monthly"]){
                type = @"MONTHLY";
                
            }else{
                type = @"XOFMONTH";
                
                //xOfMonth
                [tempDictionary setValue:[NSNumber numberWithInt:self.secondaryDetail] forKey:@"xOfMonth"];
                
                
            }
            [tempDictionary setValue:type forKey:@"Type"];
            
            //Value
            [tempDictionary setValue:[NSNumber numberWithInt:self.mainDetail] forKey:@"Value"];
            
            
            
            //CustomerId
            [tempDictionary setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"] forKey:@"CustomerId"];
            
            //MerchantId
            [tempDictionary setValue:[NSNumber numberWithInt:self.myMerchant.merchantId] forKey:@"MerchantId"];
            
            //InvoiceId
            [tempDictionary setValue:[NSNumber numberWithInt:self.myMerchant.invoiceId] forKey:@"InvoiceId"];
            
            //ItemId (optional - not using yet)
            
            
            
            if ([[self.selectedCard valueForKey:@"CCToken"] length] > 0) {
                //BT card
                
                
                //CCToken
                [tempDictionary setValue:[self.selectedCard valueForKey:@"CCToken"] forKey:@"CCToken"];
                
            }else{
                //new card
                
                NSMutableDictionary *cardDictionary = [NSMutableDictionary dictionary];
                
                //Number
                [cardDictionary setValue:[self.selectedCard valueForKey:@"Number"] forKey:@"Number"];
                
                
                //ExpirationDate
                [cardDictionary setValue:[self.selectedCard valueForKey:@"ExpirationDate"] forKey:@"ExpirationDate"];
                
                
                
                //CVV
                [cardDictionary setValue:[self.selectedCard valueForKey:@"CVV"] forKey:@"CVV"];
                
                
                [tempDictionary setValue:cardDictionary forKey:@"CreditCard"];
                
                
            }
            
            
            //Amount
            [tempDictionary setValue:[NSNumber numberWithDouble:donationAmount] forKey:@"Amount"];
            
            if (self.chargeFee > 0) {
                //Gratuity
                [tempDictionary setValue:[NSNumber numberWithDouble:self.chargeFee] forKey:@"Gratuity"];
            }
            
            //AuthorizationToken
            [tempDictionary setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"customerToken"] forKey:@"AuthorizationToken"];
            
            
            
            NSDictionary *loginDict = [[NSDictionary alloc] init];
            loginDict = tempDictionary;
            ArcClient *client = [[ArcClient alloc] init];
            
            
            self.loadingViewController.displayText.text = @"Processing...";
            self.loadingViewController.view.hidden = NO;
            
            
            NSLog(@"Dictionary: %@", loginDict);
            
            [client createRecurringPayment:loginDict];
            
            
            
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Amount" message:@"Your donation amount must be great than 0." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationFinal.submitAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
 
 
}


-(void)doneCreateRecurringPayment:(NSNotification *)notification{
    
    @try {
        self.loadingViewController.view.hidden = YES;
        
        
        
        NSDictionary *userInfo = [notification valueForKey:@"userInfo"];
        
        if ([[userInfo valueForKey:@"status"] isEqualToString:@"success"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your recurring donation was processed successfully!  You will receive an email receipt on the day of each recurring donation." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            
            for (int i = 0; i < [[self.navigationController viewControllers] count]; i++) {
                
                id viewController = [[self.navigationController viewControllers] objectAtIndex:i];
                
                if ([viewController class] == [DefaultChurchView class]) {
                    [self.navigationController popToViewController:(UIViewController *)viewController animated:YES];
                }
            }
            
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error processing your recurring donation, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationFinal.doneRecurringPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
}


@end
