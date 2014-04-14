//
//  ProfileNewViewController.m
//  Dono
//
//  Created by Nick Wroblewski on 1/26/14.
//
//

#import "ProfileNewViewController.h"
#import "ILTranslucentView.h"
#import "HomeNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "ChurchSelector.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "Merchant.h"
#import "DefaultChurchView.h"
#import "ILTranslucentView.h"
#import "rSkybox.h"
#import "MFSideMenu.h"
#import "ArcAppDelegate.h"
#import "ViewController.h"
#import "RegisterViewNew.h"
#import "ArcIdentifier.h"
#import "PaymentOptionsWebViewController.h"
#import "InitHelpPageViewController.h"

@interface ProfileNewViewController ()

@end

@implementation ProfileNewViewController






-(void)viewDidAppear:(BOOL)animated{
    if (self.loginSignupBackView.hidden == NO) {
        [self.emailText becomeFirstResponder];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    
    @try {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
     

        
        
        
        
        
      
        [self.myTableView reloadData];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateComplete:) name:@"updateGuestCustomerNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerComplete:) name:@"registerNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInCompleteGuest:) name:@"signInNotificationGuest" object:nil];
        
        
        
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
            self.isLoggedIn = YES;
            self.topLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"];
            
            self.logoutButton.hidden = NO;
            [self.logoutButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            self.logoutButton.layer.cornerRadius = 10.0;
            self.logoutButton.layer.borderWidth = 2.0;
            self.logoutButton.layer.borderColor = [[UIColor redColor] CGColor];
            self.whiteArrow.hidden = YES;
            self.loginSignupButton.hidden = YES;
            self.loginOnlyButton.hidden = YES;
            self.bottomLabel.text = @"";
            
            ArcClient *tmp = [[ArcClient alloc] init];
            if (tmp.admin) {
                self.serverButton.hidden = NO;
            }else{
                self.serverButton.hidden = YES;

            }
        }else{
            self.topLabel.text = @"Sign Up Here!";
            self.bottomLabel.text = @"Already a Member? Click to Log In.";
            self.logoutButton.hidden = YES;
            self.whiteArrow.hidden = NO;
            self.serverButton.hidden = YES;
            self.loginSignupButton.hidden = NO;
            self.loginOnlyButton.hidden = NO;
        }
        
        self.topLabel.textColor = [UIColor whiteColor];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
    
}

- (void)viewDidLoad
{
    @try {
        
        self.loginSignupBackView.layer.cornerRadius = 4.0;
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        
        ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:self.orangeView.frame];
        translucentView.translucentStyle = UIBarStyleBlack;
        translucentView.translucentTintColor = [UIColor clearColor];
        
        if (isIos7) {
            translucentView.translucentAlpha = 1.0;
            translucentView.backgroundColor = [UIColor clearColor];
            
        }else{
            translucentView.translucentAlpha = 9.0;
            translucentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
            for (UIView *view in [self.orangeView subviews]) {
                [view removeFromSuperview];
            }
            
        }
        
        
        // [self.view insertSubview:translucentView aboveSubview:self.orangeView];
        
        
        self.profileImage.layer.cornerRadius = 25.0;
        self.profileImage.layer.borderWidth = 3.0;
        self.profileImage.layer.masksToBounds = YES;
        self.profileImage.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }

    
}


-(IBAction)openMenuAction{
    [self.navigationController.sideMenu toggleLeftSideMenu];
}
- (IBAction)logoutAction {
    
    @try {
        
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully logged out" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *customerId = [prefs stringForKey:@"customerId"];
        
        
        NSString *keyString = [NSString stringWithFormat:@"%@noPaymentKey", customerId];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:keyString];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"arcUrl"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerId"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerToken"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"admin"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arcLoginType"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"customerEmail"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autoPostFacebook"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autoPostTwitter"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[self.navigationController dismissModalViewControllerAnimated:YES];
        
        InitHelpPageViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"InitHelpPage"];
        home.loggedOut = YES;
        [self.navigationController pushViewController:home animated:NO];
        
        

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.logoutAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
       
    
}
- (IBAction)serverAction {
    
    UIViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"editServer"];
    [self.navigationController pushViewController:tmp animated:YES];
    
    
}

-(void)loginOnlyAction{
    [self loginSignupAction];
    [self forgotPassword];
}
- (IBAction)loginSignupAction {
    
    @try {
        self.alphaBackView.hidden = NO;
        
        self.loginSignupBackView.hidden = NO;
        self.cancelSignupButton.hidden = NO;
        
        [self.emailText becomeFirstResponder];
        
        self.isLogin = NO;
        
        self.topLeftLabel.text = @"Register";
        [self.topRightButton setTitle:@"Already a member?" forState:UIControlStateNormal];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.loginSignupAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   

}

-(void)doneAction{
    
    @try {
        if ([self.emailText.text length] == 0 || [self.passwordText.text length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Please fill out both email and password before submitting." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }else if (!self.isLogin && [self.passwordText.text length] < 5){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Too Short" message:@"Password must be at least 5 characters." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            
        }else if (!self.isLogin && ![self validateEmail:self.emailText.text]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:@"Please enter a valid email address." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            
        }else{
            if (self.isLogin) {
                //run login
                [self runLogin];
            }else{
                // run register
               // [self runRegister];
            }
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.doneAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }

    

    
}

-(void)cancelSignup{
    
    @try {
        self.alphaBackView.hidden = YES;
        
        self.loginSignupBackView.hidden = YES;
        self.cancelSignupButton.hidden = YES;
        
        [self.emailText resignFirstResponder];
        [self.passwordText resignFirstResponder];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.cancelSignup" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }

   
}


-(IBAction)forgotPassword{
    
    @try {
        if (self.isLogin) {
            //Forgot Password
            
            UIViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"reset"];
            [self.navigationController pushViewController:tmp animated:YES];
        }else{
            //Switch to Login
            self.isLogin = YES;
            self.topLeftLabel.text = @"Login";
            [self.topRightButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.forgotPassword" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
  
    
}


- (BOOL) validateEmail: (NSString *) candidate {
    
    @try {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        return [emailTest evaluateWithObject:candidate];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.validateEmail" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        return NO;

    }
 

}




-(void)runLogin{
    @try {
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *loginDict = [[NSDictionary alloc] init];
        [ tempDictionary setObject:self.emailText.text forKey:@"userName"];
        [ tempDictionary setObject:self.passwordText.text forKey:@"password"];
        
        [self.loadingViewController startSpin];
        self.loadingViewController.displayText.text = @"Logging In...";
        
        
        loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client getCustomerToken:loginDict];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ProfileNewViewController.runLogin" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}

-(void)updateName{
    
    @try {
       
        [self.loadingViewController startSpin];
        self.loadingViewController.displayText.text = @"Updating...";
        
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        
        
        
        
        [tempDictionary setValue:self.firstNameTextField.text forKey:@"FirstName"];
        [tempDictionary setValue:self.lastNameTextField.text forKey:@"LastName"];
        
        
        NSDictionary *loginDict = [[NSDictionary alloc] init];
        loginDict = tempDictionary;
        
        
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp updateGuestCustomer:loginDict];
    }
    @catch (NSException *exception) {
         [rSkybox sendClientLog:@"ProfileNewViewController.updateName" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
  
    
}




-(void)signInComplete:(NSNotification *)notification{
    @try {
        
        [self.loadingViewController stopSpin];
     
        
        
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        //NSLog(@"Response Info: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            [[NSUserDefaults standardUserDefaults] setValue:self.emailText.text forKey:@"customerEmail"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            ArcClient *client = [[ArcClient alloc] init];
            [client getServer];
            
            ArcClient *tmp = [[ArcClient alloc] init];
            [tmp updatePushToken];
            
          
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully signed in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
          
            [self handleSuccess];
            
            
       
            
            //Do the next thing (go home?)
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == INCORRECT_LOGIN_INFO) {
                errorMsg = @"Invalid Email and/or Password";
            } else {
                // TODO -- programming error client/server coordination -- rskybox call
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            //self.errorLabel.text = errorMsg;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ProfileNewViewController.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
    }
    
}



-(void)registerComplete:(NSNotification *)notification{
    @try {
        self.loadingViewController.view.hidden = YES;
       
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            [[NSUserDefaults standardUserDefaults] setValue:self.emailText.text forKey:@"customerEmail"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            ArcClient *client = [[ArcClient alloc] init];
            [client getServer];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully registered." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            
          
            [self handleSuccess];
            
            
            
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == USER_ALREADY_EXISTS) {
                errorMsg = @"Email Address already used.";
            }else if (errorCode == NETWORK_ERROR){
                
                errorMsg = @"dono is having problems connecting to the internet.  Please check your connection and try again.  Thank you!";
                
            }else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            //self.activityView.hidden = NO;
            //self.errorLabel.hidden = NO;
            //self.errorLabel.text = errorMsg;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }
    @catch (NSException *e) {
        
        [self.loadingViewController stopSpin];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:@"We encountered an error processing your request, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [rSkybox sendClientLog:@"ProfileNewViewController.registerComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)handleSuccess{
    
    @try {
        [self cancelSignup];
        
        self.isLoggedIn = YES;
        self.topLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"];
        
        self.logoutButton.hidden = NO;
        [self.logoutButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.logoutButton.layer.cornerRadius = 10.0;
        self.logoutButton.layer.borderWidth = 2.0;
        self.logoutButton.layer.borderColor = [[UIColor redColor] CGColor];
        self.whiteArrow.hidden = YES;
        self.serverButton.hidden = NO;
        self.loginSignupButton.hidden = YES;
        self.loginOnlyButton.hidden = YES;
        self.bottomLabel.text = @"";

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.handleSuccess" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  

    
}



-(void)updateComplete:(NSNotification *)notification{
    @try {
        
        
        [self.loadingViewController stopSpin];
        
        
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        //NSLog(@"ResponseInfo: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
    
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your name has been updated." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
         
            [[NSUserDefaults standardUserDefaults] setValue:self.firstNameTextField.text forKey:@"customerFirstName"];
            [[NSUserDefaults standardUserDefaults] setValue:self.lastNameTextField.text forKey:@"customerLastName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            
        } else if([status isEqualToString:@"error"]){
            
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            
            if(errorCode == 103 || errorCode == 106) {
                //isAlreadyRegistered = YES;
            } else {
                errorMsg = @"Unable to update account, please try again.";
            }
            
            
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = @"Unable to update account, please try again.";
        }
        
        
            if([errorMsg length] > 0) {
                // self.errorLabel.text = errorMsg;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ProfileNewViewController.updateComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)signInCompleteGuest:(NSNotification *)notification{
    @try {
        
        
        self.loadingViewController.view.hidden = YES;
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        // NSLog(@"Response Info: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            mainDelegate.logout = @"true";
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            
            //Do the next thing (go home?)
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == INCORRECT_LOGIN_INFO) {
                errorMsg = @"Invalid Email and/or Password";
            } else {
                // TODO -- programming error client/server coordination -- rskybox call
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            //self.errorLabel.text = errorMsg;
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading Error" message:@"We experienced an error logging you out, please try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ProfileNewViewController.signInCompleteGuest" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
    }
    
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
    
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
    
    
        return 2;
    
}

-(void)saveName{
    
    if ([self.firstNameTextField.text length] > 0 && [self.lastNameTextField.text length] > 0) {
        [self.firstNameTextField resignFirstResponder];
        [self.lastNameTextField resignFirstResponder];
        
        [self updateName];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete Name" message:@"Please fill out both first name and last name before saving." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)cancelName{
    
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    @try {
        
        NSUInteger row = indexPath.row;
        NSUInteger section = indexPath.section;
        UITableViewCell *cell;
        
       
        if (section == 0) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell"];

            SteelfishInputText *textField = (SteelfishInputText *)[cell.contentView viewWithTag:1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (row == 0) {
                textField.placeholder = @"First Name";
                self.firstNameTextField = textField;
                
                UIToolbar *toolbar = [[UIToolbar alloc] init];
                [toolbar setBarStyle:UIBarStyleBlackTranslucent];
                [toolbar sizeToFit];
                UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
                UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveName)];
                UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelName)];
                
                doneButton.tintColor = [UIColor whiteColor];
                cancelButton.tintColor = [UIColor whiteColor];
                NSArray *itemsArray = [NSArray arrayWithObjects:cancelButton, flexButton, doneButton, nil];
                [toolbar setItems:itemsArray];
                [self.firstNameTextField setInputAccessoryView:toolbar];
                
                
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerFirstName"] length] > 0) {
                    self.firstNameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerFirstName"];
                }else{
                    self.firstNameTextField.text = @"";
                }
                
            }else{
                textField.placeholder = @"Last Name";
                self.lastNameTextField = textField;
                
                UIToolbar *toolbar = [[UIToolbar alloc] init];
                [toolbar setBarStyle:UIBarStyleBlackTranslucent];
                [toolbar sizeToFit];
                UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
                UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveName)];
                UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelName)];

                doneButton.tintColor = [UIColor whiteColor];
                cancelButton.tintColor = [UIColor whiteColor];
                NSArray *itemsArray = [NSArray arrayWithObjects:cancelButton, flexButton, doneButton, nil];
                [toolbar setItems:itemsArray];
                [self.lastNameTextField setInputAccessoryView:toolbar];
                
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerLastName"] length] > 0) {
                    self.lastNameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerLastName"];
                }else{
                    self.lastNameTextField.text = @"";
                }
                
                
                
            }

        }else{
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"supportCell"];
            
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            if (section == 1){
                SteelfishBoldLabel *supportLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];
                
                if (row == 1) {
                    supportLabel.text = @"Donation History";
                }else if (row == 0){
                    supportLabel.text = @"Payment Options";
                }else{
                    /*
                     supportLabel.text = @"Donation Subscription";
                     
                     self.recurringAmountLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:2];
                     self.recurringStringLabel = (SteelfishLabel *)[cell.contentView viewWithTag:3];
                     self.recurringActivityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:4];
                     
                     if (self.didGetRecurring) {
                     
                     self.recurringActivityIndicator.hidden = YES;
                     self.recurringAmountLabel.hidden = NO;
                     self.recurringStringLabel.hidden = NO;
                     
                     
                     
                     
                     }else{
                     self.recurringActivityIndicator.hidden = NO;
                     self.recurringAmountLabel.hidden = YES;
                     self.recurringStringLabel.hidden = YES;
                     
                     }
                     cell.selectionStyle = UITableViewCellSelectionStyleNone;
                     */
                };
                
            }
            
            
        }
  
        
        
        
        
        
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ProfileNewViewController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    @try {
        
        if (indexPath.section == 0) {
            return;
        }
        NSUInteger row = indexPath.row;
        
            if (row == 1) {
                
                [ArcClient trackEvent:@"SELECT_PAYMENT_HISTORY"];
                
                UIViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentHistory"];
                [self.navigationController pushViewController:tmp animated:YES];
            }else if (row == 0){
                [ArcClient trackEvent:@"SELECT_PAYMENT_OPTIONS"];
                
                PaymentOptionsWebViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentoptions"];
                [self.navigationController pushViewController:tmp animated:YES];
            }else{
                
                
                //[self subscriptionValueChanged];
            }
            
            
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ProfileNewViewController.didSelectRowAtIndexPath" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
    
}


-(void)subscriptionValueChanged{
    
    
    if (self.recurringAmount == 0.0) {
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
            self.subscriptionAlert = [[UIAlertView alloc] initWithTitle:@"Recurring Donation" message:@"Would you like to set up a recurring donation?  Dono will auotmatically charge the card of your choice once a month, or once a week, based on your selection.  You can cancel your recurring donation at any time." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Schedule", nil];
            [self.subscriptionAlert show];
        }else{
            self.loginAlert = [[UIAlertView alloc] initWithTitle:@"Not Logged In" message:@"Only registered users can sign up for recurring donations.  Would you like to create an account now?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Sign Up", nil];
            [self.loginAlert show];
          
        }
        
        
    }else{
        self.subscriptionAlert = [[UIAlertView alloc] initWithTitle:@"Cancel Recurring Donation" message:@"Would you like to remove your recurring donation?  Your card will no longer be charged, effective immediately." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Remove", nil];
        [self.subscriptionAlert show];
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView == self.subscriptionAlert) {
        
    }else if (alertView == self.loginAlert){
        
        if (buttonIndex == 1) {
            [self loginSignupAction];

           
        }else if (buttonIndex == 2){
            [self loginOnlyAction];

        }
    }
    
}



- (IBAction)endText {
}
@end
