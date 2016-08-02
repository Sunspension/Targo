//
//  UserRegistrationError.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation

enum UserRegistrationError: ErrorType {
    
    case UknownError(description: String)
    
    case ToManyAuthorizationCodeRequest
    
    case BlankPhoneNumber
    
    case BlankDeviceType
    
    case BlankDeviceToken
    
    case WrongCode
    
    
    var message: String {
        
        switch self {
            
        case .UknownError(let description):
            
            return description
            
        case .ToManyAuthorizationCodeRequest:
            
            return "authorization_to_many_code_request".localized
            
        case BlankPhoneNumber:
            
            return "authorization_blank_phone".localized
            
        case BlankDeviceType:
            
            return "authorization_blank_device_type".localized
            
        case BlankDeviceToken:
            
            return "authorization_blank_device_token".localized
            
        case .WrongCode:
            
            return "authorization_uknown_code".localized
        }
    }
}