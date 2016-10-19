//
//  UserRegistrationError.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation

enum UserRegistrationError: Error {
    
    case uknownError(description: String)
    
    case toManyAuthorizationCodeRequest
    
    case blankPhoneNumber
    
    case blankDeviceType
    
    case blankDeviceToken
    
    case wrongCode
    
    
    var message: String {
        
        switch self {
            
        case .uknownError(let description):
            
            return description
            
        case .toManyAuthorizationCodeRequest:
            
            return "authorization_to_many_code_request".localized
            
        case .blankPhoneNumber:
            
            return "authorization_blank_phone".localized
            
        case .blankDeviceType:
            
            return "authorization_blank_device_type".localized
            
        case .blankDeviceToken:
            
            return "authorization_blank_device_token".localized
            
        case .wrongCode:
            
            return "authorization_uknown_code".localized
        }
    }
}
