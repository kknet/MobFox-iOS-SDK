//
//  MobFoxNativeCustomEventAdMob.m
//  DemoApp
//
//  Created by Shimi Sheetrit on 9/1/16.
//  Copyright © 2016 Matomy Media Group Ltd. All rights reserved.
//

#import "MobFoxNativeCustomEventAdMob.h"

@interface MobFoxNativeCustomEventAdMob()
@property (nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic, strong) GADNativeContentAdView *contentAdView;
@end

@implementation MobFoxNativeCustomEventAdMob

#pragma mark MobFoxNativeCustomEvent

- (void)requestAdWithNetworkID:(NSString*)nid customEventInfo:(NSDictionary *)info {
    
    UIViewController* rootVC = [info objectForKey:@"viewcontroller_parent"];

    self.adLoader = [[GADAdLoader alloc]
                     initWithAdUnitID:@"ca-app-pub-3940256099942544/3986624511"
                     rootViewController:rootVC
                     adTypes:@[kGADAdLoaderAdTypeNativeAppInstall, kGADAdLoaderAdTypeNativeContent]
                     options:nil];
    self.adLoader.delegate = self;
    
    GADRequest *request = [[GADRequest alloc] init];
    request.testDevices = @[ kGADSimulatorID ];
    
    [self.adLoader loadRequest:[GADRequest request]];
    
}

- (void)registerViewWithInteraction:(UIView *)view withViewController:(UIViewController *)viewController {
    
    UIButton *button = [[UIButton alloc] init];
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];

}

#pragma mark GADNativeAd Delegate

/// Called just before presenting the user a full screen view, such as a browser, in response to
/// clicking on an ad. Use this opportunity to stop animations, time sensitive interactions, etc.
- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd {
    
    NSLog(@"nativeAdWillPresentScreen:");
    
}

/// Called just before dismissing a full screen view.
- (void)nativeAdWillDismissScreen:(GADNativeAd *)nativeAd {
    
    NSLog(@"nativeAdWillDismissScreen:");
    
}

/// Called just after dismissing a full screen view. Use this opportunity to restart anything you
/// may have stopped as part of nativeAdWillPresentScreen:.
- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd {
    
    NSLog(@"nativeAdDidDismissScreen:");
    
}

/// Called just before the application will go to the background or terminate due to an ad action
/// that will launch another application (such as the App Store). The normal UIApplicationDelegate
/// methods, like applicationDidEnterBackground:, will be called immediately before this.
- (void)nativeAdWillLeaveApplication:(GADNativeAd *)nativeAd {
    
    NSLog(@"nativeAdWillLeaveApplication:");
}


#pragma mark GADNativeAppInstallAdLoader Delegate


- (void)adLoader:(GADAdLoader *)adLoader
didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd {
    
}

#pragma mark GADNativeContentAdLoader Delegate

- (void)adLoader:(GADAdLoader *)adLoader
didReceiveNativeContentAd:(GADNativeContentAd *)nativeContentAd {
    
    // Create and place ad in view hierarchy.
    self.contentAdView = [[[NSBundle mainBundle] loadNibNamed:@"NativeContentAdView"
                                   owner:nil
                                 options:nil] firstObject];
    // TODO: Make sure to add the GADNativeContentAdView to the view hierarchy.
    
    // Associate the content ad view with the content ad object. This is required to make the ad
    // clickable.
    self.contentAdView.nativeContentAd = nativeContentAd;
    self.contentAdView.nativeContentAd.delegate = self;
    
    // Populate the content ad view with the content ad assets.
    // Some assets are guaranteed to be present in every content ad.
    ((UILabel *)self.contentAdView.headlineView).text = nativeContentAd.headline;
    ((UILabel *)self.contentAdView.bodyView).text = nativeContentAd.body;
    ((UIImageView *)self.contentAdView.imageView).image =
    ((GADNativeAdImage *)[nativeContentAd.images firstObject]).image;
    ((UILabel *)self.contentAdView.advertiserView).text = nativeContentAd.advertiser;
    [((UIButton *)self.contentAdView.callToActionView)setTitle:nativeContentAd.callToAction
                                                 forState:UIControlStateNormal];
    
    // Other assets are not, however, and should be checked first.
    if (nativeContentAd.logo && nativeContentAd.logo.image) {
        ((UIImageView *)self.contentAdView.logoView).image = nativeContentAd.logo.image;
        self.contentAdView.logoView.hidden = NO;
    } else {
        self.contentAdView.logoView.hidden = YES;
    }
    
    // In order for the SDK to process touch events properly, user interaction should be disabled on
    // all views associated with the GADNativeContentAdView. Since UIButton has userInteractionEnabled
    // set to YES by default, views of this type must explicitly set userInteractionEnabled to NO.
    
    self.contentAdView.callToActionView.userInteractionEnabled = NO;
    [self.delegate MFNativeCustomEventAd:self didLoad:nil];
    
}


- (void)adView:(DFPBannerView *)banner didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info {
    
}

#pragma mark GADAdLoader Delegate

- (void)adLoader:(GADAdLoader *)adLoader
didFailToReceiveAdWithError:(GADRequestError *)error {
    
    [self.delegate MFNativeCustomEventAdDidFailToReceiveAdWithError:error];
    
}

@end
