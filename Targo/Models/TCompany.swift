//
//  TCompany.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 12/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class TCompany: Object, Mappable {

    dynamic var id = 0
    
    dynamic var companyId = 0
    
    dynamic var title = ""
    
    dynamic var latitude = 0
    
    dynamic var longitude = 0
    
    dynamic var createdAt:String?
    
    dynamic var updatedAt = ""
    
    dynamic var deleted = false
    
    dynamic var deletedAt: String?
    
    dynamic var timeZoneOffset = 0
    
    dynamic var phone = ""
    
    dynamic var companyTitle = ""
    
    dynamic var companyCategoryId = 0
    
    dynamic var companyDescription = ""
    
    let companyImageId = RealmOptional<Int>()
    
    dynamic var companySite = ""
    
    dynamic var companyPhone = ""
    
    dynamic var companyCategoryTitle = ""
    
    dynamic var companyCategoryDescription = ""
    
    dynamic var companyCategoryImageId = 0
    
    dynamic var distance = 0
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }

    func mapping(map: Map) {
        
        id <- map["id"]
        companyId <- map["company_id"]
        title <- map["title"]
        latitude <- map["lat"]
        longitude <- map["lon"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        deletedAt <- map["updated_at"]
        timeZoneOffset <- map["timezone_offset"]
        phone <- map["phone"]
        companyTitle <- map["company_title"]
        companyCategoryId <- map["company_category_id"]
        companyDescription <- map["company_description"]
    }
}
