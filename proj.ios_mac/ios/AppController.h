#import <UIKit/UIKit.h>
//#import "GADBannerView.h"
#import "GameCenterManager.h"
#import <StoreKit/StoreKit.h>
#import "WXApi.h"
#import <HeyzapAds/HeyzapAds.h>
#import "Interstitiel.h"
#import <iAd/iAd.h>

@class RootViewController;

@interface AppController : NSObject <UIApplicationDelegate,UIAlertViewDelegate,GameCenterManagerDelegate,UIDocumentInteractionControllerDelegate,SKPaymentTransactionObserver,WXApiDelegate,HZIncentivizedAdDelegate,InterstitielDelegate> {
    UIWindow *window;
    UIView *overLayerView;
    int requestFullScreenTimes;
    NSDictionary *gameInfoDict;
    NSString *meText;
    NSString *imagePath;
    HZBannerAd *_hzBanner;
    BOOL shouldShowBanner;
}

@property(nonatomic, readonly) RootViewController* viewController;
@property (nonatomic, strong) GameCenterManager *gameCenterManager;
@property(strong,nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

