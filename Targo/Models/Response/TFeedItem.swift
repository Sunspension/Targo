//
//  TFeedItem.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 18/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TFeedItem: NSObject, Mappable {

    var id = 0
    
    var title = ""
    
    var feedItemDescription = ""
    
    var imageIds = [Int]()
    
    var createdAt = ""
    
    var updatedAt = ""
    
    var companyId = 0
    
    var actionId = 0
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        actionId <- map["action_id"]
        feedItemDescription <- map["description"]
        imageIds <- map["image_ids"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        companyId <- map["company_id"]
    }
}
