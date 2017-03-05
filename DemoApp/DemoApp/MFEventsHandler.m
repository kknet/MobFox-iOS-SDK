//
//  MFEventsHandler.m
//  DemoApp
//
//  Created by Shimi Sheetrit on 2/15/17.
//  Copyright © 2017 Matomy Media Group Ltd. All rights reserved.
//

#import "MFEventsHandler.h"

@interface MFEventsHandler()


@property (atomic, assign, getter=isBannerReported) BOOL bannerReported;
@property (atomic, assign, getter=isInterstitialReported) BOOL interstitialReported;
@property (atomic, assign, getter=isNativeReported) BOOL nativeReported;


@end


@implementation MFEventsHandler


- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        // initialize instance variables here
    }
    
    return self;
}

/*** reset blockers ***/
- (void)resetAdEventBlocker {
    
    [self setBannerReported:false];
    
}

- (void)resetInterstitialEventBlocker {
    
    [self setInterstitialReported:false];
    
}

- (void)resetNativeEventBlocker {
    
    [self setNativeReported:false];
    
}

/*** invoke blockers ***/
- (void)invokeAdEventBlocker:(void (^)(BOOL isReported))completion{

    @synchronized (self) {
        
        if([self isBannerReported]) {
            completion(YES);

        }
        
        [self setBannerReported:true];
        completion(NO);
        
    }
    
}
- (void)invokeInterstitialEventBlocker:(void (^)(BOOL isReported))completion {
    
    @synchronized (self) {
        
        if([self isInterstitialReported]) {
            completion(YES);
        }
        
        [self setInterstitialReported:true];
        completion(NO);
        
    }
}

- (void)invokeNativeEventBlocker:(void (^)(BOOL isReported))completion {

    @synchronized (self) {
        
        if([self isNativeReported]) {
            completion(YES);
        }
        
        [self setNativeReported:true];
        completion(NO);
        
    }
    
}

@end
