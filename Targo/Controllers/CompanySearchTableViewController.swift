//
//  CompanySearchTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 11/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import CoreLocation
import RealmSwift

class CompanySearchTableViewController: UITableViewController {
    
    var userLocation: CLLocation?
    
    var itemsSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompany>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-map"), style: .Plain, target: self, action: #selector(CompanySearchTableViewController.openMap))
        
        self.itemsSource = GenericTableViewDataSource<TCompanyTableViewCell, TCompany>(reusableIdentifierOrNibName: "CompanyTableCell",
                                                                                       bindingAction: { (cell, item) in
                                                                                        
                                                                                        cell.companyTitle.text = item.companyTitle
                                                                                        cell.additionalInfo.text = item.companyCategoryTitle
                                                                                        
//                                                                                        let rect = cell.layer.bounds
//                                                                                        let shadowPath = UIBezierPath(rect: rect).CGPath
//                                                                                        cell.layer.shadowPath = shadowPath
//                                                                                        
//                                                                                        cell.layer.shadowOffset = CGSize(width: 1, height: 0)
//                                                                                        cell.layer.shadowOpacity = 0.5
//                                                                                        cell.layer.shadowRadius = 1
//                                                                                        cell.clipsToBounds = true
        })
        
        self.tableView.dataSource = self.itemsSource
        
        let background = UIImageView(image: UIImage(named: "background"))
        background.frame = self.tableView.frame
        self.tableView.backgroundView = background
        
        TLocationManager.sharedInstance.subscribeObjectForLocationChange(self, selector: #selector(CompanySearchTableViewController.userLocationChanged))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = DynamicColor(hexString: kHexMainPinkColor)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    func openMap() {
        
        
    }
    
    func userLocationChanged() {
        
        if self.userLocation == nil {
            
            self.userLocation = TLocationManager.sharedInstance.lastLocation
            
            if self.userLocation != nil {
                
                let testLocation = CLLocation(latitude: 59.97, longitude: 30.40)
                
                Api.sharedInstance.loadCompanies(testLocation).onSuccess(callback: { companies in
                    
                    self.createDataSource(companies)
                    
                }).onFailure(callback: { error in
                    
                    print(error)
                })
            }
        }
    }
    
    func createDataSource(companies:[TCompany]) {
        
        let section = GenericCollectionSection<TCompany>()
        
        for company in companies {
            
            section.items.append(company)
        }
        
        self.itemsSource?.sections.append(section)
        self.tableView.reloadData()
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
