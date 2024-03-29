//
//  CreatePinView.m
//  ARC
//
//  Created by Nick Wroblewski on 9/24/12.
//
//

#import "CreatePinView.h"
#import <QuartzCore/QuartzCore.h>
#import "SteelfishTitleLabel.h"
#import "ArcAppDelegate.h"
#import "RegisterViewNew.h"
#import "SettingsView.h"
#import "EditCreditCard.h"
#import "NoPaymentSourcesViewController.h"
#import "RegisterViewNew.h"
#import "ProfileViewController.h"
#import "ViewCreditCards.h"
#import "LeftViewController.h"

@interface CreatePinView ()

@end

@implementation CreatePinView

-(void)viewDidAppear:(BOOL)animated{
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([mainDelegate.logout isEqualToString:@"true"]) {
            [self.navigationController dismissModalViewControllerAnimated:NO];
        }
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)duplicateCard:(NSNotification *)notification{
    self.isDuplicate = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    
    if (self.isLoggedInUser) {
        self.skipButton.hidden = YES;
        if (self.view.frame.size.height < 480) {
            self.skipButton.text = @"Skip";
        }
    }else{
        self.skipButton.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duplicateCard:) name:@"duplicateCardNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
    [self.hiddenText becomeFirstResponder];

    if (self.isEditPin) {
        SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Edit PIN"];
        self.navigationItem.titleView = navLabel;
        [self.navigationController.navigationItem setHidesBackButton:NO];
        [self.navigationItem setHidesBackButton:NO];
    }
 
    
}
-(void)viewDidLoad{
    
    self.skipButton.text = @"SKIP - Your card info will not be saved.";
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    
    self.initialPin = @"";
    self.confirmPin = @"";

    
   // self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
   // self.topLineView.layer.shadowRadius = 1;
   // self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
    SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Credit Card Protection"];
    self.navigationItem.titleView = navLabel;
    [self.navigationController.navigationItem setHidesBackButton:YES];
    [self.navigationItem setHidesBackButton:YES];
    
    self.isFirstPin = YES;
    
    self.checkNumOne.delegate = self;
    self.checkNumTwo.delegate = self;
    self.checkNumThree.delegate = self;
    self.checkNumFour.delegate = self;
    
    self.hiddenText = [[UITextField alloc] init];
    self.hiddenText.keyboardType = UIKeyboardTypeNumberPad;
    self.hiddenText.delegate = self;
    self.hiddenText.text = @"";
    [self.view addSubview:self.hiddenText];
    
    self.checkNumOne.text = @"";
    self.checkNumTwo.text = @"";
    self.checkNumThree.text = @"";
    self.checkNumFour.text = @"";
    
    self.checkNumOne.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumTwo.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumThree.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumFour.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    //UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    double x = 1.0;
    UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];

    
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    

    
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
            [self setValues:[self.hiddenText.text stringByReplacingCharactersInRange:range withString:string]];
            
            if (newLength == 4) {
                if (self.isFirstPin) {
                    self.initialPin = [self.hiddenText.text stringByReplacingCharactersInRange:range withString:string];
                    
                    self.checkNumFour.text = @"";
                    self.checkNumThree.text = @"";
                    self.checkNumTwo.text = @"";
                    self.checkNumOne.text = @"";
                    self.hiddenText.text = @"";
                    
                    self.isFirstPin = NO;
                    
                    self.instructionsLabel.text = @"Please re-enter your pin";
                }else{

                    self.confirmPin = [self.hiddenText.text stringByReplacingCharactersInRange:range withString:string];

                    if ([self.initialPin isEqualToString:self.confirmPin]) {
                        [self runSuccess];
                    }else{
                        self.instructionsLabel.text = @"Please create a 4 digit pin";
                        self.descriptionText.textColor = [UIColor redColor];
                        self.descriptionText.text = @"Your confirm did not match.  Please try again.";
                        
                        self.checkNumFour.text = @"";
                        self.checkNumThree.text = @"";
                        self.checkNumTwo.text = @"";
                        self.checkNumOne.text = @"";
                        self.hiddenText.text = @"";
                        
                        self.isFirstPin = YES;
                    }
                }
                return FALSE;
            }
            return TRUE;
        }
    }
    @catch (NSException *e) {
        //[rSkybox sendClientLog:@"CreditCardpayment.testField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)runSuccess{
    
    if (self.fromCreateGuest || self.isLoggedInUser) {
 
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate insertCreditCardWithNumber:self.cardNumber andSecurityCode:self.securityCode andExpiration:self.expiration andPin:self.confirmPin andCreditDebit:self.creditDebitString];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your payment information was succesfully encrypted and saved." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
        [tmp homeSelected];
        

    
    }else{
        if (self.isEditPin) {
            
            NSArray *views = [self.navigationController viewControllers];
            int cell = [views count] - 2;
            EditCreditCard *tmp = [views objectAtIndex:cell];
            tmp.pinDidChange = YES;
            tmp.newPin = self.confirmPin;
            
            NSString *welcomeMsg = @"Your PIN for this card has been edited, but your new PIN will only be activated if you choose 'Save Changes' on this page.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PIN Changed." message:welcomeMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            [self.navigationController popToViewController:tmp animated:NO];
            
            
        }else{
            
            if (self.fromRegister) {
                
                
                if (self.isInsideApp) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully registered!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    
                    ProfileViewController *profile = [[self.navigationController viewControllers] objectAtIndex:1];
                    
                    [self.navigationController popToViewController:profile animated:YES];
                }else{
                    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [mainDelegate insertCreditCardWithNumber:self.cardNumber andSecurityCode:self.securityCode andExpiration:self.expiration andPin:self.confirmPin andCreditDebit:self.creditDebitString];
                    
                    NSArray *views = [self.navigationController viewControllers];
                    int cell = [views count] - 2;
                    RegisterViewNew *tmp = [views objectAtIndex:cell];
                    tmp.fromCreditCard = YES;
                    
                    // welcome message
                    //NSString *welcomeMsg = @"Thank you for choosing Arc. You are now ready to start using mobile payments.";
                    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Complete" message:welcomeMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    // [alert show];
                    
                    [self.navigationController popToViewController:tmp animated:NO];
                }
                
                
            }else{
                
                ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                [mainDelegate insertCreditCardWithNumber:self.cardNumber andSecurityCode:self.securityCode andExpiration:self.expiration andPin:self.confirmPin andCreditDebit:self.creditDebitString];
                
                self.loadingViewController.displayText.text = @"Adding Card...";
                [self.loadingViewController startSpin];
                [self performSelector:@selector(popNow) withObject:nil afterDelay:1.5];
                
            }
            
        }

        
    }

}


-(void)goHome{
    @try {
        
        if (self.isInsideApp) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully registered!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            ProfileViewController *profile = [[self.navigationController viewControllers] objectAtIndex:1];
            
            [self.navigationController popToViewController:profile animated:YES];
        }else{
            [self performSegueWithIdentifier:@"pinHome" sender:self];

        }
        
        
    }
    @catch (NSException *e) {
        //[rSkybox sendClientLog:@"RegisterView.goHome" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


-(void)popNow{
    @try {
        
        
        if (self.isInsideApp) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully registered!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            ProfileViewController *profile = [[self.navigationController viewControllers] objectAtIndex:1];
            
            [self.navigationController popToViewController:profile animated:YES];
        }else{
            if ([ViewCreditCards class] == [[[self.navigationController viewControllers] objectAtIndex:1] class] ) {
                ViewCreditCards *tmp = [[self.navigationController viewControllers] objectAtIndex:1];
                tmp.creditCardAdded = YES;
                tmp.duplicateCard = self.isDuplicate;
                [self.navigationController popToViewController:tmp animated:YES];
            }else{
                
                NoPaymentSourcesViewController *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
                tmp.creditCardAdded = YES;
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }
        }
        
        
    }
    @catch (NSException *e) {
       // [rSkybox sendClientLog:@"AddCreditCard.popNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)viewDidUnload {
    [self setTopLineView:nil];
    [self setBackView:nil];
    [self setSkipButton:nil];
    [super viewDidUnload];
}
- (IBAction)skipAction {
    

    
    
}
@end
