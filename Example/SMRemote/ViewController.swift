//
//  ViewController.swift
//  SMRemote
//
//  Created by oneweekstudio on 07/17/2019.
//  Copyright (c) 2019 oneweekstudio. All rights reserved.
//

import UIKit
import SMRemote
import GoogleMobileAdsMediationTestSuite

class ViewController: UIViewController {
    
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: SMAdsBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadConfig()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadConfig() {
        SMRemote.sharedInstance.load(smConfig: Dev()) {
            print("Tải thành công config từ remote")
        }
    }
    
    @IBAction func showAdsFull(_ sender: Any) {
        //Gọi full với start loop
        SMAdsManager.shared.showFull(controller: self, start: #keyPath(Dev.default_start), loop: #keyPath(Dev.default_loop)) { (success) in
            print("Chuyển màn")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "B")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    @IBAction func showBannerAds(_ sender: Any) {
        //Hàm gọi quảng cáo
        SMAdsManager.shared.showBannerAds(present: self, bannerView: self.bannerView, bannerHeight: self.bannerHeight, keyConfig: #keyPath(Dev.banner_home))
    }

    
    @IBAction func showReward(_ sender: Any){
        SMAdsManager.shared.showReward(controller: self,
        rewardDidLoadComplete: {
            //
        }, rewardDidLoadFailure: {
            
        }, rewardDidWatch: {
            //Trả thưởng
        }, rewardDidClose:  {
            //
        })
    }
    
    @IBAction func callTestSuite(_ sender: Any) {
        GoogleMobileAdsMediationTestSuite.present(on:self, delegate:nil)
    }
}


//Tạo 1 class kế thừa từ SMConfig
open class Dev : SMConfig {
    
    @objc var custom_property = 1
    @objc var banner_home = 1
}
