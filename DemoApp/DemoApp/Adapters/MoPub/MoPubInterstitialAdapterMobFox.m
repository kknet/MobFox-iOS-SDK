#import "MoPubInterstitialAdapterMobFox.h"

@implementation MoPubInterstitialAdapterMobFox

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info{

    NSLog(@"MoPub inter >> MobFox >> init");
    NSLog(@"MoPub inter >> MobFox >> data: %@",[info description]);
    self.mobFoxInterAd = [[MobFoxInterstitialAd alloc] init:[info valueForKey:@"invh"]];
    self.mobFoxInterAd.delegate = self;
    [self.mobFoxInterAd loadAd];
        
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController{
    NSLog(@"MoPub inter >> MobFox >> set root");
    self.mobFoxInterAd.rootViewController = rootViewController;
    [self.mobFoxInterAd show];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Subclasses may override this method to return NO to perform impression and click tracking
    // manually.
    return NO;
}

- (void)MobFoxInterstitialAdDidLoad:(MobFoxInterstitialAd *)interstitial{
    NSLog(@"MoPub inter >> MobFox >> ad loaded");
    [self.delegate trackImpression];
    [self.delegate interstitialCustomEvent:self didLoadAd:interstitial];
   
}

- (void)MobFoxInterstitialAdDidFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"MoPub inter >> MobFox >> ad error: %@",[error description]);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)MobFoxInterstitialAdWillShow:(MobFoxInterstitialAd *)interstitial{
    [self.delegate interstitialCustomEventWillAppear:self];
    
}

- (void)MobFoxInterstitialAdClosed{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)MobFoxInterstitialAdClicked{
    [self.delegate trackClick];
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)MobFoxInterstitialAdFinished{
}

- (void)dealloc {
    
    //self.mobFoxInterAd.ad.bridge = nil;
    //self.mobFoxInterAd.ad        = nil;
    self.mobFoxInterAd.delegate = nil;
    self.mobFoxInterAd           = nil;
    
}
 
@end
