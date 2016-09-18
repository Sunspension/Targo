//
//  TCompany.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 23/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class TCompany: Object, Mappable {

    dynamic var id = 0
    
    dynamic var title = ""
    
    dynamic var companyDescription = ""
    
    dynamic var createdAt = ""
    
    dynamic var updatedAt = ""
    
    dynamic var deleted = ""
    
    dynamic var imageId = 0
    
    dynamic var site = ""
    
    dynamic var phone = ""
    
    dynamic var companyCategoryId = 0
    
    dynamic var alias = ""
    
    dynamic var rating = 0.0
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        companyDescription <- map["description"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        imageId <- map["image_id"]
        site <- map["site"]
        phone <- map["phone"]
        companyCategoryId <- map["company_category_id"]
        alias <- map["alias"]
        rating <- map["rating"]
    }
}
