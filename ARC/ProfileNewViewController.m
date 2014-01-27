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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerComplete:) name:@"registerNotification" object:nil];

    
   
    
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
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
        
    }else{
        self.topLabel.text = @"Sign Up/Log In";
        self.logoutButton.hidden = YES;
        self.whiteArrow.hidden = NO;
        self.serverButton.hidden = YES;
        self.loginSignupButton.hidden = NO;
    }
    
    self.topLabel.textColor = [UIColor whiteColor];
    
}

- (void)viewDidLoad
{
    
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
    
    
    self.profileImage.layer.cornerRadius = 35.0;
    self.profileImage.layer.borderWidth = 3.0;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    
}


-(IBAction)openMenuAction{
    [self.navigationController.sideMenu toggleLeftSideMenu];
}
- (IBAction)logoutAction {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    NSString *guestId = [prefs stringForKey:@"guestId"];
    NSString *guestToken = [prefs stringForKey:@"guestToken"];
    
    if (![guestId isEqualToString:@""] && (guestId != nil) && ![guestToken isEqualToString:@""] && (guestToken != nil)) {
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        mainDelegate.logout = @"true";
        [self.navigationController popToRootViewControllerAnimated:NO];
        
    }else{
        //Get the Guest Token, then push to InitHelpPage
        NSString *identifier = [ArcIdentifier getArcIdentifier];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *loginDict = [[NSDictionary alloc] init];
        [ tempDictionary setObject:identifier forKey:@"userName"];
        [ tempDictionary setObject:identifier forKey:@"password"];
        
        loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        
        self.loadingViewController.view.hidden = NO;
        self.loadingViewController.displayText.text = @"Logging Out";
        [client getGuestToken:loginDict];
        
    }
    
    
}
- (IBAction)serverAction {
    
    UIViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"editServer"];
    [self.navigationController pushViewController:tmp animated:YES];
    
    
}

- (IBAction)loginSignupAction {
    
    self.alphaBackView.hidden = NO;
    
    self.loginSignupBackView.hidden = NO;
    self.cancelSignupButton.hidden = NO;
    
    [self.emailText becomeFirstResponder];
    
    self.isLogin = NO;
    
    self.topLeftLabel.text = @"Register";
    [self.topRightButton setTitle:@"Already a member?" forState:UIControlStateNormal];

}

-(void)doneAction{
    
    
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
            [self runRegister];
        }
    }
    
}

-(void)cancelSignup{
    
    self.alphaBackView.hidden = YES;
    
    self.loginSignupBackView.hidden = YES;
    self.cancelSignupButton.hidden = YES;

    [self.emailText resignFirstResponder];
    [self.passwordText resignFirstResponder];
}


-(IBAction)forgotPassword{
    
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


- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
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

-(void)runRegister{
    
    
    @try{
        
        [self.loadingViewController startSpin];
        self.loadingViewController.displayText.text = @"Registering...";
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        
        
		[ tempDictionary setObject:@"none" forKey:@"FirstName"];
		[ tempDictionary setObject:@"none" forKey:@"LastName"];
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
        [rSkybox sendClientLog:@"ProfileNewViewController.runRegister" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
    
}


@end