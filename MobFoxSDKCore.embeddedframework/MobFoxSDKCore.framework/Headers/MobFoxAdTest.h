//
//  MobFoxAdTest.h
//  MobFoxSDKCore
//
//  Created by Shimi Sheetrit on 4/19/17.
//  Copyright © 2017 Matomy Media Group Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobFoxSDKCore/MobFoxSDKCore.h>


@interface MobFoxAdTest : MobFoxAd


@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSLock *responseLock;
@property (nonatomic, strong) NSTimer *responseTimeoutTimer;
@property (nonatomic, assign) BOOL isAdTouched;
@property (nonatomic, assign) BOOL isResponseTimeout;



@end
