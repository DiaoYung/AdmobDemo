//
//  Interstitiel.m
//  DrBrain
//
//  Created by Michel Morcos on 13/07/13.
//
//

#import "Interstitiel.h"
#import "AdWebViewController.h"
#import "Reachability.h"


#define APP_NAME @"dragonjump"

@interface Interstitiel ()

@end

@implementation Interstitiel

//@synthesize adDico;

@synthesize delegate; //synthesise  MyClassDelegate delegate



-(void)removeAd
{
    [self removeFromSuperview];
    //self = nil;
}

- (IBAction)goBack
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeAd)];
    [self setAlpha:0];
    [UIView commitAnimations];
    
    
    
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
    
    // Not found
    //NSLog(@"%@ doesn't seem to have a viewController". self);
    return nil;
}

-(void) backgroundStore:(NSMutableArray *)paramArray
{
    [[paramArray objectAtIndex:0] loadProductWithParameters:[paramArray objectAtIndex:1] completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [[self viewController] presentViewController:[paramArray objectAtIndex:0] animated:YES completion:nil];
            
        } else if([paramArray count]>=3) {
            [[UIApplication sharedApplication] openURL:[paramArray objectAtIndex:2]];
        }
    }];
    
    
}

- (void)openAd
{
    
    //NSLog(@"000000 %@", adDico.description);
    
    NSString *Link = [adDico objectForKey:@"Link"];
    NSString *Itunesid = [adDico objectForKey:@"Itunesid"];
    
    NSURL *appStoreURL = [NSURL URLWithString:Link];
    
    if(![Itunesid isEqualToString:@""] && NSClassFromString(@"SKStoreProductViewController"))
    {
        //[self presentAppStoreForID:[NSNumber numberWithInt:[Itunesid intValue]] inView:self withDelegate:self withURL:nil];
        
        [loadingAlert startAnimating];
        
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = self; // productViewControllerDidFinish
        
        NSDictionary *appParameters = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[Itunesid intValue]]
                                                                  forKey:SKStoreProductParameterITunesItemIdentifier];
        
        [self performSelectorInBackground:@selector(backgroundStore:) withObject:[[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:storeController, appParameters, appStoreURL, nil]]];
        
        
    }
    else if(![Itunesid isEqualToString:@""])
        [[UIApplication sharedApplication] openURL:appStoreURL];
    else
    {
        
        //NSLog(Link);
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:Link]];
        
        AdWebViewController *viewControllerWeb = [[AdWebViewController alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        viewControllerWeb.therequest = request;
        [viewControllerWeb displaySite];
        viewControllerWeb.alpha = 0;
        [self addSubview:viewControllerWeb];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [viewControllerWeb setAlpha:1];
        [UIView commitAnimations];
        
        
        
    }
    
    
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [loadingAlert stopAnimating];
    
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) updateView:(CGRect)theFrame
{
    self.frame = theFrame;
    
    generalView.frame = theFrame;
    bgdview.frame = theFrame;
    
    adButton.frame = CGRectMake((generalView.frame.size.width-adButton.frame.size.width)/2, (generalView.frame.size.height-adButton.frame.size.height)/2, adButton.frame.size.width, adButton.frame.size.height);
    
    imgValidate.frame = CGRectMake((int)(adButton.frame.origin.x+adButton.frame.size.width-imgValidate.frame.size.width-5), (int)(adButton.frame.origin.y+adButton.frame.size.height-imgValidate.frame.size.height-5), imgValidate.frame.size.width, imgValidate.frame.size.height);
    
    closeButton.frame = CGRectMake((int)(adButton.frame.origin.x+5.0), (int)(adButton.frame.origin.y+adButton.frame.size.height-closeButton.frame.size.height-5), closeButton.frame.size.width, closeButton.frame.size.height);
    
    loadingAlert.center = self.center;
}

-(void) displaySite
{
    
    NSURL *url = [NSURL URLWithString:[adDico objectForKey:@"Image"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img0 = [[UIImage alloc] initWithData:data];
    UIImage *img;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.width > 320)
    {
        float theScale = img0.size.width / ([UIScreen mainScreen].bounds.size.width - 25.0);
        
        img = [UIImage imageWithCGImage:img0.CGImage scale:theScale orientation:img0.imageOrientation];
    }
    else
        img = [UIImage imageWithCGImage:img0.CGImage scale:2 orientation:img0.imageOrientation];
    
    generalView = [[UIView alloc] initWithFrame:self.frame];
    generalView.alpha = 0;
    
    
    bgdview = [[UIView alloc] initWithFrame:generalView.frame];
    bgdview.backgroundColor = [UIColor blackColor];
    bgdview.alpha = 0.8;
    [generalView addSubview:bgdview];
    
    adButton = [[UIButton alloc] initWithFrame:CGRectMake((generalView.frame.size.width-img.size.width)/2, (generalView.frame.size.height-img.size.height)/2, img.size.width, img.size.height)];
    
    [adButton setBackgroundColor:[UIColor clearColor]];
    [adButton setAlpha:1];
    [adButton setImage:img forState: UIControlStateNormal];
    [generalView addSubview:adButton];
    
    
    UIImage *buttonImg = [UIImage imageNamed:@"validate.png"];
    imgValidate = [[UIImageView alloc] initWithImage:buttonImg];
    imgValidate.frame = CGRectMake((int)(adButton.frame.origin.x+adButton.frame.size.width-buttonImg.size.width-5), (int)(adButton.frame.origin.y+adButton.frame.size.height-buttonImg.size.height-5), buttonImg.size.width, buttonImg.size.height);
    [generalView addSubview:imgValidate];
    
    if(imgValidate.frame.origin.y+buttonImg.size.height > self.frame.size.height)
        imgValidate.frame = CGRectMake(imgValidate.frame.origin.x, (int)(self.frame.size.height-5-imgValidate.frame.size.height), buttonImg.size.width, buttonImg.size.height);
    
    if(![[adDico objectForKey:@"Link"] isEqualToString:@""])
        [adButton addTarget:self action:@selector(openAd) forControlEvents:UIControlEventTouchUpInside];
    else
    {
        imgValidate.hidden = YES;
        [adButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    UIImage *buttonCloseImg = [UIImage imageNamed:@"close.png"];
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake((int)(adButton.frame.origin.x+5.0), (int)(adButton.frame.origin.y+adButton.frame.size.height-buttonCloseImg.size.height-5), buttonCloseImg.size.width, buttonCloseImg.size.height)];
    
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton setAlpha:1];
    [closeButton setImage:buttonCloseImg forState: UIControlStateNormal];
    [closeButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [generalView addSubview:closeButton];
    
    
    if(closeButton.frame.origin.y+closeButton.frame.size.height > self.frame.size.height)
        closeButton.frame = CGRectMake(closeButton.frame.origin.x, (int)(self.frame.size.height-5-closeButton.frame.size.height), buttonCloseImg.size.width, buttonCloseImg.size.height);
    
    
    [self addSubview:generalView];
    [self bringSubviewToFront:generalView];
    
    //[self.superview addSubview:self];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [generalView setAlpha:1];
    [UIView commitAnimations];
    
    
    
    loadingAlert = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingAlert.center = self.center;
    loadingAlert.hidesWhenStopped = YES;
    [self addSubview:loadingAlert];
    
    
    
    //NSLog(@"iiiii");
    //NSLog(@"mm %@", adDico.description);
    
    [self.delegate interstitielDidLoad:self];
    
}

-(bool) hasAd
{
    if(openAd)
        [self performSelectorInBackground:@selector(displaySite) withObject:nil];
    
    return openAd;
}

- (void) createAdBkg
{
    
    openAd = false;
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetConnectionStatus = [reachability currentReachabilityStatus];
    
    if (internetConnectionStatus != NotReachable)
    {
        
        
        NSError* error2 = nil;
        
        NSString *urlstring;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            urlstring = [NSString stringWithFormat:@"http://www.presselite.com/iphone/pushnotification/interstitiel/interstitiel_ipad.xml?app=%@",APP_NAME];
        else
            urlstring = [NSString stringWithFormat:@"http://www.presselite.com/iphone/pushnotification/interstitiel/interstitiel.xml?app=%@",APP_NAME];
        
        
        
        NSString * fileContents = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlstring] encoding:NSASCIIStringEncoding error:&error2];
        
        if(error2 == nil)
        {
            
            NSRange thetmprange = [fileContents rangeOfString:@"Id:"];
            
            while(thetmprange.location != NSNotFound)
            {
                fileContents = [fileContents substringFromIndex:thetmprange.location+3];
                thetmprange = [fileContents rangeOfString:@";"];
                NSString *adId = [fileContents substringToIndex:thetmprange.location];
                
                if([standardUserDefaults objectForKey:[NSString stringWithFormat:@"ad_%@", adId]] == nil)
                {
                    thetmprange = [fileContents rangeOfString:@"Repeat:"];
                    fileContents = [fileContents substringFromIndex:thetmprange.location+7];
                    thetmprange = [fileContents rangeOfString:@";"];
                    NSString *adRepeat = [fileContents substringToIndex:thetmprange.location];
                    
                    thetmprange = [fileContents rangeOfString:@"Link:"];
                    fileContents = [fileContents substringFromIndex:thetmprange.location+5];
                    thetmprange = [fileContents rangeOfString:@";"];
                    NSString *adLink = [fileContents substringToIndex:thetmprange.location];
                    
                    thetmprange = [fileContents rangeOfString:@"Itunesid:"];
                    fileContents = [fileContents substringFromIndex:thetmprange.location+9];
                    thetmprange = [fileContents rangeOfString:@";"];
                    NSString *adItunesid = [fileContents substringToIndex:thetmprange.location];
                    
                    thetmprange = [fileContents rangeOfString:@"Image:"];
                    fileContents = [fileContents substringFromIndex:thetmprange.location+6];
                    thetmprange = [fileContents rangeOfString:@";"];
                    NSString *adImage = [fileContents substringToIndex:thetmprange.location];
                    
                    thetmprange = [fileContents rangeOfString:@"Appname:"];
                    fileContents = [fileContents substringFromIndex:thetmprange.location+8];
                    thetmprange = [fileContents rangeOfString:@";"];
                    NSString *appName = [fileContents substringToIndex:thetmprange.location];
                    
                    adDico = [NSDictionary dictionaryWithObjectsAndKeys:
                              adId,
                              @"Id",
                              adRepeat,
                              @"Repeat",
                              adLink,
                              @"Link",
                              adItunesid,
                              @"Itunesid",
                              adImage,
                              @"Image",
                              @"1",
                              @"Display",
                              nil];
                    
                    NSURL *ourURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", appName]];
                    
                    if (![adLink isEqualToString:@""] && ![[UIApplication sharedApplication] canOpenURL:ourURL]) {
                        
                        [standardUserDefaults setObject:adDico forKey:[NSString stringWithFormat:@"ad_%@", adId]];
                        [standardUserDefaults synchronize];
                        
                        adDico = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"ad_%@", adId]];
                        
                        openAd = true;
                        
                        //[self interstitielDisplay:adDico];
                        [self displaySite];
                        
                        break;
                    }
                    
                    
                }
                else
                {
                    adDico = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"ad_%@", adId]];
                    
                    int repeat = [[adDico objectForKey:@"Repeat"] intValue];
                    int display = [[adDico objectForKey:@"Display"] intValue];
                    
                    if(display < repeat)
                    {
                        display++;
                        [adDico setValue:[NSString stringWithFormat:@"%d",display] forKey:@"Display"];
                        
                        [standardUserDefaults setObject:adDico forKey:[NSString stringWithFormat:@"ad_%@", adId]];
                        [standardUserDefaults synchronize];
                        
                        openAd = true;
                        
                        //[self interstitielDisplay:adDico];
                        [self displaySite];
                        
                        //[rootViewController interstitielDidLoad:this];
                        
                        break;
                        
                    }
                }
                
                
                thetmprange = [fileContents rangeOfString:@"Id:"];
                
            }
            
        }
        
    }
}

- (void) createAd
{
    [self performSelectorInBackground:@selector(createAdBkg) withObject:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        [self performSelectorInBackground:@selector(createAdBkg) withObject:nil];
        
        /*
         
         NetworkStatus internetConnectionStatus;
         internetConnectionStatus = [[Reachability sharedReachability] internetConnectionStatus];
         
         openAd = false;
         
         if (internetConnectionStatus != NotReachable)
         {
         
         
         NSError* error2 = nil;
         
         //NSString *urlstring = @"http://www.presselite.com/iphone/pushnotification/interstitiel/interstitiel.xml";
         NSString *urlstring = @"http://www.cinema-france.com/iphone/interstitiel.xml";
         NSString * fileContents = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlstring] encoding:NSASCIIStringEncoding error:&error2];
         
         //NSLog(@"mm %@", error2.description);
         
         if(error2 == nil)
         {
         
         NSRange thetmprange = [fileContents rangeOfString:@"Id:"];
         
         while(thetmprange.location != NSNotFound)
         {
         
         fileContents = [fileContents substringFromIndex:thetmprange.location+3];
         thetmprange = [fileContents rangeOfString:@";"];
         NSString *adId = [fileContents substringToIndex:thetmprange.location];
         
         if([standardUserDefaults objectForKey:[NSString stringWithFormat:@"ad_%@", adId]] == nil)
         {
         
         thetmprange = [fileContents rangeOfString:@"Repeat:"];
         fileContents = [fileContents substringFromIndex:thetmprange.location+7];
         thetmprange = [fileContents rangeOfString:@";"];
         NSString *adRepeat = [fileContents substringToIndex:thetmprange.location];
         
         thetmprange = [fileContents rangeOfString:@"Link:"];
         fileContents = [fileContents substringFromIndex:thetmprange.location+5];
         thetmprange = [fileContents rangeOfString:@";"];
         NSString *adLink = [fileContents substringToIndex:thetmprange.location];
         
         thetmprange = [fileContents rangeOfString:@"Itunesid:"];
         fileContents = [fileContents substringFromIndex:thetmprange.location+9];
         thetmprange = [fileContents rangeOfString:@";"];
         NSString *adItunesid = [fileContents substringToIndex:thetmprange.location];
         
         thetmprange = [fileContents rangeOfString:@"Image:"];
         fileContents = [fileContents substringFromIndex:thetmprange.location+6];
         thetmprange = [fileContents rangeOfString:@";"];
         NSString *adImage = [fileContents substringToIndex:thetmprange.location];
         
         adDico = [NSDictionary dictionaryWithObjectsAndKeys:
         adId,
         @"Id",
         adRepeat,
         @"Repeat",
         adLink,
         @"Link",
         adItunesid,
         @"Itunesid",
         adImage,
         @"Image",
         @"1",
         @"Display",
         nil];
         
         [standardUserDefaults setObject:adDico forKey:[NSString stringWithFormat:@"ad_%@", adId]];
         [standardUserDefaults synchronize];
         
         adDico = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"ad_%@", adId]];
         
         openAd = true;
         
         
         
         //[self interstitielDisplay:adDico];
         //[self displaySite];
         
         
         break;
         }
         else
         {
         adDico = [standardUserDefaults objectForKey:[NSString stringWithFormat:@"ad_%@", adId]];
         
         int repeat = [[adDico objectForKey:@"Repeat"] intValue];
         int display = [[adDico objectForKey:@"Display"] intValue];
         
         if(display < repeat)
         {
         display++;
         [adDico setValue:[NSString stringWithFormat:@"%d",display] forKey:@"Display"];
         
         [standardUserDefaults setObject:adDico forKey:[NSString stringWithFormat:@"ad_%@", adId]];
         [standardUserDefaults synchronize];
         
         openAd = true;
         
         //[self interstitielDisplay:adDico];
         //[self displaySite];
         
         break;
         
         }
         }
         
         
         thetmprange = [fileContents rangeOfString:@"Id:"];
         
         }
         
         }
         
         }
         
         */
        
        // if(!openAd)
        //  [self removeAd];
        
    }
    return self;
}



@end
