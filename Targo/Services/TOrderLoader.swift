//
//  TOrderLoader.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import RealmSwift

class TOrderLoaderCookie: Object {
    
    dynamic var ordersLoaded = false
}


class TOrderLoader: NSObject {

    var pageNumer: Int = 1
    
    var pageSize: Int = 20
    
    var realm: Realm
    
    
    override init() {
        
        realm = try! Realm()
        
        super.init()
    }
    
    func loadOrders() {
        
        Api.sharedInstance.loadShopOrders(self.pageNumer).onSuccess { orders in
            
            do {
                
                try self.realm.write({
                    
                    self.realm.add(orders, update: true)
                })
            }
            catch {
                
                print("Caught an error when was trying to write orders to Realm")
            }
            
            if self.pageSize == orders.count {
                
                self.pageNumer += 1
                
                self.performSelector(#selector(TOrderLoader.loadOrders))
            }
            else {
                
                do {
                    
                    try self.realm.write({
                        
                        let cookie = self.realm.create(TOrderLoaderCookie.self, value: ["ordersLoaded" : true])
                        self.realm.add(TOrderLoaderCookie(value: cookie))
                        
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoDidLoadOrdersNotification, object: nil))
                    })
                }
                catch {
                    
                    print("Caught an error when was trying to write orders to Realm")
                }
            }
            
        }.onFailure { error in
            
            print("Occurred an error when was trying to load orders: \(error)")
        }
    }
}
