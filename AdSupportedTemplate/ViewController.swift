//
//  ViewController.swift
//  AdSupportedTemplate
//
//  Created by Julian Hays on 4/13/15.
//  Copyright (c) 2015 orbosphere. All rights reserved.
//

import UIKit

class ViewController: AdSupportedViewController {

    @IBOutlet weak var toggleAdServiceModeBtn: UIButton!
    @IBOutlet weak var removeAdsBtn: UIButton!
    @IBOutlet weak var restoreIAPBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

/* *** Ad Supported View Controller superclass setup *** */
        adMobAdUnitId = "ca-app-pub-2935377384188916/5512719901"
 
        adMobTestDeviceIds = ["a3b05331603282d5c6a6c14df6c3b61c5d701563", "4a41294bc411c886e257f8e32c1d77a8d469c8e5"]
        
        //OPTIONAL: AdMob Targeting. Uncomment to setup different types of targeting. Applies to Google AdMob adds only.
        
        //adMobTargetBirthdate = NSDate(timeIntervalSinceReferenceDate: 86400)
        //adMobTargetLocationLatitude = 44.9778
        //adMobTargetLocationLongitude = 93.2650
        //adMobTargetLocationString = "55401"
        //adMobTargetGender = AdMobTargetGenders.Male
        //adMobTargetForChildren = true
        

        //REQUIRED: Simply set the adServiceMode property to activate banner ads
        //AdServiceMode:
            //.AppleiAd
            //.GoogleAdMob
            //.AppleiAdWithGoogleAdMobFallback //If Apple iAd fails to load, Google AdMob service will be loaded instead
            //.GoogleAdMobWithAppleiAdFallback //If Google AdMob fails to load, Apple iAd service will be loaded instead
        
        adServiceMode = AdServiceMode.AppleiAd

/* *** End of Ad Supported View Controller superclass setup *** */
        
        
        //Check for existing purchase of ad removal
        persistence = (UIApplication.sharedApplication().delegate as! AppDelegate).persistence
        productIdentifiers = (persistence.purchasedProductIdentifiers() as NSSet).allObjects
        var productID = "com.orbosphere.adsupportedtemplate.removeads"
        if persistence.isPurchasedProductOfIdentifier(productID) {
            NSLog("Purchase found- removing ads")
            self.removeAdBannerView()
            self.removeAdMobBannerView()
        }else{
            NSLog("Purchase not found.")
        }
        
        //Button config
        removeAdsBtn.titleLabel?.numberOfLines = 0
        removeAdsBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        restoreIAPBtn.titleLabel?.numberOfLines = 0
        restoreIAPBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        toggleAdServiceModeBtn.titleLabel?.numberOfLines = 0
        toggleAdServiceModeBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        toggleAdServiceModeBtn.setTitle("Ad Service Mode:\nApple iAd with Google AdMob fallback", forState: UIControlState.Normal)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "orbospherecom_tile")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func toggleAdBannerLocationBtnPressed(sender: AnyObject) {
        if adBannerLocation == .Top {
           adBannerLocation = .Bottom
        }else{
            adBannerLocation = .Top
        }
    }
    
    
    @IBAction func toggleAdBannerDisplayBtnPressed(sender: AnyObject) {
        toggleBannerAd()
    }

    
    @IBAction func toggleAdServiceMode(sender: AnyObject) {
        toggleAdServiceModeBtn.titleLabel?.numberOfLines = 0
        toggleAdServiceModeBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        switch adServiceMode {
        case .AppleiAd:
            adServiceMode = .GoogleAdMob
        case .GoogleAdMob:
            adServiceMode = .AppleiAdWithGoogleAdMobFallback
        case .AppleiAdWithGoogleAdMobFallback:
            adServiceMode = .GoogleAdMobWithAppleiAdFallback
        case .GoogleAdMobWithAppleiAdFallback:
            adServiceMode = .AppleiAd
        }
        //After setting adServiceMode, it may auto-reset to Apple iAd only if the Google AdMob adUnitId is not set.
        switch adServiceMode {
        case .AppleiAd:
            toggleAdServiceModeBtn.setTitle("Ad Service Mode:\nApple iAd", forState: UIControlState.Normal)
        case .GoogleAdMob:
             toggleAdServiceModeBtn.setTitle("Ad Service Mode:\nGoogle AdMob", forState: UIControlState.Normal)
        case .AppleiAdWithGoogleAdMobFallback:
            toggleAdServiceModeBtn.setTitle("Ad Service Mode:\nApple iAd with Google AdMob fallback", forState: UIControlState.Normal)
        case .GoogleAdMobWithAppleiAdFallback:
           toggleAdServiceModeBtn.setTitle("Ad Service Mode:\nGoogle AdMob with Apple iAd fallback", forState: UIControlState.Normal)
        }
        
    }

    @IBAction func requestInterstitialBtnPressed(sender: AnyObject) {
        requestInterstitialAd()
    }
    
//MARK: In-App-Purchase Button Actions
    
    @IBAction func removeAdsBtnPressed(sender: AnyObject) {
        
        /* *** Specify that IAP product ID that you wish to use for the ad removal IAP (configured on your iTunes Connect account) *** */
        var productID = "com.orbosphere.adsupportedtemplate.removeads"
        
        requestPurchase(productID, success: { () -> Void in
            
            self.removeAdBannerView()
            self.removeAdMobBannerView()
            
        }) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                var alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func restoreIAPBtnPressed(sender: AnyObject) {
        
        /* *** Specify that IAP product ID that you wish to use for the ad removal IAP (configured on your iTunes Connect account) *** */
        var productID = "com.orbosphere.adsupportedtemplate.removeads"
        
        requestRestorePurchase(productID, success: { () -> Void in
            
            self.removeAdBannerView()
            self.removeAdMobBannerView()
            
            dispatch_async(dispatch_get_main_queue(), {
                var alert = UIAlertController(title: "Purchase Restored", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
        }) { (error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                var alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func showAppStoreView(sender: AnyObject) {
        //this can be utilized to show another product or request the user to leave a review
        //specify the iTunes App ID for the product you wish to display
        showStoreView(791588355)
        
    }
    
    
}

