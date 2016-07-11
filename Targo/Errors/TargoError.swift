//
//  TargoErrors.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 06/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

enum TargoError: ErrorType {

    static let domain = "com.targo.error";
    
    case UserLoginFailed
    
    case LoadUserFiled
    
    case UserDeauthorizationFailed
    
    case DeviceTypeBlank
    
    case DeviceTokenBlank
    
    case UndefinedError(message: String)

    
    var message: String {
        
        switch self {
            
        case .DeviceTokenBlank:
            
            return "Device token is blank."
            
        default:
            return "Uknown error"
        }
    }
}

