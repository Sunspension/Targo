//
//  UserRegistrationError.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation

enum UserRegistrationError: ErrorType {
    
    case UknownError
    
    case UnacceptableStatusCode
    
    case WrongPhoneNumber
}