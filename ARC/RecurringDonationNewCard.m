//
//  RecurringDonationNewCard.m
//  Dono
//
//  Created by Nick Wroblewski on 3/26/14.
//
//

#import "RecurringDonationNewCard.h"
#import "ArcAppDelegate.h"
#import "RecurringDonationFinal.h"
#import "rSkybox.h"
#import "NSString+CharArray.h"

@interface RecurringDonationNewCard ()

@end

@implementation RecurringDonationNewCard

-(void)viewWillAppear:(BOOL)animated{

    self.titleLabel.text = self.myMerchant.name;
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.addCardButton setTitleColor:dutchOrangeColor forState:UIControlStateNormal];
    self.addCardButton.layer.cornerRadius = 10.0;
    self.addCardButton.layer.borderWidth = 2.0;
    self.addCardButton.layer.borderColor = [dutchOrangeColor CGColor];
    
    [self.myTableView reloadData];
}





- (IBAction)addCardAction {
    
    if ([[self creditCardStatus] isEqualToString:@"valid"]) {
        
        
        if ([self luhnCheck:self.creditCardNumberText.text]) {
            
            [self performSegueWithIdentifier:@"finishrecurring" sender:self];
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Card" message:@"Please enter a valid card number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
        
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"Please fill out all credit card information first" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    
}

-(NSString *)creditCardStatus{
    @try {
        
        if ([self.creditCardSecurityCodeText.text isEqualToString:@""] && [self.creditCardNumberText.text isEqualToString:@""] && [self.expirationText.text isEqualToString:@""]){
            
            return @"empty";
        }else{
            //At least one is entered, must all be entered
            if (![self.creditCardSecurityCodeText.text isEqualToString:@""] && ![self.creditCardNumberText.text isEqualToString:@""] && ([self.expirationText.text length] == 5)){
                return @"valid";
            }else{
                return @"invalid";
            }
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RecurringDonationNewCard.creditCardStatus" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    @try {
        
        
        
        
        
        if ([[segue identifier] isEqualToString:@"finishrecurring"]) {
            
            RecurringDonationFinal *recurring = [segue destinationViewController];
            recurring.myMerchant = self.myMerchant;
        
            recurring.scheduleString = self.scheduleString;
            recurring.mainDetail = self.mainDetail;
            recurring.secondaryDetail = self.secondaryDetail;
            
            self.selectedCard = @{@"Number": [self.creditCardNumberText.text stringByReplacingOccurrencesOfString:@" " withString:@""], @"CVV" : self.creditCardSecurityCodeText.text, @"ExpirationDate": self.expirationText.text};
            
            recurring.selectedCard = self.selectedCard;
            
            // ADD THE CARD INFO recurring.selectedCard =
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RecurringDonationNewCard.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        
        
        UITableViewCell *cell;
        
        
        if (indexPath.row == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"numberCell"];
            
            SteelfishTextFieldCreditCardiOS6 *numberText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:1];
            self.creditCardNumberText = numberText;
            self.creditCardNumberText.placeholder = @"1234 5678 9102 3456";
            self.creditCardNumberText.delegate = self;
            [self.creditCardNumberText setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            [self.creditCardNumberText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
            
        }else if (indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:@"expCell"];
            
            SteelfishTextFieldCreditCardiOS6 *expText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:1];
            self.expirationText = expText;
            self.expirationText.placeholder = @"MM/YY";
            
            SteelfishTextFieldCreditCardiOS6 *pinText = (SteelfishTextFieldCreditCardiOS6 *)[cell.contentView viewWithTag:2];
            self.creditCardSecurityCodeText = pinText;
            self.creditCardSecurityCodeText.placeholder = @"CVV";
            
            self.creditCardSecurityCodeText.delegate = self;
            self.expirationText.delegate = self;
            
            [self.creditCardSecurityCodeText setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.expirationText setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            [self.creditCardSecurityCodeText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
            [self.expirationText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
            
            
            
        }
        
        
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RecurringDonationNewCard.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}



- (BOOL) luhnCheck:(NSString *)stringToTest {
    
    
    @try {
        stringToTest = [stringToTest stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSMutableArray *stringAsChars = [stringToTest toCharArray];
        
        BOOL isOdd = YES;
        int oddSum = 0;
        int evenSum = 0;
        
        for (int i = [stringToTest length] - 1; i >= 0; i--) {
            
            int digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];
            
            if (isOdd)
                oddSum += digit;
            else
                evenSum += digit/5 + (2*digit) % 10;
            
            isOdd = !isOdd;
        }
        
        return ((oddSum + evenSum) % 10 == 0);
    }
    @catch (NSException *exception) {
        
        [rSkybox sendClientLog:@"RecurringDonationNewCard.luhnCheck" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

        return NO;
    }
  
  
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    @try {
        self.isDelete = NO;
        
        
        if (textField == self.creditCardNumberText){
            
            if ([string isEqualToString:@""]) {
                self.isDelete = YES;
                return TRUE;
            }
            
            if ([self.creditCardNumberText.text length] >= 20) {
                
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                return FALSE;
            }
            
        }else if (textField == self.expirationText){
            
            if ([string isEqualToString:@""]) {
                self.isDelete = YES;
                
                
                return TRUE;
            }
            if ([self.expirationText.text length] >= 5) {
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                return FALSE;
            }
            
        }else if (textField == self.creditCardSecurityCodeText){
            
            if ([string isEqualToString:@""]) {
                
                
                return TRUE;
            }
            
            if ([self.creditCardSecurityCodeText.text length] >= 4) {
                if ([string isEqualToString:@""]) {
                    return YES;
                }
                return FALSE;
            }
            
        }
        return TRUE;
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationNewCard.shouldChangeCharacters" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}


-(void)valueChanged:(id)sender{
    
    @try {
       
        if (self.shouldIgnoreValueChanged) {
            self.shouldIgnoreValueChanged = NO;
        }else{
            if (sender == self.creditCardNumberText){
                [self formatCreditCard:NO];
            }
        }
        
        if (self.shouldIgnoreValueChangedExpiration) {
            self.shouldIgnoreValueChangedExpiration = NO;
        }else{
            if (sender == self.expirationText) {
                
                [self formatExpiration];
            }
        }
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationNewCard.valueChanged" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
    
}

-(void)formatCreditCard:(BOOL)final{
    
    @try {
        if (!self.isDelete) {
            
            
            NSString *cardNumber = self.creditCardNumberText.text;
            BOOL isAmex = NO;
            
            if ([cardNumber length] > 1) {
                if ([[cardNumber substringToIndex:2] isEqualToString:@"34"] || [[cardNumber substringToIndex:2] isEqualToString:@"37"]) {
                    isAmex = YES;
                }
            }
            
            if (isAmex) {
                
                
                if (final) {
                    
                    cardNumber = [NSString stringWithFormat:@"%@ %@ %@", [cardNumber substringToIndex:4], [cardNumber substringWithRange:NSMakeRange(4, 6)], [cardNumber substringFromIndex:10]];
                    
                }else{
                    if ([cardNumber length] == 4) {
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 11){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 17){
                        [self.expirationText becomeFirstResponder];
                    }else if ([cardNumber length] == 5) {
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:4], [cardNumber substringFromIndex:4]];
                    }else if ([cardNumber length] == 12){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:11], [cardNumber substringFromIndex:11]];
                        
                    }
                }
                
                
                
            }else{
                
                if (final) {
                    
                    cardNumber = [NSString stringWithFormat:@"%@ %@ %@ %@", [cardNumber substringToIndex:4], [cardNumber substringWithRange:NSMakeRange(4, 4)], [cardNumber substringWithRange:NSMakeRange(8, 4)], [cardNumber substringFromIndex:12]];
                }else{
                    if ([cardNumber length] == 4) {
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 9){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 14){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 19){
                        [self.expirationText becomeFirstResponder];
                    }else if ([cardNumber length] == 5) {
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:4], [cardNumber substringFromIndex:4]];
                    }else if ([cardNumber length] == 10){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:9], [cardNumber substringFromIndex:9]];
                        
                    }else if ([cardNumber length] == 15){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:14], [cardNumber substringFromIndex:14]];
                    }
                }
                
            }
            
            
            
            //self.shouldIgnoreValueChanged = YES;
            
            self.creditCardNumberText.text = cardNumber;
        }
    }
    
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationNewCard.formatCreditCard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}

-(void)formatExpiration{
    
    @try {
        NSString *expiration = self.expirationText.text;
        
        if (self.isDelete) {
            
            if ([expiration length] == 2) {
                expiration = [expiration substringToIndex:1];
            }
            
        }else{
            if ([expiration length] == 5) {
                [self.creditCardSecurityCodeText becomeFirstResponder];
            }
            
            if ([expiration length] == 1) {
                if (![expiration isEqualToString:@"1"] && ![expiration isEqualToString:@"0"]) {
                    expiration = [NSString stringWithFormat:@"0%@/", expiration];
                }
            }else if ([expiration length] == 2){
                expiration = [expiration stringByAppendingString:@"/"];
            }
        }
        
       // self.shouldIgnoreValueChangedExpiration = YES;
        
        
        self.expirationText.text = expiration;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationNewCard.formatException" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}


-(void)backspaceHit{
    
    @try {
        if (([self.creditCardSecurityCodeText.text length] == 0) && [self.creditCardSecurityCodeText isFirstResponder]) {
            [self.expirationText becomeFirstResponder];
        }else if (([self.expirationText.text length] == 0) && [self.expirationText isFirstResponder]) {
            [self.creditCardNumberText becomeFirstResponder];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RecurringDonationNewCard.backSpaceHit" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}




@end
