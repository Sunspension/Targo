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
            .responseObject("data", completionHandler: { (response: Response<AuthorizationResponse, TargoError>) in
                
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
                    
                    p.failure(UserRegistrationError.UknownError(description: "Unknown error"))
                    
                    return
                }
                
                p.success(true)
            })
        
        return p.future
    }
    
    func userLogin(phoneNumber: String, code: String) -> Future<User, UserRegistrationError> {
        
        let p = Promise<User, UserRegistrationError>()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let token = defaults.objectForKey(kTargoDeviceToken) as? String {
            
            server.authorization(phoneNumber, code: code, deviceToken: token, parameters: nil)
                
                .responseObject("data", completionHandler: { (response: Response<UserSession, TargoError>) in
                    
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
                })
                
//                .responseObject(keyPath: "data", mapToObject: UserSession(),
//                    completionHandler: { (response:Response<UserSession, NSError>) in
//                        
//                        if let userSession = response.result.value {
//                            
//                            print("user session: \(userSession)")
//                            
//                            let realm = try! Realm()
//                            
//                            try! realm.write({
//                                
//                                realm.add(userSession, update: true)
//                            })
//                        }
//                })
                
                .responseObject("data.user", completionHandler: { (response: Response<User, TargoError>) in
                    
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
                })
//                .responseObject(keyPath: "data.user", mapToObject: User(),
//                                completionHandler: { (response: Response<User, NSError>) in
//                                    
//                                    if let user = response.result.value {
//                                        
//                                        print("user: \(user)")
//                                        
//                                        let realm = try! Realm()
//                                        
//                                        try! realm.write({
//                                            
//                                            realm.add(user, update: true)
//                                        })
//                                        
//                                        // save user data to secure storage
//                                        let keyChain = KeychainSwift()
//                                        keyChain.set(code, forKey: phoneNumber)
//                                        
//                                        p.success(user)
//                                    }
//                })
        }
        
        return p.future
    }
    
    func userLogut() -> Future<Bool, TargoError> {
        
        let p = Promise<Bool, TargoError>()
        
        server.deauthorization()
            .validate()
            .responseJSON { (response: Response<AnyObject, NSError>) in
                
                if response.result.error != nil {
                    
                    p.failure(.UserDeauthorizationFailed)
                }
                
                p.success(true)
            }
            .responseObject(keyPath: "data", mapToObject: UserSession(),
                            completionHandler: { (response:Response<UserSession, NSError>) in
                                
                                if let userSession = response.result.value {
                                    
                                    print("user logout session: \(userSession)")
                                    
                                    let realm = try! Realm()
                                    
                                    let sessions = realm.objects(UserSession)
                                    let users = realm.objects(User)
                                    
                                    realm.beginWrite()
                                    realm.delete(sessions)
                                    realm.delete(users)
                                    
                                    do {
                                        
                                        try realm.commitWrite()
                                    }
                                    catch {
                                        
                                        print("Caught an error when was trying to make commit to Realm")
                                    }
                                    
                                    let defaults = NSUserDefaults.standardUserDefaults()
                                    defaults.removeObjectForKey(kTargoCodeSent)
                                    defaults.synchronize()
                                }
            })
        
        return p.future
    }
    
    func loadCurrentUser() -> Future<User, TargoError> {
        
        let p = Promise<User, TargoError>()
        
        let realm = try! Realm()
        
        if let session = realm.objects(UserSession).last {
            
            server.loadUserById(session.userId)
                .validate()
                .responseObject(keyPath: "data.user",
                                mapToObject: User(),
                                completionHandler: { (response: Response<User, NSError>) in
                                    
                                    if let user = response.result.value {
                                        
                                        print("user: \(user)")
                                        
                                        let realm = try! Realm()
                                        
                                        try! realm.write({
                                            
                                            realm.add(user, update: true)
                                        })
                                        
                                        p.success(user)
                                    }
                })
        }
        
        return p.future
    }
    
    func loadCompanies(location: CLLocation) -> Future<TCompaniesPage, TargoError> {
        
        let p = Promise<TCompaniesPage, TargoError>()
        
        server.loadCompaniesByLocation(location)
            .debugLog()
            .validate()
            .responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                
                print(response.result.value)
                
            })
            .responseObject(keyPath: "data",
                            mapToObject: TCompaniesPage(),
                            context: nil) { (response: Response<TCompaniesPage, NSError>) in
                                
                                if let page = response.result.value {
                                    
                                    print("companies page: \(page)")
                                    p.success(page)
                                }
                                else if let error = response.result.error {
                                    
                                    print("page error: \(error)")
                                    
                                    p.failure(.CompanyPageLoadingFailed)
                                }
        }
        
        return p.future
    }
    
    func loadCompanyMenu(companyId: Int) -> Future<TCompanyMenuPage, TargoError> {
        
        let p = Promise<TCompanyMenuPage, TargoError>()
        
        server.loadCompanyMenu(companyId)
            .debugLog()
            .validate()
            .responseJSON { response in
                
                print(response.result.value)
                
            }.responseObject(keyPath: "data",
                             mapToObject: TCompanyMenuPage(),
                             context: nil) { response in
                                
                                if let page = response.result.value {
                                    
                                    print("company menu page: \(page)")
                                    p.success(page)
                                }
                                else if let error = response.result.error {
                                    
                                    print("menu page error: \(error)")
                                    p.failure(.CompanyMenuPageLoadingFailed)
                                }
        }
        
        return p.future
    }
    
    func makeTestOrder() -> Future<TTestOrderResponse, TargoError> {
        
        let p = Promise<TTestOrderResponse, TargoError>()
        
        server.makeTestOrder()
            .debugLog()
            .responseJSON { response in
                
                print(response.result)
                
            }.responseObject { (response: Result<TTestOrderResponse, NSError>) in
                
                if let result = response.value {
                    
                    p.success(result)
                }
                else if let error = response.error {
                    
                    p.failure(TargoError.TestOrderError(message: error.localizedDescription))
                }
        }
        
        return p.future
    }
}
