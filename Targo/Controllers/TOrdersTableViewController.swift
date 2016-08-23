//
//  TOrdersTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import RealmSwift
import SwiftOverlays

enum ShopOrdersSectionEnum {
    
    case History
    
    case InProgress
}


class TOrdersTableViewController: UITableViewController {

    var dataSource: GenericTableViewDataSource<THistoryOrderItemTableViewCell, TShopOrder>?
    
    var companies: [TCompany]?
    
    var orders: [TShopOrder]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "HistoryOrderItemCell",
                                                     bindingAction: { (cell, item) in
                                                        
                                                        if let companies = self.companies {
                                                            
                                                            if let company = companies.filter({ $0.id == item.item?.companyId })
                                                                .first {
                                                                
                                                                cell.companyName.text = company.title
                                                                
                                                                let items = item.item!.items
                                                                
                                                                var orderDesription = ""
                                                                
                                                                for index in 0 ... items.count - 1 {
                                                                    
                                                                    let orderItem = items[index]
                                                                    orderDesription += orderItem.title
                                                                    
                                                                    if (index != items.count - 1) {
                                                                        
                                                                        orderDesription += ", "
                                                                    }
                                                                }
                                                                
                                                                cell.orderDescription.text = orderDesription
                                                                
                                                                let formatter = NSDateFormatter()
                                                                formatter.dateFormat = kDateTimeFormat
                                                                
                                                                if let date = formatter.dateFromString(item.item!.created) {
                                                                    
                                                                    let formatter = NSDateFormatter()
                                                                    formatter.dateStyle = .MediumStyle
                                                                    formatter.timeStyle = .NoStyle
                                                                    
                                                                    cell.orderDate.text = formatter.stringFromDate(date)
                                                                }
                                                            }
                                                        }
        })
        
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.setup()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setup()
        
        let realm = try! Realm()
        let orders = realm.objects(TShopOrder)
        self.orders = Array<TShopOrder>(orders)
        
        if let orders = self.orders {
            
            let companyId = orders.map({ $0.companyId })
            let set = Set<Int>(companyId)
            let ids = Array(set)
            
            self.showWaitOverlay()
            
            Api.sharedInstance.loadCompaniesByIds(ids).onSuccess(callback: {[weak self] companies in
                
                self?.removeAllOverlays()
                
                self?.companies = companies
                self?.createDataSource()
                self?.tableView.reloadData()
                
                }).onFailure(callback: { error in
                    
                    self.removeAllOverlays()
                })
        }
    }

    private func createDataSource() {
        
        self.dataSource?.sections.removeAll()
        
        for order in self.orders! {
            
            let orderStatus = ShopOrderStatusEnum(rawValue: order.orderStatus)
            
            if orderStatus == .Canceled || orderStatus == .Finished {
                
                var sectionHistory =
                    self.dataSource!.sections.filter({ $0.sectionType as? ShopOrdersSectionEnum == .History }).first
                
                if sectionHistory == nil {
                    
                    sectionHistory = GenericCollectionSection<TShopOrder>(title: "order_history_order_title".localized)
                    self.dataSource?.sections.append(sectionHistory!)
                }
                
                sectionHistory!.items.append(GenericCollectionSectionItem(item: order))
            }
            else {
                
                var inProgress =
                    self.dataSource!.sections.filter({ $0.sectionType as? ShopOrdersSectionEnum == .InProgress }).first
                
                if inProgress == nil {
                    
                    inProgress = GenericCollectionSection<TShopOrder>(title: "order_in_progress_order_title".localized)
                    self.dataSource?.sections.append(inProgress!)
                }
                
                inProgress!.items.append(GenericCollectionSectionItem(item: order))
            }
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
