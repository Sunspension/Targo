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
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func setupDataSource() {
        
        self.dataSource.sections.append(self.section)
        
        self.section.initializeItem(cellStyle: .default, item: <#T##Any?#>, bindingAction: <#T##(UITableViewCell, CollectionSectionItem) -> Void#>)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
