//
//  ViewController.swift
//  SMRemote
//
//  Created by oneweekstudio on 07/17/2019.
//  Copyright (c) 2019 oneweekstudio. All rights reserved.
//

import UIKit
import SMRemote

class ViewController: UIViewController {

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
            print("Success")
        }
    }
    
    @IBAction func showAdsFull(_ sender: Any) {
        SMAdsManager.shared.showFull(controller: self, start: #keyPath(Dev.default_start), loop: #keyPath(Dev.default_loop)) { (success) in
            print("Chuyển màn")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "B")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }

}

open class Dev : SMConfig {
    
    var custom_property = 1
}
