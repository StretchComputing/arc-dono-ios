//
//  LoadingViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 2/21/13.
//
//

#import "LoadingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcAppDelegate.h"
#import "TJSpinner.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

-(void)viewDidLoad{
    
    
    self.mainBackView.layer.cornerRadius = 3.0;
    self.mainBackView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.mainBackView.layer.borderWidth = 1.0;
    
    
    self.mainBackView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.mainBackView.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
    self.mainBackView.layer.shadowOpacity = .5f;
    self.mainBackView.layer.shadowRadius = 10.0f;
    
    
    //iconimageview
    //mainbackview
    TJSpinner *circularSpinner = [[TJSpinner alloc] initWithSpinnerType:kTJSpinnerTypeCircular];
 
    circularSpinner.hidesWhenStopped = NO;
    circularSpinner.radius = 10;
    circularSpinner.pathColor = [UIColor whiteColor];
    circularSpinner.fillColor = [UIColor orangeColor];
    circularSpinner.thickness = 4;
    [circularSpinner startAnimating];

    
    
    
    circularSpinner.frame = self.iconImageView.frame;
    
    [self.mainBackView insertSubview:circularSpinner aboveSubview:self.iconImageView];

    self.iconImageView.hidden = YES;
    
 //   [self runSpinAnimationOnView:self.iconImageView duration:1.0 rotations:1.0 repeat:200.0];
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 2.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)startSpin{
    //[self.iconImageView.layer removeAllAnimations];
    self.view.hidden = NO;
    //[self runSpinAnimationOnView:self.iconImageView duration:1.0 rotations:1.0 repeat:200.0];

}
-(void)stopSpin{
    self.view.hidden = YES;
   // [self.iconImageView.layer removeAllAnimations];
}
- (void)viewDidUnload {
    [self setIconImageView:nil];
    [super viewDidUnload];
}
@end
