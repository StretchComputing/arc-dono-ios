//
//  InitHelpPageViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import "InitHelpPageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PrivacyTermsViewController.h"
#import "rSkybox.h"
#import "ArcAppDelegate.h"
#import "ArcClient.h"
#import "ArcIdentifier.h"
#import "GetPasscodeViewController.h"

@interface InitHelpPageViewController ()

@end

@implementation InitHelpPageViewController

-(void)viewDidAppear:(BOOL)animated{
    
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"didShowInitHelp"] length] > 0) {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didShowInitHelp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.helpView.frame;
            frame.origin.x = 30;
            self.helpView.frame = frame;
        }];
        
        [self performSelector:@selector(doneHelp) withObject:nil afterDelay:5.5];
        
    }
    
   
}

-(void)viewWillDisappear:(BOOL)animated{
    
    if (!self.isGoingPrivacyTerms) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }else{
        self.isGoingPrivacyTerms = NO;
    }
}


-(void)viewWillAppear:(BOOL)animated{
    
    
   // if (self.showLogin) {
        self.skipButton.hidden = YES;
        self.loginButton.hidden = NO;
        self.registerButton.hidden = NO;
    [self.myScrollView setContentOffset:CGPointMake(0, 0)];
   // }else{
     //   self.skipButton.hidden = NO;
    //    self.loginButton.alpha = 0.0;
    //    self.registerButton.alpha = 0.0;
        
   // }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerComplete:) name:@"registerNotification" object:nil];
    //self.loadingViewController.view.hidden = NO;
    //self.loadingViewController.displayText.text = @"
    
    NSString *identifier = [ArcIdentifier getArcIdentifier];
    
    
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *loginDict = [[NSDictionary alloc] init];
    [ tempDictionary setObject:identifier forKey:@"userName"];
    [ tempDictionary setObject:identifier forKey:@"password"];
    
    loginDict = tempDictionary;
    ArcClient *client = [[ArcClient alloc] init];
   // [client getGuestToken:loginDict];
    
    
    
}

-(void)doneHelp{
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.helpView.frame;
        frame.origin.x = 320;
        self.helpView.frame = frame;
    }];
}
- (void)viewDidLoad
{
    self.loginRegisterFrontView.layer.cornerRadius = 5.0;
    self.loginRegisterFrontView.layer.masksToBounds = YES;

    self.skipButton.layer.cornerRadius = 12.0;
    self.skipButton.layer.borderColor = [dutchRedColor CGColor];
    self.skipButton.layer.borderWidth = 2.0;
    
    self.loginButton.layer.cornerRadius = 12.0;
    self.loginButton.layer.borderColor = [dutchRedColor CGColor];
    self.loginButton.layer.borderWidth = 2.0;
    
    self.registerButton.layer.cornerRadius = 12.0;
    self.registerButton.layer.borderColor = [dutchRedColor CGColor];
    self.registerButton.layer.borderWidth = 2.0;
    
    self.termsButton.text = @"Terms of Use";
    self.termsButton.tintColor = dutchDarkBlueColor;
    self.privacyButton.text = @"Privacy Policy";
    self.privacyButton.tintColor = dutchDarkBlueColor;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    
    
    self.helpView.layer.cornerRadius = 7.0;
    self.helpView.layer.masksToBounds = YES;
    
    [super viewDidLoad];
	
    self.myScrollView.delegate = self;
    self.startUsingButton.text = @"Start Using Dono!";
    
    self.startUsingButton.tintColor =  dutchRedColor;
    
    @try {
        self.pageControl.pageIndicatorTintColor = dutchTopLineColor;
        self.pageControl.currentPageIndicatorTintColor = dutchRedColor;
    }
    @catch (NSException *exception) {
        
    }
   
    [self.myScrollView setContentSize:CGSizeMake(1280, 0)];
    
    self.helpImage1.layer.borderColor = [[UIColor blackColor] CGColor];
    self.helpImage1.layer.borderWidth = 2.0;
  //  self.helpImage1.layer.masksToBounds = YES;

   // self.helpImage1.layer.cornerRadius = 7.0;
    
    self.helpImage2.layer.borderColor = [[UIColor blackColor] CGColor];
    self.helpImage2.layer.borderWidth = 2.0;
    //self.helpImage2.layer.masksToBounds = YES;

   // self.helpImage2.layer.cornerRadius = 7.0;
    
    self.helpImage3.layer.borderColor = [[UIColor blackColor] CGColor];
    self.helpImage3.layer.borderWidth = 2.0;
   // self.helpImage3.layer.masksToBounds = YES;
   // self.helpImage3.layer.cornerRadius = 5.0;
    
    
    self.helpImage1.layer.shadowOffset = CGSizeMake(-2, 2);
    self.helpImage1.layer.shadowRadius = 1;
    self.helpImage1.layer.shadowOpacity = 0.5;
    
    self.helpImage2.layer.shadowOffset =  CGSizeMake(-2, 2);
    self.helpImage2.layer.shadowRadius = 1;
    self.helpImage2.layer.shadowOpacity = 0.5;
    
    self.helpImage3.layer.shadowOffset =  CGSizeMake(-2, 2);
    self.helpImage3.layer.shadowRadius = 1;
    self.helpImage3.layer.shadowOpacity = 0.5;
    
    
    
  //  self.topLine.layer.shadowOffset = CGSizeMake(0, 1);
 //   self.topLine.layer.shadowRadius = 1;
 //   self.topLine.layer.shadowOpacity = 0.2;
   // self.topLine.backgroundColor = dutchTopLineColor;
   // self.view.backgroundColor = dutchTopNavColor;
    
    
  //  self.bottomLine.layer.shadowOffset = CGSizeMake(0, 1);
  ////  self.bottomLine.layer.shadowRadius = 1;
  //  self.bottomLine.layer.shadowOpacity = 0.2;
    self.bottomLine.backgroundColor = dutchTopLineColor;

    
    self.vertLine1.layer.shadowOffset = CGSizeMake(1, 0);
    self.vertLine1.layer.shadowRadius = 1;
    self.vertLine1.layer.shadowOpacity = 0.5;
    
    self.vertLine2.layer.shadowOffset = CGSizeMake(1, 0);
    self.vertLine2.layer.shadowRadius = 1;
    self.vertLine2.layer.shadowOpacity = 0.5;
    
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    self.loadingViewController.view.hidden = YES;
    [self.view addSubview:self.loadingViewController.view];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int offset = scrollView.contentOffset.x;
    
    if (offset == 0) {
        self.pageControl.currentPage = 0;
    }else if (offset == 320){
        self.pageControl.currentPage = 1;
    }else if (offset == 640){
        self.pageControl.currentPage = 2;
    }else if (offset == 960){
        self.pageControl.currentPage = 3;
        [self fadeToLogin];
        //[self.skipButton setTitle:@"Get Started!" forState:UIControlStateNormal];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        @try {
            
            
            
            if ([[segue identifier] isEqualToString:@"goPrivacy"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = YES;
                self.isGoingPrivacyTerms = YES;
                
            }
            
            if ([[segue identifier] isEqualToString:@"goTerms"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = NO;
                self.isGoingPrivacyTerms = YES;
                
            }
        }
        @catch (NSException *e) {
            [rSkybox sendClientLog:@"InitialHelpPageVC.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InitialHelpPageVC.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (IBAction)termsAction {
    [self performSegueWithIdentifier:@"goTerms" sender:self];
}

- (IBAction)privacyAction {
    [self performSegueWithIdentifier:@"goPrivacy" sender:self];

}

- (IBAction)registerAction {
    self.isLogin = NO;
    self.loginRegisterBackView.hidden = NO;
    self.loginRegisterTitleText.text = @"New Account";
    self.nameText.hidden = NO;
    [self.emailText becomeFirstResponder];
    self.forgotPasswordButton.hidden = YES;
    self.passwordText.text = @"";
}

- (IBAction)loginAction {
    
    self.isLogin = YES;
    self.loginRegisterBackView.hidden = NO;
    self.loginRegisterTitleText.text = @"Log In";
    self.nameText.hidden = YES;
    [self.emailText becomeFirstResponder];
    self.forgotPasswordButton.hidden = NO;
    self.passwordText.text = @"";

}

-(void)fadeToLogin{
    
    [UIView animateWithDuration:0.4 animations:^(void){
       
        self.skipButton.alpha = 0.0;
        self.registerButton.alpha = 1.0;
        self.loginButton.alpha = 1.0;
    }];
}
-(void)startUsingAction{
    
    [self fadeToLogin];

    /*
    if (self.didFailToken) {
        
        NSString *identifier = [ArcIdentifier getArcIdentifier];
        
        self.loadingViewController.view.hidden = NO;
        self.loadingViewController.displayText.text = @"Starting dono...";
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *loginDict = [[NSDictionary alloc] init];
        [ tempDictionary setObject:identifier forKey:@"userName"];
        [ tempDictionary setObject:identifier forKey:@"password"];
        
        loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client getGuestToken:loginDict];
        
        
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didAgreeTerms"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"guestToken"] length] > 0) {
            
            UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
            home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:home animated:YES];
            
        }else{
            if (self.doesHaveGuestToken || self.guestTokenError) {
                
                if (self.guestTokenError) {
                    
                    self.didPushStart = YES;
                    self.loadingViewController.view.hidden = NO;
                    self.loadingViewController.displayText.text = @"Loading dono...";
                    
                    NSString *identifier = [ArcIdentifier getArcIdentifier];
                    
                    
                    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                    NSDictionary *loginDict = [[NSDictionary alloc] init];
                    [ tempDictionary setObject:identifier forKey:@"userName"];
                    [ tempDictionary setObject:identifier forKey:@"password"];
                    
                    loginDict = tempDictionary;
                    ArcClient *client = [[ArcClient alloc] init];
                    [client getGuestToken:loginDict];
                    
                    
                    
                }else{
                    UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
                    home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentModalViewController:home animated:YES];
                }
                
            }else{
                
                //Call is still loading
                self.didPushStart = YES;
                self.loadingViewController.view.hidden = NO;
                self.loadingViewController.displayText.text = @"Loading dono...";
            }
        }

    }
       
     */
}

- (IBAction)forgotPasswordAction {
    
    if (self.loggedOut) {
        UIViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"reset"];
        [self.navigationController pushViewController:tmp animated:YES];
    }else{
        
        
        UINavigationController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"resetNav"];
        GetPasscodeViewController *passcode = [[tmp viewControllers] objectAtIndex:0];
        passcode.isInitial = YES;
        [self presentViewController:tmp animated:YES completion:nil];
    }
   
    
}

- (IBAction)endText {
}



- (IBAction)loginRegisterNoThanksAction {
    self.loginRegisterBackView.hidden = YES;
    
    [self.emailText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self.nameText resignFirstResponder];
}

- (IBAction)loginRegisterSubmitAction {
    
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
            
            
        }else if (!self.isLogin && [self.nameText.text length] == 0){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Name" message:@"Please enter your name.  Your name will only be used to give you credit for your donations, if you choose to not donate anonymously." delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else{
            if (self.isLogin) {
                //run login
                [self runLogin];
            }else{
                // run register
                [self runRegister];
            }
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"InitHelpPageVC.doneAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
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
        [rSkybox sendClientLog:@"InitHelpPageVC.runLogin" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}

-(void)runRegister{
    
    
    
    @try{
        
        [self.loadingViewController startSpin];
        self.loadingViewController.displayText.text = @"Registering...";
        
        NSString *firstName = @"";
        NSString *lastName = @"";
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        
        NSArray *nameArray = [self.nameText.text componentsSeparatedByString:@" "];
        
        if ([nameArray count] > 0) {
            
            firstName = [nameArray objectAtIndex:0];
            
            for (int i = 1; i < [nameArray count]; i++) {
                
                if ([lastName length] == 0) {
                    lastName = [lastName stringByAppendingFormat:@"%@", [nameArray objectAtIndex:i]];

                }else{
                    lastName = [lastName stringByAppendingFormat:@" %@", [nameArray objectAtIndex:i]];

                }
            }
        }
      
        
		[ tempDictionary setObject:firstName forKey:@"FirstName"];
		[ tempDictionary setObject:lastName forKey:@"LastName"];
		[ tempDictionary setObject:self.emailText.text forKey:@"eMail"];
		[ tempDictionary setObject:self.passwordText.text forKey:@"Password"];
        [ tempDictionary setObject:@"Phone" forKey:@"Source"];
        
        [ tempDictionary setObject:[NSNumber numberWithBool:NO] forKey:@"IsGuest"];
        
        
        
        //[ tempDictionary setObject:genderString forKey:@"Gender"];
        
        // TODO hard coded for now
        [ tempDictionary setObject:@"123" forKey:@"PassPhrase"];
        
        
        
        //[ tempDictionary setObject:birthDayString forKey:@"BirthDate"];
        [ tempDictionary setObject:@(YES) forKey:@"AcceptTerms"];
        [ tempDictionary setObject:@(YES) forKey:@"Notifications"];
        [ tempDictionary setObject:@(NO) forKey:@"Facebook"];
        [ tempDictionary setObject:@(NO) forKey:@"Twitter"];
        
		loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client createCustomer:loginDict];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InitHelpPageVC.runRegister" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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


-(void)signInComplete:(NSNotification *)notification{
    @try {
        
        self.loadingViewController.view.hidden = YES;
        
        
        
        
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
        [rSkybox sendClientLog:@"InitHelpPageVC.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
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
            NSString *firstName = @"";
            NSString *lastName = @"";
            
    
            
            NSArray *nameArray = [self.nameText.text componentsSeparatedByString:@" "];
            
            if ([nameArray count] > 0) {
                
                firstName = [nameArray objectAtIndex:0];
                
                for (int i = 1; i < [nameArray count]; i++) {
                    
                    if ([lastName length] == 0) {
                        lastName = [lastName stringByAppendingFormat:@"%@", [nameArray objectAtIndex:i]];
                        
                    }else{
                        lastName = [lastName stringByAppendingFormat:@" %@", [nameArray objectAtIndex:i]];
                        
                    }
                }
            }

            
            
            
            [[NSUserDefaults standardUserDefaults] setValue:firstName forKey:@"customerFirstName"];
            [[NSUserDefaults standardUserDefaults] setValue:lastName forKey:@"customerLastName"];
            
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
        
        [rSkybox sendClientLog:@"InitHelpPageVC.registerComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)handleSuccess{
    
    if (self.loggedOut) {
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        self.loginRegisterBackView.hidden = YES;
        UIViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
        home.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:home animated:YES];
    }
   
}


@end
