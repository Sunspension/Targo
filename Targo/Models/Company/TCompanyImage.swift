//
//  TCompanyImage.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 16/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class TCompanyImage: Object, Mappable {

    dynamic var id = 0
    
    dynamic var title = ""
    
    dynamic var url = ""
    
    dynamic var path = ""
    
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
        url <- map["url"]
        path <- map["path"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        deletedAt.value <- map["deleted_at"]
    }
}
