//
//  AdSupportedViewController.swift
//  AdSupportedTemplate
//
//  Created by orbosphere on 4/14/15.
//  Copyright (c) 2015 orbosphere. All rights reserved.
//

import Foundation
import iAd
import GoogleMobileAds
import StoreKit

class AdSupportedViewController : UIViewController,
    ADBannerViewDelegate,
    ADInterstitialAdDelegate,
    GADBannerViewDelegate,
    GADInterstitialDelegate,
SKStoreProductViewControllerDelegate{
    
    //MARK:Helpers
    var adBannerIsLoaded = false {
        didSet{
            self.adjustViewForBannerView()
        }
    }
    var adMobBannerIsLoaded = false {
        didSet {
            self.adjustViewForBannerView()
        }
    }
    
    var adBannerBuffer: Int {
        get {
            var multiplier = CGFloat(1)
            
            if self.isAdMobBannerDisplaying || self.isIAdBannerDisplaying {
                if self.isIAdBannerDisplaying {
                    return Int(self.adBannerView!.frame.size.height * multiplier)
                }else if self.isAdMobBannerDisplaying {
                    return Int(self.adMobBannerView!.frame.size.height * multiplier)
                }else {
                    return 0
                }
            }else {
                return 0
            }
        }
    }
    
    //MARK: In-App-Purchase Properties
    
    var progressHUD :MBProgressHUD?
    var product: SKProduct?
    var persistence: RMStoreKeychainPersistence!
    var productIdentifiers = [AnyObject]()
    
    //MARK: iAd Properties
    
    //iAd Banner
    var isIAdBannerDisplaying = false {
        didSet{
            self.adjustViewForBannerView()
        }
    }
    
    
    var adBannerView: ADBannerView?
    var adBannerViewTopConstraint: NSLayoutConstraint!
    var adBannerViewBottomConstraint: NSLayoutConstraint!
    var adBannerViewCenterHorizontalConstraint: NSLayoutConstraint!
    
    //iAd Interstitial
    var interstitialAd: ADInterstitialAd!
    var interstitialAdView: UIView = UIView()
    var interstitialCloseButton:UIButton!
    var interstitialTimer: NSTimer?
    
    //MARK: AdMob Properties
    
    //Google AdMob Banner
    
    var adMobTestDeviceIds = [String]()
    var adMobAdUnitId: String?
    //NOTE: During development, it is recommended to utilize test ads to avoid generating false impressions. Additionally, you can always count on a test ad being available.
    //Starting in SDK version 7.0.0, simulators will automatically show test ads.
    
    //AdMob Targeting (optional) NOTE: set targeting before calling setupBannerAd or requestInterstitialAd
    var adMobTargetLocationLatitude: CGFloat?
    var adMobTargetLocationLongitude: CGFloat?
    var adMobTargetLocationAccuracy: CGFloat?
    var adMobTargetLocationString: String?
    var adMobTargetGender: AdMobTargetGenders?
    var adMobTargetBirthdate: NSDate?
    var adMobTargetForChildren = false
    var adMobTargetContentURLString: String?
    
    var isAdMobBannerDisplaying = false
    var adMobBannerView: GADBannerView?
    var adMobBannerViewTopConstraint: NSLayoutConstraint!
    var adMobBannerViewBottomConstraint: NSLayoutConstraint!
    var adMobBannerViewCenterHorizontalConstraint: NSLayoutConstraint!
    
    var adMobInterstitialAd : GADInterstitial?
    
    //MARK: Configuration Properties
    
    enum AdServiceMode {
        case AppleiAd, GoogleAdMob, AppleiAdWithGoogleAdMobFallback, GoogleAdMobWithAppleiAdFallback
    }
    
    enum AdBannerLocation {
        case Top, Bottom
    }
    
    enum AdMobTargetGenders {
        case Male, Female
    }
    
    var adServiceMode = AdServiceMode.AppleiAdWithGoogleAdMobFallback {
        didSet {
            
            removeAdBannerView()
            removeAdMobBannerView()
            
            switch adServiceMode {
            case .AppleiAd:
                NSLog("Ad Service Mode: Apple iAd")
                
            case .GoogleAdMob:
                if let adMobAdUnitId = adMobAdUnitId {
                    NSLog("Ad Service Mode: Google AdMob")
                }else {
                    NSLog("Google AdMob AdUnitId is NOT SET! Defaulting to Apple iAd mode")
                    adServiceMode = .AppleiAd
                }
            case .AppleiAdWithGoogleAdMobFallback:
                if let adMobAdUnitId = adMobAdUnitId {
                    NSLog("Ad Service Mode: Apple iAd with Google AdMob fallback")
                }else {
                    NSLog("Google AdMob AdUnitId is NOT SET! Defaulting to Apple iAd mode")
                    adServiceMode = .AppleiAd
                }
            case .GoogleAdMobWithAppleiAdFallback:
                if let adMobAdUnitId = adMobAdUnitId {
                    NSLog("Ad Service Mode: Google AdMob with Apple iAd fallback")
                }else {
                    NSLog("Google AdMob AdUnitId is NOT SET! Defaulting to Apple iAd mode")
                    adServiceMode = .AppleiAd
                }
            }
            setupBannerAd()
        }
    }
    
    
    var adBannerLocation = AdBannerLocation.Top {
        didSet {
            updateIAdConstraints()
            updateAdMobConstraints()
        }
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Manual
        NSLog("Google Mobile Ads SDK Version: \(GADRequest.sdkVersion())")
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        NSLog("transition to trait collection: \(newCollection)")
        coordinator.animateAlongsideTransition({ (context) -> Void in
            
            }, completion: { (context) -> Void in
                
        })
    }
    
    func adjustViewForBannerView() {
        
    }
    
    //MARK: In App Purchase
    
    func requestPurchase(productID:String, success: () -> Void, failure: (error: NSError) -> Void) {
        var prodIdentifiers = Set<NSObject>()
        prodIdentifiers.insert(productID)
        
        progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD?.mode = MBProgressHUDMode.Indeterminate
        progressHUD?.labelText = ""
        progressHUD?.show(true)
        
        RMStore.defaultStore().requestProducts( prodIdentifiers, success: { (products, invalidProductIdentifiers) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.progressHUD?.hide(true)
            })
            NSLog("products loaded")
            if products.count > 0 {
                self.product = products[0] as? SKProduct
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showPurchaseAlert(productID, success:success , failure:failure)
                })
                
            }else{
                failure(error:NSError(domain: "IAP", code: 0, userInfo: [NSLocalizedDescriptionKey:"Unable to load product"]))
            }
            
            }) { (error) -> Void in
                NSLog("error requesting IAPs: \(error.localizedDescription)")
                dispatch_async(dispatch_get_main_queue(),{
                    self.progressHUD?.hide(true)
                })
                failure(error: error)
        }
        
    }
    
    func requestRestorePurchase(productID:String, success: () -> Void, failure: (error: NSError) -> Void) {
        
        
        progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressHUD?.mode = MBProgressHUDMode.Indeterminate
        //progressHUD?.labelText = "Remove Ads"
        
        RMStore.defaultStore().restoreTransactionsOnSuccess({ (transactions) -> Void in
            dispatch_async(dispatch_get_main_queue(),{
                self.progressHUD?.hide(true)
            })
            
            NSLog("transactions restored")
            
            let store = RMStore.defaultStore()
            self.persistence = store.transactionPersistor as? RMStoreKeychainPersistence
            self.productIdentifiers = (self.persistence.purchasedProductIdentifiers() as NSSet).allObjects
            if self.persistence.isPurchasedProductOfIdentifier(productID) {
                success()
            }else {
                failure(error:NSError(domain: "IAP", code: 0, userInfo: [NSLocalizedDescriptionKey:"Purchase not found"]))
            }
            
            }, failure: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(),{
                    self.progressHUD?.hide(true)
                })
                failure(error:error)
        })
        
    }
    
    private func showPurchaseAlert(productID:String, success: () -> Void, failure: (error: NSError) -> Void) {
        
        if let product = product {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
            numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            numberFormatter.locale = product.priceLocale
            let formattedString = numberFormatter.stringFromNumber(product.price)
            
            var alert = UIAlertController(title: product.localizedTitle, message: "\(product.localizedDescription) for \(formattedString!)?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Buy", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
                //self.progressHUD?.labelText = "Removing Ads"
                self.progressHUD?.show(true)
                
                RMStore.defaultStore().addPayment(productID, success: { (transaction) -> Void in
                    dispatch_async(dispatch_get_main_queue(),{
                        self.progressHUD?.hide(true)
                    })
                    
                    NSLog("Purchase made for \(productID)")
                    success()
                    
                    }, failure: { (transaction, error) -> Void in
                        dispatch_async(dispatch_get_main_queue(),{
                            self.progressHUD?.hide(true)
                        })
                        NSLog("Error making purchase: \(error.localizedDescription)")
                        failure(error:error)
                })
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
            
        }else{
            failure(error:NSError(domain: "IAP", code: 0, userInfo: [NSLocalizedDescriptionKey:"Product not found"]))
        }
    }
    
    func showStoreView(appId: Int) {
        NSLog("showStoreView: \(appId)")
        NSLog("Note- this only works on a real device. It does not work on the Simulator")
        
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [SKStoreProductParameterITunesItemIdentifier :
            NSNumber(integer: appId)] //791588355
        
        storeViewController.loadProductWithParameters(parameters,
            completionBlock: {result, error in
                if result {
                    self.presentViewController(storeViewController,
                        animated: true, completion: nil)
                }
                if error != nil {
                    println("error showing store view: \(error.localizedDescription)")
                }
                
        })
        
    }
    
    func productViewControllerDidFinish(viewController:
        SKStoreProductViewController!) {
            viewController.dismissViewControllerAnimated(true,
                completion: nil)
    }
    
    //MARK: Combined Ad Controls
    
    func setupBannerAd() {
        switch adServiceMode {
        case .AppleiAd:
            setupAdBannerView()
        case .GoogleAdMob:
            if let adMobAdUnitId = adMobAdUnitId {
                setupAdMobBannerView()
            }
        case .AppleiAdWithGoogleAdMobFallback:
            setupAdBannerView()
        case .GoogleAdMobWithAppleiAdFallback:
            if let adMobAdUnitId = adMobAdUnitId {
                setupAdMobBannerView()
            }
        }
    }
    
    func toggleBannerAd() {
        switch adServiceMode {
        case .AppleiAd:
            toggleiAdBannerAd()
        case .GoogleAdMob:
            toggleAdMobBannerAd()
        default:
            toggleiAdBannerAd()
            toggleAdMobBannerAd()
        }
    }
    
    func requestInterstitialAd() {
        switch adServiceMode {
        case .AppleiAd, .AppleiAdWithGoogleAdMobFallback:
            requestAppleInterstitialAd()
        case .GoogleAdMob, .GoogleAdMobWithAppleiAdFallback:
            if let adMobAdUnitId = adMobAdUnitId {
                requestAdMobInterstitialAd(adMobAdUnitId, testDevices: adMobTestDeviceIds)
            }
        }
        
    }
    
    func adMobSizeForTraitCollection(traitCollection:UITraitCollection) {
        
        ADBannerView(adType: ADAdType.Banner)// ADBannerContentSizeIdentifier320x50
    }
    
    //MARK: ADInterstitialAd
    
    func requestAppleInterstitialAd() {
        NSLog("requestInterstitialAd")
        interstitialAd = ADInterstitialAd()
        interstitialAd.delegate = self
    }
    
    //MARK: AdInterstitialAdDelegate⍜
    
    func closeInterstitialAd() {
        NSLog("closeInterstitialAd")
        interstitialAdView.removeFromSuperview()
        interstitialCloseButton.removeFromSuperview()
        interstitialAd = nil
    }
    
    func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
        NSLog("interstitialWillLoad")
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        NSLog("interstitialAdDidLoad")
        if (interstitialAd.loaded) {
            NSLog("adding interstitial Ad to view")
            interstitialAdView = UIView()
            interstitialAdView.frame = self.view.bounds
            view.addSubview(interstitialAdView)
            
            interstitialCloseButton = UIButton(frame: CGRect(x: self.view.bounds.width - 50, y:  25, width: 25, height: 25))
            //interstitialCloseButton.setBackgroundImage(UIImage(named: "error"), forState: UIControlState.Normal)
            interstitialCloseButton.setTitle("✕", forState: UIControlState.Normal)
            interstitialCloseButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            interstitialCloseButton.titleLabel?.font = UIFont(name: interstitialCloseButton.titleLabel!.font.fontName, size: 30.0)
            interstitialCloseButton.addTarget(self, action: Selector("closeInterstitialAd"), forControlEvents: UIControlEvents.TouchDown)
            self.view.addSubview(interstitialCloseButton)
            
            interstitialAd.presentInView(interstitialAdView)
        }else{
            NSLog("intierstitialAd loaded but not really")
        }
        
        UIViewController.prepareInterstitialAds()
    }
    
    
    
    func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
        NSLog("interstitialAdActionDidFinish")
        interstitialAdView.removeFromSuperview()
        interstitialCloseButton.removeFromSuperview()
    }
    
    func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
        NSLog("interstitialAdActionShouldBegin")
        return true
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        NSLog("interstitialAd didFailWithError: \(error.localizedDescription)")
        if adServiceMode == .AppleiAdWithGoogleAdMobFallback && adMobAdUnitId != nil{
            requestAdMobInterstitialAd(adMobAdUnitId!, testDevices: adMobTestDeviceIds)
        }
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        NSLog("interstitialAdDidUnload")
        interstitialAdView.removeFromSuperview()
        interstitialCloseButton.removeFromSuperview()
    }
    
    //MARK: ADBannerView
    
    func setupAdBannerView() {
        NSLog("setupAdBannerView")
        if adBannerView == nil {
            adBannerView = ADBannerView(adType: ADAdType.Banner)
            adBannerView!.delegate = self
            adBannerView!.setTranslatesAutoresizingMaskIntoConstraints(false)
            isIAdBannerDisplaying = true
            view.addSubview(adBannerView!)
            updateIAdConstraints()
            
        }
    }
    
    
    
    func removeAdBannerView() {
        NSLog("removeAdBannerView")
        adBannerView?.removeFromSuperview()
        adBannerView = nil
    }
    
    func updateIAdConstraints() {
        NSLog("updateIAdConstraints")
        if adBannerViewTopConstraint != nil {
            view.removeConstraint(adBannerViewTopConstraint)
        }
        if adBannerViewBottomConstraint != nil {
            view.removeConstraint(adBannerViewBottomConstraint)
        }
        if adBannerViewCenterHorizontalConstraint != nil {
            view.removeConstraint(adBannerViewCenterHorizontalConstraint)
        }
        switch adBannerLocation {
        case .Top:
            if adBannerView != nil {
                var constant = -adBannerView!.frame.height
                if isIAdBannerDisplaying {
                    constant = 20.0
                }
                adBannerViewCenterHorizontalConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: adBannerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
                adBannerViewTopConstraint = NSLayoutConstraint(item: adBannerView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: constant)
                view.addConstraints([adBannerViewCenterHorizontalConstraint, adBannerViewTopConstraint])
            }
        case .Bottom:
            if adBannerView != nil {
                var constant = adBannerView!.frame.height
                if isIAdBannerDisplaying {
                    constant = 0
                }
                adBannerViewCenterHorizontalConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: adBannerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
                adBannerViewBottomConstraint = NSLayoutConstraint(item: adBannerView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: bottomLayoutGuide, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: constant)
                view.addConstraints([adBannerViewCenterHorizontalConstraint, adBannerViewBottomConstraint])
            }
        default:
            adBannerLocation = .Top
            updateIAdConstraints()
        }
        
        view.layoutIfNeeded()
    }
    
    func toggleiAdBannerAd() {
        NSLog("toggleiAdBannerAd")
        var tempIsIAdBannerDisplaying = isIAdBannerDisplaying
        if let adBannerView = self.adBannerView {
            self.adBannerView!.hidden = false
            
            switch adBannerLocation {
            case .Top:
                if adBannerViewTopConstraint != nil {
                    if isIAdBannerDisplaying {
                        adBannerViewTopConstraint.constant = -adBannerView.frame.height
                        tempIsIAdBannerDisplaying = false
                    }else{
                        adBannerViewTopConstraint.constant = 20
                        tempIsIAdBannerDisplaying = true
                    }
                }
            case .Bottom:
                if adBannerViewBottomConstraint != nil {
                    if isIAdBannerDisplaying {
                        adBannerViewBottomConstraint.constant = adBannerView.frame.height
                        tempIsIAdBannerDisplaying = false
                    }else{
                        adBannerViewBottomConstraint.constant = 0
                        tempIsIAdBannerDisplaying = true
                    }
                }
            default:
                adBannerLocation = .Top
                toggleiAdBannerAd()
            }
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }) { (success) -> Void in
                    self.isIAdBannerDisplaying = tempIsIAdBannerDisplaying
                    if self.isIAdBannerDisplaying == false {
                        if self.adBannerView != nil {
                            self.adBannerView!.hidden = true
                        }
                    }
            }
        }
    }
    
    //MARK: ADBannerViewDelegate
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBannerIsLoaded = true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("bannerView didFail: \(error.localizedDescription)")
        if adServiceMode == .AppleiAdWithGoogleAdMobFallback {
            if let adMobAdUnitId = adMobAdUnitId {
                setupAdMobBannerView()
            }
        }
    }
    
    
    //MARK: AdMob
    
    
    func setAdMobTargetLocation(longitude: CGFloat, latitude: CGFloat, accuracy: CGFloat) {
        self.adMobTargetLocationLongitude = longitude
        self.adMobTargetLocationLatitude = latitude
        self.adMobTargetLocationAccuracy = accuracy
    }
    
    func setupAdMobRequest() -> GADRequest {
        var request = GADRequest()
        
        request.testDevices = adMobTestDeviceIds
        
        if let  latitude = adMobTargetLocationLatitude, longitude = self.adMobTargetLocationLongitude, accuracy = adMobTargetLocationAccuracy {
            request.setLocationWithLatitude(latitude, longitude: longitude, accuracy: accuracy)
        }else if let locationString = adMobTargetLocationString {
            request.setLocationWithDescription(locationString)
        }
        
        if let gender = adMobTargetGender {
            if gender == .Male {
                request.gender = GADGender.Male
            }else if gender == .Female {
                request.gender = GADGender.Female
            }
        }
        
        if let birthdate = adMobTargetBirthdate {
            request.birthday = birthdate
        }
        
        if adMobTargetForChildren == true {
            request.tagForChildDirectedTreatment(true)
        }
        
        if let contentURL = adMobTargetContentURLString {
            request.contentURL = contentURL
        }
        
        return request
    }
    
    //MARK: AdMob Interstitial
    func requestAdMobInterstitialAd(adUnitID:String, testDevices:[String]) {
        NSLog("requestAdMobInterstitialAd")
        let request = GADRequest()
        request.testDevices = testDevices
        
        adMobInterstitialAd = GADInterstitial()
        adMobInterstitialAd?.delegate = self
        adMobInterstitialAd?.adUnitID = adUnitID
        adMobInterstitialAd?.loadRequest(request)
    }
    
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        NSLog("interstitialDidDismissScreen")
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        NSLog("interstitialDidReceiveAd")
        adMobInterstitialAd?.presentFromRootViewController(self)
    }
    
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        NSLog("interstitialAd (admob) didFailToReceiveAdWithError \(error)")
        if adServiceMode == .GoogleAdMobWithAppleiAdFallback {
            requestAppleInterstitialAd()
        }
    }
    
    
    
    //MARK: AdMob Banner
    
    func setupAdMobBannerView() {
        NSLog("setupAdmobBannerView")
        
        if let adUnitId = adMobAdUnitId {
            if adMobBannerView == nil {
                let request = setupAdMobRequest()
                
                adMobBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: CGPointMake(0, 0))
                adMobBannerView!.setTranslatesAutoresizingMaskIntoConstraints(false)
                
                adMobBannerView!.adUnitID = adMobAdUnitId
                
                adMobBannerView!.rootViewController = self
                adMobBannerView!.delegate = self
                
                adMobBannerView!.loadRequest(request)
                
                view.addSubview(adMobBannerView!)
                isAdMobBannerDisplaying = true
                updateAdMobConstraints()
            }
        }else {
            NSLog("ERROR: cannot setup AdMobBannerView - adMobAdUnitId is not set.")
        }
        
    }
    
    func removeAdMobBannerView() {
        adMobBannerView?.removeFromSuperview()
        adMobBannerView = nil
    }
    
    func updateAdMobConstraints() {
        NSLog("updateAdMobConstraints")
        if adMobBannerViewTopConstraint != nil {
            view.removeConstraint(adMobBannerViewTopConstraint)
        }
        if adMobBannerViewBottomConstraint != nil {
            view.removeConstraint(adMobBannerViewBottomConstraint)
        }
        if adMobBannerViewCenterHorizontalConstraint != nil {
            view.removeConstraint(adMobBannerViewCenterHorizontalConstraint)
        }
        switch adBannerLocation {
        case .Top:
            if adMobBannerView != nil {
                var constant = -adMobBannerView!.frame.height
                if isAdMobBannerDisplaying {
                    constant = 20
                }
                adMobBannerViewCenterHorizontalConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: adMobBannerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
                adMobBannerViewTopConstraint = NSLayoutConstraint(item: adMobBannerView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: constant)
                view.addConstraints([adMobBannerViewCenterHorizontalConstraint, adMobBannerViewTopConstraint])
            }
        case .Bottom:
            if adMobBannerView != nil {
                var constant = adMobBannerView!.frame.height
                if isAdMobBannerDisplaying {
                    constant = 0
                }
                adMobBannerViewCenterHorizontalConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: adMobBannerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
                adMobBannerViewBottomConstraint = NSLayoutConstraint(item: adMobBannerView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: bottomLayoutGuide, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: constant)
                view.addConstraints([adMobBannerViewCenterHorizontalConstraint, adMobBannerViewBottomConstraint])
            }
        default:
            adBannerLocation = .Top
            updateAdMobConstraints()
        }
        
        view.layoutIfNeeded()
    }
    
    func toggleAdMobBannerAd()  {
        NSLog("toggleAdMobBannerAd")
        if let adMobBannerView = self.adMobBannerView {
            
            var tempIsAdMobBannerDisplaying = isAdMobBannerDisplaying
            adMobBannerView.hidden = false
            
            switch adBannerLocation {
            case .Top:
                if adMobBannerViewTopConstraint != nil {
                    if isAdMobBannerDisplaying {
                        adMobBannerViewTopConstraint.constant = -adMobBannerView.frame.height
                        tempIsAdMobBannerDisplaying = false
                    }else{
                        adMobBannerViewTopConstraint.constant = 20
                        tempIsAdMobBannerDisplaying = true
                    }
                }
            case .Bottom:
                if adMobBannerViewBottomConstraint != nil {
                    if isAdMobBannerDisplaying {
                        adMobBannerViewBottomConstraint.constant = adMobBannerView.frame.height
                        tempIsAdMobBannerDisplaying = false
                    }else{
                        adMobBannerViewBottomConstraint.constant = 0
                        tempIsAdMobBannerDisplaying = true
                    }
                }
            default:
                adBannerLocation = .Top
                toggleAdMobBannerAd()
            }
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }) { (success) -> Void in
                    self.isAdMobBannerDisplaying = tempIsAdMobBannerDisplaying
                    if self.isAdMobBannerDisplaying == false {
                        if self.adMobBannerView != nil {
                            self.adMobBannerView!.hidden = true
                        }
                    }
            }
        }
        
    }
    
    //MARK: GADBannerViewDelegate
    
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        NSLog("adView didFailToReceiveAdWithError \(GADRequestError.description())")
        if adServiceMode == .GoogleAdMobWithAppleiAdFallback {
            setupAdBannerView()
        }
    }
    
    func adViewDidDismissScreen(adView: GADBannerView!) {
        NSLog("adViewDidDismissScreen")
        
    }
    
    func adViewDidReceiveAd(view: GADBannerView!) {
        NSLog("adViewDidReceiveAd")
        adMobBannerIsLoaded = true
    }
    
    func adViewWillDismissScreen(adView: GADBannerView!) {
        NSLog("adViewWillDismissScreen")
    }
    
    func adViewWillLeaveApplication(adView: GADBannerView!) {
        NSLog("adViewWillLeaveApplication")
    }
    
    func adViewWillPresentScreen(adView: GADBannerView!) {
        NSLog("adViewWillPresentScreen")
    }
    
}