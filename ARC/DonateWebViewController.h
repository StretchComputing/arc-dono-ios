//
//  DonateWebViewController.h
//  Dono
//
//  Created by Nick Wroblewski on 2/9/14.
//
//

#import <UIKit/UIKit.h>

@interface DonateWebViewController : UIViewController <UIWebViewDelegate>


@property (nonatomic, strong) NSString *webUrl;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@end
