//
//  TCompaniesPage.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 13/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class TCompaniesPage: Object, Mappable {

    dynamic var totalCount = 0
    
    dynamic var pageCount = 0
    
    dynamic var currentPage = 0
    
    dynamic var pageSize = 0
    
    let companies = List<TCompany>()
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    
    func mapping(map: Map) {
        
        totalCount <- map["total_count"]
        pageCount <- map["page_count"]
        currentPage <- map["current_page"]
        pageSize <- map["page_size"]
    }
}
