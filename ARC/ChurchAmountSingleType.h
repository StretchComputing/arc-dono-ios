//
//  ChurchAmountSingleType.h
//  HolyDutch
//
//  Created by Nick Wroblewski on 10/16/13.
//
//

#import <UIKit/UIKit.h>
#import "Merchant.h"
#import "SteelfishBoldLabel.h"
#import "SteelfishLabel.h"
#import "NVUIGradientButton.h"
#import "SteelfishBoldInputText.h"
#import "CreditCard.h"
@class Merchant;

@interface ChurchAmountSingleType : UIViewController <UIActionSheetDelegate>
- (IBAction)goBack;


@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *merchantNameText;
@property IBOutlet UIButton *goBackButton;

@property (nonatomic, strong) NSArray *creditCards;
@property BOOL isHome;

@property BOOL haveDwolla;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) CreditCard *selectedCard;
@property (nonatomic, strong) Merchant *myMerchant;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *titleLabel;
@property (nonatomic, strong) NSDictionary *donationType;
@property (strong, nonatomic) IBOutlet SteelfishLabel *typeLabel;
@property (strong, nonatomic) IBOutlet SteelfishBoldInputText *amountText;
@property (strong, nonatomic) IBOutlet UISlider *amountSlider;

@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickButtonOne;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickButtonTwo;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickButtonThree;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickButtonFour;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *payButton;
- (IBAction)payAction;

- (IBAction)quickActionOne;
- (IBAction)quickActionTwo;
- (IBAction)quickActionThree;
- (IBAction)quickActionFour;

- (IBAction)sliderChanged;
@end
