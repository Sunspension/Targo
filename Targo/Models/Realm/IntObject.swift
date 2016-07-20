//
//  IntObject.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class IntObject: Object, Mappable {

    dynamic var value = 0
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        value <- map["value"]
    }
}
