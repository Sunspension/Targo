//
//  TFeedTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import SwiftOverlays
import AlamofireImage

private enum TCompanyNewsLoadingStatus : Int {
    
    case idle
    
    case loading
    
    case failed
    
    case loaded
}

class TFeedTableViewController: UITableViewController {

    fileprivate var loadingStatus = TCompanyNewsLoadingStatus.idle
    
    fileprivate var dataSource = TableViewDataSource()
    
    fileprivate let section = CollectionSection()
    
    fileprivate var companies = Set<TCompany>()
    
    fileprivate var images = Set<TImage>()
    
    fileprivate var pageNumber = 1
    
    fileprivate var pageSize = 20
    
    fileprivate var canLoadNext = false
    
    fileprivate var dummyView: UILabel = {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 70))
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Нет новостей"
        
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.setup()
        
        self.tableView.tableFooterView = UIView()
        
        self.dataSource.sections.append(section)
        
        self.tableView.dataSource = self.dataSource
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .plain,
                                                                target: nil,
                                                                action: nil)
        
        let nib1 = UINib(nibName: String(describing: TCompanyNewsTableViewCell.self), bundle: nil)
        self.tableView.register(nib1, forCellReuseIdentifier: TCompanyNewsTableViewCell.identifier())
        
        let nib2 = UINib(nibName: String(describing: TNewsTableViewCell.self), bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: TNewsTableViewCell.identifier())
        
        self.loadNews()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let superView = self.view.superview , self.loadingStatus == .loading {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
        
        if self.loadingStatus == .failed {
            
            self.loadNews()
        }
    }
    
    // MARK: - Private mathods
    
    fileprivate func loadNews() {
        
        self.loadingStatus = .loading
        
        if let superView = self.view.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
        
        Api.sharedInstance.feed(pageNumber: pageNumber, pageSize: pageSize)
            
            .onSuccess {[unowned self] page in
                
                self.loadingStatus = .loaded
                
                if self.pageSize == page.news.count {
                    
                    self.canLoadNext = true
                    self.pageNumber += 1
                }
                else {
                    
                    // reset counter
                    self.pageNumber = 1
                    self.canLoadNext = false
                    // TODO if need update must remove all items from data source
                }
                
                if let superView = self.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                for company in page.companies {
                    
                    self.companies.insert(company)
                }
                
                if let images = page.images {
                    
                    for image in images {
                        
                        self.images.insert(image)
                    }
                }
                
                self.createDataSource(news: page.news)
                
                if page.news.count == 0 {
                    
                    self.tableView.tableFooterView = self.dummyView
                }
                else {
                    
                    self.tableView.tableFooterView = UIView()
                }

                self.tableView.reloadData()
            }
            .onFailure {[unowned self] error in
                
                self.loadingStatus = .failed
                
                if let superView = self.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                print(error)
            }
    }
    
    fileprivate func createDataSource(news: [TFeedItem]) {
        
        for item in news {
            
            if let company = self.companies.filter({ $0.id == item.companyId }).first {
                
                if company.alias == "targo" {
                    
                    section.initializeItem(reusableIdentifierOrNibName: TNewsTableViewCell.identifier(),
                                           item: item,
                                           bindingAction: { (cell, item) in
                                            
                                            if item.indexPath.row + 10
                                                >= self.dataSource.sections[item.indexPath.section].items.count
                                                && self.canLoadNext
                                                && self.loadingStatus != .loading {
                                                
                                                self.loadNews()
                                            }
                                            
                                            let newsItem = item.item as! TFeedItem
                                            let viewCell = cell as! TNewsTableViewCell
                                            
                                            viewCell.layoutIfNeeded()
                                            viewCell.selectionStyle = .none
                                            
                                            if newsItem.imageIds.count > 0 {
                                                
                                                if let image = self.images.filter({ $0.id == newsItem.imageIds[0] }).first {
                                                 
                                                    viewCell.imageZeroHeight.priority = 250
                                                    viewCell.imageAcpectRatio.priority = 900
                                                    viewCell.layoutIfNeeded()
                                                    
                                                    let filter = AspectScaledToFillSizeFilter(size: viewCell.newsImage.bounds.size)
                                                    viewCell.newsImage.af_setImage(withURL: URL(string: image.url)!, filter: filter)
                                                }
                                            }
                                            
                                            viewCell.actionButton.tintColor = UIColor.white
                                            
                                            switch newsItem.actionId {
                                                
                                            case 0:
                                                
                                                viewCell.actionButtonHeight.priority = 250
                                                viewCell.actionButtonZeroHeight.priority = 900
                                                
                                                break
                                                
                                            case 1:
                                                
                                                viewCell.actionButton.setTitle("feed_open_menu_action".localized, for: .normal)
                                                viewCell.actionButton.bnd_tap.observe(with: { event in
                                                    
                                                    let controller = TCompanyMenuTableViewController.controllerInstance(addressId: newsItem.addressId)
                                                    
                                                    self.navigationController?.pushViewController(controller, animated: true)
                                                    
                                                }).disposeIn(viewCell.bag)
                                                
                                                break
                                                
                                            case 2:
                                                
                                                viewCell.actionButton.setTitle("feed_open_company_info_action".localized, for: .normal)
                                                viewCell.actionButton.bnd_tap.observe(with: { event in
                                                    
                                                    let controller = TCompanyInfoTableViewController.controllerInstance(addressId: newsItem.addressId)
                                                    
                                                    self.navigationController?.pushViewController(controller, animated: true)
                                                    
                                                }).disposeIn(viewCell.bag)
                                                
                                                break
                                                
                                            default:
                                                break
                                            }
                                            
                                            viewCell.layoutIfNeeded()
                                            viewCell.actionButton.backgroundColor = UIColor(hexString: kHexMainPinkColor)
                                            viewCell.newsDetails.text = newsItem.feedItemDescription
                                            
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = kDateTimeFormat
                                            
                                            if let date = formatter.date(from: newsItem.createdAt) {
                                                
                                                let formatter = DateFormatter()
                                                formatter.dateStyle = .short
                                                formatter.timeStyle = .none
                                                
                                                viewCell.dateTime.text = formatter.string(from: date)
                                            }
                    })
                }
                else {
                    
                    section.initializeItem(reusableIdentifierOrNibName: TCompanyNewsTableViewCell.identifier(),
                                           item: item,
                                           bindingAction: { (cell, item) in
                                            
                                            if item.indexPath.row + 10
                                                >= self.dataSource.sections[item.indexPath.section].items.count
                                                && self.canLoadNext
                                                && self.loadingStatus != .loading {
                                                
                                                self.loadNews()
                                            }
                                            
                                            let newsItem = item.item as! TFeedItem
                                            let viewCell = cell as! TCompanyNewsTableViewCell
                                            
                                            viewCell.layoutIfNeeded()
                                            
                                            if newsItem.imageIds.count > 0 {
                                                
                                                if let image = self.images.filter({ $0.id == newsItem.imageIds[0] }).first {
                                                    
                                                    viewCell.imageZeroHeight.priority = 250
                                                    viewCell.imageAcpectRatio.priority = 900
                                                    viewCell.layoutIfNeeded()
                                                    
                                                    let filter = AspectScaledToFillSizeFilter(size: viewCell.newsImage.bounds.size)
                                                    viewCell.newsImage.af_setImage(withURL: URL(string: image.url)!, filter: filter)
                                                }
                                            }
                                            
                                            viewCell.actionButton.tintColor = UIColor.white
                                            
                                            switch newsItem.actionId {
                                                
                                            case 0:
                                                
                                                viewCell.actionButtonHeight.priority = 250
                                                viewCell.actionButtonZeroHeight.priority = 900
                                                
                                                break
                                                
                                            case 1:
                                                
                                                viewCell.actionButton.setTitle("feed_open_menu_action".localized, for: .normal)
                                                viewCell.actionButton.bnd_tap.observe(with: { event in
                                                    
                                                    let controller = TCompanyMenuTableViewController.controllerInstance(addressId: newsItem.addressId)
                                                    
                                                    self.navigationController?.pushViewController(controller, animated: true)
                                                    
                                                }).disposeIn(viewCell.bag)
                                                
                                                break
                                                
                                            case 2:
                                                
                                                viewCell.actionButton.setTitle("feed_open_company_info_action".localized, for: .normal)
                                                viewCell.actionButton.bnd_tap.observe(with: { event in
                                                    
                                                    let controller = TCompanyInfoTableViewController.controllerInstance(addressId: newsItem.addressId)
                                                    
                                                    self.navigationController?.pushViewController(controller, animated: true)
                                                    
                                                }).disposeIn(viewCell.bag)
                                                
                                                break
                                                
                                            default:
                                                break
                                            }
                                            
                                            viewCell.layoutIfNeeded()
                                            viewCell.actionButton.backgroundColor = UIColor(hexString: kHexMainPinkColor)
                                            
                                            viewCell.companyName.text = company.title
                                            viewCell.newsDetails.text = newsItem.feedItemDescription
                                            
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = kDateTimeFormat
                                            
                                            if let date = formatter.date(from: newsItem.createdAt) {
                                                
                                                let formatter = DateFormatter()
                                                formatter.dateStyle = .short
                                                formatter.timeStyle = .none
                                                
                                                viewCell.dateTime.text = formatter.string(from: date)
                                            }
                    })
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = self.dataSource.sections[indexPath.section].items[indexPath.row].cellHeight {
            
            return height
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.dataSource.sections[indexPath.section].items[indexPath.row].cellHeight = cell.frame.height
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let controller = self.instantiateViewControllerWithIdentifierOrNibName("FeedDetails") as! TFeedDetailsTableViewController
//        
//        if let news = self.dataSource.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row].item as? TFeedItem {
//            
//            controller.news = news
//            
//            if let company = self.companies.filter({ $0.id == news.companyId }).first {
//                
//                controller.company = company
//            }
//        }
//        
//        self.navigationController?.pushViewController(controller, animated: true)
//    }
    
    // MARK: - Table view data source
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
