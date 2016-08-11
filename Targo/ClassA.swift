//
//  ClassA.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 11/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class ClassA: NSObject {
    
    var closure: ((valueOne: Int, valueTwo: Int) -> Int)?
    
    func getResultClosure() {
        
        let result = self.closure?(valueOne: 2, valueTwo: 4)
        print("result: \(result)")
    }
}
