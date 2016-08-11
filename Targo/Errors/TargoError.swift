//
//  TargoErrors.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 06/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

enum TargoError: ErrorType {

    static let domain = "com.targo.error";
    
    case DataSerializationFailed(failureReason: String)
    
    case ServerError(failureReason: TServerError)
    
    case BadRequest(failureReason: TBadRequest)
    
    case UserLoginFailed
    
    case UserLoadingFailed
    
    case CompanyPageLoadingFailed
    
    case CompanyMenuPageLoadingFailed
    
    case UserDeauthorizationFailed
    
    case DeviceTypeBlank
    
    case DeviceTokenBlank
    
    case TestOrderError
    
    case CreditCardsLoadingError
    
    case UndefinedError(message: String)

    
    var message: String {
        
        switch self {
            
        case .DeviceTokenBlank:
            
            return "Device token is blank."
            
        default:
            return "Uknown error"
        }
    }
    
    var domain: String {
        
        return self.domain
    }
    
    var localizedDescription: String {
        
        switch self {
            
        case .DataSerializationFailed(let message):
            
            return message
            
        case .BadRequest(let failureReason):
            
            return failureReason.message.isEmpty ? failureReason.name :failureReason.message
            
        default:
            return ""
        }
    }
    
    var userData: AnyObject? {
        
        switch self {
            
        case .BadRequest(let failureReason):
            
            return failureReason
            
        case .ServerError(let failureReason):
            
            return failureReason
            
        default:
            return nil
        }
    }
}

