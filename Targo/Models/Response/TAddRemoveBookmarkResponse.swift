//
//  TAddRemoveBookmarkResponse.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 03/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TAddRemoveBookmarkResponse: NSObject, Mappable {

    var success = [Int]()
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        success <- map["data"]
    }
}
