//
//  MobFoxCustomEventFacebook.h
//  MobFoxCoreDemo
//
//  Created by Shimi Sheetrit on 11/1/16.
//  Copyright © 2015 Shimi Sheetrit. All rights reserved.
//

#ifndef MobFoxCustomEventFacebook_h
#define MobFoxCustomEventFacebook_h

#import <MobFoxSDKCore/MobFoxSDKCore.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>


@interface MobFoxCustomEventFacebook : MobFoxCustomEvent <FBAdViewDelegate>


//- (void)requestAdWithSize:(CGSize)size networkID:(NSString*)nid customEventInfo:(NSDictionary *)info;

@end

#endif