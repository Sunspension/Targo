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
    
    fileprivate let section = GenericCollectionSection<TCompanyAddress>()
    
    fileprivate let searchSection = GenericCollectionSection<TCompanyAddress>()
    
    fileprivate let favoriteSection = GenericCollectionSection<TCompanyAddress>()
    
    fileprivate var companyImages = Set<TImage>()
    
    fileprivate var userLocation: CLLocation?
    
    fileprivate var dataSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompanyAddress>?
    
    fileprivate var searchDataSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompanyAddress>?
    
    fileprivate var favoriteDataSource: GenericTableViewDataSource<TCompanyTableViewCell, TCompanyAddress>?
    
    fileprivate var companiesPage: TCompanyAddressesPage?
    
    fileprivate var searchCompaniesPage: TCompanyAddressesPage?
    
    fileprivate var pageNumber: Int = 1
    
    fileprivate var searchPageNumer: Int = 1
    
    fileprivate var pageSize: Int = 20
    
    fileprivate var canLoadNext = true
    
    fileprivate var searchCanLoadNext = true
    
    fileprivate var loadingStatus = TLoadingStatusEnum.idle
    
    fileprivate var searchLoadingStatus = TLoadingStatusEnum.idle
    
    fileprivate var favoriteLoadingStatus = TLoadingStatusEnum.idle
    
    fileprivate let manager = NetworkReachabilityManager(host: "www.apple.com")
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var shouldShowSearchResults = false
    
    fileprivate var cancelPreviousResult = false
    
    fileprivate var cancellationTokens = [Operation]()
    
    fileprivate var scheduleRefreshTimer: Timer?
    
    fileprivate var bookmarkButton = UIButton(type: .custom)
    
    fileprivate var dummyView: UILabel = {
       
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 70))
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Нет заведений"
        
        return label
    }()
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: kHexTableViewBackground)
        self.tableView.backgroundView = backgroundView
        self.setup()
        
        setupSearchController()
        setupRefreshControl()
        
        manager?.listener = { status in
            
            switch status {
                
            case .reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi):
                
                if self.canLoadNext && self.loadingStatus == .failed {
                    
                    self.loadCompanyAddress()
                }
                
                break
                
            default:
                break
            }
        }
        
        manager?.startListening()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-map"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.openMap))
        
        self.bookmarkButton.setImage(UIImage(named: "icon-star"), for: UIControlState())
        self.bookmarkButton.setImage(UIImage(named: "icon-fullStar"), for: .selected)
        self.bookmarkButton.tintColor = UIColor(hexString: "#f1c40f")
        self.bookmarkButton.addTarget(self, action: #selector(self.loadBookmarks), for: .touchUpInside)
        self.bookmarkButton.sizeToFit()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.bookmarkButton)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        self.dataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "CompanyTableCell", bindingAction: binding)
        self.dataSource?.sections.append(section)
        
        self.searchDataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "CompanyTableCell", bindingAction: binding)
        self.searchDataSource?.sections.append(searchSection)
        
        self.favoriteDataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "CompanyTableCell", bindingAction: binding)
        self.favoriteDataSource?.sections.append(favoriteSection)
        
        self.tableView.dataSource = self.dataSource
        
        TLocationManager.sharedInstance.subscribeObjectForLocationChange(self, selector: #selector(self.userLocationChanged))
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onUIApplicationWillEnterForegroundNotification),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        
        self.loadCompanyAddress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // update for new items every 10 minutes
        self.scheduleRefreshTimer = Timer.scheduledTimer(timeInterval: 600,
                                                         target: self,
                                                         selector: #selector(self.manualRefresh),
                                                         userInfo: nil,
                                                         repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.scheduleRefreshTimer?.invalidate()
        
        if let superView = self.view.superview {
            
            SwiftOverlays.removeAllOverlaysFromView(superView)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var item: GenericCollectionSectionItem<TCompanyAddress>!
        
        if shouldShowSearchResults == true {
            
            let section = self.searchDataSource!.sections[(indexPath as NSIndexPath).section]
            item = section.items[(indexPath as NSIndexPath).row]
        }
        else if self.bookmarkButton.isSelected {
            
            let section = self.favoriteDataSource!.sections[(indexPath as NSIndexPath).section]
            item = section.items[(indexPath as NSIndexPath).row]
        }
        else {
            
            let section = self.dataSource!.sections[(indexPath as NSIndexPath).section]
            item = section.items[(indexPath as NSIndexPath).row]
        }
        
        let controller = TCompanyMenuTableViewController.controllerInstance()
        controller.company = item.item
        controller.companyImage = self.companyImages.filter({$0.id == item.item!.companyImageId.value}).first
        controller.showButtonInfo = true
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openMap() {
        
        if let mapViewController = self.instantiateViewControllerWithIdentifierOrNibName("CompaniesOnMaps") as? TCompaniesOnMapsViewController {
            
            mapViewController.companies = self.dataSource?.sections[0].items.map({ $0.item! })
            mapViewController.images = Array(self.companyImages)
            
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    func userLocationChanged() {
        
        self.userLocation = TLocationManager.sharedInstance.lastLocation
        
        if self.userLocation != nil && self.loadingStatus != .loading && self.canLoadNext {
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }
            
            self.loadingStatus = .loading
            
            self.pageNumber = 1
            
            // Try to load only first several companies related to user location and limit
            Api.sharedInstance.loadCompanyAddresses(
                location: self.userLocation!,
                pageNumber: self.pageNumber,
                pageSize: self.pageSize)
                
                .onSuccess(callback: { [unowned self] companyPage in
                    
                    self.loadingStatus = .loaded
                    
                    if self.pageSize == companyPage.companies.count {
                        
                        self.canLoadNext = true
                        self.pageNumber += 1
                    }
                    else {
                        
                        // reset counter
                        self.pageNumber = 1
                        self.canLoadNext = false
                    }
                    
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    self.companiesPage = companyPage
                    
                    self.section.items.removeAll()
                    self.createDataSource()
                    
                    if self.section.items.count == 0 {
                        
                        self.tableView.tableFooterView = self.dummyView
                    }
                    else {
                        
                        self.tableView.tableFooterView = UIView()
                    }

                    self.tableView.reloadData()
                    
                    }).onFailure(callback: { [unowned self] error in
                        
                        self.loadingStatus = .failed
                        
                        if let superview = self.view.superview {
                            
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                        
                        print(error)
                    })
        }
    }
    
    func loadCompanyAddress(_ forceRefresh: Bool = false) {
        
        if self.userLocation == nil {
            
            if let location = TLocationManager.sharedInstance.previousSuccessLocation {
                
                self.userLocation = location
            }
            else {
                
                if forceRefresh {
                    
                    self.refreshControl?.endRefreshing()
                }
                
                self.loadingStatus = .failed
                
                return
            }
        }
        
        guard self.userLocation != nil else {
            
            return
        }
        
        self.loadingStatus = .loading
        
        Api.sharedInstance.loadCompanyAddresses(
            
            location: self.userLocation!,
            pageNumber: self.pageNumber,
            pageSize: self.pageSize)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                self.loadingStatus = .loaded
                
                if forceRefresh {
                    
                    self.refreshControl?.endRefreshing()
                    self.section.items.removeAll()
                }
                
                self.companiesPage = companyPage
                self.createDataSource()
                
                if self.section.items.count == 0 {
                    
                    self.tableView.tableFooterView = self.dummyView
                }
                else {
                    
                    self.tableView.tableFooterView = UIView()
                }
                
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
                    
                    self.loadingStatus = .failed
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
        
        if canLoadNext && loadingStatus == .failed {
            
            self.loadCompanyAddress()
        }
    }
    
    //MARK: - UISearchBar delegate implementation
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        shouldShowSearchResults = true
        reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        shouldShowSearchResults = false
        reloadData()
    }
    
    //MARK: - UISearchResultUpdating delegate implementation
    func updateSearchResults(for searchController: UISearchController) {
        
        self.searchPageNumer = 1
        
        for token in self.cancellationTokens {
            
            token.cancel()
        }
        
        let token = Operation()
        self.cancellationTokens.append(token)
        
        if let string = searchController.searchBar.text {
            
            loadCompanyAddress(string, cancellationToken: token)
        }
    }

    
    func manualRefresh() {
        
        if self.bookmarkButton.isSelected {
            
            self.loadFavoriteCompanyAddresses(true)
        }
        else {
            
            self.pageNumber = 1
            self.loadCompanyAddress(true)
        }
    }
    
    func createFavoriteDataSource(_ page: TCompanyAddressesPage) {
        
        self.favoriteSection.items.removeAll()
        
        for company in page.companies {
            
            self.favoriteSection.items.append(GenericCollectionSectionItem(item: company))
        }
        
        for image in page.images {
            
            self.companyImages.insert(image)
        }
    }
    
    func loadBookmarks() {
        
        if self.userLocation == nil {
            
            self.loadingStatus = .failed
            
            return
        }
        
        self.bookmarkButton.isSelected = !self.bookmarkButton.isSelected
        
        if bookmarkButton.isSelected {
            
            tableView.tableHeaderView = nil
            self.tableView.dataSource = self.favoriteDataSource
            
            self.loadFavoriteCompanyAddresses()
        }
        else {
            
            self.tableView.tableHeaderView = searchController.searchBar
            self.tableView.dataSource = self.dataSource
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.tableView.contentOffset = CGPoint.zero
        }
    }
    
    func loadFavoriteCompanyAddresses(_ forceRefresh: Bool = false) {
        
        Api.sharedInstance.favoriteCompanyAddresses(location: self.userLocation!)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                self.loadingStatus = .loaded
                
                if forceRefresh {
                    
                    self.refreshControl?.endRefreshing()
                    self.favoriteSection.items.removeAll()
                }
                
                self.createFavoriteDataSource(companyPage)
                
                if self.favoriteSection.items.count == 0 {
                    
                    self.tableView.tableFooterView = self.dummyView
                }
                else {
                    
                    self.tableView.tableFooterView = UIView()
                }
                
                self.tableView.reloadData()
                
                //                    if self.pageSize == companyPage.companies.count {
                //
                //                        self.canLoadNext = true
                //                        self.pageNumber += 1
                //                    }
                //                    else {
                //
                //                        // reset counter
                //                        self.pageNumber = 1
                //                        self.canLoadNext = false
                //                    }
                
                }).onFailure(callback: { error in
                    
                    if forceRefresh {
                        
                        self.refreshControl?.endRefreshing()
                    }
                    
                    self.loadingStatus = .failed
                    print(error)
                })
    }
    
    //MARK: - Private methods
    fileprivate func setupRefreshControl() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.manualRefresh), for: .valueChanged)
    }
    
    fileprivate func getCompanyImage(_ item: GenericCollectionSectionItem<TCompanyAddress>, viewCell: TCompanyTableViewCell) {
        
        let company = item.item!
        
        if let image =
            self.companyImages.filter({$0.id == company.companyImageId.value}).first {
            
            let open = company.isOpenNow
            
            if open == nil || !open! {
                
                viewCell.closeCompany()
            }
            
            let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
            viewCell.companyImage.af_setImage(withURL: URL(string: image.url)!,
                                              filter: filter,
                                              imageTransition: .crossDissolve(0.5))
        }
    }
    
    fileprivate func setupSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search_place_holder".localized
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = UIColor(hexString: kHexMainPinkColor)
        self.definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
    }

    
    fileprivate func binding(_ cell: TCompanyTableViewCell, item: GenericCollectionSectionItem<TCompanyAddress>) {
        
        let indexPath = item.indexPath
        
        if shouldShowSearchResults {
            
            if indexPath!.row + 10
                >= self.searchDataSource!.sections[indexPath!.section].items.count
                && self.searchCanLoadNext
                && self.searchLoadingStatus != .loading {
                
                guard let string = searchController.searchBar.text else {
                    
                    return
                }
                
                self.loadCompanyAddress(string)
            }
        }
        else {
            
            if indexPath!.row + 10
                >= self.dataSource!.sections[indexPath!.section].items.count
                && self.canLoadNext
                && self.loadingStatus != .loading {
                
                self.loadCompanyAddress()
            }
        }
        
        let company = item.item!
        
        let distance = company.distance / 1000
        
        let distanceString = distance < 1 ? String(Int(company.distance)) + " " + "meters".localized
            : String(format:"%.1f", distance) + " " + "kilometers".localized
        
        cell.companyTitle.text = company.companyTitle
        cell.additionalInfo.text = company.companyCategoryTitle
            + ", " + distanceString + ", " + company.title
        
        cell.ratingText.text = String(format:"%.1f", company.rating)
        cell.ratingProgress.setProgress(1 / 5 * company.rating, animated: false)
        cell.ratingProgress.trackFillColor = UIColor(hexString: kHexMainPinkColor)
        cell.ratingProgress.isHidden = false
        
        DispatchQueue.main.async {
            
            if self.shouldShowSearchResults {
                
                if let item = self.searchDataSource?.sections[item.indexPath.section].items[item.indexPath.row] {
                    
                    item.cellHeight = cell.frame.height
                    self.getCompanyImage(item, viewCell: cell)
                }
            }
            else if self.bookmarkButton.isSelected {
                
                if let item = self.favoriteDataSource?.sections[item.indexPath.section].items[item.indexPath.row] {
                    
                    item.cellHeight = cell.frame.height
                    self.getCompanyImage(item, viewCell: cell)
                }
            }
            else {
                
                if let item = self.dataSource?.sections[item.indexPath.section].items[item.indexPath.row] {
                    
                    item.cellHeight = cell.frame.height
                    self.getCompanyImage(item, viewCell: cell)
                }
            }
            
            let layer = cell.shadowView.layer
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowOpacity = 0.5
            layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
        }
    }
    
    fileprivate func loadCompanyAddress(_ query:String, cancellationToken: Operation? = nil) {
        
        if self.userLocation == nil {
            
            self.searchLoadingStatus = .failed
            return
        }
        
        self.searchLoadingStatus = .loading
        
        if let superView = self.tableView.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
        
        Api.sharedInstance.loadCompanyAddresses(
            
            location: self.userLocation!,
            pageNumber: self.searchPageNumer,
            pageSize: self.pageSize,
            query: query)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                if let superView = self.tableView.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                if let token = cancellationToken {
                    
                    self.cancellationTokens.remove(token)
                    
                    if token.isCancelled {
                        
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
                
                self.searchLoadingStatus = .loaded
                
                // apply received data
                self.createSearchDataSource()
                
                if self.searchSection.items.count == 0 {
                    
                    self.tableView.tableFooterView = self.dummyView
                }
                else {
                    
                    self.tableView.tableFooterView = UIView()
                }
                
                self.tableView.reloadData()
                
                }).onFailure(callback: { error in
                    
                    self.searchLoadingStatus = .failed
                    print(error)
                })
    }
    
    fileprivate func createSearchDataSource() {
        
        if let page = self.searchCompaniesPage {
            
            for company in page.companies {
                
                self.searchSection.items.append(GenericCollectionSectionItem(item: company))
            }
            
            for image in page.images {
                
                self.companyImages.insert(image)
            }
        }
    }
    
    
    fileprivate func reloadData() {
        
        self.tableView.dataSource = shouldShowSearchResults ? searchDataSource : dataSource
        self.tableView.reloadData()
    }
    
//    fileprivate func reloadTableView() {
//        
//        UIView.transition(with: self.tableView,
//                          duration: 0.2,
//                          options: .transitionCrossDissolve,
//                          animations: {
//            
//                            self.tableView.reloadData()
//            
//                        }, completion: nil)
//    }
}
