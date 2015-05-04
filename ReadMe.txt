Ad Supported Template - Swift, iOS 7.1, iOS 8+, iPhone, iPad, Universal device and orientation support
Dual Ad Service Implementation- 
Apple iAd
Google AdMob (Includes user targeting options)

Utilize this project template to monetize your app with Ads and In-App-Purchases. 

If you have an existing project, you can also transfer the AdSupportedViewController into your own project. 

AdSupportedViewController.swift provides a UIViewController subclass that can display banner ads or interstitial/fullscreen ads. 
To utilize ad support, simply set ViewControllers in your app as subclasses of AdSupportedViewController. Then specify they ad service you wish to use. 

The configuration of AdSupportedViewController is as follows. This can likely be placed in your viewDidLoad method. 

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


Copyright 2015 Orbosphere
www.orbosphere.com

