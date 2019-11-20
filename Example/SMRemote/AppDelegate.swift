//
//  AppDelegate.swift
//  SMRemote
//
//  Created by oneweekstudio on 07/17/2019.
//  Copyright (c) 2019 oneweekstudio. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import SMRemote
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
         // Use Firebase library to configure APIs.
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //Khong dung ham nay nua
        SMAdsManager.shared.config(enableDebug: true)
        
        //Su dung ham nay
        SMRemote.sharedInstance.enableDebug(true)
        
        return true
    }
    
  
}

