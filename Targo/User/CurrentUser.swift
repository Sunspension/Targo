//
//  CurrentUser.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 03/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CurrentUser: NSObject {

    var currentUser: User?
    
    static let sharedInstanse = CurrentUser()
    
    override init() {
        
        
    }
}