//
//  TRemoteServer.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 29/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Alamofire

class TRemoteServer: NSObject, PRemoteServerV1 {

    static let baseURLString = "http://45.62.123.157:8082/api"
    
    static let deviceType = "ios"
    
    
    
    static func registration(phoneNumber: String, parameters: [String : AnyObject]?) -> Request {
        
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey(kTargoDeviceToken)
        var params: [String: AnyObject] = ["phone" : phoneNumber, "device_type" : deviceType, "device_token" : deviceToken ?? "11123123"]
        
        if parameters != nil {
            
            params += parameters!
        }
        
        return TRemoteServer.request(.POST, remotePath: baseURLString + "/code", parameters: params)
    }
    
    static func authorization(phoneNumber: String, code: String, parameters: [String : AnyObject]?) -> Request {
        
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey(kTargoDeviceToken)
        var params: [String: AnyObject] = ["phone" : phoneNumber,
                                           "code" : code,
                                           "device_type" : deviceType,
                                           "device_token" : deviceToken ?? "11123123"]
        
        if parameters != nil {
            
            params += parameters!
        }
        
        return TRemoteServer.request(.POST, remotePath: baseURLString + "/auth", parameters: params)
    }
    
    private static func request(method: Alamofire.Method, remotePath: URLStringConvertible, parameters: [String : AnyObject]?) -> Request {
        
        return self.request(method, remotePath: remotePath, parameters: parameters, headers: nil);
    }
    
    private static func request(method: Alamofire.Method, remotePath: URLStringConvertible, parameters: [String : AnyObject]?, headers: [String : String]?) -> Request {
        
        return Alamofire.request(method, remotePath, parameters: parameters, encoding: Alamofire.ParameterEncoding.JSON, headers: headers).validate()
    }
}
