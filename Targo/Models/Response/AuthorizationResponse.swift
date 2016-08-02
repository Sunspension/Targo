//
//  AuthorizationResponse.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 01/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class AuthorizationResponse: Object, Mappable {

    dynamic var phone = 0
    
    dynamic var deviceType = ""
    
    dynamic var deviceToken = ""
    
    dynamic var type = 0
    
    dynamic var id = 0
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        phone <- map["data.phone"]
        deviceToken <- map["data.device_token"]
        deviceType <- map["data.device_type"]
        type <- map["data.type"]
        id <- map["data.id"]
    }
}
