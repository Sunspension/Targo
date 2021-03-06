//
//  TTestOrderResponse.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper

enum PaymentStatus: Int {
    
    case new = 1
    case ready
    case processing
    case complete
    case error
}

class TTestOrder: NSObject, Mappable {
    
    var id = 0
    
    var userId = 0
    
    var responseDescription = ""
    
    var message = ""
    
    var paymentStatus = 0
    
    var type = 0
    
    var cardId = 0
    
    var amount = 0
    
    var url = ""
    
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    
    func mapping(map: Map) {
        
        userId <- map["user_id"]
        responseDescription <- map["description"]
        message <- map["message"]
        paymentStatus <- map["payment_status"]
        type <- map["type"]
        cardId <- map["card_id"]
        amount <- map["amount"]
        id <- map["id"]
        url <- map["url"]
    }
}
