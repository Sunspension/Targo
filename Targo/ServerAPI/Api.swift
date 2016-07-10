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

struct Api {
    
    static func userRegistration(phoneNumber: String) -> Future<Bool, UserRegistrationError> {
        
        let p = Promise<Bool, UserRegistrationError>()
        
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey(kTargoDeviceToken) as? String
        
        TRemoteServer.registration(phoneNumber, deviceToken:deviceToken ?? "", parameters: nil)
            .validate()
            .responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                
                if let error = response.result.error {
                    
                    print("User registration error :\(error)")
                    
                    if let errorKey = error.userInfo.keys.first as? String {
                        
                        switch errorKey {
                            
                        case "StatusCode":
                            
                            p.failure(.UnacceptableStatusCode)
                            break
                            
                        case "phone":
                            
                            p.failure(.WrongPhoneNumber)
                            break
                            
                        default:
                            
                            p.failure(.UknownError)
                            break
                        }
                    }
                    else {
                        
                        p.failure(.UknownError)
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
    
    static func userLogin(phoneNumber: String, code: String) -> Future<User, UserRegistrationError> {
        
        let p = Promise<User, UserRegistrationError>()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let token = defaults.objectForKey(kTargoDeviceToken) as? String {
            
            TRemoteServer.authorization(phoneNumber, code: code, deviceToken: token, parameters: nil)
                .validate()
                .responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                    
                    if let error = response.result.error {
                        
                        print("User login error :\(error)")
                        
                        if let errorKey = error.userInfo.keys.first as? String {
                            
                            switch errorKey {
                                
                            case "StatusCode":
                                
                                p.failure(.UnacceptableStatusCode)
                                break
                                
                            case "phone":
                                
                                p.failure(.WrongPhoneNumber)
                                break
                                
                            default:
                                
                                p.failure(.UknownError)
                                break
                            }
                        }
                        else {
                            
                            p.failure(.UknownError)
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
    
    static func userLogut() -> Future<Bool, TargoError> {
        
        let p = Promise<Bool, TargoError>()
        
        TRemoteServer.deauthorization().validate().responseJSON { (response: Response<AnyObject, NSError>) in
            
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
                    realm.beginWrite()
                    realm.delete(sessions)
                    
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
}
