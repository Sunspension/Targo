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
        
        let deviceToken = UserDefaults.standard.object(forKey: kTargoDeviceToken) as? String
        
        server.registration(phoneNumber: phoneNumber, deviceToken: deviceToken ?? "1111-1111-1111-1111", parameters: nil)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(mapToObject: TBadRequest(), completionHandler: { (response: DataResponse<TBadRequest>) in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
            })
            .responseObject(keyPath: "data", completionHandler: { (response: DataResponse<TAuthorizationResponse>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(UserRegistrationError.uknownError(description: response.result.error!.localizedDescription))
                    return
                }
                
                p.success(true)
            })
            
//            .responseObject("data") { (response: Response<TAuthorizationResponse, TargoError>) in
//                
//                guard let _ = response.result.value else {
//                    
//                    switch response.result.error! {
//                        
//                    case .BadRequest:
//                        
//                        let error = response.result.error?.userData as! TBadRequest
//                        
//                        switch error.name {
//                            
//                        case "Bad Request":
//                            
//                            p.failure(.ToManyAuthorizationCodeRequest)
//                            return
//                            
//                        default:
//                            break
//                        }
//                        
//                    case .ServerError:
//                        
//                        let error = response.result.error?.userData as! TServerError
//                        
//                        // We can get many errors but we are going to handle just first
//                        let firstError = error.errors.first
//                        
//                        switch firstError!.field {
//                            
//                        case "phone":
//                            
//                            p.failure(UserRegistrationError.BlankPhoneNumber)
//                            
//                            return
//                            
//                        case "device_type":
//                            
//                            p.failure(UserRegistrationError.BlankDeviceType)
//                            
//                            return
//                            
//                        case "device_token":
//                            
//                            p.failure(UserRegistrationError.BlankDeviceToken)
//                            
//                            return
//                            
//                        default:
//                            break
//                        }
//                        
//                        break
//                        
//                    default:
//                        break
//                    }
//                    
//                    p.failure(UserRegistrationError.UknownError(description: response.result.error!.localizedDescription))
//                    
//                    return
//                }
//                
//                p.success(true)
//            }
        
        return p.future
    }
    
    func userLogin(phoneNumber: String, code: String) -> Future<User, TargoError> {
        
        let p = Promise<User, TargoError>()
        
        let defaults = UserDefaults.standard
        
        let token = defaults.object(forKey: kTargoDeviceToken) as? String ?? "1111-1111-1111-1111"
        
        server.authorization(phoneNumber: phoneNumber, code: code, deviceToken: token, parameters: nil)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data", completionHandler: { (response: DataResponse<UserSession>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                let userSession = response.result.value!
                
                let realm = try! Realm()
                
                try! realm.write({
                    
                    realm.add(userSession, update: true)
                })
            })
            .responseObject(keyPath: "data.user") { (response: DataResponse<User>) in
                
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
        
//        if let token = defaults.object(forKey: kTargoDeviceToken) as? String {
//            
//            server.authorization(phoneNumber: phoneNumber, code: code, deviceToken: token, parameters: nil)
//                
//                .responseJSON { response in
//                    
//                    if let error = response.result.error {
//                        
//                        print("Response error: \(error)")
//                    }
//                    else {
//                        
//                        print("Response result: \(response.result.value)")
//                    }
//                }
//                .responseObject(keyPath: "data", completionHandler: { (response: DataResponse<UserSession>) in
//                    
//                    guard response.result.error == nil else {
//                        
//                        p.failure(.error(error: response.result.error!))
//                        return
//                    }
//                    
////                    guard let _ = response.result.value else {
////                        
////                        p.failure(UserRegistrationError.uknownError(description: response.result.error!.localizedDescription))
////                        return
////                    }
//                    
//                    let userSession = response.result.value!
//                    
//                    let realm = try! Realm()
//                    
//                    try! realm.write({
//                        
//                        realm.add(userSession, update: true)
//                    })
//                })
////                .responseObject(keyPath: "data") { (response: DataResponse<UserSession>) in
////                    
////                    guard let _ = response.result.value else {
////                        
////                        switch response.result.error! {
////                            
////                        case .BadRequest:
////                            
////                            let error = response.result.error?.userData as! TBadRequest
////                            
////                            switch error.message {
////                                
////                            case "Code not found":
////                                
////                                p.failure(.WrongCode)
////                                return
////                                
////                            default:
////                                break
////                            }
////                            
////                        default:
////                            break
////                        }
////                        
////                        p.failure(UserRegistrationError.UknownError(description: "Unknown error"))
////                        
////                        return
////                    }
////                    
////                    let userSession = response.result.value!
////                    
////                    let realm = try! Realm()
////                    
////                    try! realm.write({
////                        
////                        realm.add(userSession, update: true)
////                    })
////                }
//                .responseObject(keyPath: "data.user") { (response: DataResponse<User>) in
//                    
//                    if let user = response.result.value {
//                        
//                        print("user: \(user)")
//                        
//                        let realm = try! Realm()
//                        
//                        try! realm.write({
//                            
//                            realm.add(user, update: true)
//                        })
//                        
//                        // save user data to secure storage
//                        let keyChain = KeychainSwift()
//                        keyChain.set(code, forKey: phoneNumber)
//                        
//                        p.success(user)
//                    }
//                }
//        }
        
        return p.future
    }
    
    func userLogut() -> Future<Bool, TargoError> {
        
        let p = Promise<Bool, TargoError>()
        
        server.deauthorization()
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<UserSession>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
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
                
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: kTargoCodeSent)
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
        
        if let session = realm.objects(UserSession.self).last {
            
            server.loadUser(userId: session.userId)
                
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        
                        print("Response error: \(error)")
                    }
                    else {
                        
                        print("Response result: \(response.result.value)")
                    }
                }
                .responseObject(keyPath: "data") { (response: DataResponse<User>) in
                    
                    guard response.result.error == nil else {
                        
                        p.failure(.error(error: response.result.error!))
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
    
    func loadCompanyAddress(location: CLLocation?, addressId: Int) -> Future<TCompanyAddress, TargoError> {
        
        let p = Promise<TCompanyAddress, TargoError>()
        
        server.loadCompanyAddress(location: location, addressId: addressId)
            
            .responseJSON { response in
            
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<TCompanyAddress>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                let result = response.result.value!
                p.success(result)
            }
        
        return p.future
    }
    
    func loadCompanyAddresses(location: CLLocation,
                              pageNumber: Int,
                              pageSize: Int = 20,
                              query: String? = nil,
                              distance: Int? = nil) -> Future<TCompanyAddressesPage, TargoError> {
        
        let p = Promise<TCompanyAddressesPage, TargoError>()
        
        server.loadCompanyAddresses(location: location, pageNumber: pageNumber, pageSize: pageSize, query: query, distance: distance)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<TCompanyAddressesPage>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                let page = response.result.value!
                p.success(page)
            }
        
        return p.future
    }
    
    func loadCompanyMenu(companyId: Int,
                         pageNumber: Int,
                         pageSize: Int = 20) -> Future<TCompanyMenuPage, TargoError> {
        
        let p = Promise<TCompanyMenuPage, TargoError>()
        
        server.loadCompanyMenu(companyId: companyId, pageNumber: pageNumber, pageSize: pageSize)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<TCompanyMenuPage>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
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
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<TTestOrder>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func checkTestOrder(orderId: Int) -> Future<TTestOrder, TargoError> {
        
        let p = Promise<TTestOrder, TargoError>()
        
        server.checkTestOrder(orderId: orderId)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<TTestOrder>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
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
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseArray(keyPath: "data.card") { (response: DataResponse<[TCreditCard]>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
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
                       date: Date? = nil,
                       asap: Bool? = nil,
                       numberOfPersons: Int? = nil,
                       description: String? = nil) -> Future<TShopOrder, TargoError> {
        
        let p = Promise<TShopOrder, TargoError>()
        
        server.makeShopOrder(cardId: cardId,
            items: items,
            addressId: addressId,
            serviceId: serviceId,
            date: date,
            asap: asap,
            numberOfPersons: numberOfPersons,
            description: description)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
                
//                let request = String(data: response.request!.HTTPBody!, encoding: String.Encoding.utf8)
//
//                print("order request:\(request)\n order response:\(response.result.value)")
                
            }.responseObject(keyPath: "data") { (response: DataResponse<TShopOrder>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
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
        
        server.checkShopOrderStatus(orderStatus: orderStatus)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
                
            }.responseObject(keyPath: "data") { (response: DataResponse<TShopOrder>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
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
    
    func loadCompany(companyId: Int) -> Future<TCompany, TargoError> {
        
        let p = Promise<TCompany, TargoError>()
        
        server.loadCompany(companyId: companyId)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
                
            }.responseObject(keyPath: "data") { (response: DataResponse<TCompany>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadCompanies(companiesIds: [Int]) -> Future<[TCompany], TargoError> {
        
        let p = Promise<[TCompany], TargoError>()
        
        server.loadCompanies(companiesIds: companiesIds)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
                
            }.responseArray(keyPath: "data.company") { (response: DataResponse<[TCompany]>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
                
            }
        
        return p.future
    }
    
    func loadImage(imageId: Int) -> Future<TImage, TargoError> {
        
        let p = Promise<TImage, TargoError>()
        
        server.loadImage(imageId: imageId)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
                
            }.responseObject(keyPath: "data") { (response: DataResponse<TImage>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadImages(imageIds: [Int]) -> Future<[TImage], TargoError> {
        
        let p = Promise<[TImage], TargoError>()
        
        server.loadImages(imageIds: imageIds)
            
            .responseJSON { response in
            
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
                
            }.responseArray(keyPath: "data.image") { (response: DataResponse<[TImage]>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadShopOrders(updatedDate: String, olderThen: Bool, pageSize: Int) -> Future<[TShopOrder], TargoError> {
        
        let p = Promise<[TShopOrder], TargoError>()
        
        server.loadShopOrders(updatedDate: updatedDate, olderThen: olderThen, pageSize: pageSize)
            
            .responseJSON { response in
            
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            
            }.responseArray(keyPath: "data.shop-order") { (response: DataResponse<[TShopOrder]>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func loadShopOrders(pageNumber: Int, pageSize: Int = 20) -> Future<[TShopOrder], TargoError> {
        
        let p = Promise<[TShopOrder], TargoError>()
        
        server.loadShopOrders(pageNumber: pageNumber, pageSize: pageSize)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
                
            }.responseArray(keyPath: "data.shop-order") { (response: DataResponse<[TShopOrder]>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func cancelOrderByUser(orderId: Int) -> Future<TShopOrder, TargoError> {
        
        let p = Promise<TShopOrder, TargoError>()
        
        server.updateOrderStatus(orderId: orderId, orderStatus: 2)
            
            .responseJSON { response in
            
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
                
            }.responseObject(keyPath: "data") { (response: DataResponse<TShopOrder>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
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
        
        server.feed(pageNumber: pageNumber, pageSize: pageSize)
            
            .responseJSON { response in
            
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<TFeedPage>) in
             
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func addBookmark(companyAddressId: Int) -> Future<TAddRemoveBookmarkResponse, TargoError> {
        
        let p = Promise<TAddRemoveBookmarkResponse, TargoError>()
        
        server.addBookmark(companyAddressId: companyAddressId)
            
            .responseJSON { response in
            
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject { (response: DataResponse<TAddRemoveBookmarkResponse>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
            }
        
        return p.future
    }
    
    func removeBookmark(companyAddressId: Int) -> Future<TAddRemoveBookmarkResponse, TargoError> {
        
        let p = Promise<TAddRemoveBookmarkResponse, TargoError>()
        
        server.removeBookmark(companyAddressId: companyAddressId)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject { (response: DataResponse<TAddRemoveBookmarkResponse>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
        }
        
        return p.future
    }
    
    func favoriteCompanyAddresses(location: CLLocation, pageNumber: Int? = nil, pageSize: Int? = nil) -> Future<TCompanyAddressesPage, TargoError> {
        
        let p = Promise<TCompanyAddressesPage, TargoError>()
        
        server.favoriteCompanyAddresses(location: location, pageNumber: pageNumber, pageSize: pageSize)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<TCompanyAddressesPage>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
        }
        
        return p.future
        
    }
    
    func uploadImage(image: UIImage) -> Future<TImageUploadResponse, TargoError> {
        
        let p = Promise<TImageUploadResponse, TargoError>()
        
        server.uploadImage(image: image) { (encodingResult) in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                upload
                    .responseJSON { response in
                        
                        if let error = response.result.error {
                            
                            print("Error: \(error)")
                        }
                        else {
                            
                            print(response.result.value!)
                        }
                    }
                    .responseObject(keyPath: "data") { (response: DataResponse<TImageUploadResponse>) in
                        
                        guard response.result.error == nil else {
                            
                            p.failure(.error(error: response.result.error!))
                            return
                        }
                        
                        p.success(response.result.value!)
                }
                
            case .failure(let encodingError):
                
                p.failure(.error(error: encodingError))
                print(encodingError)
            }
        }
        
        return p.future
    }
    
    func applyUserImage(userId: Int, imageId: Int) -> Future<User, TargoError> {
        
        let p = Promise<User, TargoError>()
        
        server.applyUserImage(userId: userId, imageId: imageId)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<User>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
        }
        
        return p.future
    }
    
    func updateUserInformation(userId: Int, firstName: String?, lastName: String?, email: String?) -> Future<User, TargoError> {
        
        let p = Promise<User, TargoError>()
        
        server.updateUserInformation(userId: userId, firstName: firstName, lastName: lastName, email: email)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<User>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
        }
        
        return p.future
    }
    
    func setCompanyRating(orderId: Int, mark: Int) -> Future<TShopOrder, TargoError> {
        
        let p = Promise<TShopOrder, TargoError>()
        
        server.setCompanyRating(orderId: orderId, mark: mark)
            
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Response error: \(error)")
                }
                else {
                    
                    print("Response result: \(response.result.value)")
                }
            }
            .responseObject(keyPath: "data") { (response: DataResponse<TShopOrder>) in
                
                guard response.result.error == nil else {
                    
                    p.failure(.error(error: response.result.error!))
                    return
                }
                
                p.success(response.result.value!)
        }
        
        return p.future
    }
    
    fileprivate func validator(_ validation: (URLRequest?, HTTPURLResponse, Data?)) -> Request.ValidationResult {
        
        if let data = validation.2 {
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                
                guard json["user_id"] != nil else {
                    
                    return Request.ValidationResult.failure(TargoError.unAuthorizedRequest)
                }
                
                return .success
            }
            catch {
                
                return Request.ValidationResult.failure(TargoError.dataSerializationFailed(failureReason: "Serializaation data to JSON failed"))
            }
        }
        
        return .success
    }
}
