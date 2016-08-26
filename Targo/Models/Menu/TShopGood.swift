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
    
    dynamic var count = 0
    
    dynamic var externalId = 0
    
    dynamic var persistentId = 0
    
    dynamic var createdAt = ""
    
    dynamic var updatedAt = ""
    
    dynamic var deleted = false
    
    dynamic var parentId = 0
    
    dynamic var history = ""
    
    var imageIds: [Int] {
        
        get {
            
            return backingImageIds.map { $0.value }
        }
    }
    
    let backingImageIds = List<RealmInt>()
    
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        
        return ["imageIds"]
    }
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        goodDescription <- map["description"]
        companyId <- map["company_id"]
        shopCategoryId <- map["shop_category_id"]
        price <- map["price"]
        persistentId <- map["persistent_id"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        parentId <- map["parent_id"]
        count <- map["count"]
        
        var imageIds = [Int]()
        imageIds <- map["image_ids"]
        self.backingImageIds.appendContentsOf(imageIds.map({ RealmInt(value: [$0]) }))
    }
}