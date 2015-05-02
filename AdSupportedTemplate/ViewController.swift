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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      // setupAdMobBannerView("ca-app-pub-2935377384188916/5512719901", testDevices: ["a3b05331603282d5c6a6c14df6c3b61c5d701563", "4a41294bc411c886e257f8e32c1d77a8d469c8e5"])
        
        toggleAdServiceModeBtn.titleLabel?.numberOfLines = 0
        toggleAdServiceModeBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        
        adMobAdUnitId = "ca-app-pub-2935377384188916/5512719901"
        adMobTestDeviceIds = ["a3b05331603282d5c6a6c14df6c3b61c5d701563", "4a41294bc411c886e257f8e32c1d77a8d469c8e5"]
        adServiceMode = AdServiceMode.AppleiAdWithGoogleAdMobFallback
        toggleAdServiceModeBtn.setTitle("Ad Service Mode:\nApple iAd with Google AdMob fallback", forState: UIControlState.Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchPressed(sender: AnyObject) {
        if adBannerLocation == .Top {
           adBannerLocation = .Bottom
        }else{
            adBannerLocation = .Top
        }
    }
    
    
    @IBAction func togglePressed(sender: AnyObject) {
        toggleBannerAd()
    }

    @IBAction func interstitialBtnPressed(sender: AnyObject) {
        requestAdMobInterstitialAd("ca-app-pub-2935377384188916/5512719901", testDevices: ["a3b05331603282d5c6a6c14df6c3b61c5d701563", "4a41294bc411c886e257f8e32c1d77a8d469c8e5"])
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

    
}

