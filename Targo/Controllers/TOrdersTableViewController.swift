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
    
    case history
    
    case inProgress
}


class TOrdersTableViewController: UITableViewController {

    fileprivate var dataSource: GenericTableViewDataSource<THistoryOrderItemTableViewCell, TShopOrder>?
    
    fileprivate var dummyView: UILabel = {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 70))
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Нет заказов"
        
        return label
    }()
    
    fileprivate var loading = false
    
    fileprivate var timer: Timer?
    
    fileprivate let activeStatuses = [ShopOrderStatusEnum.new,
                                      ShopOrderStatusEnum.view,
                                      ShopOrderStatusEnum.paymentSuccess,
                                      ShopOrderStatusEnum.complete,
                                      ShopOrderStatusEnum.inProgress]
    
    var companies: [TCompany]?
    
    var orders: [TShopOrder]?
    
    var companyImages: [TImage]?
    
    var checkingOrdersLoadingStatus = TLoadingStatusEnum.idle
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onOrdersLoadNotification(_:)),
                                               name: NSNotification.Name(rawValue: kTargoDidLoadOrdersNotification),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onOrdersLoadNotification(_:)),
                                               name: NSNotification.Name(rawValue: kTargoUserDidCancelOrderNotification),
                                               object: nil)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        
        self.dataSource = GenericTableViewDataSource(reusableIdentifierOrNibName: "HistoryOrderItemCell",
                                                     bindingAction: { (cell, item) in
                                                        
                                                        if let companies = self.companies {
                                                            
                                                            if let company = companies.filter({ $0.id == item.item?.companyId })
                                                                .first {
                                                                
                                                                cell.companyName.text = company.title
                                                                cell.orderStatus.text = item.item!.orderStatusTitle
                                                                cell.orderNumber.text = "Заказ " + String(item.item!.id)
                                                                
                                                                var totalPrice = 0
                                                                
                                                                item.item!.items.forEach({ good in
                                                                    
                                                                    totalPrice += good.count * good.price
                                                                })
                                                                
                                                                let discount = Int((Double(totalPrice) * (Double(item.item!.discountAmount) / 100)))
                                                                
                                                                totalPrice -= discount
                                                                
                                                                cell.price.text = String(totalPrice) + " \u{20BD}"
                                                                
                                                                if item.item!.isNew {
                                                                    
                                                                    let background = UIView()
                                                                    background.backgroundColor = UIColor(red: 205 / 255, green: 0 / 255, blue: 121 / 255, alpha: 0.17)
                                                                    cell.backgroundView = background
                                                                }
                                                                else {
                                                                    
                                                                    let background = UIView()
                                                                    background.backgroundColor = UIColor.white
                                                                    cell.backgroundView = background
                                                                }
                                                            }
                                                        }
        })
        
        self.tableView.dataSource = self.dataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.setup()
        self.setup()
        
        self.tableView.register(UINib(nibName: "TCompanyMenuHeaderView", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        let realm = try! Realm()
        
        if let _ = realm.objects(TOrderLoaderCookie.self).first {
            
            let orders = realm.objects(TShopOrder.self).sorted(byKeyPath: "id", ascending: false)
            self.orders = Array<TShopOrder>(orders)
            
            loadCompaniesAndImages()
        }
        
        self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.timer = Timer.scheduledTimer(timeInterval: 10,
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
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
        self.removeAllOverlays()
    }
    
    func onOrdersLoadNotification(_ notification: Notification) {
        
       self.reloadFromDataBase()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! TCompanyMenuHeaderView
        header.title.text = self.dataSource!.sections[section].title
        
        DispatchQueue.main.async {
            
            header.background.backgroundColor = UIColor(hexString: kHexMainPinkColor)
            header.layer.shadowPath = UIBezierPath(rect: header.layer.bounds).cgPath
            header.layer.shadowOffset = CGSize(width: 0, height: 1)
            header.layer.shadowOpacity = 0.5
        }
        
        return header;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("OrderStatus") as? TOrderStatusViewController {
            
            let item = self.dataSource!.sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
            
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
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundView = nil
            
            controller.shopOrder = item.item
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func checkActiveOrdersStatus() {
        
        if self.checkingOrdersLoadingStatus == .loading {
            
            return
        }
        
        if let section = self.dataSource?.sections.filter({ ($0.sectionType as! ShopOrdersSectionEnum) == .inProgress }).first {
            
            if let targetItem = section.items.max(by: {
                
                self.dateFromString($0.item!.updated)?.compare(self.dateFromString($1.item!.updated)!) == .orderedDescending }) {
                
                self.checkingOrdersLoadingStatus = .loading
                
                Api.sharedInstance.loadShopOrders(updatedDate: targetItem.item!.updated, olderThen: true, pageSize: 1000)
                    
                    .onSuccess(callback: { [weak self] orders in
                        
                        self?.checkingOrdersLoadingStatus = .loaded
                        
                        if orders.count > 0 {
                            
                            self?.handlingOrders(orders)
                            self?.reloadFromDataBase()
                        }
                    })
                    .onFailure(callback: { [weak self] error in
                        
                        self?.checkingOrdersLoadingStatus = .failed
                    })
            }
        }
    }

    
    //MARK: - Private methods
    fileprivate func handlingOrders(_ orders: [TShopOrder]) {
        
        let realm = try! Realm()
        
        for order in orders {
            
            if let oldOrder = realm.object(ofType: TShopOrder.self, forPrimaryKey: order.id) {
                
                if let oldDate = self.dateFromString(oldOrder.updated) {
                    
                    if let newDate = self.dateFromString(order.updated) {
                        
                        if oldDate.compare(newDate) != .orderedSame {
                            
                            if order.orderStatus == ShopOrderStatusEnum.canceled.rawValue
                                || order.orderStatus == ShopOrderStatusEnum.finished.rawValue
                                || order.orderStatus == ShopOrderStatusEnum.payError.rawValue
                                || order.orderStatus == ShopOrderStatusEnum.canceledByUser.rawValue {
                                
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
    }
    
    fileprivate func reloadFromDataBase() {
        
        let realm = try! Realm()
        let orders = realm.objects(TShopOrder.self).sorted(byKeyPath: "id", ascending: false)
        self.orders = Array<TShopOrder>(orders)
        
        loadCompaniesAndImages()
    }
    
    fileprivate func dateFromString(_ date: String) -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = kDateTimeFormat
        
        return formatter.date(from: date)
    }
    
    fileprivate func loadCompaniesAndImages() {
        
        if let orders = self.orders {
            
            let companyIds = orders.map({ $0.companyId })
            let set = Set<Int>(companyIds)
            let ids = Array(set)
            
            self.loading = true
            
            Api.sharedInstance.loadCompanies(companiesIds: ids)
                
                .onSuccess(callback: {[weak self] companies in
                    
                    let imageIds = companies.map({ $0.imageId })
                    let set = Set<Int>(imageIds)
                    let ids = Array(set)
                    
                    Api.sharedInstance.loadImages(imageIds: ids)
                        
                        .onSuccess(callback: {[weak self] images in
                            
                            self?.loading = false
                            
                            if let superview = self?.view.superview {
                                
                                SwiftOverlays.removeAllOverlaysFromView(superview)
                            }
                            
                            self?.companies = companies
                            self?.companyImages = images
                            
                            self?.createDataSource()
                            
                            if self?.orders?.count == 0 {
                                
                                self?.tableView.tableFooterView = self?.dummyView
                            }
                            else {
                                
                                self?.tableView.tableFooterView = UIView()
                            }
                            
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
    
    fileprivate func createDataSource() {
        
        self.dataSource?.sections.removeAll()
        
        let addItemToHistoryClosure: (_ order: TShopOrder) -> Void = { order in
            
            var sectionHistory =
                self.dataSource!.sections.filter({ $0.sectionType as? ShopOrdersSectionEnum == .history }).first
            
            if sectionHistory == nil {
                
                sectionHistory = GenericCollectionSection<TShopOrder>(title: "order_history_order_title".localized)
                sectionHistory!.sectionType = ShopOrdersSectionEnum.history
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
        
        for order in self.orders! {
            
            if let orderStatus = ShopOrderStatusEnum(rawValue: order.orderStatus) {
                
                if self.activeStatuses.contains(orderStatus) {
                    
                    var inProgress =
                        self.dataSource!.sections.filter({ $0.sectionType as? ShopOrdersSectionEnum == .inProgress }).first
                    
                    if inProgress == nil {
                        
                        inProgress = GenericCollectionSection<TShopOrder>(title: "order_in_progress_order_title".localized)
                        inProgress!.sectionType = ShopOrdersSectionEnum.inProgress
                        self.dataSource?.sections.append(inProgress!)
                    }
                    
                    inProgress!.items.append(GenericCollectionSectionItem(item: order))
                }
                else {
                    
                    addItemToHistoryClosure(order)
                }
            }
            else {
                
                addItemToHistoryClosure(order)
            }
        }
        
        self.dataSource?.sections.sort(by: { ($0.sectionType as! ShopOrdersSectionEnum).rawValue > ($1.sectionType as! ShopOrdersSectionEnum).rawValue })
    }
}
