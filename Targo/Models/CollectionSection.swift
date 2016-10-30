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
    
    var selectedItems: [CollectionSectionItem] = []
    
    var sectionType: Any?
    
    var selected = false
    
    
    init(title: String? = "") {
        
        self.title = title;
    }
    
    func initializeDefaultCell(_ reusableIdentifier: String? = nil,
                               cellStyle: UITableViewCellStyle,
                               item: Any?,
                               itemType: Any? = nil,
                               bindingAction: @escaping (_ cell:UITableViewCell, _ item: CollectionSectionItem) -> Void) {
    
        let item = CollectionSectionItem(reusableIdentifier: reusableIdentifier, cellStyle: cellStyle, item: item)
        item.bindingAction = bindingAction
        item.itemType = itemType
        self.items.append(item)
    }
    
    func initializeCellWithReusableIdentifierOrNibName(identifier identifierOrNibName: String,
                                                       item: Any?,
                                                       itemType: Any? = nil,
                                                       bindingAction: @escaping (_ cell:UITableViewCell, _ item: CollectionSectionItem) -> Void) {
        
        let item = CollectionSectionItem(reusableIdentifierOrNibName: identifierOrNibName, item: item)
        item.itemType = itemType
        item.bindingAction = bindingAction
        self.items.append(item)
    }
    
    func initializeSwappableCellWithReusableIdentifierOrNibName(firstIdentifier firstIdentifierOrNibName: String,
                                                                secondIdentifier secondIdentifierOrNibName: String,
                                                                item: Any?,
                                                                itemType: Any? = nil,
                                                                bindingAction: @escaping (_ cell:UITableViewCell, _ item: CollectionSectionItem) -> Void) {
        
        let item = CollectionSectionItem(firstReusableIdentifierOrNibName: firstIdentifierOrNibName,
                                         secondReusableIdentifierOrNibName: secondIdentifierOrNibName, item: item)
        item.bindingAction = bindingAction
        item.itemType = itemType
        self.items.append(item)
    }
}

