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
    
    case Idle
    
    case Loading
    
    case Failed
    
    case Loaded
}

class TFeedTableViewController: UITableViewController {

    private var loadingStatus = TCompanyNewsLoadingStatus.Idle
    
    private var dataSource = TableViewDataSource()
    
    private let section = CollectionSection()
    
    private var news: [TFeedItem] = []
    
    private var companies = Set<TCompany>()
    
    private var pageNumber = 1
    
    private var pageSize = 20
    
    private var canLoadNext = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        self.setup()
        
        self.tableView.tableFooterView = UIView()
        
        self.dataSource.sections.append(section)
        
        self.tableView.dataSource = self.dataSource
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                                style: .Plain,
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

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let superView = self.view.superview where self.loadingStatus == .Loading {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
        
        if self.loadingStatus == .Failed {
            
            self.loadNews()
        }
    }
    
    // MARK: - Private mathods
    
    private func loadNews() {
        
        self.loadingStatus = .Loading
        
        if let superView = self.view.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superView)
        }
        
        Api.sharedInstance.feed(pageNumber, pageSize: pageSize)
            
            .onSuccess {[weak self] page in
                
                self?.loadingStatus = .Loaded
                
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
                
                self.loadingStatus = .Failed
                
                if let superView = self.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superView)
                }
                
                print(error)
            }
    }
    
    private func createDataSource() {
        
        self.section.items.removeAll()
        
        for item in news {
            
            if let company = self.companies.filter({ $0.id == item.companyId }).first {
                
                if company.alias == "targo" {
                    
                    section.initializeCellWithReusableIdentifierOrNibName("TargoNews", item: item, bindingAction: { (cell, item) in
                        
                        if item.indexPath.row + 10
                            >= self.dataSource.sections[item.indexPath.section].items.count
                            && self.canLoadNext
                            && self.loadingStatus != .Loading {
                            
                            self.loadNews()
                        }
                        
                        let newsItem = item.item as! TFeedItem
                        let viewCell = cell as! TFeedTargoNewsTableViewCell
                        
                        viewCell.layoutIfNeeded()
                        
                        viewCell.more.setTitle("action_more".localized, forState: .Normal)
                        viewCell.more.tintColor = UIColor(hexString: kHexMainPinkColor)
                        viewCell.more.userInteractionEnabled = false
                        viewCell.newsDetails.text = newsItem.feedItemDescription
                        
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = kDateTimeFormat
                        
                        if let date = formatter.dateFromString(newsItem.createdAt) {
                            
                            let formatter = NSDateFormatter()
                            formatter.dateStyle = .ShortStyle
                            formatter.timeStyle = .NoStyle
                            
                            viewCell.date.text = formatter.stringFromDate(date)
                        }
                    })
                }
                else {
                    
                    section.initializeCellWithReusableIdentifierOrNibName("CompanyNews", item: item, bindingAction: { (cell, item) in
                        
                        if item.indexPath.row + 10
                            >= self.dataSource.sections[item.indexPath.section].items.count
                            && self.canLoadNext
                            && self.loadingStatus != .Loading {
                            
                            self.loadNews()
                        }
                        
                        let newsItem = item.item as! TFeedItem
                        let viewCell = cell as! TFeedCompanyNewsTableViewCell
                        
                        viewCell.layoutIfNeeded()
                        
                        viewCell.more.setTitle("action_more".localized, forState: .Normal)
                        viewCell.more.tintColor = UIColor(hexString: kHexMainPinkColor)
                        viewCell.more.userInteractionEnabled = false
                        viewCell.companyTitle.text = company.title
                        viewCell.newsDetails.text = newsItem.feedItemDescription
                        
                        let formatter = NSDateFormatter()
                        formatter.dateFormat = kDateTimeFormat
                        
                        if let date = formatter.dateFromString(newsItem.createdAt) {
                            
                            let formatter = NSDateFormatter()
                            formatter.dateStyle = .ShortStyle
                            formatter.timeStyle = .NoStyle
                            
                            viewCell.date.text = formatter.stringFromDate(date)
                        }
                    })
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller = self.instantiateViewControllerWithIdentifierOrNibName("FeedDetails") as! TFeedDetailsTableViewController
        
        if let news = self.dataSource.sections[indexPath.section].items[indexPath.row].item as? TFeedItem {
            
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
