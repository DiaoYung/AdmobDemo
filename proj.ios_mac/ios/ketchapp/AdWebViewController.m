//
//  AdWebViewController.m
//
//  Created by Antoine Morcos on 20/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AdWebViewController.h"


@implementation AdWebViewController


@synthesize backButton, nextButton, therequest, theWebView;

UIActivityIndicatorView *loadingAlert;



UIToolbar *toolbar;


- (IBAction)goBack
{

	theWebView.delegate = nil;
    theWebView = nil;
    
	[self removeFromSuperview];

}

-(void) displaySite
{
	[theWebView loadRequest:therequest];
	theWebView.delegate = self;
}

-(IBAction) pageBack
{
	[theWebView goBack];
}

-(IBAction) pageNext
{
	[theWebView goForward];
}


-(IBAction) refresh
{
    
}

-(void) changeSize:(CGRect)frame
{
    self.frame = frame;
	theWebView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height-45);
	toolbar.frame = CGRectMake(0, frame.size.height-45, frame.size.width, 45.0f);
	loadingAlert.center = CGPointMake(frame.size.width/2, frame.size.height/2);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
        
		theWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-45)];
		theWebView.userInteractionEnabled = YES;
		theWebView.multipleTouchEnabled = YES;
		theWebView.scalesPageToFit = YES;
		[self addSubview:theWebView];
		
		toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, frame.size.height-45, frame.size.width, 45.0f)];
		toolbar.barStyle = UIBarStyleDefault;
        toolbar.translucent = false;
		
		
		UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
		
		UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(goBack)];
		[closeButton setStyle:UIBarButtonItemStylePlain];
		
		
		backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"up.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pageBack)];
		nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"down.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pageNext)];
		
		backButton.enabled = NO;
		nextButton.enabled = NO;
		
		
		[toolbar setItems:[NSArray arrayWithObjects:spaceButton, backButton,spaceButton,nextButton,spaceButton, closeButton, nil]];
		
		[self addSubview: toolbar];
		
		
		loadingAlert = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		loadingAlert.center = CGPointMake(frame.size.width/2, frame.size.height/2);
		
		loadingAlert.hidesWhenStopped = YES;
		[self addSubview:loadingAlert];
		
		
        
	}
	
	return self;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
	[loadingAlert startAnimating];
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	
	if([theWebView  canGoBack])
		backButton.enabled = YES;
	else
		backButton.enabled = NO;
	
	if([theWebView  canGoForward])
		nextButton.enabled = YES;
	else
		nextButton.enabled = NO;
	
	[loadingAlert stopAnimating];
	
}



-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES; //(interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}



- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	

    [loadingAlert startAnimating];
    
    
	NSURL *theUrl = request.URL;
	NSString *urlStringLink = theUrl.description;
    
    NSRange range = [urlStringLink rangeOfString :@"phobos.apple.com"];
    
 
    if (range.location != NSNotFound)
    {
        
        NSArray * pairs = [urlStringLink componentsSeparatedByString:@"&"];
        NSArray * bits = [[pairs objectAtIndex:0] componentsSeparatedByString:@"="];
        
        NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        
        [self presentAppStoreForID:[NSNumber numberWithInt:[value intValue]] inView:self withDelegate:self withURL:request.URL];
        
        return NO;
    }
    else
    {
        return YES;
    }
    

    
}

- (UIViewController *)viewController
{
    for (UIResponder * nextResponder = self.nextResponder;
         nextResponder;
         nextResponder = nextResponder.nextResponder)
    {
        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController *)nextResponder;
    }
    

    return nil;
}

-(void) backgroundStore:(NSMutableArray *)paramArray
{
    [[paramArray objectAtIndex:0] loadProductWithParameters:[paramArray objectAtIndex:1] completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [[self viewController] presentViewController:[paramArray objectAtIndex:0] animated:YES completion:nil];
           
            
        } else {
         
            [loadingAlert stopAnimating];
            [[UIApplication sharedApplication] openURL:[paramArray objectAtIndex:2]];
        }
    }];
    
    
}

- (void)presentAppStoreForID:(NSNumber *)appStoreID inView:(UIView *)view withDelegate:(id<SKStoreProductViewControllerDelegate>)delegate withURL:(NSURL *)appStoreURL
{
    
    if(NSClassFromString(@"SKStoreProductViewController")) { // Checks for iOS 6 feature.
        
        
        
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = delegate; // productViewControllerDidFinish
        
        
        NSDictionary *appParameters = [NSDictionary dictionaryWithObject:appStoreID
                                                                  forKey:SKStoreProductParameterITunesItemIdentifier];
        
        [self performSelectorInBackground:@selector(backgroundStore:) withObject:[[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:storeController, appParameters, appStoreURL, nil]]];
        
        
        
    } else { // Before iOS 6, we can only open the URL
        
        
        [[UIApplication sharedApplication] openURL:appStoreURL];
        
    }
    
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
    [loadingAlert stopAnimating];
}




@end
