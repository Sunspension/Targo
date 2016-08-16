//
//  UserProfileTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor

class UserProfileTableViewController: UITableViewController {

    var itemsSource: GenericTableViewDataSource<UITableViewCell, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.itemsSource = GenericTableViewDataSource<UITableViewCell, String>(reusableIdentifierOrNibName: nil, bindingAction: { (cell, item ) in
        
            cell.textLabel?.text = item.item
        })
        
        let section = GenericCollectionSection<String>(title: nil)
        
        let menuItems = ["Lgout", "Add new card", "Get info about my cards"]
        
        for item in menuItems {
            
            section.items.append(GenericCollectionSectionItem(item: item))
        }
        
        self.itemsSource?.sections.append(section)
        
        self.tableView.dataSource = self.itemsSource
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
            
        case 0:
         
            Api.sharedInstance.userLogut()
                
                .onSuccess(callback: { success in
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoUserLoggedOutSuccessfully, object: nil))
                
            }).onFailure(callback: { error in
                
                print("User logout error: \(error)")
            })
            
            break
            
        case 1:
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("AddCreditCard") {
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
            
        default:
            break
        }
    }
    
    // MARK: - Table view data source

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
