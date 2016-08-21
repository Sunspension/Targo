//
//  RRemoteServerV1.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 29/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

protocol PRemoteServerV1 {
    
    func registration(phoneNumber: String, deviceToken: String, parameters: [String : AnyObject]?) -> Request
    
    func authorization(phoneNumber: String, code: String, deviceToken: String, parameters: [String : AnyObject]?) -> Request
    
    func deauthorization() -> Request
    
    func loadUserById(userId: Int) -> Request
    
    func loadCompaniesByLocation(location: CLLocation) -> Request
    
    func loadCompanyMenu(companyId: Int) -> Request
    
    func makeTestOrder() -> Request
    
    func checkTestOrder(orderId: Int) -> Request
    
    func loadCreditCards() -> Request
    
    func makeShopOrder(cardId: Int, items: [Int : Int], addressId: Int, serviceId: Int, date: NSDate) -> Request
    
    func checkShopOrderStatus(orderStatus: Int) -> Request
}