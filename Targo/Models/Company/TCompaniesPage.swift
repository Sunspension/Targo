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

class TCompanyAddressesPage: Mappable {

    var totalCount = 0
    
    var pageCount = 0
    
    var currentPage = 0
    
    var pageSize = 0
    
    var companies = [TCompanyAddress]()
    
    var images = [TImage]()
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    
    func mapping(map: Map) {
        
        totalCount <- map["meta.total_count"]
        pageCount <- map["meta.page_count"]
        currentPage <- map["meta.current_page"]
        pageSize <- map["meta.page_size"]
        companies <- map["company-address"]
        images <- map["image"]
    }
}
