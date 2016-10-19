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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].items.count 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        item.indexPath = indexPath
        
        if item.defaultcell == true {
            
            let cell = UITableViewCell(style: item.cellStyle!, reuseIdentifier: item.reusableIdentifierOrNibName)
            item.bindingAction?(cell, item)
            return cell;
        }
        
        if let identifier = item.reusableIdentifierOrNibName {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
                
                item.bindingAction?(cell, item)
                return cell
            }
            
            if let cell = Bundle.main.loadNibNamed(item.reusableIdentifierOrNibName!, owner: self, options: nil)!.last as? UITableViewCell {
                
                item.bindingAction?(cell, item)
                return cell
            }
        }
        
        let cell =  UITableViewCell()
        item.bindingAction?(cell, item)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sections[section].title
    }
}
