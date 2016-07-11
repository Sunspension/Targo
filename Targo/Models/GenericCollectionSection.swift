//
//  GenericCollectionSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericCollectionSection<TCollectionItem>: NSObject {

    var title: String
    
    var items: [TCollectionItem] = []
    
    
    init(title: String?) {
        
        self.title = title ?? ""
    }
}