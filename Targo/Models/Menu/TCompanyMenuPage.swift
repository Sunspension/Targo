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
    
    var totalCount = 0
    
    var pageCount = 0
    
    var currentPage = 0
    
    var pageSize = 0

    var goods = [TShopGood]()
    
    var categories = [TShopCategory]()
    
    
    required convenience init?(map: Map) {
        
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
