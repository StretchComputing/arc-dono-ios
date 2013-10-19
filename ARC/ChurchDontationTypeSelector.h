//
//  ChurchDontationTypeSelector.h
//  HolyDutch
//
//  Created by Nick Wroblewski on 10/16/13.
//
//

#import <UIKit/UIKit.h>
#import "Merchant.h"
#import "SteelfishBoldLabel.h"
#import "NVUIGradientButton.h"

@class Merchant;

@interface ChurchDontationTypeSelector : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property IBOutlet UIButton *goBackButton;

@property (nonatomic, strong) NSMutableArray *selectedRows;
@property (nonatomic, strong) IBOutlet SteelfishBoldLabel *merchantNameText;

@property BOOL isHome;
-(IBAction)next;
-(IBAction)goBack;
@property (nonatomic, strong) Merchant *myMerchant;
@property (strong, nonatomic) IBOutlet SteelfishBoldLabel *titleLabel;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *nextButton;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end
