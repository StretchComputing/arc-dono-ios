//
//  DefaultChurchView.h
//  HolyDutch
//
//  Created by Nick Wroblewski on 11/5/13.
//
//

#import <UIKit/UIKit.h>
#import "Merchant.h"
#import "SteelfishBoldLabel.h"
#import "NVUIGradientButton.h"
#import "CreditCard.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "SteelfishLabel.h"
#import "LoadingViewController.h"
#import "SteelfishTextFieldCreditCardiOS6.h"

@class  LoadingViewController;

@interface DefaultChurchView : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIView *guestCreateAccountView;

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *makeDonationButton;
@property (strong, nonatomic) IBOutlet SteelfishLabel *topLabel;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;

@property (nonatomic, strong) NSMutableArray *creditCardArray;
@property (strong, nonatomic) IBOutlet UIView *nameView;
- (IBAction)makeDonation:(id)sender;
@property BOOL haveDwolla;
@property (nonatomic, strong) NSString *amount;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *merchantName;
@property (strong, nonatomic) IBOutlet UIImageView *merchantImage;
@property (nonatomic, strong) Merchant *myMerchant;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) NSDictionary *donationType;
@property (nonatomic, strong) CreditCard *selectedCard;
@property (nonatomic, strong) NSArray *creditCards;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickButtonOne;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickButtonTwo;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickButtonThree;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickButtonFour;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *payButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *contactButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *websiteButton;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *messagesButton;
@property (strong, nonatomic) IBOutlet SteelfishLabel *recurringLabelBottom;

@property (strong, nonatomic) IBOutlet SteelfishLabel *donatingAsLabel;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *recurringLabelTop;
@property BOOL didFinishCards;
@property BOOL didJustRegister;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *donationHistoryButton;
@property (nonatomic, strong) UIAlertView *loginAlert;
@property (nonatomic, strong) UIAlertView *subscriptionAlert;

- (IBAction)quickActionOne;
- (IBAction)quickActionTwo;
- (IBAction)quickActionThree;
- (IBAction)quickActionFour;
- (IBAction)goDonationHistory;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *viewAllLocationsButton;
- (IBAction)goAllChurches;
@property (nonatomic, strong) UIAlertView *anonymousAlert;
@property (nonatomic, strong) UIAlertView *registerSuccessAlert;

@property (nonatomic, strong) NSMutableArray *messagesArray;

@property double recurringAmount;
@property BOOL didGetRecurring;
-(IBAction)contactAction;
-(IBAction)messagesAction;

-(IBAction)websiteAction;


//guestcreateaccount
- (IBAction)guestCreateAccountCancelAction;

@property (strong, nonatomic) IBOutlet UIView *guestCreateAccountFrontView;
- (IBAction)guestCreateAccountSubmitAction;
@property (strong, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *guestCreateAccountEmailText;

@property (strong, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *guestCreateAccountPasswordText;
- (IBAction)endText;

@property (nonatomic, strong) UIAlertView *areYouSureAlert;


@property (strong, nonatomic) IBOutlet UIView *anonymousAlertBackView;

- (IBAction)anonymousCancelAction;
- (IBAction)anonymousDonateAction;
- (IBAction)anonymousCreateAction;
@property (strong, nonatomic) IBOutlet UIImageView *anonymousCheckBox;
- (IBAction)anonymousReminderCheckAction;
@property BOOL anonymousReminderChecked;


@end
