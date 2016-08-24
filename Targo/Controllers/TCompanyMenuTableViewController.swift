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

class TCompanyMenuTableViewController: UIViewController, UITableViewDelegate {

    var company: TCompanyAddress?
    
    var companyImage: TCompanyImage?
    
    var itemsSource = TableViewDataSource()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        
        self.buttonMakeOrder.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        
        self.buttonMakeOrder.enabled = false
        self.buttonMakeOrder.alpha = 0.5
        
        self.title = company?.companyTitle
        
        self.tableView.setup()
        self.tableView.delegate = self
        self.tableView.dataSource = self.itemsSource
        
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
        
        if let company = company {
            
            self.showWaitOverlay()
            
            Api.sharedInstance.loadCompanyMenu(company.companyId)
                
                .onSuccess(callback: { [weak self] menuPage in
                
                self?.removeAllOverlays()
                
                self?.menuPage = menuPage
                self?.createDataSource()
                self?.tableView.reloadData()
                
            }).onFailure(callback: { [weak self] error in
                
                self?.removeAllOverlays()
            })
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setup()
    }
    
    func openInfo() {
        
        if let controller =  self.instantiateViewControllerWithIdentifierOrNibName("CompanyInfoController") as? TCompanyInfoTableViewController {
            
            controller.company = self.company
            controller.companyImage = self.companyImage
            
            controller.makeOrderNavigationAction = {
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func createDataSource() {
        
        let section = CollectionSection()
        
        section.initializeCellWithReusableIdentifierOrNibName("CompanyImageMenu", item: self.companyImage) { (cell, item) in
            
            let viewCell = cell as! TCompanyImageMenuTableViewCell
            
            if let companyImage = item.item as? TCompanyImage {
                
                let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.frame.size)
                viewCell.companyImage.af_setImageWithURL(NSURL(string: companyImage.url)!, filter: filter, imageTransition: .None)
            }
            
            viewCell.selectionStyle = .None
        }
        
        section.initializeCellWithReusableIdentifierOrNibName("WorkingTimeViewCell", item: company) { (cell, item) in
        
            let viewCell = cell as! TWorkingTimeTableViewCell
            viewCell.selectionStyle = .None
            viewCell.setWorkingTimeAndHandlingOrder("11:00 - 00:00", handlingOrder: "20 - 37 minutes")
        }
        
        self.itemsSource.sections.append(section)
        
        for good in self.menuPage!.goods {
            
            var section = self.itemsSource.sections.filter({ $0.sectionType as? Int == good.shopCategoryId }).first
            
            if (section == nil) {
                
                let category = menuPage!.categories.filter({ $0.id == good.shopCategoryId && $0.id != 0 }).first
                section = CollectionSection(title: category?.title ?? "Акция")
                section?.sectionType = good.shopCategoryId
                self.itemsSource.sections.append(section!)
            }
            
            section!.initializeSwappableCellWithReusableIdentifierOrNibName("MenuItemSmallCell",
                                                                            secondIdentifierOrNibName: "MenuItemFullCell",
                                                                            item: good,
                                                                            bindingAction: { (cell, item) in
                                                                                
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("sectionHeader") as! TCompanyMenuHeaderView
        header.title.text = self.itemsSource.sections[section].title
        
        return header;
    }
    
    // Here is a magic to save height of current cell, otherwise you will get scrolling of table view content when cell will expand
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        self.cellHeightDictionary[indexPath] = cell.frame.size.height
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
        header.layer.shadowOffset = CGSize(width: 0, height: 2)
        header.layer.shadowOpacity = 0.5
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.01 : 30
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = self.itemsSource.sections[indexPath.section]
        
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
