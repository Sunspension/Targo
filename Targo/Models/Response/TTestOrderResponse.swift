//
//  TTestOrderResponse.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 27/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import EVReflection

class TTestOrderResponse: EVObject {

    var order: TTestDataResponse?
    var status = 0
    var userId = 0
    
    override func propertyMapping() -> [(String?, String?)] {
        
        return[("order", "data")]
    }
}

class TTestDataResponse: EVObject {
    
    var id: Int?
    
    var userId: Int?
    
    var responseDescription: String?
    
    var errorMessage: String?
    
    var paymentStatus: Int?
    
    var type: Int?
    
    var cardId: Int?
    
    var amount: Int?
    
    var url: String?
    
    override func propertyMapping() -> [(String?, String?)] {
        
        return[("responseDescription", "description"),
               ("errorMessage", "error_message"),
               ("paymentStatus", "payment_status"),
               ("cardType", "card_type"),
               ("userId", "user_id"),
               ("cardId", "card_id")]
    }
}
