//
//  ViewController.swift
//  AdSupportedTemplate
//
//  Created by Julian Hays on 4/13/15.
//  Copyright (c) 2015 orbosphere. All rights reserved.
//

import UIKit

class ViewController: AdSupportedViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //setupAdBannerView()
       setupAdMobBannerView("ca-app-pub-2935377384188916/5512719901", testDevices: ["a3b05331603282d5c6a6c14df6c3b61c5d701563", "4a41294bc411c886e257f8e32c1d77a8d469c8e5"])
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
        toggleAdMobBannerAd()
    }

    @IBAction func interstitialBtnPressed(sender: AnyObject) {
        requestAdMobInterstitialAd("ca-app-pub-2935377384188916/5512719901", testDevices: ["a3b05331603282d5c6a6c14df6c3b61c5d701563", "4a41294bc411c886e257f8e32c1d77a8d469c8e5"])
    }

}

