//
//  TTestOrderResponse.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

class TTestOrderResponse: NSObject, Mappable {
    
    var id = 0
    
    var userId = 0
    
    var responseDescription = ""
    
    var errorMessage = ""
    
    var paymentStatus = 0
    
    var type = 0
    
    var cardId = 0
    
    var amount = 0
    
    var url = ""
    
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    
    func mapping(map: Map) {
        
        userId <- map["user_id"]
        responseDescription <- map["description"]
        errorMessage <- map["error_message"]
        paymentStatus <- map["paymant_status"]
        type <- map["type"]
        cardId <- map["card_id"]
        amount <- map["card_id"]
        id <- map["id"]
        url <- map["url"]
    }
}
