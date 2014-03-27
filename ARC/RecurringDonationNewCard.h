//
//  RecurringDonationNewCard.h
//  Dono
//
//  Created by Nick Wroblewski on 3/26/14.
//
//

#import <UIKit/UIKit.h>
#import "Merchant.h"
#import "SteelfishLabel.h"
#import "SteelfishTextFieldCreditCardiOS6.h"

@interface RecurringDonationNewCard : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) Merchant *myMerchant;
@property NSDictionary *selectedCard;


@property (strong, nonatomic) IBOutlet SteelfishLabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *addCardButton;
- (IBAction)addCardAction;
@property (nonatomic, strong) NSString *scheduleString;
@property int mainDetail;
@property int secondaryDetail;

@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *creditCardSecurityCodeText;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *creditCardNumberText;
@property (weak, nonatomic) IBOutlet SteelfishTextFieldCreditCardiOS6 *expirationText;

@property (nonatomic, strong) IBOutlet UITableView *myTableView;


@property BOOL isDelete;
@property BOOL shouldIgnoreValueChanged;
@property BOOL shouldIgnoreValueChangedExpiration;



@end
