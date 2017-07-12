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
    
    case undefined // 0
    
    case new // 1
    
    case canceledByUser // 2
    
    case view // 3
    
    case canceled // 4
    
    case paymentSuccess // 5
    
    case complete // 6
    
    case finished // 7
    
    case payError // 8
    
    case inProgress // 9
    
    
    static func statusDescriptionFromPaymentStatus(paymentStatus: Int) -> String? {
        
        if let item = ShopOrderStatusEnum(rawValue: paymentStatus) {
            
            return item.statusDescription()
        }
        
        return nil;
    }
    
    func statusDescription() -> String {
        
        switch self {
            
        case .new:
            
            return "order_status_new".localized
            
        case .canceledByUser:
            
            return "order_status_canceled_by_user".localized
            
        case .view:
            
            return "order_status_seen".localized
            
        case .canceled:
            
            return "order_status_canceled".localized
            
        case .paymentSuccess:
            
            return "order_status_processing".localized
            
        case .complete:
            
            return "order_status_ready".localized
            
        case .finished:
            
            return "order_status_finished".localized
            
        case .inProgress:
            
            return "order_status_pay_success".localized
            
        case .payError:
            
            return "order_status_pay_error".localized
            
        default:
            return "Undefined"
        }
    }
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
    
    dynamic var discountAmount = 0
    
    dynamic var cardId = 0
    
    dynamic var orderStatus = 0
    
    dynamic var companyId = 0
    
    dynamic var addressId = 0
    
    dynamic var prepared = ""
    
    dynamic var isNew = false
    
    dynamic var orderStatusTitle = ""
    
    var items = List<TShopGood>()
    
    
    required convenience init?(map: Map) {
        
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
        discountAmount <- map["discount_amount"]
        items <- (map["items"], ListTransform<TShopGood>())
        orderStatusTitle <- map["order_status_title"]
    }
}

extension TShopOrder {
    
    var orderStatusDescription: String? {
        
        return ShopOrderStatusEnum.statusDescriptionFromPaymentStatus(paymentStatus: self.orderStatus)
    }
}
