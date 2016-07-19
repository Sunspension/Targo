//
//  CollectionSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CollectionSection: NSObject {
    
    var title: String?
    
    var items: [CollectionSectionItem] = []
    
    var selectedItems: [Any] = []
    
    
    init(title: String? = "") {
        
        self.title = title;
    }
    
    func initializeCellWithReusableIdentifierOrNibName(identifierOrNibName: String, item: Any?, bindingAction: (cell:UITableViewCell, item: CollectionSectionItem?) -> Void) {
        
        self.initializeCellWithReusableIdentifierOrNibName(identifierOrNibName, item: item, itemType: nil, bindingAction: bindingAction)
    }
    
    func initializeCellWithReusableIdentifierOrNibName(identifierOrNibName: String, item: Any?, itemType: Int?, bindingAction: (cell:UITableViewCell, item: CollectionSectionItem?) -> Void) {
        
        let item = CollectionSectionItem(reusableIdentifierOrNibName: identifierOrNibName, item: item)
        item.itemType = itemType
        item.bindingAction = bindingAction
        self.items.append(item)
    }
}

