//
//  InnerViewController.m
//  DemoApp
//
//  Created by Shimi Sheetrit on 1/4/17.
//  Copyright © 2017 Matomy Media Group Ltd. All rights reserved.
//

#import "GenericAdapterViewController.h"
#import "CollectionViewCell.h"
#import "MFTestAdapter.h"
#import "MFDemoConstants.h"


#define ADS_TYPE_NUM 5

typedef NS_ENUM(NSInteger, MFRandomStringPart) {
    
    MFGenericAdapterBanner = 0,
    MFGenericAdapterInterstitial,
    MFGenericAdapterNative,
    MFGenericAdapterVideoBanner,
    MFGenericAdapterVideoInterstitial
    
};

@interface GenericAdapterViewController()
    
@property (nonatomic, strong) NSString *cellID;
@property (nonatomic, strong) MFTestAdapter *bannerAdapter;
@property (nonatomic, strong) MFTestAdapter *interstitialAdapter;
@property (nonatomic, strong) MFTestAdapter *nativeAdapter;

@property (nonatomic, strong) MFTestAdapter *bannerVideoAdapter;
@property (nonatomic, strong) MFTestAdapter *interstitialVideoAdapter;
@property (weak, nonatomic) IBOutlet UILabel *nativeDescription;

@property (weak, nonatomic) IBOutlet UIView *nativeAdView;
@property (weak, nonatomic) IBOutlet UILabel *nativeTitle;
@property (weak, nonatomic) IBOutlet UIImageView *nativeImage;

@property (nonatomic) CGRect bannerAdRect;
@property (nonatomic) CGRect videoBannerAdRect;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;



@end

@implementation GenericAdapterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellID = @"cellID";
    self.nativeAdView.hidden = YES;

    // Oreintation dependent in iOS 8 and later.
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float bannerWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 728.0 : 320.0;
    float bannerHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90.0 : 50.0;
    self.bannerAdRect = CGRectMake((screenWidth-bannerWidth)/2, SCREEN_HEIGHT - bannerHeight , bannerWidth, bannerHeight);
    
    float videoWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 500.0 : 300.0;
    float videoHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 450.0 : 250.0;
    
    float videoTopMargin = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 200.0 : 200.0;
    self.videoBannerAdRect = CGRectMake((screenWidth - videoWidth)/2, self.collectionView.frame.size.height + videoTopMargin, videoWidth, videoHeight);
    
    // ads allocation.
    self.bannerAdapter = [[MFTestAdapter alloc] init];
    self.interstitialAdapter = [[MFTestAdapter alloc] init];
    self.nativeAdapter = [[MFTestAdapter alloc] init];
    self.bannerVideoAdapter = [[MFTestAdapter alloc] init];
    self.interstitialVideoAdapter = [[MFTestAdapter alloc] init];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:true];
    
    [self hideAll];
    
}


    
#pragma mark Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return ADS_TYPE_NUM;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    CollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:self.cellID forIndexPath:indexPath];
    cell.title.text = [self adTitle:indexPath];
    cell.image.image = [self adImage:indexPath];
    
    if (cell.selected) {
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor]; // Default color
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    [self hideAll];
    
    switch (indexPath.item) {
            
        case MFGenericAdapterBanner:
            
            
            self.bannerAdapter.delegate = self;
            [self.bannerAdapter requestAdWithFrame:self.bannerAdRect networkID:MOBFOX_HASH_BANNER_TEST customEventInfo:[[NSDictionary alloc] initWithObjectsAndKeys:self, @"viewcontroller_parent", nil]];
            
            [self hideAds:indexPath];

            
            break;
            
        case MFGenericAdapterInterstitial:
            
            
            self.interstitialAdapter.delegate = self;
            [self.interstitialAdapter requestInterstitialAdWithFrame:CGRectZero networkID:MOBFOX_HASH_INTER_TEST customEventInfo:nil];
            
            [self hideAds:indexPath];

        
            break;
            
        case MFGenericAdapterNative:
            
            
            self.nativeAdapter.delegate = self;
            [self.nativeAdapter requestNativeAdWithFrame:CGRectZero networkID:MOBFOX_HASH_NATIVE_TEST customEventInfo:nil];
            
            [self hideAds:indexPath];

            
            break;
            
            
        case MFGenericAdapterVideoBanner:
            
            
            self.bannerVideoAdapter.delegate = self;
            [self.bannerVideoAdapter requestAdWithFrame:self.videoBannerAdRect networkID:MOBFOX_HASH_VIDEO_TEST customEventInfo:[[NSDictionary alloc] initWithObjectsAndKeys:self, @"viewcontroller_parent", @"true", @"is_video_ad", nil]];
            
            [self hideAds:indexPath];

            
            break;
 
            
        case MFGenericAdapterVideoInterstitial:
            
            
            self.interstitialVideoAdapter.delegate = self;
            [self.interstitialVideoAdapter requestInterstitialAdWithFrame:CGRectZero networkID:MOBFOX_HASH_VIDEO_TEST customEventInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"true", @"is_video_ad", nil] ];
            
            [self hideAds:indexPath];

            
            break;
            
        default:
            break;
    }
    
    
}
    
#pragma mark Private Methods

- (void)hideAll {
    
    [self.bannerVideoAdapter.bannerAd pause];

    self.bannerAdapter.bannerAd.hidden = YES;
    self.bannerVideoAdapter.bannerAd.hidden = YES;
    [self.bannerAdapter.bannerAd removeFromSuperview];
    [self.bannerVideoAdapter.bannerAd removeFromSuperview];
    self.nativeAdView.hidden = YES;
    
    self.bannerAdapter.bannerAd = nil;
    self.bannerVideoAdapter.bannerAd = nil;
    
}

- (void)hideAds:(NSIndexPath *)indexPath {
    
        switch (indexPath.item) {
                
            case MFGenericAdapterBanner:
                self.bannerAdapter.bannerAd.hidden = NO;
                self.bannerVideoAdapter.bannerAd.hidden = YES;
                [self.bannerVideoAdapter.bannerAd removeFromSuperview];
                self.nativeAdView.hidden = YES;
                
                break;
                
            case MFGenericAdapterInterstitial:
                self.bannerAdapter.bannerAd.hidden = YES;
                self.bannerVideoAdapter.bannerAd.hidden = YES;
                [self.bannerAdapter.bannerAd removeFromSuperview];
                [self.bannerVideoAdapter.bannerAd removeFromSuperview];
                self.nativeAdView.hidden = YES;

                break;
                
            case MFGenericAdapterNative:
                self.bannerAdapter.bannerAd.hidden = YES;
                self.bannerVideoAdapter.bannerAd.hidden = YES;
                [self.bannerAdapter.bannerAd removeFromSuperview];
                [self.bannerVideoAdapter.bannerAd removeFromSuperview];
                self.nativeAdView.hidden = NO;
                
                break;
           
            case MFGenericAdapterVideoBanner:
                self.bannerAdapter.bannerAd.hidden = YES;
                [self.bannerAdapter.bannerAd removeFromSuperview];
                self.bannerVideoAdapter.bannerAd.hidden = NO;
                self.nativeAdView.hidden = YES;
                self.bannerVideoAdapter.bannerAd.skip = true;

                break;
                
            case MFGenericAdapterVideoInterstitial:
                self.bannerAdapter.bannerAd.hidden = YES;
                self.bannerVideoAdapter.bannerAd.hidden = YES;
                [self.bannerAdapter.bannerAd removeFromSuperview];
                [self.bannerVideoAdapter.bannerAd removeFromSuperview];
                self.nativeAdView.hidden = YES;
                
                break;
            
                
            default:
                break;
        }
}
        

- (NSString *)adTitle:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case MFGenericAdapterBanner:
            return @"Banner";
            break;
        case MFGenericAdapterInterstitial:
            return @"Interstitial";
            break;
        case MFGenericAdapterNative:
            return @"Native";
            break;
        case MFGenericAdapterVideoBanner:
            return @"Video(Bnr)";
            break;
        case MFGenericAdapterVideoInterstitial:
            return @"Video(Int)";
            break;
        
            
        default:
            return @"";
            break;
    }
}

- (UIImage *)adImage:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case MFGenericAdapterBanner:
            return [UIImage imageNamed:@"test_banner.png"];
            break;
        case MFGenericAdapterInterstitial:
            return [UIImage imageNamed:@"test_interstitial.png"];
            break;
        case MFGenericAdapterNative:
            return [UIImage imageNamed:@"test_native.png"];
            break;
        case MFGenericAdapterVideoBanner:
            return [UIImage imageNamed:@"test_video.png"];
            break;
        case MFGenericAdapterVideoInterstitial:
            return [UIImage imageNamed:@"test_video.png"];
            break;
            

        default:
            return nil;
            break;
    }
}

#pragma mark MFTestAdapterBase Delegate

// banner
- (void)MFTestAdapterBaseAdDidLoad:(UIView *)ad {
    
    NSLog(@"InnerViewController >> MFTestAdapterBaseAdDidLoad");
        
}
- (void)MFTestAdapterBaseAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"InnerViewController >> MFTestAdapterBaseAdDidFailToReceiveAdWithError");

}

// Interstital
- (void)MFTestAdapterInterstitialAdapterBaseAdDidLoad:(UIView *)ad {
    
    NSLog(@"InnerViewController >> MFTestAdapterInterstitialAdapterBaseAdDidLoad");

    
}
- (void)MFTestAdapterInterstitialAdapterBaseAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"InnerViewController >> MFTestAdapterInterstitialAdapterBaseAdDidFailToReceiveAdWithError");

}

// native
- (void)MFTestAdapterNativeAdapterBaseAdDidLoad:(MobFoxNativeData *)ad {
    
    NSLog(@"InnerViewController >> MFTestAdapterNativeAdapterBaseAdDidLoad");
    
    _nativeTitle.text = ad.assetHeadline;
    _nativeDescription.text = ad.assetDescription;
    _nativeImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:ad.icon.url]];
    
}

- (void)MFTestAdapterNativeAdapterBaseAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"InnerViewController >> MFTestAdapterNativeAdapterBaseAdDidFailToReceiveAdWithError");

    
}


@end
