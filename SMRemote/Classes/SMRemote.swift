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
    
    open var isDebug: Bool = false
    
    var remoteConfig = RemoteConfig.remoteConfig()
    var settings = RemoteConfigSettings()
    var expirationDuration = 0
    
    public static let sharedInstance : SMRemote = {
        let instance = SMRemote()
        instance.remoteConfig.configSettings = instance.settings
        return instance
    }()
    
    public func enableDebug(_ isDebug: Bool = false) {
        SMRemote.sharedInstance.isDebug = isDebug
    }
    
    //Hàm này trả về JSON tools và mã quảng cáo
    open func loadConfig( smConfig: SMRemoteConfig, completionHandler: ((_ tools: Any?,_ quangcao: Any?) -> Void)?) {
        let _expirationDuration = self.expirationDuration
        remoteConfig.fetch(withExpirationDuration: TimeInterval(_expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
                DispatchQueue.main.async {
                    self.setToolConfig(smConfig) { (json, qc)  in
                        completionHandler?(json, qc)
                    }
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                completionHandler?(nil, nil)
            }
        }
    }
    
    private func setToolConfig(_ config : SMRemoteConfig, completionHandler:@escaping (_ config :Any,_ quangcao: Any?) -> Void) {
        var qc: Any?
        if let string = self.remoteConfig["quangcao"].stringValue ,
           let quangcao = string.convertJson(){
            print("Quảng cáo :\n \(quangcao)")
            SMAdsManager.shared.quangcao = AdsModel(quangcao)
            qc = quangcao
        }
        
        print("\nTools :")
        guard let string = remoteConfig["tools"].stringValue ,
            let json = string.convertJson() else {
            completionHandler([:], qc)
            return }
        
        let mirror = Mirror.init(reflecting: config)
        
        if let mirror_super = mirror.superclassMirror {
            for i in mirror_super.children {
                if let key = i.label {
                    if let value = json[key] as? Int {
                        //print("- Super: nhận về key \(key) value \(value)")
                        self.set(key: key + adsPrefix, value: value)
                        //print("- Super set counterKey : \(key)")
                        self.set(key: key + adsPrefixCounter, value: 1)
                    } else {
                        //print("- Không nhận giá trị của key \(key)")
                    } //End if
                } //End if
            } // End for
        } //End if
        
        for i in mirror.children {
            if let key = i.label {
                if let value = json[key] as? Int {
                    print("- Child: [VALUE] \(value) | [GET KEY] \(key) ")
                    self.set(key: key + adsPrefix, value: value)
                    if key == "ad_dialog_loop" {
                        //print("- Super: Không update counter của ad_dialog: hiện tại = \(self.getCounter(key: key))")
                        if self.getCounter(key: key) == 0 {
                            self.set(key: key + adsPrefixCounter, value: 1)
                        }
                    } else if key == "ad_dialog_start" {
                        //print("- Super: Không update counter của ad_dialog: hiện tại = \(self.getCounter(key: key))")
                        if self.getCounter(key: key) == 0 {
                            self.set(key: key + adsPrefixCounter, value: 1)
                        }
                    } else {
                        //print("- Child: [SET] counterKey : \(key)")
                        self.set(key: key + adsPrefixCounter, value: 1)
                    }
                } else {
                    print("- Error: Can not set [KEY] \(key) \(type(of: json[key]))")
                } //End if
            } //End if
        } //End for
        
        completionHandler(json, qc)
    }
    
    //Hàm hỗ trợ lấy remote config theo key. Ví vụ nhập "quangcao" -> trả về JSON quảng cáo tương ứng
    open func getRemoteValue( ByParameterKey key: String, completionHandler: @escaping (Any?) -> Void) -> Void {
        completionHandler(self.remoteConfig[key])
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

extension String {
    func convertJson()->[String:Any]?{
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]
            {
                return jsonArray
            } else {
                print("bad json")
                return nil
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
}
