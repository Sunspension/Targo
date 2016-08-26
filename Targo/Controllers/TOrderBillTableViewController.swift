//
//  TOrderBillTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor

class TOrderBillTableViewController: UITableViewController {

    var dataSource = TableViewDataSource()
    
    var shopOrder: TShopOrder?
    
    var companyName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setup()
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self.dataSource
        self.tableView.allowsSelection = false
        
        self.tableView.registerNib(UINib(nibName: "TCompanyMenuHeaderView", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        self.title = "bill_details_your_bill".localized
        
        let section = CollectionSection()
        
        section.initializeCellWithReusableIdentifierOrNibName("BillCompanyNameCell",
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
                section.initializeCellWithReusableIdentifierOrNibName("BillMenuItemCell",
                                                                      item: item) { (cell, item) in
                                                                        
                                                                        let viewCell = cell as! TBillMenuItemTableViewCell
                                                                        let good = item.item as? TShopGood
                                                                        
                                                                        viewCell.itemName.text = good!.title
                                                                        viewCell.itemPrice.text = String(good!.count)
                                                                            + " x " + String(good!.price) + " \u{20BD}"
                }
            }
        }
        
        section.initializeCellWithReusableIdentifierOrNibName("BillCompanyNameCell",
                                                              item: nil, itemType: 1) { (cell, item) in
                                                                
                                                                let viewCell = cell as! TBillCompanyNameTableViewCell
                                                                
                                                                viewCell.companyName.text = "order_review_total_price".localized
                                                                viewCell.companyName.textAlignment = .Right
                                                                viewCell.orderDate.text = String(totalPrice) + " \u{20BD}"
                                                                let color = DynamicColor(hexString: "F0F0F0")
                                                                viewCell.contentView.backgroundColor = color
        }
        
        self.dataSource.sections.append(section)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        guard self.dataSource.sections[indexPath.section].items[indexPath.row].itemType != nil else {
//            
//            return
//        }
//        
//        
//    }

//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as! TCompanyMenuHeaderView
//        header.title.text = self.dataSource.sections[section].title
//        header.title.textColor = UIColor(hexString: kHexMainPinkColor)
//        
//        return header;
//    }
//    
//    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        
//        let header = view as! TCompanyMenuHeaderView
//        
//        header.background.backgroundColor = UIColor.lightGrayColor()
//        header.layer.shadowPath = UIBezierPath(rect: header.layer.bounds).CGPath
//        header.layer.shadowOffset = CGSize(width: 0, height: 2)
//        header.layer.shadowOpacity = 0.5
//    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let header = UILabel()
//        
//        header.textColor = UIColor(hexString: kHexMainPinkColor)
//        header.font = UIFont.systemFontOfSize(20)
//        header.text = self.dataSource.sections[section].title
//        header.sizeToFit()
//        return header
//    }
    
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
