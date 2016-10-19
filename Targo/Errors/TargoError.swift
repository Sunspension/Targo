//
//  TargoErrors.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 06/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

enum TargoError: Error {

    static let domain = "com.targo.error";

    case error(error: Error)
    
    case dataSerializationFailed(failureReason: String)
    
    case serverError(failureReason: TServerError)
    
    case badRequest(failureReason: TBadRequest)
    
    case userLoginFailed
    
    case userLoadingFailed
    
    case companyPageLoadingFailed
    
    case companyMenuPageLoadingFailed
    
    case userDeauthorizationFailed
    
    case deviceTypeBlank
    
    case deviceTokenBlank
    
    case testOrderError
    
    case creditCardsLoadingError
    
    case undefinedError(message: String)

    case shopOrderError
    
    
    var message: String {
        
        switch self {
            
        case .deviceTokenBlank:
            
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
            
        case .dataSerializationFailed(let message):
            
            return message
            
        case .badRequest(let failureReason):
            
            return failureReason.message.isEmpty ? failureReason.name :failureReason.message
            
        case .error(let error):
            return error.localizedDescription
            
        default:
            return ""
        }
    }
    
    var userData: AnyObject? {
        
        switch self {
            
        case .badRequest(let failureReason):
            
            return failureReason
            
        case .serverError(let failureReason):
            
            return failureReason
            
        default:
            return nil
        }
    }
}

