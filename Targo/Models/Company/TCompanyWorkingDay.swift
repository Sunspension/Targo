//
//  TCompanyWorkingDay.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 13/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class TCompanyWorkingDay: Object {

    dynamic var begin = ""
    
    dynamic var end = ""
    
    convenience init(begin: String, end: String) {
        
        self.init()
        
        self.begin = begin
        self.end = end
    }
    
    required init() {
        
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        
        super.init(value: value, schema: schema)
    }
}
