//
//  TCompanyMenuTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import EZLoadingActivity
import NVActivityIndicatorView
import SwiftOverlays
import SignalKit
import AlamofireImage

class TCompanyMenuTableViewController: UIViewController, UITableViewDelegate {

    var company: TCompany?
    
    var companyImage: TCompanyImage?
    
    var itemsSource = TableViewDataSource()
    
    var menuPage: TCompanyMenuPage?
    
    var showButtonInfo: Bool = false
    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonMakeOrder: UIButton!
    
    
    @IBAction func makeOrderAction(sender: AnyObject) {
    
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.setup()
        
        self.buttonMakeOrder.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        
        self.buttonMakeOrder.enabled = false
        self.buttonMakeOrder.alpha = 0.5
        
//        let frame = self.view.bounds
//        let toolBarHeigth: CGFloat = 44
//        let busyIndicator = NVActivityIndicatorView(frame: CGRect(x: frame.width / 2 - 35, y: frame.height / 2 - 35 - toolBarHeigth , width: 70, height: 70), type: .BallClipRotateMultiple, color: UIColor(hexString: kHexMainPinkColor), padding:0)
//        
//        self.view.addSubview(busyIndicator)
        
        self.title = company?.companyTitle
        
        self.tableView.setup()
        self.tableView.delegate = self
        self.tableView.dataSource = self.itemsSource
        
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
            
//            self.startActivityAnimating(type: .BallClipRotateMultiple, color: UIColor(hexString: kHexMainPinkColor))
            
            self.showWaitOverlay()
            
            Api.sharedInstance.loadCompanyMenu(1)
                
                .onSuccess(callback: { menuPage in
                
                self.removeAllOverlays()
                
                self.menuPage = menuPage
                self.createDataSource()
                self.tableView.reloadData()
                
            }).onFailure(callback: { error in
                
                self.removeAllOverlays()
            })
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.frame.size)
            viewCell.companyImage.af_setImageWithURL(NSURL(string: (item.item as! TCompanyImage).url)!, filter: filter, imageTransition: .None)
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
                
                let category = menuPage!.categories.filter({ $0.id == good.shopCategoryId }).first
                section = CollectionSection(title: category!.title)
                section?.sectionType = good.shopCategoryId
                self.itemsSource.sections.append(section!)
            }
            
            section!.initializeSwappableCellWithReusableIdentifierOrNibName("MenuItemSmallCell", secondIdentifierOrNibName: "MenuItemFullCell", item: good, bindingAction: { (cell, item) in
                
                if item.swappable {
                    
                    if !item.selected {
                        
                        let itemGood = item.item as! TShopGood
                        let viewCell = cell as! TMenuItemSmallTableViewCell
                        
                        viewCell.addSeparator()
                        viewCell.goodTitle.text = itemGood.title
                        viewCell.goodDescription.text = itemGood.goodDescription
                        viewCell.price.text = String(format: "%li \u{20BD}", itemGood.price)
                        viewCell.selectionStyle = .None
                    }
                    else {
                        
                        let itemGood = item.item as! TShopGood
                        let viewCell = cell as! TMenuItemFullTableViewCell
                        
                        viewCell.addSeparator()
                        viewCell.goodTitle.text = itemGood.title
                        viewCell.goodDescription.text = itemGood.goodDescription
                        viewCell.price.text = String(format: "%li \u{20BD}", itemGood.price)
                        viewCell.selectionStyle = .None
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
        
        let item = self.itemsSource.sections[indexPath.section].items[indexPath.row]
        item.selected = !item.selected
        
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
