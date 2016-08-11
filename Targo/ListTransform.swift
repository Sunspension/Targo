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

class ListTransform<T:RealmSwift.Object where T:Mappable> : TransformType {
    
    let mapper = Mapper<T>()

    
//    func transformFromJSON(value: AnyObject?) -> List<T>? {
//        
//        let results = List<T>()
//        
//        if let tempArray = value as! Array<AnyObject>? {
//            
//            for entry in tempArray {
//                
//                let model = mapper.map(entry)!
//                results.append(model)
//            }
//        }
//        
//        return results
//    }
    
    
    func transformFromJSON(value: AnyObject?) -> List<T>? {
        
        let results = List<T>()
        
        if let value = value as? [AnyObject] {
            
            for json in value {
                
                if let obj = mapper.map(json) {
                    
                    results.append(obj)
                }
            }
        }
        
        return results
    }
    
    func transformToJSON(value: List<T>?) -> [AnyObject]? {
        
        var results = [AnyObject]()
        
        if let value = value {
        
            for obj in value {
            
                let json = mapper.toJSON(obj)
                results.append(json)
            }
        }
        
        return results
    }
}