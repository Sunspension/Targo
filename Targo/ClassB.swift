//
//  ClassB.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 11/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class ClassB: NSObject {

    var classA = ClassA()
    
    override init() {
        
        super.init()
        
        self.classA.closure = { (one, two) in
            
            return one + two
        }
    }
}
