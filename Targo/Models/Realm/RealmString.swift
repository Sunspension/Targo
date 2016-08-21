//
//  StringObject.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class RealmString: Object, Mappable {

    dynamic var value = ""
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        value <- map["value"]
    }
}
