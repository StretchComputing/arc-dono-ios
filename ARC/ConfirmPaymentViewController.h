//
//  ConfirmPaymentViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "NVUIGradientButton.h"
#import "LoadingViewController.h"
#import "SteelfishBoldLabel.h"
#import "CreditCard.h"
#import "Merchant.h"
#import "MyCreditCard.h"
#import "SteelfishLabel.h"

@class LoadingViewController;

@interface ConfirmPaymentViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>


- (IBAction)pinBegan:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) IBOutlet SteelfishLabel *pinPrompt;

@property (nonatomic, strong) NSMutableArray *selectedDonationTypes;
@property double chargeFee;
@property int numSelected;

@property BOOL isDefault;
@property BOOL isAnonymous;
@property (strong, nonatomic) IBOutlet UIImageView *defaultImageView;

@property (strong, nonatomic) IBOutlet UIImageView *anonymousImageView;

- (IBAction)anonymousClicked;
- (IBAction)defaultClicked;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *locationNameLabel;

@property (strong, nonatomic) IBOutlet UIView *anonymousView;
@property (nonatomic, strong) MyCreditCard *mySelectedCard;
@property (nonatomic, strong) CreditCard *selectedCard;
@property double donationAmount;
@property BOOL justAddedCard;
@property (nonatomic, strong) Merchant *myMerchant;

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (strong, nonatomic) Invoice *myInvoice;
@property (strong, nonatomic) IBOutlet SteelfishLabel *pinExplainText;

@property int incorrectPinCount;
- (IBAction)showPinHelp;

@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;
@property (nonatomic, strong) NSString *transactionNotes;
@property int paymentPointsReceived;

@property (strong, nonatomic) IBOutlet UIView *ccPinView;

@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet UITextField *hiddenText;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;
@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *confirmButton;
- (IBAction)confirmAction;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *paymentLabel;
- (IBAction)goBackAction;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;

@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *myTotalLabel;
@property double mySplitPercent;
@property (nonatomic, strong) NSArray *myItemsArray;
@property (nonatomic, strong) NSTimer *myTimer;
@end
