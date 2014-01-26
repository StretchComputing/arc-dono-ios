//
//  DefaultWebViewController.h
//  Dono
//
//  Created by Nick Wroblewski on 1/25/14.
//
//

#import <UIKit/UIKit.h>

@interface DefaultWebViewController : UIViewController
- (IBAction)goBack;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *webUrl;
@end
