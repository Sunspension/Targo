//
//  TUserCreditCardsTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import SwiftOverlays

class TUserCreditCardsTableViewController: UITableViewController {

    var dataSource = TableViewDataSource()
    
    var cards: [TCreditCard]?
    
    var selectedAction: ((_ cardIndex: Int) -> Void)?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.tableView.tableFooterView = UIView()
        self.setup()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        self.tableView.dataSource = dataSource
        
        if cards != nil {
            
            createDataSource()
        }
        else {
            
            loadCards()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.dataSource.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        guard item.itemType != nil else {
            
            self.selectedAction?((indexPath as NSIndexPath).row)
            let _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("AddCreditCard") {
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    fileprivate func createDataSource() {
        
        self.dataSource.sections.removeAll()
        
        let section = CollectionSection()
        
        for card in self.cards! {
            
            section.initializeItem(reusableIdentifierOrNibName: "UserCardCell",
                                   item: card,
                                   bindingAction: { (cell, item) in
                                    
                                    let viewCell = cell as! TUserCreditCardTableViewCell
                                    let card = item.item as! TCreditCard
                                    viewCell.title.text = card.mask
                                    viewCell.selectionStyle = .none
                                    
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
        
        section.initializeItem(reusableIdentifierOrNibName: "UserCardCell",
                               item: nil,
                               itemType: 1,
                               bindingAction: { (cell, item) in
                                
                                let viewCell = cell as! TUserCreditCardTableViewCell
                                viewCell.title.text = "credit_card_add_new_one".localized
                                viewCell.icon.image = UIImage(named: "icon-new-card")
                                viewCell.accessoryType = .disclosureIndicator
                                
        })
        
        self.dataSource.sections.append(section)
    }
    
    fileprivate func loadCards() {
        
        Api.sharedInstance.loadCreditCards()
            .onSuccess { [weak self] cards in
                
                if let superView = self?.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                self?.cards = cards
                self?.createDataSource()
                self?.tableView.reloadData()
                
            }.onFailure { [weak self] error in
                
                if let superView = self?.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                print(error)
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
