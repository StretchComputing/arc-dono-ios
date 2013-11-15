//
//  MultiDonationView.m
//  HolyDutch
//
//  Created by Nick Wroblewski on 10/17/13.
//
//

#import "MultiDonationView.h"
#import "ArcAppDelegate.h"

@interface MultiDonationView ()

@end

@implementation MultiDonationView


-(void)setQuickPays{
    
    if (self.myMerchant.quickPayFour <= 100) {
        self.quickDoubleOne = 5.0;
        self.quickDoubleTwo = 10.0;
        self.quickDoubleThree = 15.0;
        self.quickDoubleFour = 25.0;
        
    }else if (self.myMerchant.quickPayFour <= 200){
        self.quickDoubleOne = 10.0;
        self.quickDoubleTwo = 25.0;
        self.quickDoubleThree = 50.0;
        self.quickDoubleFour = 75.0;
    }else{
        self.quickDoubleOne = 25.0;
        self.quickDoubleTwo = 50.0;
        self.quickDoubleThree = 75.0;
        self.quickDoubleFour = 100.0;
    }
    
    self.quickDonateButtonOne.text = [NSString stringWithFormat:@"$%.0f", self.quickDoubleOne];
    self.quickDonateButtonOne.textColor = [UIColor whiteColor];
    self.quickDonateButtonOne.tintColor = dutchDarkBlueColor;
    
    self.quickDonateButtonTwo.text = [NSString stringWithFormat:@"$%.0f", self.quickDoubleTwo];
    self.quickDonateButtonTwo.textColor = [UIColor whiteColor];
    self.quickDonateButtonTwo.tintColor = dutchDarkBlueColor;
    
    self.quickDonateButtonThree.text = [NSString stringWithFormat:@"$%.0f", self.quickDoubleThree];
    self.quickDonateButtonThree.textColor = [UIColor whiteColor];
    self.quickDonateButtonThree.tintColor = dutchDarkBlueColor;
    
    self.quickDonateButtonFour.text = [NSString stringWithFormat:@"$%.0f", self.quickDoubleFour];
    self.quickDonateButtonFour.textColor = [UIColor whiteColor];
    self.quickDonateButtonFour.tintColor = dutchDarkBlueColor;
    
    
}
- (void)viewDidLoad
{

    
   
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.mainView.layer.cornerRadius = 2.0;
    self.mainView.layer.borderColor = [[UIColor colorWithRed:171.0/255.0 green:171.0/255.0 blue:171.0/255.0 alpha:1.0] CGColor];
    self.mainView.layer.borderWidth = 1.0;
    
 
    
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    
    UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
   // UIBarButtonItem *payButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pay)];
    UIBarButtonItem *payButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(pay)];
    
    if (isIos7) {
        payButton.tintColor = [UIColor whiteColor];
        cancelButton.tintColor = [UIColor whiteColor];
    }
    NSArray *itemsArray = [NSArray arrayWithObjects:cancelButton, flexButton, payButton, nil];
    
    
    [toolbar setItems:itemsArray];
    
    [self.amountText setInputAccessoryView:toolbar];
    
    [self.amountText addTarget:self action:@selector(textBeginEdit) forControlEvents:UIControlEventEditingDidBegin];
    
    
    
}

-(void)textBeginEdit{
    
    self.initialAmount = self.amountText.text;
    if ([self.amountText.text doubleValue] == 0.0){
        self.amountText.text = @"";
    }
    
    if (self.view.frame.origin.y > 0) {
        
        //[self.parentVc.middleView setContentOffset:CGPointMake(0, self.view.frame.origin.y) animated:YES];
    }
}


-(void)cancel{
    
    
    self.amountText.text = self.initialAmount;
    
    [self.amountText resignFirstResponder];
    
    if ([self.amountText.text isEqualToString:@""]) {
        self.amountText.text = @"0.00";
    }
}

-(void)pay{
    
    double amount = [self.amountText.text doubleValue];
    self.amountText.text = [NSString stringWithFormat:@"%.2f", amount];
    
    [self.amountText resignFirstResponder];
    [self.parentVc calculateTotal];
}
-(IBAction)quickDonateActionOne{
    self.amountText.text = [NSString stringWithFormat:@"%.2f", self.quickDoubleOne];
    [self.parentVc calculateTotal];

    
}
-(IBAction)quickDonateActionTwo{
    self.amountText.text = [NSString stringWithFormat:@"%.2f", self.quickDoubleTwo];
    [self.parentVc calculateTotal];


}
-(IBAction)quickDonateActionThree{
    self.amountText.text = [NSString stringWithFormat:@"%.2f", self.quickDoubleThree];
    [self.parentVc calculateTotal];


}
-(IBAction)quickDonateActionFour{
    self.amountText.text = [NSString stringWithFormat:@"%.2f", self.quickDoubleFour];
    [self.parentVc calculateTotal];


    
}

- (IBAction)textEditDidBegin {
    
    double amountDouble = [self.amountText.text doubleValue];
    
    if (amountDouble == 0.0) {
        self.amountText.text = @"";
    }
    
    
}
@end
