//
//  AuthorizationCodeResponse.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 28/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import EVReflection

class ResponseError: EVObject {
    
    var field: String?
    
    var message: String?
}


class AuthorizationCodeResponse: EVObject {

    var data: AuthorizationCodeResponseItem?
    
    var status: NSNumber?
    
    var errors: [ResponseError] = [ResponseError]()
}


class AuthorizationCodeResponseItem: EVObject {
    
    var phone: NSNumber?
    
    var deviceType: String?
    
    var deviceToken: String?
    
    var type: NSNumber?
    
    var id: NSNumber?
}