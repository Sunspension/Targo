//
//  InterOperation.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 28/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

struct InterOperation {

    static func makeCall(_ phoneNumber: String) {
        
        if let phoneURL = URL(string: "tel://\(phoneNumber)") {
            
            openURL(phoneURL)
        }
    }
    
    static func openBrowser(_ urlString: String) {
        
        if let url = URL(string: urlString) {
            
            openURL(url)
        }
    }
    
    fileprivate static func openURL(_ url: URL) {
        
        let application = UIApplication.shared
        
        if application.canOpenURL(url) {
            
            application.openURL(url)
        }
    }
}
