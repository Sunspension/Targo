//
//  TOrderFinishedViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 21/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor

class TOrderFinishedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonFinish: UIButton!
    
    var dataSource = TableViewDataSource()
    
    var shopOrder: TShopOrder?
    
    var companyName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self.dataSource
        self.tableView.allowsSelection = false
        
        self.title = "Оцените заказ"
        
        self.navigationItem.hidesBackButton = true
        
        self.buttonFinish.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        self.buttonFinish.addTarget(self, action: #selector(TOrderFinishedViewController.closeAction), forControlEvents: .TouchUpInside)
        
        let section = CollectionSection()
        
        section.initializeCellWithReusableIdentifierOrNibName("OrderCompanyNameCell",
                                                              item: self.shopOrder) { (cell, item) in
                                                                
                                                                let viewCell = cell as! TBillCompanyNameTableViewCell
                                                                let order = item.item as? TShopOrder
                                                                viewCell.companyName.text = self.companyName
                                                                
                                                                let formatter = NSDateFormatter()
                                                                formatter.dateFormat = kDateTimeFormat
                                                                
                                                                if let date = formatter.dateFromString(order!.created) {
                                                                    
                                                                    let formatter = NSDateFormatter()
                                                                    formatter.dateStyle = .MediumStyle
                                                                    formatter.timeStyle = .NoStyle
                                                                    
                                                                    viewCell.orderDate.text = formatter.stringFromDate(date)
                                                                }
        }
        
        var totalPrice = 0
        
        if let order = self.shopOrder {
            
            for item in order.items {
                
                totalPrice += item.count * item.price
                section.initializeCellWithReusableIdentifierOrNibName("OrderMenuItemCell",
                                                                      item: item) { (cell, item) in
                                                                        
                                                                        let viewCell = cell as! TBillMenuItemTableViewCell
                                                                        let good = item.item as? TShopGood
                                                                        
                                                                        viewCell.itemName.text = good!.title
                                                                        viewCell.itemPrice.text = String(good!.count)
                                                                            + " x " + String(good!.price) + " \u{20BD}"
                }
            }
        }
        
        section.initializeCellWithReusableIdentifierOrNibName("OrderCompanyNameCell",
                                                              item: nil, itemType: 1) { (cell, item) in
                                                                
                                                                let viewCell = cell as! TBillCompanyNameTableViewCell
                                                                
                                                                viewCell.companyName.text = "order_review_total_price".localized
                                                                viewCell.companyName.textAlignment = .Right
                                                                viewCell.orderDate.text = String(totalPrice) + " \u{20BD}"
                                                                let color = DynamicColor(hexString: "F0F0F0")
                                                                viewCell.contentView.backgroundColor = color
        }
        
        section.initializeCellWithReusableIdentifierOrNibName("OrderShareCell", item: nil) { (cell, item) in
            
            let viewCell = cell as! TOrderShareTableViewCell
            viewCell.shareImage.image = UIImage(named: "stars")
            viewCell.title.text = "Оцените заказ"
        }
        
        section.initializeCellWithReusableIdentifierOrNibName("OrderShareCell", item: nil) { (cell, item) in
            
            let viewCell = cell as! TOrderShareTableViewCell
            viewCell.shareImage.image = UIImage(named: "social")
            viewCell.title.text = "Рассказать друзьям"
        }
        
        self.dataSource.sections.append(section)
        
        // Do any additional setup after loading the view.
    }

    func closeAction() {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
