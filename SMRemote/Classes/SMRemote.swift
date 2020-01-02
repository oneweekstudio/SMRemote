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
    public var isDebug: Bool = false
    
    var remoteConfig = RemoteConfig.remoteConfig()
    var settings = RemoteConfigSettings()
    var expirationDuration = 0
    
    public static let sharedInstance : SMRemote = {
        let instance = SMRemote()
        instance.settings.minimumFetchInterval = 0
        instance.remoteConfig.configSettings = instance.settings
        
//        if SMRemote.sharedInstance.isDebug {
//            instance.expirationDuration = 0
//        }
        
        return instance
    }()
    
    public func enableDebug(_ isDebug: Bool = false) {
        SMRemote.sharedInstance.isDebug = isDebug
    }
    
    //Load
    @available(*, deprecated, renamed: "loadConfig")
    open func load( smConfig: SMRemoteConfig, completionHandler: ((Bool) -> Void)?) {
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate(completionHandler: nil)
                self.setConfig(smConfig)
                completionHandler?(true)
            } else {
                completionHandler?(false)
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    open func loadConfig( smConfig: SMRemoteConfig, completionHandler: ((Any?, Any?) -> Void)?) {
        let _expirationDuration = SMRemote.sharedInstance.isDebug ? 0 : 3600
        remoteConfig.fetch(withExpirationDuration: TimeInterval(_expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate(completionHandler: nil)
                self.setToolConfig(smConfig) { (json, qc)  in
                    completionHandler?(json, qc)
                }
                completionHandler?(nil, nil)
            } else {
                completionHandler?(nil, nil)
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    
    @available(*, deprecated, renamed: "setToolConfig")
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
                if key == "ad_dialog_loop" {
                    print("Super: Không update counter của ad_dialog")
                    if self.getCounter(key: key) == 0 {
                        self.set(key: key + adsPrefixCounter, value: 1)
                    }
                } else if key == "ad_dialog_start" {
                    print("Super: Không update counter của ad_dialog")
                    if self.getCounter(key: key) == 0 {
                        self.set(key: key + adsPrefixCounter, value: 1)
                    }
                } else {
                    self.set(key: key + adsPrefixCounter, value: 1)
                }
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
    
    
    private func setToolConfig(_ config : SMRemoteConfig, completionHandler:@escaping (_ config :Any,_ quangcao: Any?) -> Void) {
        var qc: Any?
        if let quangcao = self.remoteConfig["quangcao"].jsonValue as? [String: Any]{
            print("Quảng cáo :\n \(quangcao)")
            SMAdsManager.shared.quangcao = AdsModel(quangcao)
            qc = quangcao
        }
        
        print("JSON key Config:")
        print(remoteConfig["tools"].jsonValue ?? "None")
        guard let json = remoteConfig["tools"].jsonValue as? [String:Any] else {
            completionHandler([:], qc)
            return }
        
        let mirror = Mirror.init(reflecting: config)
        if let mirror_super = mirror.superclassMirror {
            for i in mirror_super.children {
                if let key = i.label {
                    if let value = json[key] as? Int {
                        print("Super: nhận về key \(key) value \(value)")
                        self.set(key: key + adsPrefix, value: value)
                        print("Super set counterKey : \(key)")
                        self.set(key: key + adsPrefixCounter, value: 1)
                    } else {
                        print("Không nhận giá trị của key \(key)")
                    } //End if
                } //End if
            } // End for
        } //End if
        
        for i in mirror.children {
            if let key = i.label {
                if let value = json[key] as? Int {
                    print("Child: nhận về key \(key) value \(value)")
                    self.set(key: key + adsPrefix, value: value)
                    if key == "ad_dialog_loop" {
                        print("Super: Không update counter của ad_dialog: hiện tại = \(self.getCounter(key: key))")
                        if self.getCounter(key: key) == 0 {
                            self.set(key: key + adsPrefixCounter, value: 1)
                        }
                    } else if key == "ad_dialog_start" {
                        print("Super: Không update counter của ad_dialog: hiện tại = \(self.getCounter(key: key))")
                        if self.getCounter(key: key) == 0 {
                            self.set(key: key + adsPrefixCounter, value: 1)
                        }
                    } else {
                        print("Chill set counterKey : \(key)")
                        self.set(key: key + adsPrefixCounter, value: 1)
                    }
                } //End if
            } //End if
        } //End for
        
        completionHandler(json, qc)
    }
    
    fileprivate func set(key:String, value: Any) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    open func get(key: String) -> Int {
        let value =  UserDefaults.standard.integer(forKey: key + adsPrefix)
        return value
    }
    
    open func getCounter(key: String) -> Int {
        let value =  UserDefaults.standard.integer(forKey: key + adsPrefixCounter)
        return value
    }
    
}
