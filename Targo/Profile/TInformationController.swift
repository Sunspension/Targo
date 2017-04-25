//
//  TInformationController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/04/2017.
//  Copyright © 2017 Targo. All rights reserved.
//

import UIKit

class TInformationController: UITableViewController {

    fileprivate var dataSource = TableViewDataSource()
    
    fileprivate let section = CollectionSection()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.setupDataSource()
        self.tableView.tableFooterView = UIView()
        self.setCustomBackButton()
    }
    
    fileprivate func setupDataSource() {
        
        self.dataSource.sections.append(self.section)
        
        self.section.initializeItem(cellStyle: .default,
                                    item: "page_information_terms_&_condictions_text".localized) { (cell, item) in
                                        
                                        cell.textLabel?.text = item.item as? String
                                        cell.accessoryType = .disclosureIndicator
        }
        
        self.section.initializeItem(cellStyle: .default,
                                    item: "page_information_privacy_policy_text".localized) { (cell, item) in
                                        
                                        cell.textLabel?.text = item.item as? String
                                        cell.accessoryType = .disclosureIndicator
        }
        
        self.tableView.dataSource = self.dataSource
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            
            if let path = Bundle.main.path(forResource: "agreement", ofType: "docx") {
                
                let title = "page_information_terms_&_condictions_text".localized
                self.t_router_openDocumentController(url: URL(fileURLWithPath: path), title: title)
            }
            
            break
            
        case 1:
            
            if let path = Bundle.main.path(forResource: "privacy-policy", ofType: "docx") {
                
                let title = "page_information_privacy_policy_text".localized
                self.t_router_openDocumentController(url: URL(fileURLWithPath: path), title: title)
            }
            
            break
            
        default:
            break
        }
    }
}
