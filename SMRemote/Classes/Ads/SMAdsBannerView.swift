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


open class SMAdsBannerView : UIView {
    
    private var admobView: GADBannerView!
    private var facebookView: FBAdView!
    
    static let bannerHeight : CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 60 : 100
    
    var rootViewController: UIViewController!
    
    var bannerUnit: AdsUnit! {
        didSet {
            self.initAds()
        }
    }
    
    private func initAds() {
        self.backgroundColor = UIColor.clear
        if bannerUnit.status == 1 {
            if bannerUnit.network == "admob" {
                self.loadGADBannerView()
            } else if bannerUnit.network == "facebook" {
                self.loadFBAdView()
            }
        }
    }
    
    private func loadGADBannerView() {
        admobView = GADBannerView.init(adSize: kGADAdSizeSmartBannerPortrait)
        admobView.adUnitID = bannerUnit.ads_id
        admobView.delegate = self
        admobView.rootViewController = rootViewController
        let request = GADRequest()
        if SMAdsManager.shared.isDebug {
            request.testDevices = [kGADSimulatorID]
        }
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
//        if bannerUnit != nil {
//            if bannerUnit.network == "admob" {
//                self.addConstraintAdsView(ads: admobView)
//            } else if bannerUnit.network == "facebook" {
//                self.addConstraintAdsView(ads: facebookView)
//            }
//        }
      
    }

}


extension SMAdsBannerView : GADBannerViewDelegate {
  
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("GADBannerView : adViewDidReceiveAd")
        self.backgroundColor = UIColor.black
    }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
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
