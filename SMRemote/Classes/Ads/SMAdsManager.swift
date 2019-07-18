//
//  SMAdsManager.swift
//  FirebaseCore
//
//  Created by OW01 on 7/17/19.
//

import Foundation
import GoogleMobileAds
import PKHUD
import FBAudienceNetwork

//MARK:- Config
let adsPrefixCounter:String = "_ads_counter"
let adsPrefix:String = "_ads"


//Admob
//ads_id: full : ca-app-pub-3940256099942544/4411468910
//ads_id: banner: ca-app-pub-3940256099942544~1458002511
//app_id: ca-app-pub-3940256099942544~1458002511

//Facebook
//Duc Truong, [Jul 18, 2019 at 9:50:06 AM]:
//Full: 1562525404054991_1698301837144013
//
//banner: 1562525404054991_1698301767144020
//
//Facebook app id: 1562525404054991

//MARK:- Manager
open class SMAdsManager : NSObject {
    
    public static let shared = SMAdsManager()
    
    /// Quảng cáo này được lấy khi gọi remote config load.
     var quangcao:AdsModel = AdsModel()
    
    fileprivate var admob: GADInterstitial!
    fileprivate var facebook: FBInterstitialAd!
    
    var isDebug:Bool = true
    
    /// Khi quảng cáo thực thi xong ( true hay fail ) nó sẽ sử dụng hàm này
    fileprivate var interstitialDidCompled : ((Bool) -> Void)?
    
    /// Hiển thị quảng cáo full với start loop
    ///
    /// - Parameters:
    ///   - controller: controller hiển thị quảng cáo
    ///   - start: lần đầu mở quảng cáo
    ///   - loop: sau loop lần thì hiển thị quảng cáo
    ///   - completionHandler: sau khi hiển thị quảng cáo xong, chạy vào completionHandler.
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
                //                self.loadGADInterstitial(controller: controller, completionHandler: { success in
                //                    if success {
                //                        self.admob.present(fromRootViewController: controller)
                //                    } else {
                //                        completionHandler?(true)
                //                    }
                //                })
                self.requestAds(controller: controller, quangcao: self.quangcao) { (success) in
                    completionHandler?(success)
                }
            } else {
                completionHandler?(true)
            }
        } else {
            if startCounter == startConfig {
                //Show ads
                //                self.loadGADInterstitial(controller: controller, completionHandler: { success in
                //                    if success {
                //                        self.admob.present(fromRootViewController: controller)
                //                    } else {
                //                        completionHandler?(true)
                //                    }
                //                })
                self.requestAds(controller: controller, quangcao: self.quangcao) { (success) in
                    completionHandler?(success)
                }
            } else {
                completionHandler?(true)
            }
        }
    }
    
    /// Chuyển các counter về 1
    ///
    /// - Parameter key: Là 1  key của thằng Userdefault
    private func resetCounter(key:String) {
        UserDefaults.standard.setValue(1, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    /// Tăng counter lên 1 đơn vị
    ///
    /// - Parameters:
    ///   - key: key của thằng User default
    ///   - value: giá trị bân đầu của key trong user default
    private func plusCounter(key:String, value: Int) {
        UserDefaults.standard.setValue(value + 1, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    private func requestAds( controller : UIViewController, quangcao: AdsModel , completionHandler: ((Bool) -> Void)?) {
        if quangcao.full.network == "facebook" {
            self.loadFBInterstitialAd(controller: controller) { (success) in
                if success {
                    self.facebook.show(fromRootViewController: controller)
                } else {
                    completionHandler?(true)
                }
            }
        } else if quangcao.full.network == "admob" {
            self.loadGADInterstitial(controller: controller) { (success) in
                if success {
                    self.admob.present(fromRootViewController: controller)
                } else {
                    completionHandler?(true)
                }
            }
        } else {
            completionHandler?(false)
        }
    }
    
    /// Tải quảng cáo với google. Biến completionHandler được gán trả về cho manager. để đợi 1 tín hiệu (true, fail) từ delegate
    ///
    /// - Parameters:
    ///   - controller: controller cần hiển thị loadding và present quảng cáo
    ///   - completionHandler: Việc hoàn thiện này cần thằng Delegate thực thi xong và trả về
    private func loadGADInterstitial(controller: UIViewController, completionHandler:((Bool) -> Void)?) {
        DispatchQueue.main.async {
            HUD.show(.labeledProgress(title: nil, subtitle: "load ads..."), onView: controller.view)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            print("SMAdsManager: Load full with id: \(self.quangcao.full.ads_id)")
            
            self.interstitialDidCompled = completionHandler
            
            self.admob = GADInterstitial(adUnitID: self.quangcao.full.ads_id)
            let request = GADRequest()
            self.admob.load(request)
            self.admob.delegate = self
            if self.isDebug {
                print("DEBUG ENABLE : kGADSimulatorID  \(kGADSimulatorID)")
                request.testDevices = [kGADSimulatorID]
            }
        }
    }
    
    /// Tải quảng cáo với facebook. Biến completionHandler được gán trả về cho manager. để đợi 1 tín hiệu (true, fail) từ delegate
    ///
    /// - Parameters:
    ///   - controller: controller cần hiển thị loadding và present quảng cáo
    ///   - completionHandler: Việc hoàn thiện này cần thằng Delegate thực thi xong và trả về
    private func loadFBInterstitialAd( controller: UIViewController, completionHandler :((Bool) -> Void)?) {
        DispatchQueue.main.async {
            HUD.show(.labeledProgress(title: nil, subtitle: "load ads..."), onView: controller.view)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            print("SMAdsManager: Load full with id: \(self.quangcao.full.ads_id)")
            
            self.interstitialDidCompled = completionHandler
            
            self.facebook = FBInterstitialAd.init(placementID: self.quangcao.full.ads_id)
            self.facebook.delegate = self
            self.facebook.load()
            if self.isDebug {
                print("DEBUG ENABLE : TEST_DEVICES_HASH  \(FBAdSettings.testDeviceHash())")
                FBAdSettings.setLogLevel(FBAdLogLevel.log)
                FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
            }
        }
    }
    
}

//MARK:- GADInterstitialDelegate
extension SMAdsManager : GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    public func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("SMAdsManager:ADMOB:interstitialDidReceiveAd")
        interstitialDidCompled?(true)
        HUD.hide()
    }
    
    /// Tells the delegate an ad request failed.
    public func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("SMAdsManager:ADMOB:interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        interstitialDidCompled?(false)
        HUD.hide()
    }
    
    /// Tells the delegate that an interstitial will be presented.
    public func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        //        print("SMAdsManager:interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    public func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        //        print("SMAdsManager:interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    public func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        //        print("SMAdsManager:interstitialDidDismissScreen")
        interstitialDidCompled?(false)
        HUD.hide()
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    public func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        //        print("SMAdsManager:interstitialWillLeaveApplication")
    }
}

//MARK:- FBInterstitialAdDelegate
extension SMAdsManager : FBInterstitialAdDelegate {
    
    public func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        print("SMAdsManager:FB:interstitialDidReceiveAd")
        interstitialDidCompled?(true)
        HUD.hide()
    }
    
    public func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print("SMAdsManager:interstitial:FB:didFailToReceiveAdWithError: \(error.localizedDescription)")
        interstitialDidCompled?(false)
        HUD.hide()
    }
    
    public func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        interstitialDidCompled?(false)
        HUD.hide()
    }
}


//MARK:- Banner
extension SMAdsManager {
    
    open func showBannerAds( present controller: UIViewController, bannerView: SMAdsBannerView, bannerHeight height : NSLayoutConstraint, keyConfig: String) {
        let bannerUnit = SMAdsManager.shared.quangcao.banner
        
        bannerView.rootViewController = controller
        
        bannerView.bannerUnit = bannerUnit
        
        if enableBannerAds(keyConfig: keyConfig) {
            height.constant = SMAdsBannerView.bannerHeight
        } else {
            height.constant = 0
        }
        
        bannerView.updateConstraints()
        controller.view.layoutSubviews()
    }
    
    private func enableBannerAds( keyConfig : String) -> Bool {
        let userDefault = UserDefaults.standard
        let status = userDefault.integer(forKey: keyConfig + adsPrefix)
        return status > 0
    }
    
    
}
