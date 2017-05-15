//
//  UserSession.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 07/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class UserSession: Object, Mappable {
    
    dynamic var userId = 0
    
    dynamic var sid = ""
    
    var isExpired: Bool {
        
        return userId == 0
    }

    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "sid"
    }
    
    func mapping(map: Map) {
     
        userId <- map["user_id"]
        sid <- map["sid"]
    }
}
