//
//  Extensions.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 29/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation

func += <K, V> (inout left: [K:V], right: [K:V]) {
 
    for (k, v) in right {
        
        left.updateValue(v, forKey: k)
    }
}