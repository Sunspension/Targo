//
//  HTTPManager.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 15/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Alamofire
import Timberjack

class HTTPManager: Alamofire.Manager {

    static let sharedManager: HTTPManager = {
        let configuration = Timberjack.defaultSessionConfiguration()
        let manager = HTTPManager(configuration: configuration)
        return manager
    }()
}
