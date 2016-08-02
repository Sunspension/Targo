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
import AlamofireImage
import SwiftOverlays

class CompanySearchTableViewController: UITableViewController {
    
    var userLocation: CLLocation?
    
    var itemsSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompany>?
    
    var companyImages: [TCompanyImage] = []
    
    var companiesPage: TCompaniesPage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setup()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-map"), style: .Plain, target: self, action: #selector(CompanySearchTableViewController.openMap))
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.itemsSource =
            GenericTableViewDataSource<TCompanyTableViewCell, TCompany>(reusableIdentifierOrNibName: "CompanyTableCell",
                                                                                       bindingAction: { (cell, item) in
                                                                                        
                                                                                        cell.companyTitle.text = item.companyTitle
                                                                                        cell.additionalInfo.text = item.companyCategoryTitle + ", " + item.distance + " m"
                                                                                        
                                                                                        let imageSize = cell.companyImage.bounds.size
                                                                                        
                                                                                        if let image = self.companyImages.filter({$0.id == item.companyImageId.value}).first {
                                                                                        
                                                                                            let filter = AspectScaledToFillSizeFilter(size: imageSize)
                                                                                            cell.companyImage.af_setImageWithURL(NSURL(string: image.url)!, filter: filter, imageTransition: .CrossDissolve(0.6))
                                                                                        }
        })
        
        let background = UIImageView(image: UIImage(named: "background"))
        background.frame = self.tableView.frame
        self.tableView.backgroundView = background
        self.tableView.dataSource = self.itemsSource
        
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
        
        self.setup()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = self.itemsSource!.sections[indexPath.section].items[indexPath.row]
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("MenuController") as? TCompanyMenuTableViewController {
            
            let viewCell = tableView.cellForRowAtIndexPath(indexPath) as! TCompanyTableViewCell
            
            controller.company = item
            controller.companyImage = viewCell.companyImage.image
                
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openMap() {
        
        if let mapViewController = self.instantiateViewControllerWithIdentifierOrNibName("CompaniesOnMaps") as? TCompaniesOnMapsViewController {
            
            mapViewController.companiesPage = self.companiesPage
            mapViewController.companyImages = self.companyImages
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // This code is here because of strange bug with the size of a shadow
//        if cell.layer.shadowPath != nil {
//            
//            return
//        }
        
        let viewCell = cell as! TCompanyTableViewCell
        let layer = viewCell.shadowView.layer
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.5
        layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
    }
    
    func userLocationChanged() {
        
        if self.userLocation == nil {
            
            self.userLocation = TLocationManager.sharedInstance.lastLocation
            
            if self.userLocation != nil {
                
                self.showWaitOverlay()
                
                Api.sharedInstance.loadCompanies(self.userLocation!).onSuccess(callback: { companyPage in
                    
                    self.removeAllOverlays()
                    self.companiesPage = companyPage
                    self.createDataSource()
                    
                }).onFailure(callback: { error in
                    
                    self.removeAllOverlays()
                    print(error)
                })
            }
        }
    }
    
    func createDataSource() {
        
        let section = GenericCollectionSection<TCompany>()
        
        if let page = self.companiesPage {
            
            for company in page.companies {
                
                section.items.append(company)
            }
            
            self.companyImages.removeAll()
            self.companyImages.appendContentsOf(page.images)
            self.itemsSource?.sections.append(section)
            self.tableView.reloadData()
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
