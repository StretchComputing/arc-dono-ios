//
//  PaymentOptionsWebViewController.h
//  Dono
//
//  Created by Nick Wroblewski on 3/7/14.
//
//

#import <UIKit/UIKit.h>

@interface PaymentOptionsWebViewController : UIViewController <UIWebViewDelegate>


- (IBAction)goBack;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *webUrl;


@end
