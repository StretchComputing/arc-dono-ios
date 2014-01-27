//
//  InitTutorialPageViewController.h
//  Dono
//
//  Created by Nick Wroblewski on 1/26/14.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import "LoadingViewController.h"
#import "SteelfishBoldButton.h"
@interface InitTutorialPageViewController : UIViewController <UIScrollViewDelegate>


@property (strong, nonatomic) IBOutlet UIView *helpView;
@property BOOL isGoingPrivacyTerms;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property BOOL doesHaveGuestToken;
@property BOOL didPushStart;
@property BOOL guestTokenError;
@property BOOL didFailToken;
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage1;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage2;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *startUsingButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage3;
@property (strong, nonatomic) IBOutlet UIView *topLine;
@property (strong, nonatomic) IBOutlet UIView *bottomLine;
@property (strong, nonatomic) IBOutlet UIView *vertLine1;
@property (strong, nonatomic) IBOutlet UIView *vertLine2;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *termsButton;
- (IBAction)termsAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *privacyButton;
- (IBAction)privacyAction;
@property (strong, nonatomic) IBOutlet SteelfishBoldButton *skipButton;



@end
