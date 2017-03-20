//
//  ViewController.swift
//  DemoAppSwift
//
//  Created by Shimi Sheetrit on 2/16/16.
//  Copyright © 2016 Matomy Media Group Ltd. All rights reserved.
//

import UIKit
import MobFoxSDKCore
import GoogleMobileAds


let AdsTypeNum = 4
let adRefresh = 10

struct InventoryHash {
    
    static let MobFoxHashBanner = "fe96717d9875b9da4339ea5367eff1ec"
    static let MobFoxHashInter = "267d72ac3f77a3f447b32cf7ebf20673"
    static let MobFoxHashNative = "80187188f458cfde788d961b6882fd53"
    static let MobFoxHashVideo = "651586294dac23e245f26789c4043aa9"
}

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MobFoxAdDelegate, MobFoxInterstitialAdDelegate, MobFoxNativeAdDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nativeAdView: UIView!
    @IBOutlet weak var innerNativeAdView: UIView!
    @IBOutlet weak var nativeAdTitle: UILabel!
    @IBOutlet weak var nativeAdDescription: UILabel!
    @IBOutlet weak var nativeAdIcon: UIImageView!
    
    internal var invh: String?
    private let cellID = "cellID"
    private var clickURL: URL?
    private var adVideoRect: CGRect!
    
    // MobFox.
    private var mobfoxAd: MobFoxAd!
    private var mobfoxInterAd: MobFoxInterstitialAd!
    private var mobfoxNativeAd: MobFoxNativeAd!
    private var mobfoxVideoAd: MobFoxAd!
    
    // AdMob.
    private var bannerView: GADBannerView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        self.nativeAdView.isHidden = true
        
        let recognizer = UITapGestureRecognizer.init(target: self, action: "handleGesture:")
        self.innerNativeAdView.addGestureRecognizer(recognizer)
        
        // Oreintation dependent in iOS 8 and later.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let bannerWidth = CGFloat(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 728.0 : 320.0)
        let bannerHeight = CGFloat(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 90.0 : 50.0)
        let videoWidth = CGFloat(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 500.0 : 300.0)
        let videoHeight = CGFloat(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 450.0 : 250.0)

        /*** Banner ***/
        let rect = CGRect(origin: CGPoint(x: (screenWidth-bannerWidth)/2, y: screenHeight-bannerHeight), size: CGSize(width: bannerWidth, height: bannerHeight) )
        mobfoxAd = MobFoxAd(InventoryHash.MobFoxHashBanner, withFrame: rect)
        mobfoxAd.delegate = self
        mobfoxAd.refresh = adRefresh as NSNumber!
        self.view.addSubview(mobfoxAd)
        
        /*** Interstitial ***/
        mobfoxInterAd = MobFoxInterstitialAd(InventoryHash.MobFoxHashInter, withRootViewController:self)
        mobfoxInterAd.delegate = self

        /*** Native ***/
        mobfoxNativeAd = MobFoxNativeAd(InventoryHash.MobFoxHashNative)
        mobfoxNativeAd.delegate = self
        
        /*** Video ***/
        let videoTopMargin = CGFloat(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 200.0 : 80.0)
        self.adVideoRect = CGRect(x: (screenWidth - videoWidth)/2, y: self.collectionView.frame.size.height + videoTopMargin, width: videoWidth, height: videoHeight)
        self.initVideoAd()
        
        /*** AdMob ***/
        bannerView = GADBannerView.init(adSize: kGADAdSizeBanner, origin: CGPoint(x: 0, y: 0))
        bannerView.adUnitID = "ca-app-pub-6224828323195096/5240875564​" // "ca-app-pub-3940256099942544/2934735716"
        bannerView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        bannerView.rootViewController = self
        let request = GADRequest()
        //request.testDevices = ["221e6c438e8184e0556942ea14bb214b"] // kGADSimulatorID
        bannerView.load(request)
        self.view.addSubview(bannerView)
        
     
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        print("viewWillDisappear")
        
        super.viewWillDisappear(animated)
        self.removeVideoAd()

    }
    
    //MARK: MobFox Ad Delegate
     func mobFoxAdDidLoad(_ banner: MobFoxAd!) {
        
        print("MobFoxAdDidLoad")
        
    }
    
    func mobFoxAdDidFailToReceiveAdWithError(_ error: NSError!) {
        
        print("MobFoxAdDidFailToReceiveAdWithError: ", error.description)
        
    }
    
    func mobFoxAdClosed() {
        
        print("MobFoxAdClosed")

    }
    
    func mobFoxAdClicked() {
        
        print("MobFoxAdClicked")

    }
    
    //MARK: MobFox Ad Interstitial Delegate
    func mobFoxInterstitialAdDidLoad(_ interstitial: MobFoxInterstitialAd!) {
        
        print("MobFoxInterstitialAdDidLoad")
        
        if(self.mobfoxInterAd.ready){
            self.mobfoxInterAd.show()
        }

    }
    
    func mobFoxInterstitialAdDidFailToReceiveAdWithError(_ error :NSError!) {
    
        print("MobFoxInterstitialAdDidFailToReceiveAdWithError: \(error.description)");
    
    }
    
    func mobFoxInterstitialAdClosed() {
    
    print("MobFoxInterstitialAdClosed")
    
    }
    
    func mobFoxInterstitialAdClicked() {
    
    print("MobFoxInterstitialAdClicked")
    
    }
    
    func mobFoxInterstitialAdFinished() {
    
    print("MobFoxInterstitialAdFinished")
    
    }
    
    //MARK: MobFox Ad Native Delegate
    func mobFoxNativeAdDidLoad(_ ad: MobFoxNativeAd!, withAdData adData: MobFoxNativeData!) {
        
        self.nativeAdIcon.image = UIImage(data: try! Data(contentsOf: adData.icon.url))
        self.nativeAdTitle.text = adData.assetHeadline
        self.nativeAdDescription.text = adData.assetDescription
        self.clickURL = adData.clickURL.absoluteURL
                
    }
    
    func mobFoxNativeAdDidFailToReceiveAdWithError(_ error: NSError!) {
        
        print("MobFoxNativeAdDidFailToReceiveAdWithError")

    }
    
    //MARK: UICollection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("collectionView:didSelectItemAtIndexPath")
        
        let cell = collectionView.cellForItem(at: indexPath)
        if cell != nil {
            cell!.backgroundColor = UIColor.lightGray
        }
        
        switch (indexPath as NSIndexPath).item {
        case 0:
            self.hideAds(indexPath)
            self.removeVideoAd()
            if self.invh != nil {self.mobfoxAd.invh = self.invh!.characters.count > 0 ? self.invh! : InventoryHash.MobFoxHashBanner}
            self.resumeAdRefresh()
            
        case 1:
            self.hideAds(indexPath)
            self.pauseAdRefresh()
            self.removeVideoAd()
            if self.invh != nil {self.mobfoxInterAd.invh = self.invh!.characters.count > 0  ? self.invh! : InventoryHash.MobFoxHashInter}
            self.mobfoxInterAd.load()

        case 2:
            self.hideAds(indexPath)
            self.pauseAdRefresh()
            self.removeVideoAd()
            if self.invh != nil {self.mobfoxNativeAd.invh = self.invh!.characters.count > 0  ? self.invh! : InventoryHash.MobFoxHashNative}
            self.mobfoxNativeAd.load()

        case 3:
            self.hideAds(indexPath)
            self.pauseAdRefresh()
            self.removeVideoAd()
            self.initVideoAd()
            if self.invh != nil {self.mobfoxVideoAd.invh = self.invh!.characters.count > 0  ? self.invh! : InventoryHash.MobFoxHashVideo}
            self.mobfoxVideoAd.load()

            
        default:
             break
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        if cell != nil {
            cell?.backgroundColor = UIColor.white
        }
        
    }
    
    //MARK: UICollection View Data Source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID , for: indexPath) as! CollectionViewCell
        
        cell.title.text = self.adTitle(indexPath)
        cell.image.image = self.adImage(indexPath)

        if cell.isSelected {
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.backgroundColor = UIColor.white // Default color
        }
        
        return cell
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 4
    }
    
    //MARK: Private Functions
    private func adTitle(_ indexPath: IndexPath) ->String {
        
        switch (indexPath as NSIndexPath).item {
        case 0:
            return "Banner"
        case 1:
            return "Interstitial"
        case 2:
            return "Native"
        case 3:
            return "Video"
            
        default:
            return ""
        }
        
    }
    
    private func adImage(_ indexPath: IndexPath) ->UIImage {
        
        switch (indexPath as NSIndexPath).item {
        case 0:
            return UIImage(named:"test_banner.png")!
        case 1:
            return UIImage(named:"test_interstitial.png")!
        case 2:
            return UIImage(named:"test_native.png")!
        case 3:
            return UIImage(named:"test_video.png")!
            
        default:
            return UIImage()
        }
        
    }
    
    private func hideAds(_ indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).item {
            
        case 0:
            self.mobfoxAd.isHidden = false
            self.nativeAdView.isHidden = true
            if self.mobfoxVideoAd != nil {self.mobfoxVideoAd.isHidden = true}
            
        case 1:
            self.mobfoxAd.isHidden = true
            self.nativeAdView.isHidden = true
            if self.mobfoxVideoAd != nil {self.mobfoxVideoAd.isHidden = true}
            
        case 2:
            self.mobfoxAd.isHidden = true
            self.nativeAdView.isHidden = false
            if self.mobfoxVideoAd != nil {self.mobfoxVideoAd.isHidden = true}
            
        case 3:
            self.mobfoxAd.isHidden = true
            self.nativeAdView.isHidden = true
            if self.mobfoxVideoAd != nil {self.mobfoxVideoAd.isHidden = true}
            
        default:
            break
            
        }
        
    }
        
    private func initVideoAd() {
        
        if (self.mobfoxVideoAd == nil) {
            
            self.mobfoxVideoAd = MobFoxAd(InventoryHash.MobFoxHashVideo, withFrame: self.adVideoRect)
            self.mobfoxVideoAd.delegate = self
            self.mobfoxVideoAd.type = "video"
            self.view.addSubview(self.mobfoxVideoAd)
        }
    }
    
    private func removeVideoAd () {
        
        if self.mobfoxVideoAd != nil {
        
        //self.mobfoxVideoAd.stopPlayback()
        self.mobfoxAd.removeFromSuperview()
        self.mobfoxVideoAd = nil
        
        }
        
    }
    
    private func pauseAdRefresh (){
        
        if(adRefresh > 0) {
            
            self.mobfoxAd.refresh = NSNumber.init(value: 0)
            self.mobfoxAd.load()
            self.mobfoxAd.removeFromSuperview()
        }
    }
    
    private func resumeAdRefresh () {
        
        if(adRefresh > 0) {
            
            self.view.addSubview(self.mobfoxAd)
            self.mobfoxAd.refresh = NSNumber.init(value: adRefresh)
            self.mobfoxAd.load()
            
        } else {
            
            self.mobfoxAd.refresh = NSNumber.init(value: adRefresh)
            self.mobfoxAd.load()
        }
    }
    
    private func handleGesture( _ gestureRecognizer: UIGestureRecognizer) {
        
        if (self.clickURL != nil) {
            UIApplication.shared.openURL(self.clickURL!)
        }
    }
    
}

