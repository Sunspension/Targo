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
    
    fileprivate var news: [TFeedItem] = []
    
    fileprivate var companies = Set<TCompany>()
    
    fileprivate var pageNumber = 1
    
    fileprivate var pageSize = 20
    
    fileprivate var canLoadNext = false
    
    
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
            
            .onSuccess {[weak self] page in
                
                self?.loadingStatus = .loaded
                
                if self?.pageSize == page.news.count {
                    
                    self?.canLoadNext = true
                    self?.pageNumber += 1
                }
                else {
                    
                    // reset counter
                    self?.pageNumber = 1
                    self?.canLoadNext = false
                }
                
                if let superView = self?.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                self?.news += page.news
                
                for company in page.companies {
                    
                    self?.companies.insert(company)
                }
                
                self?.createDataSource()
                self?.tableView.reloadData()
            }
            .onFailure {[unowned self] error in
                
                self.loadingStatus = .failed
                
                if let superView = self.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                print(error)
            }
    }
    
    fileprivate func createDataSource() {
        
        self.section.items.removeAll()
        
        for item in news {
            
            if let company = self.companies.filter({ $0.id == item.companyId }).first {
                
                if company.alias == "targo" {
                    
                    section.initializeCellWithReusableIdentifierOrNibName("TargoNews", item: item, bindingAction: { (cell, item) in
                        
                        if item.indexPath.row + 10
                            >= self.dataSource.sections[item.indexPath.section].items.count
                            && self.canLoadNext
                            && self.loadingStatus != .loading {
                            
                            self.loadNews()
                        }
                        
                        let newsItem = item.item as! TFeedItem
                        let viewCell = cell as! TFeedTargoNewsTableViewCell
                        
                        viewCell.layoutIfNeeded()
                        
                        viewCell.more.setTitle("action_more".localized, for: UIControlState())
                        viewCell.more.tintColor = UIColor(hexString: kHexMainPinkColor)
                        viewCell.more.isUserInteractionEnabled = false
                        viewCell.newsDetails.text = newsItem.feedItemDescription
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = kDateTimeFormat
                        
                        if let date = formatter.date(from: newsItem.createdAt) {
                            
                            let formatter = DateFormatter()
                            formatter.dateStyle = .short
                            formatter.timeStyle = .none
                            
                            viewCell.date.text = formatter.string(from: date)
                        }
                    })
                }
                else {
                    
                    section.initializeCellWithReusableIdentifierOrNibName("CompanyNews", item: item, bindingAction: { (cell, item) in
                        
                        if item.indexPath.row + 10
                            >= self.dataSource.sections[item.indexPath.section].items.count
                            && self.canLoadNext
                            && self.loadingStatus != .loading {
                            
                            self.loadNews()
                        }
                        
                        let newsItem = item.item as! TFeedItem
                        let viewCell = cell as! TFeedCompanyNewsTableViewCell
                        
                        viewCell.layoutIfNeeded()
                        
                        viewCell.more.setTitle("action_more".localized, for: UIControlState())
                        viewCell.more.tintColor = UIColor(hexString: kHexMainPinkColor)
                        viewCell.more.isUserInteractionEnabled = false
                        viewCell.companyTitle.text = company.title
                        viewCell.newsDetails.text = newsItem.feedItemDescription
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = kDateTimeFormat
                        
                        if let date = formatter.date(from: newsItem.createdAt) {
                            
                            let formatter = DateFormatter()
                            formatter.dateStyle = .short
                            formatter.timeStyle = .none
                            
                            viewCell.date.text = formatter.string(from: date)
                        }
                    })
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = self.instantiateViewControllerWithIdentifierOrNibName("FeedDetails") as! TFeedDetailsTableViewController
        
        if let news = self.dataSource.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row].item as? TFeedItem {
            
            controller.news = news
            
            if let company = self.companies.filter({ $0.id == news.companyId }).first {
                
                controller.company = company
            }
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
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
