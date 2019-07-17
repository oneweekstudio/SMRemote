//
//  AdsUnit.swift
//  FirebaseCore
//
//  Created by OW01 on 7/17/19.
//

import Foundation
import MagicMapper

@objcMembers
open class AdsUnit : NSObject , Mappable {
    var app_id = ""
    var ads_id = ""
    var format = ""
    var status = 0
    var network = ""
}
