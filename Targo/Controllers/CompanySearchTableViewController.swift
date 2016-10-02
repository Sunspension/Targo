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
import Alamofire


class CompanySearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private let section = GenericCollectionSection<TCompanyAddress>()
    
    private let searchSection = GenericCollectionSection<TCompanyAddress>()
    
    private var companyImages = Set<TCompanyImage>()
    
    private var userLocation: CLLocation?
    
    private var dataSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompanyAddress>?
    
    private var searchDataSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompanyAddress>?
    
    private var companiesPage: TCompanyAddressesPage?
    
    private var searchCompaniesPage: TCompanyAddressesPage?
    
    private var pageNumber: Int = 1
    
    private var searchPageNumer: Int = 1
    
    private var pageSize: Int = 20
    
    private var canLoadNext = true
    
    private var searchCanLoadNext = true
    
    private var loadingStatus = TLoadingStatusEnum.Idle
    
    private var searchLoadingStatus = TLoadingStatusEnum.Idle
    
    private let manager = NetworkReachabilityManager(host: "www.apple.com")
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var shouldShowSearchResults = false
    
    private var cancelPreviousResult = false
    
    private var cancellationTokens = [NSOperation]()
    
    private var scheduleRefreshTimer: NSTimer?
    
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setup()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0 / 255, green: 0 / 255, blue: 80 / 255, alpha: 0.1)
        self.tableView.backgroundView = backgroundView
        self.setup()
        
        setupSearchController()
        
        manager?.listener = { status in
            
            switch status {
                
            case .Reachable(NetworkReachabilityManager.ConnectionType.EthernetOrWiFi):
                
                if self.canLoadNext && self.loadingStatus == .Failed {
                    
                    self.loadCompanyAddress()
                }
                
                break
                
            default:
                break
            }
        }
        
        manager?.startListening()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-map"),
                                                                 style: .Plain,
                                                                 target: self,
                                                                 action: #selector(CompanySearchTableViewController.openMap))
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .Plain,
                                                                target: nil,
                                                                action: nil)
        
        self.dataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "CompanyTableCell", bindingAction: binding)
        self.dataSource?.sections.append(section)
        
        self.searchDataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "CompanyTableCell", bindingAction: binding)
        self.searchDataSource?.sections.append(searchSection)
        
        self.tableView.dataSource = self.dataSource
        
        TLocationManager.sharedInstance.subscribeObjectForLocationChange(self,
                                                                         selector: #selector(CompanySearchTableViewController.userLocationChanged))
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(CompanySearchTableViewController.onUIApplicationWillEnterForegroundNotification),
                                                         name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(CompanySearchTableViewController.manualRefresh), forControlEvents: .ValueChanged)

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // update for new items every 10 minutes
        self.scheduleRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(600,
                                                                           target: self,
                                                                           selector: #selector(CompanySearchTableViewController.manualRefresh),
                                                                           userInfo: nil,
                                                                           repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.scheduleRefreshTimer?.invalidate()
        
        if let superView = self.view.superview {
            
            SwiftOverlays.removeAllOverlaysFromView(superView)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var item: GenericCollectionSectionItem<TCompanyAddress>!
        
        if shouldShowSearchResults == true {
            
            let section = self.searchDataSource!.sections[indexPath.section]
            item = section.items[indexPath.row]
        }
        else {
            
            let section = self.dataSource!.sections[indexPath.section]
            item = section.items[indexPath.row]
        }
        
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
        
        if shouldShowSearchResults {
            
            if let height = self.searchDataSource?.sections[indexPath.section].items[indexPath.row].cellHeight {
                
                return height
            }
        }
        else {
            
            if let height = self.dataSource?.sections[indexPath.section].items[indexPath.row].cellHeight {
                
                return height
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let viewCell = cell as! TCompanyTableViewCell
        
        viewCell.layoutIfNeeded()
        
        if shouldShowSearchResults {
            
            if let item = self.searchDataSource?.sections[indexPath.section].items[indexPath.row] {
                
                item.cellHeight = viewCell.frame.height
                getCompanyImage(item, viewCell: viewCell)
            }
        }
        else {
            
            if let item = self.dataSource?.sections[indexPath.section].items[indexPath.row] {
                
                item.cellHeight = viewCell.frame.height
                getCompanyImage(item, viewCell: viewCell)
            }
        }
        
        let layer = viewCell.shadowView.layer
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
    }
    
    func userLocationChanged() {
        
        self.userLocation = TLocationManager.sharedInstance.lastLocation
        
        if self.userLocation != nil && self.loadingStatus != .Loading && self.canLoadNext {
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }
            
            self.loadingStatus = .Loading
            
            self.pageNumber = 1
            
            // Try to load only first several companies related to user location and limit
            Api.sharedInstance.loadCompanyAddresses(
                self.userLocation!,
                pageNumber: self.pageNumber,
                pageSize: self.pageSize)
                
                .onSuccess(callback: { [unowned self] companyPage in
                    
                    self.loadingStatus = .Loaded
                    
                    if self.pageSize == companyPage.companies.count {
                        
                        self.canLoadNext = true
                        self.pageNumber += 1
                    }
                    
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    self.companiesPage = companyPage
                    
                    self.section.items.removeAll()
                    self.createDataSource()
                    self.tableView.reloadData()
                    
                    }).onFailure(callback: { [unowned self] error in
                        
                        self.loadingStatus = .Failed
                        
                        if let superview = self.view.superview {
                            
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                        
                        print(error)
                    })
        }
    }
    
    func loadCompanyAddress(forceRefresh: Bool = false) {
        
        if self.userLocation == nil {
            
            self.loadingStatus = .Failed
            return
        }
        
        self.loadingStatus = .Loading
        
        Api.sharedInstance.loadCompanyAddresses(
            
            self.userLocation!,
            pageNumber: self.pageNumber,
            pageSize: self.pageSize)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                self.loadingStatus = .Loaded
                
                if forceRefresh {
                    
                    self.refreshControl?.endRefreshing()
                    self.section.items.removeAll()
                }
                
                self.companiesPage = companyPage
                self.createDataSource()
                self.tableView.reloadData()
                
                if self.pageSize == companyPage.companies.count {
                    
                    self.canLoadNext = true
                    self.pageNumber += 1
                }
                else {
                    
                    // reset counter
                    self.pageNumber = 1
                    self.canLoadNext = false
                }
                
                }).onFailure(callback: { error in
                
                    if forceRefresh {
                        
                        self.refreshControl?.endRefreshing()
                    }
                    
                    self.loadingStatus = .Failed
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
    
    func onUIApplicationWillEnterForegroundNotification() {
        
        if canLoadNext && loadingStatus == .Failed {
            
            self.loadCompanyAddress()
        }
    }
    
    //MARK: - UISearchBar delegate implementation

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        shouldShowSearchResults = true
        reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        shouldShowSearchResults = false
        reloadData()
    }
    
    //MARK: - UISearchResultUpdating delegate implementation
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.searchPageNumer = 1
        
        for token in self.cancellationTokens {
            
            token.cancel()
        }
        
        let token = NSOperation()
        self.cancellationTokens.append(token)
        
        if let string = searchController.searchBar.text {
            
            loadCompanyAddress(string, cancellationToken: token)
        }
    }

    func manualRefresh() {
        
        self.pageNumber = 1
        self.loadCompanyAddress(true)
    }
    
    //MARK: - Private methods
    
    private func getCompanyImage(item: GenericCollectionSectionItem<TCompanyAddress>, viewCell: TCompanyTableViewCell) {
        
        let company = item.item!
        
        if let image =
            self.companyImages.filter({$0.id == company.companyImageId.value}).first {
            
            let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
            viewCell.companyImage.af_setImageWithURL(NSURL(string: image.url)!,
                                                     filter: filter, imageTransition: .CrossDissolve(0.5))
        }
    }
    
    private func setupSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search_place_holder".localized
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = UIColor(hexString: kHexMainPinkColor)
        self.definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
    }

    
    private func binding(cell: TCompanyTableViewCell, item: GenericCollectionSectionItem<TCompanyAddress>) {
        
        let indexPath = item.indexPath
        
        if shouldShowSearchResults {
            
            if indexPath.row + 10
                >= self.searchDataSource!.sections[indexPath.section].items.count
                && self.searchCanLoadNext
                && self.searchLoadingStatus != .Loading {
                
                guard let string = searchController.searchBar.text else {
                    
                    return
                }
                
                self.loadCompanyAddress(string)
            }
        }
        else {
            
            if indexPath.row + 10
                >= self.dataSource!.sections[indexPath.section].items.count
                && self.canLoadNext
                && self.loadingStatus != .Loading {
                
                self.loadCompanyAddress()
            }
        }
        
        let company = item.item!
        cell.companyTitle.text = company.companyTitle
        cell.additionalInfo.text = company.companyCategoryTitle
            + ", "
            + String(Int(company.distance))
            + " m"
        
        cell.ratingText.text = String(format:"%.1f", company.rating)
        cell.ratingProgress.setProgress(1 / 5 * company.rating, animated: false)
        cell.ratingProgress.trackFillColor = UIColor(hexString: kHexMainPinkColor)
        cell.ratingProgress.hidden = false
    }
    
    private func loadCompanyAddress(query:String, cancellationToken: NSOperation? = nil) {
        
        if self.userLocation == nil {
            
            self.searchLoadingStatus = .Failed
            return
        }
        
        self.searchLoadingStatus = .Loading
        
        if let superView = self.tableView.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
        
        Api.sharedInstance.loadCompanyAddresses(
            
            self.userLocation!,
            pageNumber: self.searchPageNumer,
            pageSize: self.pageSize,
            query: query)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                if let superView = self.tableView.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                if let token = cancellationToken {
                    
                    self.cancellationTokens.remove(token)
                    
                    if token.cancelled {
                        
                        return
                    }
                }
                
                self.searchCompaniesPage = companyPage
                
                if self.searchPageNumer == 1 {
                    
                    self.searchSection.items.removeAll()
                }
                
                if self.pageSize == companyPage.companies.count {
                    
                    self.searchCanLoadNext = true
                    self.searchPageNumer += 1
                }
                else {
                    
                    // reset counter
                    self.searchPageNumer = 1
                    self.searchCanLoadNext = false
                }
                
                self.searchLoadingStatus = .Loaded
                
                // apply received data
                self.createSearchDataSource()
                self.tableView.reloadData()
                
                }).onFailure(callback: { error in
                    
                    self.searchLoadingStatus = .Failed
                    print(error)
                })
    }
    
    private func createSearchDataSource() {
        
        if let page = self.searchCompaniesPage {
            
            for company in page.companies {
                
                self.searchSection.items.append(GenericCollectionSectionItem(item: company))
            }
            
            for image in page.images {
                
                self.companyImages.insert(image)
            }
        }
    }
    
    
    private func reloadData() {
        
        self.tableView.dataSource = shouldShowSearchResults ? searchDataSource : dataSource
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
