//
//  RecurringDonationFinal.h
//  Dono
//
//  Created by Nick Wroblewski on 3/26/14.
//
//

#import <UIKit/UIKit.h>
#import "Merchant.h"
#import "SteelfishLabel.h"
#import "SteelfishBoldLabel.h"
#import "LoadingViewController.h"
@class LoadingViewController;
@interface RecurringDonationFinal : UIViewController

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (strong, nonatomic) IBOutlet SteelfishLabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet SteelfishLabel *scheduleLabel;
@property (strong, nonatomic) IBOutlet SteelfishLabel *paymentLabel;
@property (strong, nonatomic) IBOutlet UITextField *paymentAmountTextField;

- (IBAction)submitAction;
@property (nonatomic, strong) Merchant *myMerchant;
@property NSDictionary *selectedCard;
@property (strong, nonatomic) IBOutlet SteelfishLabel *processingLabel;

@property (nonatomic, strong) NSString *scheduleString;
@property int mainDetail;
@property int secondaryDetail;
@property double chargeFee;

@end
