//
//  TShopCategory.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TShopCategory: NSObject, Mappable {
    
    var id = 0
    
    var title = ""
    
    var categoryDescription = ""
    
    var companyId = 0
    
    var addressId = 0
    
    var imageId = 0
    
    var createdAt = ""
    
    var updatedAt = ""
    
    var deleted = false
    
    var deletedAt: Bool?
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        categoryDescription <- map["description"]
        companyId <- map["company_id"]
        addressId <- map["address_id"]
        imageId <- map["image_id"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        deletedAt <- map["deleted_at"]
    }
}
