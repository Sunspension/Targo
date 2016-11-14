//
//  TFeedPage.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 18/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TFeedPage: NSObject, Mappable {

    var news: [TFeedItem] = []
    
    var companies: [TCompany] = []
    
    var images: [TImage]? = []
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        news <- map["promotion"]
        companies <- map["company"]
        images <- map["image"]
    }
}
