//
//  ChurchAmountMultipleTypes.m
//  HolyDutch
//
//  Created by Nick Wroblewski on 10/16/13.
//
//

#import "ChurchAmountMultipleTypes.h"
#import "ArcAppDelegate.h"
#import "rSkybox.h"
#import "ArcUtility.h"
#import "AddCreditCardGuest.h"
#import "ConfirmPaymentViewController.h"
#import "MultiDonationView.h"



@interface ChurchAmountMultipleTypes ()

@end

@implementation ChurchAmountMultipleTypes


- (IBAction)moveRight {
    
    if (self.currentIndex < [self.selectedDonations count] - 1) {
        self.currentIndex++;
        [self.middleView setContentOffset:CGPointMake(self.currentIndex * 320, 0) animated:YES];
    }
}

- (IBAction)moveLeft {
    
    if (self.currentIndex > 0) {
        self.currentIndex--;
        [self.middleView setContentOffset:CGPointMake(self.currentIndex * 320, 0) animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    
    self.typeLabel.text = self.myMerchant.name;

    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.multiDonationViews = [NSMutableArray array];
    
    for (int i = 0; i < [self.selectedDonations count]; i++) {
        
        NSDictionary *selected = [self.selectedDonations objectAtIndex:i];
        
        NSLog(@"Selected: %@", selected);
        
        MultiDonationView *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"multiDonationView"];
        tmp.view.frame = CGRectMake(i*320, 0, 320, 133);
        tmp.titleLabel.text = [selected valueForKey:@"Description"];
        tmp.parentVc = self;
        [self.multiDonationViews addObject:tmp];
    }
    
    
    for (int i = 0; i < [self.multiDonationViews count]; i++) {
        
        MultiDonationView *tmp = [self.multiDonationViews objectAtIndex:i];
        [self.middleView addSubview:tmp.view];
        
        self.middleView.contentSize = CGSizeMake(320 * i + 160 + 250, 133);
    }
    
    self.middleView.scrollEnabled = NO;
    
    self.payButton.textColor = [UIColor whiteColor];
    self.payButton.tintColor = dutchGreenColor;
    self.payButton.text = @"Pay";
    
    self.amountText.text = @"My Total: $0.00";
    self.amountText.hidden = YES;
}


- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)payAction {
    
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
    
    if ([self.creditCards count] > 0) {
        //Have at least 1 card, present UIActionSheet
        
        if ([self.creditCards count] == 1) {
            
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
        [rSkybox sendClientLog:@"ChurchAmountMultipleTypes.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}






- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        double amount = [[self.amountText.text stringByReplacingOccurrencesOfString:@"My Total: $" withString:@""] doubleValue];
        
        
        NSMutableArray *itemArray = [NSMutableArray array];
        
        
        for (int i = 0; i < [self.multiDonationViews count]; i++) {
            
            MultiDonationView *tmp = [self.multiDonationViews objectAtIndex:i];
            NSDictionary *donation = [self.selectedDonations objectAtIndex:i];
            
            NSString *itemId = [donation valueForKey:@"Id"];
            
            double percentDouble = [tmp.amountText.text doubleValue]/amount;
            
            NSString *percent = [NSString stringWithFormat:@"%.2f", percentDouble];
            
            
            NSDictionary *item = @{@"Amount":@"1", @"Percent":percent, @"Id":itemId};
            
            [itemArray addObject:item];

            
        }
        

        
        
        
        if ([[segue identifier] isEqualToString:@"addCard"]) {
            
            AddCreditCardGuest *addCard = [segue destinationViewController];
            addCard.myMerchant = self.myMerchant;
            addCard.myItemsArray = [NSMutableArray arrayWithArray:itemArray];
            addCard.donationAmount = amount;
            
            
        }else if ([[segue identifier] isEqualToString:@"payCard"]) {
            
            ConfirmPaymentViewController *confirm = [segue destinationViewController];
            confirm.donationAmount = amount;
            confirm.selectedCard = self.selectedCard;
            confirm.myMerchant = self.myMerchant;
            confirm.myItemsArray = [NSMutableArray arrayWithArray:itemArray];


        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ChurchAmountMultipleTypes.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)calculateTotal{
    
    double total = 0.0;
    for (int i = 0; i < [self.multiDonationViews count]; i++) {
     
        MultiDonationView *tmp = [self.multiDonationViews objectAtIndex:i];
        
        total += [tmp.amountText.text doubleValue];
    }
    
    self.amountText.text = [NSString stringWithFormat:@"My Total: $%.2f", total];
    
    NSLog(@"Amoutn Text: %@", self.amountText.text);
    
    if (self.currentIndex < [self.selectedDonations count] - 1) {
        self.currentIndex++;
        [self.middleView setContentOffset:CGPointMake(self.currentIndex * 320, 0) animated:YES];
    }
}

@end
