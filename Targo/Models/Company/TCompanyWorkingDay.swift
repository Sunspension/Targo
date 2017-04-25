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
    
    dynamic var isClose: Bool {
        
        get {
            
            return self.begin == "00:00" && self.end == "00:00"
        }
    }
    
    dynamic var isAroundTheClock: Bool {
        
        get {
        
            return self.begin == "00:00" && self.end == "24:00"
        }
    }
    
    convenience init(begin: String, end: String) {
        
        self.init()
        
        self.begin = begin
        self.end = end
    }
}
