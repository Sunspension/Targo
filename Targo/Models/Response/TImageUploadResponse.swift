//
//  TImageUploadResponse.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 06/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TImageUploadResponse: NSObject, Mappable {

    var id = 0
    
    var userId = 0
    
    var path = ""
    
    var url = ""
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        userId <- map["user_id"]
        path <- map["path"]
        url <- map["url"]
    }
}
