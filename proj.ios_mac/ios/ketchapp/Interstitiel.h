//
//  Interstitiel.h
//  DrBrain
//
//  Created by Michel Morcos on 13/07/13.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/SKStoreProductViewController.h>

@class Interstitiel;             //define class, so protocol can see MyClass
@protocol InterstitielDelegate   //define delegate protocol
- (void) interstitielDidLoad: (Interstitiel *) sender;  //define delegate method to be implemented within another class
@end //end protocol

@interface Interstitiel : UIView <SKStoreProductViewControllerDelegate>
{
    
	NSDictionary *adDico;
    
    NSUserDefaults *standardUserDefaults;
    
    bool openAd;
    
    UIActivityIndicatorView *loadingAlert;
    
    UIView *generalView;
    UIView *bgdview;
    UIButton *adButton;
    UIImageView *imgValidate;
    UIButton *closeButton;
    
}

//@property (nonatomic, assign) UIViewController *rootViewController;

@property (nonatomic, assign) id <InterstitielDelegate> delegate; //define MyClassDelegate as delegate



//@property(nonatomic,retain) NSDictionary *adDico;

-(void) updateView:(CGRect)theFrame;
-(void) displaySite;
-(bool) hasAd;
- (void) createAd;

@end
