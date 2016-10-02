//
//  API.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 06/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import RealmSwift
import BrightFutures
import KeychainSwift
import CoreLocation
import ObjectMapper

struct Api {
    
    static let sharedInstance = Api()
    
    let server: PRemoteServerV1 = TRemoteServer()
    
    func userRegistration(phoneNumber: String) -> Future<Bool, UserRegistrationError> {
        
        let p = Promise<Bool, UserRegistrationError>()
        
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey(kTargoDeviceToken) as? String
        
        server.registration(phoneNumber, deviceToken: deviceToken ?? "", parameters: nil)
            
            .responseJSON { response in
                
                print(response.result.value)
            }
            .responseObject("data") { (response: Response<TAuthorizationResponse, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    switch response.result.error! {
                        
                    case .BadRequest:
                        
                        let error = response.result.error?.userData as! TBadRequest
                        
                        switch error.name {
                            
                        case "Bad Request":
                            
                            p.failure(.ToManyAuthorizationCodeRequest)
                            return
                            
                        default:
                            break
                        }
                        
                    case .ServerError:
                        
                        let error = response.result.error?.userData as! TServerError
                        
                        // We can get many errors but we are going to handle just first
                        let firstError = error.errors.first
                        
                        switch firstError!.field {
                            
                        case "phone":
                            
                            p.failure(UserRegistrationError.BlankPhoneNumber)
                            
                            return
                            
                        case "device_type":
                            
                            p.failure(UserRegistrationError.BlankDeviceType)
                            
                            return
                            
                        case "device_token":
                            
                            p.failure(UserRegistrationError.BlankDeviceToken)
                            
                            return
                            
                        default:
                            break
                        }
                        
                        break
                        
                    default:
                        break
                    }
                    
                    p.failure(UserRegistrationError.UknownError(description: response.result.error!.localizedDescription))
                    
                    return
                }
                
                p.success(true)
            }
        
        return p.future
    }
    
    func userLogin(phoneNumber: String, code: String) -> Future<User, UserRegistrationError> {
        
        let p = Promise<User, UserRegistrationError>()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let token = defaults.objectForKey(kTargoDeviceToken) as? String {
            
            server.authorization(phoneNumber, code: code, deviceToken: token, parameters: nil)
                
                .responseJSON { response in
                    
                    print("login request:\(response.request?.HTTPBody)\n login response:\(response.result.value)")
                }
                .responseObject("data") { (response: Response<UserSession, TargoError>) in
                    
                    guard let _ = response.result.value else {
                        
                        switch response.result.error! {
                            
                        case .BadRequest:
                            
                            let error = response.result.error?.userData as! TBadRequest
                            
                            switch error.message {
                                
                            case "Code not found":
                                
                                p.failure(.WrongCode)
                                return
                                
                            default:
                                break
                            }
                            
                        default:
                            break
                        }
                        
                        p.failure(UserRegistrationError.UknownError(description: "Unknown error"))
                        
                        return
                    }
                    
                    let userSession = response.result.value!
                    
                    let realm = try! Realm()
                    
                    try! realm.write({
                        
                        realm.add(userSession, update: true)
                    })
                }
                .responseObject("data.user") { (response: Response<User, TargoError>) in
                    
                    if let user = response.result.value {
                        
                        print("user: \(user)")
                        
                        let realm = try! Realm()
                        
                        try! realm.write({
                            
                            realm.add(user, update: true)
                        })
                        
                        // save user data to secure storage
                        let keyChain = KeychainSwift()
                        keyChain.set(code, forKey: phoneNumber)
                        
                        p.success(user)
                    }
                }
        }
        
        return p.future
    }
    
    func userLogut() -> Future<Bool, TargoError> {
        
        let p = Promise<Bool, TargoError>()
        
        server.deauthorization()
            
            .responseJSON { response in
                
                print(response.result.value)
            }
            .responseObject("data") { (response: Response<UserSession, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
//                
//                let realm = try! Realm()
//                
//                let sessions = realm.objects(UserSession)
//                let users = realm.objects(User)
//                
//                realm.beginWrite()
//                realm.delete(sessions)
//                realm.delete(users)
//                
//                do {
//                    
//                    try realm.commitWrite()
//                }
//                catch {
//                    
//                    print("Caught an error when was trying to make commit to Realm")
//                }
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.removeObjectForKey(kTargoCodeSent)
                defaults.synchronize()
                
                if let phone = AppSettings.sharedInstance.lastSessionPhoneNumber {
                    
                    let keyChain = KeychainSwift()
                    keyChain.delete(phone)
                }
                
                p.success(true)
            }
        
        return p.future
    }
    
    func loadCurrentUser() -> Future<User, TargoError> {
        
        let p = Promise<User, TargoError>()
        
        let realm = try! Realm()
        
        if let session = realm.objects(UserSession).last {
            
            server.loadUserById(session.userId)
                
                .responseJSON { response in
                    
                    print(response.result.value)
                }
                .responseObject("data.user") { (response: Response<User, TargoError>) in
                    
                    guard let _ = response.result.value else {
                        
                        p.failure(response.result.error!)
                        return
                    }
                    
                    let user = response.result.value!
                    
                    let realm = try! Realm()
                    
                    try! realm.write({
                        
                        realm.add(user, update: true)
                    })
                    
                    p.success(user)
                }
        }
        
        return p.future
    }
    
    func loadCompanyAddresses(location: CLLocation, pageNumber: Int, pageSize: Int = 20, query: String? = nil, distance: Int? = nil) -> Future<TCompanyAddressesPage, TargoError> {
        
        let p = Promise<TCompanyAddressesPage, TargoError>()
        
        server.loadCompanyAddresses(location, pageNumber: pageNumber, pageSize: pageSize, query: query, distance: distance)
            
            .responseJSON { response in
                
                print(response.result.value)
            }
            .responseObject("data") { (response: Response<TCompanyAddressesPage, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                let page = response.result.value!
                p.success(page)
            }
        
        return p.future
    }
    
    func loadCompanyMenu(companyId: Int, pageNumber: Int, pageSize: Int = 20) -> Future<TCompanyMenuPage, TargoError> {
        
        let p = Promise<TCompanyMenuPage, TargoError>()
        
        server.loadCompanyMenu(companyId, pageNumber: pageNumber, pageSize: pageSize)
            
            .responseJSON { response in
                
                print(response.result.value)
            }
            .responseObject("data") { (response: Response<TCompanyMenuPage, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                let page = response.result.value!
                p.success(page)
            }
        
        return p.future
    }
    
    func testOrder() -> Future<TTestOrder, TargoError> {
        
        let p = Promise<TTestOrder, TargoError>()
        
        server.makeTestOrder()
            
            .responseJSON { response in
                
                print(response.result.value)
            }
            .responseObject("data") { (response: Response<TTestOrder, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func checkTestOrder(orderId: Int) -> Future<TTestOrder, TargoError> {
        
        let p = Promise<TTestOrder, TargoError>()
        
        server.checkTestOrder(orderId)
            
            .responseJSON { response in
                
                print(response.result.value)
            }
            .responseObject("data") { (response: Response<TTestOrder, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadCreditCards() -> Future<[TCreditCard], TargoError> {
        
        let p = Promise<[TCreditCard], TargoError>()
        
        server.loadCreditCards()
            
            .responseJSON { response in
                
                print(response.result.value)
            }
            .responseArray("data.card") { (response: Response<[TCreditCard], TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func makeShopOrder(cardId: Int,
                       items: [Int : Int],
                       addressId: Int,
                       serviceId: Int,
                       date: NSDate? = nil,
                       numberOfPersons: Int? = nil,
                       description: String? = nil) -> Future<TShopOrder, TargoError> {
        
        let p = Promise<TShopOrder, TargoError>()
        
        server.makeShopOrder(cardId,
            items: items,
            addressId: addressId,
            serviceId: serviceId,
            date: date,
            numberOfPersons: numberOfPersons,
            description: description)
            
            .responseJSON { response in
                
                let request = String(data: response.request!.HTTPBody!, encoding: NSUTF8StringEncoding)
                
                print("order request:\(request)\n order response:\(response.result.value)")
                
            }.responseObject("data") { (response: Response<TShopOrder, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                let realm = try! Realm()
                
                try! realm.write({
                    
                    realm.add(response.result.value!, update: true)
                })
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func checkShopOrderStatus(orderStatus: Int) -> Future<TShopOrder, TargoError> {
        
        let p = Promise<TShopOrder, TargoError>()
        
        server.checkShopOrderStatus(orderStatus)
            
            .responseJSON { response in
                
                print(response.result.value)
                
            }.responseObject("data") { (response: Response<TShopOrder, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                let realm = try! Realm()
                
                try! realm.write({
                    
                    realm.add(response.result.value!, update: true)
                })
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadCompanyById(companyId: Int) -> Future<TCompany, TargoError> {
        
        let p = Promise<TCompany, TargoError>()
        
        server.loadCompanyById(companyId)
            
            .responseJSON { response in
                
                print(response.result.value)
                
            }.responseObject("data") { (response: Response<TCompany, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadCompaniesByIds(companiesIds: [Int]) -> Future<[TCompany], TargoError> {
        
        let p = Promise<[TCompany], TargoError>()
        
        server.loadCompaniesByIds(companiesIds)
            
            .responseJSON { response in
                
                print(response.result.value)
                
            }.responseArray("data.company") { (response: Response<[TCompany], TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
                
            }
        
        return p.future
    }
    
    func loadImageById(imageId: Int) -> Future<TCompanyImage, TargoError> {
        
        let p = Promise<TCompanyImage, TargoError>()
        
        server.loadImageById(imageId)
            
            .responseJSON { response in
                
                print(response.result.value)
                
            }.responseObject("data.image") { (response: Response<TCompanyImage, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadImagesByIds(imageIds: [Int]) -> Future<[TCompanyImage], TargoError> {
        
        let p = Promise<[TCompanyImage], TargoError>()
        
        server.loadImagesByIds(imageIds)
            
            .responseJSON { response in
            
                print(response.result.value)
                
            }.responseArray("data.image") { (response: Response<[TCompanyImage], TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadShopOrders(updatedDate: String, olderThen: Bool, pageSize: Int) -> Future<[TShopOrder], TargoError> {
        
        let p = Promise<[TShopOrder], TargoError>()
        
        server.loadShopOrders(updatedDate, olderThen: olderThen, pageSize: pageSize)
            
            .responseJSON { response in
            
                print(response.result.value)
            
            }.responseArray("data.shop-order") { (response: Response<[TShopOrder], TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadShopOrders(pageNumber: Int, pageSize: Int = 20) -> Future<[TShopOrder], TargoError> {
        
        let p = Promise<[TShopOrder], TargoError>()
        
        server.loadShopOrders(pageNumber, pageSize: pageSize)
            
            .responseJSON { response in
                
                print(response.result.value)
                
            }.responseArray("data.shop-order") { (response: Response<[TShopOrder], TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func cancelOrderByUser(orderId: Int) -> Future<TShopOrder, TargoError> {
        
        let p = Promise<TShopOrder, TargoError>()
        
        server.updateOrderStatus(orderId, orderStatus: 2)
            
            .responseJSON { response in
            
                print(response.result.value)
                
            }.responseObject("data") { (response:Response<TShopOrder, TargoError>) in
                
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                let realm = try! Realm()
                
                try! realm.write({
                    
                    realm.add(response.result.value!, update: true)
                })
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func feed(pageNumber: Int, pageSize: Int = 20) -> Future<TFeedPage, TargoError> {
        
        let p = Promise<TFeedPage, TargoError>()
        
        server.feed(pageNumber, pageSize: pageSize)
            
            .responseJSON { response in
            
                print(response.result.value)
            }
            .responseObject("data") { (response: Response<TFeedPage, TargoError>) in
             
                guard let _ = response.result.value else {
                    
                    p.failure(response.result.error!)
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
}
