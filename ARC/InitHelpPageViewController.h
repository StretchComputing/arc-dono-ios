//
//  InitHelpPageViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import "LoadingViewController.h"
#import "SteelfishBoldButton.h"
#import "SteelfishTextFieldCreditCardiOS6.h"
#import "SteelfishLabel.h"

@class  LoadingViewController;

@interface InitHelpPageViewController : UIViewController <UIScrollViewDelegate>

@property BOOL loggedOut;

@property BOOL showLogin;
@property (strong, nonatomic) IBOutlet UIView *helpView;
@property BOOL isGoingPrivacyTerms;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property BOOL doesHaveGuestToken;
@property BOOL didPushStart;
@property BOOL guestTokenError;
@property BOOL didFailToken;
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage1;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage2;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *startUsingButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage3;
@property (strong, nonatomic) IBOutlet UIView *topLine;
@property (strong, nonatomic) IBOutlet UIView *bottomLine;
@property (strong, nonatomic) IBOutlet UIView *vertLine1;
@property (strong, nonatomic) IBOutlet UIView *vertLine2;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *termsButton;
- (IBAction)termsAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *privacyButton;
- (IBAction)privacyAction;
@property (strong, nonatomic) IBOutlet SteelfishBoldButton *skipButton;
@property (strong, nonatomic) IBOutlet SteelfishBoldButton *registerButton;
- (IBAction)registerAction;
@property (strong, nonatomic) IBOutlet SteelfishBoldButton *loginButton;
- (IBAction)loginAction;

-(IBAction)startUsingAction;
@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordButton;
- (IBAction)forgotPasswordAction;

- (IBAction)endText;


@property BOOL isLogin;
@property (strong, nonatomic) IBOutlet UIView *loginRegisterBackView;
@property (strong, nonatomic) IBOutlet SteelfishLabel *loginRegisterTitleText;

@property (strong, nonatomic) IBOutlet UIView *loginRegisterFrontView;
@property (strong, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *emailText;
@property (strong, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *passwordText;
@property (strong, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *nameText;

- (IBAction)loginRegisterNoThanksAction;
- (IBAction)loginRegisterSubmitAction;

@end
