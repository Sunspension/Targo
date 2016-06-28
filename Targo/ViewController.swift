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
        
        Alamofire.request(Router.ApiAuthorization(phoneNumber: "79119477269")).responseObject {
            
            (response: Result<AuthorizationCodeResponse, NSError>) in
            
            if let result = response.value {
                
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

