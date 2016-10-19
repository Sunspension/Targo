//
//  ListTransform.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 15/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class ListTransform<T:RealmSwift.Object> : TransformType where T:Mappable {
    
    typealias Object = List<T>
    
    typealias JSON = [AnyObject]
    
    let mapper = Mapper<T>()
    
    
    func transformFromJSON(_ value: Any?) -> Object? {
        
        let results = List<T>()
        
        if let value = value as? [AnyObject] {
            
            for json in value {
                
                if let obj = mapper.map(JSON: json as! [String : Any]) {
                    
                    results.append(obj)
                }
            }
        }
        
        return results
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        
        var results = [AnyObject]()
        
        if let value = value {
            
            for obj in value {
                
                let json = mapper.toJSON(obj)
                results.append(json as AnyObject)
            }
        }
        
        return results

    }
}
