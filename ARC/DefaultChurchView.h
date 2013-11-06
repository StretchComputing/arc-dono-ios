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

@interface DefaultChurchView : UIViewController <UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet NVUIGradientButton *makeDonationButton;

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
@property (strong, nonatomic) IBOutlet NVUIGradientButton *donationHistoryButton;
@property (nonatomic, strong) UIAlertView *logInAlert;
- (IBAction)quickActionOne;
- (IBAction)quickActionTwo;
- (IBAction)quickActionThree;
- (IBAction)quickActionFour;
- (IBAction)goDonationHistory;

@end
