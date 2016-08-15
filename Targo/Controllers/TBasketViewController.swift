//
//  TBasketViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 14/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TBasketViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var makeOrder: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "basket_title".localized

        self.tableView.setup()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
