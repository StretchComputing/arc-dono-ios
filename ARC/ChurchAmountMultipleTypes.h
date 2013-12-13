//
//  ChurchAmountMultipleTypes.h
//  HolyDutch
//
//  Created by Nick Wroblewski on 10/16/13.
//
//

#import <UIKit/UIKit.h>
#import "Merchant.h"
#import "CreditCard.h"
#import "SteelfishBoldLabel.h"
#import "NVUIGradientButton.h"

@class Merchant;

@interface ChurchAmountMultipleTypes : UIViewController <UIActionSheetDelegate>
- (IBAction)goBack;

@property double chargeFee;
@property BOOL isHome;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;


@property (nonatomic, strong) NSString *webCardNumber;
@property (nonatomic, strong) NSString *webExpiration;
@property (nonatomic, strong) NSString *webSecurityCode;


@property int currentIndex;
@property (nonatomic, strong) IBOutlet UIScrollView *middleView;
@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *typeLabel;
@property BOOL haveDwolla;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) CreditCard *selectedCard;
@property (nonatomic, strong) NSMutableArray *multiDonationViews;

@property (nonatomic, strong) Merchant *myMerchant;
@property (nonatomic, strong) NSMutableArray *selectedDonations;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *payButton;
- (IBAction)payAction;

@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *amountText;

-(void)calculateTotal;


@property (nonatomic, strong) IBOutlet UIView *helpOverlayView;
-(IBAction)closeHelpOverlay;



@end
