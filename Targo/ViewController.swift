//
//  ViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireJsonToObjects

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey(kTargoDeviceToken)
        let params: [String: AnyObject] = ["phone" : "79119477269", "device_type" : "ios", "device_token" : deviceToken ?? "11123123"]
        
        Alamofire.request(.POST, Router.baseURLString + "/code", parameters: params, encoding: Alamofire.ParameterEncoding.JSON, headers: nil).responseString { (response: Response<String, NSError>) in
            
            print("response: \(response)")
            
            }.responseObject { (request, response, result: Result<AuthorizationCodeResponse, NSError>) in
            
                if let res = result.value {
                    
                    let i = 0
                }
        }
        
//        Alamofire.request(Router.ApiAuthorization(phoneNumber: "79119477269")).responseObject {
//            
//            (response: Result<AuthorizationCodeResponse, NSError>) in
//            
//            if let result = response.value {
//                
//            }
//        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

