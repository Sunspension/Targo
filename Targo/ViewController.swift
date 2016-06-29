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
        
        TRemoteServer.registration("", parameters: nil)
            .responseObject { (response: Result<AuthorizationCodeResponse, NSError>) in
                
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

