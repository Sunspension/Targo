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
    
    var item: Any?
    
    var itemType: Int?
    
    var reusableIdentifierOrNibName: String?
    
    var selected: Bool = false
    
    var hasError: Bool = false
    
    var indexPath: NSIndexPath!
    
    var bindingAction: ((cell: UITableViewCell, item: CollectionSectionItem?) -> Void)!
    
    init(reusableIdentifierOrNibName: String? = nil, item: Any?) {
        
        self.reusableIdentifierOrNibName = reusableIdentifierOrNibName
        self.item = item
        
        super.init()
    }
    
    init(cellStyle: UITableViewCellStyle, item: Any?) {
        
        self.item = item
        self.cellStyle = cellStyle
        self.defaultcell = true;
        self.reusableIdentifierOrNibName = ""
        
        super.init()
    }
}
