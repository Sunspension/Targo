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
    
    let section = GenericCollectionSection<TCompanyAddress>()
    
    var companyImages = Set<TCompanyImage>()
    
    var userLocation: CLLocation?
    
    var dataSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompanyAddress>?
    
    var companiesPage: TCompanyAddressesPage?
    
    var pageNumer: Int = 1
    
    var pageSize: Int = 20
    
    var loading = false
    
    var canLoadNext = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setup()
        self.setup()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-map"),
                                                                 style: .Plain,
                                                                 target: self,
                                                                 action: #selector(CompanySearchTableViewController.openMap))
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .Plain,
                                                                target: nil,
                                                                action: nil)
        
        self.dataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "CompanyTableCell",
                                                      bindingAction: { (cell, item) in
                                                        
                                                        let indexPath = item.indexPath
                                                        
                                                        if indexPath.row
                                                            == self.dataSource!.sections[indexPath.section].items.count - 2
                                                            && self.canLoadNext {
                                                            
                                                            self.loadCompanyAddress()
                                                        }
                                                        
                                                        let company = item.item!
                                                        
                                                        cell.companyTitle.text = company.companyTitle
                                                        cell.additionalInfo.text = company.companyCategoryTitle
                                                            + ", "
                                                            + String(Int(company.distance))
                                                            + " m"
                                                        
                                                        let imageSize = cell.companyImage.bounds.size
                                                        
                                                        if let image = self.companyImages.filter({$0.id == company.companyImageId.value}).first {
                                                            
                                                            let filter = AspectScaledToFillSizeFilter(size: imageSize)
                                                            cell.companyImage.af_setImageWithURL(NSURL(string: image.url)!, placeholderImage: UIImage(named: "blank"), filter: filter, imageTransition: .CrossDissolve(0.6))
                                                        }
        })
        
//        let background = UIImageView(image: UIImage(named: "background"))
//        background.frame = self.tableView.frame
//        self.tableView.backgroundView = background
        
        self.dataSource?.sections.append(self.section)
        self.tableView.dataSource = self.dataSource
        
        TLocationManager.sharedInstance.subscribeObjectForLocationChange(self,
                                                                         selector: #selector(CompanySearchTableViewController.userLocationChanged))
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item = self.dataSource!.sections[indexPath.section].items[indexPath.row]
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("MenuController") as? TCompanyMenuTableViewController {
            
            controller.company = item.item
            controller.companyImage = self.companyImages.filter({$0.id == item.item!.companyImageId.value}).first
            controller.showButtonInfo = true
                
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
        
        let viewCell = cell as! TCompanyTableViewCell
        let layer = viewCell.shadowView.layer
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
    }
    
    func userLocationChanged() {
        
        if self.userLocation == nil {
            
            self.userLocation = TLocationManager.sharedInstance.lastLocation
            
            if self.userLocation != nil {
                
                self.showWaitOverlay()
                
                // Try to load only first several companies related to user location and limit
                Api.sharedInstance.loadCompanyAddresses(self.userLocation!,
                    pageNumber: 1, pageSize: self.pageSize)
                    
                    .onSuccess(callback: { [weak self] companyPage in
                        
                        if self?.pageSize == companyPage.companies.count {
                            
                            self?.canLoadNext = true
                            self?.pageNumer += 1
                        }
                        
                        self?.removeAllOverlays()
                        self?.companiesPage = companyPage
                        
                        self?.createDataSource()
                        self?.tableView.reloadData()
                        
                        }).onFailure(callback: { [weak self] error in
                            
                            self?.removeAllOverlays()
                            print(error)
                        })
            }
        }
    }
    
    func loadCompanyAddress() {
        
        self.loading = true
        self.showWaitOverlay()
        
        Api.sharedInstance.loadCompanyAddresses(self.userLocation!,
            pageNumber: self.pageNumer, pageSize: self.pageSize)
            
            .onSuccess(callback: { [weak self] companyPage in
                
                self?.removeAllOverlays()
                self?.companiesPage = companyPage
                
                self?.createDataSource()
                self?.tableView.reloadData()
                
                if self?.pageSize == companyPage.companies.count {
                    
                    self?.pageNumer += 1
                }
                else {
                    
                    // reset counter
                    self?.pageNumer = 1
                    self?.canLoadNext = false
                }
                
                }).onFailure(callback: { [weak self] error in
                    
                    self?.removeAllOverlays()
                    print(error)
                })
    }
    
    func createDataSource() {
        
        if let page = self.companiesPage {
            
            for company in page.companies {
                
                self.section.items.append(GenericCollectionSectionItem(item: company))
            }
            
            for image in page.images {
                
                self.companyImages.insert(image)
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
