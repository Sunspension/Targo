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
    
    var companies = List<TCompany>()
    
    var images = List<TCompanyImage>()
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    
    func mapping(map: Map) {
        
        totalCount <- map["meta.total_count"]
        pageCount <- map["meta.page_count"]
        currentPage <- map["meta.current_page"]
        pageSize <- map["meta.page_size"]
        companies <- (map["company-address"], ListTransform<TCompany>())
        images <- (map["image"], ListTransform<TCompanyImage>())
    }
}
