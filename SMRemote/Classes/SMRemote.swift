//
//  SMRemote.swift
//  FirebaseCore
//
//  Created by OW01 on 7/17/19.
//

import Foundation
import FireBase

class SMRemote : NSObject {
    
    static let prefix:String = "_counter"
    var remoteConfig = RemoteConfig.remoteConfig()
    var settings = RemoteConfigSettings()
    var expirationDuration = 3600
    
    static let remote : SMRemote = {
        let instance = SMRemote()
        instance.settings.minimumFetchInterval = 0
        instance.remoteConfig.configSettings = instance.settings
//        instance.remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        return instance
    }()
    
}
