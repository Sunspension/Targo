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
    
    static let alamofireManager: Alamofire.Manager = {
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        
        return Alamofire.Manager(configuration: configuration)
    }()
    
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
    
    func loadCompanyAddresses(location: CLLocation, pageNumber: Int, pageSize: Int, query: String?, distance: Int?) -> Request {
        //
        //        let params: [String: AnyObject] = ["lat" : location.coordinate.latitude,
        //                                           "lon" : location.coordinate.longitude,
        //                                           "order" : ["dist" : "asc"],
        //                                           "conditions" : ["dist" : ["<" : 3000]]]
        
        var params: [String: AnyObject] = ["lat" : location.coordinate.latitude,
                                           "lon" : location.coordinate.longitude,
                                           "order" : ["dist" : "asc"],
                                           "extend" : "image",
                                           "page_size" : pageSize,
                                           "page" : pageNumber]
        
        if let query = query {
            
            params["query"] = query
        }
        
        if let distance = distance {
            
            params["conditions"] = ["dist" : ["<" : distance]]
        }
        
        return self.request(.GET, remotePath: baseURLString + "/company-address", parameters: params)
    }
    
    func loadCompanyMenu(companyId: Int, pageNumber: Int, pageSize: Int = 20) -> Request {
        
        let params: [String : AnyObject] = [ "filters" : ["company_id" : companyId],
                                             "extend" : "shop-category",
                                             "page" : pageNumber,
                                             "page_size" : pageSize,
                                             "order" : ["shop_category_id" : "asc"]]
        
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
    
    func makeShopOrder(cardId: Int,
                       items: [Int : Int],
                       addressId: Int,
                       serviceId: Int,
                       date: NSDate?,
                       numberOfPersons: Int? = nil,
                       description: String? = nil) -> Request {
        
        var goods: [[String : Int]] = []
        
        for item in items {
            
            goods.append(["id" : item.0, "count" : item.1])
        }
        
        var params: [String : AnyObject] = [ "items" : goods,
                                             "address_id" : addressId,
                                             "card_id" : cardId,
                                             "service_id" : serviceId]
        if let date = date {
            
            let formatter = NSDateFormatter()
            
            formatter.dateFormat = kDateTimeFormat
            let dateString = formatter.stringFromDate(date)
            
            params["prepared_at"] = dateString
        }
        
        if numberOfPersons != nil {
            
            params["person_number"] = numberOfPersons
        }
        
        if description != nil && !description!.isEmpty{
            
            params["description"] = description
        }
        
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
    
    func loadShopOrders(updatedDate: String, olderThen: Bool, pageSize: Int = 20) -> Request {
        
        var params: [String : AnyObject] = [:]
        
        params["extend"] = "company"
        params["merge"] = "true"
        params["conditions"] = ["updated_at" : olderThen ? [">" : updatedDate] : ["<" : updatedDate]]
        params["page_size"] = pageSize
        params["order"] = ["id" : "desc"]
        
        return self.request(.GET, remotePath: baseURLString + "/shop-order", parameters: params)
    }
    
    func loadShopOrders(pageNumber: Int, pageSize: Int = 20) -> Request {
        
        var params: [String : AnyObject] = [:]
        
//        params["extend"] = "company"
//        params["merge"] = "true"
        params["page"] = pageNumber
        params["page_size"] = pageSize
        params["order"] = ["id" : "desc"]
        
        return self.request(.GET, remotePath: baseURLString + "/shop-order", parameters: params)
    }
    
    func updateOrderStatus(orderId: Int, orderStatus: Int) -> Request {
        
        let params: [String : AnyObject] = ["order_status" : orderStatus]
        
        return self.request(.PUT, remotePath: baseURLString + "/shop-order/" + String(orderId), parameters: params)
    }
    
    func feed(pageNumber: Int, pageSize: Int = 20) -> Request {
        
        let params: [String : AnyObject] = ["page" : pageNumber, "page_size" : pageSize, "extend" : "company"]
        return self.request(.GET, remotePath: baseURLString + "/promotion", parameters : params)
    }
    
    func addBookmark(companyAddressId: Int) -> Request {
        
        return self.request(.PUT, remotePath: baseURLString + "/company-address" + "/\(companyAddressId)", parameters: ["is_favorite" : true])
    }
    
    func removeBookmark(companyAddressId: Int) -> Request {
        
        return self.request(.PUT, remotePath: baseURLString + "/company-address" + "/\(companyAddressId)", parameters: ["is_favorite" : false])
    }
    
    func favoriteComanyAddresses(location: CLLocation, pageNumber: Int?, pageSize: Int?) -> Request {
        
        var params: [String: AnyObject] = ["lat" : location.coordinate.latitude,
                                           "lon" : location.coordinate.longitude,
                                           "order" : ["dist" : "asc"],
                                           "extend" : "image",
                                           "filters" : ["is_favorite" : true]]
        
        if let pageNumber = pageNumber {
            
            params["page"] = pageNumber
        }
        
        if let pageSize = pageSize {
            
            params["page_size"] = pageSize
        }
        
        return self.request(.GET, remotePath: baseURLString + "/company-address", parameters: params)
    }
    
    func uploadImage(image: UIImage, encodingCompletion: (Manager.MultipartFormDataEncodingResult -> Void)?) {
        
        TRemoteServer.alamofireManager.upload(.POST, baseURLString + "/image", multipartFormData: { multipartFromData in
            
                if let data = UIImagePNGRepresentation(image) {
                    
                    multipartFromData.appendBodyPart(data: data, name: "file", mimeType: "image/png")
                }
            
            }, encodingCompletion: encodingCompletion)
    }
    
    // MARK: - Private methods
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible) -> Request {
        
        return self.request(method, remotePath: remotePath, parameters: nil)
    }
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible, parameters: [String : AnyObject]?) -> Request {
        
        return self.request(method, remotePath: remotePath, parameters: parameters, headers: nil);
    }
    
    private func request(method: Alamofire.Method, remotePath: URLStringConvertible, parameters: [String : AnyObject]?, headers: [String : String]?) -> Request {
        
        let request = TRemoteServer.alamofireManager.request(method, remotePath, parameters: parameters, encoding: method == .POST ? .JSON : .URL, headers: headers)
        print(request)
        return request
    }
}
