//
//  SMAdsManager.swift
//  FirebaseCore
//
//  Created by OW01 on 7/17/19.
//

import Foundation
import GoogleMobileAds

//MARK:- Config
let adsPrefixCounter:String = "_ads_counter"
let adsPrefix:String = "_ads"

//MARK:- Manager
open class SMAdsManager : NSObject {
    
    public static let shared = SMAdsManager()
    
    var quangcao:AdsModel = AdsModel()
    
    var interstitial: GADInterstitial!
    
    var interstitialLoadCompled : ((Bool) -> Void)?
    
    open func showFull( controller: UIViewController,  start: String ,  loop : String , completionHandler : ((Bool) -> Void)?) {
        
        let userDefault = UserDefaults.standard
        
        let startConfig = userDefault.integer(forKey: start + adsPrefix)
        let loopConfig = userDefault.integer(forKey: loop + adsPrefix)
        
        let startCounter = userDefault.integer(forKey: start + adsPrefixCounter)
        let loopCounter = userDefault.integer(forKey: loop + adsPrefixCounter)
        
        self.plusCounter(key: start + adsPrefixCounter, value: startCounter)
        
        print("\(start + adsPrefix) \(startConfig) \(loop +  adsPrefix) \(loopConfig) ")
        print("\(start + adsPrefixCounter) \(startCounter) \(loop +  adsPrefixCounter) \(loopCounter) ")
        
        if startCounter > startConfig {
            self.plusCounter(key: loop + adsPrefixCounter, value: loopCounter)
            if loopCounter - 1 == loopConfig  {
                self.resetCounter(key: loop + adsPrefixCounter)
                //Show ads
                self.loadGADInterstitial(completionHandler: { success in
                    if success {
                        self.interstitial.present(fromRootViewController: controller)
                    } else {
                        completionHandler?(true)
                    }
                })
            } else {
                completionHandler?(true)
            }
        } else {
            if startCounter == startConfig {
                //Show ads
                self.loadGADInterstitial(completionHandler: { success in
                    if success {
                        self.interstitial.present(fromRootViewController: controller)
                    } else {
                        completionHandler?(true)
                    }
                })
                
            } else {
                completionHandler?(true)
            }
        }
    }
    
    private func resetCounter(key:String) {
        UserDefaults.standard.setValue(1, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    private func plusCounter(key:String, value: Int) {
        UserDefaults.standard.setValue(value + 1, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func loadGADInterstitial(completionHandler:((Bool) -> Void)?) {
        interstitialLoadCompled = completionHandler
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        request.testDevices = [kGADSimulatorID]
    }
}


extension SMAdsManager : GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    public func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("SMAdsManager:interstitialDidReceiveAd")
        interstitialLoadCompled?(true)
    }
    
    /// Tells the delegate an ad request failed.
    public func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("SMAdsManager:interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        interstitialLoadCompled?(false)
    }
    
    /// Tells the delegate that an interstitial will be presented.
    public func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("SMAdsManager:interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    public func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("SMAdsManager:interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    public func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("SMAdsManager:interstitialDidDismissScreen")
        interstitialLoadCompled?(false)
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    public func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("SMAdsManager:interstitialWillLeaveApplication")
    }
}
