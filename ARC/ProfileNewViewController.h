//
//  ProfileNewViewController.h
//  Dono
//
//  Created by Nick Wroblewski on 1/26/14.
//
//

#import <UIKit/UIKit.h>
#import "SteelfishBoldLabel.h"
#import "LoadingViewController.h"
#import "SteelfishTextFieldCreditCardiOS6.h"
#import "SteelfishLabel.h"
#import "SteelfishBoldButton.h"
#import "SteelfishBoldLabel.h"
#import "LatoRegularLabel.h"

@class LoadingViewController;

@interface ProfileNewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
- (IBAction)logoutAction;
@property (strong, nonatomic) IBOutlet UIImageView *whiteArrow;
@property (strong, nonatomic) IBOutlet UIButton *serverButton;
- (IBAction)serverAction;
- (IBAction)loginSignupAction;
- (IBAction)loginOnlyAction;

@property (nonatomic, strong) UIAlertView *loginAlert;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIButton *loginSignupButton;
@property (strong, nonatomic) IBOutlet UIButton *loginOnlyButton;

@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *topLabel;
@property (strong, nonatomic) IBOutlet SteelfishLabel *bottomLabel;

@property (strong, nonatomic) IBOutlet UIImageView *orangeView;
@property BOOL isLoggedIn;

@property (nonatomic, strong) IBOutlet UIView *loginSignupBackView;
@property (nonatomic, strong) IBOutlet UIView *alphaBackView;

@property (nonatomic, strong) IBOutlet SteelfishTextFieldCreditCardiOS6 *emailText;
@property (nonatomic, strong) IBOutlet SteelfishTextFieldCreditCardiOS6 *passwordText;
- (IBAction)doneAction;
- (IBAction)cancelSignup;
@property (nonatomic, strong) IBOutlet SteelfishBoldButton *cancelSignupButton;
@property BOOL isLogin;

-(IBAction)forgotPassword;

@property (nonatomic, strong) IBOutlet SteelfishLabel *topLeftLabel;
@property (nonatomic, strong) IBOutlet SteelfishBoldButton *topRightButton;


@property double recurringAmount;
@property (nonatomic, strong) NSString *recurringString;
@property (nonatomic, strong) SteelfishBoldLabel *recurringAmountLabel;
@property (nonatomic, strong) SteelfishLabel *recurringStringLabel;
@property (nonatomic, strong) UIActivityIndicatorView *recurringActivityIndicator;
@property BOOL didGetRecurring;
@property (nonatomic, strong) UIAlertView *subscriptionAlert;





@end
