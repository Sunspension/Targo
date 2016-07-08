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
    
    let userId = RealmOptional<Int>()
    
    dynamic var sid = ""
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "userId"
    }
    
    func mapping(map: Map) {
     
        userId.value <- map["user_id"]
        sid <- map["sid"]
    }
}
