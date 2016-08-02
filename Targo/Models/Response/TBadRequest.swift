//
//  TBadRequest.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 02/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TBadRequest: NSObject, Mappable {

    var status = 0
    
    var name = ""
    
    var message = ""
    
    var code = 0
    
    var type = ""
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        status <- map["status"]
        name <- map["name"]
        message <- map["message"]
        code <- map["code"]
        type <- map["type"]
    }
}
