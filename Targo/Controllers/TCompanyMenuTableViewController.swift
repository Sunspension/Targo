//
//  TCompanyMenuTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import SwiftOverlays
import AlamofireImage
import Bond
import ReactiveKit

private enum SectionTypeEnum: Int {
    
    case companyInfo = 001
}


class TCompanyMenuTableViewController: UIViewController, UITableViewDelegate {

    fileprivate var pageNumber = 1
    
    fileprivate var pageSize = 20
    
    fileprivate var canLoadNext = true
    
    fileprivate var loadingStatus = TLoadingStatusEnum.idle
    
    fileprivate var categories = Set<TShopCategory>()
    
    var company: TCompanyAddress?
    
    var companyImage: TImage?
    
    var dataSource = TableViewDataSource()
    
    var menuPage: TCompanyMenuPage?
    
    var showButtonInfo: Bool = false
    
    let orderItems = MutableObservableArray([CollectionSectionItem]())

    var cellHeightDictionary = [IndexPath : CGFloat]()
    
    var bag: Disposable?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonMakeOrder: UIButton!
    
    
    @IBAction func makeOrderAction(_ sender: AnyObject) {
    
        var goods = Array<(item: TShopGood, count: Int)>()
        
        for item in orderItems {
            
            let quantity = item.userData as! Int
            let good = item.item as! TShopGood
            
            goods.append((item: good, count: quantity))
        }
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("BasketController") as? TOrderReviewViewController {
            
            controller.itemSource = goods
            controller.company = self.company
            controller.companyImage = self.companyImage
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    deinit {
        
        print("\(typeName(self)) \(#function)")
        self.bag?.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = company?.companyTitle
        self.setup()
        
        self.buttonMakeOrder.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        
        self.buttonMakeOrder.isEnabled = false
        self.buttonMakeOrder.alpha = 0.5
        
        self.tableView.setup()
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        
        self.bag = self.orderItems.observeNext(with: { event in
            
            UIView.beginAnimations("buton", context: nil)
            
            UIView.animate(withDuration: 0.2, animations: {
                
                if event.dataSource.count == 0 {
                    
                    self.buttonMakeOrder.isEnabled = false
                    self.buttonMakeOrder.alpha = 0.5
                }
                else {
                    
                    self.buttonMakeOrder.isEnabled = true
                    self.buttonMakeOrder.alpha = 1
                }
            })
            
            UIView.commitAnimations()
        })
        
//        self.bag = self.observableOrderItems.observe { event in
//            
//            UIView.beginAnimations("buton", context: nil)
//            
//            UIView.animate(withDuration: 0.2, animations: {
//                
//                if self.orderItems.count == 0 {
//                    
//                    self.buttonMakeOrder.isEnabled = false
//                    self.buttonMakeOrder.alpha = 0.5
//                }
//                else {
//                    
//                    self.buttonMakeOrder.isEnabled = true
//                    self.buttonMakeOrder.alpha = 1
//                }
//            })
//            
//            UIView.commitAnimations()
//        }
        
        if showButtonInfo {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-info"), style: .plain, target: self, action: #selector(TCompanyMenuTableViewController.openInfo))
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tableView.register(UINib(nibName: "TCompanyImageMenuTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "CompanyImageMenu")
        
        self.tableView.register(UINib(nibName: "TCompanyMenuHeaderView", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        self.tableView.register(UINib(nibName: "TMenuItemSmallTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "MenuItemSmallCell")
        
        self.tableView.register(UINib(nibName: "TMenuItemFullTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "MenuItemFullCell")
        
        self.loadCompanyMenu()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if self.loadingStatus != .loading {
            
            return
        }
        
        if let superview = self.view.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superview)
        }
    }
    
    func openInfo() {
        
        if let controller =  self.instantiateViewControllerWithIdentifierOrNibName("CompanyInfoController") as? TCompanyInfoTableViewController {
            
            controller.company = self.company
            controller.companyImage = self.companyImage
            
            controller.makeOrderNavigationAction = {
                
                let _ = self.navigationController?.popViewController(animated: true)
            }
            
            controller.openMapNavigationAction = {
                
                if let company = self.company {
                    
                    if let mapViewController = self.instantiateViewControllerWithIdentifierOrNibName("CompaniesOnMaps") as? TCompaniesOnMapsViewController {
                        
                        mapViewController.companies = [company]
                        
                        if let image = self.companyImage {
                            
                            mapViewController.images = [image]
                        }
                        
                        mapViewController.reason = OpenMapsReasonEnum.oneCompany
                        
                        self.navigationController?.pushViewController(mapViewController, animated: true)
                    }
                }
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func addGoods() {
        
        for good in self.menuPage!.goods {
            
            var section = self.dataSource.sections.filter({ $0.sectionType as? Int == good.shopCategoryId }).first
            
            if (section == nil) {
                
                let category = self.categories.filter({ $0.id == good.shopCategoryId && $0.id != 0 }).first
                section = CollectionSection(title: category?.title ?? "Акция")
                section?.sectionType = good.shopCategoryId
                self.dataSource.sections.append(section!)
            }
            
            section!.initializeSwappableCellWithReusableIdentifierOrNibName("MenuItemSmallCell",
                                                                            secondIdentifierOrNibName: "MenuItemFullCell",
                                                                            item: good,
                                                                            bindingAction: { (cell, item) in
                                                                                
                                                                                let indexPath = item.indexPath!
                                                                                
                                                                                if indexPath.section == self.dataSource.sections.count - 1
                                                                                    && indexPath.row + 10
                                                                                    >= self.dataSource.sections[indexPath.section].items.count
                                                                                    && self.canLoadNext
                                                                                    && self.loadingStatus != .loading {
                                                                                    
                                                                                    self.loadCompanyMenu()
                                                                                }
                                                                                
                                                                                if item.swappable {
                                                                                    
                                                                                    if !item.selected {
                                                                                        
                                                                                        let itemGood = item.item as! TShopGood
                                                                                        let viewCell = cell as! TMenuItemSmallTableViewCell
                                                                                        
                                                                                        viewCell.addSeparator()
                                                                                        viewCell.goodTitle.text = itemGood.title
                                                                                        viewCell.goodDescription.text = itemGood.goodDescription
                                                                                        viewCell.price.text = String(itemGood.price) + " \u{20BD}"
                                                                                        viewCell.selectionStyle = .none
                                                                                    }
                                                                                    else {
                                                                                        
                                                                                        let itemGood = item.item as! TShopGood
                                                                                        let viewCell = cell as! TMenuItemFullTableViewCell
                                                                                        
                                                                                        viewCell.layoutIfNeeded()
                                                                                        
                                                                                        viewCell.buttonMore.setTitle("menu_more_ddetails".localized, for: UIControlState())
                                                                                        viewCell.quantityTitle.text = "menu_quantity".localized
                                                                                        
                                                                                        viewCell.addSeparator()
                                                                                        viewCell.goodTitle.text = itemGood.title
                                                                                        viewCell.goodDescription.text = itemGood.goodDescription
                                                                                        viewCell.price.text = String(itemGood.price) + " \u{20BD}"
                                                                                        viewCell.selectionStyle = .none
                                                                                        
                                                                                        if item.userData == nil {
                                                                                            
                                                                                            item.userData = 1
                                                                                        }
                                                                                        
                                                                                        viewCell.quantity.text = String(item.userData as! Int)
                                                                                        
                                                                                        viewCell.buttonPlus.bnd_tap.observe(with: {_ in
                                                                                            
                                                                                            var count = item.userData as! Int
                                                                                            count += 1
                                                                                            item.userData = count
                                                                                            viewCell.quantity.text = String(count)
                                                                                            
                                                                                        }).disposeIn(viewCell.bag)
                                                                                        
                                                                                        viewCell.buttonMinus.bnd_tap.observe(with: {_ in 
                                                                                            
                                                                                            if let count = item.userData as? Int , count > 1 {
                                                                                                
                                                                                                var quantity = count
                                                                                                quantity -= 1
                                                                                                item.userData = quantity
                                                                                                viewCell.quantity.text = String(quantity)
                                                                                            }
                                                                                            
                                                                                        }).disposeIn(viewCell.bag)
                                                                                    }
                                                                                }
            })
        }
    }
    
    func createDataSource() {
        
        guard self.dataSource.sections.filter({ $0.sectionType as? SectionTypeEnum == SectionTypeEnum.companyInfo }).first == nil else {
            
            self.addGoods()
            return
        }
        
        let section = CollectionSection()
        section.sectionType = SectionTypeEnum.companyInfo
        
        section.initializeCellWithReusableIdentifierOrNibName("CompanyImageMenu", item: self.companyImage) { (cell, item) in
            
            let viewCell = cell as! TCompanyImageMenuTableViewCell
            
            viewCell.layoutIfNeeded()
            
            viewCell.point.isHidden = true
            viewCell.title.isHidden = true
            
            if let companyImage = item.item as? TImage {
                
                let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
                viewCell.companyImage.af_setImage(withURL: URL(string: companyImage.url)!, filter: filter)
            }
            
            viewCell.selectionStyle = .none
        }
        
        section.initializeCellWithReusableIdentifierOrNibName("WorkingTimeViewCell", item: company) { (cell, item) in
            
            let viewCell = cell as! TWorkingTimeTableViewCell
            viewCell.selectionStyle = .none
            
            if let company = item.item as? TCompanyAddress , company.averageOrderTime.count == 2 {
                
                let min = company.averageOrderTime[0].value
                let max = company.averageOrderTime[1].value
                
                if let workingHours = self.company!.todayWorkingHours {
                    
                    if workingHours.count == 2 {
                        
                        viewCell.setWorkingTimeAndHandlingOrder("\(workingHours[0]) - \(workingHours[1])", handlingOrder: "\(min) - \(max) " + "minutes".localized)
                    }
                }
            }
        }
        
        self.dataSource.sections.append(section)
        self.addGoods()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! TCompanyMenuHeaderView
        header.title.text = self.dataSource.sections[section].title
        
        return header;
    }
    
    // Here is a magic to save height of current cell, otherwise you will get scrolling of table view content when cell will expand
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.cellHeightDictionary[indexPath] = cell.frame.size.height
        
//        if let viewCell = cell as? TCompanyImageMenuTableViewCell {
//            
//            let item = self.itemsSource.sections[indexPath.section].items[indexPath.row]
//            
//            if let companyImage = item.item as? TImage {
//                
//                let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
//                viewCell.companyImage.af_setImageWithURL(NSURL(string: companyImage.url)!, filter: filter)
//            }
//        }
    }
    
    // Here is a magic to save height of current cell, otherwise you will get scrolling of table view content when cell will expand
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = self.cellHeightDictionary[indexPath] {
            
            return height
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section == 0 {
            
            return
        }
        
        let header = view as! TCompanyMenuHeaderView
        
        header.background.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        header.layer.shadowPath = UIBezierPath(rect: header.layer.bounds).cgPath
        header.layer.shadowOffset = CGSize(width: 0, height: 1)
        header.layer.shadowOpacity = 0.5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.01 : 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 0 {
            
            return
        }
        
        let section = self.dataSource.sections[(indexPath as NSIndexPath).section]
        
        if section.sectionType == nil {
            
            return
        }
        
        let item = section.items[(indexPath as NSIndexPath).row]
        item.selected = !item.selected
        
        if item.selected {
            
            self.orderItems.append(item)
        }
        else {
            
            if let index = self.orderItems.index(of: item) {
                
                self.orderItems.remove(at: index)
            }
        }

        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    
    //MARK: - Private methods
    
    fileprivate func loadCompanyMenu() {
        
        if let company = company {
            
            self.loadingStatus = .loading
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }

            Api.sharedInstance.loadCompanyMenu(companyId: company.companyId, pageNumber: self.pageNumber, pageSize: self.pageSize)
                
                .onSuccess(callback: { [weak self] menuPage in
                    
                    self?.loadingStatus = .loaded
                    
                    if let superview = self?.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    self?.menuPage = menuPage
                    
                    for category in menuPage.categories {
                        
                        self?.categories.insert(category)
                    }
                    
                    self?.createDataSource()
                    self?.tableView.reloadData()
                    
                    if self?.pageSize == menuPage.goods.count {
                        
                        self?.canLoadNext = true
                        self?.pageNumber += 1
                    }
                    else {
                        
                        self?.pageNumber = 1
                        self?.canLoadNext = false
                    }
                })
                .onFailure(callback: { [weak self] error in
                    
                    self?.loadingStatus = .failed
                    
                    if let superview = self?.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                })
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
