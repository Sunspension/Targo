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
    
    static let alamofireManager: Alamofire.SessionManager = {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    let dev = "http://dev.targo.club/api"
    
    let prod = "https://api.targo.club/api"
    
    let noSSLProd = "http://api.targo.club/api"
    
    var baseURLString: String {
        
        return dev
    }
    
    let deviceType = "ios"
    
    
    func registration(phoneNumber: String, deviceToken: String, parameters: [String : Any]? = nil) -> DataRequest {
        
        var params: [String: Any] = ["phone" : phoneNumber, "device_type" : deviceType, "device_token" : deviceToken]
        
        if parameters != nil {
            
            params += parameters!
        }
        
        return self.request(method: .post, remotePath: baseURLString + "/code", parameters: params)
    }
    
    func authorization(phoneNumber: String, code: String, deviceToken: String, parameters: [String : Any]? = nil) -> DataRequest {

        let systemVersion = UIDevice.current.systemVersion;
        let info = Bundle.main.infoDictionary
        let bundleId = Bundle.main.bundleIdentifier
        
        let applicationVersion = info?["CFBundleShortVersionString"]
        
        var params: [String: Any] = ["phone" : phoneNumber,
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
        
        return self.request(method: .post, remotePath: baseURLString + "/auth", parameters: params)
    }

    func deauthorization() -> DataRequest {
        
        return self.request(method: .delete, remotePath: baseURLString + "/auth")
    }
    
    func loadUser(userId: Int) -> DataRequest {
        
        return self.request(method: .get,
                            remotePath: baseURLString + "/user/\(userId)",
                            parameters: ["extend" : "image"])
    }
    
    func loadCompanyAddress(location: CLLocation?, addressId: Int) -> DataRequest {
        
        let params: [String : Any] = ["extend" : "image",
                                      "lat" : location?.coordinate.latitude ?? 0.0,
                                      "lon" : location?.coordinate.longitude ?? 0.0]
        
        return self.request(method: .get,
                            remotePath: baseURLString + "/company-address" + "/\(addressId)", parameters: params)
    }
    
    func loadCompanyAddresses(location: CLLocation,
                              pageNumber: Int,
                              pageSize: Int,
                              query: String? = nil,
                              distance: Int? = nil) -> DataRequest {
        //
        //        let params: [String: AnyObject] = ["lat" : location.coordinate.latitude,
        //                                           "lon" : location.coordinate.longitude,
        //                                           "order" : ["dist" : "asc"],
        //                                           "conditions" : ["dist" : ["<" : 3000]]]
        
        var params: [String: Any] = ["lat" : location.coordinate.latitude,
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
        
        return self.request(method: .get, remotePath: baseURLString + "/company-address", parameters: params)
    }
    
    func loadCompanyMenu(companyId: Int, pageNumber: Int, pageSize: Int = 20) -> DataRequest {
        
        let params: [String : Any] = [ "filters" : ["company_id" : companyId],
                                             "extend" : "shop-category",
                                             "page" : pageNumber,
                                             "page_size" : pageSize,
                                             "order" : ["shop_category_id" : "asc"]]
        
        return self.request(method: .get, remotePath: baseURLString + "/shop-good", parameters: params)
    }
    
    func makeTestOrder() -> DataRequest {
        
        let params: [String : Any] = [ "type" : 1]
        return self.request(method: .post, remotePath: baseURLString + "/order", parameters: params)
    }
    
    func checkTestOrder(orderId: Int) -> DataRequest {
        
        return self.request(method: .get, remotePath: baseURLString + "/order/" + String(orderId))
    }
    
    func loadCreditCards() -> DataRequest {
        
        return self.request(method: .get, remotePath: baseURLString + "/card")
    }
    
    func makeShopOrder(cardId: Int,
                       items: [Int : Int],
                       addressId: Int,
                       serviceId: Int,
                       date: Date?,
                       asap: Bool? = nil,
                       numberOfPersons: Int? = nil,
                       description: String? = nil) -> DataRequest {
        
        var goods: [[String : Int]] = []
        
        for item in items {
            
            goods.append(["id" : item.0, "count" : item.1])
        }
        
        var params: [String : Any] = [ "items" : goods,
                                       "address_id" : addressId,
                                       "card_id" : cardId,
                                       "service_id" : serviceId]
        if let date = date {
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = kDateTimeFormat
            let dateString = formatter.string(from: date as Date)
            
            params["prepared_at"] = dateString
        }
        
        if asap != nil {
            
            params["asap"] = asap
        }
        
        if numberOfPersons != nil {
            
            params["person_number"] = numberOfPersons
        }
        
        if description != nil && !description!.isEmpty{
            
            params["description"] = description
        }
        
        return self.request(method: .post, remotePath: baseURLString + "/shop-order", parameters: params)
    }
    
    func checkShopOrderStatus(orderStatus: Int) -> DataRequest {
        
        return self.request(method: .get, remotePath: baseURLString + "/shop-order/" + String(orderStatus))
    }
    
    func loadCompany(companyId: Int) -> DataRequest {
        
        return self.request(method: .get, remotePath: baseURLString + "/company/" + String(companyId))
    }
    
    func loadCompanies(companiesIds: [Int]) -> DataRequest {
        
        let params: [String : Any] = ["filters" : [ "id" : companiesIds ]]
        return self.request(method: .get, remotePath: baseURLString + "/company", parameters: params)
    }
    
    func loadImage(imageId: Int) -> DataRequest {
        
        return self.request(method: .get, remotePath: baseURLString + "/image/" + String(imageId))
    }
    
    func loadImages(imageIds: [Int]) -> DataRequest {
        
        let params: [String : Any] = ["filters" : [ "id" : imageIds ]]
        return self.request(method: .get, remotePath: baseURLString + "/image", parameters: params)
    }
    
    func loadShopOrders(updatedDate: String, olderThen: Bool, pageSize: Int = 20) -> DataRequest {
        
        var params: [String : Any] = [:]
        
        params["extend"] = "company"
        params["merge"] = "true"
        params["conditions"] = ["updated_at" : olderThen ? [">" : updatedDate] : ["<" : updatedDate]]
        params["page_size"] = pageSize
        params["order"] = ["id" : "desc"]
        
        return self.request(method: .get, remotePath: baseURLString + "/shop-order", parameters: params)
    }
    
    func loadShopOrders(pageNumber: Int, pageSize: Int = 20) -> DataRequest {
        
        var params: [String : Any] = [:]
        
//        params["extend"] = "company"
//        params["merge"] = "true"
        params["page"] = pageNumber
        params["page_size"] = pageSize
        params["order"] = ["id" : "desc"]
        
        return self.request(method: .get, remotePath: baseURLString + "/shop-order", parameters: params)
    }
    
    func updateOrderStatus(orderId: Int, orderStatus: Int) -> DataRequest {
        
        let params: [String : Any] = ["order_status" : orderStatus]
        
        return self.request(method: .put, remotePath: baseURLString + "/shop-order/" + String(orderId), parameters: params)
    }
    
    func feed(pageNumber: Int, pageSize: Int = 20) -> DataRequest {
        
        let params: [String : Any] = ["page" : pageNumber,
                                      "page_size" : pageSize,
                                      "extend" : "company,image",
                                      "order" : ["id" : "desc"]]
        return self.request(method: .get, remotePath: baseURLString + "/promotion", parameters : params)
    }
    
    func addBookmark(companyAddressId: Int) -> DataRequest {
        
        return self.request(method: .put, remotePath: baseURLString + "/company-address" + "/\(companyAddressId)", parameters: ["is_favorite" : true])
    }
    
    func removeBookmark(companyAddressId: Int) -> DataRequest {
        
        return self.request(method: .put, remotePath: baseURLString + "/company-address" + "/\(companyAddressId)", parameters: ["is_favorite" : false])
    }
    
    func favoriteCompanyAddresses(location: CLLocation, pageNumber: Int?, pageSize: Int?) -> DataRequest {
        
        var params: [String: Any] = ["lat" : location.coordinate.latitude,
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
        
        return self.request(method: .get, remotePath: baseURLString + "/company-address", parameters: params)
    }
    
    func uploadImage(image: UIImage, encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?) {
        
        TRemoteServer.alamofireManager.upload(multipartFormData: { multipartFormData in
            
                if let data = UIImageJPEGRepresentation(image, 0.85) {
                    
                    multipartFormData.append(data, withName: "file", fileName: "jpg", mimeType: "image/jpeg")
                }
        
            }, to: baseURLString + "/image", encodingCompletion: encodingCompletion)
    }
    
    func applyUserImage(userId: Int, imageId: Int) -> DataRequest {
        
        return self.request(method: .put, remotePath: baseURLString + "/user/\(userId)", parameters: ["image_id" : imageId])
    }
    
    func updateUserInformation(userId: Int, firstName: String?, lastName: String?, email: String?) -> DataRequest {
        
        var params = [String : Any]()
        
        if let firstName = firstName {
            
            params["first_name"] = firstName
        }
        
        if let lastName = lastName {
            
            params["last_name"] = lastName
        }
        
        if let email = email {
            
            params["email"] = email
        }
        
        return self.request(method: .put, remotePath: baseURLString + "/user/\(userId)", parameters: params)
    }
    
    func setCompanyRating(orderId: Int, mark: Int) -> DataRequest {
        
        return self.request(method: .put, remotePath: baseURLString + "/shop-order/\(orderId)", parameters: ["mark" : mark])
    }
    
    
    // MARK: - Private methods
    
    fileprivate func request(method: HTTPMethod, remotePath: URLConvertible) -> DataRequest {
        
        return self.request(method: method, remotePath: remotePath, parameters: nil)
    }
    
    fileprivate func request(method: HTTPMethod, remotePath: URLConvertible, parameters: [String : Any]?) -> DataRequest {
        
        return self.request(method: method, remotePath: remotePath, parameters: parameters, headers: nil);
    }
    
    fileprivate func request(method: HTTPMethod, remotePath: URLConvertible, parameters: Parameters?, headers: [String : String]?) -> DataRequest {
        
        let request = TRemoteServer.alamofireManager.request(remotePath,
                                                             method: method,
                                                             parameters: parameters,
                                                             encoding: method != .post ? URLEncoding.default : JSONEncoding.default,
                                                             headers: headers)
        
        print("request: \(request)\n parameters: \(parameters)")
        return request
    }
}
