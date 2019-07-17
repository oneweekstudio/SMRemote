//
//  AdsModel.swift
//  FirebaseCore
//
//  Created by OW01 on 7/17/19.
//

import Foundation
import MagicMapper

@objcMembers
open class AdsModel : NSObject, Mappable {
    var full = AdsUnit()
    var banner = AdsUnit()
    var native = AdsUnit()
    var reward = AdsUnit()
}
