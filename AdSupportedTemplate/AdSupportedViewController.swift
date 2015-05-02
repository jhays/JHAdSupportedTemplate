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

class AdSupportedViewController : UIViewController,
                              ADBannerViewDelegate,
                          ADInterstitialAdDelegate,
                             GADBannerViewDelegate,
                           GADInterstitialDelegate{
    
    
//MARK: iAd Properties
    
    //iAd Banner
    var isIAdBannerDisplaying = false
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
    
    var adServiceMode = AdServiceMode.AppleiAdWithGoogleAdMobFallback {
        didSet {
            
            removeAdBannerView()
            removeAdmMobBannerView()

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
    
//MARK: Combined Ad Controls
    
    func setupBannerAd() {
        switch adServiceMode {
        case .AppleiAd:
            setupAdBannerView()
        case .GoogleAdMob:
            if let adMobAdUnitId = adMobAdUnitId {
                setupAdMobBannerView(adMobAdUnitId, testDevices: adMobTestDeviceIds)
            }
        case .AppleiAdWithGoogleAdMobFallback:
            setupAdBannerView()
        case .GoogleAdMobWithAppleiAdFallback:
            if let adMobAdUnitId = adMobAdUnitId {
                setupAdMobBannerView(adMobAdUnitId, testDevices: adMobTestDeviceIds)
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
                    constant = 0.0
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
        
        switch adBannerLocation {
        case .Top:
            if adBannerViewTopConstraint != nil {
                if isIAdBannerDisplaying {
                    adBannerViewTopConstraint.constant = -adBannerView!.frame.height
                    tempIsIAdBannerDisplaying = false
                }else{
                    adBannerViewTopConstraint.constant = 0
                    tempIsIAdBannerDisplaying = true
                }
            }
        case .Bottom:
            if adBannerViewBottomConstraint != nil {
                if isIAdBannerDisplaying {
                    adBannerViewBottomConstraint.constant = adBannerView!.frame.height
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
        }
    }
    
//MARK: ADBannerViewDelegate
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("bannerView didFail: \(error.localizedDescription)")
        if adServiceMode == .AppleiAdWithGoogleAdMobFallback {
            if let adMobAdUnitId = adMobAdUnitId {
                setupAdMobBannerView(adMobAdUnitId, testDevices: adMobTestDeviceIds)
            }
        }
    }
    
    
//MARK: AdMob
    

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
            requestInterstitialAd()
        }
    }
    
    
    
    //MARK: AdMob Banner
    
    func setupAdMobBannerView(adUnitID:String, testDevices:[String]) {
        NSLog("setupAdmobBannerView")
        let request = GADRequest()
        
        request.testDevices = testDevices
        
        adMobBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: CGPointMake(0, 0))
        adMobBannerView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        adMobBannerView!.adUnitID = adUnitID
        
        adMobBannerView!.rootViewController = self
        adMobBannerView!.delegate = self
        
        adMobBannerView!.loadRequest(request)
        
        view.addSubview(adMobBannerView!)
        isAdMobBannerDisplaying = true
        updateAdMobConstraints()
        
    }
    
    func removeAdmMobBannerView() {
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
                    constant = 0
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
        var tempIsAdMobBannerDisplaying = isAdMobBannerDisplaying
        
        switch adBannerLocation {
        case .Top:
            if adMobBannerViewTopConstraint != nil {
                if isAdMobBannerDisplaying {
                    adMobBannerViewTopConstraint.constant = -adMobBannerView!.frame.height
                    tempIsAdMobBannerDisplaying = false
                }else{
                    adMobBannerViewTopConstraint.constant = 0
                    tempIsAdMobBannerDisplaying = true
                }
            }
        case .Bottom:
            if adMobBannerViewBottomConstraint != nil {
                if isAdMobBannerDisplaying {
                    adMobBannerViewBottomConstraint.constant = adMobBannerView!.frame.height
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