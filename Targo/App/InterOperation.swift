//
//  InterOperation.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 28/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

struct InterOperation {

    static func makeCall(phoneNumber: String) {
        
        if let phoneURL = NSURL(string: "tel://\(phoneNumber)") {
            
            openURL(phoneURL)
        }
    }
    
    static func openBrowser(urlString: String) {
        
        if let url = NSURL(string: urlString) {
            
            openURL(url)
        }
    }
    
    private static func openURL(url: NSURL) {
        
        let application = UIApplication.sharedApplication()
        
        if application.canOpenURL(url) {
            
            application.openURL(url)
        }
    }
}
