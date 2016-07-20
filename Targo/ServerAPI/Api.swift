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

struct Api {
    
    static let sharedInstance = Api()
    
    let server: PRemoteServerV1 = TRemoteServer()
    
    func userRegistration(phoneNumber: String) -> Future<Bool, UserRegistrationError> {
        
        let p = Promise<Bool, UserRegistrationError>()
        
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey(kTargoDeviceToken) as? String
        
        server.registration(phoneNumber, deviceToken:deviceToken ?? "", parameters: nil)
            .validate()
            .responseJSON(completionHandler: { response in
                
                if let error = response.result.error {
                    
                    print("User registration error :\(error)")
                    
                    if let errorKey = error.userInfo.keys.first as? String {
                        
                        switch errorKey {
                            
                        case "phone":
                            
                            p.failure(.WrongPhoneNumber)
                            break
                            
                        default:
                            
                            do {
                                
                                let json = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions())
                                let description = json.debugDescription
                                p.failure(.UknownError(description: description))
                                print(json)
                            }
                            catch {
                                
                                print(error)
                            }
                            
                            break
                        }
                    }
                    else {
                        
                        p.failure(.UknownError(description: response.result.error!.description))
                    }
                }
                
                print("User registration value: \(response.result.value)")
            })
            .responseObject { (response: Result<AuthorizationCodeResponse, NSError>) in
                
                if response.isSuccess {
                    
                    AppSettings.sharedInstance.lastSessionPhoneNumber = phoneNumber
                    p.success(true)
                }
        }
        
        return p.future
    }
    
    func userLogin(phoneNumber: String, code: String) -> Future<User, UserRegistrationError> {
        
        let p = Promise<User, UserRegistrationError>()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let token = defaults.objectForKey(kTargoDeviceToken) as? String {
            
            server.authorization(phoneNumber, code: code, deviceToken: token, parameters: nil)
                .validate()
                .responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                    
                    if let error = response.result.error {
                        
                        print("User login error :\(error)")
                        
                        if let errorKey = error.userInfo.keys.first as? String {
                            
                            switch errorKey {
                                
                            case "StatusCode":
                                
                                p.failure(.UnacceptableStatusCode(description: error.localizedDescription))
                                break
                                
                            case "phone":
                                
                                p.failure(.WrongPhoneNumber)
                                break
                                
                            default:
                                
                                p.failure(.UknownError(description: ""))
                                break
                            }
                        }
                        else {
                            
                            p.failure(.UknownError(description: ""))
                        }
                    }
                    
                    print("User login value: \(response.result.value)")
                })
                .responseObject(queue: nil, keyPath: "data", mapToObject: UserSession(), completionHandler: { (response:Response<UserSession, NSError>) in
                    
                    if let userSession = response.result.value {
                        
                        print("user session: \(userSession)")
                        
                        let realm = try! Realm()
                        
                        try! realm.write({
                            
                            realm.add(userSession, update: true)
                        })
                    }
                })
                .responseObject(queue: nil, keyPath: "data.user", mapToObject: User(), completionHandler: { (response: Response<User, NSError>) in
                    
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
        }
        
        return p.future
    }
    
    func userLogut() -> Future<Bool, TargoError> {
        
        let p = Promise<Bool, TargoError>()
        
        server.deauthorization().validate().responseJSON { (response: Response<AnyObject, NSError>) in
            
            if response.result.error != nil {
                
                p.failure(.UserDeauthorizationFailed)
            }
            
            p.success(true)
            
            }
            .responseObject(queue: nil, keyPath: "data", mapToObject: UserSession(), completionHandler: { (response:Response<UserSession, NSError>) in
                
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
                .responseObject(queue: nil,
                                keyPath: "data.user",
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
            .responseObject(queue: nil,
                keyPath: "data",
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
            .validate().responseJSON { response in
                
                print(response.result.value)
                
        }.responseObject(queue: nil, keyPath: "data",
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
}
