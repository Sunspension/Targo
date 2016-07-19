//
//  TableViewDataSource.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 19/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource {
    
    var sections: [CollectionSection] = []

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].items.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.sections.count ?? 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = self.sections[indexPath.section].items[indexPath.row]
        
        if let identifier = item.reusableIdentifierOrNibName {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier(identifier) {
                
                item.bindingAction(cell: cell, item: item)
                return cell
            }
            
            if let cell = NSBundle.mainBundle().loadNibNamed(item.reusableIdentifierOrNibName, owner: self, options: nil).last as? UITableViewCell {
                
                item.bindingAction(cell: cell, item: item)
                return cell
            }
        }
        
        let cell =  UITableViewCell()
        item.bindingAction(cell: cell, item: item)
        
        return cell;
    }
}
