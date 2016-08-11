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

struct TRemoteServer: PRemoteServerV1 {

    let baseURLString = "https://api.targo.club/api"
    
    let deviceType = "ios"
    
    
    func registration(phoneNumber: String, deviceToken: String, parameters: [String : AnyObject]? = nil) -> Request {
        
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
                                           "order" : ["dist" : "asc"],
                                           "extend" : "image"]
        
        return self.request(.GET, remotePath: baseURLString + "/company-address", parameters: params)
    }
    
    func loadCompanyMenu(companyId: Int) -> Request {
        
        let params: [String : AnyObject] = [ "filters" : ["company_id" : companyId],
                                             "extend" : "shop-category"]
        
        return self.request(.GET, remotePath: baseURLString + "/shop-good", parameters: params)
    }
    
    func makeTestOrder() -> Request {
        
        let params: [String : AnyObject] = [ "type" : 1]
        return self.request(.POST, remotePath: baseURLString + "/order", parameters: params)
    }
    
    func loadCreditCards() -> Request {
        
        return self.request(.GET, remotePath: baseURLString + "/card")
    }
    
    func makeShopOrder(cardId: Int, items: [String: Int], addressId: Int) -> Request {
        
        let formatter = NSDateFormatter()
        
        
        
        let params: [String : AnyObject] = [ "service_id" : 1,
                                             "items" : items,
                                             "address_id" : addressId,
                                             "card_id" : cardId, "prepared_at" : NSDate() ]
        return self.request(.POST, remotePath: baseURLString + "/shop-order", parameters: params)
    }
    
    // mark - private methods
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible) -> Request {
        
        return self.request(method, remotePath: remotePath, parameters: nil)
    }
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible, parameters: [String : AnyObject]?) -> Request {
        
        return self.request(method, remotePath: remotePath, parameters: parameters, headers: nil);
    }
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible, parameters: [String : AnyObject]?, headers: [String : String]?) -> Request {
        
        return Alamofire.request(method, remotePath, parameters: parameters, encoding: method == .POST ? .JSON : .URL, headers: headers)
    }
}
