//
//  SupportViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/27/13.
//
//

#import "SupportViewController.h"
#import "MFSideMenu.h"
#import "SteelfishBoldLabel.h"
#import "rSkybox.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcClient.h"
#import "LeftViewController.h"
#import "LatoRegularLabel.h"

@interface SupportViewController ()

@end

@implementation SupportViewController


-(void)viewWillAppear:(BOOL)animated{
    
    @try {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"defaultChurchId"] length] > 0) {
            self.defaultChurchSwitch.on = YES;
        }else{
            self.defaultChurchSwitch.on = NO;
        }
        
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"skipDonationOptions"] length] > 0) {
            self.showDonationOptionsSwitch.on = NO;
        }else{
            self.showDonationOptionsSwitch.on = YES;
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SupportViewController.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
 

    
}
-(void)viewDidLoad{
    
    
    @try {
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        self.versionLabel.text = [NSString stringWithFormat:@"version %@", appVersionString];
        
        
        [rSkybox addEventToSession:@"viewSupportViewController"];
        self.callButton.text = @"Call Us";
        self.emailButton.text = @"Send Us An Email";
        
        /// self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
        // self.topLineView.layer.shadowRadius = 1;
        //  self.topLineView.layer.shadowOpacity = 0.2;
        self.topLineView.backgroundColor = dutchTopLineColor;
        // self.backView.backgroundColor = dutchTopNavColor;
        
        
        
        [ArcClient trackEvent:@"SUPPORT_VIEW"];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SupportViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   

    
    

}

- (IBAction)openMenuAction {
    [self.navigationController.sideMenu toggleLeftSideMenu];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
   
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 3;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    @try {
        
        NSUInteger row = indexPath.row;
        NSUInteger section = indexPath.section;
        UITableViewCell *cell;
        
        if (section == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"contactUsCell"];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"supportCell"];
        }
        
        
        
        
        if (section == 2) {
            LatoRegularLabel *supportLabel = (LatoRegularLabel *)[cell.contentView viewWithTag:1];
            LatoRegularLabel *infoLabel = (LatoRegularLabel *)[cell.contentView viewWithTag:2];
            
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            NSString *phoneNumber = @"";
            NSString *emailAddress = @"";
            
            if (![prefs valueForKey:@"arcPhoneNumber"]) {
                [prefs setValue:@"201-838-3410" forKey:@"arcPhoneNumber"];
            }
            
            if (![prefs valueForKey:@"arcMail"]) {
                [prefs setValue:@"support@arcmobile.co" forKey:@"arcMail"];
            }
            
            phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"arcPhoneNumber"];
            emailAddress = [[NSUserDefaults standardUserDefaults] valueForKey:@"arcMail"];
            
            
            if (row == 0) {
                
                supportLabel.text = @"Email";
                infoLabel.text = emailAddress;
            }else{
                supportLabel.text = @"Phone";
                infoLabel.text = phoneNumber;
            }

        }else if (section == 1){
            SteelfishBoldLabel *supportLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];

                if (row == 0) {
                    supportLabel.text = @"How It Works";

                }else if (row == 1){
                    supportLabel.text = @"Feedback";

                }else{
                    supportLabel.text = @"Rate Us!";
                }

            
        }else if (section == 0){
            
            SteelfishBoldLabel *supportLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];
            supportLabel.text = @"View Donation History";
        }
       
        
        
        
        
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportViewController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    @try {
        NSUInteger section = indexPath.section;
        NSUInteger row = indexPath.row;
        
        if (section == 1) {
            
            if (row == 0) {
                //Help
                UIViewController *tutorial = [self.storyboard instantiateViewControllerWithIdentifier:@"InitTutorial"];
                [self.navigationController pushViewController:tutorial animated:YES];
                
            }else if (row == 1){
                [self emailFeedbackAction];
                
            }else{
                
                
                //rate
                NSString *str = @"itms-apps://itunes.apple.com/app/id755467894?at=10l6dK";
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                
                
            }
            
            
        }else if (section == 2){
            if (row == 0) {
                [self emailAction];
            }else{
                [self callAction];
            }
        }else if (section == 0){
            //go donation history
            
            UIViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentHistory"];
            [self.navigationController pushViewController:tmp animated:YES];
           
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"SupportViewController.didSelectRowAtIndexPath" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  

    
}


- (void)viewDidUnload {
    [self setCallButton:nil];
    [self setEmailButton:nil];
    [super viewDidUnload];
}
- (IBAction)callAction {
    
    @try {
        
        [rSkybox addEventToSession:@"phoneCallToArc"];
        
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]){
            
            NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"arcPhoneNumber"];
            
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            
            
            NSString *url = [@"tel://" stringByAppendingString:phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
            
            
        }else {
            
            NSString *message1 = @"You cannot make calls from this device.";
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:message1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert1 show];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportViewController.call" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

    
    
}
- (IBAction)emailAction {
    
    @try {
        
        [rSkybox addEventToSession:@"emailToArc"];
        
        if ([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            [mailViewController setToRecipients:@[[[NSUserDefaults standardUserDefaults] valueForKey:@"arcMail"]]];
            
            [self presentModalViewController:mailViewController animated:YES];
            
        }else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:@"Your device cannot currently send email." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportViewController.email" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)emailFeedbackAction {
    
    @try {
        
        [rSkybox addEventToSession:@"emailFeedbackToArc"];
        
        if ([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            [mailViewController setToRecipients:@[[[NSUserDefaults standardUserDefaults] valueForKey:@"arcMail"]]];
            [mailViewController setSubject:@"dono Feedback"];
            
            [self presentModalViewController:mailViewController animated:YES];
            
        }else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:@"Your device cannot currently send email." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportViewController.email" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return @"Dono";
    }else if (section == 2){
        return @"Contact Us";
    }else{
        return @"Donations";
    }
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    @try {
        
        switch (result)
        {
            case MFMailComposeResultCancelled:
                break;
            case MFMailComposeResultSent:
                
                break;
            case MFMailComposeResultFailed:
                
                break;
                
            case MFMailComposeResultSaved:
                
                break;
            default:
                
                break;
        }
        
        
        [self dismissModalViewControllerAnimated:YES];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportVC.mailComposeController" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)showDonationOptionsChanged {
    
    if (self.showDonationOptionsSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"skipDonationOptions"];
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"skipDonationOptions"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)defaultChurchChanged {
    
    if (self.defaultChurchSwitch.on) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Adding A Default" message:@"To add a default location, select 'Make this my default donation location' next time you pick a location to donate to. Would you like to go there now?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Yes", nil];
        [alert show];
        self.defaultChurchSwitch.on = NO;
    }else{
        
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"defaultChurchId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Default Location Removed" message:@"Your default location has been successfully removed." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
        LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
        [tmp homeSelected];
    }
}
@end
