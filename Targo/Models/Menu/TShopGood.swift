//
//  TShopGood.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 16/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class TShopGood: Mappable {

    
    var id = 0
    
    var title = ""
    
    var goodDescription = ""
    
    var companyId = 0
    
    var shopCategoryId = 0
    
    var price = 0
    
    var externalId = 0
    
    var persistentId = 0
    
    var createdAt = ""
    
    var updatedAt = ""
    
    var deleted = false;
    
    var deletedAt: Bool?
    
    var parentId = 0
    
    var searchVector = ""
    
    var history = ""
    
    var imageIds = [String]()
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        goodDescription <- map["description"]
        companyId <- map["comapny_id"]
        shopCategoryId <- map["shop_category_id"]
        price <- map["price"]
        externalId <- map["external_id"]
        persistentId <- map["repsistent_id"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        deletedAt <- map["deleted_at"]
        parentId <- map["parent_id"]
        searchVector <- map["search_vector"]
        history <- map["history"]
        imageIds <- map["image_ids"]
    }
}
