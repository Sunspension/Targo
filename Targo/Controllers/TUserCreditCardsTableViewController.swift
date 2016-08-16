//
//  TUserCreditCardsTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TUserCreditCardsTableViewController: UITableViewController {

    var dataSource = TableViewDataSource()
    
    var cards: [TCreditCard]?
    
    var selectedAction: ((cardIndex: Int) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.tableView.tableFooterView = UIView()
        self.setup()
        
        self.title = "credit_card_payment_method".localized
        
        self.tableView.dataSource = dataSource
        
        if let cards = cards {
            
            let section = CollectionSection()
            
            for card in cards {
                
                section.initializeCellWithReusableIdentifierOrNibName("UserCardCell",
                                                                      item: card,
                                                                      bindingAction: { (cell, item) in
                                                                        
                                                                        let viewCell = cell as! TUserCreditCardTableViewCell
                                                                        let card = item.item as! TCreditCard
                                                                        viewCell.title.text = card.mask
                                                                        viewCell.selectionStyle = .None
                                                                        
                                                                        switch card.type {
                                                                            
                                                                        case "Visa":
                                                                            
                                                                            viewCell.icon.image = UIImage(named: "visa")
                                                                            
                                                                            break
                                                                            
                                                                        case "MasterCard":
                                                                            
                                                                            viewCell.icon.image = UIImage(named: "mastercard")
                                                                            
                                                                            break
                                                                            
                                                                        default:
                                                                            
                                                                            break
                                                                        }
                })
            }
            
            section.initializeCellWithReusableIdentifierOrNibName("UserCardCell",
                                                                  item: nil, itemType: 1,
                                                                  bindingAction: { (cell, item) in
                                                                    
                                                                    let viewCell = cell as! TUserCreditCardTableViewCell
                                                                    viewCell.icon.layer.borderWidth = 1
                                                                    viewCell.icon.layer.borderColor = UIColor.grayColor().CGColor
                                                                    viewCell.title.text = "credit_card_add_new_one".localized
                                                                    
            })
            
            self.dataSource.sections.append(section)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = self.dataSource.sections[indexPath.section].items[indexPath.row]
        
        guard item.itemType != nil else {
            
            self.selectedAction?(cardIndex: indexPath.row)
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("AddCreditCard") {
            
            self.navigationController?.pushViewController(controller, animated: true)
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
