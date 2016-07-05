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

struct Api {

    static func userLogin(phoneNumber: String, code: String) -> Future<User, TargoError> {
        
        let p = Promise<User, TargoError>()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let token = defaults.objectForKey(kTargoDeviceToken) as? String {
            
            TRemoteServer.authorization(phoneNumber, code: code, deviceToken: token, parameters: nil)
                .validate()
                .responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                    
                    print("response: \(response.result.value)")
                    
                })
                .responseObject(queue: nil, keyPath: "data.user", mapToObject: User(), completionHandler: { (response: Response<User, NSError>) in
                    
                    if let user = response.result.value {
                        
                        print("response: \(user)")
                        
                        let realm = try! Realm()
                        
                        try! realm.write({
                            
                            realm.add(user, update: true)
                        })
                        
                        p.success(user)
                    }
                    else if let error = response.result.error {
                        
                        p.failure(.UserLoginFailed)
                        print("response user authentification: \(error)")
                    }
                })
        }
        
        return p.future
    }
}
