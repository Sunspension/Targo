//
//  APIRouter.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 28/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    
    static let baseURLString = "http://45.62.123.157:8082/api/"
    
    static let perPage = 10
    
    
//    case Search(query: String, page: Int)
    
    case ApiAuthorization(phoneNumber: String)
    
    case ApiAuthorizationCode(phoneNumber: String, code: String)
    
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        
        let result: (path: String, params: [String : AnyObject]) = {
           
            switch self {
                
            case .ApiAuthorization(let phoneNumber):
                
                return ("code", ["phone" : phoneNumber])
                
            case .ApiAuthorizationCode(let phoneNumber, let code):
                
                return ("auth", ["phone" : phoneNumber, "code" : code])
            }
        }()
        
//        let result: (path: String, parameters: [String: AnyObject]?) = {
//            
//            switch self {
//                
//            case .Search(let query, let page) where page > 0:
//                
//                return ("/search", ["q": query, "offset": Router.perPage * page])
//            
//            case .Search(let query, _):
//                
//                return ("/search", ["q": query])
//                
//            case .Path(let pathString):
//                
//                return (pathString, nil)
//            }
//        }()
        
        let URL = NSURL(string: Router.baseURLString)!
        
        let URLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        
        let encoding = Alamofire.ParameterEncoding.URL
        
        URLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return encoding.encode(URLRequest, parameters: result.params).0
    }
}