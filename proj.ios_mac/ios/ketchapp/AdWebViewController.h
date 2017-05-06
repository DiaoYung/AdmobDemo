//
//  AdWebViewController.h
//
//  Created by Antoine Morcos on 20/07/10.
//

#import <UIKit/UIKit.h>
#import <StoreKit/SKStoreProductViewController.h>

@interface AdWebViewController : UIView <UIWebViewDelegate,SKStoreProductViewControllerDelegate> {
    
	IBOutlet NSURLRequest *therequest;
	IBOutlet UIWebView *theWebView;
	
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *nextButton;
}

@property(nonatomic,retain) UIBarButtonItem *backButton;
@property(nonatomic,retain) UIBarButtonItem *nextButton;

@property(nonatomic,retain) NSURLRequest *therequest;
@property(nonatomic,retain) UIWebView *theWebView;


-(void) displaySite;
-(void) changeSize:(CGRect)frame;

- (IBAction)goBack;
-(IBAction) pageBack;
-(IBAction) pageNext;


@end
