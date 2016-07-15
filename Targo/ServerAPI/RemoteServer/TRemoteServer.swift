//
//  TRemoteServer.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 29/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON

struct TRemoteServer: PRemoteServerV1 {

    let baseURLString = "http://45.62.123.157:8082/api"
    
    let deviceType = "ios"
    
    
    func registration(phoneNumber: String, deviceToken: String, parameters: [String : AnyObject]?) -> Request {
        
        var params: [String: AnyObject] = ["phone" : phoneNumber, "device_type" : deviceType, "device_token" : deviceToken]
        
        if parameters != nil {
            
            params += parameters!
        }
        
        return self.request(.POST, remotePath: baseURLString + "/code", parameters: params)
    }
    
    func authorization(phoneNumber: String, code: String, deviceToken: String, parameters: [String : AnyObject]?) -> Request {

        let systemVersion = UIDevice.currentDevice().systemVersion;
        let info = NSBundle.mainBundle().infoDictionary
        let bundleId = NSBundle.mainBundle().bundleIdentifier
        
        let applicationVersion = info?["CFBundleShortVersionString"]
        
        var params: [String: AnyObject] = ["phone" : phoneNumber,
                                           "code" : code,
                                           "device_type" : deviceType,
                                           "device_token" : deviceToken,
                                           "type" : "code",
                                           "application" : bundleId ?? "",
                                           "system_version" : systemVersion,
                                           "application_version" : applicationVersion ?? ""]
        
        if parameters != nil {
            
            params += parameters!
        }
        
        return self.request(.POST, remotePath: baseURLString + "/auth", parameters: params)
    }

    func deauthorization() -> Request {
        
        return self.request(.DELETE, remotePath: baseURLString + "/auth")
    }
    
    func loadUserById(userId: Int) -> Request {
        
        return self.request(.GET, remotePath: baseURLString + "/user/\(userId)")
    }
    
    func loadCompaniesByLocation(location: CLLocation) -> Request {
//        
//        let params: [String: AnyObject] = ["lat" : location.coordinate.latitude,
//                                           "lon" : location.coordinate.longitude,
//                                           "order" : ["dist" : "asc"],
//                                           "conditions" : ["dist" : ["<" : 3000]]]
        
        let params: [String: AnyObject] = ["lat" : location.coordinate.latitude,
                                           "lon" : location.coordinate.longitude,
                                           "order" : ["dist" : "asc"]]
        
        return Alamofire.request(.GET, baseURLString + "/company-address", parameters: params, headers: nil)
    }
    
    
    //mark - private methods
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible) -> Request {
        
        return self.request(method, remotePath: remotePath, parameters: nil)
    }
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible, parameters: [String : AnyObject]?) -> Request {
        
        return self.request(method, remotePath: remotePath, parameters: parameters, headers: nil);
    }
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible, parameters: [String : AnyObject]?, headers: [String : String]?) -> Request {
        
        let request = Alamofire.request(method, remotePath, parameters: parameters, encoding:.JSON, headers: headers).validate()
        
        debugPrint("request: \(request)")
        
        return request
    }
}
