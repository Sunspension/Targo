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
    
    func loadCompanyAddressesByLocation(location: CLLocation) -> Request {
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
    
    func checkTestOrder(orderId: Int) -> Request {
        
        return self.request(.GET, remotePath: baseURLString + "/order/" + String(orderId))
    }
    
    func loadCreditCards() -> Request {
        
        return self.request(.GET, remotePath: baseURLString + "/card")
    }
    
    func makeShopOrder(cardId: Int, items: [Int : Int], addressId: Int, serviceId: Int, date: NSDate) -> Request {
        
        let formatter = NSDateFormatter()
        
        formatter.dateFormat = kDateTimeFormat
        let dateString = formatter.stringFromDate(date)
        
        var goods: [[String : Int]] = []
        
        for item in items {
            
            goods.append(["id" : item.0, "count" : item.1])
        }
        
        let params: [String : AnyObject] = [ "items" : goods,
                                             "address_id" : addressId,
                                             "card_id" : cardId,
                                             "service_id" : serviceId,
                                             "prepared_at" : dateString ]
        
        return self.request(.POST, remotePath: baseURLString + "/shop-order", parameters: params)
    }
    
    func checkShopOrderStatus(orderStatus: Int) -> Request {
        
        return self.request(.GET, remotePath: baseURLString + "/shop-order/" + String(orderStatus))
    }
    
    func loadCompanyById(companyId: Int) -> Request {
        
        return self.request(.GET, remotePath: baseURLString + "/company/" + String(companyId))
    }
    
    func loadCompaniesByIds(companiesIds: [Int]) -> Request {
        
        let params: [String : AnyObject] = ["filters" : [ "id" : companiesIds ]]
        return self.request(.GET, remotePath: baseURLString + "/company", parameters: params)
    }
    
    func loadImageById(imageId: Int) -> Request {
        
        return self.request(.GET, remotePath: baseURLString + "/image/" + String(imageId))
    }
    
    func loadImagesByIds(imageIds: [Int]) -> Request {
        
        let params: [String : AnyObject] = ["filters" : [ "id" : imageIds ]]
        return self.request(.GET, remotePath: baseURLString + "/image", parameters: params)
    }
    
    func loadShopOrders(updatedDate: String, limit: Int) -> Request {
        
        var params: [String : AnyObject] = [:]
        
        params["extend"] = "company"
        params["merge"] = "true"
        params["conditions"] = ["updated_at" : ["<" : updatedDate]]
        params["limit"] = limit
        params["order"] = ["id" : "desc"]
        
        return self.request(.GET, remotePath: baseURLString + "/shop-order", parameters: params)
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
