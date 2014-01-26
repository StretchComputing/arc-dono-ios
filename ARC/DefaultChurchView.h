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


@interface DefaultChurchView : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet NVUIGradientButton *makeDonationButton;
@property (strong, nonatomic) IBOutlet SteelfishLabel *topLabel;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;

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

@property (strong, nonatomic) IBOutlet NVUIGradientButton *donationHistoryButton;
@property (nonatomic, strong) UIAlertView *logInAlert;
- (IBAction)quickActionOne;
- (IBAction)quickActionTwo;
- (IBAction)quickActionThree;
- (IBAction)quickActionFour;
- (IBAction)goDonationHistory;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *viewAllLocationsButton;
- (IBAction)goAllChurches;

@property (nonatomic, strong) NSMutableArray *messagesArray;

-(IBAction)contactAction;
-(IBAction)messagesAction;

-(IBAction)websiteAction;


@end
