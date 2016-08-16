//
//  TCreditCard.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 06/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TCreditCard: NSObject, Mappable {

    var id = 0
    
    var userId = 0
    
    var mask = ""
    
    var type = ""
    
    var expireAt: String?
   
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        userId <- map["user_id"]
        mask <- map["mask"]
        type <- map["type"]
        expireAt <- map["expired_at"]
    }
}
