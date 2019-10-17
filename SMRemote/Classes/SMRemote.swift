//
//  SMRemote.swift
//  FirebaseCore
//
//  Created by OW01 on 7/17/19.
//

import Foundation
import FirebaseRemoteConfig
import GoogleMobileAds
open class SMRemote : NSObject {
    
//    static let prefix:String = "_counter"
    
    var remoteConfig = RemoteConfig.remoteConfig()
    var settings = RemoteConfigSettings()
    var expirationDuration = 3600

    public static let sharedInstance : SMRemote = {
        let instance = SMRemote()
        instance.settings.minimumFetchInterval = 0
        instance.remoteConfig.configSettings = instance.settings
        return instance
    }()
    
    //Load
    open func load( smConfig: SMRemoteConfig, completionHandler: (() -> Void)?) {
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate(completionHandler: nil)
                self.setConfig(smConfig)
                completionHandler?()
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    private func setConfig(_ config : SMRemoteConfig) {

        if let quangcao = self.remoteConfig["quangcao"].jsonValue as? [String: Any]{
            print("Quảng cáo : \(quangcao)")
            SMAdsManager.shared.quangcao = AdsModel(quangcao)
        }
        
        let mirror = Mirror.init(reflecting: config)
        if let mirror_super = mirror.superclassMirror {
            for i in mirror_super.children {
                guard let key = i.label else { return }
                guard let value = remoteConfig[key].numberValue as? Int else { return }
                print("Super: nhận về key \(key) value \(value)")
                self.set(key: key + adsPrefix, value: value)
                self.set(key: key + adsPrefixCounter, value: 1)
            }
        }
        
        for i in mirror.children {
            guard let key = i.label else { return }
            guard let value = remoteConfig[key].numberValue as? Int else { return }
            print("Child: nhận về key \(key) value \(value)")
            self.set(key: key + adsPrefix, value: value)
            self.set(key: key + adsPrefixCounter, value: 1)
        }
        
    }
    
    fileprivate func set(key:String, value: Any) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }

}
