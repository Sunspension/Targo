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
    
    func loadCreditCards() -> Request
}