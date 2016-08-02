//
//  AlamofireExtensions.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 04/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

extension Request {
    
    func debugLog() -> Request {
        
        debugPrint(self)
        return self
    }
}

extension Request {
    
    func responseObject<T: Mappable>(keyPath: String? = nil, completionHandler: Response<T, TargoError> -> Void) -> Self {
        
        let responseSerializer = ResponseSerializer<T, TargoError> { request, response, data, error in
            
            guard error == nil else {
                
                return .Failure(TargoError.UndefinedError(message: error!.localizedDescription))
            }
            
            guard data != nil else {
                
                let failureReason = "Object could not be serialized because data was nil."
                return .Failure(.DataSerializationFailed(failureReason: failureReason))
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            guard result.isSuccess else {
                
                let failureReason = "JSON could not be converted to object."
                return .Failure(.DataSerializationFailed(failureReason: failureReason))
            }
            
            if let status = result.value?.valueForKey("status") as? Int {
                
                guard status != 400 else {
                    
                    let error = Mapper<TBadRequest>().map(result.value)
                    return .Failure(.BadRequest(failureReason: error!))
                }
                
                guard status != 422 else {
                    
                    let error = Mapper<TServerError>().map(result.value)
                    return .Failure(.ServerError(failureReason: error!))
                }
            }
            
            let JSONToMap: AnyObject?
            
            if let keyPath = keyPath where keyPath.isEmpty == false {
                
                JSONToMap = result.value?.valueForKeyPath(keyPath)
            }
            else {
                
                JSONToMap = result.value
            }
            
            guard let parsedObject = Mapper<T>().map(JSONToMap) else {
                
                let failureReason = "ObjectMapper failed to serialize response."
                return .Failure(.DataSerializationFailed(failureReason: failureReason))
            }
            
            return .Success(parsedObject)
        }
        
        return response(responseSerializer:responseSerializer, completionHandler: completionHandler)
    }
    
    func responseArray<T: Mappable>(keyPath: String? = nil, completionHandler: Response<[T], TargoError> -> Void) -> Self {
        
        let responseSerializer = ResponseSerializer<[T], TargoError> { request, response, data, error in
            
            guard error == nil else {
                
                return .Failure(TargoError.UndefinedError(message: error!.localizedDescription))
            }
            
            guard data != nil else {
                
                let failureReason = "Object could not be serialized because data was nil."
                return .Failure(.DataSerializationFailed(failureReason: failureReason))
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            guard result.isSuccess else {
                
                let failureReason = "JSON could not be converted to object."
                return .Failure(.DataSerializationFailed(failureReason: failureReason))
            }
            
            if let status = result.value?.valueForKey("status") as? Int {
                
                guard status != 400 else {
                    
                    let error = Mapper<TBadRequest>().map(result.value)
                    return .Failure(.BadRequest(failureReason: error!))
                }
                
                guard status != 422 else {
                    
                    let error = Mapper<TServerError>().map(result.value)
                    return .Failure(.ServerError(failureReason: error!))
                }
            }
            
            let JSONToMap: AnyObject?
            
            if let keyPath = keyPath where keyPath.isEmpty == false {
                
                JSONToMap = result.value?.valueForKeyPath(keyPath)
            }
            else {
                
                JSONToMap = result.value
            }
            
            guard let parsedObject = Mapper<T>().mapArray(JSONToMap) else {
                
                let failureReason = "ObjectMapper failed to serialize response."
                return .Failure(.DataSerializationFailed(failureReason: failureReason))
            }
            
            return .Success(parsedObject)
        }
        
        return response(responseSerializer:responseSerializer, completionHandler: completionHandler)
    }
}

