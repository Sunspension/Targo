//
//  TErrorResponse.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 01/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TServerError: NSObject, Mappable {
    
    var status = 0
    
    var errors = [TError]()
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        status <- map["status"]
        errors <- map["errors"]
    }
}

class TError: Mappable {
    
    var field: String = ""
    var message: String = ""
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        field <- map["field"]
        message <- map["message"]
    }
}
