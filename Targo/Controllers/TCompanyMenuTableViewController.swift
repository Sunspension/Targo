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

private enum SectionTypeEnum: Int {
    
    case CompanyInfo = 001
}


class TCompanyMenuTableViewController: UIViewController, UITableViewDelegate {

    private var pageNumber = 1
    
    private var pageSize = 20
    
    private var canLoadNext = true
    
    private var loadingStatus = TLoadingStatusEnum.Idle
    
    private var categories = Set<TShopCategory>()
    
    var company: TCompanyAddress?
    
    var companyImage: TImage?
    
    var dataSource = TableViewDataSource()
    
    var menuPage: TCompanyMenuPage?
    
    var showButtonInfo: Bool = false
    
    let orderItems = ObservableArray<CollectionSectionItem>()

    var cellHeightDictionary = [NSIndexPath : CGFloat]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonMakeOrder: UIButton!
    
    
    @IBAction func makeOrderAction(sender: AnyObject) {
    
        var goods = Array<(item: TShopGood, count: Int)>()
        
        for item in self.orderItems {
            
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = company?.companyTitle
        self.setup()
        
        self.buttonMakeOrder.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        
        self.buttonMakeOrder.enabled = false
        self.buttonMakeOrder.alpha = 0.5
        
        self.tableView.setup()
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        
        self.orderItems.observe { event in
            
            UIView.beginAnimations("buton", context: nil)
            
            UIView.animateWithDuration(0.2, animations: {
                
                if event.sequence.count == 0 {
                    
                    self.buttonMakeOrder.enabled = false
                    self.buttonMakeOrder.alpha = 0.5
                }
                else {
                    
                    self.buttonMakeOrder.enabled = true
                    self.buttonMakeOrder.alpha = 1
                }
            })
            
            UIView.commitAnimations()
        }
        
        if showButtonInfo {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-info"), style: .Plain, target: self, action: #selector(TCompanyMenuTableViewController.openInfo))
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.tableView.registerNib(UINib(nibName: "TCompanyImageMenuTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "CompanyImageMenu")
        
        self.tableView.registerNib(UINib(nibName: "TCompanyMenuHeaderView", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        self.tableView.registerNib(UINib(nibName: "TMenuItemSmallTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "MenuItemSmallCell")
        
        self.tableView.registerNib(UINib(nibName: "TMenuItemFullTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "MenuItemFullCell")
        
        self.loadCompanyMenu()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if self.loadingStatus != .Loading {
            
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
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            
            controller.openMapNavigationAction = {
                
                if let company = self.company {
                    
                    if let mapViewController = self.instantiateViewControllerWithIdentifierOrNibName("CompaniesOnMaps") as? TCompaniesOnMapsViewController {
                        
                        mapViewController.companies = [company]
                        
                        if let image = self.companyImage {
                            
                            mapViewController.images = [image]
                        }
                        
                        mapViewController.reason = OpenMapsReasonEnum.OneCompany
                        
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
                                                                                
                                                                                let indexPath = item.indexPath
                                                                                
                                                                                if indexPath.section == self.dataSource.sections.count - 1
                                                                                    && indexPath.row + 10
                                                                                    >= self.dataSource.sections[indexPath.section].items.count
                                                                                    && self.canLoadNext
                                                                                    && self.loadingStatus != .Loading {
                                                                                    
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
                                                                                        viewCell.selectionStyle = .None
                                                                                    }
                                                                                    else {
                                                                                        
                                                                                        let itemGood = item.item as! TShopGood
                                                                                        let viewCell = cell as! TMenuItemFullTableViewCell
                                                                                        
                                                                                        viewCell.layoutIfNeeded()
                                                                                        
                                                                                        viewCell.buttonMore.setTitle("menu_more_ddetails".localized, forState: .Normal)
                                                                                        viewCell.quantityTitle.text = "menu_quantity".localized
                                                                                        
                                                                                        viewCell.addSeparator()
                                                                                        viewCell.goodTitle.text = itemGood.title
                                                                                        viewCell.goodDescription.text = itemGood.goodDescription
                                                                                        viewCell.price.text = String(itemGood.price) + " \u{20BD}"
                                                                                        viewCell.selectionStyle = .None
                                                                                        
                                                                                        if item.userData == nil {
                                                                                            
                                                                                            item.userData = 1
                                                                                        }
                                                                                        
                                                                                        viewCell.quantity.text = String(item.userData as! Int)
                                                                                        
                                                                                        viewCell.buttonPlus.bnd_tap.observe({
                                                                                            
                                                                                            var count = item.userData as! Int
                                                                                            count += 1
                                                                                            item.userData = count
                                                                                            viewCell.quantity.text = String(count)
                                                                                            
                                                                                        }).disposeIn(viewCell.bag)
                                                                                        
                                                                                        viewCell.buttonMinus.bnd_tap.observe({
                                                                                            
                                                                                            if let count = item.userData as? Int where count > 1 {
                                                                                                
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
        
        guard self.dataSource.sections.filter({ $0.sectionType as? SectionTypeEnum == SectionTypeEnum.CompanyInfo }).first == nil else {
            
            self.addGoods()
            return
        }
        
        let section = CollectionSection()
        section.sectionType = SectionTypeEnum.CompanyInfo
        
        section.initializeCellWithReusableIdentifierOrNibName("CompanyImageMenu", item: self.companyImage) { (cell, item) in
            
            let viewCell = cell as! TCompanyImageMenuTableViewCell
            
            viewCell.layoutIfNeeded()
            
            viewCell.point.hidden = true
            viewCell.title.hidden = true
            
            if let companyImage = item.item as? TImage {
                
                let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
                viewCell.companyImage.af_setImageWithURL(NSURL(string: companyImage.url)!, filter: filter)
            }
            
            viewCell.selectionStyle = .None
        }
        
        section.initializeCellWithReusableIdentifierOrNibName("WorkingTimeViewCell", item: company) { (cell, item) in
            
            let viewCell = cell as! TWorkingTimeTableViewCell
            viewCell.selectionStyle = .None
            
            if let company = item.item as? TCompanyAddress where company.averageOrderTime.count == 2 {
                
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as! TCompanyMenuHeaderView
        header.title.text = self.dataSource.sections[section].title
        
        return header;
    }
    
    // Here is a magic to save height of current cell, otherwise you will get scrolling of table view content when cell will expand
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
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
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let height = self.cellHeightDictionary[indexPath] {
            
            return height
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section == 0 {
            
            return
        }
        
        let header = view as! TCompanyMenuHeaderView
        
        header.background.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        header.layer.shadowPath = UIBezierPath(rect: header.layer.bounds).CGPath
        header.layer.shadowOffset = CGSize(width: 0, height: 1)
        header.layer.shadowOpacity = 0.5
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.01 : 30
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            return
        }
        
        let section = self.dataSource.sections[indexPath.section]
        
        if section.sectionType == nil {
            
            return
        }
        
        let item = section.items[indexPath.row]
        item.selected = !item.selected
        
        if item.selected {
            
            self.orderItems.append(item)
        }
        else {
            
            if let index = self.orderItems.indexOf(item) {
                
                self.orderItems.removeAtIndex(index)
            }
        }

        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    
    //MARK: - Private methods
    
    private func loadCompanyMenu() {
        
        if let company = company {
            
            self.loadingStatus = .Loading
            
            if let superview = self.view.superview {
                
                SwiftOverlays.showCenteredWaitOverlay(superview)
            }

            Api.sharedInstance.loadCompanyMenu(company.companyId, pageNumber: self.pageNumber, pageSize: self.pageSize)
                
                .onSuccess(callback: { [weak self] menuPage in
                    
                    self?.loadingStatus = .Loaded
                    
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
                    
                    self?.loadingStatus = .Failed
                    
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
