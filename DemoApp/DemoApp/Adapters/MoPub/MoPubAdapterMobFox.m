#import "MoPubAdapterMobFox.h"


@implementation MoPubAdapterMobFox


- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info{
    
    [MFReport log:@"mopub" withInventoryHash:[info valueForKey:@"invh"] andWithMessage:@"request"];
     NSLog(@"MoPub >> MobFox >> init");
     NSLog(@"MoPub >> MobFox >> data: %@",[info description]);
    
    
    self.ad = [[MobFoxAd alloc] init:[info valueForKey:@"invh"] withFrame:CGRectMake(0, 0, size.width, size.height)];
    self.ad.delegate = self;
    [self.ad loadAd];
    [MFReport log:@"mopub" withInventoryHash:self.ad.invh andWithMessage:@"request.mobfox"];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Subclasses may override this method to return NO to perform impression and click tracking
    // manually.
    return NO;
}


- (void)MobFoxAdDidLoad:(MobFoxAd *)banner{
    [MFReport log:@"mopub" withInventoryHash:self.ad.invh andWithMessage:@"impression"];
    NSLog(@"MoPub >> MobFox >> Loaded");
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:banner];
}

- (void)MobFoxAdDidFailToReceiveAdWithError:(NSError *)error{
     NSLog(@"MoPub >> MobFox >> error : %@",[error description]);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)MobFoxAdClosed{
    
}

- (void)MobFoxAdClicked{
    [self.delegate trackClick];
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (void)MobFoxAdFinished{
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)dealloc {
    
    self.ad.delegate    = nil;
    self.ad             = nil;
}


@end
