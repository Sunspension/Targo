//
//  RRemoteServerV1.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 29/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation
import Alamofire

protocol PRemoteServerV1 {
    
    static func registration(phoneNumber: String, parameters: [String : AnyObject]?) -> Request
    
    static func authorization(phoneNumber: String, code: String, parameters: [String : AnyObject]?) -> Request
}