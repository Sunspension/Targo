//
//  AppSettings.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 05/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class AppSettings: NSObject {

    static let sharedInstance = AppSettings()
    
    var lastSessionPhoneNumber: String? {
        
        get {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            return defaults.objectForKey(kTargoLastSessionPhone) as? String
        }
        
        set (newValue) {
            
            let defauls = NSUserDefaults.standardUserDefaults()
            defauls.setValue(newValue, forKey: kTargoLastSessionPhone)
        }
    }
}
