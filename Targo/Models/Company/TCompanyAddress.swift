//
//  TCompany.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 12/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import CoreLocation

class TCompanyAddress: Object, Mappable {

    dynamic var id = 0
    
    dynamic var companyId = 0
    
    dynamic var title = ""
    
    dynamic var latitude = 0.0
    
    dynamic var longitude = 0.0
    
    dynamic var createdAt:String?
    
    dynamic var updatedAt = ""
    
    dynamic var deleted = false
    
    dynamic var deletedAt: String?
    
    dynamic var timeZoneOffset = 0
    
    dynamic var phone = ""
    
    dynamic var companyTitle = ""
    
    dynamic var companyCategoryId = 0
    
    dynamic var companyDescription = ""
    
    let companyImageId = RealmOptional<Int>()
    
    dynamic var companySite = ""
    
    dynamic var companyPhone = ""
    
    dynamic var companyCategoryTitle = ""
    
    dynamic var companyCategoryDescription = ""
    
    dynamic var companyCategoryImageId = 0
    
    dynamic var distance = 0.0
    
    dynamic var rating = 0.0
    
    dynamic var isFavorite = false
    
    dynamic var isAvailable = false
    
    dynamic var discount = 0
    
    let backingWorkingTime = List<TCompanyWorkingDay>()

    var averageOrderTime = List<RealmInt>()
    
    var workingTime: [[String]] {
        
        get {
            
            return backingWorkingTime.map({ day in
                
                var workingDay = [String]()
                workingDay.append(day.begin)
                workingDay.append(day.end)
                return workingDay
            })
        }
    }
    
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        
        return ["workingTime", "averageOrderTime"]
    }

    
    func mapping(map: Map) {
        
        id <- map["id"]
        companyId <- map["company_id"]
        title <- map["title"]
        latitude <- map["lat"]
        longitude <- map["lon"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        deletedAt <- map["updated_at"]
        timeZoneOffset <- map["timezone_offset"]
        phone <- map["phone"]
        companyTitle <- map["company_title"]
        companyCategoryId <- map["company_category_id"]
        companyDescription <- map["company_description"]
        companyImageId.value <- map["image_id"]
        companySite <- map["company_site"]
        companyPhone <- map["company_phone"]
        companyCategoryTitle <- map["company_category_title"]
        companyCategoryDescription <- map["company_category_description"]
        companyCategoryImageId <- map["company_category_image_id"]
        distance <- map["dist"]
        rating <- map["company_rating"]
        isFavorite <- map["is_favorite"]
        isAvailable <- map["is_available"]
        discount <- map["discount_percent"]
        
        let transform = TransformOf<List<RealmInt>, [Int]>(fromJSON: { (value: [Int]?) -> List<RealmInt>? in
            
            if let time = value , time.count == 2 {
                
                let list = List<RealmInt>()
                
                for t in time {
                    
                    list.append(RealmInt(value: ["value" : t]))
                }
                
                return list
            }
            
            return nil
            
            }, toJSON: { (value: List<RealmInt>?) -> [Int]? in
                
                if let time = value {
                    
                    var result = [Int]()
                    
                    for t in time {
                        
                        result.append(t.value)
                    }
                    
                    return result
                }
                
                return nil
        })
        
        averageOrderTime <- (map["avg_order_time"], transform)
        
        var workingTime = [[String]]()
        workingTime <- map["work_time"]
        
        self.backingWorkingTime.append(objectsIn: workingTime.map({ value in
            TCompanyWorkingDay(begin: value[0], end: value[1]) }))
    }
}
