//
//  TShopOrder.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

enum ShopOrderStatusEnum: Int {
    
    case New = 1
    
    case CanceledByUser
    
    case View
    
    case Canceled
    
    case Processing
    
    case Complete
    
    case Finished
    
    case PayError
    
    case PaySuccess
}


class TShopOrder: Object, Mappable {

    dynamic var id = 0
    
    dynamic var userId = 0
    
    dynamic var orderDescription = ""
    
    dynamic var amount = 0.0
    
    dynamic var created = ""
    
    dynamic var updated = ""
    
    dynamic var deleted = false
    
    dynamic var paymentStatus = 0
    
    dynamic var cardId = 0
    
    dynamic var orderStatus = 0
    
    dynamic var companyId = 0
    
    dynamic var addressId = 0
    
    dynamic var prepared = ""
    
    var items = List<TShopGood>()
    
    required convenience init?(_ map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        userId <- map["user_id"]
        orderDescription <- map["description"]
        amount <- map["amount"]
        created <- map["created_at"]
        updated <- map["updated_at"]
        deleted <- map["deleted"]
        paymentStatus <- map["payment_status"]
        cardId <- map["card_id"]
        orderStatus <- map["order_status"]
        companyId <- map["company_id"]
        addressId <- map["address_id"]
        prepared <- map["prepared_at"]
        items <- (map["items"], ListTransform<TShopGood>())
    }
}