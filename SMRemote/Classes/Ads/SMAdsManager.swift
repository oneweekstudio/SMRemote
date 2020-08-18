//
//  SMAdsManager.swift
//  FirebaseCore
//
//  Created by OW01 on 7/17/19.
//

import Foundation
import GoogleMobileAds
import FBAudienceNetwork
import JGProgressHUD

import FacebookAdapter
import VungleAdapter

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
    
    //Quảng cáo xen kẽ
    fileprivate var admob: GADInterstitial!
    fileprivate var facebook: FBInterstitialAd!
    
    
    //Quảng cáo reward ( quảng cáo trả thưởng )
    fileprivate var rewardedAd: GADRewardedAd? //Google
    fileprivate var rewardedVideoAd: FBRewardedVideoAd? //Facebook
    
    fileprivate var controller: UIViewController?
    fileprivate var rewardController: UIViewController?
    
    //Quảng cáo xen kẽ ( full ) khi hoàn thành
    fileprivate var interstitialDidCompled : ((Bool) -> Void)?
    
    //Quảng cáo reward
    fileprivate var rewardDidLoadComplete : (() -> Void)?
    fileprivate var rewardDidLoadFailure : (() -> Void)?
    
    fileprivate var rewardDidPresent : (() -> Void)?
    fileprivate var rewardDidFailToPresent : (() -> Void)?
    
    fileprivate var rewardDidClose : (() -> Void)?
    fileprivate var rewardUserDidEarn : (() -> Void)?
    
    fileprivate var rewardUserDidClick : (() -> Void)?
    
    
    let hudSMAds = JGProgressHUD(style: .dark)
    
    open func showLoading(vc: UIViewController) {
        DispatchQueue.main.async {
            self.hudSMAds.textLabel.text = "Loading"
            self.hudSMAds.show(in: vc.view)
        }
    }
    
    open func hideLoading(vc: UIViewController?) {
        DispatchQueue.main.async {
            self.hudSMAds.dismiss(afterDelay: 1.5, animated: true)
        }
    }
    
    /// Hiển thị quảng cáo full với start loop
    ///
    /// - Parameters:
    ///   - controller: controller hiển thị quảng cáo
    ///   - start: lần đầu mở quảng cáo
    ///   - loop: sau loop lần thì hiển thị quảng cáo
    ///   - completionHandler: sau khi hiển thị quảng cáo xong, chạy vào completionHandler.
    open func showFull( controller: UIViewController,  start: String ,  loop : String , completionHandler : ((Bool) -> Void)?) {
        
        self.controller = controller
        
        let userDefault = UserDefaults.standard
        let object = userDefault.bool(forKey: "purchase")
        if object {
            completionHandler?(true)
        } else {
            let startConfig = userDefault.integer(forKey: start + adsPrefix)
            let loopConfig = userDefault.integer(forKey: loop + adsPrefix)
            
            let startCounter = userDefault.integer(forKey: start + adsPrefixCounter)
            let loopCounter = userDefault.integer(forKey: loop + adsPrefixCounter)
            
            self.plusCounter(key: start + adsPrefixCounter, value: startCounter)
            
            print("\(start + adsPrefix) \(startConfig) \(loop +  adsPrefix) \(loopConfig) ")
            print("\(start + adsPrefixCounter) \(startCounter) \(loop +  adsPrefixCounter) \(loopCounter) ")
            
            if startConfig == 0 && loopConfig == 0 {
                completionHandler?(true)
            } else {
                if startCounter > startConfig {
                    self.plusCounter(key: loop + adsPrefixCounter, value: loopCounter)
                    if loopCounter == loopConfig  {
                        self.resetCounter(key: loop + adsPrefixCounter)
                        //Show ads
                        self.requestAds(controller: controller, quangcao: self.quangcao) { (success) in
                            completionHandler?(success)
                        }
                    } else {
                        completionHandler?(true)
                    }
                } else {
                    if startCounter == startConfig {
                        //Show ads
                        self.requestAds(controller: controller, quangcao: self.quangcao) { (success) in
                            completionHandler?(success)
                        }
                    } else {
                        completionHandler?(true)
                    }
                }
            }
        }
    }
    
    //Tùy chình hiện quảng cáo
    
    
    /// Tùy chỉnh hiện quảng cáo
    /// - Parameter controller: controller cần show dialog
    /// - Parameter start: thường thì là ad_dialog_start
    /// - Parameter loop: thường thì là ad_dialog_loop
    /// - Parameter completionHandler: Khi không hiện quảng cáo check completionHadnler (true ),  hiện quảng cáo là completionHandler(false)
    open func show( controller: UIViewController,  start: String ,  loop : String , completionHandler : ((Bool) -> Void)?) {
        
        self.controller = controller
        
        let userDefault = UserDefaults.standard
        let startConfig = userDefault.integer(forKey: start + adsPrefix)
        let loopConfig = userDefault.integer(forKey: loop + adsPrefix)
        
        let startCounter = userDefault.integer(forKey: start + adsPrefixCounter)
        let loopCounter = userDefault.integer(forKey: loop + adsPrefixCounter)
        
        self.plusCounter(key: start + adsPrefixCounter, value: startCounter)
        
        print("\(start + adsPrefix) \(startConfig) \(loop +  adsPrefix) \(loopConfig) ")
        print("\(start + adsPrefixCounter) \(startCounter) \(loop +  adsPrefixCounter) \(loopCounter) ")
        
        if startConfig == 0 && loopConfig == 0 {
            completionHandler?(true)
        } else {
            if startCounter > startConfig {
                self.plusCounter(key: loop + adsPrefixCounter, value: loopCounter)
                if loopCounter == loopConfig  {
                    self.resetCounter(key: loop + adsPrefixCounter)
                    completionHandler?(false)
                } else {
                    completionHandler?(true)
                }
            } else {
                if startCounter == startConfig {
                    completionHandler?(false)
                } else {
                    completionHandler?(true)
                }
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
        if quangcao.full.status == 1 {
            if quangcao.full.network == "facebook" {
                self.loadFBInterstitialAd(controller: controller) { (success) in
                    if success {
                        self.facebook.show(fromRootViewController: controller)
                    } else {
                        completionHandler?(true)
                    }
                }
            } else if quangcao.full.network == "admob" || quangcao.full.network == "mediation" {
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
        self.showLoading(vc: controller)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            print("SMAdsManager: Load full with id: \(self.quangcao.full.ads_id)")
            
            self.interstitialDidCompled = completionHandler
            
            self.admob = GADInterstitial(adUnitID: self.quangcao.full.ads_id)
            let request = GADRequest()
            
            if self.quangcao.full.network == "mediation" {
                
                //Facebook mediation config
                let extras = GADFBNetworkExtras()
                extras.nativeAdFormat = .native
                request.register(extras)
                
                //Vungle mediation config
                let vungleExtras = VungleAdNetworkExtras()
                vungleExtras.allPlacements = ["AdmobMediatedBanner"]
                request.register(vungleExtras)
            }
            
            self.admob.load(request)
            self.admob.delegate = self
            if SMRemote.sharedInstance.isDebug {
                print("DEBUG ENABLE : kGADSimulatorID  \(kGADSimulatorID)")
                //                request.testDevices = [(kGADSimulatorID as! String)]
            }
        }
    }
    
    /// Tải quảng cáo với facebook. Biến completionHandler được gán trả về cho manager. để đợi 1 tín hiệu (true, fail) từ delegate
    ///
    /// - Parameters:
    ///   - controller: controller cần hiển thị loadding và present quảng cáo
    ///   - completionHandler: Việc hoàn thiện này cần thằng Delegate thực thi xong và trả về
    private func loadFBInterstitialAd( controller: UIViewController, completionHandler :((Bool) -> Void)?) {
        self.showLoading(vc: controller)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            print("SMAdsManager: Load full with id: \(self.quangcao.full.ads_id)")
            
            self.interstitialDidCompled = completionHandler
            
            self.facebook = FBInterstitialAd.init(placementID: self.quangcao.full.ads_id)
            self.facebook.delegate = self
            self.facebook.load()
            if SMRemote.sharedInstance.isDebug {
                print("DEBUG ENABLE : TEST_DEVICES_HASH  \(FBAdSettings.testDeviceHash())")
                FBAdSettings.setLogLevel(FBAdLogLevel.log)
                FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
            }
        }
    }
    
}

//MARK:- GADInterstitialDelegate (Full)
extension SMAdsManager : GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    public func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("SMAdsManager:ADMOB:interstitialDidReceiveAd")
        print("Interstitial adapter class name: \(ad.responseInfo?.adNetworkClassName)")
        interstitialDidCompled?(true)
        self.hideLoading(vc: self.controller)
    }
    
    /// Tells the delegate an ad request failed.
    public func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("SMAdsManager:ADMOB:interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        interstitialDidCompled?(false)
        self.hideLoading(vc: self.controller)
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
        self.hideLoading(vc: self.controller)
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    public func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        //        print("SMAdsManager:interstitialWillLeaveApplication")
    }
}

//MARK:- FBInterstitialAdDelegate ( Full )
extension SMAdsManager : FBInterstitialAdDelegate {
    
    public func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        print("SMAdsManager:FB:interstitialDidReceiveAd")
        interstitialDidCompled?(true)
        self.hideLoading(vc: self.controller)
    }
    
    public func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        print("SMAdsManager:interstitial:FB:didFailToReceiveAdWithError: \(error.localizedDescription)")
        interstitialDidCompled?(false)
        self.hideLoading(vc: self.controller)
    }
    
    public func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        interstitialDidCompled?(false)
        self.hideLoading(vc: self.controller)
    }
}


//MARK:- Banner
extension SMAdsManager {
    
    /// Gọi hàm để hiển thị banner
    ///
    /// - Parameters:
    ///   - controller: controller nơi chứa banner
    ///   - bannerView: IBOutlet bannerview
    ///   - height: Constraint Banner view
    ///   - keyConfig: keyBanner
    open func showBannerAds( present controller: UIViewController, bannerView: SMAdsBannerView, bannerHeight height : NSLayoutConstraint, keyConfig: String) {
        
        let userDefault = UserDefaults.standard
        let object = userDefault.bool(forKey: "purchase")
        
        if object {
            print("User purchased")
            height.constant = 0
            bannerView.isHidden = true
            bannerView.removeBannerView()
        } else {
            
            let bannerUnit = SMAdsManager.shared.quangcao.banner
            
            if enableBannerAds(keyConfig: keyConfig) && bannerUnit.status == 1{
                print("SMAdsManager: Show banner!")
                height.constant = SMAdsBannerView.bannerHeight
                
                bannerView.rootViewController = controller
                
                bannerView.bannerUnit = bannerUnit
                
                //Load ads
                bannerView.initAds()
                
            } else {
                print("SMAdsManager: Hide banner!")
                height.constant = 0
                bannerView.isHidden = true
                bannerView.removeBannerView()
            }
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

//MARK:- Quảng cáo reward
extension SMAdsManager{
    
    //Tải quảng cáo reward
    open func loadReward(
        rewardDidLoadComplete : (() -> Void)?,
        rewardDidLoadFailure : (() -> Void)?) {
        self.rewardController = controller
        self.rewardDidLoadComplete = rewardDidLoadComplete
        self.rewardDidLoadFailure = rewardDidLoadFailure
        self.requestReward()
    }
    
    //Load
    private func requestReward() {
        if quangcao.reward.status == 1 {
            if quangcao.reward.network == "facebook" {
                self.loadFacebookRewardedVideoAd()
            }
            else
                if quangcao.reward.network == "admob" {
                    self.loadAdmobRewardedVideoAd()
                }
                else {
                    self.rewardDidLoadFailure?()
            }
        } else {
            //Không load quảng cáo
            self.rewardDidLoadFailure?()
        }
    }
    
    //Hiển thị
    open func presentReward(controller: UIViewController,
                            rewardDidPresent: (() -> Void)?,
                            rewardDidFailToPresent:  (() -> Void)?,
                            rewardDidClose: (() -> Void)?,
                            rewardUserDidEarn: (() -> Void)?,
                            rewardUserDidClick: (() -> Void)?) {
        self.rewardDidPresent = rewardDidPresent
        self.rewardDidFailToPresent = rewardDidFailToPresent
        self.rewardDidClose = rewardDidClose
        self.rewardUserDidEarn = rewardUserDidEarn
        self.rewardUserDidClick = rewardUserDidClick
        
        if quangcao.reward.status == 1 {
            if quangcao.reward.network == "facebook" {
                self.presentFacebookRewardedVideoAd(controller: controller)
            } else if quangcao.reward.network == "admob" {
                    self.presentAdmobRewardedVideoAd(controller: controller)
            }
        } else {
            //Không load quảng cáo
            rewardDidFailToPresent?()
        }
        
    }
    
}

//MARK:- GADRewardedAdDelegate
extension SMAdsManager : GADRewardedAdDelegate {
    
    public func loadAdmobRewardedVideoAd() {
        self.rewardedAd = GADRewardedAd(adUnitID: quangcao.reward.ads_id)
        rewardedAd?.load(GADRequest()) { error in
            if let error = error {
                // Handle ad failed to load case.
                //Error
                print("Load error: \(error)")
                self.rewardDidLoadFailure?()
            } else {
                // Ad successfully loaded.
                print("Load admod reward success!")
                self.rewardDidLoadComplete?()
            }
        }
    }
    
    public func presentAdmobRewardedVideoAd(controller: UIViewController) {
        if rewardedAd?.isReady == true {
            rewardDidPresent?()
            rewardedAd?.present(fromRootViewController: controller, delegate:self)
        } else {
            rewardDidFailToPresent?()
        }
    }
    
    /// Tells the delegate that the user earned a reward.
    public func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        self.rewardUserDidEarn?()
    }
    /// Tells the delegate that the rewarded ad was presented.
    public func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad presented.")
        self.rewardDidPresent?()
    }
    /// Tells the delegate that the rewarded ad was dismissed.
    public func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad dismissed.")
        self.rewardDidClose?()
    }
    /// Tells the delegate that the rewarded ad failed to present.
    public func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        print("Rewarded ad failed to present.")
        self.rewardDidFailToPresent?()
        
    }
    
    
}

//MARK: FBRewardedVideoAdDelegate
extension SMAdsManager: FBRewardedVideoAdDelegate {
    
    public func loadFacebookRewardedVideoAd() {
        self.rewardedVideoAd = FBRewardedVideoAd.init(placementID: quangcao.reward.ads_id)
        self.rewardedVideoAd?.delegate = self
        self.rewardedVideoAd?.load()
    }
    
    public func presentFacebookRewardedVideoAd(controller: UIViewController) {
        if let rewardedVideoAd = self.rewardedVideoAd, rewardedVideoAd.isAdValid {
            rewardDidPresent?()
            self.rewardedVideoAd?.show(fromRootViewController: controller, animated: true)
        } else {
            rewardDidFailToPresent?()
        }
    }
    
    public func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("Video ad is loaded and ready to be displayed")
        self.rewardDidLoadComplete?()
    }
    
    public func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("Rewarded video ad failed to load")
        self.rewardDidLoadFailure?()
    }
    
    public func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        print("Rewarded video ad failed to load \(error)")
        self.rewardDidLoadFailure?()
    }
    
    public func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("Video ad clicked")
        self.rewardUserDidClick?()
    }
    
    public func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("Rewarded Video ad video complete - this is called after a full video view, before the ad end card is shown. You can use this event to initialize your reward")
        rewardUserDidEarn?()
    }
    
    public func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("Rewarded Video ad closed - this can be triggered by closing the application, or closing the video end card")
        rewardDidClose?()
    }
}
