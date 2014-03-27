//
//  RecurringDonationOne.h
//  Dono
//
//  Created by Nick Wroblewski on 3/26/14.
//
//

#import <UIKit/UIKit.h>
#import "SteelfishLabel.h"
#import "Merchant.h"

@interface RecurringDonationOne : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet SteelfishLabel *titleLabel;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (strong, nonatomic) IBOutlet UIImageView *monthlyCheckImage;
@property (strong, nonatomic) IBOutlet UIImageView *xofMonthCheckImage;
@property (strong, nonatomic) IBOutlet UITextField *mainDetailText;
@property (strong, nonatomic) IBOutlet UITextField *secondaryDetailText;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
- (IBAction)textFieldEditingChanged:(id)sender;

@property (nonatomic, strong) NSMutableArray *matchingDays;
- (IBAction)continueAction;
@property (strong, nonatomic) IBOutlet UISegmentedControl *secondarySegmentControl;
@property (strong, nonatomic) IBOutlet SteelfishLabel *secondaryExplanation;

@property (strong, nonatomic) IBOutlet UIImageView *weeklyCheckImage;

- (IBAction)endText;

- (IBAction)weeklyAction;
- (IBAction)monthlyAction;
- (IBAction)xdayAction;

@property (nonatomic, strong) NSArray *daysOfWeek;

@property BOOL isChangingKeyboard;
@property (nonatomic, strong) NSArray *creditCards;
@property (nonatomic, strong) Merchant *myMerchant;
@property (nonatomic, strong) NSDictionary *selectedCard;

@property (nonatomic, strong) NSString *scheduleString;
@property int mainDetail;
@property int secondaryDetail;

@property (strong, nonatomic) IBOutlet SteelfishLabel *monthlyHelpText;

@end
