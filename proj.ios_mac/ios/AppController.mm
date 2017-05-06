/****************************************************************************
 Copyright (c) 2010 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "AppController.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import <GameKit/GameKit.h>
#import "RootViewController.h"
#import "iRate.h"
#import "MobClick.h"
#import "IAPManager.h"
#import "SVProgressHUD.h"
#import <Social/Social.h>

#include "IOSNDKHelper.h"

#import "MixView.h"

#import <objc/runtime.h>
#import <objc/message.h>

#define kChartBoostAppID_iOS @"5513d6330d6025619ee4d9ec"
#define kChartBoostAppSignature_iOS @"e1bd2da9fe7387f0dc0f7564c1c310cece8c9a2a"

#define kMobClickID @"55125bd9fd98c5703b0006f0"
#define kAppID 992473095
#define kGameCenterBestID @"dragonjump.best"
#define kAppNameEN @"Dragon Jump"
#define kAppNameCN @"龙之跃"
#define kNO_ADS_ID @"dragonjump.noads"
#define kUnlockID @"ad35saf5wgewetrc3c5n"
#define kUMENG_param_fullscreen_rate_key @"fullscreenRate"

#define kADMOB_FULLSCREEN_ID @"ca-app-pub-2641376718074288/8051694852"
#define kAdmobID @"ca-app-pub-2641376718074288/9528428057"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation AppController

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 0.5;
    [iRate sharedInstance].usesUntilPrompt = 4;
    [iRate sharedInstance].appStoreID = kAppID;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Override point for customization after application launch.
    if ([GameCenterManager isGameCenterAvailable]) {
        if([GKLocalPlayer localPlayer].authenticated == NO){
            self.gameCenterManager = [[GameCenterManager alloc] init];
            [self.gameCenterManager setDelegate:self];
            [self.gameCenterManager authenticateLocalUser];
        }
    } else {
    }
    

    CGRect r = [[UIScreen mainScreen] bounds];
    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame:r];
    NSLog(@"rect is %@",NSStringFromCGRect([window bounds]));
    [MobClick startWithAppkey:kMobClickID];
    
    [MobClick updateOnlineConfig];
    // Init the CCEAGLView
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [window bounds]
                                     pixelFormat: kEAGLColorFormatRGB565
                                     depthFormat: GL_DEPTH24_STENCIL8_OES
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples: 0];
     [eaglView setMultipleTouchEnabled:YES];

    // Use RootViewController manage CCEAGLView 
    _viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    _viewController.wantsFullScreenLayout = YES;
    //UIView *view = [[UIView alloc] init];
    //[view addSubview:eaglView];
    _viewController.view = eaglView;
    
    [WXApi registerApp:@"wx23ae9add767b91ee"];

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: _viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:_viewController];
    }

    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden:true];
    
    
//    if([[NSLocale preferredLanguages][0] rangeOfString:@"zh"].location!=NSNotFound){
//        [MIXView initWithID:@"6bf6ab37c4cd9337"];
//        [MIXView preloadAdWithDelegate:self withPlace:@"default"];
//    }

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);

    cocos2d::Application::getInstance()->run();
    
    [IOSNDKHelper SetNDKReciever:self];
    
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
        Method ori_Method =  class_getInstanceMethod([ADInterstitialAd class], @selector(init));
        Method my_Method = class_getInstanceMethod([ADInterstitialAd class], @selector(initCustom));
        method_exchangeImplementations(ori_Method, my_Method);
    }
    
    requestFullScreenTimes = 0;
//    @try {
//        ADInterstitialAd *dsw = [[ADInterstitialAd alloc] init];
//    } @catch (NSException * e) {
//        NSLog(@"cant load iad");
//    }
    
    //ADInterstitialAd *dsw = [[ADInterstitialAd alloc] init];
    
    [HeyzapAds startWithPublisherID:@"ff4d63e68db9518cacc9a4b5d8e375d8"];

    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"m_data"] isEqualToString:kUnlockID]){
        [self setupBanner];
    }
    
//    [HeyzapAds setDebugLevel:HZDebugLevelInfo];
    
    shouldShowBanner = NO;
    
    return YES;
}


-(void)setupBanner{
    
    overLayerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.viewController.view addSubview:overLayerView];
    
    CGRect rc = [UIScreen mainScreen].bounds;
    HZBannerAdOptions *options = [[HZBannerAdOptions alloc] init];
    [options setPresentingViewController:_viewController];
    [HZBannerAd requestBannerWithOptions:options success:^(HZBannerAd *banner) {
        [overLayerView insertSubview:banner atIndex:0];
        [banner setCenter:CGPointMake(rc.size.width/2., rc.size.height-[banner frame].size.height/2.)];
        _hzBanner = banner;
        _hzBanner.hidden = !shouldShowBanner;
    } failure:^(NSError *error) {
        NSLog(@"Error = %@",error);
    }];
    
    Interstitiel *theAd = [[Interstitiel alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    theAd.delegate = self;

}

-(void)showBanner:(NSObject*)prms{
    shouldShowBanner = YES;
    [self updateBannerState];
}

-(void)resetInterstitials:(NSObject*)prms{
    requestFullScreenTimes = 0;
}

-(void)updateBannerState{
    if(_hzBanner&&[_hzBanner superview]&&shouldShowBanner){
        _hzBanner.hidden = NO;
    }
}


-(void)sendGameInfoToLocal:(NSObject*)prms{
    if(gameInfoDict){
        [gameInfoDict release];
        gameInfoDict = nil;
    }
    NSDictionary *parameters = (NSDictionary*)prms;
    gameInfoDict = parameters;
    [gameInfoDict retain];
}

-(void)ios_checkIfNoAds:(NSObject *)prms{
    NSString  *shouldShareGetCoin = @"";
    if([[MobClick getConfigParams:@"sks"] isEqualToString:@"y"]){
        shouldShareGetCoin = @"yes";
    }
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"m_data"] isEqualToString:kUnlockID]){
        [IOSNDKHelper SendMessage:@"ios_callBack_checkIfNoAds_yes" WithParameters:@{@"buyDone":@"yes"}];
    }else{
        [IOSNDKHelper SendMessage:@"ios_callBack_checkIfNoAds_yes" WithParameters:nil];
    }
}

-(void)popShare:(NSObject *)prms{
    NSDictionary *parameters = (NSDictionary*)prms;
    NSLog(@"Passed params are : %@", parameters);
    NSString *ss = (NSString*)[parameters objectForKey:@"word"];
    NSString *target = (NSString*)[parameters objectForKey:@"target"];
    NSString *path = (NSString*)[parameters objectForKey:@"path"];
    NSString *successCallBack = (NSString*)[parameters objectForKey:@"successCallBack"];
    //    if([[NSLocale preferredLanguages][0] rangeOfString:@"zh"].location!=NSNotFound){
    //        target = @"weixin";
    //    }
    
    if(!target||target.length<1){
        
        NSMutableArray *sharingItems = [[NSMutableArray alloc] init];
        [ss retain];
        [sharingItems addObject:ss];
        if([path length]>0){
            [sharingItems addObject:[UIImage imageNamed:path]];
        }
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [_viewController presentViewController:activityController animated:YES completion:nil];
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")&&UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            NSObject *obj = [activityController performSelector:@selector(popoverPresentationController) withObject:nil];
            [obj performSelector:@selector(setSourceView:) withObject:_viewController.view];
            //            UIPopoverPresentationController *presentationController =
            //            [activityController popoverPresentationController];
            //            presentationController.sourceView = _viewController.view;
            
        }
    }else if([target isEqualToString:@"weixin"]){
    }
}

-(void)buyNOADs:(NSObject *)prms{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[IAPManager sharedIAPManager] purchaseProductForId:kNO_ADS_ID
                                             completion:^(SKPaymentTransaction *transaction) {
                                                 
                                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                 [SVProgressHUD dismiss];
                                                 [IOSNDKHelper SendMessage:@"buySuccess" WithParameters:@{@"buyDone":@YES}];
                                                 [self removeAdsForever];
                                             } error:^(NSError *err) {
                                                 [IOSNDKHelper SendMessage:@"buySuccess" WithParameters:nil];
                                                 [SVProgressHUD dismiss];
                                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                 NSLog(@"An error occured while purchasing: %@", err.localizedDescription);
                                             }];
}

-(void)removeAdsForever{

    [[NSUserDefaults standardUserDefaults] setObject:kUnlockID forKey:@"m_data"];
    if(_hzBanner&&[_hzBanner superview]){
        [_hzBanner removeFromSuperview];
        _hzBanner = NULL;
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
    }
    if ([purchasedItemIDs containsObject:kNO_ADS_ID] ) {
        [self removeAdsForever];
        [IOSNDKHelper SendMessage:@"buySuccess" WithParameters:@{@"buyDone":@YES}];
    }else{
        [IOSNDKHelper SendMessage:@"buySuccess" WithParameters:nil];
    }
    [SVProgressHUD dismiss];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"Restore Failed"];
}


-(void)restorePurchases:(NSObject *)prms{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [SVProgressHUD showWithStatus:@"Connecting" maskType:SVProgressHUDMaskTypeGradient];
}


-(void)getOnlineParams:(NSObject *)prms{
    NSDictionary *dict = [MobClick getConfigParams];
    [dict retain];
    [IOSNDKHelper SendMessage:@"receiveOnlinParams" WithParameters:dict];
}

-(void)openLink:(NSObject *)prms{
    NSDictionary *parameters = (NSDictionary*)prms;
    NSString *link = [parameters objectForKey:@"link"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

-(void)openKetchappFacebook:(NSObject *)prms{
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/503287153144438"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/503287153144438"]];
    }
}

-(void)openFacebook:(NSObject *)prms{
//    [HeyzapAds presentMediationDebugViewController];
//    return;
        NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/826105720734980"];
        if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
            [[UIApplication sharedApplication] openURL:facebookURL];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/lemonjamstudio"]];
        }
}

-(void)openTwitter:(NSObject *)prms{
    if([[NSLocale preferredLanguages][0] rangeOfString:@"zh"].location!=NSNotFound){
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://weibo.com/5208389604"]];
    }else{
        NSURL *urlApp = [NSURL URLWithString:[NSString stringWithFormat:@"%@",@"twitter:///user?screen_name=lemonjamstudio"]];
        if ([[UIApplication sharedApplication] canOpenURL:urlApp]){
            [[UIApplication sharedApplication] openURL:urlApp];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/lemonjamstudio"]];
        }
    }
}

-(void)openOurApps:(NSObject *)prms{
//    828687666
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/artist/zhipeng-wang/id884737211"]];
}

-(void)moreApps:(NSObject *)prms{
//        [[Chartboost sharedChartboost] cacheMoreApps:CBLocationHomeScreen];
//        [[Chartboost sharedChartboost] showMoreApps:CBLocationHomeScreen];
}

-(void)popRate:(NSObject *)prms{
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

-(void)popRank:(NSObject *)prms{
    if([GameCenterManager isGameCenterAvailable]){
        GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
        GKLocalPlayer *localplayer = [GKLocalPlayer localPlayer];
        [localplayer authenticateWithCompletionHandler:^(NSError *error) {
            [localplayer authenticateWithCompletionHandler:nil];
            if (error) {
                //DISABLE GAME CENTER FEATURES / SINGLEPLAYER
                UIAlertView *alert;
                if([[NSLocale preferredLanguages][0] rangeOfString:@"zh"].location!=NSNotFound){
                    alert = [[UIAlertView alloc] initWithTitle:@"进入失败" message:@"请登录GameCenter之后再试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                }else{
                    alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please log in to GameCenter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                }
                [alert show];
            }
            else {
                //ENABLE GAME CENTER FEATURES / MULTIPLAYER
                if (leaderboardController != NULL)
                {
                    leaderboardController.category = kGameCenterBestID;
                    leaderboardController.timeScope = GKLeaderboardTimeScopeWeek;
                    leaderboardController.leaderboardDelegate = (id)self;
                    [_viewController presentViewController:leaderboardController animated: YES completion:^{
                        
                    }];
                }
            }
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Unable to enter GameCenter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    };

}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self showFullScreenAds:nil];
    [_viewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)showFullScreenAds:(NSObject *)prms{

    requestFullScreenTimes++;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"m_data"] isEqualToString:kUnlockID]||requestFullScreenTimes%6!=0){
        return;
    }
    [HZInterstitialAd show];
}

- (void) interstitielDidLoad:(Interstitiel*) theInterstitiel
{
    [overLayerView addSubview:theInterstitiel];
    [overLayerView bringSubviewToFront:theInterstitiel];
    
    //PUT THE GAME ON PAUSE IF NECESSARY
}


-(void)logInUmeng:(NSObject *)prms{
    NSString *link = [prms objectForKey:@"event"];
    if(link&&link.length>0){
        NSString *sub = [prms objectForKey:@"sub"];
        if([sub length]>0){
            [MobClick event:link label:sub];
        }else{
           [MobClick event:link];
        }
    }
}

-(void)reportScore:(NSObject *)prms{
    if(prms!=nil){
        NSDictionary *parameters = (NSDictionary*)prms;
        NSLog(@"Passed params are : %@", parameters);
        int bestLevel = [[parameters objectForKey:@"best"] intValue];
        
        if ([GameCenterManager isGameCenterAvailable]) {
            //total time
            if(bestLevel!=0)[self.gameCenterManager reportScore:bestLevel forCategory:kGameCenterBestID];
        }
    }
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:40];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, image.size.height-180, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    //    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"Done", nil)
    //                                                   message:NSLocalizedString(@"", nil)];
    //    [alert show];
}


-(void)popWindow:(NSObject *)prms{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"hey" message:@"won" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if(buttonIndex == alertView.cancelButtonIndex){
//        [IOSNDKHelper SendMessage:@"callBackFromNative" WithParameters:nil];
//    }
//}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
     //We don't need to call this method any more. It will interupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->pause(); */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
     //We don't need to call this method any more. It will interupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->resume(); */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    /**
    if(![[[NSUserDefaults standardUserDefaults] stringForKey:@"UD"] isEqualToString:@"wft4d32r3t24r233fewdh654gd"]){
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 24];
        //notification.fireDate = [[NSDate date] dateByAddingTimeInterval:20];
        if([[NSLocale preferredLanguages][0] rangeOfString:@"zh"].location!=NSNotFound){
            notification.alertBody = @"5个心已经恢复完成!快来银河漫游者与朋友PK";
        }else{
            notification.alertBody = @"Come back and play Galaxy Walker! Hearts are full.";
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
     **/
    
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


-(void)share:(NSObject*)prms{
    
    NSString *type = [prms objectForKey:@"type"];
    NSString *text = [prms objectForKey:@"text"];
    imagePath = [prms objectForKey:@"imagePath"];
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
        NSMutableArray *sharingItems = [[[NSMutableArray alloc] init] autorelease];
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if([language rangeOfString:@"zh"].location==NSNotFound&&[language rangeOfString:@"fr"].location==NSNotFound&&[language rangeOfString:@"pt"].location==NSNotFound){
            text = [NSString stringWithFormat:@"%@ Can you beat me? ",text];
        }
        NSString *sdas =[NSString stringWithFormat:@"%@https://itunes.apple.com/app/dragon-jump/id992473095",text];
        
            [sharingItems addObject:sdas];
        //[sharingItems addObject:[UIImage imageNamed:imagePath]];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [_viewController presentViewController:activityController animated:YES completion:nil];
        return;
    }
    
    if([type isEqualToString:@"fb"]){
        
        NSMutableArray *sharingItems = [[NSMutableArray alloc] init];
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if([language rangeOfString:@"zh"].location==NSNotFound&&[language rangeOfString:@"fr"].location==NSNotFound&&[language rangeOfString:@"pt"].location==NSNotFound){
            text = [NSString stringWithFormat:@"%@ Can you beat me? ",text];
        }
        NSString *sdas =[NSString stringWithFormat:@"%@https://itunes.apple.com/app/dragon-jump/id992473095",text];
        
        [sharingItems addObject:sdas];
        if([imagePath length]>0){
            UIImage *img = [[UIImage alloc] initWithContentsOfFile:imagePath];
            if(img){
                [sharingItems addObject:img];
            }
        }
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [_viewController presentViewController:activityController animated:YES completion:nil];
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")&&UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            NSObject *obj = [activityController performSelector:@selector(popoverPresentationController) withObject:nil];
            [obj performSelector:@selector(setSourceView:) withObject:_viewController.view];
            //            UIPopoverPresentationController *presentationController =
            //            [activityController popoverPresentationController];
            //            presentationController.sourceView = _viewController.view;
            
        }
        return;
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeFacebook];
        //NSString *sdas =[NSString stringWithFormat:@"%@https://itunes.apple.com/app/dragon-jump/id992473095",text];
        [composeController setInitialText:sdas];
        [composeController addImage:[UIImage imageNamed:imagePath]];
        
        [_viewController presentViewController:composeController
                                      animated:YES completion:nil];
    }else if([type isEqualToString:@"twitter"]){
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:[NSString stringWithFormat:@"%@https://itunes.apple.com/app/dragon-jump/id992473095",text]];
        [composeController addImage:[UIImage imageNamed:imagePath]];
        
        [_viewController presentViewController:composeController
                                      animated:YES completion:nil];
    }else if([type isEqualToString:@"weibo"]){
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        
        [composeController setInitialText:[NSString stringWithFormat:@"%@ https://itunes.apple.com/app/dragon-jump/id992473095",text]];
        [composeController addImage:[UIImage imageNamed:imagePath]];
        
        [_viewController presentViewController:composeController
                                      animated:YES completion:nil];
    }
    else if([type isEqualToString:@"weixin"]){
        if([WXApi isWXAppInstalled]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享到微信"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"朋友圈",@"好友",nil];
            [alert show];
            [alert release];
            meText = [NSString stringWithFormat:@"%@",text];
            [meText retain];
            [imagePath retain];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:@"没有安装微信"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    int scene = WXSceneSession;
    if(buttonIndex==alertView.cancelButtonIndex){
        return;
    }
    if(buttonIndex==1){
        scene = WXSceneTimeline;
        
        WXMediaMessage *message = [WXMediaMessage message];
//        [message setThumbImage:[UIImage imageNamed:imagePath]];
        
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSData dataWithContentsOfFile:imagePath];
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        
        [WXApi sendReq:req];
        [imagePath release];
        [meText retain];
    }else{
        scene = WXSceneSession;
        
        WXMediaMessage *message = [WXMediaMessage message];
        UIImage *ori = [UIImage imageNamed:imagePath];
        UIImage *scaledImage = [self scaleImage:ori ProportionalToSize:CGSizeMake(200, 200)];
        [message setThumbImage:scaledImage];
        
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSData dataWithContentsOfFile:imagePath];
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        
        [WXApi sendReq:req];
        [imagePath release];
        [meText retain];
    }
}

- (UIImage *) scaleImage:(UIImage*)img ProportionalToSize: (CGSize)size1
{
    if(img.size.width>img.size.height)
    {
        NSLog(@"LandScape");
        size1=CGSizeMake((img.size.width/img.size.height)*size1.height,size1.height);
    }
    else
    {
        NSLog(@"Potrait");
        size1=CGSizeMake(size1.width,(img.size.height/img.size.width)*size1.width);
    }
    
    return [self scaleImage:img ToSize:size1];
}

- (UIImage *) scaleImage:(UIImage*)img ToSize: (CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(img.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), img.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), img.CGImage);
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage: scaledImage];
    
    CGImageRelease(scaledImage);
    
    return image;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
}


-(void)showInCenAds:(NSObject *)prms{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [HZIncentivizedAd setDelegate:self];
    
    [HZIncentivizedAd fetchWithCompletion:^(BOOL result, NSError *error) {
        if(!error){
            [HZIncentivizedAd show];
            [SVProgressHUD dismiss];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error fetching ad"];
        }
    }];
}

- (void) didCompleteAdWithTag: (NSString *)tag {
    [IOSNDKHelper SendMessage:@"incentivizedAdShown" WithParameters:@{@"done":@"yes"}];
}

- (void) didFailToCompleteAdWithTag: (NSString *)tag {
    // When user fails to watch the incentivized video all the way through
    [IOSNDKHelper SendMessage:@"incentivizedAdShown" WithParameters:@{@"done":@"yes"}];
}


@end
