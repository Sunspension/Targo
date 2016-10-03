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
    
    func loadCompanyAddresses(location: CLLocation, pageNumber: Int, pageSize: Int, query: String?, distance: Int?) -> Request
    
    func loadCompanyMenu(companyId: Int, pageNumber: Int, pageSize: Int) -> Request
    
    func makeTestOrder() -> Request
    
    func checkTestOrder(orderId: Int) -> Request
    
    func loadCreditCards() -> Request
    
    func makeShopOrder(cardId: Int,
                       items: [Int : Int],
                       addressId: Int,
                       serviceId: Int,
                       date: NSDate?,
                       numberOfPersons: Int?,
                       description: String?) -> Request
    
    func checkShopOrderStatus(orderStatus: Int) -> Request
    
    func loadCompanyById(companyId: Int) -> Request
    
    func loadCompaniesByIds(companiesIds: [Int]) -> Request
    
    func loadImageById(imageId: Int) -> Request
    
    func loadImagesByIds(imageIds: [Int]) -> Request
    
    func loadShopOrders(updatedDate: String, olderThen: Bool, pageSize: Int) -> Request
    
    func loadShopOrders(pageNumber: Int, pageSize: Int) -> Request
    
    func updateOrderStatus(orderId: Int, orderStatus: Int) -> Request
    
    func feed(pageNumber: Int, pageSize: Int) -> Request
    
    func addBookmark(companyAddressId: Int) -> Request
}
