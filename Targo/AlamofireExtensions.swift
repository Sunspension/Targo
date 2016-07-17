//
//  AlamofireExtensions.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 04/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

extension Request {
    
    func debugLog() -> Request {
        
        debugPrint(self)
        return self
    }
}