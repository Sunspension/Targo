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

class TShopGood: Object, Mappable {

    
    dynamic var id = 0
    
    dynamic var title = ""
    
    dynamic var goodDescription = ""
    
    dynamic var companyId = 0
    
    dynamic var shopCategoryId = 0
    
    dynamic var price = 0
    
    dynamic var externalId = 0
    
    dynamic var persistentId = 0
    
    dynamic var createdAt = ""
    
    dynamic var updatedAt = ""
    
    dynamic var deleted = false;
    
    let deletedAt = RealmOptional<Bool>()
    
    dynamic var parentId = 0
    
    dynamic var searchVector = ""
    
    dynamic var history = ""
    
    var imageIds = List<IntObject>()
    
    
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
        deletedAt.value <- map["deleted_at"]
        parentId <- map["parent_id"]
        searchVector <- map["search_vector"]
        history <- map["history"]
        imageIds <- (map["image_ids"], ListTransform<IntObject>())
    }
}
