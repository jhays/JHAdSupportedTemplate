Ad Supported Template - Swift, iOS 7.1, iOS 8+, iPhone, iPad, Universal device and orientation support
Dual Ad Service Implementation- 
Apple iAd
Google AdMob (Includes user targeting options)
In-App-Purchase for Ad Removal, ability to add additional IAPs and restore purchases
Show Store View to showcase other apps or prompt the user for a review

Utilize this project template to monetize your app with Ads and In-App-Purchases. 

If you have an existing project, you can also transfer the AdSupportedViewController into your own project. If you also wish to utilize In App Purchases in your own project, you will also need to transfer RMStore (including the embedded SSL library), and MBPRogressHUD.

AdSupportedViewController.swift provides a UIViewController subclass that can display banner ads or interstitial/fullscreen ads. 
To utilize ad support, simply set ViewControllers in your app as subclasses of AdSupportedViewController. Then specify they ad service you wish to use. 

The configuration of AdSupportedViewController is as follows. This can likely be placed in your viewDidLoad method. 

/* *** Ad Supported View Controller superclass setup *** */
		//to setup an adMob campaign, go to https://www.google.com/admob/. Create your adUnitId there.
        adMobAdUnitId = "" // such as "ca-app-pub-2935377384188917/5512719902" //But don't use this, it is just an example and it is invalid. 
 
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


In App Purchase support utilizes RMStore: 
https://github.com/robotmedia/RMStore

These IAP functions wrap the RMStore functionality with easy to use completion and failure closures. 
IAP functions:

func requestPurchase(productID:String, success: () -> Void, failure: (error: NSError) -> Void)
func requestRestorePurchase(productID:String, success: () -> Void, failure: (error: NSError) -> Void) {

Pass in the product ID of the IAP item (as specified in iTunesConnect). requestPurchase will prompt the user with an alert view to Buy or Cancel. Upon selecting "Buy", it will then initiate the purchase and call success or failure closures. 

To test In App Purchases, you must be logged OUT of any real App Store accounts on the device. Set up a sandbox tester account in iTunes Connect. Run the app, and attempt to make the purchase. At that time, you will be prompted to log in- you must log in with the iTunes Connect sandbox tester account. 

To check for existing purchase, utilize the persistence object that is specified on AppDelegate
Example:
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

Copyright 2015 Orbosphere
www.orbosphere.com

