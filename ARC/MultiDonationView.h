//
//  MultiDonationView.h
//  HolyDutch
//
//  Created by Nick Wroblewski on 10/17/13.
//
//

#import <UIKit/UIKit.h>
#import "SteelfishLabel.h"
#import "SteelfishBoldLabel.h"
#import "SteelfishBoldInputText.h"
#import "NVUIGradientButton.h"
#import "ChurchAmountMultipleTypes.h"

@class ChurchAmountMultipleTypes;

@interface MultiDonationView : UIViewController

@property (nonatomic, strong) ChurchAmountMultipleTypes *parentVc;

@property (nonatomic, strong) NSString *initialAmount;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet SteelfishLabel *titleLabel;

@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickDonateButtonOne;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickDonateButtonTwo;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickDonateButtonThree;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *quickDonateButtonFour;

-(IBAction)quickDonateActionOne;
-(IBAction)quickDonateActionTwo;
-(IBAction)quickDonateActionThree;
-(IBAction)quickDonateActionFour;
@property (strong, nonatomic) IBOutlet SteelfishBoldInputText *amountText;

@end
