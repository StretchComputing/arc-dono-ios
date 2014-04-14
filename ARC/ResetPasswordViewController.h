//
//  ResetPasswordViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 10/15/12.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import "LoadingViewController.h"

@class LoadingViewController;

@interface ResetPasswordViewController : UIViewController

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UITextField *passcodeText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmText;
- (IBAction)submitAction;
@property BOOL isInitial;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;

@property (nonatomic, strong) NSString *emailAddress;
@property (strong, nonatomic) IBOutlet UIButton *backAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *submitButton;
- (IBAction)goBackAction;

@end
