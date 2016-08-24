//
//  TOrderBillTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TOrderBillTableViewController: UITableViewController {

    var dataSource = TableViewDataSource()
    
    var shopOrder: TShopOrder?
    
    var companyName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setup()
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self.dataSource
        
        let section = CollectionSection(title: "bill_details_your_bill".localized)
        
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
        
        if let order = self.shopOrder {
            
            for item in order.items {
                
                section.initializeCellWithReusableIdentifierOrNibName("BillMenuItemCell",
                                                                      item: item) { (cell, item) in
                                                                        
                                                                        let viewCell = cell as! TBillMenuItemTableViewCell
                                                                        let good = item.item as? TShopGood
                                                                        
                                                                        viewCell.itemName.text = good!.title
                                                                        viewCell.itemPrice.text = String(good!.price) + " \u{20BD}"
                }
            }
        }
        
        
        self.dataSource.sections.append(section)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UILabel()
        
        header.textColor = UIColor(hexString: kHexMainPinkColor)
        header.font = UIFont.systemFontOfSize(20)
        header.text = self.dataSource.sections[section].title
        header.sizeToFit()
        return header
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
