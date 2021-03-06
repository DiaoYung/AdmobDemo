//
//  MIXView.h
//  GuoHeMixiOSDev
//
//  Created by Lynn Woo on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "MIXViewDelegate.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
// We need store kit to use the product view controller.
#import <StoreKit/StoreKit.h>
#endif
@class MIXCacheHandler;

@interface MIXView:UIView
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
 <UIWebViewDelegate,SKStoreProductViewControllerDelegate>
#else
 <UIWebViewDelegate>
#endif

// 初始化推广橱窗
+ (MIXView *)initWithID:(NSString *)adUnitId;

// 展示推广橱窗及广告
+ (void)showAdWithDelegate:(id) delegate;

// 根据广告触发位展示推广橱窗及广告
+ (void)showAdWithDelegate:(id)delegate withPlace:(NSString *)place;

// 停止推广橱窗请求及展示
+ (void)dismissAd;

// 检查预加载是否完成
+ (BOOL)canServeAd:(NSString *)place;

// 检查预渲染是否完成
+ (BOOL)isPreloadFinish:(NSString *)place;

// 预加载广告
+ (void)preloadAdWithDelegate:(id)delegate withPlace:(NSString *)place;

@end
