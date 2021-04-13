//
//  SMAdsBannerView.swift
//  FBSDKCoreKit
//
//  Created by OW01 on 7/18/19.
//

import Foundation
import UIKit
import GoogleMobileAds
import FBAudienceNetwork
import FacebookAdapter
import VungleAdapter

open class SMAdsBannerView : UIView {
    
    private var admobView: GADBannerView!
    private var facebookView: FBAdView!
    
    static let bannerHeight : CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 60 : 100
    
    var rootViewController: UIViewController!
    
    var bannerUnit: AdsUnit!
    
    func initAds() {
        self.backgroundColor = UIColor.clear
        self.removeBannerView()
        if bannerUnit.status == 1 {
            
            switch bannerUnit.network {
            case "admob":
                self.loadGADBannerView()
                break
            case "facebook":
                self.loadFBAdView()
                break
            case "mediation":
                self.loadMediation()
            default:
                break
            }
        }
    }
    
    private func loadMediation() {
        print(#function)
        admobView = GADBannerView.init(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width))
        admobView.adUnitID = bannerUnit.ads_id
        admobView.delegate = self
        admobView.rootViewController = rootViewController
        
        let request = GADRequest()
        
        //Facebook mediation config
        let extras = GADFBNetworkExtras()
        extras.nativeAdFormat = .nativeBanner
        request.register(extras)
        
        //Vungle mediation config
        let vungleExtras = VungleAdNetworkExtras()
        vungleExtras.allPlacements = ["AdmobMediatedBanner"]
        request.register(vungleExtras)
        
        self.addSubview(admobView)
        admobView.load(request)
        self.addConstraintAdsView(ads: admobView)
    }
    
    private func loadGADBannerView() {
        admobView = GADBannerView.init(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width))
        admobView.adUnitID = bannerUnit.ads_id
        admobView.delegate = self
        admobView.rootViewController = rootViewController
        let request = GADRequest()
        self.addSubview(admobView)
        admobView.load(request)
        self.addConstraintAdsView(ads: admobView)
    }
    
    private func loadFBAdView() {
        facebookView = UIDevice.current.userInterfaceIdiom == .phone ? FBAdView.init(placementID: bannerUnit.ads_id, adSize: kFBAdSizeHeight50Banner, rootViewController: rootViewController) : FBAdView.init(placementID: bannerUnit.ads_id, adSize: kFBAdSizeHeight90Banner, rootViewController: rootViewController)
        facebookView.delegate = self
        facebookView.loadAd()
        self.addSubview(facebookView)
        self.addConstraintAdsView(ads: facebookView)
    }
    
    private func addConstraintAdsView( ads view: UIView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let top = NSLayoutConstraint.init(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 5)
        
        let bottom = NSLayoutConstraint.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -5)
        
        let left = NSLayoutConstraint.init(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)
        
        let right = NSLayoutConstraint.init(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
        
        self.addConstraints([top, bottom, left, right])
        view.layoutIfNeeded()
        view.updateConstraintsIfNeeded()
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //Khi người dùng không cho hiện banner view
   open func removeBannerView() {
    
        if admobView != nil {
            admobView.removeFromSuperview()
        }
        
        if facebookView != nil {
            facebookView.removeFromSuperview()
        }
    }
    
}


extension SMAdsBannerView : GADBannerViewDelegate {
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GADBannerView : adViewDidReceiveAd")
        print("Banner adapter class name: \(bannerView.responseInfo?.adNetworkClassName ?? "nil")")
        self.backgroundColor = UIColor.black
    }
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner adapter class name: \(bannerView.responseInfo?.adNetworkClassName ?? "nil")")
        print("GADBannerView : didFailToReceiveAdWithError \(error.localizedDescription)")
    }
}

extension SMAdsBannerView : FBAdViewDelegate {
    
    public func adViewDidLoad(_ adView: FBAdView) {
        print("FBAdView : adViewDidLoad")
        self.backgroundColor = UIColor.black
    }
    
    public func adView(_ adView: FBAdView, didFailWithError error: Error) {
        print("FBAdView : didFailWithError \(error.localizedDescription)")
    }
    
    
}
