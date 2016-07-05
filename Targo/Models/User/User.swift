//
//  User.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 29/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class User: Object, Mappable {

    dynamic var id = 0
    
    dynamic var phone = ""
    
    dynamic var firstName = ""
    
    dynamic var lastName = ""
    
    dynamic var createdAt = ""
    
    dynamic var updatedAt = ""
    
    dynamic var deleted = false
    
    dynamic var deletedAt = ""
    
    dynamic var status = 0
    
    dynamic var sendEmail = false
    
    dynamic var sendPush = false
    
    dynamic var sendSMS = false
    
    dynamic var alias = ""
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        phone <- map["phone"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        deletedAt <- map["deleted_at"]
        status <- map["status"]
        sendEmail <- map["send_email"]
        sendPush <- map["send_push"]
        sendSMS <- map["send_sms"]
        alias <- map["alias"]
    }
}
