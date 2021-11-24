//
//  AppDelegate.swift
//  KVaultApp
//
//  Created by Fetih Tunay on 13/02/2021.
//  Copyright © Fetih Tunay. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMobileAds
import Firebase
import AppRating

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    typealias InterstialHandler =  (_ isCompleted: Bool) -> Void
    
    var interstialHandler : InterstialHandler?
    var interstitial: GADInterstitial?
    
    var window: UIWindow?
    var homeNav = MainStoryBoard.instantiateViewController(withIdentifier: "HomeNav")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DBManager.sharedInstance.createTable(withTableName: DBTableAlbum, withDictionary: [DBAlbumName:"", DBRowID :"", DBAlbumImage : "", DBAlbumPassword : ""])
        DBManager.sharedInstance.createTable(withTableName: DBTableGallery, withDictionary: [DBGalleryImageName:"", DBRowID :"",  DBTimestamp : "", DBAlbumID : "", DBVideoThumbName : ""])
        
        FirebaseApp.configure()
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        
        IQKeyboardManager.shared.enable = true
        if UtilityClass.isOnboardingSeen(){
            ShowPinScreenWithCallBack { (success) in
                self.setHomeAsRoot()
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showOnboardingViewController({ (index, isSkip) in
                    if isSkip{
                        UtilityClass.setOnboardingSeenFlag(isShow: true)
                        ShowPinScreenWithCallBack {[weak self] (success) in
                            self?.setHomeAsRoot()
                        }
                    }
                })
            }
        }
      //  self.setupRating()
        
        return true
    }
    
    override init() {
        // first set the appID - this must be the very first call of AppRating!
        AppRating.appID("1462193369");
        
        // enable debug mode (disable this in production mode)
        AppRating.debugEnabled(true);
        
        // reset the counters (for testing only);
        // AppRating.resetAllCounters();
        
        // set some of the settings (see the github readme for more information about that)
        AppRating.daysUntilPrompt(0);
        AppRating.usesUntilPrompt(2);
        AppRating.secondsBeforePromptIsShown(3);
        AppRating.significantEventsUntilPrompt(0); // set this to zero if you dont't want to use this feature
    }
    
   
    
    func setHomeAsRoot(){
        self.window?.rootViewController = homeNav
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Foreground")
        //  if UtilityClass.isUserLoggedIN(){
        
        // }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //        ShowPinScreenWithCallBack { (success) in
        //            self.setHomeAsRoot()
        //        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func setupBannerView(_ bannerView : GADBannerView, viewController : UIViewController){
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" 
        bannerView.isHidden = true
        bannerView.rootViewController = viewController
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
        bannerView.delegate = self
    }
    
    func showFullScreenAd(_ callBack : @escaping InterstialHandler){
        self.interstialHandler = callBack
        if interstitial == nil{
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")

            interstitial?.delegate = self
            let request = GADRequest()
            interstitial?.load(request)
        }
        
    }
}

func ShowPinScreenWithCallBack( _ callBack : @escaping EnterPinHandler){
    if let pinNavVC = MainStoryBoard.instantiateViewController(withIdentifier: "EnterPinNav") as? UINavigationController{
        if let pinVC = pinNavVC.viewControllers.first as? EnterPinViewController{
            pinVC.pinHandler = callBack
            APPDELEGATE.window?.rootViewController = pinNavVC
            // UtilityClass.presentViewController(vc: pinNavVC)
        }
    }
}

extension AppDelegate : GADBannerViewDelegate, GADInterstitialDelegate{
    // BANNER
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        // bannerView.updateConstraint(attribute: .height, constant: 100)
    }
    
    //===============================
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstialHandler?(true)
        self.interstitial?.delegate = nil
        self.interstitial = nil
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        self.interstialHandler?(true)
        self.interstitial?.delegate = nil
        self.interstitial = nil
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if ad.isReady{
            if let root = self.window?.rootViewController{
                ad.present(fromRootViewController: root)
            }
        }
    }
}
