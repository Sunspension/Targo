//
//  GenericTableViewDataSource.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericTableViewDataSource<TTableViewCell: UITableViewCell, TTableItem: Any>: NSObject, UITableViewDataSource {

    var sections: [GenericCollectionSection<TTableItem>] = []
    
    var bindingAction: (cell: TTableViewCell, item: TTableItem) -> Void
    
    var reusableIdentifierOrNibName: String?
    
    init(reusableIdentifierOrNibName: String?, bindingAction: (cell: TTableViewCell, item: TTableItem) -> Void) {
        
        self.bindingAction = bindingAction
        self.reusableIdentifierOrNibName = reusableIdentifierOrNibName
        
        super.init()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].items.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.sections.count ?? 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = self.sections[indexPath.section].items[indexPath.row]
        
        if let identifier = self.reusableIdentifierOrNibName {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? TTableViewCell {
                
                self.bindingAction(cell: cell, item: item)
                
                return cell
            }
            
            if let cell = NSBundle.mainBundle().loadNibNamed(self.reusableIdentifierOrNibName, owner: self, options: nil).last as? TTableViewCell {
                
                self.bindingAction(cell: cell, item: item)
                return cell
            }
        }
        
        let cell =  UITableViewCell() as! TTableViewCell
        self.bindingAction(cell: cell, item: item)
        
        return cell;
    }
}
