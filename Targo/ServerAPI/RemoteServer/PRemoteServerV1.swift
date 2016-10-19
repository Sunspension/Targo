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
    
    func registration(phoneNumber: String, deviceToken: String, parameters: [String : Any]?) -> DataRequest
    
    func authorization(phoneNumber: String, code: String, deviceToken: String, parameters: [String : Any]?) -> DataRequest
    
    func deauthorization() -> DataRequest
    
    func loadUserById(userId: Int) -> DataRequest
    
    func loadCompanyAddresses(location: CLLocation, pageNumber: Int, pageSize: Int, query: String?, distance: Int?) -> DataRequest
    
    func loadCompanyMenu(companyId: Int, pageNumber: Int, pageSize: Int) -> DataRequest
    
    func makeTestOrder() -> DataRequest
    
    func checkTestOrder(orderId: Int) -> DataRequest
    
    func loadCreditCards() -> DataRequest
    
    func makeShopOrder(cardId: Int,
                       items: [Int : Int],
                       addressId: Int,
                       serviceId: Int,
                       date: Date?,
                       numberOfPersons: Int?,
                       description: String?) -> DataRequest
    
    func checkShopOrderStatus(orderStatus: Int) -> DataRequest
    
    func loadCompanyById(companyId: Int) -> DataRequest
    
    func loadCompaniesByIds(companiesIds: [Int]) -> DataRequest
    
    func loadImageById(imageId: Int) -> DataRequest
    
    func loadImagesByIds(imageIds: [Int]) -> DataRequest
    
    func loadShopOrders(updatedDate: String, olderThen: Bool, pageSize: Int) -> DataRequest
    
    func loadShopOrders(pageNumber: Int, pageSize: Int) -> DataRequest
    
    func updateOrderStatus(orderId: Int, orderStatus: Int) -> DataRequest
    
    func feed(pageNumber: Int, pageSize: Int) -> DataRequest
    
    func addBookmark(companyAddressId: Int) -> DataRequest
    
    func removeBookmark(companyAddressId: Int) -> DataRequest
    
    func favoriteComanyAddresses(location: CLLocation, pageNumber: Int?, pageSize: Int?) -> DataRequest
    
    func uploadImage(image: UIImage, encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?)
    
    func applyUserImage(userId: Int, imageId: Int) -> DataRequest
    
    func updateUserInformation(userId: Int, firstName: String?, lastName: String?, email: String?) -> DataRequest
    
    func setCompanyRating(orderId: Int, mark: Int) -> DataRequest
}
