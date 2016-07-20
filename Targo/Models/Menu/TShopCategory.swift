//
//  TShopCategory.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class TShopCategory: Object, Mappable {

    
    dynamic var id = 0
    
    dynamic var title = ""
    
    dynamic var categoryDescription = ""
    
    dynamic var companyId = 0
    
    dynamic var addressId = 0
    
    dynamic var imageId = 0
    
    dynamic var createdAt = ""
    
    dynamic var updatedAt = ""
    
    dynamic var deleted = false
    
    let deletedAt = RealmOptional<Bool>()
    
    
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
        deletedAt.value <- map["deleted_at"]
    }
}
