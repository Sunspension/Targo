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
    
    var sectionType: AnyObject?
    
    
    init(title: String? = "") {
        
        self.title = title;
    }
    
    func initializeDefaultCell(reusableIdentifier: String? = nil, cellStyle: UITableViewCellStyle, item: Any?, bindingAction: (cell:UITableViewCell, item: CollectionSectionItem?) -> Void) {
        
        self.initializeDefaultCell(reusableIdentifier, cellStyle: cellStyle, item: item, itemType: nil, bindingAction: bindingAction)
    }
    
    func initializeDefaultCell(reusableIdentifier: String? = nil, cellStyle: UITableViewCellStyle, item: Any?, itemType: AnyObject?, bindingAction: (cell:UITableViewCell, item: CollectionSectionItem?) -> Void) {
    
        let item = CollectionSectionItem(reusableIdentifier: reusableIdentifier, cellStyle: cellStyle, item: item)
        item.bindingAction = bindingAction
        item.itemType = itemType
        self.items.append(item)
    }
    
    func initializeCellWithReusableIdentifierOrNibName(identifierOrNibName: String, item: Any?, bindingAction: (cell:UITableViewCell, item: CollectionSectionItem?) -> Void) {
        
        self.initializeCellWithReusableIdentifierOrNibName(identifierOrNibName, item: item, itemType: nil, bindingAction: bindingAction)
    }
    
    func initializeCellWithReusableIdentifierOrNibName(identifierOrNibName: String, item: Any?, itemType: AnyObject?, bindingAction: (cell:UITableViewCell, item: CollectionSectionItem?) -> Void) {
        
        let item = CollectionSectionItem(reusableIdentifierOrNibName: identifierOrNibName, item: item)
        item.itemType = itemType
        item.bindingAction = bindingAction
        self.items.append(item)
    }
}

