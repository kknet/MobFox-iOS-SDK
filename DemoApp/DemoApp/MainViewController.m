//
//  ViewController.m
//  DemoApp
//
//  Created by Shimi Sheetrit on 2/1/16.
//  Copyright © 2016 Matomy Media Group Ltd. All rights reserved.
//

#import "MainViewController.h"
#import "CollectionViewCell.h"
#import "SettingsViewController.h"
#import "NativeAdViewController.h"
#import "AppDelegate.h"
#import "MPMobFoxNativeAdRenderer.h"
#import "GenericAdapterViewController.h"
#import "MFDemoConstants.h"

#define ADS_TYPE_NUM 9
#define AD_REFRESH 0



typedef NS_ENUM(NSInteger, MFRandomStringPart) {
    MFAdTypeBanner = 0,
    MFAdTypeInterstitial,
    MFAdTypeNative,
    MFAdTypeVideoBanner,
    MFAdTypeVideoInterstitial,
    MFTestWaterfall,
    MFTestScrolView,
    MFTestGenericAdapter,
    MFTestAdapters
};



@interface MainViewController ()

@property (strong, nonatomic) MobFoxAd *mobfoxAd;
@property (strong, nonatomic) MobFoxAd *mobfoxAdWaterfall;
@property (strong, nonatomic) MobFoxInterstitialAd *mobfoxInterAd;
@property (strong, nonatomic) MobFoxNativeAd* mobfoxNativeAd;
@property (strong, nonatomic) MobFoxAd *mobfoxVideoAd;
@property (strong, nonatomic) MobFoxInterstitialAd *mobfoxVideoInterstitial;

@property (strong, nonatomic) NSURL *clickURL;
@property (strong, nonatomic) NSString *cellID;
@property (strong, nonatomic) UIViewController *vc;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *nativeAdView;
@property (weak, nonatomic) IBOutlet UIView *innerNativeAdView;

@property (weak, nonatomic) IBOutlet UIImageView *nativeAdIcon;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdTitle;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdDescription;
@property (weak, nonatomic) IBOutlet UITextField *invhInput;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;


@property (nonatomic) CGRect videoAdRect;
@property (nonatomic) CGRect bannerAdRect;
@property (nonatomic) NSIndexPath *lastIndexSelected;


@property (nonatomic, strong) MFTestAdapter *testAdapter;


/*** AdMob ***/
@property (nonatomic, strong) GADBannerView *gadBannerView;
@property (nonatomic, strong) DFPBannerView *dfpBannerView;
@property (nonatomic, strong) GADInterstitial *gadInterstitial;
@property (nonatomic, strong) DFPInterstitial *dfpInterstitial;
@property (nonatomic, strong) GADNativeAd *gadNative;
@property (nonatomic, strong) GADAdLoader *adLoader;


/*** Smaato ***/
@property (nonatomic, strong) SOMAAdView* somaBanner;
@property (nonatomic, strong) SOMAInterstitialAdView* somaInterstitial;
@property (nonatomic, strong) SOMANativeAd* somaNative;


/*** MoPub ***/
@property (nonatomic, retain) MPAdView *adView;
@property (nonatomic, retain) MPCollectionViewAdPlacer* placer;
@property (strong, nonatomic) MPAdView *mpAdView;
@property (strong, nonatomic) MPInterstitialAdController *mpInterstitialAdController;
@property (strong, nonatomic) MPNativeAd *mpNativeAd;


@end



@implementation MainViewController


static bool perform_segue_enabled;

- (void)setBtnSelected {
    
    NSLog(@"setBtnSelected");
    
    [self performSegueWithIdentifier:@"MainToSettings" sender:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    ////////////////////////////////////////////////////////////////////////
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Set Inv" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(setBtnSelected)];
    
    _navigationItem.rightBarButtonItem = settingsButton;

    
    self.cellID = @"cellID";
    self.invhInput.delegate = self;
    self.nativeAdView.hidden = true;
    self.invhInput.hidden = true;

    /*
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
     */
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.innerNativeAdView addGestureRecognizer:recognizer];
    
    // Oreintation dependent in iOS 8 and later.
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    //float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float bannerWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 728.0 : 320.0;
    float bannerHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90.0 : 50.0;
    float videoWidth = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 500.0 : 300.0;
    float videoHeight = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 450.0 : 250.0;
    
    
    /*** Banner ***/
    [MobFoxAd locationServicesDisabled:false];

    self.bannerAdRect = CGRectMake((screenWidth-bannerWidth)/2, SCREEN_HEIGHT - bannerHeight , bannerWidth, bannerHeight);
    self.mobfoxAd = [[MobFoxAd alloc] init:MOBFOX_HASH_BANNER_TEST withFrame:self.bannerAdRect];
    self.mobfoxAd.delegate = self;
    self.mobfoxAd.refresh = [NSNumber numberWithInt:AD_REFRESH];
    self.mobfoxAd.adspace_strict = false;
    [self.view addSubview:self.mobfoxAd];
    

    /*** Interstitial ***/
    
    [MobFoxInterstitialAd locationServicesDisabled:true];
    
    MainViewController *rootController =(MainViewController*)[[(AppDelegate*)
                                                               [[UIApplication sharedApplication]delegate] window] rootViewController];
    
    self.mobfoxInterAd = [[MobFoxInterstitialAd alloc] init:MOBFOX_HASH_INTER withRootViewController:rootController];
    self.mobfoxInterAd.delegate = self;
    
    
    /*** Native ***/
    
    [MobFoxNativeAd locationServicesDisabled:true];
    
    self.mobfoxNativeAd = [[MobFoxNativeAd alloc] init:MOBFOX_HASH_NATIVE];
    self.mobfoxNativeAd.delegate = self;
    
    
    /*** Video (Banner) ***/
    
    [MobFoxAd locationServicesDisabled:true];

    float videoTopMargin = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 200.0 : 80.0;
    self.videoAdRect = CGRectMake((screenWidth - videoWidth)/2, self.collectionView.frame.size.height + videoTopMargin, videoWidth, videoHeight);
    self.mobfoxVideoAd = [[MobFoxAd alloc] init:MOBFOX_HASH_VIDEO_TEST withFrame:self.videoAdRect];
    
    self.mobfoxVideoAd.delegate = self;
    self.mobfoxVideoAd.type = @"video";
    self.mobfoxVideoAd.skip = YES;
    [self.view addSubview:self.mobfoxVideoAd];
    
    
    /*** Video (Inter) ***/

    [MobFoxAd locationServicesDisabled:true];
    
    self.mobfoxVideoInterstitial = [[MobFoxInterstitialAd alloc] init:MOBFOX_HASH_VIDEO_TEST withRootViewController:self];
    self.mobfoxVideoInterstitial.delegate = self;

    
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"-- viewDidAppear: --");
    [super viewDidAppear:true];
    NSLog(@"invh: %@", self.invh);
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    //NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [self.mobfoxVideoAd pause];
    //self.mobfoxVideoAd = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"MainToGenericAdapter"] || [identifier isEqualToString:@"MainToAdapters"]) {
        
        NSLog(@"_lastIndexSelected.item: %ld", (long)_lastIndexSelected.item);
        
        if(perform_segue_enabled == true) {
            
            perform_segue_enabled = false;
            return YES;
        }
    }
    
    return NO;
}

- (UIViewController *)viewControllerForPresentingModalView {
    
    return self;
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


#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    _lastIndexSelected = indexPath;
    
    
    switch (indexPath.item) {
            
        case MFAdTypeBanner:

            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];
            self.mobfoxAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_BANNER_TEST;
            [self.mobfoxAd loadAd];
            
            break;
            
        case MFAdTypeInterstitial:

            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];
            self.mobfoxInterAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_INTER;
            [self.mobfoxInterAd loadAd];

            break;
            
        case MFAdTypeNative:
            
            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];
            self.mobfoxNativeAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_NATIVE;
            [self.mobfoxNativeAd loadAd];
            
            break;
            
        case MFAdTypeVideoBanner:
            
            [self hideAds:indexPath];
            self.mobfoxVideoAd.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_VIDEO_TEST;
            [self.mobfoxVideoAd loadAd];
            break;
            
        case MFAdTypeVideoInterstitial:
            
            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];
            self.mobfoxVideoInterstitial.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_VIDEO_TEST;
            [self.mobfoxVideoInterstitial loadAd];
            break;
            
        case MFTestWaterfall:
            // waterfall
            [self hideAds:indexPath];
            [self.mobfoxVideoAd pause];

            self.mobfoxAdWaterfall = [[MobFoxAd alloc] init:MOBFOX_HASH_BANNER_TEST withFrame:self.bannerAdRect];
            self.mobfoxAdWaterfall.invh = self.invh.length > 0 ? self.invh: MOBFOX_HASH_BANNER_TEST;
            self.mobfoxAdWaterfall.delegate = self;
            [self.view addSubview:self.mobfoxAdWaterfall];
            [self.mobfoxAdWaterfall loadAd];
            
            break;
            
        case MFTestScrolView: {
            
            [self hideAds:indexPath];
            
            float bannerWidth_ = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 728.0 : 320.0;
            float bannerHeight_ = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 90.0 : 50.0;
            self.bannerAdRect = CGRectMake((SCREEN_WIDTH-bannerWidth_)/2, 1350.0 /*screenHeight-bannerHeight*/, bannerWidth_, bannerHeight_);
            self.mobfoxAd = [[MobFoxAd alloc] init:MOBFOX_HASH_BANNER_TEST withFrame:self.bannerAdRect];
            self.mobfoxAd.delegate = self;
            self.mobfoxAd.refresh = [NSNumber numberWithInt:AD_REFRESH];
            self.mobfoxAd.hidden = NO;

            // close button.
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [closeButton addTarget:self
                            action:@selector(dismissVC)
                  forControlEvents:UIControlEventTouchUpInside];
            [closeButton setTitle:@"Close" forState:UIControlStateNormal];
            closeButton.frame = CGRectMake(0, 0.0, SCREEN_WIDTH, 50.0);
            closeButton.backgroundColor = [UIColor blueColor];
            
            // loadAd button(1).
            UIButton *loadAdButton_1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [loadAdButton_1 addTarget:self
                            action:@selector(loadAd1)
                  forControlEvents:UIControlEventTouchUpInside];
            [loadAdButton_1 setTitle:@"Load Ad" forState:UIControlStateNormal];
            loadAdButton_1.frame = CGRectMake(0, 1250.0, SCREEN_WIDTH, 50.0);
            loadAdButton_1.backgroundColor = [UIColor blueColor];
            
            // loadAd button(2).
            UIButton *loadAdButton_2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [loadAdButton_2 addTarget:self
                             action:@selector(loadAd2)
                   forControlEvents:UIControlEventTouchUpInside];
            [loadAdButton_2 setTitle:@"Load Ad" forState:UIControlStateNormal];
            loadAdButton_2.frame = CGRectMake(0, 250.0, SCREEN_WIDTH, 50.0);
            loadAdButton_2.backgroundColor = [UIColor blueColor];
            
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            scrollView.backgroundColor = [UIColor grayColor];
            [scrollView addSubview:self.mobfoxAd];
            [scrollView addSubview:closeButton];
            [scrollView addSubview:loadAdButton_1];
            [scrollView addSubview:loadAdButton_2];

            scrollView.scrollEnabled = YES;
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1400);
            
            UIView *view_1 = [[UIView alloc] initWithFrame:CGRectMake(0, 400, SCREEN_WIDTH, 200)];
            UIView *view_2 = [[UIView alloc] initWithFrame:CGRectMake(0, 600, SCREEN_WIDTH, 250)];
            UIView *view_3 = [[UIView alloc] initWithFrame:CGRectMake(0, 800, SCREEN_WIDTH, 300)];
            view_1.backgroundColor = [UIColor redColor];
            view_2.backgroundColor = [UIColor yellowColor];
            view_3.backgroundColor = [UIColor greenColor];
            [scrollView addSubview:view_1];
            [scrollView addSubview:view_2];
            [scrollView addSubview:view_3];

            
            self.vc = [[UIViewController alloc] init];
            self.vc.view.backgroundColor = [UIColor whiteColor];
            [self.vc.view addSubview:scrollView];
            
            [self.mobfoxAd loadAd];
            
            [self presentViewController:self.vc animated:YES completion:^{
                // Verify it's not visible.
                //[self.mobfoxAd loadAd];
                
            }];
    
    
            break;
        }
    
        case MFTestGenericAdapter:
            
            [self hideAds:indexPath];
            
            perform_segue_enabled = true;
            [self shouldPerformSegueWithIdentifier:@"MainToGenericAdapter" sender:nil];
            [self performSegueWithIdentifier:@"MainToGenericAdapter" sender:nil];

            break;
            
        case MFTestAdapters:
            
            [self hideAds:indexPath];
            
            perform_segue_enabled = true;
            [self shouldPerformSegueWithIdentifier:@"MainToAdapters" sender:nil];
            [self performSegueWithIdentifier:@"MainToAdapters" sender:nil];
            
            break;
            
       
        

    }
  
}

- (void)loadAd1 {
    [self.mobfoxAd loadAd];
}

- (void)loadAd2 {
    [self.mobfoxAd loadAd];
}

- (void)dismissVC {
    
    [self.vc dismissViewControllerAnimated:YES completion:nil];
    //self.vc = nil;
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark MobFox Ad Delegate

//called when ad is displayed
- (void)MobFoxAdDidLoad:(MobFoxAd *)banner {
    
    NSLog(@"MobFoxAdDidLoad:");
}

//called when an ad cannot be displayed
- (void)MobFoxAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxAdDidFailToReceiveAdWithError: %@", [error description]);
}

//called when ad is closed/skipped
- (void)MobFoxAdClosed {
    NSLog(@"MobFoxAdClosed:");

}

//called when ad is clicked

- (void)MobFoxAdClicked {
    NSLog(@"MobFoxAdClicked:");

}

- (void)MobFoxAdFinished {
    NSLog(@"MobFoxAdFinished:");
    
}

#pragma mark MobFox Interstitial Ad Delegate

//best to show after delegate informs an ad was loaded
- (void)MobFoxInterstitialAdDidLoad:(MobFoxInterstitialAd *)interstitial {
    
    NSLog(@"MobFoxInterstitialAdDidLoad:");
        
    if(self.mobfoxInterAd.ready){
        [self.mobfoxInterAd show];
        
    }
    
    if(self.mobfoxVideoInterstitial.ready){
        [self.mobfoxVideoInterstitial show];
    }
}

- (void)dismissIntAd {
    [self.mobfoxInterAd dismissAd];

}

- (void)MobFoxInterstitialAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxInterstitialAdDidFailToReceiveAdWithError: %@", [error description]);
    
}

- (void)MobFoxInterstitialAdClosed {
    
    NSLog(@"MobFoxInterstitialAdClosed");
    
}

- (void)MobFoxInterstitialAdClicked {
    
    NSLog(@"MobFoxInterstitialAdClicked");
    
}

- (void)MobFoxInterstitialAdFinished {
    
    NSLog(@"MobFoxInterstitialAdFinished");
    
}

#pragma mark MobFox Native Ad Delegate

//called when ad response is returned
- (void)MobFoxNativeAdDidLoad:(MobFoxNativeAd *)ad withAdData:(MobFoxNativeData *)adData {
    
    self.nativeAdIcon.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:adData.icon.url]];
    self.nativeAdTitle.text = adData.assetHeadline;
    self.nativeAdDescription.text = adData.assetDescription;
    self.clickURL = [adData.clickURL absoluteURL];
    
    //adData.callToActionText
    NSLog(@"adData.assetHeadline: %@", adData.assetHeadline);
    NSLog(@"adData.assetDescription: %@", adData.assetDescription);
    NSLog(@"adData.callToActionText: %@", adData.callToActionText);
    
    for (MobFoxNativeTracker *tracker in adData.trackersArray) {
        
        //NSLog(@"tracker: %@", tracker);
        //NSLog(@"tracker.url: %@", tracker.url);

        if ([tracker.url absoluteString].length > 0)
        {
            
            // Fire tracking pixel
            UIWebView* wv = [[UIWebView alloc] initWithFrame:CGRectZero];
            NSString* userAgent = [wv stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            NSURLSessionConfiguration* conf = [NSURLSessionConfiguration defaultSessionConfiguration];
            conf.HTTPAdditionalHeaders = @{ @"User-Agent" : userAgent };
            NSURLSession* session = [NSURLSession sessionWithConfiguration:conf];
            NSURLSessionDataTask* task = [session dataTaskWithURL:tracker.url completionHandler:
                                          ^(NSData *data,NSURLResponse *response, NSError *error){
                                          
                                              if(error) NSLog(@"err %@",[error description]);

                                          }];
            [task resume];
            
        }
        
    }
    [ad registerViewWithInteraction:self.nativeAdView withViewController:self];

    
}

//called when ad response cannot be returned
- (void)MobFoxNativeAdDidFailToReceiveAdWithError:(NSError *)error {
    
    NSLog(@"MobFoxNativeAdDidFailToReceiveAdWithError: %@", [error description]);
    
}


#pragma mark Private Methods

- (void)hideAds:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case MFAdTypeBanner:
            self.mobfoxAd.hidden= NO;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;

            break;
            
        case MFAdTypeInterstitial:
            self.mobfoxAd.hidden= YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case MFAdTypeNative:
            self.mobfoxAd.hidden= YES;
            self.nativeAdView.hidden = NO;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case MFAdTypeVideoBanner:

            self.mobfoxAd.hidden= YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = NO;
            
            break;
            
        case MFAdTypeVideoInterstitial:
            self.mobfoxAd.hidden= YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case MFTestWaterfall:
            self.mobfoxAd.hidden= YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case MFTestScrolView:
            self.mobfoxAd.hidden= YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case MFTestGenericAdapter:
            self.mobfoxAd.hidden= YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
        case MFTestAdapters:
            self.mobfoxAd.hidden= YES;
            self.nativeAdView.hidden = YES;
            self.mobfoxVideoAd.hidden = YES;
            
            break;
            
   

            
        default:
            break;
    }
    
}

- (NSString *)adTitle:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case MFAdTypeBanner:
            return @"Banner";
            break;
        case MFAdTypeInterstitial:
            return @"Interstitial";
            break;
        case MFAdTypeNative:
            return @"Native";
            break;
        case MFAdTypeVideoBanner:
            return @"Video(Bnr)";
            break;
        case MFAdTypeVideoInterstitial:
            return @"Video(Int)";
            break;
        case MFTestWaterfall:
            return @"Waterfall";
            break;
        case MFTestScrolView:
            return @"ScrollView";
            break;
        case MFTestGenericAdapter:
            return @"G-Adapter";
            break;
        case MFTestAdapters:
            return @"Adapters";
            break;
            
            
        default:
            return @"";
            break;
    }
}

- (UIImage *)adImage:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case MFAdTypeBanner:
            return [UIImage imageNamed:@"test_banner.png"];
            break;
        case MFAdTypeInterstitial:
            return [UIImage imageNamed:@"test_interstitial.png"];
            break;
        case MFAdTypeNative:
            return [UIImage imageNamed:@"test_native.png"];
            break;
        case MFAdTypeVideoBanner:
            return [UIImage imageNamed:@"test_video.png"];
            break;
        case MFAdTypeVideoInterstitial:
            return [UIImage imageNamed:@"test_video.png"];
            break;
        case MFTestWaterfall:
            return [UIImage imageNamed:@"test_banner.png"];
            break;
        case MFTestScrolView:
            return [UIImage imageNamed:@"test_interstitial.png"];
            break;
        case MFTestGenericAdapter:
            return [UIImage imageNamed:@"test_banner.png"];
            break;
        case MFTestAdapters:
            return [UIImage imageNamed:@"test_banner.png"];
            break;

            
        default:
            return nil;
            break;
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    
    [[UIApplication sharedApplication] openURL:self.clickURL];
    
}

- (void)presentViewController {
    
    NativeAdViewController *nativeVC = [[NativeAdViewController alloc] init];
    [self presentViewController:nativeVC animated:YES completion:nil];
    
}

#pragma mark Mopub Ad Delegate

- (void)adViewDidLoadAd:(MPAdView *)view
{
    NSLog(@"Mopub -- adViewDidLoadAd");
}

#pragma mark Mopub Interstitial Delegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    
    NSLog(@"Mopub -- interstitialDidLoadAd");
    
    if(interstitial.ready) {
        
        [interstitial showFromViewController:self];

    }

}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    
    NSLog(@"Mopub -- interstitialDidFailToLoadAd ");

}

#pragma mark Mopub Native Delegate

- (void)willPresentModalForNativeAd:(MPNativeAd *)nativeAd {
    
    NSLog(@"nativeAd.properties: %@", nativeAd.properties);
    
}

#pragma mark Mopub Nativew Ad Delegate

-(void)nativeAdWillPresentModalForCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> first");
}

-(void)nativeAdDidDismissModalForCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> second");
}

-(void)nativeAdWillLeaveApplicationFromCollectionViewAdPlacer:(MPCollectionViewAdPlacer *)placer{
    NSLog(@">> third");
}


#pragma mark AdMob Ad Delegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    
    NSLog(@"adViewDidReceiveAd");
    
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"didFailToReceiveAdWithError: %@", error);

}

#pragma mark Click-Time Lifecycle Notifications

/// Tells the delegate that a full screen view will be presented in response to the user clicking on
/// an ad. The delegate may want to pause animations and time sensitive interactions.
- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
    
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView {
    
}

/// Tells the delegate that the full screen view has been dismissed. The delegate should restart
/// anything paused while handling adViewWillPresentScreen:.
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    
}

/// Tells the delegate that the user click will open another app, backgrounding the current
/// application. The standard UIApplicationDelegate methods, like applicationDidEnterBackground:,
/// are called immediately before this method is called.
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
    
}


#pragma mark AdMob interstitial Ad Delegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    
    NSLog(@"interstitialDidReceiveAd");
    
    if(ad.isReady) {
        
        if(self.gadInterstitial) {
            [self.gadInterstitial presentFromRootViewController:self];
        }
        else {
            [self.dfpInterstitial presentFromRootViewController:self];
        }
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error description]);
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen:");
    
}

/// Called when |ad| fails to present.
- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidFailToPresentScreen:");
    
}

/// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen:");

}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen:");

}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store). The normal
/// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
/// before this.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication:");
}

#pragma mark Smaato Banner Ad Delegate

- (UIViewController*)somaRootViewController{
    NSLog(@"somaRootViewController:");
    return self;
}

- (void)somaAdViewWillLoadAd:(SOMAAdView *)adview{
    // Here make sure that the adview or its parent is currently positioned inside the viweable area. If ad is covered, it will not show.
    NSLog(@"somaAdViewWillLoadAd:");

}

#pragma mark Smaato Interstitial Ad Delegate

- (void)somaAdViewDidLoadAd:(SOMAAdView *)adview{
    // called when the Ad is ready to be shown. Banners are automatically shown but you have to explicitly show the interstitial ads.
    NSLog(@"somaAdViewDidLoadAd:");
    [self.somaInterstitial show];

}

- (void)somaAdView:(SOMAAdView *)adview didFailToReceiveAdWithError:(NSError *)error{
    // if failed to load ad or if ad is covered or partially obstruted or load is called too frequently or there is already loaded but not yet shown.
    NSLog(@"somaAdView:didFailToReceiveAdWithError:");
}

- (void)somaAdViewWillEnterFullscreen:(SOMAAdView *)adview{
    // it is called before going into expanded state.
}

- (void)somaAdViewDidExitFullscreen:(SOMAAdView *)adview{
    // called when expanded fullscreen ad is closed.
}

- (void)somaAdViewWillHide:(SOMAAdView *)adview{
    // called when the ad is hidden by SDK for some reason.
}

- (void)somaAdViewApplicationWillGoBackground:(SOMAAdView *)adview {
// is called when some redirect in the app leads over to another app (i.e. minimizes the current app)
}

#pragma mark Smaato Native Ad Delegate

- (void)somaNativeAdDidLoad:(SOMANativeAd*)nativeAd {
    NSLog(@"somaNativeAdDidLoad");
    
}

- (void)somaNativeAdDidFailed:(SOMANativeAd*)nativeAd withError:(NSError*)error {
    NSLog(@"somaNativeAdDidFailed Error: %@",[error description]);
    
}

- (BOOL)somaNativeAdShouldEnterFullScreen:(SOMANativeAd *)nativeAd {
    NSLog(@"somaNativeAdShouldEnterFullScreen");
    return NO;
}

#pragma mark MFTestAdapterBase Delegate

- (void)MFTestAdapterBaseAdDidLoad:(UIView *)ad {
    NSLog(@"MFTestAdapterBaseAdDidLoad");
    ad.frame = CGRectMake( (SCREEN_WIDTH - ad.frame.size.width)/2, SCREEN_HEIGHT - ad.frame.size.height, ad.frame.size.width, ad.frame.size.height ); // set new
    [self.view addSubview:ad];
 
}

- (void)MFTestAdapterBaseAdDidFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"MFTestAdapterBaseAdDidFailToReceiveAdWithError");
    
}




@end




