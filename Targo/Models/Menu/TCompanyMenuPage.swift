//
//  TCompanyMenuPage.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TCompanyMenuPage: Mappable {
    
    dynamic var totalCount = 0
    
    dynamic var pageCount = 0
    
    dynamic var currentPage = 0
    
    dynamic var pageSize = 0

    var goods = [TShopGood]()
    
    var categories = [TShopCategory]()
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
    
        totalCount <- map["meta.total_count"]
        pageCount <- map["meta.page_count"]
        currentPage <- map["meta.current_page"]
        pageSize <- map["meta.page_size"]
        goods <- map["shop-good"]
        categories <- map["shop-category"]
    }
}
