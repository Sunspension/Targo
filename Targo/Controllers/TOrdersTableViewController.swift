//
//  TOrdersTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import RealmSwift
import SwiftOverlays

private enum ShopOrdersSectionEnum: Int {
    
    case History
    
    case InProgress
}


class TOrdersTableViewController: UITableViewController {

    var dataSource: GenericTableViewDataSource<THistoryOrderItemTableViewCell, TShopOrder>?
    
    var companies: [TCompany]?
    
    var orders: [TShopOrder]?
    
    var companyImages: [TImage]?
    
    var loading = false
    
    var checkingOrdersLoadingStatus = TLoadingStatusEnum.Idle
    
    var timer: NSTimer?
    
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(TOrdersTableViewController.onOrdersLoadNotification(_:)),
                                                         name: kTargoDidLoadOrdersNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(TOrdersTableViewController.onOrdersLoadNotification(_:)),
                                                         name: kTargoUserDidCancelOrderNotification,
                                                         object: nil)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        self.dataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "HistoryOrderItemCell",
                                                     bindingAction: { (cell, item) in
                                                        
                                                        if let companies = self.companies {
                                                            
                                                            if let company = companies.filter({ $0.id == item.item?.companyId })
                                                                .first {
                                                                
                                                                cell.companyName.text = company.title
                                                                
                                                                let items = item.item!.items
                                                                
                                                                var orderDesription = ""
                                                                
                                                                for index in 0 ... items.count - 1 {
                                                                    
                                                                    let orderItem = items[index]
                                                                    orderDesription += orderItem.title
                                                                    
                                                                    if (index != items.count - 1) {
                                                                        
                                                                        orderDesription += ", "
                                                                    }
                                                                }
                                                                
                                                                cell.orderDescription.text = orderDesription
                                                                
                                                                if item.item!.isNew {
                                                                    
                                                                    let background = UIView()
                                                                    background.backgroundColor = UIColor(red: 205 / 255, green: 0 / 255, blue: 121 / 255, alpha: 0.17)
                                                                    cell.backgroundView = background
                                                                }
                                                                else {
                                                                    
                                                                    let background = UIView()
                                                                    background.backgroundColor = UIColor.whiteColor()
                                                                    cell.backgroundView = background
                                                                }
                                                                
                                                                let formatter = NSDateFormatter()
                                                                formatter.dateFormat = kDateTimeFormat
                                                                
                                                                if let date = formatter.dateFromString(item.item!.created) {
                                                                    
                                                                    let formatter = NSDateFormatter()
                                                                    formatter.dateStyle = .ShortStyle
                                                                    formatter.timeStyle = .NoStyle
                                                                    
                                                                    cell.orderDate.text = formatter.stringFromDate(date)
                                                                }
                                                            }
                                                        }
        })
        
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.setup()
        self.setup()
        
        self.tableView.registerNib(UINib(nibName: "TCompanyMenuHeaderView", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        let realm = try! Realm()
        
        if let _ = realm.objects(TOrderLoaderCookie).first {
            
            let orders = realm.objects(TShopOrder).sorted("id", ascending: false)
            self.orders = Array<TShopOrder>(orders)
            
            loadCompaniesAndImages()
        }
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10,
                                                            target: self,
                                                            selector: #selector(TOrdersTableViewController.checkActiveOrdersStatus),
                                                            userInfo: nil,
                                                            repeats: true)
        
        if let superview = self.view.superview {
            
            if self.loading {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
        self.removeAllOverlays()
    }
    
    func onOrdersLoadNotification(notification: NSNotification) {
        
       self.reloadFromDataBase()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as! TCompanyMenuHeaderView
        header.title.text = self.dataSource!.sections[section].title
        
        return header;
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! TCompanyMenuHeaderView
        
        header.background.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        header.layer.shadowPath = UIBezierPath(rect: header.layer.bounds).CGPath
        header.layer.shadowOffset = CGSize(width: 0, height: 1)
        header.layer.shadowOpacity = 0.5
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("OrderStatus") as? TOrderStatusViewController {
            
            let item = self.dataSource!.sections[indexPath.section].items[indexPath.row]
            
            if let company = self.companies?.filter({ $0.id == item.item!.companyId }).first {
                
                controller.companyName = company.title
                
                if let image = self.companyImages?.filter({ $0.id == company.imageId }).first {
                    
                    controller.companyImage = image
                }
            }
            
            let order = item.item!
            let realm = try! Realm()
            realm.beginWrite()
            
            order.isNew = false
            
            do {
                
                try realm.commitWrite()
            }
            catch {
                
                print("Caught an error when was trying to make commit to Realm")
            }
            
            // turn off the background
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.backgroundView = nil
            
            controller.shopOrder = item.item
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func checkActiveOrdersStatus() {
        
        if self.checkingOrdersLoadingStatus == .Loading {
            
            return
        }
        
        if let section = self.dataSource?.sections.filter({ ($0.sectionType as! ShopOrdersSectionEnum) == .InProgress }).first {
            
            if let targetItem = section.items.maxElement({self.dateFromString($0.item!.updated)?.compare(self.dateFromString($1.item!.updated)!) == .OrderedDescending }) {
                
                self.checkingOrdersLoadingStatus = .Loading
                
                Api.sharedInstance.loadShopOrders(targetItem.item!.updated, olderThen: true, pageSize: 1000)
                    
                    .onSuccess(callback: {[weak self] orders in
                        
                        self?.checkingOrdersLoadingStatus = .Loaded
                        
                        let realm = try! Realm()
                        
                        for order in orders {
                            
                            if let oldOrder = realm.objectForPrimaryKey(TShopOrder.self, key: order.id) {
                                
                                if let oldDate = self?.dateFromString(oldOrder.updated) {
                                    
                                    if let newDate = self?.dateFromString(order.updated) {
                                        
                                        if oldDate.compare(newDate) != .OrderedSame {
                                            
                                            if order.orderStatus == ShopOrderStatusEnum.Canceled.rawValue
                                                || order.orderStatus == ShopOrderStatusEnum.Finished.rawValue
                                                || order.orderStatus == ShopOrderStatusEnum.PayError.rawValue
                                                || order.orderStatus == ShopOrderStatusEnum.CanceledByUser.rawValue {
                                                
                                                order.isNew = false
                                            }
                                            else {
                                                
                                                order.isNew = true
                                            }
                                            
                                            try! realm.write({
                                                
                                                realm.add(order, update: true)
                                            })
                                        }
                                    }
                                }
                            }
                        }
                        
                        if orders.count > 0 {
                            
                            self?.reloadFromDataBase()
                        }
                    })
                    .onFailure(callback: {[weak self] error in
                        
                        self?.checkingOrdersLoadingStatus = .Failed
                    })
            }
        }
    }

    
    //MARK: - Private methods
    
    private func reloadFromDataBase() {
        
        let realm = try! Realm()
        let orders = realm.objects(TShopOrder).sorted("id", ascending: false)
        self.orders = Array<TShopOrder>(orders)
        
        loadCompaniesAndImages()
    }
    
    private func dateFromString(date: String) -> NSDate? {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = kDateTimeFormat
        
        return formatter.dateFromString(date)
    }
    
    private func loadCompaniesAndImages() {
        
        if let orders = self.orders {
            
            let companyIds = orders.map({ $0.companyId })
            let set = Set<Int>(companyIds)
            let ids = Array(set)
            
            self.loading = true
            
            Api.sharedInstance.loadCompaniesByIds(ids)
                
                .onSuccess(callback: {[weak self] companies in
                    
                    let imageIds = companies.map({ $0.imageId })
                    let set = Set<Int>(imageIds)
                    let ids = Array(set)
                    
                    Api.sharedInstance.loadImagesByIds(ids)
                        
                        .onSuccess(callback: {[weak self] images in
                            
                            self?.loading = false
                            
                            if let superview = self?.view.superview {
                                
                                SwiftOverlays.removeAllOverlaysFromView(superview)
                            }
                            
                            self?.companies = companies
                            self?.companyImages = images
                            
                            self?.createDataSource()
                            self?.tableView.reloadData()
                            
                            }).onFailure(callback: {[weak self] error in
                                
                                self?.loading = false
                                
                                if let superview = self?.view.superview {
                                    
                                    SwiftOverlays.removeAllOverlaysFromView(superview)
                                }
                            })
                    
                    }).onFailure(callback: {[weak self] error in
                        
                        self?.loading = false
                        
                        if let superview = self?.view.superview {
                            
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                        })
        }
    }
    
    private func createDataSource() {
        
        self.dataSource?.sections.removeAll()
        
        for order in self.orders! {
            
            let orderStatus = ShopOrderStatusEnum(rawValue: order.orderStatus)
            
            if orderStatus == .Canceled
                || orderStatus == .Finished
                || orderStatus == .PayError
                || orderStatus == .CanceledByUser {
                
                var sectionHistory =
                    self.dataSource!.sections.filter({ $0.sectionType as? ShopOrdersSectionEnum == .History }).first
                
                if sectionHistory == nil {
                    
                    sectionHistory = GenericCollectionSection<TShopOrder>(title: "order_history_order_title".localized)
                    sectionHistory!.sectionType = ShopOrdersSectionEnum.History
                    self.dataSource?.sections.append(sectionHistory!)
                }
                
                let realm = try! Realm()
                realm.beginWrite()
                
                order.isNew = false
                
                do {
                    
                    try realm.commitWrite()
                }
                catch {
                    
                    print("Caught an error when was trying to make commit to Realm")
                }
                
                sectionHistory!.items.append(GenericCollectionSectionItem(item: order))
            }
            else {
                
                var inProgress =
                    self.dataSource!.sections.filter({ $0.sectionType as? ShopOrdersSectionEnum == .InProgress }).first
                
                if inProgress == nil {
                    
                    inProgress = GenericCollectionSection<TShopOrder>(title: "order_in_progress_order_title".localized)
                    inProgress!.sectionType = ShopOrdersSectionEnum.InProgress
                    self.dataSource?.sections.append(inProgress!)
                }
                
                inProgress!.items.append(GenericCollectionSectionItem(item: order))
            }
        }
        
        self.dataSource?.sections.sortInPlace({ ($0.sectionType as! ShopOrdersSectionEnum).rawValue > ($1.sectionType as! ShopOrdersSectionEnum).rawValue })
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
