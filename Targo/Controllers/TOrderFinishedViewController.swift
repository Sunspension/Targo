//
//  TOrderFinishedViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 21/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import SwiftOverlays

class TOrderFinishedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonFinish: UIButton!
    
    var dataSource = TableViewDataSource()
    
    var shopOrder: TShopOrder?
    
    var companyName: String?
    
    var ratingMark: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self.dataSource
        self.tableView.allowsSelection = false
        
        self.tableView.register(UINib(nibName: "TOrderRatingTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "OrderRatingCell")
        
        self.title = "order_rating_title".localized
        
        self.navigationItem.hidesBackButton = true
        
        self.buttonFinish.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        self.buttonFinish.addTarget(self, action: #selector(TOrderFinishedViewController.closeAction), for: .touchUpInside)
        
        let section = CollectionSection()
        
        section.initializeItem(reusableIdentifierOrNibName: "OrderCompanyNameCell",
                               item: self.shopOrder) { (cell, item) in
                                
                                let viewCell = cell as! TBillCompanyNameTableViewCell
                                let order = item.item as? TShopOrder
                                viewCell.companyName.text = self.companyName
                                
                                let formatter = DateFormatter()
                                formatter.dateFormat = kDateTimeFormat
                                
                                if let date = formatter.date(from: order!.created) {
                                    
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    formatter.timeStyle = .none
                                    
                                    viewCell.orderDate.text = formatter.string(from: date)
                                }
        }
        
        var totalPrice = 0
        
        if let order = self.shopOrder {
            
            for item in order.items {
                
                totalPrice += item.count * item.price
                section.initializeItem(reusableIdentifierOrNibName: "OrderMenuItemCell",
                                       item: item) { (cell, item) in
                                        
                                        let viewCell = cell as! TBillMenuItemTableViewCell
                                        let good = item.item as? TShopGood
                                        
                                        viewCell.itemName.text = good!.title
                                        viewCell.itemPrice.text = String(good!.count)
                                            + " x " + String(good!.price) + " \u{20BD}"
                }
            }
        }
        
        section.initializeItem(reusableIdentifierOrNibName: "OrderCompanyNameCell",
                               item: nil, itemType: 1) { (cell, item) in
                                
                                let viewCell = cell as! TBillCompanyNameTableViewCell
                                
                                viewCell.companyName.text = "order_review_total_price".localized
                                viewCell.companyName.textAlignment = .right
                                viewCell.orderDate.text = String(totalPrice) + " \u{20BD}"
                                let color = DynamicColor(hexString: "F0F0F0")
                                viewCell.contentView.backgroundColor = color
        }
        
        section.initializeItem(reusableIdentifierOrNibName: "OrderRatingCell", item: nil) { (cell, item) in
            
            let viewCell = cell as! TOrderRatingTableViewCell
            viewCell.unratedColor = UIColor.lightGray
            viewCell.ratedColor = UIColor(hexString: "#FAAE00")
            viewCell.title.text = "order_rating_title".localized
            
            var rating = item.userData as? Int
            
            if rating == nil {
                
                item.userData = 0
                rating = 0
            }
            
            viewCell.rating = rating!
            viewCell.ratingDidSetAction = { ratingMark in
                
                self.ratingMark = ratingMark
                item.userData = ratingMark
            }
        }
        
        self.dataSource.sections.append(section)
    }

    func closeAction() {
        
        if self.ratingMark != nil {
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }
            
            Api.sharedInstance.setCompanyRating(orderId: self.shopOrder!.id, mark: self.ratingMark!)
                .onSuccess(callback: { order in
                
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    let _ = self.navigationController?.popToRootViewController(animated: true)
                })
                .onFailure(callback: { (error) in
                    
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    self.showOkAlert("error".localized, message: "order_rating_set_error".localized)
                    print(error)
                })
        }
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
