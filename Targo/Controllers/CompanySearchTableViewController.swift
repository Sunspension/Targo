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
    
    private let section = GenericCollectionSection<TCompanyAddress>()
    
    private var companyImages = Set<TCompanyImage>()
    
    private var userLocation: CLLocation?
    
    private var dataSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompanyAddress>?
    
    private var companiesPage: TCompanyAddressesPage?
    
    private var pageNumer: Int = 1
    
    private var pageSize: Int = 20
    
    private var loading = false
    
    private var canLoadNext = true
    
    
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
                                                        
                                                        if indexPath.row + 10
                                                            >= self.dataSource!.sections[indexPath.section].items.count
                                                            && self.canLoadNext
                                                            && !self.loading {
                                                            
                                                            self.loadCompanyAddress()
                                                        }
                                                        
                                                        let company = item.item!
                                                        cell.companyTitle.text = company.companyTitle
                                                        cell.additionalInfo.text = company.companyCategoryTitle
                                                            + ", "
                                                            + String(Int(company.distance))
                                                            + " m"
                                                        
                                                        cell.ratingText.text = "4.7"
                                                        cell.ratingProgress.setProgress(1 / 5 * 4.7, animated: false)
                                                        cell.ratingProgress.trackFillColor = UIColor(hexString: kHexMainPinkColor)
                                                        cell.ratingProgress.hidden = false
                                                        
                                                        let imageSize = cell.companyImage.bounds.size
                                                        
                                                        if let image =
                                                            self.companyImages.filter({$0.id == company.companyImageId.value}).first {
                                                            
                                                            let filter = AspectScaledToFillSizeFilter(size: imageSize)
                                                            cell.companyImage.af_setImageWithURL(NSURL(string: image.url)!,
                                                                filter: filter, imageTransition: .CrossDissolve(0.5))
                                                        }
        })
        
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
            
            mapViewController.companies = self.dataSource?.sections[0].items.map({ $0.item! })
            mapViewController.images = Array(self.companyImages)
            
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    // Here is a magic to save height of current cell, otherwise you will get scrolling of table view content when cell will expand
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let height = self.dataSource?.sections[indexPath.section].items[indexPath.row].cellHeight {
            
            return height
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        self.dataSource?.sections[indexPath.section].items[indexPath.row].cellHeight = cell.frame.height
        
        let viewCell = cell as! TCompanyTableViewCell
        let layer = viewCell.shadowView.layer
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
    }
    
    func userLocationChanged() {
        
        if self.userLocation == nil {
            
            self.userLocation = TLocationManager.sharedInstance.lastLocation
            
            if self.userLocation != nil && !self.loading {
                
                if let superview = self.view.superview {
                    
                    SwiftOverlays.showCenteredWaitOverlay(superview)
                }
                
                self.loading = true
                
                // Try to load only first several companies related to user location and limit
                Api.sharedInstance.loadCompanyAddresses(self.userLocation!,
                    pageNumber: 1, pageSize: self.pageSize)
                    
                    .onSuccess(callback: { [unowned self] companyPage in
                        
                        self.loading = false
                        
                        if self.pageSize == companyPage.companies.count {
                            
                            self.canLoadNext = true
                            self.pageNumer += 1
                        }
                        
                        if let superview = self.view.superview {
                            
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                        
                        self.companiesPage = companyPage
                        
                        self.section.items.removeAll()
                        self.createDataSource()
                        self.tableView.reloadData()
                        
                        }).onFailure(callback: { [unowned self] error in
                            
                            self.loading = false
                            
                            if let superview = self.view.superview {
                                
                                SwiftOverlays.removeAllOverlaysFromView(superview)
                            }
                            
                            print(error)
                        })
            }
        }
    }
    
    func loadCompanyAddress() {
        
        self.loading = true
        
        Api.sharedInstance.loadCompanyAddresses(self.userLocation!,
            pageNumber: self.pageNumer, pageSize: self.pageSize)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                self.loading = false
                
                self.companiesPage = companyPage
                self.createDataSource()
                self.tableView.reloadData()
                
                if self.pageSize == companyPage.companies.count {
                    
                    self.pageNumer += 1
                }
                else {
                    
                    // reset counter
                    self.pageNumer = 1
                    self.canLoadNext = false
                }
                
                }).onFailure(callback: { error in
                
                    self.loading = false
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
