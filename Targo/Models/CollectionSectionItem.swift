//
//  CollectionSectionItem.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CollectionSectionItem: NSObject {

    private (set) var defaultcell: Bool = false
    
    private (set) var cellStyle: UITableViewCellStyle?
    
    private (set) var firstReusableIdentifierOrNibName: String?
    
    private (set) var secondReusableIdentifierOrNibName: String?
    
    
    var item: Any?
    
    var itemType: Any?
    
    var userData: Any?
    
    var validation: (() -> Bool)?
    
    var reusableIdentifierOrNibName: String? {
        
        get {
            
            return swappable ? (selected ? secondReusableIdentifierOrNibName : firstReusableIdentifierOrNibName) : firstReusableIdentifierOrNibName
        }
    }
    
    var selected = false
    
    var hasError = false
    
    var indexPath: NSIndexPath!
    
    var bindingAction: ((cell: UITableViewCell, item: CollectionSectionItem) -> Void)!
    
    var swappable = false
    
    var cellHeight: CGFloat?
    
    
    init(reusableIdentifierOrNibName: String? = nil, item: Any?) {
        
        self.firstReusableIdentifierOrNibName = reusableIdentifierOrNibName
        self.item = item
        
        super.init()
    }
    
    init(firstReusableIdentifierOrNibName: String? = nil, secondReusableIdentifierOrNibName: String? = nil, item: Any?) {
        
        self.firstReusableIdentifierOrNibName = firstReusableIdentifierOrNibName
        self.secondReusableIdentifierOrNibName = secondReusableIdentifierOrNibName
        self.item = item
        self.swappable = true
        
        super.init()
    }
    
    init(reusableIdentifier: String?, cellStyle: UITableViewCellStyle, item: Any?) {
        
        self.item = item
        self.cellStyle = cellStyle
        self.defaultcell = true;
        self.firstReusableIdentifierOrNibName = reusableIdentifier
        
        super.init()
    }
}
