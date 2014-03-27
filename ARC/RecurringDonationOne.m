//
//  RecurringDonationOne.m
//  Dono
//
//  Created by Nick Wroblewski on 3/26/14.
//
//

#import "RecurringDonationOne.h"
#import "ArcAppDelegate.h"
#import "rSkybox.h"
#import "RecurringDonationNewCard.h"
#import "RecurringDonationFinal.h"
#import "ArcUtility.h"

@interface RecurringDonationOne ()

@end

@implementation RecurringDonationOne

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.titleLabel.text = self.myMerchant.name;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)keyboardWillShow{
    
    if (!self.isChangingKeyboard) {
        [UIView animateWithDuration:0.3 animations:^(void){
            
            CGRect frame = self.view.frame;
            frame.origin.y -= 130;
            self.view.frame = frame;
            
        }];
    }else{
        self.isChangingKeyboard = NO;
    }
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

}
-(void)keyboardWillHide{
    
    if (!self.isChangingKeyboard) {
        [UIView animateWithDuration:0.3 animations:^(void){
            
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            self.view.frame = frame;
            
        }];
    }
 
    
   
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    self.mainDetailText.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.daysOfWeek = @[@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday", @"sunday"];
    self.matchingDays = [NSMutableArray array];
    [self.continueButton setTitleColor:dutchOrangeColor forState:UIControlStateNormal];
    self.continueButton.layer.cornerRadius = 10.0;
    self.continueButton.layer.borderWidth = 2.0;
    self.continueButton.layer.borderColor = [dutchOrangeColor CGColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)endText {
    [self.mainDetailText becomeFirstResponder];

}

- (IBAction)weeklyAction {
    
    self.weeklyCheckImage.hidden = NO;
    self.monthlyCheckImage.hidden = YES;
    self.xofMonthCheckImage.hidden = YES;

    self.secondarySegmentControl.hidden = YES;
    self.secondaryExplanation.hidden = YES;
    self.mainDetailText.placeholder = @"Which day of the week?";
    
    self.mainDetailText.text = @"";
    
    self.mainDetailText.keyboardType = UIKeyboardTypeAlphabet;
    self.myTableView.hidden = YES;

    self.monthlyHelpText.hidden = YES;
    
    if ([self.mainDetailText isFirstResponder]) {
        self.isChangingKeyboard = YES;
        [self.mainDetailText resignFirstResponder];
        [self.mainDetailText becomeFirstResponder];
    }
}

- (IBAction)monthlyAction {
    
    self.weeklyCheckImage.hidden = YES;
    self.monthlyCheckImage.hidden = NO;
    self.xofMonthCheckImage.hidden = YES;
    
    self.secondarySegmentControl.hidden = YES;
    self.secondaryExplanation.hidden = YES;
    self.mainDetailText.placeholder = @"Which day of the month?";
    self.mainDetailText.text = @"";
    self.mainDetailText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    if ([self.mainDetailText isFirstResponder]) {
        self.isChangingKeyboard = YES;
        [self.mainDetailText resignFirstResponder];
        [self.mainDetailText becomeFirstResponder];
    }
   
    
    
    self.monthlyHelpText.hidden = NO;
    self.myTableView.hidden = YES;

}

- (IBAction)xdayAction {
    
    self.weeklyCheckImage.hidden = YES;
    self.monthlyCheckImage.hidden = YES;
    self.xofMonthCheckImage.hidden = NO;
    
    self.secondarySegmentControl.hidden = NO;
    self.secondaryExplanation.hidden = NO;
    
    self.mainDetailText.placeholder = @"Which day of the week?";
    self.mainDetailText.text = @"";
    self.mainDetailText.keyboardType = UIKeyboardTypeAlphabet;

    self.monthlyHelpText.hidden = YES;
    self.myTableView.hidden = YES;

    if ([self.mainDetailText isFirstResponder]) {
        self.isChangingKeyboard = YES;
        [self.mainDetailText resignFirstResponder];
        [self.mainDetailText becomeFirstResponder];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    BOOL showedAlert = NO;
    
    if ([self.mainDetailText.text length] > 0) {
        
        if (self.weeklyCheckImage.hidden == NO) {
            
            if (![self.daysOfWeek containsObject:[self.mainDetailText.text lowercaseString]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Day" message:@"You must pick a day of the week, Sunday through Saturday." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                showedAlert = YES;
            }
            
        }else if (self.monthlyCheckImage.hidden == NO){
            
            self.mainDetailText.text = [self.mainDetailText.text lowercaseString];
            
            self.mainDetailText.text = [self.mainDetailText.text stringByReplacingOccurrencesOfString:@"st" withString:@""];
            self.mainDetailText.text = [self.mainDetailText.text stringByReplacingOccurrencesOfString:@"nd" withString:@""];
            self.mainDetailText.text = [self.mainDetailText.text stringByReplacingOccurrencesOfString:@"rd" withString:@""];
            self.mainDetailText.text = [self.mainDetailText.text stringByReplacingOccurrencesOfString:@"th" withString:@""];
            
            
            int number = [self.mainDetailText.text intValue];

            if (number < 1 || number > 28) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Day" message:@"Your day of the month must be a number, 1-28." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                showedAlert = YES;
                
            }else{
                self.mainDetailText.text = [NSString stringWithFormat:@"%d", number];
            }
            
        }else{
            //x of month
            
            if (![self.daysOfWeek containsObject:[self.mainDetailText.text lowercaseString]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Day" message:@"You must pick a day of the week, Sunday through Saturday." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                showedAlert = YES;
            }
            
            
            
        }
    }

    
    if (!showedAlert) {
        [self.mainDetailText resignFirstResponder];
        self.myTableView.hidden = YES;

    }
    
    
    return NO;
    

}




- (IBAction)continueAction {
    
    if ([self.mainDetailText.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Details" message:@"Please fill out Step #2, the details of your recurring donation, before continuing." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }else{

        if ([self.creditCards count] > 0) {
            
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            
            for (int i = 0; i < [self.creditCards count]; i++) {
                NSDictionary *tmpCard = [self.creditCards objectAtIndex:i];
                
                NSString *type = [ArcUtility getCardTypeForNumber:[tmpCard valueForKey:@"Number"]];
                
                [self.actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@  %@", type, [tmpCard valueForKey:@"Number"]]];
         
            }
            
            [self.actionSheet addButtonWithTitle:@"+ New Card"];
            [self.actionSheet addButtonWithTitle:@"Cancel"];
            self.actionSheet.cancelButtonIndex = [self.creditCards count];
            [self.actionSheet showInView:self.view];
            
            
        }else{
            [self performSegueWithIdentifier:@"newcard" sender:self];
        }
        
        
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    @try {
        
        
        if (buttonIndex == [self.creditCards count] + 1) {
            //cancel
        }else if (buttonIndex == [self.creditCards count]){
            //new card
            [self performSegueWithIdentifier:@"newcard" sender:self];

        }else{
            
            self.selectedCard = [self.creditCards objectAtIndex:buttonIndex];
            
            [self performSegueWithIdentifier:@"finishrecurring" sender:self];

        }
        
            
    
        
    }@catch (NSException *e) {
        // NSLog(@"E: %@", e);
        [rSkybox sendClientLog:@"RecurringDonationOne.actionSheet" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    @try {
        
        
        
        
        
        if ([[segue identifier] isEqualToString:@"newcard"]) {
            
            RecurringDonationNewCard *recurring = [segue destinationViewController];
            recurring.myMerchant = self.myMerchant;
            
            recurring.myMerchant = self.myMerchant;
            
            
            self.secondaryDetail = -1;
            
            if (self.weeklyCheckImage.hidden == NO) {
                
                self.scheduleString = @"weekly";
                
                self.mainDetail = [self.daysOfWeek indexOfObject:[self.mainDetailText.text lowercaseString]] + 1;
                
            }else if (self.monthlyCheckImage.hidden == NO){
                
                self.scheduleString = @"monthly";
                self.mainDetail = [self.mainDetailText.text intValue];
                
                
            }else{
                //x of month
                self.scheduleString = @"x";
                
                self.secondaryDetail = self.secondarySegmentControl.selectedSegmentIndex + 1;
                
                self.mainDetail = [self.daysOfWeek indexOfObject:[self.mainDetailText.text lowercaseString]] + 1;
                
            }
            
            recurring.scheduleString = self.scheduleString;
            recurring.mainDetail = self.mainDetail;
            recurring.secondaryDetail = self.secondaryDetail;
            
            
            
            
        }else if ([[segue identifier] isEqualToString:@"finishrecurring"]) {
            
            RecurringDonationFinal *recurring = [segue destinationViewController];
            recurring.myMerchant = self.myMerchant;
            recurring.selectedCard = [NSDictionary dictionaryWithDictionary:self.selectedCard];
            
            
            self.secondaryDetail = -1;
            
            if (self.weeklyCheckImage.hidden == NO) {
                
                self.scheduleString = @"weekly";
                
                self.mainDetail = [self.daysOfWeek indexOfObject:[self.mainDetailText.text lowercaseString]] + 1;
            
            }else if (self.monthlyCheckImage.hidden == NO){
                
                self.scheduleString = @"monthly";
                self.mainDetail = [self.mainDetailText.text intValue];

                
            }else{
                //x of month
                self.scheduleString = @"x";

                self.secondaryDetail = self.secondarySegmentControl.selectedSegmentIndex + 1;
                
                self.mainDetail = [self.daysOfWeek indexOfObject:[self.mainDetailText.text lowercaseString]] + 1;

            }
            
            recurring.scheduleString = self.scheduleString;
            recurring.mainDetail = self.mainDetail;
            recurring.secondaryDetail = self.secondaryDetail;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RecurringDonationOne.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}






- (IBAction)textFieldEditingChanged:(id)sender {
    
    @try {
        self.matchingDays = [NSMutableArray array];
        if (self.weeklyCheckImage.hidden == NO || self.xofMonthCheckImage.hidden == NO) {
            
            if ([self.mainDetailText.text length] > 0) {
                
                for (int i = 0; i < [self.daysOfWeek count]; i++) {
                    
                    NSString *dayOfWeek = [self.daysOfWeek objectAtIndex:i];
                    
                    if ([[dayOfWeek substringToIndex:[self.mainDetailText.text length]] isEqualToString:self.mainDetailText.text]) {
                        [self.matchingDays addObject:dayOfWeek];
                    }
                }
                
                if ([self.matchingDays count] > 0) {
                    self.myTableView.hidden = NO;
                    [self.myTableView reloadData];
                }
                
            }else{
                self.myTableView.hidden = YES;
                
            }
            
            
        }else{
            self.myTableView.hidden = YES;
        }
        
    }
    @catch (NSException *exception) {
        self.myTableView.hidden = YES;
        NSLog(@"E: %@",exception);
    }
   
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        if ([self.matchingDays count] == 0) {
            self.myTableView.hidden = YES;
        }
        return [self.matchingDays count];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RecurringDonationOne.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dayCell"];
        
        SteelfishLabel *dayLabel = (SteelfishLabel *)[cell.contentView viewWithTag:1];
        
        dayLabel.text = [[self.matchingDays objectAtIndex:indexPath.row] capitalizedString];
        
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RecurringDonationOne.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    self.mainDetailText.text = [[self.matchingDays objectAtIndex:indexPath.row] capitalizedString];
    
    [self.mainDetailText resignFirstResponder];
    
    self.matchingDays = [NSMutableArray array];
    self.myTableView.hidden = YES;
    
  
    
    
    
}




@end
