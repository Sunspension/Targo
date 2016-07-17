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
    
    dynamic var companyId = 0
    
    dynamic var shopCategoryId = 0
    
    dynamic var price = 0
    
    dynamic var externalId = 0
    
    dynamic var persistentId = 0
    
    dynamic var createdAt = ""
    
    dynamic var apdatedAt = ""
    
    dynamic var deleted = false;
    
    let deletedAt = RealmOptional<Bool>()
    
    dynamic var parentId = 0
    
    dynamic var searchVector = ""
    
    dynamic var history = ""
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        
    }
}
